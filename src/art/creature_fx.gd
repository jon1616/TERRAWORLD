class_name CreatureFx
extends RefCounted
## Il corpo vivo delle creature (voce 289, guida `ARTE.md` §8), uguale per tutte: l'ombra di contatto sotto chi sta a
## terra, il respiro da ferme (la metà alta del disegno scende di un pixel e risale: niente scale che sfocano) e la
## dissolvenza alla morte. Una creatura nuova li ha senza scrivere nulla.

const BREATH := """
shader_type canvas_item;
void fragment() {
	float seed = MODEL_MATRIX[3].x * 0.37;
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
