class_name Crafting
extends RefCounted
## Regole della fabbricazione (nessun disegno): quali stazioni sono vicine, quali ricette si possono usare, se bastano
## i materiali, e il fabbricare vero e proprio sulla Bisaccia.
## Gli ingredienti si prendono dalla Bisaccia e poi dalle casse vicine con «usa per creare» (`pool`, lo aggiorna
## `Storage`): `have` conta, `take` toglie. Ciò che si fabbrica va sempre nella Bisaccia.


## Le casse vicine da cui la creazione prende gli ingredienti (Bisaccia), dalla più vicina.
static var pool: Array = []


## Quanti ne hai, contando anche le casse vicine.
static func have(b: Bisaccia, id: String) -> int:
	var n := b.count(id)
	for c in pool:
		n += (c as Bisaccia).count(id)
	return n


## Tutto ciò che si ha (Bisaccia e casse vicine), contato una volta: id -> quanti. Per l'elenco Creare, che altrimenti
## contava gli stessi oggetti per ogni ingrediente di ogni ricetta.
static func counts(b: Bisaccia) -> Dictionary:
	var out := {}
	for bb in b.all_bags():                       # voce 296: anche le tasche e il basto
		for s in bb.slots:
			if not s.is_empty():
				out[s["id"]] = int(out.get(s["id"], 0)) + int(s["n"])
	for c in pool:
		for s in (c as Bisaccia).slots:
			if not s.is_empty():
				out[s["id"]] = int(out.get(s["id"], 0)) + int(s["n"])
	return out


## Come `can_craft`, con i conteggi già fatti (`counts`).
static func can_craft_with(r: Dictionary, b: Bisaccia, have_n: Dictionary) -> bool:
	for k in r["in"]:
		if int(have_n.get(k, 0)) < int(r["in"][k]):
			return false
	return b.room_for(String(r["out"])) >= int(r["qty"])


static func in_pool(id: String) -> int:
	var n := 0
	for c in pool:
		n += (c as Bisaccia).count(id)
	return n


## Toglie n oggetti: prima dalla Bisaccia, poi dalle casse. False (e niente tolto) se non bastano.
static func take(b: Bisaccia, id: String, n: int) -> bool:
	if have(b, id) < n:
		return false
	var from_bag := mini(b.count(id), n)
	if from_bag > 0:
		b.remove(id, from_bag)
	n -= from_bag
	for c in pool:
		if n <= 0:
			break
		var k := mini((c as Bisaccia).count(id), n)
		if k > 0:
			(c as Bisaccia).remove(id, k)
			n -= k
	return true


## I banchi dove si crea qualcosa: il banco di almeno una ricetta, più Maglio e Telaio (le Lavorazioni). Le altre
## stazioni (lampade, tamburi, arredi, macchine) non sono «banchi vicini» (3 ott 2026, segnalato dall'utente).
static var _craft_st := {}
static func craft_stations() -> Dictionary:
	if _craft_st.is_empty():
		for r in RecipesData.all():
			var st := String(r["station"])
			if st != "":
				_craft_st[st] = true
		_craft_st["maglio"] = true
		_craft_st["telaio"] = true
	return _craft_st


## Stazioni a portata della cella c: {id: true}.
static func stations_near(world: World, c: Vector2i) -> Dictionary:
	var out := {}
	for o in world.stations:
		var id: String = world.stations[o]
		var sd: Dictionary = StationsData.STATIONS[id]
		if sd.has("slots") or sd.get("fixed", false):
			continue                           # ceste, scrigni, Cuore e portale non sono stazioni di lavoro
		if not craft_stations().has(id):
			continue                           # (3 ott 2026) lampade, tamburi, arredi: non si crea niente lì
		var size: Array = sd["size"]
		var r := Rect2i(o, Vector2i(size[0], size[1])).grow(StationsData.craft_reach)
		if r.has_point(c):
			out[id] = true
	return out


## Gli oggetti che il personaggio ha già scoperto (`Character.erbario["oggetti"]`, lo imposta `main`): le ricette delle
## leghe (voce 52) e dei materiali dei geni (voce 53) si vedono solo quando se ne conoscono gli ingredienti, e le loro
## armi quando se ne è avuto il lingotto (sono centinaia: così l'elenco cresce con le scoperte).
static var known := {}
## Roadmap 17: le parole del personaggio (`Character.lingua`) per le ricette scritte (campo `parole`), e un numero che
## cambia a ogni parola confermata (per la memoria delle ricette usabili).
static var words := {}
static var words_version := 0


