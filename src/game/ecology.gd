class_name Ecology
extends Node
## La catena alimentare e le popolazioni (voce 57). Le creature cacciano e brucano da sole (`BhCaccia`, `BhPascola`,
## aggiunte da `Creature.setup` secondo la famiglia); qui si tiene il conto di ciò che succede:
## - **popolazioni per zona** (una zona = `ZONE` colonne): ogni famiglia ha un valore (1 = normale) che moltiplica la
##   frequenza con cui nasce lì (`Fauna.weight_of`). Cacciare una famiglia la fa calare; i predatori crescono se le
##   prede abbondano e calano se mancano, gli erbivori il contrario; lasciate stare, tornano verso l'equilibrio
##   (`step`). Salvate in `world_meta["popolazioni"]`.
## - l'erba brucata (la vista si ridisegna) e le colture mangiate dalle famiglie `pest`.

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
	_t -= dt
	if _t > 0.0:
		return
	_t = STEP
	step(pops)


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
