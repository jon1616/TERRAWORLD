class_name EnergyView
extends RefCounted
## Roadmap 19: come si vede la rete (per `Energy`): l'aspetto delle macchine (bagliore acceso o spento, più scure senza
## energia, la porta aperta trasparente), le loro luci (`LightMap.set_extra("rete")`), il bagliore delle vene dove la
## Linfa scorre.


static func repaint(e: Energy, ni: int) -> void:
	for c: Vector2i in e.nets[ni]["cells"]:
		if e.m.view.chunks.has(World.chunk_of(c)):
			e.m.view.refresh_vein(c)


## [fa luce, ha energia, trasparenza, forza del bagliore] di una macchina (per `ViewProps`). Il bagliore di una riserva
## dice quanto è piena.
static func look(e: Energy, o: Vector2i) -> Array:
	var mc: Machine = e.machines.get(o)
	if mc == null:
		return [true, true, 1.0, 1.0]
	var needs := float(mc.d.get("pulsi", 0)) > 0.0
	var powered := mc.role() != "macchina" or not needs or mc.power >= 0.99 or not mc.on()
	var glow := mc.lit if mc.d.has("light") else (mc.role() != "macchina" or mc.power >= 0.99)
	var alpha := 1.0
	var gk := 1.0
	match mc.role():
		"sorgente":
			glow = mc.made > 0.01
		"riserva":
			var fill := float(mc.st.get("g", 0.0)) / maxf(float(mc.d.get("cap", 1)), 1.0)
			glow = fill > 0.001
			gk = snappedf(0.25 + 0.75 * fill, 0.05)
		"comando", "nodo":
			glow = bool(mc.st.get("out", false)) or float(mc.get_meta("flash", 0.0)) > 0.0
	if mc.d.get("porta", false):
		glow = bool(mc.st.get("open", false))
		alpha = 0.3 if glow else 1.0
		powered = true
	return [glow, powered, alpha, gk]


static func refresh_look(e: Energy, mc: Machine) -> void:
	var lk := look(e, mc.o)
	mc.set_meta("look", lk)
	e.m.view.props.set_machine_look(mc.o, bool(lk[0]), bool(lk[1]), float(lk[2]), float(lk[3]))


static func update_looks(e: Energy) -> void:
	var lights := []
	var zones := []
	for mc: Machine in e.machines.values():
		if mc.has_meta("flash"):
			mc.set_meta("flash", maxf(float(mc.get_meta("flash")) - Energy.TICK, 0.0))
		var lk := look(e, mc.o)
		if mc.get_meta("look", []) != lk:
			mc.set_meta("look", lk)
			e.m.view.props.set_machine_look(mc.o, bool(lk[0]), bool(lk[1]), float(lk[2]), float(lk[3]))
		if mc.lit and mc.d.has("light"):
			var col: Color = mc.d["light"]
			if mc.st.has("col"):
				col = Color(String(mc.st["col"])) * 1.6            # l'Insegna: il colore scelto
			lights.append([mc.o, col])
		if mc.d.has("zona") and mc.role() == "macchina" and mc.on() and mc.power >= 0.99:
			var z: Array = mc.d["zona"]
			zones.append([mc.center(), String(z[0]), float(z[1]) * 16.0, float(z[2])])
	if lights != e._lights:
		e._lights = lights
		e.m.light.set_extra("rete", lights)
	if e.m.get("zones") != null and e.m.zones.powered != zones:
		e.m.zones.powered = zones
