class_name BhDeriva
extends Behavior
## Deriva (Roadmap 16, voce 160, le meduse di nuvola e le balene delle stelle): si lascia portare dal vento, piano,
## salendo e scendendo come una bolla, senza allontanarsi troppo da dove è nata (torna indietro controvento). Se la
## colpisci e non è docile, ti viene incontro. Parametri: drift (velocità nel vento), bob (quanto sale e scende, px),
## leash (tessere dalla casa).

var t := 0.0
var home := Vector2.INF
var dir := 1.0


func tick(c: Creature, dt: float) -> void:
	t += dt
	if home == Vector2.INF:
		home = c.position
		dir = 1.0 if c.rng.randf() < 0.5 else -1.0
	if c.busy:
		return
	var wind := Projectiles.wind / 60.0 if absf(Projectiles.wind) > 1.0 else 0.0
	var drift := float(c.p.get("drift", 22.0))
	var leash := float(c.p.get("leash", 18)) * 16.0
	if absf(c.position.x - home.x) > leash:
		dir = -signf(c.position.x - home.x)
	var hurt := c.hp < c.hp_max and not c.docile and c.target != null
	if hurt and Behavior.sees(c, float(c.p.get("sight", 16))):
		c.want_fly = (c.target.position - c.position).normalized() * c.speed
	else:
		var bob := float(c.p.get("bob", 24.0))
		var vy := (home.y + sin(t * 0.8) * bob - c.position.y) * 1.2
		c.want_fly = Vector2(dir * drift + wind * drift, vy)
	if absf(c.want_fly.x) > 2.0:
		c.facing = 1 if c.want_fly.x > 0.0 else -1
