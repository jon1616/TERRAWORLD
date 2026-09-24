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
