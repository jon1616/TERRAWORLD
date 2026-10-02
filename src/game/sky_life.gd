class_name SkyLife
extends Node2D
## Roadmap 34, voce 331: la vita lontana nel cielo dello sfondo, disegnata dal codice in un piano a parallasse tra le
## nuvole e i monti del bioma (`Background` lo monta e lo fa seguire):
##   - di giorno ogni tanto uno stormo attraversa il cielo (a V o sparso, ali che battono, del colore dei monti lontani);
##   - al tramonto i pipistrelli, a zig-zag;
##   - nei biomi di fuoco (`EMBERS`) le faville che salgono lontano e si spengono.
## Niente fisica né collisioni: sono solo figure. Fuori dalla superficie non si vedono (le copre il terreno).

const F := 0.12                        # parallasse (lontano come le prime colline)
const OFF := -40.0
const FLOCK_EVERY := [35.0, 80.0]      # secondi tra uno stormo e l'altro
const BATS_EVERY := [6.0, 14.0]
const EMBERS := ["brace", "cenere"]
const EMBER_MAX := 26

var bg: Node2D
var _rng := RandomNumberGenerator.new()
var _birds: Array = []                 # {p: Vector2, v: Vector2, ph: fase delle ali, bat: bool, t: tempo}
var _embers: Array = []                # {p, v, t, life}
var _next_flock := 12.0
var _next_bats := 3.0
var _view := Vector2(800, 450)
var _cx := 0.0                         # il centro della visuale nelle coordinate del piano
var col := Color(0.2, 0.3, 0.35)       # il colore delle sagome (dal bioma)
var biome := ""
var time := 0.5
var tint := Color.WHITE                # il colore dell'ora (da `Background.set_time`)
var gain := Color.WHITE                # quanto va compensato il buio per ciò che brilla (le faville)


func setup(b: Node2D, sd: int) -> void:
	bg = b
	_rng.seed = sd + 4242
	z_index = 0


## Lo chiama `Background.follow` a ogni fotogramma.
func follow(cp: Vector2, view: Vector2, horizon: float) -> void:
	position = Vector2(cp.x * (1.0 - F), horizon - 190.0 + OFF + (cp.y - horizon) * (1.0 - F))
	_view = view
	_cx = cp.x - position.x


func is_day() -> bool:
	return time > 0.24 and time < 0.74


func is_dusk() -> bool:
	return time >= 0.74 and time < 0.88


func _process(dt: float) -> void:
	if not visible:
		return
	_next_flock -= dt
	if _next_flock <= 0.0:
		_next_flock = _rng.randf_range(FLOCK_EVERY[0], FLOCK_EVERY[1])
		if is_day():
			flock()
	_next_bats -= dt
	if _next_bats <= 0.0:
		_next_bats = _rng.randf_range(BATS_EVERY[0], BATS_EVERY[1])
		if is_dusk():
			bats()
	for b in _birds:
		b["t"] = float(b["t"]) + dt
		b["ph"] = float(b["ph"]) + dt * (14.0 if b["bat"] else 7.0)
		var v: Vector2 = b["v"]
		if b["bat"]:
			v.y = sin(float(b["t"]) * 5.0 + float(b["ph"]) * 0.1) * 18.0       # a zig-zag
		b["p"] = (b["p"] as Vector2) + v * dt
	_birds = _birds.filter(func(b: Dictionary) -> bool: return absf((b["p"] as Vector2).x - _cx) < _view.x * 0.8 + 60.0 or float(b["t"]) < 2.0)
	_tick_embers(dt)
	queue_redraw()


## Uno stormo da un lato all'altro della visuale (a V o sparso).
## `near` = già in mezzo alla visuale (le prove).
func flock(near := false) -> void:
	var dir := 1.0 if _rng.randf() < 0.5 else -1.0
	var n := _rng.randi_range(5, 11)
	var start := Vector2(_cx - dir * (0.0 if near else _view.x * 0.6 + 30.0), _rng.randf_range(40.0, 120.0))
	var v := Vector2(dir * _rng.randf_range(22.0, 34.0), _rng.randf_range(-2.0, 2.0))
	var vee := _rng.randf() < 0.6
	for i in n:
		var off := Vector2.ZERO
		if vee:
			var k := (i + 1) / 2
			var side := 1.0 if i % 2 == 0 else -1.0
			off = Vector2(-dir * k * 7.0, side * k * 4.0)
		else:
			off = Vector2(_rng.randf_range(-30.0, 30.0), _rng.randf_range(-12.0, 12.0))
		_birds.append({"p": start + off, "v": v * _rng.randf_range(0.95, 1.05), "ph": _rng.randf() * TAU, "bat": false, "t": 0.0})


