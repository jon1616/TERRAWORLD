class_name WorldPregen
extends RefCounted
## Il mondo preparato in anticipo (28 set 2026): quando si pianta un Seme in un'Aiuola, il mondo che ne nascerà
## comincia a generarsi in un thread in sottofondo, **su un solo processore** (così la luce e il resto del gioco non
## aspettano); attraversando il portale, se è pronto ed è nato con gli stessi parametri, `MainBoot.new_world` lo usa
## subito. Se non è ancora pronto si genera come sempre, su tutti i processori (non si aspetta il lavoro lento).
## Il risultato è lo stesso mondo in ogni caso: le fasce del generatore danno lo stesso risultato in fila o insieme
## (`GenBands`, provato da `TestsGenRepeat`).

const MAX_JOBS := 2                    # quanti mondi al più in memoria (uno è ~15 MB)

static var _jobs: Array = []           # {"key", "world", "thread", "times"}


## Comincia a preparare il mondo di un seme (se non c'è già).
static func start(sd: int, gw: int, gh: int, params: Dictionary) -> void:
	var key := key_of(sd, gw, gh, params)
	for j in _jobs:
		if j["key"] == key:
			return
	_drop_old()
	if _jobs.size() >= MAX_JOBS:
		return
	var job := {"key": key, "world": World.new(), "times": []}
	var p := params.duplicate(true)
	p["seriale"] = true                    # un processore solo (`GenBands`): il gioco intanto va avanti
	var th := Thread.new()
	job["thread"] = th
	var w: World = job["world"]
	th.start(func() -> Array: return WorldGen.generate(w, sd, gw, gh, p))
	_jobs.append(job)


## Il mondo già pronto per questi parametri ({} se non c'è o non è finito): chi lo prende lo toglie dall'elenco.
static func take(sd: int, gw: int, gh: int, params: Dictionary) -> Dictionary:
	var key := key_of(sd, gw, gh, params)
	for j in _jobs:
		if j["key"] == key and not (j["thread"] as Thread).is_alive():
			j["times"] = (j["thread"] as Thread).wait_to_finish()
			_jobs.erase(j)
			return j
	return {}


## Quanti mondi si stanno preparando o sono pronti (per le prove).
static func count() -> int:
	return _jobs.size()


## Chiudendo il gioco nessun thread deve restare a metà.
static func finish() -> void:
	for j in _jobs:
		(j["thread"] as Thread).wait_to_finish()
	_jobs.clear()


## I lavori finiti più vecchi lasciano il posto (l'ultimo Seme piantato è quello che si attraverserà).
static func _drop_old() -> void:
	while _jobs.size() >= MAX_JOBS:
		var gone := -1
		for i in _jobs.size():
			if not (_jobs[i]["thread"] as Thread).is_alive():
				gone = i
				break
		if gone < 0:
			return
		(_jobs[gone]["thread"] as Thread).wait_to_finish()
		_jobs.remove_at(gone)


## La chiave di un mondo: seme, misure e parametri, con i numeri interi scritti sempre allo stesso modo (i parametri
## passano dal salvataggio JSON, che rilegge 3 come 3.0) e le chiavi in ordine.
static func key_of(sd: int, gw: int, gh: int, params: Dictionary) -> String:
	var p := params.duplicate(true)
	p.erase("seriale")
	return "%d|%d|%d|%s" % [sd, gw, gh, JSON.stringify(_norm(p), "", true)]


static func _norm(v: Variant) -> Variant:
	if v is float and is_equal_approx(v, roundf(v)):
		return int(v)
	if v is Array:
		return (v as Array).map(func(x: Variant) -> Variant: return _norm(x))
	if v is Dictionary:
		var d := {}
		for k in v:
			d[str(k)] = _norm(v[k])
		return d
	return v
