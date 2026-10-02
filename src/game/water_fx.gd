class_name WaterFx
extends Node2D
## Roadmap 35, voce 336: la vita sulla superficie dei liquidi (il riflesso e le cascate li disegna `LiquidView`).
##   - increspature: la pioggia sugli specchi all'aperto, chi entra o esce, chi nuota (anelli di pixel che si allargano)
##   - spruzzi: tuffi e uscite del Germogliato e delle creature vicine (`ImpactData.SPLASH`)
##   - schiuma ai piedi delle cascate
##   - il colore del cielo che `LiquidView` riflette
## Solo disegno: non cambia i liquidi.

const S := 16
const SCAN := 0.5                      # ogni quanto si cercano le superfici nella visuale (secondi)
const RIPPLE_LIFE := 0.8
const MAX_RIPPLES := 90
const RAIN_RATE := 150.0               # increspature al secondo per ogni 100 celle di superficie con la pioggia piena

var m: Node2D
var _surf: Array = []                  # [punto della superficie (px), all'aperto]
var _falls: Array = []                 # punti dove una cascata tocca uno specchio
var _ripples: Array = []               # {p, t, w}
var _in := {}                          # id dell'istanza -> era nel liquido
var _scan_t := 0.0
var _foam_t := 0.0
var _swim_t := 0.0
var _sky_t := 0.0
var _rain_acc := 0.0
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	z_as_relative = false
	z_index = 13
	_rng.seed = 335


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	_scan_t -= dt
	if _scan_t <= 0.0:
		_scan_t = SCAN
		_scan()
	_sky(dt)
	_rain(dt)
	_bodies(dt)
	_foam(dt)
	for r in _ripples:
		r["t"] = float(r["t"]) + dt
	_ripples = _ripples.filter(func(r: Dictionary) -> bool: return float(r["t"]) < RIPPLE_LIFE)
	queue_redraw()


## Le superfici e i piedi delle cascate nella visuale.
func _scan() -> void:
	_surf.clear()
	_falls.clear()
	var w: World = m.world
	var cam: Camera2D = m.cam
	var view: Vector2 = m.get_viewport_rect().size / cam.zoom
	var ctr := cam.get_screen_center_position()
	var x0 := maxi(floori((ctr.x - view.x * 0.5) / S) - 1, 1)
	var x1 := mini(floori((ctr.x + view.x * 0.5) / S) + 1, w.w - 2)
	var y0 := maxi(floori((ctr.y - view.y * 0.5) / S) - 1, 1)
	var y1 := mini(floori((ctr.y + view.y * 0.5) / S) + 1, w.h - 2)
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			var lv := w.liq(x, y)
			if lv <= 0:
				continue
			if w.liq(x, y - 1) == 0 and not w.solid(x, y - 1):
				_surf.append([Vector2(x * S + 8, y * S + 16.0 - 16.0 * lv / 8.0), w.wall(x, y) == 0])
			elif w.liq(x - 1, y) == 0 and w.liq(x + 1, y) == 0 and w.liq(x, y + 1) > 0 \
					and (w.liq(x - 1, y + 1) > 0 or w.liq(x + 1, y + 1) > 0):
				_falls.append(Vector2(x * S + 8, (y + 1) * S + 1))


## Il colore del cielo che si riflette: il cielo del bioma, con la luce dell'ora.
func _sky(dt: float) -> void:
	_sky_t -= dt
	if _sky_t > 0.0:
		return
	_sky_t = 0.25
	var bg: Background = m.background
	var mat: ShaderMaterial = m.liquids.view.material
	if bg == null or mat == null or bg._grad == null:
		return
	var sk: Color = bg._grad.colors[1].lerp(Color.WHITE, 0.25) * bg._sky_rect.modulate
	mat.set_shader_parameter("sky_tint", sk)


func _rain(dt: float) -> void:
	if m.weather == null or _surf.is_empty():
		return
	var rain := float(m.weather.state().get("rain", 0.0))
	if rain <= 0.0 or not m.weather.outdoor():
		return
	_rain_acc += dt * RAIN_RATE * rain * _surf.size() / 100.0
	while _rain_acc >= 1.0:
		_rain_acc -= 1.0
		var s: Array = _surf[_rng.randi_range(0, _surf.size() - 1)]
		if s[1]:
			ripple((s[0] as Vector2) + Vector2(_rng.randf_range(-7.0, 7.0), 0), 0.6)


