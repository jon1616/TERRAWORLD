class_name BhOrbita
extends Behavior
## Orbita (voce 378, per chi vola): invece di venire addosso gira attorno al bersaglio a distanza, e intanto gli altri
## comportamenti sparano. Va scritto dopo «vola». Parametri: orbit_r (tessere), orbit_speed (giri al secondo).

var ang := 0.0


func tick(c: Creature, dt: float) -> void:
	if c.busy or c.target == null or not Behavior.sees(c, float(c.p.get("sight", 26))):
		return
	ang += TAU * float(c.p.get("orbit_speed", 0.18)) * dt * (1.3 if c.enraged else 1.0)
	var goal: Vector2 = c.target.position + Vector2.RIGHT.rotated(ang) * float(c.p.get("orbit_r", 6.0)) * 16.0
	c.want_fly = (goal - c.position).limit_length(c.speed * 1.4)
