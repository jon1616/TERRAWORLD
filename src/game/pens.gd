class_name Pens
extends Node
## I recinti e l'Incubatrice (voce 59).
## Recinto di radici: fino a `HerdData.PEN_CAP` creature della mandria ci vivono (gironzolano da `PEN_LEFT` tessere a
## sinistra a `PEN_RIGHT` a destra della stazione). La stazione è anche la mangiatoia: nelle sue caselle si mette il
## cibo (clic destro, come una cesta) e ci finisce ciò che producono. Ogni creatura ha fame (`HUNGER_RATE`), mangia
## da sola dalla mangiatoia, e se non ha fame produce (`TAME.produce`) più in fretta se è felice, se ha compagne della
## stessa famiglia nel recinto e se è di livello alto. Il tempo passa anche mentre sei altrove (`OFFLINE_CAP`): si
## conta con l'orologio (`rec["t"]`).
## Incubatrice: le uova posate nelle sue caselle si schiudono dopo `HATCH` secondi (anche lontano), in vasetti con la
## creatura già tua.
## Un recinto ripreso o distrutto: le sue creature vanno a riposare nel Giardino.

const S := 16
const SHOW := 110.0                    # tessere: le creature del recinto si vedono entro questa distanza

var m: Node2D
var pens: Array[Vector2i] = []
var incubators: Array[Vector2i] = []
var hatched := 0                       # uova schiuse (le prove le contano)
var laid := 0                          # voce 60: uova delle coppie
var _t := 1.0
var _scan_t := 0.0
var _caught_up := false
var _rng := RandomNumberGenerator.new()


## Voce 142: una stalla nel mondo fa produrre di più la mandria (lo scrive `Rooms`).
static var room_mult := 1.0


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()


static func key(o: Vector2i) -> String:
	return "%d,%d" % [o.x, o.y]


static func cell_of(k: String) -> Vector2i:
	return Vector2i(int(k.get_slice(",", 0)), int(k.get_slice(",", 1)))


func _scan() -> void:
	pens.clear()
	incubators.clear()
	for o in m.world.stations:
		match String(m.world.stations[o]):
			"recinto":
				pens.append(o)
			"incubatrice":
				incubators.append(o)
	# chi aveva il recinto in questo mondo e non lo trova più va a riposare
	for r in m.herd.records():
		if r["stato"] == "recinto" and r["mondo"] == m.world_id and not cell_of(String(r["recinto"])) in pens:
			m.herd.set_state(r, "riposo")
			m.hud.toast("Il recinto di %s non c'è più: è andata a riposare nel Giardino" % r["nome"])


## Le schede che vivono nel recinto `k` di questo mondo.
func members(k: String) -> Array:
	return m.herd.records().filter(func(r: Dictionary) -> bool:
		return r["stato"] == "recinto" and r["mondo"] == m.world_id and r["recinto"] == k)


## Il recinto con posto più vicino a un punto ("" se non ce n'è).
func free_pen(near: Vector2) -> String:
	_scan()
	var best := ""
	var bd := 1e18
	for o in pens:
		var d := (Vector2(o) * S).distance_squared_to(near)
		if d < bd and members(key(o)).size() < HerdData.PEN_CAP:
			bd = d
			best = key(o)
	return best


## Deve stare in scena (recinto di questo mondo, non troppo lontano)?
func shows(rec: Dictionary) -> bool:
	if rec["mondo"] != m.world_id:
		return false
	var o := cell_of(String(rec["recinto"]))
	return (Vector2(o) * S).distance_to(m.player.position) < SHOW * S


## Da dove a dove gironzola (in pixel, x).
func range_of(rec: Dictionary) -> Vector2:
	var o := cell_of(String(rec["recinto"]))
	return Vector2((o.x - HerdData.PEN_LEFT) * S + 8.0, (o.x + HerdData.PEN_RIGHT) * S + 8.0)


## L'altezza del pavimento del recinto (in pixel).
func pen_y(rec: Dictionary) -> float:
	var o := cell_of(String(rec["recinto"]))
	return (o.y + 2) * float(S)


func spawn_pos(rec: Dictionary) -> Vector2:
	var o := cell_of(String(rec["recinto"]))
	var d := CreaturesData.get_data(String(rec["specie"]))
	var x := o.x + _rng.randi_range(-HerdData.PEN_LEFT + 1, HerdData.PEN_RIGHT - 1)
	return Vector2(x * S + 8, pen_y(rec) - float(d["half"][1]) - 0.1)