## Chi entra o esce da un liquido schizza; chi nuota lascia increspature.
func _bodies(dt: float) -> void:
	var p: Player = m.player
	_watch(p, p.position + Vector2(0, Player.HALF.y), p.vel.length())
	_swim_t -= dt
	if p.in_liquid and absf(p.vel.x) > 20.0 and _swim_t <= 0.0:
		_swim_t = 0.3
		var top := _top_above(p.position)
		if top.x > -1e8:
			ripple(top, 0.8)
	for c in m.fauna.list:
		if is_instance_valid(c) and c.position.distance_squared_to(p.position) < 420.0 * 420.0:
			_watch(c, c.position, c.vel.length())
	for k in _in.keys():
		if not is_instance_id_valid(k):
			_in.erase(k)


func _watch(who: Node2D, feet: Vector2, speed: float) -> void:
	var w: World = m.world
	var c := Vector2i(floori(feet.x / S), floori((feet.y - 2.0) / S))
	var wet := w.liq(c.x, c.y) >= 2
	var id := who.get_instance_id()
	var was: bool = _in.get(id, wet)
	_in[id] = wet
	if wet == was:
		return
	var top := _top_above(feet + Vector2(0, -2))
	if top.x < -1e8:
		return
	var td: Dictionary = LiquidsData.TYPES[w.liq_type(c.x, c.y) if wet else w.liq_type(c.x, c.y + 1)]
	var pal: Array[Color] = [td["color"], td["top"], (td["top"] as Color).lightened(0.3)]
	var big := clampf(speed / 200.0, 0.4, 1.0) * (1.0 if wet else 0.6)
	var spec: Dictionary = ImpactData.SPLASH.duplicate()
	spec["n"] = roundi(float(spec["n"]) * big)
	ImpactFx.burst(m.fx, top, [spec], pal)
	ripple(top, 1.0)
	ripple(top + Vector2(0, 0), 0.5)
	m.sfx.play("tuffo", top)


## Il punto della superficie sopra (o appena sotto) una posizione: cerca la prima cella senza liquido sopra.
func _top_above(pos: Vector2) -> Vector2:
	var w: World = m.world
	var x := floori(pos.x / S)
	var y := floori(pos.y / S)
	for i in 6:
		if w.liq(x, y) > 0 and w.liq(x, y - 1) == 0:
			return Vector2(pos.x, y * S + 16.0 - 16.0 * w.liq(x, y) / 8.0)
		if w.liq(x, y) == 0:
			y += 1
		else:
			y -= 1
	return Vector2(-1e9, 0)


func _foam(dt: float) -> void:
	_foam_t -= dt
	if _foam_t > 0.0 or _falls.is_empty():
		return
	_foam_t = 0.22
	for f in _falls.slice(0, 6):
		ripple(f + Vector2(_rng.randf_range(-3.0, 3.0), 0), 0.7)
		ImpactFx.burst(m.fx, f, [ImpactData.FOAM], [Color("#cfe8ff"), Color("#ffffff")])


## Un anello sulla superficie in `p`; `w` = quanto è grande (0-1).
func ripple(p: Vector2, w := 1.0) -> void:
	if _ripples.size() >= MAX_RIPPLES:
		_ripples.pop_front()
	_ripples.append({"p": p, "t": 0.0, "w": w})


func _draw() -> void:
	for r in _ripples:
		var k := float(r["t"]) / RIPPLE_LIFE
		var rad := roundf(1.0 + k * 13.0 * float(r["w"]))
		var a := (1.0 - k) * 0.75
		var p: Vector2 = (r["p"] as Vector2).round()
		var col := Color(0.92, 0.97, 1.0, a)
		# due archi di pixel che si allontanano, un filo più su al centro (l'anello visto di sbieco)
		draw_rect(Rect2(p.x - rad - 2.0, p.y, 3.0, 1.0), col)
		draw_rect(Rect2(p.x + rad, p.y, 3.0, 1.0), col)
		if rad > 3.0:
			draw_rect(Rect2(p.x - rad * 0.5 - 1.0, p.y - 1.0, 2.0, 1.0), Color(col, a * 0.6))
			draw_rect(Rect2(p.x + rad * 0.5 - 1.0, p.y - 1.0, 2.0, 1.0), Color(col, a * 0.6))
		if k < 0.25 and float(r["w"]) >= 0.6:
			draw_rect(Rect2(p.x, p.y - 2.0 - k * 8.0, 1.0, 1.0), Color(col, a))      # la goccia che risale


## Le misure per le prove.
func counts() -> Dictionary:
	return {"superfici": _surf.size(), "cascate": _falls.size(), "increspature": _ripples.size()}
