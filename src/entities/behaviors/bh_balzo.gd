class_name BhBalzo
extends Behavior
## Balzo indietro (voce 378): quando il bersaglio gli arriva troppo vicino salta all'indietro, lontano (poi gli altri
## comportamenti tirano). Parametri: hop_cool, hop_r (tessere).

var t := 0.0


func tick(c: Creature, dt: float) -> void:
	t -= dt
	if t > 0.0 or not c.on_floor or c.target == null or c.busy:
		return
	var d := c.target.position.x - c.position.x
	if absf(d) > float(c.p.get("hop_r", 3.0)) * 16.0 or absf(c.target.position.y - c.position.y) > 48.0:
		return
	t = float(c.p.get("hop_cool", 3.0))
	c.vel = Vector2(-signf(d) * 210.0, -230.0)
	c.on_floor = false
