class_name BhPastore
extends Behavior
## Pastore (voce 130): guida le creature della sua famiglia vicine (`p.herd_r` tessere): quando sono calme lo seguono
## (`Mind.lead`). Se cade, il gregge si sbanda e fugge (`Wiles`). Si abbatte lui per primo.

var t := 0.0


func tick(c: Creature, dt: float) -> void:
	t -= dt
	if t > 0.0:
		return
	t = 0.5
	var fauna := c.get_parent()
	if fauna == null or not "list" in fauna:
		return
	var r := float(c.p.get("herd_r", 12)) * 16.0
	for o in fauna.list:
		if o != c and not o.boss and o.tame == null and (o.family == c.family or o.base == c.base) \
				and o.position.distance_to(c.position) < r:
			o.mind.lead = c
