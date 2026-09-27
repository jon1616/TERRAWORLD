class_name Background
extends Node2D
## Cielo di «Radici e Linfa»: turchese profondo che scende al corallo, un sole pallido, le radici del cosmo che fanno
## archi nel cielo, colline lontane e due file di alberi-lanterna a parallasse. Tutto segue con calma l'altezza della
## superficie sotto la visuale, così resta all'orizzonte sia sulle colline sia nelle valli.
## Giorno e notte (`DayCycle` chiama `set_time`): il sole fa il suo arco, di notte c'è la luna, compaiono le stelle e
## cielo e colline prendono il colore dell'ora.

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
var eclipse := 0.0                     # voce 78: quanto è piena l'eclissi (il sole diventa un disco scuro)
var no_lights := false                 # voce 78: mondo senza sole, né sole né luna
var _moon: Sprite2D
var _sky_rect: TextureRect
var _stars: TextureRect
var _time := 0.3
var biome_tint := Color.WHITE          # colore del bioma di superficie sotto la visuale (sfumato)
var season_tint := Color.WHITE         # voce 66: un velo del colore della stagione
var weather_tint := Color.WHITE        # voce 75: il cielo del tempo che fa
var _biome_goal := Color.WHITE
var _horizon := 0.0
var void_mode := false                 # voce 62: il Giardino sospeso nel Vuoto (niente colline né foreste, sempre le stelle)


func setup(w: World) -> void:
	world = w
	z_index = -30
	_horizon = w.surface[w.spawn.x] * S
	_make_sky()
	_sun = Sprite2D.new()
	_sun.texture = ImageTexture.create_from_image(NatureArt.sun())
	_sun.modulate = Color(2.2, 2.1, 1.8)
	add_child(_sun)
	_moon = Sprite2D.new()
	_moon.texture = ImageTexture.create_from_image(NatureArt.moon())
	_moon.modulate = Color(1.4, 1.6, 1.7)
	add_child(_moon)
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
	_sky_rect = tr
	# le stelle: un'immagine di puntini sopra il cielo, visibile solo di notte
	_stars = TextureRect.new()
	_stars.texture = ImageTexture.create_from_image(NatureArt.stars(800, 450, world.world_seed))
	_stars.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_stars.stretch_mode = TextureRect.STRETCH_SCALE
	_stars.set_anchors_preset(Control.PRESET_FULL_RECT)
	_stars.modulate.a = 0.0
	sky.add_child(_stars)


## Ora del giorno (0-1), colore della scena e quanto è notte (0-1).
## `star_gain` compensa la luce che moltiplica anche lo sfondo (vedi `DayCycle.apply`).
func set_time(t: float, tint: Color, night: float, star_gain := Color.WHITE) -> void:
	_time = t
	tint *= biome_tint * season_tint * weather_tint
	_sky_rect.modulate = tint
	_stars.modulate = Color(minf(star_gain.r, 6.0), minf(star_gain.g, 6.0), minf(star_gain.b, 6.0),
		maxf(night, 0.55) if void_mode else night)
	_moon.modulate = Color(0.95, 1.05, 1.1) * Color(minf(star_gain.r, 2.5), minf(star_gain.g, 2.5), minf(star_gain.b, 2.5))
	for L in _layers:
		(L["node"] as Node2D).modulate = tint.lerp(Color.WHITE, 0.15)
	_sun.visible = t > 0.18 and t < 0.82 and not no_lights
	_moon.visible = (not (t > 0.18 and t < 0.82) or t < 0.22 or t > 0.78) and not no_lights
	_sun.modulate = Color(2.2, 2.1, 1.8).lerp(Color(0.04, 0.03, 0.07), eclipse)


## `cp` = centro della visuale in pixel del mondo, `view` = dimensione della visuale in pixel del mondo.
func follow(cp: Vector2, view: Vector2, dt: float, snap := false) -> void:
	var cx := clampi(int(cp.x / S), 0, world.w - 1)
	var target := float(world.surface[cx] * S)
	_biome_goal = Color(0.7, 0.7, 0.66) if Blight.surface_blighted(world, cx) else BiomesData.BIOMES[world.biomes[cx]]["tint"]
	biome_tint = _biome_goal if snap else biome_tint.lerp(_biome_goal, clampf(dt * 0.8, 0.0, 1.0))
	_horizon = target if snap else lerpf(_horizon, target, clampf(dt * 1.5, 0.0, 1.0))
	# sole e luna fanno un arco da sinistra a destra: il sole di giorno (0,2-0,8), la luna di notte
	_sun.position = _arc(cp, view, (_time - 0.2) / 0.6)
	_moon.position = _arc(cp, view, fposmod(_time - 0.7, 1.0) / 0.6) + Vector2(0, view.y * 0.1)
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


## Posizione sull'arco del cielo per un avanzamento p (0 = sorge a sinistra, 1 = tramonta a destra).
func _arc(cp: Vector2, view: Vector2, p: float) -> Vector2:
	var x := cp.x + (p - 0.5) * view.x * 1.05
	var y := cp.y - view.y * 0.12 - sin(clampf(p, 0.0, 1.0) * PI) * view.y * 0.34
	return Vector2(x, y + (_horizon - cp.y) * 0.04)


## Il Giardino (voce 62): galleggia nel Vuoto, quindi niente colline né foreste all'orizzonte (solo le radici del
## cosmo) e le stelle si vedono anche di giorno.
func set_void() -> void:
	void_mode = true
	for k in range(1, _layers.size()):
		(_layers[k]["node"] as Node2D).visible = false
