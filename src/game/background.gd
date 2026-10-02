class_name Background
extends Node2D
## Cielo di «Radici e Linfa»: turchese profondo che scende al corallo, un sole pallido, le radici del cosmo che fanno
## archi nel cielo, colline lontane e due file di alberi-lanterna a parallasse. Tutto segue con calma l'altezza della
## superficie sotto la visuale, così resta all'orizzonte sia sulle colline sia nelle valli.
## Giorno e notte (`DayCycle` chiama `set_time`): il sole fa il suo arco, di notte c'è la luna, compaiono le stelle e
## cielo e colline prendono il colore dell'ora.
## Roadmap 34, voce 329: ogni bioma ha il suo sfondo (`BackdropData`: il cielo e tre piani, disegni di `BackdropArt`).
## Le radici del cosmo restano di tutti. L'insieme dei piani di un bioma si fa in un thread la prima volta che serve
## (quello della partenza subito) e resta; passando da un bioma all'altro il vecchio sfuma nel nuovo, cielo compreso.

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
var _sets := {}                        # voce 329: bioma -> {"root": Node2D, "layers": [piani come in `_layers`]}
var _jobs := {}                        # bioma -> {"task": id, "imgs": [Image]} (i piani in preparazione)
var _cur := ""                         # il bioma dello sfondo che si vede (o che sta arrivando)
var _old := ""                         # quello che sta sfumando via
var _fade := 1.0                       # 0 → 1 durante il passaggio
var _grad: Gradient
var _sky_from: PackedColorArray
var _sky_to: PackedColorArray
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
	# le radici del cosmo, di tutti i biomi (gli altri piani li ha ogni bioma: voce 329)
	var d0: Array = LAYERS[0]
	_layers.append(_make_layer(self, _layer_image(String(d0[3]), int(d0[2]), w.world_seed + 50), d0[0], d0[1], int(d0[2])))
	var b0 := _biome_id(w.spawn.x)
	_install(b0, _set_images(b0, w.world_seed))
	_cur = b0
	_fade = 1.0
	_sky_to = _sky_colors(b0)
	_sky_from = _sky_to
	_paint_sky(1.0)


func _make_layer(parent: Node, im: Image, f: float, off: float, width: int) -> Dictionary:
	var tex := ImageTexture.create_from_image(im)
	var node := Node2D.new()
	parent.add_child(node)
	var sprites: Array[Sprite2D] = []
	for n in 1 + ceili(1400.0 / width):
		var sp := Sprite2D.new()
		sp.texture = tex
		sp.centered = false
		node.add_child(sp)
		sprites.append(sp)
	return {"node": node, "f": f, "off": off, "w": float(width), "sprites": sprites}


## Il bioma di superficie di una colonna (il suo id).
func _biome_id(x: int) -> String:
	var cx := clampi(x, 0, world.w - 1)
	return String(BiomesData.BIOMES[world.biomes[cx]]["id"])


## Le immagini dei tre piani di un bioma (puro codice: anche in un thread).
static func _set_images(id: String, seed_: int) -> Array:
	var out := []
	var layers: Array = BackdropData.of(id)["layers"]
	for k in layers.size():
		out.append(BackdropArt.layer(layers[k], seed_ + 50 + k * 7 + hash(id) % 1000))
	return out


## Monta i piani di un bioma (nascosti finché non sfumano dentro).
func _install(id: String, imgs: Array) -> void:
	var root := Node2D.new()
	add_child(root)
	var layers: Array = BackdropData.of(id)["layers"]
	var list := []
	for k in layers.size():
		var spec: Array = layers[k]
		list.append(_make_layer(root, imgs[k], float(spec[1]), float(spec[2]), int(spec[3])))
	_sets[id] = {"root": root, "layers": list}
	root.visible = not void_mode


static func _sky_colors(id: String) -> PackedColorArray:
	var out := PackedColorArray()
	for c in BackdropData.of(id)["sky"]:
		out.append(Color(String(c)))
	return out


## Il cielo a metà del passaggio (f da 0 a 1 tra il cielo di prima e quello nuovo).
func _paint_sky(f: float) -> void:
	if _grad == null:
		return
	var cols := PackedColorArray()
	for i in _sky_to.size():
		cols.append(_sky_from[i].lerp(_sky_to[i], f))
	_grad.colors = cols


## Voce 329: subito lo sfondo di un bioma (un salto: portale, rinascita, prove), senza sfumare; se non è pronto si fa
## adesso.
func _snap_set(id: String) -> void:
	if _jobs.has(id):
		WorkerThreadPool.wait_for_task_completion(int(_jobs[id]["task"]))
		_install(id, _jobs[id]["imgs"])
		_jobs.erase(id)
	elif not _sets.has(id):
		_install(id, _set_images(id, world.world_seed))
	_old = ""
	_cur = id
	_fade = 1.0
	_sky_to = _sky_colors(id)
	_sky_from = _sky_to
	_paint_sky(1.0)
	_process(0.0)


## Voce 329: il bioma sotto la visuale cambia → si prepara il suo sfondo (se non c'è) e si sfuma.
func _want(id: String) -> void:
	if id == _cur:
		return
	if not _sets.has(id):
		if not _jobs.has(id):
			var job := {"imgs": []}
			var sd: int = world.world_seed
			job["task"] = WorkerThreadPool.add_task(func() -> void: job["imgs"] = _set_images(id, sd), true, "sfondo")
			_jobs[id] = job
		return
	_old = _cur
	_cur = id
	_fade = 0.0
	_sky_from = _grad.colors if _grad != null else _sky_colors(id)
	_sky_to = _sky_colors(id)


