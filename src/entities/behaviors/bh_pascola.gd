class_name BhPascola
extends Behavior
## Pascola (voce 57): un erbivoro scappa dai predatori che lo cacciano (entro `FLEE` tessere); quando ha fame va a
## brucare l'erba e i fiori sul pavimento vicino, e li mangia (le famiglie `pest` anche le colture del giardino).
## Viene per ultimo; non fa nulla se il Germogliato lo ha fatto arrabbiare (le docili provocate attaccano).

const FLEE := 8.0
const LOOK := 6
const EAT := 1.6
const STAMINA := 3.0                   # secondi di fuga, poi deve riprendere fiato (e la si può prendere)

var pest := false
var _goal := Vector2i(-1, -1)
var _eat := 0.0
var _scan := 0.0
var _run := 0.0


func tick(c: Creature, dt: float) -> void:
	c.hunger = minf(c.hunger + dt / 70.0, 1.5)
	var fauna := c.get_parent()
	# via dai predatori, finché ha fiato
	_run = maxf(_run - dt * 0.6, 0.0)
	for o in fauna.list:
		if _run >= STAMINA:
			break
		if o != c and is_instance_valid(o) and o.hunt == c and o.position.distance_to(c.position) < FLEE * 16.0:
			var away := signf(c.position.x - o.position.x)
			c.want_x = (away if away != 0.0 else 1.0) * 1.4
			_run += dt * 1.6
			c.facing = int(signf(c.want_x))
			if c.on_floor and c.wall_ahead(c.facing):
				c.vel.y = -280.0
				c.on_floor = false
			_goal = Vector2i(-1, -1)
			return
	if (c.docile and c.provoked) or c.hunger < 0.4 or c.fly:
		return
	_scan -= dt
	if _goal.x < 0 and _scan <= 0.0:
		_scan = 1.0
		_goal = _find(c)
	if _goal.x < 0:
		return
	var gx := _goal.x * 16.0 + 8.0
	if absf(gx - c.position.x) > 6.0:
		c.want_x = signf(gx - c.position.x) * 0.6
		c.facing = int(signf(c.want_x))
		_eat = 0.0
		return
	c.want_x = 0.0
	_eat += dt
	if _eat >= EAT:
		fauna.graze(c, _goal)
		c.hunger = 0.0
		_goal = Vector2i(-1, -1)
		_eat = 0.0


## L'erba (o la coltura) più vicina sul pavimento, entro `LOOK` tessere a destra e a sinistra.
func _find(c: Creature) -> Vector2i:
	var w := c.world
	var feet := Vector2i(floori(c.position.x / 16.0), floori((c.position.y + c.half.y - 1.0) / 16.0))
	for r in LOOK:
		for side in [1, -1]:
			var x: int = feet.x + side * r
			for dy in range(-1, 2):
				var q := Vector2i(x, feet.y + dy)
				if pest and w.crops.has(q):
					return q
				var d := w.decor_at(q.x, q.y)
				if d in TileDefs.DECOR_GRASS or d in TileDefs.DECOR_FLOWERS or d == TileDefs.DECOR_FERN:
					return q
	return Vector2i(-1, -1)
