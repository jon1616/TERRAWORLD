class_name BhFotofobo
extends Behavior
## Fotofobo (voce 130): al buio è più forte e più svelto (× `p.dark_mult`); in una luce forte fugge. Vede al buio.
## Si affronta con le torce: una luce accanto a sé è un riparo.

var t := 0.0
var _dmg := -1
var _spd := 0.0


func tick(c: Creature, dt: float) -> void:
	if _dmg < 0:
		_dmg = c.damage
		_spd = c.speed
		c.mind.dark = true
	t -= dt
	if t > 0.0:
		return
	t = 0.3
	var fauna := c.get_parent()
	if fauna == null or not "light" in fauna or fauna.light == null:
		return
	var v: float = fauna.light.value_at(Vector2i(floori(c.position.x / 16.0), floori(c.position.y / 16.0)))
	if v < 0.0:
		return
	var dm := float(c.p.get("dark_mult", 1.5))
	if v > 0.55:
		c.damage = _dmg
		c.speed = _spd
		c.mind.force_flee(1.5)
	elif v < 0.15:
		c.damage = roundi(_dmg * dm)
		c.speed = _spd * (1.0 + (dm - 1.0) * 0.5)
	else:
		c.damage = _dmg
		c.speed = _spd
