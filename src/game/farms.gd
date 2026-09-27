class_name Farms
extends Node
## Le farm automatiche (voce 89, dati in `FarmData`): esche che chiamano le creature del loro bottino, tramogge che
## aspirano gli oggetti caduti, nastri che li spingono, la Radice-ancora che tiene viva la farm da lontano e il tetto
## di rendita per zona. Le creature chiamate seguono le regole di sempre (strato, bioma, notte, buio, torce): la farm la
## mette a punto il giocatore. Le chiamate portano il segno "farm" (`Fauna.kill` chiede `loot_gate` per il bottino).

const TICK := 0.25
const REACH := 70.0 * 16.0             # come le trappole: senza Radice-ancora lavora solo vicino a te

var m: Node2D
var baits: Array = []                  # [origine, id]
var hoppers: Array = []                # [origine, id]
var anchors: Array = []                # centri in px
var belts: Array = []                  # [rettangolo in px, verso]
var called := 0                        # creature chiamate (prove)
var pulled := 0                        # oggetti aspirati dalle tramogge (prove, obiettivi)
var _count := -1
var _t := 0.0
var _wait := {}                        # "x,y" -> secondi alla prossima chiamata
var _tired_toast := 0.0
var _rng := RandomNumberGenerator.new()
static var _by_item := {}              # oggetto -> specie che lo lasciano


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	m.fauna.keep_alive = anchored
	m.fauna.loot_gate = _gate
	rebuild()


func rebuild() -> void:
	baits.clear()
	hoppers.clear()
	anchors.clear()
	belts.clear()
	for o in m.world.stations:
		var id := String(m.world.stations[o])
		if FarmData.is_bait(id):
			baits.append([o, id])
		elif FarmData.is_hopper(id):
			hoppers.append([o, id])
		elif id == "radice_ancora":
			anchors.append((Vector2(o) + Vector2(0.5, 1.0)) * 16.0)
		elif id.begins_with("nastro_"):
			belts.append([Rect2(Vector2(o) * 16.0 + Vector2(0, -4), Vector2(16, 20)), 1.0 if id == "nastro_dx" else -1.0])
	_count = m.world.stations.size()


## Un punto è tenuto vivo da una Radice-ancora?
func anchored(pos: Vector2) -> bool:
	for a in anchors:
		if (a as Vector2).distance_to(pos) <= FarmData.ANCHOR_R * 16.0:
			return true
	return false


func _alive_here(pos: Vector2) -> bool:
	return pos.distance_to(m.player.position) <= REACH or anchored(pos)


## Le specie che lasciano un oggetto (dal bottino delle creature), senza Guardiani.
static func species_of(item: String) -> Array:
	if _by_item.is_empty():
		for id in CreaturesData.CREATURES:
			var cd: Dictionary = CreaturesData.CREATURES[id]
			if cd.get("boss", false) or (cd.get("strata", []) as Array).is_empty():
				continue
			for e in LootData.TABLES.get(String(cd.get("loot", "")), []):
				var list: Array = _by_item.get(String(e["item"]), [])
				if not id in list:
					list.append(id)
				_by_item[String(e["item"])] = list
	return _by_item.get(item, [])


## Chi può chiamare un'esca in o: {"ok": [specie], "why": perché nessuna}.
func callable_at(o: Vector2i) -> Dictionary:
	var bag: Bisaccia = m.world.chest_at(o)
	var item := String(bag.slots[0].get("id", "")) if not bag.is_empty() else ""
	if item == "":
		return {"ok": [], "why": "Posaci un pezzo di bottino (clic destro)", "item": ""}
	var sp := species_of(item)
	if sp.is_empty():
		return {"ok": [], "why": "Nessuna creatura lascia questo oggetto", "item": item}
	var stratum := StrataData.at(m.world, o.x, o.y)
	var biome := "avvizzito" if Blight.surface_blighted(m.world, o.x) else String(BiomesData.BIOMES[BiomesData.at(m.world, o.x)]["id"])
	var ok := []
	var why := ""
	for id in sp:
		var cd: Dictionary = CreaturesData.CREATURES[id]
		if not stratum in cd["strata"]:
			why = "Qui non ci vive: %s" % StrataData.STRATA[stratum]["name"]
		elif stratum == 0 and cd.has("biomes") and not biome in cd["biomes"]:
			why = "Vive in un altro bioma"
		elif cd.get("night", false) and stratum == 0 and not m.fauna.night and biome != "avvizzito":
			why = "Esce solo di notte"
		else:
			ok.append(id)
	return {"ok": ok, "why": why, "item": item}


func _process(dt: float) -> void:
	if not m.built:
		return
	_tired_toast = maxf(_tired_toast - dt, 0.0)
	# i nastri spingono a ogni fotogramma
	for b in belts:
		if _alive_here((b[0] as Rect2).get_center()):
			m.drops.push(b[0], FarmData.BELT_SPEED * float(b[1]))
	_t -= dt
	if _t > 0.0:
		return
	_t = TICK
	if m.world.stations.size() != _count:
		rebuild()
	for h in hoppers:
		var c := (Vector2(h[0]) + Vector2(0.5, 0.5)) * 16.0
		if _alive_here(c):
			var n: int = m.drops.pull_into(c, float(FarmData.HOPPERS[h[1]]["r"]) * 16.0, m.world.chest_at(h[0]))
			if n > 0:
				pulled += n
				m.objectives.bump("tramoggia", n)
	for b in baits:
		_bait(b[0], String(b[1]))


