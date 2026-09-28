class_name BhTessitore
extends Behavior
## Tessitore (voce 130): ogni tanto (`p.web_every`), se ti vede, tende una ragnatela dove sei (`Wiles`): chi ci passa
## corre a metà. Le torce vicine la bruciano, e una torcia in mano la brucia al passaggio.

var t := 2.0
var tell := -1.0


func tick(c: Creature, dt: float) -> void:
	if tell >= 0.0:
		c.want_x = 0.0
		tell -= dt
		if tell < 0.0 and c.target:
			c.acts.append({"kind": "tela", "at": c.target.position})
		return
	t -= dt
	if t > 0.0 or not Behavior.sees(c, float(c.p.get("sight", 12))):
		return
	t = float(c.p.get("web_every", 6.0))
	tell = 0.5
	c.telegraph(tell)
