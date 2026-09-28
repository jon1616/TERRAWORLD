class_name BhRosicchia
extends Behavior
## Rosicchiatore (voce 130): durante un assedio rode le porte che gli sbarrano la strada (scelta dell'utente: fuori
## dagli assedi nessuna creatura distrugge nulla). Davanti a una porta si ferma e morde; chiede il morso, `Wiles` decide.

var t := 0.0
var _on := false


func tick(c: Creature, dt: float) -> void:
	var fx := floori((c.position.x + c.facing * (c.half.x + 6.0)) / 16.0)
	var fy := floori((c.position.y + c.half.y - 2.0) / 16.0)
	var door := Wiles.siege and (c.world.tile(fx, fy) == TileDefs.PORTA or c.world.tile(fx, fy - 1) == TileDefs.PORTA)
	if door:
		_on = true
		c.busy = true
		c.want_x = 0.0
		t -= dt
		if t <= 0.0:
			t = float(c.p.get("gnaw_every", 2.0))
			c.shake = 0.5
			c.acts.append({"kind": "rosicchia", "cell": Vector2i(fx, fy)})
	elif _on:
		_on = false
		c.busy = false
		c.shake = 0.0
