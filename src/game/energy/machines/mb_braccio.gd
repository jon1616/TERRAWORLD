class_name MbBraccio
extends MachineBehavior
## Il Braccio di radice: con i suoi pulsi sposta un oggetto al secondo dal contenitore (cassa, o la cassetta di una
## macchina) che tocca il suo lato sinistro a quello che tocca il suo lato destro (`st.dir` = -1: il contrario). Con un
## filtro (`st.filtro`) solo quell'oggetto. Gli oggetti con tratti e dati passano interi.

const EVERY := 1.0


static func _box_at(e: Energy, c: Vector2i) -> Bisaccia:
	var st: Dictionary = e.m.world.station_at(c)
	if st.is_empty() or not StationsData.STATIONS[st["id"]].has("slots"):
		return null
	return e.m.world.chest_at(st["origin"])


func tick(mc: Machine, e: Energy, dt: float) -> void:
	if not mc.on() or mc.power < 0.99:
		return
	var t := float(mc.get_meta("t", 0.0)) - dt
	if t > 0.0:
		mc.set_meta("t", t)
		return
	mc.set_meta("t", EVERY)
	var left := _box_at(e, mc.o + Vector2i(-1, 0))
	var right := _box_at(e, mc.o + Vector2i(1, 0))
	var from := left if int(mc.st.get("dir", 1)) > 0 else right
	var to := right if int(mc.st.get("dir", 1)) > 0 else left
	if from == null or to == null or from == to:
		return
	var f := String(mc.st.get("filtro", ""))
	for i in from.slots.size():
		var id := from.id_at(i)
		if id == "" or (f != "" and id != f):
			continue
		var one: Dictionary = from.slots[i].duplicate(true)
		var single := not one.has("tratto") and not one.has("dati")
		if single:
			one["n"] = 1
		if to.add_stack(one) > 0:
			continue
		if single and int(from.slots[i]["n"]) > 1:
			from.slots[i]["n"] = int(from.slots[i]["n"]) - 1
		else:
			from.slots[i] = {}
		from.changed.emit()
		to.changed.emit()
		mc.st["spostati"] = int(mc.st.get("spostati", 0)) + 1
		return


func panel_rows(mc: Machine, e: Energy) -> Array:
	var d := int(mc.st.get("dir", 1))
	var held := String(e.m.hud.current().get("id", ""))
	var f := String(mc.st.get("filtro", ""))
	return [["Verso", [["da sinistra a destra", d > 0, func() -> void: mc.st["dir"] = 1],
		["da destra a sinistra", d < 0, func() -> void: mc.st["dir"] = -1]]],
		["Filtro", [["tutto", f == "", func() -> void: mc.st["filtro"] = ""],
			["solo: %s" % String(ItemsData.get_item(held).get("name", "ciò che hai in mano")) if held != "" else "(prendi in mano un oggetto)",
				f != "" and f == held, func() -> void:
					if held != "":
						mc.st["filtro"] = held]]]]


func state_text(mc: Machine, e: Energy) -> String:
	var f := String(mc.st.get("filtro", ""))
	return super.state_text(mc, e) + " · spostati: %d%s" % [int(mc.st.get("spostati", 0)),
		(" · solo %s" % String(ItemsData.get_item(f).get("name", f))) if f != "" else ""]
