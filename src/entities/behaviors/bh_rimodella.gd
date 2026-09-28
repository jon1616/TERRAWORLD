class_name BhRimodella
extends Behavior
## Rimodella l'arena (voce 136, la Grande Scavatrice): ogni tanto (`p.pillar_every`) la terra trema (il segnale) e
## attorno al Germogliato si alzano pilastri di radice che crollano dopo qualche secondo (`GreatGuardians`): non
## rompe nulla, aggiunge soltanto. Contromossa: spostarsi quando trema, usare i pilastri per salire.

var t := 3.0
var tell := -1.0


func tick(c: Creature, dt: float) -> void:
	if tell >= 0.0:
		tell -= dt
		if tell < 0.0 and c.target:
			c.acts.append({"kind": "pilastri", "at": c.target.position, "n": int(c.p.get("pillars", 3))})
		return
	t -= dt * (1.4 if c.enraged else 1.0)
	if t > 0.0 or not Behavior.sees(c, float(c.p.get("sight", 24))):
		return
	t = float(c.p.get("pillar_every", 6.0))
	tell = 0.8
	c.telegraph(tell)
