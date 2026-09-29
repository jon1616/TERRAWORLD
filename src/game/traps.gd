class_name Traps
extends Node2D
## Le trappole (voce 88, dati in `TrapsData`): tiene l'elenco di quelle piazzate e, a piccoli intervalli, guarda chi
## entra nella loro area. Colpiscono da sole: danno (con l'elemento, le debolezze e le reazioni di `Elements`), gelo,
## spinta. Ogni trappola aspetta "cool" secondi prima di colpire di nuovo la stessa creatura. Le creature uccise danno
## il bottino di sempre (`Fauna.kill`): sono il cuore delle farm (voce 89). Spuntoni, lama e pressa feriscono anche il
## Germogliato se è armata. Clic destro = disarma o riarma (`world_meta["trappole_ferme"]`). Lavorano solo entro
## `REACH` tessere dal giocatore, come le creature che esistono.

const TICK := 0.1
const REACH := 70.0 * 16.0

var m: Node2D
var list: Array = []                   # [origine, tipo, forza, centro in px]
var kills := 0                         # creature abbattute dalle trappole (prove, diario)
var _count := -1
var _t := 0.0
var _cool := {}                        # "x,y|id creatura" -> secondi che mancano
var _flash: Array = []                 # [da, a, colore, tempo] i lampi dei colpi


func setup(main: Node2D) -> void:
	m = main
	z_as_relative = false
	z_index = 24
	rebuild()


func rebuild() -> void:
	list.clear()
	for o in m.world.stations:
		var d := TrapsData.info(String(m.world.stations[o]))
		if not d.is_empty():
			list.append([o, String(d["type"]), float(d["k"]), (Vector2(o) + Vector2(0.5, 0.5)) * 16.0])
	_count = m.world.stations_rev()


static func _key(o: Vector2i) -> String:
	return "%d,%d" % [o.x, o.y]


func armed(o: Vector2i) -> bool:
	return not _key(o) in (m.world_meta.get("trappole_ferme", []) as Array)


## Clic destro: disarma o riarma.
func toggle(o: Vector2i) -> bool:
	var off: Array = m.world_meta.get("trappole_ferme", [])
	var k := _key(o)
	if k in off:
		off.erase(k)
		m.hud.toast("Trappola armata")
	else:
		off.append(k)
		m.hud.toast("Trappola disarmata")
	m.world_meta["trappole_ferme"] = off
	m.sfx.play("apri", Vector2(o) * 16.0)
	queue_redraw()
	return true


## L'area di una trappola: chi ci sta dentro viene colpito.
static func area(o: Vector2i, td: Dictionary) -> Rect2:
	var cell := Rect2(Vector2(o) * 16.0, Vector2(16, 16))
	match String(td["area"]):
		"attorno":
			return cell.grow(float(td["r"]) * 16.0 - 8.0)
		"sotto":
			return Rect2(Vector2(o.x, o.y + 1) * 16.0, Vector2(16, float(td["r"]) * 16.0))
		"linea":
			return Rect2(Vector2(o.x - float(td["r"]), o.y) * 16.0, Vector2(float(td["r"]) * 32.0 + 16.0, 16.0))
	return cell.grow(-2.0)


func _process(dt: float) -> void:
	if not m.built:
		return
	for i in range(_flash.size() - 1, -1, -1):
		_flash[i][3] = float(_flash[i][3]) - dt
		if float(_flash[i][3]) <= 0.0:
			_flash.remove_at(i)
	if not _flash.is_empty() or visible:
		queue_redraw()
	for k in _cool.keys():
		_cool[k] = float(_cool[k]) - dt
		if float(_cool[k]) <= 0.0:
			_cool.erase(k)
	_t -= dt
	if _t > 0.0:
		return
	_t = TICK
	if m.world.stations_rev() != _count:
		rebuild()
	var pp: Vector2 = m.player.position
	for e in list:
		var o: Vector2i = e[0]
		if ((e[3] as Vector2).distance_to(pp) > REACH and not (m.farms != null and m.farms.anchored(e[3]))) or not armed(o):
			continue
		var td: Dictionary = TrapsData.TYPES[e[1]]
		var box := area(o, td)
		for c in m.fauna.list.duplicate():
			if not is_instance_valid(c) or c.tame or not box.intersects(c.rect()):
				continue
			var ck := "%s|%d" % [_key(o), c.get_instance_id()]
			if _cool.has(ck):
				continue
			_cool[ck] = float(td["cool"])
			_hit(e, td, c)
		if td.get("hurts", false) and box.intersects(Rect2(pp - Player.HALF, Player.HALF * 2.0)):
			var pk := _key(o) + "|g"
			if not _cool.has(pk):
				_cool[pk] = float(td["cool"]) * 2.0
				m.combat.hurt_player(maxi(roundi(float(td["dmg"]) * float(e[2]) * 0.5), 1), (e[3] as Vector2).x)


