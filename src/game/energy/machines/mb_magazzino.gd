class_name MbMagazzino
extends MachineBehavior
## Il Magazzino vivo: una cassa grande che, con i suoi pulsi, si riordina da sola ogni `EVERY` secondi (unisce le pile
## uguali e mette in fila per tipo, come il pulsante Riordina).

const EVERY := 8.0


func tick(mc: Machine, e: Energy, dt: float) -> void:
	if not mc.on() or mc.power < 0.99:
		return
	var t := float(mc.get_meta("t", 0.0)) - dt
	if t > 0.0:
		mc.set_meta("t", t)
		return
	mc.set_meta("t", EVERY)
	var box: Bisaccia = e.m.world.chest_at(mc.o)
	box.sort_bag(0)
	box.changed.emit()
