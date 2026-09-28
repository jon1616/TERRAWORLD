class_name BhRosicchia
extends Behavior
## Rosicchiatore (voce 130): mangia le colture che incontra e rosicchia la terra naturale tenera che gli sbarra la
## strada (mai i blocchi costruiti: scelta dell'utente, le costruzioni si rompono solo negli assedi). `Wiles` lo fa.

var t := 1.0


func tick(c: Creature, dt: float) -> void:
	t -= dt
	if t > 0.0:
		return
	t = float(c.p.get("gnaw_every", 2.0))
	var fx := floori((c.position.x + c.facing * (c.half.x + 6.0)) / 16.0)
	var fy := floori((c.position.y + c.half.y - 2.0) / 16.0)
	for q in [Vector2i(fx, fy), Vector2i(fx, fy - 1)]:
		if c.world.crops.has(q) or c.world.solid(q.x, q.y):
			c.acts.append({"kind": "rosicchia", "cell": q})
			return
