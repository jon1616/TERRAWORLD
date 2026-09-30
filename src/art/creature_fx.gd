class_name CreatureFx
extends RefCounted
## Il corpo vivo delle creature (voce 289, guida `ARTE.md` §8), uguale per tutte: l'ombra di contatto sotto chi sta a
## terra, il respiro da ferme (la metà alta del disegno scende di un pixel e risale: niente scale che sfocano) e la
## dissolvenza alla morte. Una creatura nuova li ha senza scrivere nulla.

const BREATH := """
shader_type canvas_item;
varying float seed;
// (MODEL_MATRIX c'è solo nel vertex: il seme di ogni creatura passa da qui)
void vertex() { seed = MODEL_MATRIX[3].x * 0.37; }
void fragment() {
	float b = step(0.45, sin(TIME * 2.1 + seed));
	vec2 uv = UV;
	if (uv.y < 0.5) {
		uv.y -= b * TEXTURE_PIXEL_SIZE.y;
	}
	COLOR = (uv.y < 0.0) ? vec4(0.0) : texture(TEXTURE, uv) * COLOR;
}
"""

static var _breath: ShaderMaterial
static var _shadow: Texture2D


static func breath() -> ShaderMaterial:
	if _breath == null:
		var sh := Shader.new()
		sh.code = BREATH
		_breath = ShaderMaterial.new()
		_breath.shader = sh
	return _breath


## L'ombra: un'ellisse scura e morbida, larga quanto la creatura (la stessa immagine, scalata).
static func shadow_sprite(w: float) -> Sprite2D:
	if _shadow == null:
		var g := Gradient.new()
		g.set_color(0, Color(0, 0, 0, 0.45))
		g.set_color(1, Color(0, 0, 0, 0.0))
		var gt := GradientTexture2D.new()
		gt.gradient = g
		gt.fill = GradientTexture2D.FILL_RADIAL
		gt.fill_from = Vector2(0.5, 0.5)
		gt.fill_to = Vector2(0.5, 0.0)
		gt.width = 32
		gt.height = 8
		_shadow = gt
	var s := Sprite2D.new()
	s.texture = _shadow
	s.scale = Vector2(maxf(w, 8.0) * 1.3 / 32.0, 1.0)
	s.show_behind_parent = true
	return s


## Alla morte: una copia chiara del disegno si solleva di qualche pixel e svanisce.
static func ghost(parent: Node, spr: Sprite2D, at: Vector2) -> void:
	if parent == null or spr == null or spr.texture == null or not bool(Settings.v("particelle")):
		return
	var g := Sprite2D.new()
	g.texture = spr.texture
	g.offset = spr.offset
	g.scale = spr.scale
	g.rotation = spr.rotation
	g.position = at
	g.modulate = Color(2.2, 2.2, 2.0, 0.85)
	g.z_index = 4
	parent.add_child(g)
	var tw := g.create_tween().set_parallel(true)
	tw.tween_property(g, "position:y", at.y - 10.0, 0.4).set_ease(Tween.EASE_OUT)
	tw.tween_property(g, "modulate", Color(1.2, 1.2, 1.2, 0.0), 0.4)
	tw.chain().tween_callback(g.queue_free)


## (voce 290) Il volume, per ogni disegno di creatura (fatto dal codice o da Nano Banana): il contorno nero diventa del
## colore del corpo molto scurito (come fanno i pixel artist: il nero pieno appiattisce), e il corpo prende la luce da
## sinistra in alto (un filo più chiaro dove tocca il contorno in alto e a sinistra, più scuro in basso e a destra).
static func shade(src: Image) -> Image:
	var img := src.duplicate() as Image
	if img.is_compressed():
		return img
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	var edge := PackedByteArray()
	edge.resize(w * h)
	# 1. il contorno: pixel scuri che toccano il vuoto
	for y in h:
		for x in w:
			var c := img.get_pixel(x, y)
			if c.a < 0.5 or c.get_luminance() > 0.13:
				continue
			if _empty(img, x - 1, y) or _empty(img, x + 1, y) or _empty(img, x, y - 1) or _empty(img, x, y + 1):
				edge[y * w + x] = 1
	# 2. il contorno prende il colore del corpo accanto, molto scurito
	for y in h:
		for x in w:
			if edge[y * w + x] == 0:
				continue
			var sum := Vector3.ZERO
			var n := 0
			for d: Vector2i in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var q := Vector2i(x, y) + d
				if q.x < 0 or q.y < 0 or q.x >= w or q.y >= h or edge[q.y * w + q.x] == 1:
					continue
				var b := img.get_pixelv(q)
				if b.a > 0.5 and b.get_luminance() > 0.13:
					sum += Vector3(b.r, b.g, b.b)
					n += 1
			if n > 0:
				var avg := sum / n
				var body := Color(avg.x, avg.y, avg.z)
				var o := body.darkened(0.72)
				o = o.lerp(Color(0.06, 0.03, 0.08), 0.35)          # un velo prugna: il contorno dello stile
				img.set_pixel(x, y, Color(o, img.get_pixel(x, y).a))
	# 3. la luce da sinistra in alto
	var out := img.duplicate() as Image
	for y in h:
		for x in w:
			if edge[y * w + x] == 1:
				continue
			var c := img.get_pixel(x, y)
			if c.a < 0.5:
				continue
			var lit := _is_edge(edge, w, h, x, y - 1) or _is_edge(edge, w, h, x - 1, y)
			var dark := _is_edge(edge, w, h, x, y + 1) or _is_edge(edge, w, h, x + 1, y)
			if lit and not dark:
				out.set_pixel(x, y, Color(c.lightened(0.14), c.a))
			elif dark and not lit:
				out.set_pixel(x, y, Color(c.darkened(0.16), c.a))
	return out


static func _empty(img: Image, x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
		return true
	return img.get_pixel(x, y).a < 0.5


static func _is_edge(edge: PackedByteArray, w: int, h: int, x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < w and y < h and edge[y * w + x] == 1


## (voce 291) La presenza di un boss: un alone che pulsa lento sotto di lui e qualche scintilla che sale, del colore
## della sua ira (ambra; rossa quando è infuriato, lo cambia `Creature._animate`).
static func aura(c: Node2D, size: Vector2) -> Node2D:
	var root := Node2D.new()
	root.z_index = -1
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 0.55))
	g.set_color(1, Color(1, 1, 1, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(0.5, 0.0)
	gt.width = 64
	gt.height = 64
	var halo := Sprite2D.new()
	halo.name = "alone"
	halo.texture = gt
	halo.scale = Vector2(size.x * 2.6 / 64.0, size.y * 1.6 / 64.0)
	halo.modulate = Color(1.6, 0.9, 0.4, 0.35)
	root.add_child(halo)
	var tw := halo.create_tween().set_loops()
	tw.tween_property(halo, "modulate:a", 0.55, 1.2).set_trans(Tween.TRANS_SINE)
	tw.tween_property(halo, "modulate:a", 0.25, 1.2).set_trans(Tween.TRANS_SINE)
	var p := CPUParticles2D.new()
	p.name = "scintille"
	p.amount = 10
	p.lifetime = 1.6
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(size.x, size.y * 0.5)
	p.direction = Vector2(0, -1)
	p.spread = 20.0
	p.gravity = Vector2(0, -20)
	p.initial_velocity_min = 8.0
	p.initial_velocity_max = 22.0
	p.color_ramp = Fx.fade(Color(2.0, 1.1, 0.5))
	p.local_coords = false
	root.add_child(p)
	c.add_child(root)
	c.move_child(root, 0)
	return root
