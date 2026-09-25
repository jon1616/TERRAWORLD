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
const AMMO := ["dardo_vuoto", "dardo_aculeo", "dardo_piumato", "dardo"]  # l'arco usa i dardi migliori che ci sono

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
var god := false
var dmg_mult := 1.0                    # accessori: danno × (vedi `GearEffects`)
var spd_mult := 1.0                    # accessori: colpi più rapidi
var magic_mult := 1.0                  # vesti di seta: incantesimi più forti
var boon_thorns := 0                   # Pozione di spine
var thorns := 0                        # tratto Spine dell'equipaggiamento: danno a chi ti tocca                       # per le prove: il Germogliato non si ferisce


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
		var hits: Dictionary = s["hits"]
		for c in fauna.list.duplicate():
			if not hits.has(c) and c.rect().grow(2.0).has_point(pos):
				hits[c] = true
				if float(s["chill"]) > 0.0:
					c.chill_t = maxf(c.chill_t, float(s["chill"]))   # onda di lagunite: rallenta
				_strike(c, int(s["damage"]), pos.x - signf(s["vel"].x) * 10.0, float(s["knock"]))
				if int(s["pierce"]) <= 0:
					return true
				s["pierce"] = int(s["pierce"]) - 1
				return false
		return false
	if Rect2(player.position - Player.HALF, Player.HALF * 2.0).has_point(pos):
		if float(s.get("slow", 0.0)) > 0.0 and not god:
			if player.slow_t <= 0.0:
				m.hud.toast("Invischiato nella ragnatela!")
			player.slow_t = maxf(player.slow_t, float(s["slow"]))
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
	var tr := String(item.get("tratto", ""))
	var spd := float(it.get("speed", 0.0)) * TraitsData.effect(tr, "speed") * spd_mult
	player.swing_period = 1.0 / spd if use == "colpo" and spd > 0.0 else DIG_PERIOD
	_melee(it, use, tr)
	_bow(it, use, active, dt, tr)


## Colpi in mischia: ogni giro dell'attrezzo colpisce una volta ogni creatura nell'area davanti.
func _melee(it: Dictionary, use: String, tr := "") -> void:
	var sw: bool = player.swinging or player.force_swing
	var dmg := roundi(int(it.get("damage", 0)) * TraitsData.effect(tr, "damage") * _boon())
	if not sw or dmg <= 0 or not use in ["colpo", "scava", "abbatti"]:
		_cycle = -1
		return
	var cyc := int(player.swing_t / player.swing_period)
	if cyc != _cycle:
		_cycle = cyc
		_hit_set.clear()
		if use == "colpo":
			m.sfx.play("colpo")
	var ph := fmod(player.swing_t, player.swing_period) / player.swing_period
	if ph < 0.15:
		return                             # l'attrezzo è ancora alzato
	var area := Rect2(player.position + Vector2(player.facing * MELEE_REACH.x * 0.5 - MELEE_REACH.x * 0.5, -22),
			MELEE_REACH)
	area.position.x += player.facing * 6
	for c in fauna.list.duplicate():
		if not _hit_set.has(c) and area.intersects(c.rect()):
			_hit_set[c] = true
			_strike(c, dmg, player.position.x, float(it.get("knockback", 1.5)) * TraitsData.effect(tr, "knock") / 3.0)


## Arco: tenendo premuto tira un dardo a ogni giro (secondo la velocità dell'arco), finché ci sono dardi.
func _bow(it: Dictionary, use: String, active: bool, dt: float, tr := "") -> void:
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
	var ammo := ""
	for a in AMMO:
		if bisaccia.count(a) > 0:
			ammo = a
			break
	if ammo == "":
		m.hud.toast("Niente dardi")
		_bow_t = 1.0
		return
	_bow_t = 1.0 / (float(it.get("speed", 1.5)) * TraitsData.effect(tr, "speed") * spd_mult)
	bisaccia.remove(ammo, 1)
	m.sfx.play("tira")
	var dmg := roundi((int(it.get("damage", 0)) * TraitsData.effect(tr, "damage") + int(ItemsData.get_item(ammo).get("damage", 0))) * _boon())
	# un po' di anticipo sulla caduta, così il dardo va dove si mira anche lontano
	var flight := d.length() / DART_SPEED
	var v := d.normalized() * DART_SPEED
	v.y -= 0.5 * DART_GRAV * minf(flight, 0.8)
	var n := int(it.get("multishot", 1))       # l'Arco iridato tira più dardi a ventaglio con un dardo solo
	for k in n:
		shots.fire(from + d.normalized() * 8.0, v.rotated((k - (n - 1) / 2.0) * 0.12), DART_GRAV, dmg, true,
				float(it.get("knockback", 1.0)) * TraitsData.effect(tr, "knock") / 3.0)


