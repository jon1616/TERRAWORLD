class_name HudScrim
extends CanvasGroup
## (9 ott 2026, l'utente: «senza un fondo scuro, quando lo sfondo ha il colore delle scritte fatico a leggerle») Il fondo
## scuro e sfumato dietro le scritte dell'HUD sul mondo (orologio, obiettivi, riga dell'Albero-Madre, il filo, le righe
## degli eventi…): ogni scritta che lo vuole entra nel gruppo `GROUP`; i fondi vicini si fondono. Si misura
## il testo vero, non la casella (il filo è largo 760 ma il testo occupa la metà), e si ridisegna a ogni fotogramma.

const GROUP := "hud_fondo"
const PAD := Vector2(12, 5)              # quanto il fondo sborda dal testo
const ALPHA := 0.94                      # quanto è scuro (con hdr_2d la fusione è lineare: 0,5 scuriva appena)
const FEATHER := 18                      # la sfumatura del bordo (l'ombra del riquadro, dello stesso colore)

var _box: StyleBoxFlat
var _pad: Control


func _ready() -> void:
	# il gruppo disegna i suoi riquadri pieni in un'immagine a parte e la posa con ALPHA: i fondi delle scritte vicine
	# si fondono in una macchia sola, senza il rettangolone che copriva anche lo spazio vuoto fra le scritte
	self_modulate = Color(1, 1, 1, ALPHA)
	_box = StyleBoxFlat.new()
	_box.bg_color = Color(0.035, 0.03, 0.05)
	_box.set_corner_radius_all(10)
	_box.shadow_color = Color(0.035, 0.03, 0.05)
	_box.shadow_size = FEATHER
	_box.anti_aliasing = true
	_pad = Control.new()
	_pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pad.size = Vector2(1600, 900)
	_pad.draw.connect(func() -> void:
		for r in rects():
			_pad.draw_style_box(_box, r))
	add_child(_pad)


func _process(_dt: float) -> void:
	_pad.queue_redraw()


## I riquadri da disegnare: il testo di ogni scritta del gruppo, allargato.
func rects() -> Array[Rect2]:
	var out: Array[Rect2] = []
	for n in get_tree().get_nodes_in_group(GROUP):
		var c := n as Control
		if c == null or not c.is_visible_in_tree() or c.modulate.a < 0.05:
			continue
		var r := text_rect(c)
		if r.size.x < 1.0 or r.size.y < 1.0:
			continue
		out.append(r.grow_individual(PAD.x, PAD.y, PAD.x, PAD.y))
	return out


## Il rettangolo occupato dal testo di una scritta (Label o RichTextLabel), in coordinate dell'HUD.
static func text_rect(c: Control) -> Rect2:
	var p := c.global_position
	if c is RichTextLabel:
		var rl := c as RichTextLabel
		if rl.get_parsed_text().strip_edges() == "":
			return Rect2()
		var w := float(rl.get_content_width())
		var h := float(rl.get_content_height())
		var x := p.x
		if rl.text.begins_with("[center]"):
			x += (rl.size.x - w) * 0.5
		return Rect2(x, p.y, w, h)
	if c is Label:
		var l := c as Label
		var t := l.text.strip_edges()
		if t == "":
			return Rect2()
		var font := l.get_theme_font("font")
		var fs := l.get_theme_font_size("font_size")
		var w := 0.0
		for line in t.split("\n"):
			w = maxf(w, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
		if l.autowrap_mode != TextServer.AUTOWRAP_OFF:
			w = minf(w, l.size.x)
		var x := p.x
		if l.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER:
			x += (l.size.x - w) * 0.5
		elif l.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
			x += l.size.x - w
		var h := float(l.get_line_count()) * float(l.get_line_height()) if l.autowrap_mode != TextServer.AUTOWRAP_OFF \
			else l.get_minimum_size().y
		return Rect2(x, p.y, w, h)
	return Rect2()
