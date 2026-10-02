class_name SurfaceLife
extends Node2D
## Roadmap 35, voce 339: la vita minuta della superficie (i biomi e i numeri in `SurfaceLifeData`):
##   - lucciole al tramonto e di notte, che vagano e lampeggiano (sopra il buio: brillano da sé)
##   - polline che galleggia di giorno nei prati, spinto dal vento
##   - foglie che cadono dagli alberi della visuale, svolazzando, e si posano (dai tizzoni cade cenere)
##   - l'erba che si piega al passaggio del Germogliato e delle creature (`WindFx.set_push`)
## Solo disegno, solo vicino alla superficie e solo nella visuale; niente si salva.

const S := 16

var m: Node2D
var _glow: Node2D                      # le lucciole, sopra il buio
var _flies: Array = []                 # {p, home, v, t, ph, col}
var _pollen: Array = []                # {p, v, t, life, col}
var _leaves: Array = []                # {p, v, t, ph, col, rest}
var _rng := RandomNumberGenerator.new()
var _view := Rect2()
var _biome := ""


func setup(main: Node2D) -> void:
	m = main
	z_as_relative = false
	z_index = 3
	_glow = Node2D.new()
	_glow.z_as_relative = false
	_glow.z_index = 26
	add_child(_glow)
	_glow.draw.connect(_draw_glow)
	_rng.seed = 339


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	_push()
	var cam: Camera2D = m.cam
	var size: Vector2 = m.get_viewport_rect().size / cam.zoom
	_view = Rect2(cam.get_screen_center_position() - size * 0.5, size)
	var w: World = m.world
	var cx := clampi(floori(_view.get_center().x / S), 0, w.w - 1)
	_biome = String(BiomesData.BIOMES[w.biomes[cx]]["id"])
	# solo vicino alla superficie (sotto terra niente di tutto questo)
	var near := _view.get_center().y < float(w.surface[cx] * S) + 220.0
	var wind: float = float(m.weather.wind) if m.weather != null else 0.0
	_tick_flies(dt, near)
	_tick_pollen(dt, near, wind)
	_tick_leaves(dt, near, wind)
	queue_redraw()
	_glow.queue_redraw()


## Quanto è sera o notte (0-1): sale al tramonto, cala all'alba.
func night() -> float:
	var t: float = m.day.time
	if t >= 0.74:
		return clampf((t - 0.74) / 0.08, 0.0, 1.0)
	if t < 0.24:
		return clampf((0.24 - t) / 0.08, 0.0, 1.0)
	return 0.0


func _tick_flies(dt: float, near: bool) -> void:
	var want := 0
	if near and SurfaceLifeData.FIREFLIES.has(_biome):
		want = roundi(SurfaceLifeData.MAX_FIREFLIES * night())
	if _flies.size() < want and _rng.randf() < dt * 6.0:
		var p := _air_above_ground(1, 6)
		if p.x > -1e8:
			_flies.append({"p": p, "home": p, "v": Vector2.ZERO, "t": 0.0, "ph": _rng.randf() * TAU,
				"col": Color(String(SurfaceLifeData.FIREFLIES[_biome]))})
	var keep: Array = []
	for f in _flies:
		f["t"] = float(f["t"]) + dt
		var v: Vector2 = f["v"]
		v += Vector2(_rng.randf_range(-1, 1), _rng.randf_range(-1, 1)) * 60.0 * dt
		v += ((f["home"] as Vector2) - (f["p"] as Vector2)) * 0.25 * dt      # restano attorno a casa
		v = v.limit_length(14.0)
		f["v"] = v
		f["p"] = (f["p"] as Vector2) + v * dt
		# troppe o fuori dalla visuale: si spengono
		if _view.grow(80.0).has_point(f["p"]) and keep.size() < maxi(want, 0) + 2:
			keep.append(f)
	if keep.size() > want:
		keep.resize(want)
	_flies = keep


