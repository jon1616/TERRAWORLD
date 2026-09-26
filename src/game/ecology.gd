class_name Ecology
extends Node
## La catena alimentare e le popolazioni (voce 57). Le creature cacciano e brucano da sole (`BhCaccia`, `BhPascola`,
## aggiunte da `Creature.setup` secondo la famiglia); qui si tiene il conto di ciò che succede:
## - **popolazioni per zona** (una zona = `ZONE` colonne): ogni famiglia ha un valore (1 = normale) che moltiplica la
##   frequenza con cui nasce lì (`Fauna.weight_of`). Cacciare una famiglia la fa calare; i predatori crescono se le
##   prede abbondano e calano se mancano, gli erbivori il contrario; lasciate stare, tornano verso l'equilibrio
##   (`step`). Salvate in `world_meta["popolazioni"]`.
## - l'erba brucata (la vista si ridisegna) e le colture mangiate dalle famiglie `pest`.
## Voce 58: i **nidi** (`world_meta["nidi"]` = {"x,y": {fam, eggs, t, fed}}, nati da `PassNidi`; i mondi di prima li
## ricevono al primo ingresso). Le creature di una famiglia con i nidi nascono dai nidi della zona (`nest_spawn`); ogni
## nido fa un uovo ogni `EGG_TIME` secondi (fino a 3; nutrito il doppio in fretta); clic destro = prendere un uovo,
## nutrirlo con il cibo della famiglia, o distruggerlo con piccone o ascia (la zona si svuota di quella famiglia).
## Le **migrazioni**: all'alba e al tramonto i branchi delle famiglie `migrate` si spostano tutti dalla stessa parte.

const ZONE := 200
const STEP := 5.0                      # secondi tra un passo e l'altro del modello
const RATE := 0.025                    # quanto si avvicina all'equilibrio a ogni passo
const MIN := 0.15
const MAX := 1.8

var m: Node2D
var pops := {}                         # zona (int, come testo nel salvataggio) → {famiglia: valore}
var hunts := 0                         # prede prese dai predatori (per le prove)
var grazed := 0                        # erba e colture mangiate
var _t := STEP
var nests := {}                        # "x,y" -> {fam, eggs, t, fed}
const EGG_TIME := 240.0
const EGG_MAX := 3
const NEST_CHANCE := 0.65              # quante nascite (delle famiglie con i nidi) partono da un nido
const MIGRATION := 50.0                # secondi di migrazione
var _was_night := false
var _mig_t := 0.0
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	var saved: Dictionary = m.world_meta.get("popolazioni", {})
	for z in saved:
		pops[int(z)] = (saved[z] as Dictionary).duplicate()
	m.world_meta["popolazioni"] = pops
	m.fauna.pop_factor = factor
	m.fauna.killed.connect(func(c: Creature) -> void: change(c.position.x, FamiliesData.family_of(c.id), -0.08))
	m.fauna.hunted.connect(_on_hunt)
	m.fauna.grazed.connect(_on_graze)
	_rng.randomize()
	# i nidi: dal generatore, o (mondi di prima) costruiti adesso
	if not m.world_meta.has("nidi"):
		var notes: Dictionary = m.world.gen_notes.get("nidi", {})
		if notes.is_empty() and not m.world.gen_notes.has("nidi"):
			var c := GenContext.new(m.world.world_seed ^ 0x4E1D)
			PassNidi.new().run(m.world, c)
			notes = c.notes.get("nidi", {})
		var ns := {}
		for k in notes:
			ns[k] = {"fam": notes[k], "eggs": 1, "t": 0.0, "fed": 0.0}
		m.world_meta["nidi"] = ns
	nests = m.world_meta["nidi"]
	m.fauna.nest_hook = nest_spawn
	_was_night = m.day.is_night()


static func zone_of(x: float) -> int:
	return floori(x / 16.0 / ZONE)


