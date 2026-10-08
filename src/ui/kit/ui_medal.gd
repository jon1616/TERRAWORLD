class_name UiMedal
extends Control
## Il medaglione di una meccanica o di una cosa (Roadmap 55): un cerchio d'inchiostro con l'anello del suo colore e un
## alone, l'icona al centro. Un'icona a pixel piccola si ingrandisce di numeri interi (quadretti netti); una dipinta si
## adatta morbida.

var icon: Texture2D:
	set(v):
		icon = v
		# un disegno a pixel piccolo a quadretti netti, uno dipinto morbido
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if v != null and v.get_width() <= 24 			else CanvasItem.TEXTURE_FILTER_LINEAR
		queue_redraw()
var ring := UiPalette.AMBRA
var glow := true


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.5 - 3.0
	if glow:
		for k in 6:
			draw_circle(c, r + 2.0 + k * 1.5, Color(ring, 0.05 - k * 0.007), true, -1.0, true)
	draw_circle(c, r, Color("#0b1415"), true, -1.0, true)
	draw_circle(c, r - 1.0, Color(ring, 0.10), true, -1.0, true)
	draw_circle(c, r, Color(ring, 0.85), false, 1.6, true)
	draw_circle(c, r - 4.0, Color(ring, 0.25), false, 1.0, true)
	if icon == null:
		return
	var tw := float(icon.get_width())
	var th := float(icon.get_height())
	var room := r * 1.25
	var k := room / maxf(tw, th)
	if tw <= 24.0:
		k = maxf(floorf(k), 1.0)                 # un disegno a pixel: ingrandito di numeri interi
	var s := Vector2(tw, th) * k
	draw_texture_rect(icon, Rect2((c - s * 0.5).round(), s), false)
