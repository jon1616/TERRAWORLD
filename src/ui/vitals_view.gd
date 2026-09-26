class_name VitalsView
extends Control
## Vita e Linfa in alto a destra, su un riquadro scuro che si legge sopra il cielo e dentro le grotte: due barre
## grandi con il numero dentro, una foglia e una goccia accanto. La Vita va dal verde muschio all'ambra e al rosso man
## mano che cala; quello che si è appena perso resta chiaro per un attimo e poi si svuota piano (si vede quanto ha fatto
## male un colpo); sotto un quarto della Vita la barra pulsa. La Linfa è turchese.
## (Prima c'erano 10 foglie e 10 gocce piccole con il numero accanto: si vedevano poco e la minimappa le copriva.
## La minimappa ora comincia sotto `BOTTOM`.)

const W := 360.0                       # larghezza del riquadro
const TOP := 12.0
const BAR := Vector2(300, 24)          # barra della Vita (quella della Linfa è più bassa)
const LINFA_H := 18.0
const PAD := 10.0
const ICON := 22.0
const BOTTOM := TOP + PAD * 2.0 + 24.0 + 8.0 + LINFA_H   # dove finisce il riquadro (la minimappa va sotto)
const TRAIL_WAIT := 0.5                # secondi prima che la parte persa cominci a svuotarsi
const TRAIL_SPEED := 0.6               # frazione della barra al secondo

var vitals: Vitals
var _leaf_tex: Texture2D
var _drop_tex: Texture2D
var _font: Font
var _hp_trail := 1.0                   # frazione mostrata come «appena persa»
var _linfa_trail := 1.0
var _hp_wait := 0.0
var _linfa_wait := 0.0
var _last_hp := -1
var _last_linfa := -1
var _pulse := 0.0


func setup(v: Vitals) -> void:
	vitals = v
	_leaf_tex = ImageTexture.create_from_image(_leaf(Px.pal(["#0c3a30", "#1f7a5a", "#3aa08a", "#8ef0c0"]), 1.0))
	_drop_tex = ImageTexture.create_from_image(_drop(Px.pal(["#0a3a4a", "#1f8a9a", "#5cc8cc", "#dcffff"])))
	_font = ThemeDB.fallback_font
	position = Vector2(1600.0 - W - 16.0, TOP)
	size = Vector2(W, BOTTOM - TOP)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	vitals.changed.connect(queue_redraw)
	queue_redraw()


func _process(dt: float) -> void:
	if vitals == null:
		return
	var hp := _frac(vitals.hp, vitals.hp_max)
	var li := _frac(vitals.linfa, vitals.linfa_max)
	# la parte persa: resta ferma un attimo, poi scende fino al valore vero (se si guarisce, segue subito)
	if vitals.hp != _last_hp:
		if vitals.hp < _last_hp:
			_hp_wait = TRAIL_WAIT
		_last_hp = vitals.hp
	if vitals.linfa != _last_linfa:
		if vitals.linfa < _last_linfa:
			_linfa_wait = TRAIL_WAIT
		_last_linfa = vitals.linfa
	var redraw := false
	_hp_wait -= dt
	_linfa_wait -= dt
	if _hp_trail < hp:
		_hp_trail = hp
	elif _hp_trail > hp and _hp_wait <= 0.0:
		_hp_trail = maxf(hp, _hp_trail - TRAIL_SPEED * dt)
		redraw = true
	if _linfa_trail < li:
		_linfa_trail = li
	elif _linfa_trail > li and _linfa_wait <= 0.0:
		_linfa_trail = maxf(li, _linfa_trail - TRAIL_SPEED * dt)
		redraw = true
	if hp < 0.25:
		_pulse += dt
		redraw = true
	elif _pulse != 0.0:
		_pulse = 0.0
		redraw = true
	if redraw:
		queue_redraw()


static func _frac(v: int, mx: int) -> float:
	return clampf(float(v) / float(maxi(mx, 1)), 0.0, 1.0)


## Il colore della Vita: muschio quando è piena, ambra a metà, rosso quando è poca.
static func hp_color(f: float) -> Color:
	if f > 0.5:
		return Color("#e0b040").lerp(Color("#3fc88a"), (f - 0.5) * 2.0)
	return Color("#d83a2c").lerp(Color("#e0b040"), f * 2.0)


