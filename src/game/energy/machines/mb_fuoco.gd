class_name MbFuoco
extends MachineBehavior
## Le sorgenti che bruciano (il Baccello di brace, il Cuore di cristallo): un oggetto della cassetta (`fuel` nei dati:
## oggetto -> secondi) si consuma e dà i pulsi finché dura. Bruciano solo quando la rete ne ha bisogno
## (`Energy.needs`): niente legna sprecata. Con `hot` nei dati: il doppio se ci sono almeno `HOT_CELLS` celle di brace
## liquida vicino.

const HOT_CELLS := 3


func produce(mc: Machine, e: Energy) -> float:
	var burn := float(mc.st.get("burn", 0.0))
	if burn <= 0.0:
		if not e.needs(mc):
			return 0.0
		var box: Bisaccia = e.m.world.chest_at(mc.o)
		var fuel: Dictionary = mc.d.get("fuel", {})
		for id in fuel:
			if box.count(String(id)) > 0:
				box.remove(String(id), 1)
				burn = float(fuel[id])
				break
		mc.st["burn"] = burn
		if burn <= 0.0:
			return 0.0
	var p := float(mc.d["pulsi"])
	if mc.d.has("hot") and _hot(mc, e):
		p *= float(mc.d["hot"])
	return p


func tick(mc: Machine, _e: Energy, dt: float) -> void:
	if mc.made > 0.0:
		mc.st["burn"] = maxf(float(mc.st.get("burn", 0.0)) - dt, 0.0)


func _hot(mc: Machine, e: Energy) -> bool:
	var w: World = e.m.world
	var n := 0
	for y in range(mc.o.y - 3, mc.o.y + mc.size().y + 4):
		for x in range(mc.o.x - 3, mc.o.x + mc.size().x + 3):
			if w.liq(x, y) > 0 and w.liq_type(x, y) == LiquidsData.BRACE:
				n += 1
	return n >= HOT_CELLS


func state_text(mc: Machine, e: Energy) -> String:
	var burn := float(mc.st.get("burn", 0.0))
	if mc.made > 0.0:
		return "brucia: %s (ancora %d s)" % [Energy.pulsi(mc.made), roundi(burn)]
	var box: Bisaccia = e.m.world.chest_at(mc.o)
	for id in mc.d.get("fuel", {}):
		if box.count(String(id)) > 0:
			return "spenta: la rete non ne ha bisogno"
	return "spenta: la cassetta è vuota"
