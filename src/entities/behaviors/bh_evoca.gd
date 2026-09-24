class_name BhEvoca
extends Behavior
## Evoca: nella seconda fase chiama in aiuto altre creature (id in `p.summon`), mai più di `p.summon_max` vive insieme.
## La creatura chiede, la fauna le fa nascere (`Creature.summons`).

var t := 3.0


func tick(c: Creature, dt: float) -> void:
	if not c.enraged:
		return
	t -= dt
	if t > 0.0:
		return
	t = float(c.p.get("summon_every", 8.0))
	if c.minions < int(c.p.get("summon_max", 3)):
		c.summons.append(String(c.p.get("summon", "grumo_muschio")))