## Quanto una famiglia nasce in un punto del mondo (1 = normale).
func factor(x: float, fam: String) -> float:
	return float((pops.get(zone_of(x), {}) as Dictionary).get(fam, 1.0))


func change(x: float, fam: String, d: float) -> void:
	if fam == "":
		return
	var z := zone_of(x)
	if not pops.has(z):
		pops[z] = {}
	pops[z][fam] = clampf(float(pops[z].get(fam, 1.0)) + d, MIN, MAX)


func _on_hunt(prey: Creature, pred: Creature) -> void:
	hunts += 1
	change(prey.position.x, FamiliesData.family_of(prey.id), -0.03)
	change(pred.position.x, FamiliesData.family_of(pred.id), 0.02)


func _on_graze(c: Creature, cell: Vector2i) -> void:
	grazed += 1
	if m.world.crops.has(cell):
		m.world.crops.erase(cell)
		m.world.set_decor(cell.x, cell.y, 0)
		m.hud.toast("Qualcosa ha mangiato una coltura del giardino!")
	else:
		m.world.set_decor(cell.x, cell.y, 0)
	m.view.refresh_around(cell)


func _process(dt: float) -> void:
	_eggs(dt)
	_migrations(dt)
	_t -= dt
	if _t > 0.0:
		return
	_t = STEP
	step(pops)


func _eggs(dt: float) -> void:
	for k in nests:
		var n: Dictionary = nests[k]
		if int(n["eggs"]) >= EGG_MAX:
			continue
		var fed := float(n.get("fed", 0.0))
		n["t"] = float(n["t"]) + dt * (2.0 if fed > 0.0 else 1.0)
		n["fed"] = maxf(fed - dt, 0.0)
		if float(n["t"]) >= EGG_TIME:
			n["t"] = 0.0
			n["eggs"] = int(n["eggs"]) + 1


static func key(o: Vector2i) -> String:
	return "%d,%d" % [o.x, o.y]


static func cell_of(k: String) -> Vector2i:
	return Vector2i(int(k.get_slice(",", 0)), int(k.get_slice(",", 1)))


## Un nido nell'anello delle nascite attorno al Germogliato (celle `pc`): [specie, cella] o [] se non ce n'è.
func nest_spawn(pc: Vector2i) -> Array:
	if _rng.randf() > NEST_CHANCE:
		return []
	var ok := []
	for k in nests:
		var o := cell_of(k)
		var d := Vector2(o - pc).length()
		if d >= DangerData.SPAWN_MIN and d <= DangerData.SPAWN_MAX * 1.3 and m.world.stations.has(o):
			ok.append(k)
	if ok.is_empty():
		return []
	var k := String(ok[_rng.randi_range(0, ok.size() - 1)])
	var fam := String(nests[k]["fam"])
	var members: Array = FamiliesData.FAMILIES[fam]["members"]
	var o := cell_of(k)
	return [String(members[_rng.randi_range(0, members.size() - 1)]), Vector2i(o.x, o.y + int(StationsData.STATIONS[m.world.stations[o]]["size"][1]) - 1)]


