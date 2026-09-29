class_name BhSucchia
extends Behavior
## Succhiavena (Roadmap 19, voce 207): fiuta le vene di radice vicine (entro `smell` tessere), ci va sopra e le beve,
## un morso ogni `gnaw_every` secondi (chiede il morso, `Wiles` decide: le vene di legnoferro e più dure, e quelle
## isolate con la gelatina, non si bevono). Scelta dell'utente: rovina solo le vene di radice, mai i blocchi.

var t := 0.0
var look_t := 0.0
var target := Vector2i(-1, -1)


func tick(c: Creature, dt: float) -> void:
	look_t -= dt
	if look_t <= 0.0:
		look_t = 1.0
		target = _find(c)
	if target.x < 0:
		if c.busy:
			c.busy = false
			c.shake = 0.0
		return
	var tx := float(target.x) * 16.0 + 8.0
	var dx := tx - c.position.x
	if absf(dx) > 10.0:
		c.want_x = signf(dx) * c.speed
		c.facing = 1 if dx > 0.0 else -1
		c.busy = false
		return
	c.busy = true
	c.want_x = 0.0
	c.shake = 0.3
	t -= dt
	if t <= 0.0:
		t = float(c.p.get("gnaw_every", 2.5))
		c.acts.append({"kind": "succhia", "cell": target})


## La vena di radice (non isolata) più vicina, all'altezza dei piedi o poco sotto.
func _find(c: Creature) -> Vector2i:
	var cx := floori(c.position.x / 16.0)
	var cy := floori((c.position.y + c.half.y) / 16.0)
	var r := int(c.p.get("smell", 8))
	var best := Vector2i(-1, -1)
	var bd := 99999
	for dy in range(-2, 3):
		for dx in range(-r, r + 1):
			var b := c.world.vein_at(cx + dx, cy + dy)
			if VeinsData.tier(b) == 1 and b & VeinsData.INSULATED == 0 and absi(dx) + absi(dy) < bd:
				bd = absi(dx) + absi(dy)
				best = Vector2i(cx + dx, cy + dy)
	return best
