class_name Combat
extends Node
## Il combattimento: colpi in mischia a ogni giro dell'attrezzo in mano (danno, velocità e spinta dall'oggetto), l'arco
## che tira dardi verso il mouse consumandoli dalla Bisaccia, le ferite del Germogliato (contatto con le creature e
## spore) con qualche istante di invulnerabilità, la spinta indietro e il lampeggio.

const MELEE_REACH := Vector2(26, 34)   # area del colpo davanti al Germogliato
const INVULN := 0.7                    # secondi senza ferite dopo un colpo subito
const DART_SPEED := 380.0
const DART_GRAV := 260.0
const DIG_PERIOD := 0.3                # il gesto di piccone e ascia

var m: Node2D                          # la scena di gioco
var player: Player
var fauna: Fauna
var shots: Projectiles
var vitals: Vitals
var bisaccia: Bisaccia
var invuln := 0.0
var _hit_set := {}                     # creature già colpite in questo giro dell'arma
var _cycle := -1
var _bow_t := 0.0
var auto_aim := Vector2.INF            # per le prove: punto verso cui tirare senza mouse
var auto_fire := false


func setup(main: Node2D) -> void:
	m = main
	player = m.player
	fauna = m.fauna
	shots = m.shots
	vitals = m.vitals
	bisaccia = m.character.bisaccia


## Il colpo di un proiettile: i dardi prendono le creature, le spore il Germogliato.
func on_shot(s: Dictionary) -> bool:
	var pos: Vector2 = (s["node"] as Node2D).position
	if s["player"]:
		for c in fauna.list:
			if c.rect().grow(2.0).has_point(pos):
				_strike(c, int(s["damage"]), pos.x - signf(s["vel"].x) * 10.0, float(s["knock"]))
				return true
		return false
	if Rect2(player.position - Player.HALF, Player.HALF * 2.0).has_point(pos):
		hurt_player(int(s["damage"]), pos.x)
		return true
	return false


func _process(dt: float) -> void:
	invuln = maxf(invuln - dt, 0.0)
	player.visible = invuln <= 0.0 or int(invuln * 16.0) % 2 == 0
	if not m.built:
		return
	_contact()
	var item: Dictionary = m.hud.current()
	var it := ItemsData.get_item(item["id"])
	var use: String = item["use"]
	var active: bool = m.actions.enabled and not m.hud.is_open()
	# il ritmo del gesto: le armi secondo la loro velocità, gli attrezzi da scavo sempre uguali
	var spd := float(it.get("speed", 0.0))
	player.swing_period = 1.0 / spd if use == "colpo" and spd > 0.0 else DIG_PERIOD
	_melee(it, use)
	_bow(it, use, active, dt)


## Colpi in mischia: ogni giro dell'attrezzo colpisce una volta ogni creatura nell'area davanti.
func _melee(it: Dictionary, use: String) -> void:
	var sw: bool = player.swinging or player.force_swing
	var dmg := int(it.get("damage", 0))
	if not sw or dmg <= 0 or not use in ["colpo", "scava", "abbatti"]:
		_cycle = -1
		return
	var cyc := int(player.swing_t / player.swing_period)
	if cyc != _cycle:
		_cycle = cyc
		_hit_set.clear()
	var ph := fmod(player.swing_t, player.swing_period) / player.swing_period
	if ph < 0.15:
		return                             # l'attrezzo è ancora alzato
	var area := Rect2(player.position + Vector2(player.facing * MELEE_REACH.x * 0.5 - MELEE_REACH.x * 0.5, -22),
			MELEE_REACH)
	area.position.x += player.facing * 6
	for c in fauna.list.duplicate():
		if not _hit_set.has(c) and area.intersects(c.rect()):
			_hit_set[c] = true
			_strike(c, dmg, player.position.x, float(it.get("knockback", 1.5)) / 3.0)


## Arco: tenendo premuto tira un dardo a ogni giro (secondo la velocità dell'arco), finché ci sono dardi.
func _bow(it: Dictionary, use: String, active: bool, dt: float) -> void:
	_bow_t = maxf(_bow_t - dt, 0.0)
	var aiming := use == "tira" and (auto_fire or (active and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)))
	if not aiming:
		player.aim = NAN
		return
	var target: Vector2 = auto_aim if auto_aim != Vector2.INF else m.fx.get_global_mouse_position()
	var from := player.position + Vector2(0, -6)
	var d := target - from
	player.facing = 1 if d.x >= 0.0 else -1
	player.aim = atan2(absf(d.x), d.y)
	if _bow_t > 0.0:
		return
	if bisaccia.count("dardo") <= 0:
		m.hud.toast("Niente dardi")
		_bow_t = 1.0
		return
	_bow_t = 1.0 / float(it.get("speed", 1.5))
	bisaccia.remove("dardo", 1)
	var dmg := int(it.get("damage", 0)) + int(ItemsData.get_item("dardo").get("damage", 0))
	# un po' di anticipo sulla caduta, così il dardo va dove si mira anche lontano
	var flight := d.length() / DART_SPEED
	var v := d.normalized() * DART_SPEED
	v.y -= 0.5 * DART_GRAV * minf(flight, 0.8)
	shots.fire(from + d.normalized() * 8.0, v, DART_GRAV, dmg, true, float(it.get("knockback", 1.0)) / 3.0)


func _strike(c: Creature, dmg: int, from_x: float, force: float) -> void:
	if c.take_hit(dmg, from_x, maxf(force, 0.3)):
		fauna.kill(c)


## Le creature che toccano il Germogliato lo feriscono.
func _contact() -> void:
	if invuln > 0.0 or m.life.dead:
		return
	var pr := Rect2(player.position - Player.HALF, Player.HALF * 2.0).grow(-1.0)
	for c in fauna.list:
		if c.damage > 0 and pr.intersects(c.rect().grow(-1.0)):
			hurt_player(c.damage, c.position.x)
			return


## Ferita del Germogliato da una creatura o da un colpo: meno Vita, spinta indietro, lampeggio, numero rosso.
func hurt_player(dmg: int, from_x: float) -> void:
	if invuln > 0.0 or m.life.dead:
		return
	invuln = INVULN
	var lost := vitals.hurt(dmg)
	var dir := signf(player.position.x - from_x)
	if dir == 0.0:
		dir = -float(player.facing)
	player.vel = Vector2(dir * 170.0, -170.0)
	player.on_floor = false
	Fx.float_text(m.fx, player.position + Vector2(0, -20), "-%d" % lost, Color("#ff7a5a"))
	m.life.flash(Color(1.0, 0.25, 0.2, 0.18), 0.25)
