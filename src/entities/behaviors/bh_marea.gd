class_name BhMarea
extends Behavior
## La marea (voce 136, il Leviatano del lago): ogni tanto (`p.tide_every`) si ferma, il lago ribolle (il segnale) e
## l'acqua sale e trabocca verso il Germogliato (`GreatGuardians`). Contromossa: stare in alto, lontano dalla riva.

var t := 4.0
var tell := -1.0


func tick(c: Creature, dt: float) -> void:
	if tell >= 0.0:
		tell -= dt
		if tell < 0.0 and c.target:
			c.acts.append({"kind": "marea", "at": c.position, "to": c.target.position, "n": int(c.p.get("tide_cells", 10))})
		return
	t -= dt * (1.4 if c.enraged else 1.0)
	if t > 0.0:
		return
	t = float(c.p.get("tide_every", 9.0))
	tell = 1.0
	c.telegraph(tell)
