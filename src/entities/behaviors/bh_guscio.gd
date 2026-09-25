class_name BhGuscio
extends Behavior
## Guscio (voce 22): colpita, la creatura si chiude nel guscio per qualche secondo: ferma, e i colpi le fanno un
## quarto del danno (`Creature.take_hit` guarda `shell`). Conviene aspettare che esca, o colpire forte al primo colpo.


func tick(c: Creature, dt: float) -> void:
	if c.just_hit:
		c.just_hit = false
		if c.shell <= 0.0:
			c.shell = float(c.p.get("shell_time", 2.5))
	if c.shell > 0.0:
		c.shell -= dt
		c.want_x = 0.0
		c.busy = c.shell > 0.0
