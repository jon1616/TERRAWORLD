class_name BhScudo
extends Behavior
## Scudo frontale (voce 130): para i colpi che arrivano davanti (un quinto del danno); si gira verso di te lentamente
## (`p.turn` secondi), così si colpisce da dietro o dall'alto. Va messo per ultimo nei comportamenti: decide lui
## da che parte guarda.

var face := 1
var _t := 0.0


func tick(c: Creature, dt: float) -> void:
	if c.target != null:
		var want := 1 if c.target.position.x > c.position.x else -1
		if want != face:
			_t += dt
			if _t > float(c.p.get("turn", 0.8)):
				face = want
				_t = 0.0
		else:
			_t = 0.0
	c.facing = face


## Il colpo che arriva da `from_x` è parato? (davanti e non dall'alto)
func blocks(c: Creature, from_x: float) -> bool:
	var above := c.target != null and c.target.position.y < c.position.y - c.half.y - 6.0
	return not above and signf(from_x - c.position.x) == float(face)
