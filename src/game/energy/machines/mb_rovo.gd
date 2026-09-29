class_name MbRovo
extends MachineBehavior
## Il Rovo vivo: acceso e con i suoi pulsi punge le creature (non la mandria) che lo attraversano: `DAMAGE` ogni `EVERY`
## secondi a ciascuna. Il Germogliato non si punge mai. Spento (un filo, o il pannello) si ritira: lo si vede dal colore.

const DAMAGE := 12
const EVERY := 0.5


func frame(mc: Machine, e: Energy, _dt: float) -> void:
	if not mc.on() or mc.power < 0.99:
		return
	var r := Rect2(Vector2(mc.o) * 16.0, Vector2(mc.size()) * 16.0)
	var now := Time.get_ticks_msec() / 1000.0
	for c in e.m.fauna.list.duplicate():
		if not is_instance_valid(c) or c.tame != null or not r.intersects(c.rect()):
			continue
		if now - float(c.get_meta("rovo", -9.0)) < EVERY:
			continue
		c.set_meta("rovo", now)
		if c.take_hit(DAMAGE, r.get_center().x, 0.3):
			e.m.fauna.kill(c)
		mc.st["punte"] = int(mc.st.get("punte", 0)) + 1
