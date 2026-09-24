class_name Background
extends Node2D
## Cielo di «Radici e Linfa»: turchese profondo che scende al corallo, un sole pallido, le radici del cosmo che fanno
## archi nel cielo, colline lontane e due file di alberi-lanterna a parallasse. Tutto segue con calma l'altezza della
## superficie sotto la visuale, così resta all'orizzonte sia sulle colline sia nelle valli.

const S := 16
const IMG_H := 420
const LAYERS := [
	# parallasse, spostamento verticale, larghezza, tipo
	[0.05, -170.0, 1024, "radici"],
	[0.14, -20.0, 512, "colline"],
	[0.28, 30.0, 640, "foresta_lontana"],
	[0.5, 70.0, 640, "foresta_vicina"],
]

var world: World
var _layers: Array[Dictionary] = []
var _sun: Sprite2D
var _horizon := 0.0


func setup(w: World) -> void:
	world = w
	z_index = -30
	_horizon = w.surface[w.spawn.x] * S
	_make_sky()
	_sun = Sprite2D.new()
	_sun.texture = ImageTexture.create_from_image(NatureArt.sun())
	_sun.modulate = Color(2.2, 2.1, 1.8)
	add_child(_sun)
	for k in LAYERS.size():
		var d: Array = LAYERS[k]
		var width: int = d[2]
		var im := _layer_image(String(d[3]), width, w.world_seed + 50 + k)
		var tex := ImageTexture.create_from_image(im)
		var node := Node2D.new()
		add_child(node)
		var sprites: Array[Sprite2D] = []
		for n in 1 + ceili(1400.0 / width):
			var sp := Sprite2D.new()
			sp.texture = tex
			sp.centered = false
			node.add_child(sp)
			sprites.append(sp)
		_layers.append({"node": node, "f": d[0], "off": d[1], "w": float(width), "sprites": sprites})


func _layer_image(kind: String, width: int, sd: int) -> Image:
	match kind:
		"radici":
			return NatureArt.root_arches(width, IMG_H, sd, Color("#5a92a4"), Color("#86bcc4"))
		"colline":
			return NatureArt.mountains(width, IMG_H, sd, 190.0, 45.0, 0.012, Color("#4f8a98"), Color("#427888"), false, Color(0, 0, 0, 0))
		"foresta_lontana":
			return NatureArt.lantern_forest(width, IMG_H, sd, Color("#2e6474"), Color("#ffd49a"))
	return NatureArt.lantern_forest(width, IMG_H, sd, Color("#1a4252"), Color("#ffc070"))


func _make_sky() -> void:
	var sky := CanvasLayer.new()
	sky.layer = -10
	add_child(sky)
	var tr := TextureRect.new()
	var gt := GradientTexture2D.new()
	var gr := Gradient.new()
	gr.offsets = PackedFloat32Array([0.0, 0.4, 0.72, 1.0])
	gr.colors = PackedColorArray([Color("#1d5670"), Color("#4a9aa6"), Color("#f0ae88"), Color("#ffe2b4")])
	gt.gradient = gr
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	gt.width = 4
	gt.height = 256
	tr.texture = gt
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	sky.add_child(tr)


## `cp` = centro della visuale in pixel del mondo, `view` = dimensione della visuale in pixel del mondo.
func follow(cp: Vector2, view: Vector2, dt: float, snap := false) -> void:
	var cx := clampi(int(cp.x / S), 0, world.w - 1)
	var target := float(world.surface[cx] * S)
	_horizon = target if snap else lerpf(_horizon, target, clampf(dt * 1.5, 0.0, 1.0))
	_sun.position = Vector2(cp.x * 0.98 + view.x * 0.18, cp.y * 0.96 + (_horizon - 240.0) * 0.04)
	for L in _layers:
		var f: float = L["f"]
		var node: Node2D = L["node"]
		var iw: float = L["w"]
		var off: float = L["off"]
		node.position = Vector2(cp.x * (1.0 - f), _horizon - 190.0 + off + (cp.y - _horizon) * (1.0 - f))
		var k0 := floorf((cp.x - view.x * 0.5 - node.position.x) / iw)
		var sprites: Array = L["sprites"]
		for i in sprites.size():
			(sprites[i] as Sprite2D).position = Vector2((k0 + i) * iw, 0)