## Danno ×1,2 con la Pozione di vigore attiva, e il danno in più degli accessori.
func _boon() -> float:
	return (Boons.VIGORE if m.boons.active.has("vigore") else 1.0) * dmg_mult * (Boons.SAZIO if m.boons.active.has("sazio") else 1.0)


func _strike(c: Creature, dmg: int, from_x: float, force: float) -> void:
	m.sfx.play("colpito", c.position)
	var tr := String(m.hud.current().get("tratto", ""))
	if TraitsData.effect(tr, "poison") > 0.0 or ItemsData.get_item(String(m.hud.current()["id"])).get("poison", false):
		c.poison_t = 4.0
	# creatura Spinosa: colpirla da vicino ferisce anche il Germogliato
	if c.ancient and c.ancient.has("spinosa") and player.position.distance_to(c.position) < 48.0:
		_self_hurt(maxi(int(dmg * c.ancient.value("thorns")), 1))
	if c.take_hit(dmg, from_x, maxf(force, 0.3)):
		var burst := TraitsData.effect(tr, "burst")
		fauna.kill(c)
		if burst > 0.0:
			# tratto Scoppio: la creatura abbattuta ferisce quelle vicine
			Fx.puff(m.fx, c.position, Color(2.0, 1.2, 0.6))
			for o in fauna.list.duplicate():
				if o.position.distance_to(c.position) < 48.0 and o.take_hit(int(dmg * burst), c.position.x, 0.5):
					fauna.kill(o)


## Ferita piccola che non dà invulnerabilità (spine, scoppi): numero rosso e basta.
func _self_hurt(dmg: int) -> void:
	if god or m.life.dead:
		return
	var lost := vitals.hurt(dmg)
	Fx.float_text(m.fx, player.position + Vector2(0, -20), "-%d" % lost, Color("#ff9a7a"))


## Una creatura Esplosiva muore: scoppia, e se il Germogliato è vicino si ferisce.
func on_killed(c: Creature) -> void:
	if c.ancient and c.ancient.has("esplosiva"):
		Fx.puff(m.fx, c.position, Color(2.4, 1.2, 0.5))
		m.sfx.play("rompi", c.position)
		if player.position.distance_to(c.position) < 3.5 * 16.0:
			hurt_player(int(c.ancient.value("explode")), c.position.x)


## Le creature che toccano il Germogliato lo feriscono.
func _contact() -> void:
	if invuln > 0.0 or m.life.dead:
		return
	var pr := Rect2(player.position - Player.HALF, Player.HALF * 2.0).grow(-1.0)
	for c in fauna.list:
		if c.damage > 0 and pr.intersects(c.rect().grow(-1.0)):
			hurt_player(c.damage, c.position.x)
			if c.ancient and c.ancient.has("velenosa"):
				vitals.poison_t = maxf(vitals.poison_t, c.ancient.value("poison"))
				m.hud.toast("Avvelenato!")
			# tratto Spine dell'equipaggiamento: chi tocca il Germogliato si ferisce
			if thorns + boon_thorns > 0 and c.take_hit(thorns + boon_thorns, player.position.x, 0.4):
				fauna.kill(c)
			return


## Ferita del Germogliato da una creatura o da un colpo: meno Vita, spinta indietro, lampeggio, numero rosso.
func hurt_player(dmg: int, from_x: float) -> void:
	if invuln > 0.0 or m.life.dead or god:
		return
	invuln = INVULN
	m.sfx.play("ferita")
	var lost := vitals.hurt(dmg)
	var dir := signf(player.position.x - from_x)
	if dir == 0.0:
		dir = -float(player.facing)
	player.vel = Vector2(dir * 170.0, -170.0)
	player.on_floor = false
	Fx.float_text(m.fx, player.position + Vector2(0, -20), "-%d" % lost, Color("#ff7a5a"))
	m.life.flash(Color(1.0, 0.25, 0.2, 0.18), 0.25)
