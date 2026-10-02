class_name BhRichiamo
extends Behavior
## Richiamo (voce 130): quando ti vede si ferma e chiama (un segnale lungo, `p.call_time`): se in quel tempo non
## la colpisci arrivano rinforzi (`p.call_id`, altrimenti la sua specie; `p.call_n`). Al più `p.calls` volte.
## Chi è arrivato da un richiamo (meta «chiamata», la mette `Fauna`) non chiama a sua volta: altrimenti ogni rinforzo
## della stessa specie ne chiamava altri e le creature crescevano a valanga (il crash dello Stormo, 2 ott 2026).

var cool := 0.0
var timer := -1.0
var calls := 0
var _hp := 0


func tick(c: Creature, dt: float) -> void:
	cool = maxf(cool - dt, 0.0)
	if timer >= 0.0:
		c.busy = true
		c.want_x = 0.0
		c.shake = 0.6
		c.mouth = true
		timer -= dt
		if c.hp < _hp:
			timer = -1.0                           # zittita
			c.busy = false
			c.mouth = false
			c.shake = 0.0
			c.tele = 0.0
			cool = 6.0
		elif timer < 0.0:
			c.busy = false
			c.mouth = false
			c.shake = 0.0
			calls += 1
			cool = float(c.p.get("call_cool", 20.0))
			for i in int(c.p.get("call_n", 2)):
				c.summons.append(String(c.p.get("call_id", c.base)))
		return
	if c.has_meta("chiamata") or cool > 0.0 or calls >= int(c.p.get("calls", 2)) or not Behavior.sees(c, float(c.p.get("sight", 16))):
		return
	timer = float(c.p.get("call_time", 1.6))
	_hp = c.hp
	c.telegraph(timer)