func _tick_pollen(dt: float, near: bool, wind: float) -> void:
	var day := 1.0 - night()
	if near and SurfaceLifeData.POLLEN.has(_biome) and day > 0.5 and _pollen.size() < SurfaceLifeData.MAX_POLLEN \
			and _rng.randf() < dt * 5.0:
		var p := _air_above_ground(1, 5)
		if p.x > -1e8:
			_pollen.append({"p": p, "v": Vector2(_rng.randf_range(-4, 4), _rng.randf_range(-3, 1)), "t": 0.0,
				"life": _rng.randf_range(5.0, 9.0), "col": Color(String(SurfaceLifeData.POLLEN[_biome]))})
	for q in _pollen:
		q["t"] = float(q["t"]) + dt
		var v: Vector2 = q["v"]
		q["p"] = (q["p"] as Vector2) + Vector2(v.x + wind * 0.15, v.y + sin(float(q["t"]) * 1.7) * 3.0) * dt
	_pollen = _pollen.filter(func(q: Dictionary) -> bool: return float(q["t"]) < float(q["life"]))


func _tick_leaves(dt: float, near: bool, wind: float) -> void:
	var w: World = m.world
	if near and _leaves.size() < SurfaceLifeData.MAX_LEAVES:
		var k0 := World.chunk_of(Vector2i(floori(_view.position.x / S), floori(_view.position.y / S)))
		var k1 := World.chunk_of(Vector2i(floori(_view.end.x / S), floori(_view.end.y / S)))
		var rate := dt / SurfaceLifeData.LEAVES * (1.0 + absf(wind) / 80.0)
		for ky in range(k0.y, k1.y + 1):
			for kx in range(k0.x, k1.x + 1):
				for t in w.trees.get(Vector2i(kx, ky), []):
					if _rng.randf() < rate:
						_leaf(t)
	for l in _leaves:
		l["t"] = float(l["t"]) + dt
		if float(l["rest"]) > 0.0:
			l["rest"] = float(l["rest"]) + dt
			continue
		var t := float(l["t"])
		var p: Vector2 = l["p"]
		var np := p + Vector2(sin(t * 2.3 + float(l["ph"])) * 14.0 + wind * 0.3, 16.0 + sin(t * 4.6) * 6.0) * dt
		var c := Vector2i(floori(np.x / S), floori((np.y + 1.0) / S))
		if w.solid(c.x, c.y) or w.liq(c.x, c.y) > 0:
			l["rest"] = 0.01                      # si posa
		else:
			l["p"] = np
	_leaves = _leaves.filter(func(l: Dictionary) -> bool: return float(l["rest"]) < 2.5 and float(l["t"]) < 25.0)


func _leaf(t: Vector3i) -> void:
	var d := TreesData.decode(t.z)
	var sp: Dictionary = TreesData.SPECIES[d[0]]
	var bid := String(sp.get("biome", ""))
	if bid in SurfaceLifeData.NO_LEAVES:
		return
	var h := float(TreesData.SIZES[d[1]]["h"])
	var p := Vector2(t.x * S + 8 + _rng.randf_range(-h * 0.25, h * 0.25), (t.y + 1) * S - h * _rng.randf_range(0.45, 0.9))
	if not _view.grow(40.0).has_point(p):
		return
	var col := Color("#6a6460")
	if not bid in SurfaceLifeData.ASH_TREES:
		var pal: Array = _turf(bid)
		col = Color(String(pal[_rng.randi_range(maxi(pal.size() - 3, 0), pal.size() - 1)]))
	_leaves.append({"p": p, "v": Vector2.ZERO, "t": 0.0, "ph": _rng.randf() * TAU, "col": col, "rest": 0.0})


