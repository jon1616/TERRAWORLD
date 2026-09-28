class_name VitalsView
extends Control
## Vita, Linfa e Respiro sopra la barra rapida (29 set 2026, richiesta dell'utente: «ripensate, con fantasia, ma ben
## visibili; Vita e Linfa sempre, il Respiro solo quando serve, grande come le altre»).
## Al centro il **seme-cuore**, un seme che germoglia dentro un anello d'ambra: da lui crescono due **rami**, la Vita a
## sinistra e la Linfa a destra. I rami si riempiono dal seme verso fuori e finiscono a punta di foglia (Vita) e di goccia
## (Linfa); sopra la Vita dieci foglioline (ognuna un decimo: si seccano quando la Vita scende), sotto la Linfa dieci
## gocce. La Vita va dal verde muschio all'ambra e al rosso; ciò che si è appena perso resta chiaro un attimo e poi si
## svuota piano; sotto un quarto il ramo e il seme pulsano. Il **Respiro** (sott'acqua) compare sopra il seme, grande come
## un ramo, azzurro con le bolle che salgono, e sparisce quando si torna a respirare (`breath`, lo scrive `Liquids`).
## (Prima: un riquadro in alto a destra; il Respiro era una riga di pallini.)

const W := 720.0                        # larghezza di tutto (due rami e il seme)
const BAR_W := 300.0                    # un ramo
const BAR_H := 26.0
const SEED_R := 27.0
const ROW_GAP := 16.0                   # tra il Respiro e la riga di Vita e Linfa
const TRAIL_WAIT := 0.5                 # secondi prima che la parte persa cominci a svuotarsi
const TRAIL_SPEED := 0.6                # frazione della barra al secondo
const TOP := 12.0                       # (in alto a destra ora c'è solo la minimappa, da qui)
const BOTTOM := 0.0                     # (chi si metteva sotto le vecchie barre ora comincia da `TOP`)

var vitals: Vitals
var breath := 1.0                       # il respiro che resta (0-1); lo scrive `Liquids`
var breath_need := false
var breath_secs := 0.0                  # i secondi di respiro che restano                # sott'acqua o non ancora ripreso: la barra si vede
var _leaf_tex: Texture2D
var _drop_tex: Texture2D
var _font: Font
var _hp_trail := 1.0
var _linfa_trail := 1.0
var _hp_wait := 0.0
var _linfa_wait := 0.0
var _last_hp := -1
var _last_linfa := -1
var _t := 0.0
var _breath_a := 0.0                    # quanto si vede il Respiro (sfuma)


