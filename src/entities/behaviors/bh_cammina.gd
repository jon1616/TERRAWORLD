class_name BhCammina
extends Behavior
## Cammina: verso il bersaglio se lo vede, altrimenti gironzola cambiando verso ogni tanto. Salta i gradini alti due
## tessere; mentre gironzola si gira davanti ai burroni.

var wander := 0.0
var dir := 1.0


func tick(c: Creature, dt: float) -> void:
	if c.busy:
		return
	if Behavior.sees(c, float(c.p.get("sight", 20))):
		# voce 131: chi accerchia punta al fianco del bersaglio, arrivato si stringe
		var gx: float = c.target.position.x + c.mind.flank
		if c.mind.flank != 0.0 and absf(gx - c.position.x) < 12.0:
			c.mind.flank = 0.0
		dir = signf(gx - c.position.x)
		if absf(gx - c.position.x) < 4.0:
			dir = 0.0
	elif c.mind.wander_dir(c) != 0.0:
		dir = c.mind.wander_dir(c)             # voce 129: va a vedere un rumore, o a cercarti dove ti ha visto
		if c.on_floor and not c.ground_ahead(int(dir)):
			dir = 0.0
	else:
		wander -= dt
		if wander <= 0.0:
			wander = c.rng.randf_range(2.0, 5.0)
			dir = [-1.0, 1.0, 0.0][c.rng.randi_range(0, 2)]
		if c.on_floor and dir != 0.0 and not c.ground_ahead(int(dir)):
			dir = -dir
	c.want_x = dir
	if dir != 0.0:
		c.facing = int(dir)
	if c.on_floor and dir != 0.0 and c.wall_ahead(int(dir)):
		c.vel.y = -260.0
		c.on_floor = false
