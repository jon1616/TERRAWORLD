class_name MbPiastra
extends MachineBehavior
## La Piastra di radice: accesa finché qualcuno ci sta sopra. Chi la preme si sceglie nel pannello (`st.chi`): il
## Germogliato (di solito), le creature, o tutti.


func frame(mc: Machine, e: Energy, _dt: float) -> void:
	var r := Rect2(Vector2(mc.o) * 16.0 + Vector2(0, 8), Vector2(mc.size().x * 16.0, 10.0))
	var who := String(mc.st.get("chi", "germogliato"))
	var pressed := false
	if who != "creature":
		var p: Player = e.m.player
		pressed = r.intersects(Rect2(p.position - Player.HALF, Player.HALF * 2.0))
	if not pressed and who != "germogliato":
		for c in e.m.fauna.list:
			if r.intersects(c.rect()):
				pressed = true
				break
	if pressed != bool(mc.st.get("out", false)):
		e.impulse.set_out(mc, pressed)
		e.refresh_look(mc)
