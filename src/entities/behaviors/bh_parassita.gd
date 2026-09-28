class_name BhParassita
extends Behavior
## Parassita (voce 130): se ti tocca si attacca e beve Linfa (e un poco di Vita) finché non salti, non la colpisci o
## non brucia; poi si stacca. Mentre è attaccata non ferisce al contatto (beve e basta). Parametri: drain, hold.

var on := false
var cool := 0.0
var t := 0.0
var _acc := 0.0
var _dmg := -1
var _hp := 0


func tick(c: Creature, dt: float) -> void:
	cool = maxf(cool - dt, 0.0)
	if c.target == null:
		return
	if not on:
		if cool <= 0.0 and c.position.distance_to(c.target.position) < 14.0:
			on = true
			t = 0.0
			_hp = c.hp
			_dmg = c.damage
			c.damage = 0
			c.anchored = true
			c.telegraph(0.3)
		return
	t += dt
	c.busy = true
	c.position = c.target.position + Vector2(-4.0 * c.facing, -6.0)
	_acc += dt
	if _acc >= 1.0:
		_acc -= 1.0
		c.acts.append({"kind": "beve", "linfa": int(c.p.get("drain", 2)), "vita": 1})
	var jumped: bool = "vel" in c.target and (c.target.vel as Vector2).y < -180.0
	if jumped or c.hp < _hp or c.burn_t > 0.0 or t > float(c.p.get("hold", 8.0)):
		on = false
		cool = 3.0
		c.anchored = false
		c.busy = false
		c.damage = _dmg
		c.vel = Vector2(-c.facing * 120.0, -150.0)
