class_name ImpactFx
extends RefCounted
## Roadmap 35, voce 335: i frammenti dei colpi e dello scavo (le ricette in `ImpactData`). Ogni getto è un
## `CPUParticles2D` che si libera da solo; i colori oltre 1 brillano (bagliore), e quelli `lit` stanno sopra il buio.

## Il blocco `t` si rompe in `pos`; `pal` = i suoi colori (quelli di `TileDefs.dust_colors` o del costrutto).
static func dig(parent: Node, pos: Vector2, t: int, pal: Array[Color], built := "") -> void:
	burst(parent, pos, ImpactData.DIG[dig_kind(t, built)], pal)


## Un colpo di piccone che non ha ancora rotto il blocco.
static func chip(parent: Node, pos: Vector2, t: int, pal: Array[Color]) -> void:
	var specs := [ImpactData.CHIP]
	if dig_kind(t) in ["roccia", "minerale"]:
		specs.append(ImpactData.CHIP_SPARK)
	burst(parent, pos, specs, pal)


## Il tipo di frammenti di un blocco: terra, roccia, minerale, cristallo, legno (i costrutti dal loro materiale).
static func dig_kind(t: int, built := "") -> String:
	if built != "":
		return "legno" if built.contains("legn") or built.contains("tronc") else "roccia"
	if t == TileDefs.CRYSTAL or TileDefs.kind_of(t) == "gemma":
		return "cristallo"
	if TileDefs.kind_of(t) == "minerale":
		return "minerale"
	if TileDefs.kind_of(t) == "suolo":
		return "terra"
	for o in TileDefs.ORES:
		if int(o["type"]) == t:
			return "minerale"
	if t == TileDefs.DIRT or TileDefs.is_grass(t) or float(TileDefs.HARD.get(t, 0.4)) < 0.3:
		return "terra"
	return "roccia"


## Lo schizzo di un colpo con l'elemento `elem` (anche «brace+gelo»: il primo).
## `size` = l'altezza della creatura colpita: lo scoppio dipinto (`HitFlash`, 8 ott 2026) è grande quanto lei.
static func hit(parent: Node, pos: Vector2, elem: String, size := 24.0) -> void:
	var e := elem.get_slice("+", 0)
	burst(parent, pos, ImpactData.HIT.get(e, ImpactData.HIT[""]), [])
	HitFlash.play(parent, pos, e, size)


## Una creatura sconfitta si disfa secondo la sua natura o il suo elemento.
static func death(parent: Node, pos: Vector2, cid: String, data: Dictionary) -> void:
	burst(parent, pos, ImpactData.DEATH[death_kind(cid, data)], [])


static func death_kind(cid: String, data: Dictionary) -> String:
	var nat := BondsData.nature_of(cid)
	if ImpactData.DEATH.has(nat) and nat != "":
		return nat
	var el := String(FamiliesData.parts(cid)[2])
	if el == "":
		el = String(data.get("elem", ""))
	return el if ImpactData.DEATH.has(el) else ""


static func burst(parent: Node, pos: Vector2, specs: Array, pal: Array[Color]) -> void:
	if parent == null or not bool(Settings.v("particelle")):
		return
	for sp in specs:
		_jet(parent, pos, sp, pal)


static func _jet(parent: Node, pos: Vector2, s: Dictionary, pal: Array[Color]) -> void:
	var p := CPUParticles2D.new()
	p.position = pos
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = int(s["n"])
	p.lifetime = float(s["life"])
	var r: Array = s.get("rect", [4, 4])
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(float(r[0]), float(r[1]))
	var d: Array = s.get("dir", [0, -1])
	p.direction = Vector2(float(d[0]), float(d[1]))
	p.spread = float(s.get("spread", 180.0))
	p.gravity = Vector2(0, float(s.get("g", 400.0)))
	var v: Array = s["v"]
	p.initial_velocity_min = float(v[0])
	p.initial_velocity_max = float(v[1])
	var z: Array = s.get("size", [1.0, 2.0])
	p.scale_amount_min = float(z[0])
	p.scale_amount_max = float(z[1])
	p.damping_min = float(s.get("damp", 0.0))
	p.damping_max = float(s.get("damp", 0.0))
	# i colori: varietà da una particella all'altra, e la dissolvenza alla fine
	var cols := _colors(s, pal)
	var gi := Gradient.new()
	if cols.size() == 1:
		gi.offsets = PackedFloat32Array([0.0])
		gi.colors = PackedColorArray([cols[0]])
	else:
		var offs := PackedFloat32Array()
		for i in cols.size():
			offs.append(float(i) / float(cols.size() - 1))
		gi.offsets = offs
		gi.colors = cols
	p.color_initial_ramp = gi
	var a0 := float(s.get("fade", 1.0))
	var gr := Gradient.new()
	gr.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
	gr.colors = PackedColorArray([Color(1, 1, 1, a0), Color(1, 1, 1, a0), Color(1, 1, 1, 0)])
	p.color_ramp = gr
	if s.get("lit", false):
		p.z_as_relative = false
		p.z_index = 26
	parent.add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)


static func _colors(s: Dictionary, pal: Array[Color]) -> PackedColorArray:
	var out := PackedColorArray()
	var g := float(s.get("glow", 1.0))
	var c: Variant = s.get("cols", "pal")
	if c is Array:
		for h in c:
			out.append(_mul(Color(String(h)), g))
	elif pal.size() > 0:
		if String(c) == "bright":
			for i in range(maxi(pal.size() - 2, 0), pal.size()):
				out.append(_mul(pal[i], g))
		else:
			for i in range(1, pal.size()):
				out.append(_mul(pal[i], g))
	if out.is_empty():
		out.append(Color(0.8, 0.75, 0.7))
	return out


static func _mul(c: Color, g: float) -> Color:
	return Color(c.r * g, c.g * g, c.b * g, c.a)
