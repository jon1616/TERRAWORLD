class_name VitalsView
extends Control
## Vita e Linfa in alto a destra: 10 foglie (10 punti di Vita l'una) che appassiscono quando si è feriti, e 10 gocce
## turchesi di Linfa (2 punti l'una). Accanto il numero, piccolo.

const LEAF := 20                       # lato di una foglia sullo schermo (disegnata a 10 px e ingrandita ×2)
const GAP := 3

var vitals: Vitals
var _leaf_full: Texture2D
var _leaf_half: Texture2D
var _leaf_dry: Texture2D
var _drop_full: Texture2D
var _drop_empty: Texture2D
var _label: Label


func setup(v: Vitals) -> void:
	vitals = v
	_leaf_full = _tex(_leaf(Px.pal(["#0c3a30", "#1f7a5a", "#3aa08a", "#8ef0c0"]), 1.0))
	_leaf_half = _tex(_leaf(Px.pal(["#0c3a30", "#1f7a5a", "#3aa08a", "#8ef0c0"]), 0.5))
	_leaf_dry = _tex(_leaf(Px.pal(["#1c1410", "#3a2a1c", "#4e3a26", "#6a5236"]), 1.0))
	_drop_full = _tex(_drop(Px.pal(["#0a3a4a", "#1f8a9a", "#5cc8cc", "#dcffff"])))
	_drop_empty = _tex(_drop(Px.pal(["#0a1a20", "#12303a", "#1a3c46", "#24505a"])))
	var w := 12 * (LEAF + GAP)            # spazio anche per le foglie in più dei doni
	position = Vector2(1600 - w - 20, 14)
	size = Vector2(w, 2 * LEAF + 12)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label = Label.new()
	_label.position = Vector2(w - 10 * (LEAF + GAP) - 120, 0)
	_label.size = Vector2(112, 50)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color("#cfeee4"))
	_label.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_label.add_theme_constant_override("outline_size", 5)
	add_child(_label)
	vitals.changed.connect(queue_redraw)
	queue_redraw()


func _tex(im: Image) -> Texture2D:
	return ImageTexture.create_from_image(im)


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


func _draw() -> void:
	if vitals == null:
		return
	# le foglie si allineano a destra: con i doni ne compaiono di nuove a sinistra
	var leaves := ceili(vitals.hp_max / 10.0)
	var x0 := size.x - leaves * (LEAF + GAP)
	for i in leaves:
		var leaf_hp := vitals.hp - i * 10
		var t := _leaf_full if leaf_hp >= 10 else (_leaf_half if leaf_hp >= 5 else _leaf_dry)
		draw_texture_rect(t, Rect2(Vector2(x0 + i * (LEAF + GAP), 0), Vector2(LEAF, LEAF)), false)
	var d0 := size.x - 10 * (LEAF + GAP)
	for i in 10:
		var d := _drop_full if vitals.linfa - i * 2 >= 1 else _drop_empty
		draw_texture_rect(d, Rect2(Vector2(d0 + i * (LEAF + GAP) + 3, LEAF + 6), Vector2(LEAF - 6, LEAF - 6)), false)
	_label.text = "Vita %d\nLinfa %d" % [vitals.hp, vitals.linfa]
