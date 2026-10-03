class_name GardenBackdrop
extends Node2D
## Lo sfondo del Giardino sospeso nel Vuoto (2 ott 2026; l'utente: «quando salto lo sfondo si muove in verticale con
## me, e non mi piace… lo voglio rilassante e armonioso»). Prima restavano solo le radici del cosmo, che seguivano la
## visuale al 95%: saltando sembravano incollate allo schermo. Ora cinque piani tutti suoi (disegni in
## `GardenBackdropArt`), dal più lontano: stelle, nebulosa, mondi-seme, radici del cosmo, isolette con le lanterne;
## e un pulviscolo di luce che sale piano.
## Ogni piano ha due parallassi: `fx` in orizzontale (poca: sono lontani) e `fy` in verticale, molto più grande, così con
## un salto lo sfondo resta al suo posto nel mondo e non viene dietro al Germogliato. Tutto si muove adagio: le nebulose
## scorrono, i mondi-seme e le isole ondeggiano appena. I disegni si fanno in un thread e il cielo compare sfumando.

## [disegno, fx, fy, spostamento verticale, larghezza, altezza, scala, scorrimento px/s, ampiezza e periodo
## dell'ondeggiare]
const PLANES := [
	["stelle", 0.01, 0.3, -330.0, 1024, 560, 1, 0.0, 0.0, 1.0],
	["nebulosa", 0.02, 0.35, -300.0, 512, 260, 2, 1.5, 0.0, 1.0],
	["semi", 0.04, 0.4, -230.0, 1400, 360, 1, 0.0, 3.0, 11.0],
	["radici", 0.07, 0.45, -260.0, 1024, 420, 1, 0.0, 0.0, 1.0],
	["isole", 0.16, 0.6, -40.0, 1280, 260, 1, 0.0, 4.0, 8.0],
]
const FADE := 1.2

var bg: Node2D
var anchor := 0.0                      # l'altezza del Giardino (px): lì i piani stanno com'erano pensati
var _planes: Array = []                # {node, sprites, spec, drift}
var _motes: CPUParticles2D
var _task := -1
var _imgs: Array = []
var _alpha := 0.0
var _t := 0.0
var _tint := Color.WHITE
var _night := 0.0


func setup(b: Node2D, w: World) -> void:
	bg = b
	anchor = float(w.spawn.y * 16)
	var sd: int = w.world_seed
	var out := _imgs
	_task = WorkerThreadPool.add_task(func() -> void: out.append_array(_images(sd)), true, "giardino")
	modulate.a = 0.0


static func _images(sd: int) -> Array:
	var haze := Color(GardenBackdropArt.SKY[2])
	var out := []
	for p in PLANES:
		var w := int(p[4])
		var h := int(p[5])
		match String(p[0]):
			"stelle":
				out.append(GardenBackdropArt.stars(w, h, sd + 11))
			"nebulosa":
				out.append(GardenBackdropArt.nebula(w, h, sd + 12))
			"semi":
				out.append(GardenBackdropArt.seeds(w, h, sd + 13))
			"radici":
				out.append(NatureArt.root_arches(w, h, sd + 14, Color("#4b5d94"), Color("#8f9ccc")))
			_:
				out.append(GardenBackdropArt.islands(w, h, sd + 15, haze, 0.45))
	return out


func _exit_tree() -> void:
	if _task >= 0:
		WorkerThreadPool.wait_for_task_completion(_task)
		_task = -1


func _install() -> void:
	for i in PLANES.size():
		var p: Array = PLANES[i]
		var tex := ImageTexture.create_from_image(_imgs[i])
		var node := Node2D.new()
		add_child(node)
		var k := int(p[6])
		var sprites: Array[Sprite2D] = []
		for n in 2 + ceili(1000.0 / (int(p[4]) * k)):
			var sp := Sprite2D.new()
			sp.texture = tex
			sp.centered = false
			sp.scale = Vector2(k, k)
			if String(p[0]) == "radici":
				sp.modulate.a = 0.55
			node.add_child(sp)
			sprites.append(sp)
		_planes.append({"node": node, "sprites": sprites, "spec": p, "drift": 0.0})
	# il pulviscolo di luce: sale adagio attorno alla visuale
	_motes = CPUParticles2D.new()
	_motes.amount = 22
	_motes.lifetime = 10.0
	_motes.preprocess = 10.0
	_motes.local_coords = false
	_motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_motes.emission_rect_extents = Vector2(520, 320)
	_motes.direction = Vector2(0, -1)
	_motes.spread = 25.0
	_motes.gravity = Vector2(0, -3)
	_motes.initial_velocity_min = 3.0
	_motes.initial_velocity_max = 8.0
	_motes.scale_amount_min = 1.0
	_motes.scale_amount_max = 2.0
	_motes.color_ramp = Fx.fade(Color(1.4, 1.6, 1.5, 0.7))
	var gi := Gradient.new()
	gi.offsets = PackedFloat32Array([0.0, 0.8, 1.0])
	gi.colors = PackedColorArray([GardenBackdropArt.TEAL, GardenBackdropArt.TEAL.lerp(GardenBackdropArt.VIOLET, 0.5), GardenBackdropArt.AMBER])
	_motes.color_initial_ramp = gi
	add_child(_motes)


## Il colore dell'ora (da `Background.set_time`): il Giardino resta morbido anche di notte.
func set_time(tint: Color, night: float) -> void:
	_tint = tint.lerp(Color.WHITE, 0.35)
	_night = night


func _process(dt: float) -> void:
	if _task >= 0 and WorkerThreadPool.is_task_completed(_task):
		WorkerThreadPool.wait_for_task_completion(_task)
		_task = -1
		_install()
	if _planes.is_empty():
		return
	_t += dt
	_alpha = minf(_alpha + dt / FADE, 1.0)
	modulate = Color(_tint.r, _tint.g, _tint.b, _alpha)
	for pl in _planes:
		var sp: Array = pl["spec"]
		pl["drift"] = float(pl["drift"]) + float(sp[7]) * dt
		if String(sp[0]) == "stelle":
			(pl["node"] as Node2D).modulate.a = 0.45 + 0.55 * _night


## Segue la visuale (da `Background.follow`).
func follow(cp: Vector2, view: Vector2) -> void:
	if _motes != null:
		_motes.position = cp
	for pl in _planes:
		var sp: Array = pl["spec"]
		var fx := float(sp[1])
		var fy := float(sp[2])
		var bob := sin(_t * TAU / float(sp[9])) * float(sp[8])
		var node: Node2D = pl["node"]
		node.position = Vector2(cp.x * (1.0 - fx) + float(pl["drift"]), anchor + float(sp[3]) + (cp.y - anchor) * (1.0 - fy) + bob)
		var iw := float(sp[4]) * float(sp[6])
		var k0 := floorf((cp.x - view.x * 0.5 - node.position.x) / iw)
		var sprites: Array = pl["sprites"]
		for i in sprites.size():
			(sprites[i] as Sprite2D).position = Vector2((k0 + i) * iw, 0)


## I nodi dei piani (per le prove).
func nodes() -> Array:
	return _planes.map(func(p: Dictionary) -> Node2D: return p["node"])


## Subito pronto e visibile (le prove).
func snap() -> void:
	if _task >= 0:
		WorkerThreadPool.wait_for_task_completion(_task)
		_task = -1
		_install()
	_alpha = 1.0


func ready_now() -> bool:
	return not _planes.is_empty()
