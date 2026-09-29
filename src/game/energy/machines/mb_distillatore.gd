class_name MbDistillatore
extends MachineBehavior
## Il Distillatore: posato sopra un lago di Linfa (le stesse regole del Pozzo, `MbPozzo`), con i suoi pulsi distilla una
## Pozione di Linfa ogni `EVERY` secondi di lavoro nella sua cassetta.

const EVERY := 60.0
const OUT := "pozione_linfa"


func _lake(mc: Machine, e: Energy) -> bool:
	var w: World = e.m.world
	var n := 0
	for y in range(mc.o.y + mc.size().y, mc.o.y + mc.size().y + MbPozzo.DEPTH):
		for x in range(mc.o.x - MbPozzo.SIDE, mc.o.x + mc.size().x + MbPozzo.SIDE):
			if w.liq(x, y) > 0 and w.liq_type(x, y) == LiquidsData.LINFA:
				n += 1
	return n >= 8


func demand(mc: Machine, e: Energy) -> float:
	return super.demand(mc, e) if _lake(mc, e) else 0.0


func tick(mc: Machine, e: Energy, dt: float) -> void:
	if not mc.on() or mc.power < 0.99 or not _lake(mc, e):
		return
	var t := float(mc.st.get("t", 0.0)) + dt
	if t >= EVERY:
		var box: Bisaccia = e.m.world.chest_at(mc.o)
		if box.add(OUT, 1) > 0:
			t = EVERY                                   # la cassetta è piena: aspetta
		else:
			t -= EVERY
	mc.st["t"] = t


func state_text(mc: Machine, e: Energy) -> String:
	if not _lake(mc, e):
		return "a secco: va posato sopra un lago di Linfa"
	return super.state_text(mc, e) + " · prossima pozione tra %d s" % roundi(EVERY - float(mc.st.get("t", 0.0)))
