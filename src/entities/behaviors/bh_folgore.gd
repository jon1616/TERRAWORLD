class_name BhFolgore
extends Behavior
## Folgore (Roadmap 16, voce 160, le creature della tempesta): chiama un fulmine sulla colonna dove ti trovi. Prima la
## colonna si accende (una riga di luce sottile, e il «!» sulla creatura), poi il fulmine cade lì: basta spostarsi.
## Il fulmine lo disegna e lo fa cadere `SkyStrikes` (richiesta «folgore» in `Creature.acts`). Parametri: sight,
## bolt_every, bolt_delay, bolt_damage, bolts (quanti fulmini di fila, uno accanto all'altro).

var cool := 3.0


func tick(c: Creature, dt: float) -> void:
	cool -= dt * (1.5 if c.enraged else 1.0)
	if cool > 0.0 or c.target == null or not Behavior.sees(c, float(c.p.get("sight", 24))):
		return
	cool = float(c.p.get("bolt_every", 5.0))
	var delay := float(c.p.get("bolt_delay", 0.9))
	c.telegraph(delay)
	var n := int(c.p.get("bolts", 1))
	for i in n:
		var off := (i - (n - 1) * 0.5) * 40.0
		c.acts.append({"kind": "folgore", "x": c.target.position.x + off, "delay": delay + i * 0.15,
			"damage": int(c.p.get("bolt_damage", c.damage))})
