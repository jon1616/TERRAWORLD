class_name MbIrrigatore
extends MachineBehavior
## L'Irrigatore: con i suoi pulsi e con acqua vicino (a `WATER_R` tessere) annaffia ogni `EVERY` secondi le colture non
## ancora annaffiate nel raggio di `R` tessere, come l'annaffiatoio (la coltura cresce il doppio più in fretta).

const R := 8
const WATER_R := 3
const EVERY := 4.0


func _water_near(mc: Machine, e: Energy) -> bool:
	var w: World = e.m.world
	for y in range(mc.o.y - WATER_R, mc.o.y + WATER_R + 1):
		for x in range(mc.o.x - WATER_R, mc.o.x + WATER_R + 1):
			if w.liq(x, y) >= 2 and w.liq_type(x, y) == LiquidsData.ACQUA:
				return true
	return false


func tick(mc: Machine, e: Energy, dt: float) -> void:
	if not mc.on() or mc.power < 0.99:
		return
	var t := float(mc.get_meta("t", 0.0)) - dt
	if t > 0.0:
		mc.set_meta("t", t)
		return
	mc.set_meta("t", EVERY)
	if not _water_near(mc, e):
		return
	var w: World = e.m.world
	for c: Vector2i in w.crops:
		if absi(c.x - mc.o.x) > R or absi(c.y - mc.o.y) > R:
			continue
		var cr: Array = w.crops[c]
		if float(cr[1]) > 0.0 and not bool(cr[2]):
			cr[1] = float(cr[1]) * 0.5
			cr[2] = true
			mc.st["annaffiate"] = int(mc.st.get("annaffiate", 0)) + 1
			Fx.puff(e.m.fx, Vector2(c) * 16.0 + Vector2(8, 6), Color(0.6, 1.2, 1.6))


func state_text(mc: Machine, e: Energy) -> String:
	if not _water_near(mc, e):
		return "a secco: serve acqua a 3 tessere (una pozza, una fonte, uno sbocco)"
	return super.state_text(mc, e) + " · colture annaffiate: %d" % int(mc.st.get("annaffiate", 0))