func _process(dt: float) -> void:
	for id in _jobs.keys():
		var job: Dictionary = _jobs[id]
		if WorkerThreadPool.is_task_completed(int(job["task"])):
			WorkerThreadPool.wait_for_task_completion(int(job["task"]))
			_jobs.erase(id)
			_install(String(id), job["imgs"])
	if _fade < 1.0:
		_fade = minf(_fade + dt / BackdropData.FADE, 1.0)
		_paint_sky(_fade)
	if _grad != null and not _layers.is_empty():
		# le radici del cosmo prendono il colore del cielo del bioma (in un cielo rosso non restano turchesi)
		var sk: Color = _grad.colors[1]
		for sp in _layers[0]["sprites"]:
			(sp as Sprite2D).self_modulate = Color(1, 1, 1).lerp(sk.lightened(0.3) / Color("#86bcc4"), 0.6)
	for id in _sets:
		var root: Node2D = _sets[id]["root"]
		var a := 0.0
		if id == _cur:
			a = _fade
		elif id == _old:
			a = 1.0 - _fade
		root.modulate.a = a
		root.visible = a > 0.001 and not void_mode


## Uscendo dalla scena nessun piano deve restare a metà in un thread.
func _exit_tree() -> void:
	for id in _jobs:
		WorkerThreadPool.wait_for_task_completion(int(_jobs[id]["task"]))
	_jobs.clear()


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
	_grad = gr                                   # voce 329: i colori cambiano con il bioma
	gt.gradient = gr
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	gt.width = 4
	gt.height = 256
	tr.texture = gt
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE   # il cielo non prende i clic (li rubava ai pannelli)
	sky.add_child(tr)
	_sky_rect = tr
	# le stelle: un'immagine di puntini sopra il cielo, visibile solo di notte
	_stars = TextureRect.new()
	_stars.texture = ImageTexture.create_from_image(NatureArt.stars(800, 450, world.world_seed))
	_stars.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_stars.stretch_mode = TextureRect.STRETCH_SCALE
	_stars.set_anchors_preset(Control.PRESET_FULL_RECT)
	_stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	for L in _all_layers():
		(L["node"] as Node2D).modulate = tint.lerp(Color.WHITE, 0.15)
	_sun.visible = t > 0.18 and t < 0.82 and not no_lights
	_moon.visible = (not (t > 0.18 and t < 0.82) or t < 0.22 or t > 0.78) and not no_lights
	_sun.modulate = Color(2.2, 2.1, 1.8).lerp(Color(0.04, 0.03, 0.07), eclipse)


## `cp` = centro della visuale in pixel del mondo, `view` = dimensione della visuale in pixel del mondo.
func follow(cp: Vector2, view: Vector2, dt: float, snap := false) -> void:
	var cx := clampi(int(cp.x / S), 0, world.w - 1)
	var target := float(world.surface[cx] * S)
	# voce 329: il cielo e i piani sono del bioma (`BackdropData`); la tinta resta per l'Avvizzimento
	_biome_goal = Color(0.7, 0.7, 0.66) if Blight.surface_blighted(world, cx) else Color.WHITE
	if not void_mode:
		if snap:
			_snap_set(_biome_id(cx))
		else:
			_want(_biome_id(cx))
	biome_tint = _biome_goal if snap else biome_tint.lerp(_biome_goal, clampf(dt * 0.8, 0.0, 1.0))
	_horizon = target if snap else lerpf(_horizon, target, clampf(dt * 1.5, 0.0, 1.0))
	# sole e luna fanno un arco da sinistra a destra: il sole di giorno (0,2-0,8), la luna di notte
	_sun.position = _arc(cp, view, (_time - 0.2) / 0.6)
	_moon.position = _arc(cp, view, fposmod(_time - 0.7, 1.0) / 0.6) + Vector2(0, view.y * 0.1)
	for L in _all_layers():
		if not (L["node"] as Node2D).is_visible_in_tree():
			continue
		var f: float = L["f"]
		var node: Node2D = L["node"]
		var iw: float = L["w"]
		var off: float = L["off"]
		node.position = Vector2(cp.x * (1.0 - f), _horizon - 190.0 + off + (cp.y - _horizon) * (1.0 - f))
		var k0 := floorf((cp.x - view.x * 0.5 - node.position.x) / iw)
		var sprites: Array = L["sprites"]
		for i in sprites.size():
			(sprites[i] as Sprite2D).position = Vector2((k0 + i) * iw, 0)


## Le radici del cosmo e i piani di tutti gli sfondi montati.
func _all_layers() -> Array:
	var out: Array = _layers.duplicate()
	for id in _sets:
		out.append_array(_sets[id]["layers"])
	return out


## Posizione sull'arco del cielo per un avanzamento p (0 = sorge a sinistra, 1 = tramonta a destra).
func _arc(cp: Vector2, view: Vector2, p: float) -> Vector2:
	var x := cp.x + (p - 0.5) * view.x * 1.05
	var y := cp.y - view.y * 0.12 - sin(clampf(p, 0.0, 1.0) * PI) * view.y * 0.34
	return Vector2(x, y + (_horizon - cp.y) * 0.04)


## Il Giardino (voce 62): galleggia nel Vuoto, quindi niente colline né foreste all'orizzonte (solo le radici del
## cosmo) e le stelle si vedono anche di giorno.
func set_void() -> void:
	void_mode = true
	for id in _sets:
		(_sets[id]["root"] as Node2D).visible = false
