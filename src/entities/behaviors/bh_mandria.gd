class_name BhMandria
extends Behavior
## Una creatura della mandria (voce 59, `Herd`): prende il posto dei comportamenti selvatici. Tre modi:
##   segue      sta accanto al Germogliato (ognuna al suo posto), salta gli ostacoli, se resta indietro ricompare;
##              chi combatte va addosso alle creature che minacciano il Germogliato (con il suo elemento) e
##              guadagna esperienza; le creature selvatiche la feriscono, e se la sua Vita finisce si ritira a riposare
##   recinto    gironzola dentro il suo recinto (non si fa male)
##   cavalcata  sta sotto il Germogliato e si muove con lui
##   guardia    voce 148: resta alla sua cuccia (`home` = il punto) e attacca chi ostile le si avvicina entro `GUARD`
##              tessere (le ondate delle maree comprese)

var herd: Node2D                       # il modulo `Herd`
var rec: Dictionary                    # la sua scheda (in `Character.mandria`)
var mode := "segue"
var slot := 0
var home := Vector2.ZERO               # recinto: da x a y in pixel
var foe: Creature
var _hit_cd := 0.0
var _hurt_cd := 0.0
var _jump_cd := 0.0
var _look := 0.0

const SIGHT := 12.0                    # tessere attorno al Germogliato entro cui difende
const HIT_EVERY := 0.8
const TELEPORT := 30.0
const GUARD := 14.0                    # tessere attorno alla cuccia che la creatura di guardia difende


func tick(c: Creature, dt: float) -> void:
	var m: Node2D = herd.m
	var p: Player = m.player
	_hit_cd -= dt
	_hurt_cd -= dt
	_jump_cd -= dt
	_look -= dt
	match mode:
		"cavalcata":
			c.position = p.position + Vector2(0, Player.HALF.y - c.half.y)
			c.vel = p.vel
			c.facing = p.facing
			return
		"recinto":
			c._wander(dt)
			if c.position.x < home.x:
				c.want_x = 0.5
				c.facing = 1
			elif c.position.x > home.y:
				c.want_x = -0.5
				c.facing = -1
			if c.fly:
				c.want_fly.y = clampf((m.pens.pen_y(rec) - 24.0 - c.position.y) * 2.0, -40.0, 40.0)
			return
	if mode == "guardia":
		_hurt(c, m)
		if not is_instance_valid(c) or c.tame != self:
			return
		if _look <= 0.0:
			_look = 0.35
			foe = _guard_foe(c, m)
		if foe != null and (not is_instance_valid(foe) or not m.fauna.list.has(foe)):
			foe = null
		if foe != null:
			_attack(c, m)
			_go(c, foe.position)
		else:
			_go(c, home)
		return
	if c.position.distance_to(p.position) > TELEPORT * 16.0:
		c.position = p.position + Vector2(-20.0 * p.facing, -8.0)
		c.vel = Vector2.ZERO
	_hurt(c, m)
	if not is_instance_valid(c) or c.tame != self:
		return
	if _look <= 0.0:
		_look = 0.35
		foe = _find_foe(c, m) if herd.fights(rec) else null
	if foe != null and (not is_instance_valid(foe) or not m.fauna.list.has(foe)):
		foe = null
	var goal: Vector2 = p.position + Vector2((-22.0 - slot * 16.0) * p.facing, 0.0)
	if foe != null:
		goal = foe.position
		_attack(c, m)
	_go(c, goal)


## Va verso un punto: chi vola ci vola (un po' sopra), chi cammina corre e salta muri e dislivelli.
func _go(c: Creature, goal: Vector2) -> void:
	var catch_up := maxf(1.0, 115.0 / maxf(c.speed, 1.0))
	if c.fly:
		var to := goal + Vector2(0, -18) - c.position
		c.want_fly = to.normalized() * c.speed * catch_up if to.length() > 10.0 else Vector2.ZERO
		return
	var dx := goal.x - c.position.x
	c.want_x = clampf(dx / 30.0, -1.0, 1.0) * catch_up if absf(dx) > 10.0 else 0.0
	if c.want_x != 0.0:
		c.facing = int(signf(c.want_x))
	if c.on_floor and _jump_cd <= 0.0 and absf(dx) > 8.0 and (c.wall_ahead(c.facing) or goal.y < c.position.y - 36.0):
		c.vel.y = -310.0
		c.on_floor = false
		_jump_cd = 0.6


## La creatura più vicina che minaccia il Germogliato (entro `SIGHT` tessere da lui).
func _find_foe(c: Creature, m: Node2D) -> Creature:
	var best := SIGHT * 16.0
	var out: Creature = null
	for o in m.fauna.list:
		if o.calm or o.damage <= 0 or o.buried:
			continue
		var d: float = o.position.distance_to(m.player.position)
		if d < best and o.position.distance_to(c.position) < (SIGHT + 6.0) * 16.0:
			best = d
			out = o
	return out


func _attack(c: Creature, m: Node2D) -> void:
	if _hit_cd > 0.0 or not c.rect().grow(4.0).intersects(foe.rect()):
		return
	_hit_cd = HIT_EVERY
	var dmg: int = herd.damage_now(rec)
	var elem := String(FamiliesData.parts(c.id)[2])
	if elem != "":
		dmg = Elements.hit(m.combat, foe, elem, dmg)        # l'elemento della variante (voce 51)
		if not is_instance_valid(foe) or not m.fauna.list.has(foe):
			foe = null
			return
	m.sfx.play("colpito", foe.position)
	if foe.take_hit(dmg, c.position.x, 0.7):
		herd.credit(rec, foe)
		m.fauna.kill(foe)
		foe = null


## Le creature selvatiche che la toccano la feriscono; se la Vita finisce si ritira (`Herd.faint`).
func _hurt(c: Creature, m: Node2D) -> void:
	if _hurt_cd > 0.0:
		return
	for o in m.fauna.list:
		if o.damage > 0 and not o.calm and not o.buried and o.rect().intersects(c.rect()):
			_hurt_cd = 0.9
			if c.take_hit(o.damage, o.position.x, 0.6):
				herd.faint(rec)
			else:
				rec["vita"] = float(c.hp) / float(c.hp_max)
			return


## Voce 148: il nemico più vicino alla cuccia, entro `GUARD` tessere.
func _guard_foe(c: Creature, m: Node2D) -> Creature:
	var best := GUARD * 16.0
	var out: Creature = null
	for o in m.fauna.list:
		if o == c or o.tame != null or o.calm or o.damage <= 0 or o.buried or o.docile:
			continue
		var d: float = o.position.distance_to(home)
		if d < best:
			best = d
			out = o
	return out

