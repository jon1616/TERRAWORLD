class_name Spells
extends Node
## I bastoni di Linfa (voce 21): tenendo premuto il clic sinistro il bastone in mano tira il suo incantesimo
## (`SpellsData`) verso il mouse, a ogni giro secondo la sua velocità, finché c'è Linfa. Il danno segue l'arma, il
## suo tratto e la Pozione di vigore, come le altre armi. La Linfa ricresce da sola (`Vitals`).

const SEEK_RANGE := 16.0 * 16.0        # gli incantesimi che inseguono cercano creature entro 16 tessere

var m: Node2D
var auto_aim := Vector2.INF            # per le prove: punto verso cui tirare senza mouse
var auto_fire := false
var casts := 0                         # incantesimi tirati (per le prove)
var _t := 0.0
var _warned := false


func setup(main: Node2D) -> void:
	m = main
	m.shots.seek = nearest
	m.shots.light = m.light


func _process(dt: float) -> void:
	_t = maxf(_t - dt, 0.0)
	if not m.built:
		return
	var item: Dictionary = m.hud.current()
	if item["use"] != "incanta":
		return
	var active: bool = m.actions.enabled and not m.hud.is_open()
	if not (auto_fire or (active and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT))):
		_warned = false
		return
	var it := ItemsData.get_item(item["id"])
	var tr := String(item.get("tratto", ""))
	var target: Vector2 = auto_aim if auto_aim != Vector2.INF else m.fx.get_global_mouse_position()
	var from: Vector2 = m.player.position + Vector2(0, -6)
	var d := target - from
	m.player.facing = 1 if d.x >= 0.0 else -1
	m.player.aim = atan2(absf(d.x), d.y)
	if _t > 0.0:
		return
	var cost := int(it["linfa"])
	if m.vitals.linfa < cost:
		if not _warned:
			m.hud.toast("Linfa esaurita: aspetta che ricresca o bevi una Pozione di Linfa")
			_warned = true
		_t = 0.25
		return
	m.vitals.linfa -= cost
	m.vitals.changed.emit()
	var st := Gear.stats(item)                  # voce 50: tratto e fascia (le verghe: la conduzione del metallo)
	_t = 1.0 / (maxf(float(st["speed"]), 0.1) * m.combat.spd_mult)
	var sd: Dictionary = SpellsData.SPELLS[it["spell"]]
	var dmg := roundi(float(st["damage"]) * m.combat._boon() * m.combat.magic_mult)
	var knock := float(st["knockback"]) / 3.0
	var n := int(sd["n"])
	for k in n:
		var dir := d.normalized().rotated((k - (n - 1) / 2.0) * float(sd["spread"]))
		m.shots.fire(from + dir * 8.0, dir * float(sd["speed"]), float(sd["grav"]), dmg, true, knock, sd)
	m.sfx.play("incanto")
	casts += 1


## La creatura più vicina a un punto (per gli incantesimi che inseguono); Vector2.INF se non ce n'è.
func nearest(p: Vector2) -> Vector2:
	var best := Vector2.INF
	var bd := SEEK_RANGE
	for c in m.fauna.list:
		var dd: float = c.position.distance_to(p)
		if dd < bd and not c.calm:
			bd = dd
			best = c.position
	return best
