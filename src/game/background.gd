class_name Background
extends Node2D
## Cielo al tramonto, sole, nuvole e tre file di montagne a parallasse. Le montagne seguono con calma l'altezza della
## superficie sotto la visuale, così restano all'orizzonte sia sulle colline sia nelle valli.

const S := 16
const LAYERS := [
	# parallasse, spostamento, larghezza, base, ampiezza, frequenza, colore alto, colore basso, neve, pini
	[0.1, -20.0, 512, 150.0, 80.0, 0.012, "#c4b4e0", "#d4c0dc", true, ""],
	[0.22, 20.0, 512, 150.0, 55.0, 0.016, "#8e84c0", "#7a76ac", false, ""],
	[0.42, 60.0, 512, 150.0, 35.0, 0.02, "#4f6090", "#3e4e78", false, "#34466e"],
]

var world: World
var _layers: Array[Dictionary] = []
var _clouds: Array[Sprite2D] = []
var _sun: Sprite2D
var _horizon := 0.0
var _t := 0.0


func setup(w: World) -> void:
	world = w
	z_index = -30
	_horizon = w.surface[w.spawn.x] * S
	_make_sky()
	_sun = Sprite2D.new()
	_sun.texture = ImageTexture.create_from_image(NatureArt.sun())
	_sun.modulate = Color(2.6, 2.2, 1.6)
	add_child(_sun)
	for k in 6:
		var cl := Sprite2D.new()
		cl.texture = ImageTexture.create_from_image(NatureArt.cloud(w.world_seed + k * 31))
		cl.set_meta("x", k * 260.0 + (k % 2) * 90.0)
		cl.set_meta("y", -150.0 - (k % 3) * 40.0)
		cl.modulate = Color(1, 1, 1, 0.92)
		add_child(cl)
		_clouds.append(cl)
	for k in LAYERS.size():
		var d: Array = LAYERS[k]
		var pines := Color(d[9]) if d[9] != "" else Color(0, 0, 0, 0)
		var im := NatureArt.mountains(d[2], 420, w.world_seed + 50 + k, d[3], d[4], d[5], Color(d[6]), Color(d[7]), d[8], pines)
		var tex := ImageTexture.create_from_image(im)
		var node := Node2D.new()
		add_child(node)
		var sprites: Array[Sprite2D] = []
		for n in 4:
			var sp := Sprite2D.new()
			sp.texture = tex
			sp.centered = false
			node.add_child(sp)
			sprites.append(sp)
		_layers.append({"node": node, "f": d[0], "off": d[1], "w": float(d[2]), "sprites": sprites})


func _make_sky() -> void:
	var sky := CanvasLayer.new()
	sky.layer = -10
	add_child(sky)
	var tr := TextureRect.new()
	var gt := GradientTexture2D.new()
	var gr := Gradient.new()
	gr.offsets = PackedFloat32Array([0.0, 0.42, 0.74, 1.0])
	gr.colors = PackedColorArray([Color("#4a60a8"), Color("#8a94d0"), Color("#f0a890"), Color("#ffdca8")])
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
	_t += dt
	var cx := clampi(int(cp.x / S), 0, world.w - 1)
	var target := float(world.surface[cx] * S)
	_horizon = target if snap else lerpf(_horizon, target, clampf(dt * 1.5, 0.0, 1.0))
	_sun.position = Vector2(cp.x * 0.97 + view.x * 0.22, cp.y * 0.95 + (_horizon - 200.0) * 0.05)
	for cl in _clouds:
		var bx: float = cl.get_meta("x")
		var by: float = cl.get_meta("y")
		var wrap := 1560.0
		var x := fposmod(bx + _t * 6.0 - cp.x * 0.05, wrap) - wrap * 0.5
		cl.position = Vector2(cp.x + x, cp.y * 0.93 + _horizon * 0.07 + by)
	for L in _layers:
		var f: float = L["f"]
		var node: Node2D = L["node"]
		var iw: float = L["w"]
		var off: float = L["off"]
		node.position = Vector2(cp.x * (1.0 - f), _horizon - 150.0 + off + (cp.y - _horizon) * (1.0 - f))
		var k0 := floorf((cp.x - view.x * 0.5 - node.position.x) / iw)
		var sprites: Array = L["sprites"]
		for i in sprites.size():
			(sprites[i] as Sprite2D).position = Vector2((k0 + i) * iw, 0)
