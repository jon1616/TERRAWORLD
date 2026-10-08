class_name Fx
extends RefCounted
## Piccoli effetti riusabili: sfumature per le particelle, polvere di scavo.


## Gradiente che compare e svanisce, per particelle luminose (colori oltre 1 = bagliore).
static func fade(c: Color) -> Gradient:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	var c0 := c
	c0.a = 0.0
	g.colors = PackedColorArray([c0, c, c0])
	return g


## Nuvoletta di frammenti quando si rompe un blocco; si libera da sola.
static func dust(parent: Node, pos: Vector2, cols: Array[Color]) -> void:
	if not bool(Settings.v("particelle")):
		return
	var p := CPUParticles2D.new()
	p.position = pos
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = 16
	p.lifetime = 0.7
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(6, 6)
	p.direction = Vector2(0, -1)
	p.spread = 180.0
	p.gravity = Vector2(0, 520)
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 110.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.5
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	g.colors = PackedColorArray([cols[1], cols[2], cols[cols.size() - 1]])
	p.color_initial_ramp = g
	parent.add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)


## Numero (o parola) che sale e svanisce sopra un punto: danni inflitti e subiti. Sopra il buio.
static func float_text(parent: Node, pos: Vector2, text: String, col: Color) -> void:
	if parent == null:
		return
	# (Roadmap 55) nel carattere del mondo (MSDF): nitido anche ingrandito dalla telecamera
	var l := Label.new()
	l.text = text
	l.position = pos - Vector2(30, 10)
	l.size = Vector2(60, 12)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiFonts.world(l, 10, col)
	l.z_as_relative = false
	l.z_index = 30
	l.pivot_offset = l.size * 0.5
	parent.add_child(l)
	# salta fuori (un attimo più grande), sale rallentando, svanisce
	l.scale = Vector2(1.5, 1.5)
	var tw := l.create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "position:y", l.position.y - 18.0, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.5).set_delay(0.4)
	tw.chain().tween_callback(l.queue_free)


## Sbuffo di particelle quando una creatura muore.
static func puff(parent: Node, pos: Vector2, col: Color) -> void:
	if not bool(Settings.v("particelle")):
		return
	var p := CPUParticles2D.new()
	p.position = pos
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = 18
	p.lifetime = 0.6
	p.direction = Vector2(0, -1)
	p.spread = 180.0
	p.gravity = Vector2(0, 60)
	p.initial_velocity_min = 20.0
	p.initial_velocity_max = 70.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.5
	p.color_ramp = fade(col)
	p.z_index = 26
	parent.add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)
