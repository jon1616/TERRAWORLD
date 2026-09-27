class_name BhNuota
extends Behavior
## Nuota (voce 73): le creature d'acqua restano nel liquido, girano a zonzo e, se aggressive (`p.bite`), inseguono il
## Germogliato quando è in acqua anche lui. Fuori dal liquido cadono e boccheggiano: perdono Vita poco alla volta.

var t := 0.0
var drift := Vector2.ZERO
var _dry := 0.0


func tick(c: Creature, dt: float) -> void:
	t += dt
	var w := c.world
	var cell := Vector2i(floori(c.position.x / 16.0), floori(c.position.y / 16.0))
	if w.liq(cell.x, cell.y) < 3:
		c.want_fly = Vector2(0, 160)             # fuori dall'acqua: cade
		_dry += dt
		if _dry > 1.0:
			_dry = 0.0
			c.take_hit(maxi(c.hp_max / 8, 1), c.position.x, 0.0)
		return
	_dry = 0.0
	var goal := Vector2.INF
	if bool(c.p.get("bite", false)) and Behavior.sees(c, float(c.p.get("sight", 14))):
		var tc := Vector2i(floori(c.target.position.x / 16.0), floori(c.target.position.y / 16.0))
		if w.liq(tc.x, tc.y) >= 3:
			goal = c.target.position
	if goal == Vector2.INF:
		if drift == Vector2.ZERO or c.rng.randf() < dt * 0.5:
			drift = Vector2(c.rng.randf_range(-1, 1), c.rng.randf_range(-0.4, 0.4)).normalized()
		# davanti c'è ancora acqua? altrimenti si gira
		var ahead := Vector2i(floori((c.position.x + drift.x * 14.0) / 16.0), floori((c.position.y + drift.y * 14.0) / 16.0))
		if w.liq(ahead.x, ahead.y) < 3 or w.solid(ahead.x, ahead.y):
			drift = -drift
		c.want_fly = drift * c.speed * 0.6 + Vector2(0, sin(t * 2.0) * 6.0)
	else:
		c.want_fly = (goal - c.position).normalized() * c.speed
	if absf(c.want_fly.x) > 2.0:
		c.facing = 1 if c.want_fly.x > 0.0 else -1