var plows: Array = []                  # voce 243: una cella di recinto per ogni creatura che ara (`HerdJobs.plow_at`)


func _process(dt: float) -> void:
	if not m.built:
		return
	_scan_t -= dt
	if _scan_t <= 0.0:
		_scan_t = 3.0
		_scan()
	if not _caught_up:
		_caught_up = true
		catch_up()
	_t -= dt
	if _t > 0.0:
		return
	_t = 1.0
	plows.clear()
	for o in pens:
		if not m.world.stations.has(o):
			continue
		for r in members(key(o)):
			tick(r, 1.0)
			if HerdJobs.job_of(r) == "aratura" and float(r["fame"]) < 0.8:
				plows.append(o)
		breed(key(o), 1.0)
	for o in incubators:
		incubate(o)


## Il tempo passato mentre il Germogliato era altrove (al più `OFFLINE_CAP`), a passi di 20 s.
func catch_up() -> void:
	var now := Time.get_unix_time_from_system()
	for r in m.herd.records():
		if r["stato"] != "recinto" or r["mondo"] != m.world_id:
			continue
		var el := clampf(now - float(r.get("t", now)), 0.0, HerdData.OFFLINE_CAP)
		while el > 0.0:
			var st := minf(el, 20.0)
			tick(r, st)
			el -= st
	# voce 60: le coppie, per il tempo passato (al più un uovo per coppia: poi aspettano)
	for o in pens:
		breed(key(o), HerdData.OFFLINE_CAP)


## Un passo di vita nel recinto: fame, pasto dalla mangiatoia, umore, guarigione, produzione.
func tick(rec: Dictionary, dt: float) -> void:
	var o := cell_of(String(rec["recinto"]))
	if not m.world.stations.has(o):
		return
	var chest: Bisaccia = m.world.chest_at(o)
	var t := Herd.tame_data(rec)
	rec["fame"] = minf(float(rec["fame"]) + HerdData.HUNGER_RATE * dt, 1.0)
	if float(rec["fame"]) >= 0.5:
		for food in t["diet"]:
			if chest.count(String(food)) > 0:
				chest.remove(String(food), 1)
				rec["fame"] = maxf(float(rec["fame"]) - 0.7, 0.0)
				rec["felice"] = minf(float(rec["felice"]) + 0.1, 1.0)
				m.herd.gain_xp(rec, 1, true)
				break
	HerdJobs.work(m, rec, chest, dt, _rng)                 # voce 243: i lavori della mandria
	var fam := Herd.family_of(rec)
	var friends := 0
	var mates := members(String(rec["recinto"]))
	for r in mates:
		if r != rec and Herd.family_of(r) == fam:
			friends += 1
	friends += HerdJobs.singers(mates, rec)
	var mood := (1.0 if float(rec["fame"]) < 0.6 else 0.2) + 0.1 * friends
	rec["felice"] = clampf(move_toward(float(rec["felice"]), mood, dt / 600.0), 0.0, 1.0)
	rec["vita"] = minf(float(rec["vita"]) + dt / HerdData.REST_HEAL, 1.0)
	var p: Array = t["produce"]
	var secs := float(p[1])
	if float(rec["fame"]) < 0.8:
		rec["prod"] = float(rec["prod"]) + dt * rate(rec, friends) * room_mult   # voce 142: la stalla
	if float(rec["prod"]) >= secs:
		var q := _rng.randi_range(int(p[2]), int(p[3]))
		if chest.add(String(p[0]), q) > 0:
			rec["prod"] = secs                 # la mangiatoia è piena: aspetta
		else:
			rec["prod"] = float(rec["prod"]) - secs
			m.herd.gain_xp(rec, 1, true)
			m.objectives.bump("prodotti")
	rec["t"] = Time.get_unix_time_from_system()


## Quanto in fretta produce (1 = il tempo di `produce`).
static func rate(rec: Dictionary, friends: int) -> float:
	var g: Dictionary = rec.get("doti", {})
	return (0.4 + 0.8 * float(rec["felice"])) * (1.0 + 0.04 * (mini(int(rec["lvl"]), HerdData.LVL_WORK) - 1)) * (1.0 + 0.15 * friends) \
		* Breeding.mult(g, "resa")


