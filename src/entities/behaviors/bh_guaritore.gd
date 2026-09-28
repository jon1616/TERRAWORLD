class_name BhGuaritore
extends Behavior
## Guaritore (voce 130): ogni tanto (`p.heal_every`) si ferma, si illumina (il segnale) e cura le compagne vicine
## (`p.heal` della loro Vita, entro `p.heal_r` tessere). Si abbatte per primo.

var t := 3.0
var tell := -1.0


func tick(c: Creature, dt: float) -> void:
	var fauna := c.get_parent()
	if fauna == null or not "list" in fauna:
		return
	if tell >= 0.0:
		c.want_x = 0.0
		tell -= dt
		if tell < 0.0:
			var r := float(c.p.get("heal_r", 8)) * 16.0
			for o in fauna.list:
				if o != c and not o.boss and o.hp < o.hp_max and o.position.distance_to(c.position) < r:
					o.hp = mini(o.hp_max, o.hp + maxi(1, roundi(o.hp_max * float(c.p.get("heal", 0.2)))))
					o._bar.set_value(float(o.hp) / o.hp_max)
					Fx.puff(fauna, o.position, Color(0.8, 1.8, 0.9))
		return
	t -= dt
	if t > 0.0:
		return
	t = float(c.p.get("heal_every", 5.0))
	for o in fauna.list:
		if o != c and o.hp < o.hp_max and o.position.distance_to(c.position) < float(c.p.get("heal_r", 8)) * 16.0:
			tell = 0.6
			c.telegraph(tell)
			return
