class_name MbCatapulta
extends MachineBehavior
## La Catapulta di spore: a ogni impulso che la accende (o un colpo, o il clic destro) lancia chi ci sta sopra (il
## Germogliato e le creature) nella direzione scelta nel pannello (`st.verso`: "su", "sinistra", "destra"). Ogni lancio
## costa `colpo` gocce (`Energy.spend`). Il Germogliato lanciato non si ferisce cadendo sulla stessa altezza.

const POWER := 560.0
const SIDE := Vector2(0.62, -0.78)


func _dir(mc: Machine) -> Vector2:
	match String(mc.st.get("verso", "su")):
		"sinistra":
			return Vector2(-SIDE.x, SIDE.y)
		"destra":
			return SIDE
	return Vector2(0, -1)


func launch(mc: Machine, e: Energy) -> bool:
	var r := Rect2(Vector2(mc.o) * 16.0 + Vector2(-2, -12), Vector2(mc.size().x * 16.0 + 4, 28))
	var p: Player = e.m.player
	var who := []
	if r.intersects(Rect2(p.position - Player.HALF, Player.HALF * 2.0)):
		who.append(p)
	for c in e.m.fauna.list:
		if r.intersects(c.rect()):
			who.append(c)
	if who.is_empty():
		return false
	if not e.spend(mc, float(mc.d.get("colpo", 0))):
		e.m.hud.toast("La catapulta non ha Linfa: collegala a una rete")
		return false
	for b in who:
		b.vel = _dir(mc) * POWER
		b.on_floor = false
		if b == p:
			p.reset_fall()
	mc.set_meta("flash", 0.4)
	e.m.sfx.play("salto", mc.center())
	Fx.puff(e.m.fx, mc.center(), Color(1.2, 1.6, 1.0))
	return true


func on_impulse(mc: Machine, e: Energy, _k: int, kind: String) -> void:
	if kind == "su" or kind == "colpo":
		launch(mc, e)


func touch(mc: Machine, e: Energy) -> bool:
	if not launch(mc, e):
		return false                            # nessuno sopra: il pannello
	return true


func panel_rows(mc: Machine, _e: Energy) -> Array:
	var v := String(mc.st.get("verso", "su"))
	var row := []
	for opt in [["su", "In su"], ["sinistra", "A sinistra"], ["destra", "A destra"]]:
		var o := String(opt[0])
		row.append([String(opt[1]), v == o, func() -> void: mc.st["verso"] = o])
	return [["Lancia", row]]


func state_text(mc: Machine, _e: Energy) -> String:
	return "pronta: lancia %s" % {"su": "in su", "sinistra": "a sinistra", "destra": "a destra"}.get(String(mc.st.get("verso", "su")), "in su")