## Ricette usabili con queste stazioni (quelle «a mano» sempre).
static func available(near: Dictionary) -> Array:
	# (ricordato per banchi vicini e ricette scoperte: con 2000 ricette rifarlo a ogni raccolta costava troppo)
	var key := "%s|%d|%d" % [",".join(near.keys()), known.hash(), words_version]
	if not _avail_cache.has(key):
		if _avail_cache.size() > 64:
			_avail_cache.clear()
		_avail_cache[key] = RecipesData.all().filter(func(r: Dictionary) -> bool:
			return (String(r["station"]) == "" or near.has(String(r["station"]))) and _discovered(r))
	return _avail_cache[key]


static var _avail_cache := {}


static func _discovered(r: Dictionary) -> bool:
	if r.has("parole") and not words_known(r["parole"]):
		return false                                 # Roadmap 17: scritta nella lingua dei Seminatori
	if r.get("ricettario", false):                   # voce 245: un piatto si scopre avendo avuto tutti gli ingredienti
		for k in r["in"]:
			if not known.has(k):
				return false
	var it := ItemsData.get_item(String(r["out"]))
	var mat := String(it.get("mat", ""))
	var md := MaterialsData.get_mat(mat)
	if mat != "" and (md.has("alloy") or md.has("gene") or md.has("spina")):
		return known.has(String(md["bar"]))       # le armi di una lega o di un materiale dei geni (voci 52-53)
	var out := String(r["out"])
	if out.begins_with("lingotto_") and MaterialsData.all().has(out.trim_prefix("lingotto_")):
		var bm := MaterialsData.get_mat(out.trim_prefix("lingotto_"))
		if bm.has("alloy") or bm.has("gene") or bm.has("spina"):
			for k in r["in"]:
				if not known.has(k):
					return false
	return true


static func can_craft(r: Dictionary, b: Bisaccia) -> bool:
	for k in r["in"]:
		if have(b, k) < int(r["in"][k]):
			return false
	return b.room_for(String(r["out"])) >= int(r["qty"])


## Roadmap 20: chi vuole sapere che cosa si è fabbricato (la maestria dei pilastri).
static var crafted := Callable()


static func craft(r: Dictionary, b: Bisaccia, luck := 0.0) -> bool:
	if not can_craft(r, b):
		return false
	if crafted.is_valid():
		crafted.call(r)
	for k in r["in"]:
		take(b, k, int(r["in"][k]))
	var out := String(r["out"])
	if Bisaccia.is_gear(out) and int(r["qty"]) == 1:
		# voce 54: l'equipaggiamento fabbricato nasce con una qualità (e il suo tratto, come sempre)
		var s := {"id": out, "n": 1, "dati": {"q": roll_quality(String(r["station"]), luck)}}
		var t := TraitsData.roll(out)
		if t != "":
			s["tratto"] = t
		if b.add_stack(s) == 0:
			return true
	b.add(out, int(r["qty"]))
	return true


## La qualità di un oggetto fabbricato a una stazione (0 grezzo … 3 capolavoro); la fortuna sposta il tiro in alto.
## Voce 142: la fortuna della qualità dentro un laboratorio (la scrive `Rooms`).
static var room_luck := 0.0


static func roll_quality(station: String, luck := 0.0) -> int:
	luck += room_luck
	var w: Array = TraitsData.QUALITY_WEIGHTS.get(station, TraitsData.QUALITY_WEIGHTS[""])
	var tot := 0
	for x in w:
		tot += int(x)
	var v := randi_range(1, tot)
	var q := 0
	for k in w.size():
		v -= int(w[k])
		if v <= 0:
			q = k
			break
	if luck > 0.0 and randf() < luck and q < w.size() - 1:
		q += 1
	return q


## Rinnova il tratto dell'oggetto nella casella i (al Maglio): costa `TraitsData.REFORGE_COST`, il tratto nuovo è
## sempre diverso dal vecchio. Restituisce il tratto nuovo, o "" se non si può.
static func reforge(b: Bisaccia, i: int) -> String:
	var id := b.id_at(i)
	if id == "" or not Bisaccia.is_gear(id):
		return ""
	for k in TraitsData.REFORGE_COST:
		if have(b, k) < int(TraitsData.REFORGE_COST[k]):
			return ""
	for k in TraitsData.REFORGE_COST:
		take(b, k, int(TraitsData.REFORGE_COST[k]))
	var t := TraitsData.roll(id, null, b.trait_at(i) if b.trait_at(i) != "" else "-")
	b.slots[i]["tratto"] = t
	b.changed.emit()
	return t


