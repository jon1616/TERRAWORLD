class_name BhScoppia
extends Behavior
## Scoppiante (voce 130): arrivata vicina (`p.fuse_r` tessere) si gonfia e trema per `p.fuse` secondi (il segnale),
## poi scoppia e ferisce chi c'è attorno (creature comprese; non rompe blocchi). Si affronta da lontano: abbattuta prima, non scoppia.

var timer := -1.0


func tick(c: Creature, dt: float) -> void:
	if timer >= 0.0:
		c.busy = true
		c.want_x = 0.0
		c.shake = 1.0
		c.crouch = 0.4
		timer -= dt
		if timer < 0.0:
			c.acts.append({"kind": "scoppia", "r": float(c.p.get("blast_r", 2.5)), "damage": c.damage * 4})
		return
	if c.target and c.target.position.distance_to(c.position) < float(c.p.get("fuse_r", 2.5)) * 16.0:
		timer = float(c.p.get("fuse", 1.0)) * float(c.p.get("windup", 1.0))
		c.telegraph(timer)
