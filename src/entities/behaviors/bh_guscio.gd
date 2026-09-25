class_name BhGuscio
extends Behavior
## Guscio (voce 22): colpita, la creatura si chiude nel guscio per qualche secondo: ferma, e i colpi le fanno un
## quarto del danno (`Creature.take_hit` guarda `shell`). Conviene aspettare che esca, o colpire forte al primo colpo.


func tick(c: Creature, dt: float) -> void:
	# il guscio si chiude in `Creature.take_hit` (anche mentre è stordita dal colpo); qui passa il tempo
	if c.shell > 0.0:
		c.shell -= dt
		c.want_x = 0.0
		c.busy = c.shell > 0.0
