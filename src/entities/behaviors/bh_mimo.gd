class_name BhMimo
extends Behavior
## Mimo (voce 22): la creatura se ne sta immobile travestita (il primo fotogramma è una roccia di cristallo, vedi
## `disguise` in `CreaturesData`) finché il bersaglio non le arriva a poche tessere, o finché qualcuno la colpisce;
## allora si sveglia per sempre e fanno gli altri comportamenti.

var awake := false


func tick(c: Creature, _dt: float) -> void:
	if awake:
		return
	c.anchored = true
	if c.just_hit or Behavior.sees(c, float(c.p.get("wake", 3.5))):
		awake = true
		c.anchored = false
		c.vel = Vector2(0, -160)
		c.shake = 0.0
		if c.get_parent():
			Fx.puff(c.get_parent(), c.position, Color(1.4, 1.2, 1.6))