func setup(v: Vitals) -> void:
	vitals = v
	_leaf_tex = ArtLib.tex("interfaccia", "vita")        # voce 101: le icone disegnate, se ci sono
	_drop_tex = ArtLib.tex("interfaccia", "linfa")
	_font = ThemeDB.fallback_font
	var row_y := Hud.HOTBAR_Y - 32.0 - 10.0 - SEED_R * 2.0      # sopra il nome dell'oggetto in mano
	size = Vector2(W, SEED_R * 2.0 + ROW_GAP + BAR_H + 8.0)
	position = Vector2((1600.0 - W) * 0.5, row_y - ROW_GAP - BAR_H - 8.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	vitals.changed.connect(queue_redraw)
	queue_redraw()


## Il centro del seme e la riga di Vita e Linfa (coordinate del controllo).
func _center() -> Vector2:
	return Vector2(W * 0.5, size.y - SEED_R)


func _process(dt: float) -> void:
	if vitals == null:
		return
	_t += dt
	var hp := _frac(vitals.hp, vitals.hp_max)
	var li := _frac(vitals.linfa, vitals.linfa_max)
	if vitals.hp != _last_hp:
		if vitals.hp < _last_hp:
			_hp_wait = TRAIL_WAIT
		_last_hp = vitals.hp
	if vitals.linfa != _last_linfa:
		if vitals.linfa < _last_linfa:
			_linfa_wait = TRAIL_WAIT
		_last_linfa = vitals.linfa
	_hp_wait -= dt
	_linfa_wait -= dt
	if _hp_trail < hp:
		_hp_trail = hp
	elif _hp_trail > hp and _hp_wait <= 0.0:
		_hp_trail = maxf(hp, _hp_trail - TRAIL_SPEED * dt)
	if _linfa_trail < li:
		_linfa_trail = li
	elif _linfa_trail > li and _linfa_wait <= 0.0:
		_linfa_trail = maxf(li, _linfa_trail - TRAIL_SPEED * dt)
	_breath_a = move_toward(_breath_a, 1.0 if breath_need else 0.0, dt * 4.0)
	queue_redraw()                       # (bolle, battito, sfumature: poco da disegnare)


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
	var c := _center()
	var hp := _frac(vitals.hp, vitals.hp_max)
	var li := _frac(vitals.linfa, vitals.linfa_max)
	var low := hp < 0.25
	var beat := 0.5 + 0.5 * sin(_t * 7.0) if low else 0.0
	# i due rami
	var inner := SEED_R - 6.0
	var col := hp_color(hp)
	if low:
		col = col.lerp(Color(1.0, 0.85, 0.8), 0.35 * beat)
	_branch(c, -1.0, inner, hp, _hp_trail, col, Color(1.0, 0.92, 0.7), "leaf")
	_branch(c, 1.0, inner, li, _linfa_trail, Color("#34c8d0"), Color(0.8, 1.0, 1.0), "drop")
	# le tacche: foglioline sopra la Vita, gocce sotto la Linfa
	for i in 10:
		var on := hp * 10.0 > i + 0.05
		var x := c.x - inner - (i + 0.5) * BAR_W / 10.0
		_small_leaf(Vector2(x, c.y - BAR_H * 0.5 - 5.0), on, col)
		var on_l := li * 10.0 > i + 0.05
		var xl := c.x + inner + (i + 0.5) * BAR_W / 10.0
		_small_drop(Vector2(xl, c.y + BAR_H * 0.5 + 6.0), on_l)
	# i numeri
	_text(Vector2(c.x - inner - BAR_W * 0.5, c.y), "Vita  %d / %d" % [vitals.hp, vitals.hp_max], 17)
	_text(Vector2(c.x + inner + BAR_W * 0.5, c.y), "Linfa  %d / %d" % [vitals.linfa, vitals.linfa_max], 17)
	# il seme-cuore
	_seed(c, hp, col, beat)
	# il Respiro
	if _breath_a > 0.01:
		_breath_bar(Vector2(c.x, c.y - SEED_R - ROW_GAP - BAR_H * 0.5 + 4.0))


## Un ramo: dal seme verso fuori (dir -1 a sinistra, +1 a destra), che finisce a punta. Riempito dal seme in fuori.
func _branch(c: Vector2, dir: float, inner: float, f: float, trail: float, col: Color, trail_col: Color, tip: String) -> void:
	var x0 := c.x + dir * inner
	var h := BAR_H
	# la sagoma: il fondo scuro e il bordo
	var shape := _shape(x0, dir, c.y, h, 0.0, 1.0)
	draw_colored_polygon(shape, Color(0.02, 0.04, 0.05, 0.92))
	if trail > f:
		draw_colored_polygon(_shape(x0, dir, c.y, h, f, trail), trail_col * Color(1, 1, 1, 0.7))
	if f > 0.0:
		draw_colored_polygon(_shape(x0, dir, c.y, h, 0.0, f), col.darkened(0.3))
		draw_colored_polygon(_shape(x0, dir, c.y - h * 0.12, h * 0.55, 0.0, f), col)
		# un filo di luce che corre lungo il ramo
		var y_l := c.y - h * 0.28
		draw_line(Vector2(x0, y_l), Vector2(x0 + dir * BAR_W * f * 0.97, y_l), col.lightened(0.45), 2.0)
	var edge := shape.duplicate()
	edge.append(shape[0])
	draw_polyline(edge, Color("#0a1414"), 3.0)
	draw_polyline(edge, Color("#8ef0d8") * Color(1, 1, 1, 0.55), 1.2)
	# la punta: una foglia (Vita) o una goccia (Linfa) oltre la fine del ramo
	var end := Vector2(x0 + dir * (BAR_W + 12.0), c.y)
	if tip == "leaf":
		_big_leaf(end, dir, f > 0.99, col)
	else:
		_big_drop(end, f > 0.99)


## La sagoma di un ramo tra le frazioni a e b della sua lunghezza: alta h, si stringe negli ultimi 22 px (la punta).
func _shape(x0: float, dir: float, cy: float, h: float, a: float, b: float) -> PackedVector2Array:
	var top := PackedVector2Array()
	var bot := PackedVector2Array()
	var steps := 24
	for i in steps + 1:
		var u := lerpf(a, b, float(i) / steps)
		var x := x0 + dir * BAR_W * u
		var from_end := BAR_W * (1.0 - u)
		var half := h * 0.5 * (clampf(from_end / 22.0, 0.25, 1.0) if from_end < 22.0 else 1.0)
		top.append(Vector2(x, cy - half))
		bot.append(Vector2(x, cy + half))
	bot.reverse()
	top.append_array(bot)
	return top


## Il seme-cuore: anello d'ambra, il seme scuro con il germoglio del colore della Vita; batte quando la Vita è poca.
func _seed(c: Vector2, hp: float, col: Color, beat: float) -> void:
	var r := SEED_R * (1.0 + 0.06 * beat)
	draw_circle(c, r + 3.0, Color("#0a1414"))
	draw_circle(c, r, Color("#2a1a10"))
	draw_arc(c, r - 1.5, 0.0, TAU, 40, Color("#e0a040"), 3.0)
	# la Vita come un anello che si svuota dall'alto
	draw_arc(c, r - 6.0, -PI * 0.5, -PI * 0.5 + TAU * hp, 40, col, 4.0)
	# il seme
	var sp := PackedVector2Array()
	for i in 20:
		var a := TAU * i / 20.0
		sp.append(c + Vector2(cos(a) * 9.0, sin(a) * 11.0 + 4.0))
	draw_colored_polygon(sp, Color("#8a5a2a"))
	draw_colored_polygon(PackedVector2Array([c + Vector2(-3, 0), c + Vector2(3, 2), c + Vector2(-1, 12)]), Color("#b07a3a"))
	# il germoglio: due foglie che si aprono (più la Vita è alta, più sono aperte)
	var open := 0.35 + 0.65 * hp
	for s in [-1.0, 1.0]:
		var base := c + Vector2(0, -6)
		var tip := base + Vector2(s * 12.0 * open, -10.0 - 2.0 * open)
		var mid := base + Vector2(s * 9.0 * open, -2.0)
		draw_colored_polygon(PackedVector2Array([base, mid, tip, base + Vector2(s * 3.0, -9.0)]), col)
	draw_line(c + Vector2(0, -6), c + Vector2(0, -14), col.darkened(0.2), 2.0)
	if beat > 0.0:
		draw_circle(c, r + 6.0 * beat, Color(1.0, 0.3, 0.2, 0.18 * beat))


## Il Respiro: un ramo d'acqua sopra il seme, con le bolle; rosso quando sta per finire.
func _breath_bar(c: Vector2) -> void:
	var a := _breath_a
	var w := BAR_W
	var r := Rect2(c.x - w * 0.5, c.y - BAR_H * 0.5, w, BAR_H)
	var col := Color("#58a8ff") if breath > 0.3 else Color("#58a8ff").lerp(Color("#ff5a4a"), 0.5 + 0.5 * sin(_t * 9.0))
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.02, 0.04, 0.08, 0.92 * a)
	box.border_color = Color(0.55, 0.8, 1.0, 0.8 * a)
	box.set_border_width_all(2)
	box.set_corner_radius_all(13)
	draw_style_box(box, r)
	if breath > 0.0:
		var fb := StyleBoxFlat.new()
		fb.bg_color = col * Color(1, 1, 1, a)
		fb.set_corner_radius_all(11)
		draw_style_box(fb, Rect2(r.position + Vector2(3, 3), Vector2((w - 6.0) * breath, BAR_H - 6.0)))
	# le bolle che salgono dentro e sopra la barra
	for i in 7:
		var bx := r.position.x + 18.0 + fmod(i * 47.0 + _t * 9.0, w - 36.0)
		var by := r.position.y + BAR_H - fmod(_t * 22.0 + i * 11.0, BAR_H + 14.0)
		draw_arc(Vector2(bx, by), 2.0 + (i % 3), 0.0, TAU, 10, Color(0.85, 0.95, 1.0, 0.7 * a), 1.2)
	# l'icona: una bolla grande a sinistra
	var ic := Vector2(r.position.x - 16.0, c.y)
	draw_circle(ic, 11.0, Color(0.1, 0.2, 0.35, a))
	draw_arc(ic, 11.0, 0.0, TAU, 24, Color(0.75, 0.9, 1.0, a), 2.0)
	draw_circle(ic + Vector2(-3, -4), 2.5, Color(1, 1, 1, 0.8 * a))
	var secs := breath_secs
	var tt := "Respiro" if breath > 0.0 else "Respiro finito!"
	_text(r.get_center(), "%s  %d s" % [tt, ceili(secs)] if breath > 0.0 else tt, 17, a)