func _draw() -> void:
	if vitals == null:
		return
	# il riquadro
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.02, 0.05, 0.06, 0.82)
	box.border_color = Color("#2f7a70")
	box.set_border_width_all(2)
	box.set_corner_radius_all(10)
	draw_style_box(box, Rect2(Vector2.ZERO, size))
	var x0 := PAD + ICON + 8.0
	var bw := size.x - x0 - PAD
	# la Vita
	var hp := _frac(vitals.hp, vitals.hp_max)
	var y := PAD
	draw_texture_rect(_leaf_tex, Rect2(Vector2(PAD, y + (BAR.y - ICON) * 0.5), Vector2(ICON, ICON)), false)
	var col := hp_color(hp)
	if hp < 0.25:
		col = col.lerp(Color(1.0, 0.85, 0.8), 0.35 * (0.5 + 0.5 * sin(_pulse * 7.0)))
	_bar(Rect2(x0, y, bw, BAR.y), hp, _hp_trail, col, Color(1.0, 0.92, 0.7))
	_text(Rect2(x0, y, bw, BAR.y), "Vita  %d / %d" % [vitals.hp, vitals.hp_max], 16)
	# la Linfa
	var li := _frac(vitals.linfa, vitals.linfa_max)
	y += BAR.y + 8.0
	draw_texture_rect(_drop_tex, Rect2(Vector2(PAD + 2.0, y + (LINFA_H - ICON + 4.0) * 0.5), Vector2(ICON - 4.0, ICON - 4.0)), false)
	_bar(Rect2(x0, y, bw, LINFA_H), li, _linfa_trail, Color("#34c8d0"), Color(0.8, 1.0, 1.0))
	_text(Rect2(x0, y, bw, LINFA_H), "Linfa  %d / %d" % [vitals.linfa, vitals.linfa_max], 14)


## Una barra: fondo scuro, la parte appena persa chiara, il pieno con un filo di luce in cima, il bordo.
func _bar(r: Rect2, f: float, trail: float, col: Color, trail_col: Color) -> void:
	draw_rect(r, Color(0.01, 0.02, 0.03, 0.95))
	if trail > f:
		draw_rect(Rect2(r.position, Vector2(r.size.x * trail, r.size.y)), trail_col * Color(1, 1, 1, 0.75))
	if f > 0.0:
		var fr := Rect2(r.position, Vector2(r.size.x * f, r.size.y))
		draw_rect(fr, col.darkened(0.25))
		draw_rect(Rect2(fr.position, Vector2(fr.size.x, r.size.y * 0.55)), col)
		draw_rect(Rect2(fr.position + Vector2(0, 2), Vector2(fr.size.x, 2)), col.lightened(0.35))
	# tacche ogni decimo: si contano i colpi a occhio
	for i in range(1, 10):
		var tx := r.position.x + r.size.x * i / 10.0
		draw_line(Vector2(tx, r.position.y + r.size.y - 5.0), Vector2(tx, r.position.y + r.size.y), Color(0, 0, 0, 0.45), 1.0)
	draw_rect(r, Color("#8ef0d8") * Color(1, 1, 1, 0.55), false, 1.5)


## Il numero dentro la barra, con il contorno scuro (si legge su ogni colore).
func _text(r: Rect2, t: String, fs: int) -> void:
	var tw := _font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var pos := Vector2(r.position.x + (r.size.x - tw) * 0.5, r.position.y + r.size.y * 0.5 + fs * 0.36)
	draw_string_outline(_font, pos, t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Color(0.02, 0.04, 0.05))
	draw_string(_font, pos, t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("#f4fff8"))


## Foglia a punta, inclinata, con la nervatura; `fill` = quanta parte è viva (la punta secca per prima).
static func _leaf(p: Array[Color], fill: float) -> Image:
	var im := Px.img(10, 10)
	var dry := Px.pal(["#1c1410", "#3a2a1c", "#4e3a26", "#6a5236"])
	for y in 10:
		for x in 10:
			# coordinate ruotate di 45°: a lungo la foglia (da -1 alla base a +1 in punta), b di traverso
			var dx := x + 0.5 - 5.0
			var dy := y + 0.5 - 5.0
			var a := (dx - dy) / (sqrt(2.0) * 4.6)
			var b := (dx + dy) / (sqrt(2.0) * 4.6)
			var half := 0.62 * sqrt(maxf(1.0 - a * a, 0.0)) * (1.0 - maxf(a, 0.0) * 0.35)
			if absf(b) <= half and absf(a) <= 1.0:
				var alive := (a + 1.0) * 0.5 <= fill
				var pal: Array[Color] = p if alive else dry
				var c := pal[2] if b < 0.0 else pal[1]
				if absf(b) < 0.1:
					c = pal[3]
				Px.put(im, x, y, c)
	Px.outline(im, Color("#050c10"))
	return im


static func _drop(p: Array[Color]) -> Image:
	var im := Px.img(10, 10)
	for y in 10:
		for x in 10:
			var d := Vector2((x + 0.5 - 5.0) / 3.6, (y + 0.5 - 6.2) / 3.4)
			var tip := y < 4 and absf(x + 0.5 - 5.0) <= (y + 0.5) * 0.45
			if d.length() <= 1.0 or tip:
				Px.put(im, x, y, p[2] if d.x > -0.2 else p[1])
	Px.put(im, 4, 5, p[3])
	Px.outline(im, Color("#050c10"))
	return im