## Qualche pipistrello al tramonto.
func bats(near := false) -> void:
	for i in _rng.randi_range(2, 4):
		var dir := 1.0 if _rng.randf() < 0.5 else -1.0
		var dx := _rng.randf_range(-80.0, 80.0) if near else dir * (_view.x * 0.55 + _rng.randf_range(0.0, 60.0))
		var p := Vector2(_cx - dx, _rng.randf_range(60.0, 150.0))
		_birds.append({"p": p, "v": Vector2(dir * _rng.randf_range(38.0, 55.0), 0.0), "ph": _rng.randf() * TAU,
			"bat": true, "t": 0.0})


func _tick_embers(dt: float) -> void:
	if biome in EMBERS and _embers.size() < EMBER_MAX and _rng.randf() < dt * 6.0:
		_embers.append({"p": Vector2(_cx + _rng.randf_range(-_view.x * 0.6, _view.x * 0.6), _rng.randf_range(170.0, 215.0)),
			"v": Vector2(_rng.randf_range(-4.0, 4.0), -_rng.randf_range(10.0, 22.0)), "t": 0.0, "life": _rng.randf_range(3.0, 6.0)})
	for e in _embers:
		e["t"] = float(e["t"]) + dt
		var v: Vector2 = e["v"]
		e["p"] = (e["p"] as Vector2) + Vector2(v.x + sin(float(e["t"]) * 2.0) * 3.0, v.y) * dt
	_embers = _embers.filter(func(e: Dictionary) -> bool: return float(e["t"]) < float(e["life"]))


## Quante figure ci sono adesso (le prove).
func count() -> Dictionary:
	var bats_n := 0
	for b in _birds:
		if b["bat"]:
			bats_n += 1
	return {"uccelli": _birds.size() - bats_n, "pipistrelli": bats_n, "faville": _embers.size()}


func _draw() -> void:
	var tc := tint.lerp(Color.WHITE, 0.15)
	for b in _birds:
		var p := ((b["p"] as Vector2)).round()
		var up := sin(float(b["ph"])) > 0.0
		if b["bat"]:
			var c := col.darkened(0.45) * tc
			draw_rect(Rect2(p, Vector2(2, 2)), c)
			var wy := -2.0 if up else 1.0
			draw_rect(Rect2(p + Vector2(-3, wy), Vector2(3, 1)), c)
			draw_rect(Rect2(p + Vector2(2, wy), Vector2(3, 1)), c)
		else:
			# un uccello lontano: ali in su (una V) o in giù (una Λ schiacciata)
			var c := col * tc
			draw_rect(Rect2(p, Vector2(2, 1)), c)
			var wy := -1.0 if up else 1.0
			draw_rect(Rect2(p + Vector2(-3, wy), Vector2(3, 1)), c)
			draw_rect(Rect2(p + Vector2(2, wy), Vector2(3, 1)), c)
			draw_rect(Rect2(p + Vector2(-4, wy * 2.0), Vector2(1, 1)), c)
			draw_rect(Rect2(p + Vector2(5, wy * 2.0), Vector2(1, 1)), c)
	for e in _embers:
		var k := 1.0 - float(e["t"]) / float(e["life"])
		var g := clampf((gain.r + gain.g + gain.b) / 3.0, 1.0, 3.0)    # di notte brillano lo stesso
		var c := Color(2.2 * g, 1.0 * g, 0.35 * g, minf(k * 1.5, 1.0))
		var ep := (e["p"] as Vector2).round()
		draw_rect(Rect2(ep, Vector2(2, 2)), c)
		draw_rect(Rect2(ep + Vector2(0, 2), Vector2(1, 2)), Color(c.r, c.g * 0.6, c.b * 0.5, c.a * 0.5))   # la scia
