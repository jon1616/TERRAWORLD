class_name StyleTurrets
extends Node2D
## Le piante da combattimento dello stile Radice (Roadmap 40, voce 367; dati in `StylesData`): un seme-torre piantato
## sul campo cresce in un attimo e tira spine da solo alla creatura più vicina, ogni `TURRET_EVERY` secondi, per
## `TURRET_TIME` secondi; poi appassisce. Al più `TURRET_MAX` insieme (tre con i metalli del Risveglio): la più vecchia
## lascia il posto. Le spine portano il gesto del metallo del seme. Non si salvano.

const S := 16

var styles: Styles
var _list: Array = []                    # {node, t, every, dmg, opts}
var _tex := {}


func _ready() -> void:
	z_index = 4


func count() -> int:
	return _list.size()


func cap(tier: int) -> int:
	return StylesData.TURRET_MAX_HIGH if tier >= 7 else StylesData.TURRET_MAX


## Pianta un seme-torre vicino al punto (appoggiato al primo pavimento sotto, entro sei tessere).
func plant(at: Vector2, dmg: int, opts: Dictionary, tier: int, item_id: String) -> bool:
	var m: Node2D = styles.m
	var c := Vector2i(floori(at.x / S), floori(at.y / S))
	var ground := -1
	for dy in 7:
		if m.world.solid(c.x, c.y + dy + 1) and not m.world.solid(c.x, c.y + dy):
			ground = c.y + dy
			break
	if ground < 0 or (Vector2(c.x * S + 8, ground * S + 8)).distance_to(m.player.position) > 12.0 * S:
		m.hud.toast("Il seme-torre va piantato su un pavimento vicino")
		return false
	while _list.size() >= cap(tier):
		var old: Dictionary = _list.pop_front()
		_wilt(old)
	if not _tex.has(item_id):
		_tex[item_id] = ImageTexture.create_from_image(ItemIcons.of(item_id))
	var sp := Sprite2D.new()
	sp.texture = _tex[item_id]
	sp.position = Vector2(c.x * S + 8, ground * S + 8)
	sp.scale = Vector2(0.4, 0.4)
	add_child(sp)
	var tw := sp.create_tween()
	tw.tween_property(sp, "scale", Vector2(1.1, 1.1), 0.35).set_trans(Tween.TRANS_BACK)
	var o := opts.duplicate()
	o["look"] = "scheggia"
	_list.append({"node": sp, "t": StylesData.TURRET_TIME, "every": 0.2, "dmg": dmg, "opts": o})
	Fx.puff(m.fx, sp.position, Color(0.9, 1.7, 0.9))
	return true


func _process(dt: float) -> void:
	if styles == null or styles.m == null or not styles.m.built:
		return
	var m: Node2D = styles.m
	for i in range(_list.size() - 1, -1, -1):
		var tu: Dictionary = _list[i]
		tu["t"] = float(tu["t"]) - dt
		if float(tu["t"]) <= 0.0:
			_list.remove_at(i)
			_wilt(tu)
			continue
		tu["every"] = float(tu["every"]) - dt
		if float(tu["every"]) > 0.0:
			continue
		var pos: Vector2 = (tu["node"] as Sprite2D).position + Vector2(0, -6)
		var best: Creature = null
		var bd := StylesData.TURRET_RANGE * S
		for c in m.fauna.list:
			if is_instance_valid(c) and c.tame == null and not c.calm:
				var d: float = c.position.distance_to(pos)
				if d < bd:
					bd = d
					best = c
		if best == null:
			tu["every"] = 0.25
			continue
		tu["every"] = StylesData.TURRET_EVERY
		var dir := (best.position - pos).normalized()
		m.shots.fire(pos + dir * 6.0, dir * 380.0, 0.0, int(tu["dmg"]), true, 1.0, tu["opts"])


func _wilt(tu: Dictionary) -> void:
	var sp: Sprite2D = tu["node"]
	if is_instance_valid(sp):
		Fx.puff(styles.m.fx, sp.position, Color(0.8, 1.0, 0.6))
		sp.queue_free()


func clear() -> void:
	for tu in _list:
		_wilt(tu)
	_list.clear()