## Innesta un'Essenza (di una creatura antica) sull'oggetto nella casella i: il suo tratto speciale prende il posto di
## quello che c'era. Restituisce il tratto nuovo, o "" se non si può.
## Voce 54: se l'oggetto ha un posto libero l'innesto si aggiunge ("dati.innesti"); altrimenti prende il posto del
## tratto di nascita, come prima. Lo stesso tratto non si innesta due volte.
static func graft(b: Bisaccia, i: int, essence: String) -> String:
	var id := b.id_at(i)
	if id == "" or not Bisaccia.is_gear(id) or not TraitsData.can_graft(essence, id):
		return ""
	var t := String(ItemsData.get_item(essence)["graft"])
	if t in Gear.traits(b.slots[i]) or not b.remove(essence, 1):
		return ""
	if Gear.free_slots(b.slots[i]) > 0:
		var dati: Dictionary = b.slots[i].get("dati", {}).duplicate(true)
		var inn: Array = dati.get("innesti", [])
		inn.append(t)
		dati["innesti"] = inn
		b.slots[i]["dati"] = dati
	else:
		b.slots[i]["tratto"] = t
	b.changed.emit()
	return t


## Toglie l'innesto `t` dall'oggetto nella casella i (al Maglio): costa `TraitsData.UNGRAFT_COST`, l'Essenza si perde e
## il posto torna libero. Vero se è riuscito.
static func ungraft(b: Bisaccia, i: int, t: String) -> bool:
	var dati: Dictionary = b.slots[i].get("dati", {}).duplicate(true)
	var inn: Array = dati.get("innesti", [])
	if not t in inn:
		return false
	for k in TraitsData.UNGRAFT_COST:
		if have(b, k) < int(TraitsData.UNGRAFT_COST[k]):
			return false
	for k in TraitsData.UNGRAFT_COST:
		take(b, k, int(TraitsData.UNGRAFT_COST[k]))
	inn.erase(t)
	dati["innesti"] = inn
	b.slots[i]["dati"] = dati
	b.changed.emit()
	return true


## Avvolge una fascia (`FormsData.FASCE`) sul manico dell'oggetto nella casella i (al Telaio, voce 50): consuma il
## materiale, la fascia nuova prende il posto della vecchia. Vero se è riuscito.
static func wrap(b: Bisaccia, i: int, fascia: String) -> bool:
	var it := ItemsData.get_item(b.id_at(i))
	var fd: Dictionary = FormsData.FASCE.get(fascia, {})
	if fd.is_empty() or not String(it.get("form", "")) in FormsData.WRAPPABLE or have(b, String(fd["item"])) < int(fd["n"]):
		return false
	take(b, String(fd["item"]), int(fd["n"]))
	var dati: Dictionary = b.slots[i].get("dati", {}).duplicate(true)
	dati["fascia"] = fascia
	b.slots[i]["dati"] = dati
	b.changed.emit()
	return true


## Roadmap 17, voce 175: incide la parola `word` (certa: lo controlla chi chiama) sull'oggetto nella casella i, al posto
## dell'incisione che c'era. Vero se è riuscito (costo pagato).
static func engrave(b: Bisaccia, i: int, word: String) -> bool:
	var id := b.id_at(i)
	var inc := IncisionsData.of_word(word)
	if id == "" or inc.is_empty() or not Bisaccia.is_gear(id) or not TraitsData.category_of(id) in (inc["for"] as Array):
		return false
	var dati: Dictionary = b.slots[i].get("dati", {}).duplicate(true)
	if String(dati.get("incisione", "")) == String(inc["trait"]):
		return false
	for k in inc["cost"]:
		if have(b, String(k)) < int(inc["cost"][k]):
			return false
	for k in inc["cost"]:
		take(b, String(k), int(inc["cost"][k]))
	dati["incisione"] = String(inc["trait"])
	b.slots[i]["dati"] = dati
	b.changed.emit()
	return true


## Voce 355: risveglia un oggetto (una volta sola): il modo della sua forma, con i materiali del profondo.
static func awaken(b: Bisaccia, i: int) -> bool:
	var id := b.id_at(i)
	var fx := AwakenData.effect_of(id)
	if id == "" or fx == "" or not Bisaccia.is_gear(id):
		return false
	var dati: Dictionary = b.slots[i].get("dati", {}).duplicate(true)
	if String(dati.get("risveglio", "")) != "":
		return false
	var cost := AwakenData.cost_of(id)
	for k in cost:
		if have(b, String(k)) < int(cost[k]):
			return false
	for k in cost:
		take(b, String(k), int(cost[k]))
	dati["risveglio"] = fx
	b.slots[i]["dati"] = dati
	b.changed.emit()
	if awakened_hook.is_valid():
		awakened_hook.call()
	return true


## Chi conta i risvegli (lo collega `Effects`: obiettivi e maestria del combattimento).
static var awakened_hook: Callable


## Roadmap 17: tutte queste parole sono certe?
static func words_known(list: Array) -> bool:
	for w in list:
		var r: Variant = words.get(String(w), {})
		if not r is Dictionary or int((r as Dictionary).get("s", -1)) != 2:
			return false
	return true