## L'Incubatrice: ogni uovo ricorda quando è stato posato (orologio); passato `HATCH`, si schiude in un vasetto.
func incubate(o: Vector2i) -> void:
	if String(m.world.stations.get(o, "")) != "incubatrice":
		return                                  # tolta dopo l'ultimo giro dell'elenco (si rifà ogni 3 s)
	var chest: Bisaccia = m.world.chest_at(o)
	var now := Time.get_unix_time_from_system()
	for i in chest.slots.size():
		if chest.id_at(i) != "uovo":
			continue
		var d: Dictionary = chest.slots[i].get("dati", {})
		if not d.has("specie"):
			continue
		if not d.has("cova"):
			d["cova"] = now
			chest.slots[i]["dati"] = d
		if now - float(d["cova"]) < HerdData.HATCH * float(d.get("cova_mult", 1.0)):
			continue
		var rec: Dictionary = m.herd.new_record(String(d["specie"]), String(d.get("nato", "uovo")), 1.0, d.get("doti", {}))
		var coat := String(rec["doti"].get("manto", ""))
		if coat != "":
			if not m.character.erbario.has("manti"):
				m.character.erbario["manti"] = {}
			m.character.erbario["manti"][coat] = 1           # voce 60: i manti visti nascere
			if BreedData.is_rare(coat):
				m.objectives.bump("manti_rari")
				m.hud.toast("Un manto %s! Una rarità" % BreedData.COATS[coat]["name"])
		var lmsg := Lineage.on_hatch(m, rec)                 # voce 241: collezione dei manti e stirpi pure
		if lmsg != "":
			m.hud.toast(lmsg)
		rec["stato"] = "vasetto"
		chest.slots[i] = {"id": "creatura", "n": 1, "dati": rec}
		chest.changed.emit()
		hatched += 1
		m.objectives.bump("schiuse")
		m.erbario.note_tamed(Herd.family_of(rec))                # voce 61
		m.objectives.bump("addomesticate")
		if (Vector2(o) * S).distance_to(m.player.position) < 30.0 * S:
			Fx.puff(m.fx, Vector2(o) * S + Vector2(16, 8), Herd.HEARTS)
			m.hud.toast("Un uovo si è schiuso nell'Incubatrice: %s ti aspetta nel vasetto" % rec["nome"])


## Voce 60: le coppie dello stesso recinto, sazie e contente, fanno un uovo ogni `BREED_TIME` secondi (poi riposano
## `COOLDOWN` secondi). L'uovo va nella mangiatoia, con la specie e le doti del figlio già decise (`Breeding.child`).
func breed(k: String, dt: float) -> void:
	var ms := members(k)
	var now := Time.get_unix_time_from_system()
	for a in ms:
		var pu := int(a.get("coppia", -1))
		if pu < 0 or int(a["uid"]) > pu:
			continue                       # ogni coppia una volta sola, dalla parte dell'uid più piccolo
		var b := {}
		for r in ms:
			if int(r["uid"]) == pu:
				b = r
		if b.is_empty() or float(a.get("amore_cd", 0.0)) > now:
			continue
		if minf(float(a["felice"]), float(b["felice"])) < 0.7 or maxf(float(a["fame"]), float(b["fame"])) >= 0.6:
			continue
		a["amore"] = float(a.get("amore", 0.0)) + dt
		if float(a["amore"]) < BreedData.BREED_TIME:
			continue
		var c := Breeding.child(a, b, _rng)
		var egg := {"id": "uovo", "n": 1, "dati": {"fam": Herd.family_of(a), "specie": c["specie"], "doti": c["doti"],
			"nato": "allevata", "genitori": [a["nome"], b["nome"]]}}
		if m.world.chest_at(cell_of(k)).add_stack(egg) > 0:
			a["amore"] = BreedData.BREED_TIME         # la mangiatoia è piena: l'uovo aspetta
			continue
		a["amore"] = 0.0
		a["amore_cd"] = now + BreedData.COOLDOWN
		laid += 1
		m.objectives.bump("uova_allevate")
		if (Vector2(cell_of(k)) * S).distance_to(m.player.position) < 40.0 * S:
			m.hud.toast("%s e %s hanno fatto un uovo: è nella mangiatoia del recinto" % [a["nome"], b["nome"]])
