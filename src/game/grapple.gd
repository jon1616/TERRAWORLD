class_name Grapple
extends Node
## Il rampino (voce 31): con un rampino in mano il clic lancia la radice verso il mouse. Se entro la sua portata
## incontra la roccia si aggancia e il Germogliato viene tirato fino al punto (`Player.hook`), dove resta appeso; il
## salto lo sgancia, e anche S, allontanarsi troppo o scavare via la tessera d'aggancio. La corda è una radice tesa
## disegnata dalla mano al punto.

const S := 16

var m: Node2D
var rope: Line2D
var range_px := 0.0
var hits := 0                          # agganci riusciti (per le prove)
var _cell := Vector2i.ZERO             # la tessera di roccia a cui è agganciato


func setup(main: Node2D) -> void:
	m = main
	rope = Line2D.new()
	rope.width = 2.0
	rope.default_color = Color("#6e4426")
	rope.z_index = 4
	rope.visible = false
	m.fx.add_child(rope)
	m.player.air_jumped.connect(func() -> void:
		Fx.puff(m.fx, m.player.position + Vector2(0, Player.HALF.y), Color(0.9, 1.1, 1.2))
		m.sfx.play("soffio", m.player.position))


## Lancia il rampino verso un punto: true se si è agganciato alla roccia.
func fire(item: String, target: Vector2) -> bool:
	var hk: Dictionary = ItemsData.get_item(item).get("hook", {})
	if hk.is_empty():
		return false
	range_px = float(hk["range"]) * S
	var from: Vector2 = m.player.position + Vector2(0, -6)
	var dir := (target - from).normalized()
	m.sfx.play("uncino", from)
	var d := 0.0
	while d < range_px:
		d += 4.0
		var p := from + dir * d
		if m.world.solid(floori(p.x / S), floori(p.y / S)):
			_cell = Vector2i(floori(p.x / S), floori(p.y / S))
			m.player.hook = p - dir * 3.0
			m.player.hook_speed = float(hk["speed"])
			m.player.jump_buf = 0.0
			hits += 1
			return true
	# mancato: la radice si allunga per un attimo e torna
	rope.points = PackedVector2Array([from, from + dir * range_px])
	rope.visible = true
	get_tree().create_timer(0.12).timeout.connect(func() -> void:
		if m.player.hook == Vector2.INF:
			rope.visible = false)
	return false


func _process(_dt: float) -> void:
	var p: Player = m.player
	if p.hook == Vector2.INF:
		if rope.visible and rope.points.size() == 2 and rope.points[0].distance_to(p.position + Vector2(0, -6)) > 40.0:
			rope.visible = false
		return
	var gone: bool = not m.world.solid(_cell.x, _cell.y) or m.life.dead
	var too_far := p.position.distance_to(p.hook) > range_px * 1.6 + 32.0
	var down := p.control and Keys.held("giu")
	if gone or too_far or down:
		p.hook = Vector2.INF
		rope.visible = false
		return
	# dal pugno, se la posa del Germogliato lo ha (la tavola degli speciali), altrimenti dalla spalla
	var from: Vector2 = p.hand_world if p.hand_world != Vector2.INF else p.position + Vector2(p.facing * 4, -6)
	rope.points = PackedVector2Array([from, p.hook])
	rope.visible = true
