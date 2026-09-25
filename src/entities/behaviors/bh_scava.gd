class_name BhScava
extends Behavior
## Scava (voce 22): la creatura nuota nella terra e nella roccia (`ghost`: niente collisioni). Dentro la terra non si
## vede, lascia solo sbuffi di polvere e punta al bersaglio; uscendo all'aria vola ad arco con il suo slancio e ricade,
## come un pesce che salta. Chi la vede arrivare ha un attimo per spostarsi.

var _dust := 0.0
var _wander := Vector2.ZERO


func tick(c: Creature, dt: float) -> void:
	c.ghost = true
	var cell := Vector2i(floori(c.position.x / 16.0), floori(c.position.y / 16.0))
	var inside := c.world.solid(cell.x, cell.y)
	c.buried = inside
	if not inside:
		return                                 # in aria decide la gravità
	var goal: Vector2
	if Behavior.sees(c, float(c.p.get("sight", 22))):
		goal = c.target.position + Vector2(0, 6)
	else:
		if _wander == Vector2.ZERO or c.rng.randf() < dt * 0.3:
			_wander = Vector2(c.rng.randf_range(-1, 1), c.rng.randf_range(-0.3, 0.3)).normalized()
		goal = c.position + _wander * 40.0
	var to := goal - c.position
	c.want_fly = to.normalized() * c.speed
	c.facing = 1 if to.x >= 0.0 else -1
	_dust -= dt
	if _dust <= 0.0 and c.get_parent():
		_dust = 0.18
		Fx.dust(c.get_parent(), c.position, TileDefs.dust_colors(c.world.tile(cell.x, cell.y)))