## Clic destro su un nido (da `Interact`): con piccone o ascia lo distrugge, con il cibo della famiglia lo nutre,
## altrimenti prende un uovo se c'è. Vero se ha fatto qualcosa.
func touch_nest(o: Vector2i) -> bool:
	var n: Dictionary = nests.get(key(o), {})
	if n.is_empty():
		return false
	var fam := String(n["fam"])
	var held: Dictionary = m.hud.current()
	var use := String(held.get("use", ""))
	var fname := String(FamiliesData.FAMILIES[fam]["name"]).to_lower()
	if use in ["scava", "abbatti"]:
		destroy_nest(o)
		m.hud.toast("Il nido è distrutto: in questa zona ci saranno meno %s" % fname)
		return true
	if String(held.get("id", "")) in HerdData.tame_of(fam).get("diet", []):
		m.character.bisaccia.remove(String(held["id"]), 1)
		n["fed"] = 600.0
		change(o.x * 16.0, fam, 0.3)
		m.hud.toast("Hai nutrito il nido: le uova verranno più in fretta, e ci saranno più %s" % fname)
		return true
	if int(n["eggs"]) <= 0:
		m.hud.toast("Il nido è vuoto: le uova tornano con il tempo (e più in fretta se lo nutri)")
		return true
	n["eggs"] = int(n["eggs"]) - 1
	var members: Array = FamiliesData.FAMILIES[fam]["members"]
	var species := String(members[_rng.randi_range(0, members.size() - 1)])
	var egg := {"id": "uovo", "n": 1, "dati": {"fam": fam, "specie": FamiliesData.roll_variant(species, _rng)}}
	if m.character.bisaccia.add_stack(egg) > 0:
		m.drops.spawn("uovo", 1, Vector2(o) * 16.0, egg["dati"])
	m.objectives.bump("uova")
	m.erbario.note_nest(fam)                                      # voce 61
	m.hud.toast("Un uovo di %s (%d nel nido)" % [fname, int(n["eggs"])])
	return true


func destroy_nest(o: Vector2i) -> void:
	var n: Dictionary = nests.get(key(o), {})
	if n.is_empty():
		return
	change(o.x * 16.0, String(n["fam"]), -0.5)
	nests.erase(key(o))
	m.world.stations.erase(o)
	m.view.remove_station(o)
	m.light.dirty = true
	Fx.puff(m.fx, Vector2(o) * 16.0 + Vector2(8, 8), Color(1.0, 0.9, 0.7))
	m.drops.spawn("legno", 2, Vector2(o) * 16.0 + Vector2(8, 8))


## All'alba e al tramonto i branchi migrano (voce 58): ogni famiglia `migrate` prende una direzione per un po'.
func _migrations(dt: float) -> void:
	var night: bool = m.day.is_night()
	if night != _was_night:
		_was_night = night
		start_migration()
	if _mig_t > 0.0:
		_mig_t -= dt
		if _mig_t <= 0.0:
			m.fauna.migration.clear()


func start_migration() -> void:
	m.fauna.migration.clear()
	for f in FamiliesData.FAMILIES:
		if FamiliesData.FAMILIES[f].get("migrate", false):
			m.fauna.migration[f] = -1.0 if _rng.randf() < 0.5 else 1.0
	_mig_t = MIGRATION


## Un passo del modello, per ogni zona: ogni famiglia va verso il suo equilibrio, che per i predatori dipende da
## quante prede ci sono e per gli erbivori da quanti predatori li cacciano.
static func step(p: Dictionary) -> void:
	for z in p:
		var zone: Dictionary = p[z]
		var next := {}
		for f in zone:
			var fd: Dictionary = FamiliesData.FAMILIES.get(f, {})
			var target := 1.0
			if fd.has("prey"):
				target = clampf(0.5 + 0.6 * _avg(zone, fd["prey"]), 0.3, 1.6)
			elif String(fd.get("role", "")) == "erbivoro":
				target = clampf(1.3 - 0.4 * _avg(zone, _hunters_of(String(f))), 0.5, 1.6)
			var v := float(zone[f])
			next[f] = clampf(v + (target - v) * RATE, MIN, MAX)
		for f in next:
			zone[f] = snappedf(float(next[f]), 0.001)


static func _avg(zone: Dictionary, fams: Array) -> float:
	if fams.is_empty():
		return 1.0
	var s := 0.0
	for f in fams:
		s += float(zone.get(f, 1.0))
	return s / fams.size()


static func _hunters_of(fam: String) -> Array:
	var out := []
	for f in FamiliesData.FAMILIES:
		if fam in FamiliesData.FAMILIES[f].get("prey", []):
			out.append(f)
	return out
