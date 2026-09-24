class_name Ambience
extends RefCounted
## L'atmosfera della scena: bagliore (glow) sulle cose più luminose del bianco, e spore luminose che fluttuano
## nell'aria attorno alla visuale, in superficie e nelle grotte.


static func environment() -> WorldEnvironment:
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.glow_enabled = true
	env.glow_intensity = 0.7
	env.glow_strength = 1.0
	env.glow_bloom = 0.0
	env.glow_hdr_threshold = 1.0
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	for k in 7:
		env.set_glow_level(k, 1.0 if k >= 1 and k <= 4 else 0.0)
	var we := WorldEnvironment.new()
	we.environment = env
	return we


static func spores() -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.z_index = 26
	p.amount = 70
	p.lifetime = 7.0
	p.preprocess = 7.0
	p.local_coords = false
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(460, 270)
	p.direction = Vector2(0.3, -1)
	p.spread = 60.0
	p.gravity = Vector2(0, -2)
	p.initial_velocity_min = 2.0
	p.initial_velocity_max = 8.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 1.6
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	g.colors = PackedColorArray([Color(0.6, 1.4, 1.3), Color(1.6, 1.2, 0.6), Color(0.9, 0.7, 1.6)])
	p.color_initial_ramp = g
	var fade := Gradient.new()
	fade.offsets = PackedFloat32Array([0.0, 0.2, 0.8, 1.0])
	fade.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 0.8), Color(1, 1, 1, 0.8), Color(1, 1, 1, 0)])
	p.color_ramp = fade
	return p
