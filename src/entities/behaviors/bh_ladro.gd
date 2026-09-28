class_name BhLadro
extends Behavior
## Ladro (voce 130): arrivato addosso al Germogliato si ferma un attimo (il segnale) e gli ruba un oggetto dalla
## Bisaccia (`Wiles`), poi scappa. Presa, restituisce il maltolto. Parametri: steal (quanti), steal_cool.

var cool := 0.0
var tell := -1.0


func tick(c: Creature, dt: float) -> void:
	cool = maxf(cool - dt, 0.0)
	if c.has_meta("rubato"):
		c.mind.force_flee(1.0)                 # con il bottino scappa sempre
		return
	if c.target == null or cool > 0.0:
		return
	if tell < 0.0:
		if c.position.distance_to(c.target.position) < 22.0:
			tell = 0.35
			c.telegraph(tell)
	else:
		tell -= dt
		if tell <= 0.0:
			tell = -1.0
			cool = float(c.p.get("steal_cool", 8.0))
			if c.position.distance_to(c.target.position) < 30.0:
				c.acts.append({"kind": "ruba", "n": int(c.p.get("steal", 5))})
