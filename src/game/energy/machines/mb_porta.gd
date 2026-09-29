class_name MbPorta
extends MachineBehavior
## La Porta di radice viva: chiusa è un muro (tessere `PORTA`) che nessuna creatura attraversa. Con un filo si apre
## finché il filo è acceso (o a ogni colpo); senza fili si apre da sola quando il Germogliato le arriva accanto e si
## richiude quando è passato. Ogni volta che si muove costa `colpo` gocce dalla sua rete (`Energy.spend`): senza
## Linfa resta com'è. Non si chiude addosso a qualcuno.

const NEAR := 22.0                     # px ai lati: quanto vicino deve arrivare il Germogliato
const CLOSE_AFTER := 0.6               # secondi dopo che è passato


func frame(mc: Machine, e: Energy, dt: float) -> void:
	if not mc.st.has("open"):
		_move(mc, e, false)                  # appena messa: chiusa
		return
	var want: bool
	if mc.wired.is_empty():
		var r := Rect2(Vector2(mc.o) * 16.0, Vector2(mc.size()) * 16.0).grow_individual(NEAR, 0, NEAR, 0)
		var p: Player = e.m.player
		var near := r.intersects(Rect2(p.position - Player.HALF, Player.HALF * 2.0))
		var t := float(mc.st.get("t", 0.0))
		t = CLOSE_AFTER if near else maxf(t - dt, 0.0)
		mc.st["t"] = t
		want = t > 0.0
	else:
		want = mc.on()
	var open := bool(mc.st["open"])
	if want == open:
		return
	if not want and _busy(mc, e):
		return
	if e.spend(mc, float(mc.d.get("colpo", 0))):
		_move(mc, e, want)


func _busy(mc: Machine, e: Energy) -> bool:
	var r := Rect2(Vector2(mc.o) * 16.0, Vector2(mc.size()) * 16.0)
	var p: Player = e.m.player
	if r.intersects(Rect2(p.position - Player.HALF, Player.HALF * 2.0)):
		return true
	for c in e.m.fauna.list:
		if r.intersects(c.rect()):
			return true
	return false


func _move(mc: Machine, e: Energy, open: bool) -> void:
	mc.st["open"] = open
	var w: World = e.m.world
	for dy in mc.size().y:
		for dx in mc.size().x:
			var c := mc.o + Vector2i(dx, dy)
			w.set_tile(c.x, c.y, TileDefs.AIR if open else TileDefs.PORTA)
			e.m.view.refresh_around(c)
	e.m.light.dirty = true
	e.refresh_look(mc)
	e.m.sfx.play("legno", mc.center())


func removed(mc: Machine, e: Energy) -> void:
	var w: World = e.m.world
	for dy in mc.size().y:
		for dx in mc.size().x:
			var c := mc.o + Vector2i(dx, dy)
			if w.tile(c.x, c.y) == TileDefs.PORTA:
				w.set_tile(c.x, c.y, TileDefs.AIR)
				e.m.view.refresh_around(c)


func touch(mc: Machine, e: Energy) -> bool:
	if not mc.wired.is_empty():
		return false                           # la comanda il filo: il clic apre il pannello
	# senza fili: il clic la apre o la chiude a mano
	var open := not bool(mc.st.get("open", false))
	if not open and _busy(mc, e):
		return true
	if e.spend(mc, float(mc.d.get("colpo", 0))):
		_move(mc, e, open)
		mc.st["t"] = 3.0 if open else 0.0
	else:
		e.m.hud.toast("La porta non ha Linfa per muoversi: collegala a una rete")
	return true


func state_text(mc: Machine, _e: Energy) -> String:
	var s := "aperta" if bool(mc.st.get("open", false)) else "chiusa"
	return s + (" (la comanda il filo)" if not mc.wired.is_empty() else " (si apre quando arrivi)")
