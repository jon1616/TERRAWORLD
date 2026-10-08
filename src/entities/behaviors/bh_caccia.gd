class_name BhCaccia
extends Behavior
## Caccia (voce 57): un predatore affamato cerca la preda più vicina tra le famiglie che caccia (`FamiliesData` prey),
## la insegue e la morde finché non la prende; poi è sazio per un po'. Se vede il Germogliato più vicino della preda
## lascia fare agli altri comportamenti (attacca lui). Viene per ultimo: le sue intenzioni vincono sulle altre.

const SCAN := 0.5
const BITE := 0.7

var _scan := 0.0
var _bite := 0.0
var prey: Array = []


func tick(c: Creature, dt: float) -> void:
	c.hunger = minf(c.hunger + dt / 50.0, 1.5)
	_bite = maxf(_bite - dt, 0.0)
	if c.calm or c.hunger < 0.5:
		c.hunt = null
		return
	_scan -= dt
	if _scan <= 0.0:
		_scan = SCAN
		c.hunt = _nearest(c)
	var h: Creature = c.hunt
	if h == null or not is_instance_valid(h) or h.hp <= 0:
		c.hunt = null
		return
	var dh := h.position.distance_to(c.position)
	if Behavior.sees(c, float(c.p.get("sight", 20))) and c.target.position.distance_to(c.position) < dh:
		return                                    # il Germogliato è più vicino: è lui la preda
	var d := h.position - c.position
	c.facing = 1 if d.x >= 0.0 else -1
	if c.fly:
		c.want_fly = d.normalized() * c.speed
	else:
		c.want_x = signf(d.x) * 1.5                # lo scatto della caccia
		if c.on_floor and c.wall_ahead(c.facing) and c.can_hop(c.facing, 280.0):
			c.vel.y = -280.0
			c.on_floor = false
	if _bite <= 0.0 and c.rect().grow(4.0).intersects(h.rect()):
		_bite = BITE
		var fauna := c.get_parent()
		if h.take_hit(maxi(c.damage, 4), c.position.x, 0.6):
			fauna.kill_by_predator(h, c)
			c.hunger = 0.0
			c.hunt = null


## La preda più vicina entro la vista (tra le creature della fauna).
func _nearest(c: Creature) -> Creature:
	var fauna := c.get_parent()
	if fauna == null or not "list" in fauna:
		return null
	var best: Creature = null
	var bd := float(c.p.get("sight", 20)) * 16.0 * 1.3
	for o in fauna.list:
		if o == c or o.boss or not FamiliesData.family_of(o.id) in prey:
			continue
		var dd: float = o.position.distance_to(c.position)
		if dd < bd:
			bd = dd
			best = o
	return best
