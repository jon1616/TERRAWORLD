class_name WeatherCover
extends Node2D
## Roadmap 35, voce 337: il tempo che si posa sul mondo. Sopra i blocchi che vedono il cielo:
##   - la neve (bufera, gelicidio) che imbianca le cime e si scioglie piano quando smette; mai nelle terre calde
##   - il terreno lucido e più scuro dopo la pioggia, che si asciuga
##   - il velo grigio della cenere e della pioggia di brace
## Solo disegno, sotto la luce (di notte è buio come il resto): non cambia le tessere e non si salva.
## Quanto c'è di ognuno cresce e cala con il tempo (`RATES`); `snap` lo porta subito al suo valore (prove, ingresso).

const S := 16
## [secondi per arrivare al pieno, secondi per sparire]
const RATES := {"neve": [80.0, 150.0], "bagnato": [15.0, 100.0], "cenere": [60.0, 200.0]}
const SCAN := 0.5
const SNOW := [Color("#f4f8ff"), Color("#dce8f6"), Color("#b0c4dc")]
const ASH := Color("#8a8680")

var m: Node2D
var amount := {"neve": 0.0, "bagnato": 0.0, "cenere": 0.0}
var _tops := {}                        # colonna -> riga del primo blocco pieno dall'alto (solo nella visuale)
var _scan_t := 0.0
var _redraw_t := 0.0
var _cam := Vector2(-1e9, 0)


func setup(main: Node2D) -> void:
	m = main
	z_as_relative = false
	z_index = 2


## Dove va ognuno adesso (0-1), dal tempo che fa.
func goals() -> Dictionary:
	var g := {"neve": 0.0, "bagnato": 0.0, "cenere": 0.0}
	if m.weather == null or m.weather.roofed:
		return g
	var st: Dictionary = m.weather.state()
	g["neve"] = clampf(float(st.get("snow", 0.0)), 0.0, 1.0)
	g["bagnato"] = clampf(float(st.get("rain", 0.0)), 0.0, 1.0)
	g["cenere"] = clampf(float(st.get("ash", 0.0)), 0.0, 1.0)
	return g


func snap() -> void:
	var g := goals()
	for k in amount:
		# chi c'è già resta (dopo la pioggia si è bagnati): si sale subito al valore del tempo che fa
		amount[k] = maxf(float(amount[k]), float(g[k]))
	_scan_t = 0.0
	_redraw_t = 0.0


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	var g := goals()
	var any := false
	for k in amount:
		var r: Array = RATES[k]
		var goal := float(g[k])
		var a := float(amount[k])
		a = move_toward(a, goal, dt / float(r[0] if goal > a else r[1]))
		amount[k] = a
		any = any or a > 0.01
	visible = any
	if not any:
		return
	_scan_t -= dt
	if _scan_t <= 0.0:
		_scan_t = SCAN
		_scan()
	_redraw_t -= dt
	var cam: Vector2 = m.cam.get_screen_center_position()
	if _redraw_t <= 0.0 or cam.distance_to(_cam) > 8.0:
		_redraw_t = 0.25
		_cam = cam
		queue_redraw()


## La riga del primo blocco pieno di ogni colonna della visuale (le cime che vedono il cielo).
func _scan() -> void:
	_tops.clear()
	var w: World = m.world
	var view: Vector2 = m.get_viewport_rect().size / m.cam.zoom
	var ctr: Vector2 = m.cam.get_screen_center_position()
	var x0 := maxi(floori((ctr.x - view.x * 0.5) / S) - 2, 0)
	var x1 := mini(floori((ctr.x + view.x * 0.5) / S) + 2, w.w - 1)
	var ybot := mini(floori((ctr.y + view.y * 0.5) / S) + 2, w.h - 1)
	# (9 ott 2026) gli array letti direttamente: con il cielo alto 1200 righe le chiamate per cella costavano ~9 ms
	var tiles := w.tiles
	var liq := w.liquid
	var ww := w.w
	var ytop := floori((ctr.y - view.y * 0.5) / S) - 2
	for x in range(x0, x1 + 1):
		var y := 0
		var i := x
		while y <= ybot and tiles[i] == TileDefs.AIR and (liq[i] & 15) == 0:
			y += 1
			i += ww
		if y <= ybot and tiles[i] != TileDefs.AIR and y >= ytop:
			_tops[x] = y


func _draw() -> void:
	var w: World = m.world
	var snow := float(amount["neve"])
	var wet := float(amount["bagnato"])
	var ash := float(amount["cenere"])
	for x in _tops:
		var y: int = _tops[x]
		var px := float(x * S)
		var py := float(y * S)
		var b: Dictionary = BiomesData.BIOMES[w.biomes[x]]
		var hot := String(b.get("harsh", {}).get("kind", "")) == "calore"
		if wet > 0.01:
			# più scuro e lucido: un velo scuro, poi un filo di luce a tratti che corre lento
			draw_rect(Rect2(px, py, S, 6.0), Color(0, 0.02, 0.05, 0.28 * wet))
			for i in 7:
				var hx := posmod(x * 7 + i * 5 + int(Time.get_ticks_msec() / 400) % 16, 16)
				if (x * 13 + i * 7) % 4 != 0:
					draw_rect(Rect2(px + hx, py + float(i % 2), 2.0 if i % 3 else 3.0, 1.0), Color(0.9, 0.97, 1.0, 0.75 * wet))
		if ash > 0.01:
			for i in 10:
				var ax := posmod(x * 31 + i * 7, 16)
				var ay := posmod(x * 17 + i * 3, 3)
				if float(posmod(x * 11 + i * 13, 10)) < ash * 10.0:
					draw_rect(Rect2(px + ax, py + ay, 1.0, 1.0), Color(ASH, 0.85))
		if snow > 0.01 and not hot:
			# il manto: alto fino a 4 pixel, il bordo di sotto irregolare, l'ultima riga in ombra
			var depth := snow * 4.0
			for i in 16:
				var h := floorf(depth + float(posmod(x * 37 + i * 11, 7)) / 6.0 - 0.5)
				if h <= 0.0:
					continue
				draw_rect(Rect2(px + i, py - 1.0, 1.0, h), SNOW[0] if (i + x) % 5 != 0 else SNOW[1])
				draw_rect(Rect2(px + i, py - 1.0 + h, 1.0, 1.0), Color(SNOW[2], 0.8))
			# i bordi delle cime che scendono: un ciuffo di neve che pende
			if not _tops.has(x - 1) or int(_tops.get(x - 1, y)) > y:
				draw_rect(Rect2(px - 1.0, py, 2.0, 2.0 + depth * 0.5), SNOW[1])
			if not _tops.has(x + 1) or int(_tops.get(x + 1, y)) > y:
				draw_rect(Rect2(px + S - 1.0, py, 2.0, 2.0 + depth * 0.5), SNOW[1])


## Le misure per le prove.
func counts() -> Dictionary:
	return {"neve": amount["neve"], "bagnato": amount["bagnato"], "cenere": amount["cenere"], "cime": _tops.size()}