func _small_leaf(p: Vector2, on: bool, col: Color) -> void:
	var cc := col if on else Color("#4e3a26")
	draw_colored_polygon(PackedVector2Array([p + Vector2(0, 3), p + Vector2(-4, -1), p + Vector2(0, -5), p + Vector2(4, -1)]), cc)
	draw_line(p + Vector2(0, 3), p + Vector2(0, -4), cc.darkened(0.4), 1.0)


func _small_drop(p: Vector2, on: bool) -> void:
	var cc := Color("#5cc8cc") if on else Color("#1c3a40")
	draw_circle(p + Vector2(0, 1), 3.2, cc)
	draw_colored_polygon(PackedVector2Array([p + Vector2(-2.5, 0), p + Vector2(0, -5), p + Vector2(2.5, 0)]), cc)


func _big_leaf(p: Vector2, dir: float, full: bool, col: Color) -> void:
	if _leaf_tex != null:
		draw_texture_rect(_leaf_tex, Rect2(p - Vector2(12, 12), Vector2(24, 24)), false)
		return
	var cc := col if full else col.darkened(0.35)
	var back := p - Vector2(dir * 12.0, 0)
	var tip := p + Vector2(dir * 12.0, -4.0)
	draw_colored_polygon(PackedVector2Array([back, p + Vector2(0, -9), tip, p + Vector2(0, 7)]), cc)
	draw_line(back, tip, cc.darkened(0.45), 1.5)
	var edge := PackedVector2Array([back, p + Vector2(0, -9), tip, p + Vector2(0, 7), back])
	draw_polyline(edge, Color("#0a1414"), 1.5)


func _big_drop(p: Vector2, full: bool) -> void:
	if _drop_tex != null:
		draw_texture_rect(_drop_tex, Rect2(p - Vector2(12, 12), Vector2(24, 24)), false)
		return
	var cc := Color("#5cc8cc") if full else Color("#2a7a88")
	draw_circle(p + Vector2(0, 3), 8.0, cc)
	draw_colored_polygon(PackedVector2Array([p + Vector2(-7, 1), p + Vector2(0, -12), p + Vector2(7, 1)]), cc)
	draw_circle(p + Vector2(-3, 2), 2.0, Color(0.9, 1.0, 1.0, 0.8))


## Un testo centrato su `c`, con il contorno scuro.
func _text(c: Vector2, t: String, fs: int, a := 1.0) -> void:
	var tw := _font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var pos := Vector2(c.x - tw * 0.5, c.y + fs * 0.36)
	draw_string_outline(_font, pos, t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 5, Color(0.02, 0.04, 0.05, a))
	draw_string(_font, pos, t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.96, 1.0, 0.97, a))
