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
var _t := 1.0
var _scan_t := 0.0
var _caught_up := false
var _rng := RandomNumberGenerator.new()


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
	for o in pens:
		for r in members(key(o)):
			tick(r, 1.0)
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
	var fam := Herd.family_of(rec)
	var friends := 0
	for r in members(String(rec["recinto"])):
		if r != rec and Herd.family_of(r) == fam:
			friends += 1
	var mood := (1.0 if float(rec["fame"]) < 0.6 else 0.2) + 0.1 * friends
	rec["felice"] = clampf(move_toward(float(rec["felice"]), mood, dt / 600.0), 0.0, 1.0)
	rec["vita"] = minf(float(rec["vita"]) + dt / HerdData.REST_HEAL, 1.0)
	var p: Array = t["produce"]
	var secs := float(p[1])
	if float(rec["fame"]) < 0.8:
		rec["prod"] = float(rec["prod"]) + dt * rate(rec, friends)
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
	return (0.4 + 0.8 * float(rec["felice"])) * (1.0 + 0.04 * (int(rec["lvl"]) - 1)) * (1.0 + 0.15 * friends) \
		* float(g.get("resa", 1.0))


## L'Incubatrice: ogni uovo ricorda quando è stato posato (orologio); passato `HATCH`, si schiude in un vasetto.
func incubate(o: Vector2i) -> void:
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
		rec["stato"] = "vasetto"
		chest.slots[i] = {"id": "creatura", "n": 1, "dati": rec}
		chest.changed.emit()
		hatched += 1
		m.objectives.bump("schiuse")
		m.objectives.bump("addomesticate")
		if (Vector2(o) * S).distance_to(m.player.position) < 30.0 * S:
			Fx.puff(m.fx, Vector2(o) * S + Vector2(16, 8), Herd.HEARTS)
			m.hud.toast("Un uovo si è schiuso nell'Incubatrice: %s ti aspetta nel vasetto" % rec["nome"])