## I colori dell'erba di un bioma (le foglie prendono quelli), letti una volta.
static var _turfs := {}
static func _turf(bid: String) -> Array:
	if _turfs.is_empty():
		for b in BiomesData.BIOMES:
			_turfs[String(b["id"])] = (b.get("turf", {}) as Dictionary).get("pal", ["#23776a", "#3aa08a", "#72d4b0"])
	return _turfs.get(bid, ["#23776a", "#3aa08a", "#72d4b0"])


## Un punto d'aria fra `lo` e `hi` tessere sopra il terreno, in una colonna a caso della visuale (o lontanissimo se non c'è).
func _air_above_ground(lo: int, hi: int) -> Vector2:
	var w: World = m.world
	for i in 6:
		var x := clampi(floori(_rng.randf_range(_view.position.x, _view.end.x) / S), 1, w.w - 2)
		var y: int = w.surface[x] - _rng.randi_range(lo, hi)
		if y > 0 and not w.solid(x, y) and w.liq(x, y) == 0:
			return Vector2(x * S + _rng.randf_range(2, 14), y * S + _rng.randf_range(2, 14))
	return Vector2(-1e9, 0)


## L'erba si piega: il Germogliato e le creature più vicine che camminano.
func _push() -> void:
	var arr: Array[Vector3] = []
	var p: Player = m.player
	var feet := p.position + Vector2(0, Player.HALF.y - 6.0)
	arr.append(Vector3(feet.x, feet.y, 1.0 if absf(p.vel.x) > 5.0 else 0.5))
	for c in m.fauna.list:
		if arr.size() >= SurfaceLifeData.PUSHERS:
			break
		if is_instance_valid(c) and c.on_floor and c.position.distance_squared_to(p.position) < 300.0 * 300.0:
			var hy: float = float(c.data.get("half", [8, 8])[1])
			arr.append(Vector3(c.position.x, c.position.y + hy - 6.0, 1.0 if absf(c.vel.x) > 5.0 else 0.5))
	while arr.size() < SurfaceLifeData.PUSHERS:
		arr.append(Vector3(-1e6, -1e6, 0.0))
	WindFx.set_push(arr)


func _draw() -> void:
	for q in _pollen:
		var k := float(q["t"]) / float(q["life"])
		var a := minf(k * 4.0, 1.0) * minf((1.0 - k) * 3.0, 1.0) * 0.85
		draw_rect(Rect2((q["p"] as Vector2).round(), Vector2(1, 1)), Color(q["col"], a))
	for l in _leaves:
		var a := 1.0 - clampf((float(l["rest"]) - 1.0) / 1.5, 0.0, 1.0)
		var flat := sin(float(l["t"]) * 4.6 + float(l["ph"])) > 0.0 or float(l["rest"]) > 0.0
		draw_rect(Rect2((l["p"] as Vector2).round(), Vector2(2, 1) if flat else Vector2(1, 2)), Color(l["col"], a))


func _draw_glow() -> void:
	for f in _flies:
		var b := 0.5 + 0.5 * sin(float(f["t"]) * 2.2 + float(f["ph"]))
		b = b * b
		if b < 0.05:
			continue
		var c: Color = f["col"]
		var p := (f["p"] as Vector2).round()
		_glow.draw_rect(Rect2(p, Vector2(1, 1)), Color(c.r * 2.4, c.g * 2.4, c.b * 2.4, b))
		var halo := Color(c.r * 1.4, c.g * 1.4, c.b * 1.4, b * 0.3)
		_glow.draw_rect(Rect2(p + Vector2(-1, 0), Vector2(1, 1)), halo)
		_glow.draw_rect(Rect2(p + Vector2(1, 0), Vector2(1, 1)), halo)
		_glow.draw_rect(Rect2(p + Vector2(0, -1), Vector2(1, 1)), halo)
		_glow.draw_rect(Rect2(p + Vector2(0, 1), Vector2(1, 1)), halo)


## Le misure per le prove.
func counts() -> Dictionary:
	return {"lucciole": _flies.size(), "polline": _pollen.size(), "foglie": _leaves.size()}
