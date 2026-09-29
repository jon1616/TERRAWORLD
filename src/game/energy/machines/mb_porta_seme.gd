class_name MbPortaSeme
extends MachineBehavior
## La Porta-seme: clic destro porta il Germogliato davanti alla Porta-seme dello stesso canale (`st.canale`, 1-6, nel
## pannello) più vicina, in qualunque punto del mondo. Il viaggio costa `colpo` gocce della rete di partenza.

const CHANNELS := 6


func _target(mc: Machine, e: Energy) -> Machine:
	var best: Machine = null
	var ch := int(mc.st.get("canale", 1))
	for o: Machine in e.machines.values():
		if o == mc or String(o.d.get("bh", "")) != "porta_seme" or int(o.st.get("canale", 1)) != ch:
			continue
		if best == null or o.center().distance_to(mc.center()) < best.center().distance_to(mc.center()):
			best = o
	return best


func touch(mc: Machine, e: Energy) -> bool:
	if Keys.held("confronta"):
		return false                           # con Maiusc: il pannello (il canale)
	var to := _target(mc, e)
	if to == null:
		e.m.hud.toast("Nessun'altra Porta-seme sul canale %d (Maiusc+clic destro: il pannello)" % int(mc.st.get("canale", 1)))
		return true
	if not e.spend(mc, float(mc.d.get("colpo", 0))):
		e.m.hud.toast("La Porta-seme vuole %d gocce: la sua rete non le ha (una riserva piena aiuta)" % int(mc.d["colpo"]))
		return true
	var dest := to.o + Vector2i(to.size().x / 2, to.size().y - 1)
	e.m.snap_to(dest)
	e.m.sfx.play("portale", to.center())
	Fx.puff(e.m.fx, to.center(), Color(1.0, 1.8, 1.6))
	to.set_meta("flash", 0.6)
	return true


func panel_rows(mc: Machine, _e: Energy) -> Array:
	var row := []
	var cur := int(mc.st.get("canale", 1))
	for k in range(1, CHANNELS + 1):
		var n := k
		row.append([str(k), cur == k, func() -> void: mc.st["canale"] = n])
	return [["Canale", row]]


func state_text(mc: Machine, e: Energy) -> String:
	var to := _target(mc, e)
	if to == null:
		return "canale %d: nessun'altra porta" % int(mc.st.get("canale", 1))
	return "canale %d: porta a %d tessere (Maiusc+clic destro: il pannello)" % [int(mc.st.get("canale", 1)),
		roundi(to.center().distance_to(mc.center()) / 16.0)]