## Un'esca: se è ora, chiama una creatura del suo bottino in un posto buono attorno.
func _bait(o: Vector2i, id: String) -> void:
	var at := (Vector2(o) + Vector2(0.5, 0.5)) * 16.0
	if not _alive_here(at):
		return
	var k := "%d,%d" % [o.x, o.y]
	_wait[k] = float(_wait.get(k, 0.0)) - TICK
	if float(_wait[k]) > 0.0:
		return
	var bd: Dictionary = FarmData.BAITS[id]
	_wait[k] = float(bd["every"])
	var mine := 0
	for c in m.fauna.list:
		if c.get_meta("farm", "") == k:
			mine += 1
	if mine >= int(bd["cap"]):
		return
	var ca := callable_at(o)
	if (ca["ok"] as Array).is_empty():
		return
	var sp := String(ca["ok"][_rng.randi_range(0, ca["ok"].size() - 1)])
	var cell := _spot(o, int(bd["r"]), CreaturesData.CREATURES[sp].get("fly", false))
	if cell.x < 0:
		return
	var stratum := StrataData.at(m.world, cell.x, cell.y)
	var vid := FamiliesData.roll_variant(sp, _rng, m.fauna.elem_bias(stratum, ""), m.fauna.danger, m.fauna.grade)
	var cr: Creature = m.fauna.add(vid, Vector2(cell.x * 16 + 8, (cell.y + 1) * 16 - CreaturesData.get_data(vid)["half"][1] - 0.1))
	var mult: float = float(StrataData.STRATA[stratum]["danger"]) * m.fauna.vigor_mult
	cr.strengthen(mult, mult * DangerData.DAMAGE)
	cr.extra = true                        # non conta nel tetto delle nascite normali
	cr.set_meta("farm", k)
	called += 1
	# un'esca consumata ogni `per` chiamate
	var used := int(m.world_meta.get("esche_usate", {}).get(k, 0)) + 1
	var all: Dictionary = m.world_meta.get("esche_usate", {})
	if used >= int(bd["per"]):
		used = 0
		m.world.chest_at(o).remove(String(ca["item"]), 1)
	all[k] = used
	m.world_meta["esche_usate"] = all


## Un posto per la creatura chiamata: libero, a terra (se non vola), al buio sotto terra, lontano da torce e da te.
func _spot(o: Vector2i, r: int, fly: bool) -> Vector2i:
	var w: World = m.world
	var pc: Vector2i = m.player_cell()
	for tries in 16:
		var c := o + Vector2i(_rng.randi_range(-r, r), _rng.randi_range(-r / 2, r / 2))
		for dy in 8:
			var q := c + Vector2i(0, dy if not fly else 0)
			if not w.inside(q.x, q.y + 1) or not m.fauna._free(q.x, q.y) or not (fly or w.solid(q.x, q.y + 1)):
				continue
			if Vector2(q - pc).length() < FarmData.AWAY or w.torch_near(q, FarmData.TORCH):
				break
			if StrataData.at(w, q.x, q.y) > 0 and not m.fauna._dark(q):
				break
			return q
	return Vector2i(-1, -1)


## Il tetto di rendita (chiamato da `Fauna.kill`): quanti giri di bottino restano a una creatura chiamata (1 o 0).
func _gate(c: Creature) -> int:
	if not c.has_meta("farm"):
		return 1
	var z := "%d,%d" % [floori(c.position.x / 16.0 / FarmData.ZONE), floori(c.position.y / 16.0 / FarmData.ZONE)]
	var all: Dictionary = m.world_meta.get("farm_rese", {})
	var now := Time.get_unix_time_from_system()
	var e: Array = all.get(z, [now, 0])
	if now - float(e[0]) > FarmData.ZONE_TIME:
		e = [now, 0]
	e[1] = int(e[1]) + 1
	all[z] = e
	m.world_meta["farm_rese"] = all
	if int(e[1]) > FarmData.ZONE_CAP:
		if _tired_toast <= 0.0:
			_tired_toast = 30.0
			m.hud.toast("Questa zona è stanca: la farm renderà di nuovo tra %d minuti" % ceili((FarmData.ZONE_TIME - (now - float(e[0]))) / 60.0))
		return 0
	return 1


## Quanto ha già reso una zona (per la scheda dell'esca): [creature, tetto].
func zone_yield(pos: Vector2) -> Array:
	var z := "%d,%d" % [floori(pos.x / 16.0 / FarmData.ZONE), floori(pos.y / 16.0 / FarmData.ZONE)]
	var e: Array = m.world_meta.get("farm_rese", {}).get(z, [0, 0])
	if Time.get_unix_time_from_system() - float(e[0]) > FarmData.ZONE_TIME:
		return [0, FarmData.ZONE_CAP]
	return [int(e[1]), FarmData.ZONE_CAP]


## Clic destro su un nastro: cambia verso.
func flip_belt(o: Vector2i) -> bool:
	var id := String(m.world.stations[o])
	m.view.remove_station(o)
	m.world.stations[o] = "nastro_sx" if id == "nastro_dx" else "nastro_dx"
	m.view.add_station(o)
	rebuild()
	return true