## Un colpo di trappola su una creatura.
func _hit(e: Array, td: Dictionary, c: Creature) -> void:
	var at: Vector2 = e[3]
	var col := Color(String(td["color"]))
	_flash.append([at, c.position, col, 0.18])
	var chill := float(td.get("chill", 0.0))
	if chill > 0.0:
		c.chill_t = maxf(c.chill_t, chill * float(e[2]))
	var dmg := roundi(float(td["dmg"]) * float(e[2]))
	if dmg <= 0:
		return
	dmg = maxi(roundi(dmg * m.fauna._zm(c.position, "guardia")), 1)   # voce 87: lo Stendardo di guardia
	var elem := String(td.get("elem", ""))
	if elem != "":
		dmg = Elements.hit(m.combat, c, elem, dmg)
		if not is_instance_valid(c) or not m.fauna.list.has(c):
			return
	m.sfx.play("colpito", c.position)
	if c.take_hit(dmg, at.x, float(td.get("knock", 0.5))):
		kills += 1
		m.objectives.bump("prede_trappole")
		m.fauna.kill(c)


## I lampi dei colpi, e con una trappola in mano le aree di quelle vicine (rosse se disarmate).
func _draw() -> void:
	for f in _flash:
		var a := float(f[3]) / 0.18
		draw_line(f[0], f[1], Color(f[2] as Color, 0.8 * a), 2.0)
		draw_circle(f[1], 5.0 * a, Color(f[2] as Color, 0.6 * a))
	var held := str(ItemsData.get_item(String(m.hud.current().get("id", ""))).get("place", ""))
	if not TrapsData.is_trap(held):
		return
	var pp: Vector2 = m.player.position
	for e in list:
		if (e[3] as Vector2).distance_to(pp) < 900.0:
			var col := Color(String(TrapsData.TYPES[e[1]]["color"])) if armed(e[0]) else Color("#ff4a4a")
			draw_rect(area(e[0], TrapsData.TYPES[e[1]]), Color(col, 0.7), false, 1.5)


## Clic destro sulla Leva delle trappole: la gira, e tutte le trappole entro `LEVER_R` tessere la seguono.
func lever(o: Vector2i) -> bool:
	var up := String(m.world.stations[o]) == "leva_trappole"
	m.view.remove_station(o)
	m.world.stations[o] = "leva_trappole_su" if up else "leva_trappole"
	m.view.add_station(o)
	var off: Array = m.world_meta.get("trappole_ferme", [])
	var n := 0
	for e in list:
		if Vector2(e[0] - o).length() <= TrapsData.LEVER_R:
			n += 1
			off.erase(_key(e[0]))
			if not up:
				off.append(_key(e[0]))
	m.world_meta["trappole_ferme"] = off
	m.hud.toast("%s: %d trappole" % ["Armate" if up else "Ferme", n])
	m.sfx.play("apri", Vector2(o) * 16.0)
	return true


## Il riassunto per la scheda di una trappola.
static func describe(id: String) -> String:
	var d := TrapsData.info(id)
	if d.is_empty():
		return ""
	var td: Dictionary = TrapsData.TYPES[d["type"]]
	var bits: Array[String] = [String(td["desc"])]
	if int(td["dmg"]) > 0:
		bits.append("danno %d%s" % [roundi(float(td["dmg"]) * float(d["k"])),
			" di " + String(ElementsData.ELEMENTS[td["elem"]]["name"]).to_lower() if td.has("elem") else ""])
	bits.append("ogni %.1f s" % float(td["cool"]))
	return " · ".join(bits)
