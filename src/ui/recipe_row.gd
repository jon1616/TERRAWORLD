class_name RecipeRow
extends Button
## Una riga dell'elenco «Creare» (`CraftingPanel`), colorata secondo il tipo di ciò che nasce (`CraftCatsData`):
## una striscia del colore a sinistra, l'icona grande in un riquadro tinto, il nome (con la quantità) e il banco dove si
## fa; sotto, gli ingredienti con l'icona e «quanti ne hai / quanti ne servono» (verde se bastano, rosso se no; si
## contano anche le casse vicine). Il suggerimento (cosa serve, quanto se ne ha, a cosa serve) si scrive quando il mouse
## ci passa sopra.
## La riga è **un nodo solo** che si disegna da sé (`_draw`): composta da una decina di nodi (etichette, icone,
## riquadri), la prima apertura dell'elenco con 260 ricette costava 90 ms solo per impaginarli. Si costruisce una volta
## e si riusa: `refresh` cambia i numeri e ridisegna. Rifare tutte le righe da capo costava 106 ms (26 set 2026).
## `style` e gli stili condivisi servono anche alle righe semplici del pannello (lavorazioni del Maglio e del Telaio).

const HEIGHT := 60
const AMBER := Color("#ffb84a")
const TEAL := Color("#2f7a70")
const TEXT := Color("#f2fff9")
const TEXT_OFF := Color("#8aa6a2")
const HAVE := Color("#9ff0b8")
const MISSING := Color("#ff7a6a")
const OUTLINE := Color(0.02, 0.04, 0.05)

static var _styles := {}               # "colore:si/no:stato" -> StyleBoxFlat condiviso
static var _font: Font

var r: Dictionary
var bag: Bisaccia
var can := false                       # disegnata come possibile? (parte «no», come quasi tutte alla prima apertura)
var color := TEAL                      # il colore della sua categoria
var _out_tex: Texture2D
var _title := ""
var _where := ""
var _ings: Array = []                  # [texture, quanti ne servono, quanti ne hai]


## Prepara la riga della ricetta `recipe`, letta dalla Bisaccia `b`.
func setup(recipe: Dictionary, b: Bisaccia) -> void:
	r = recipe
	bag = b
	if _font == null:
		_font = ThemeDB.fallback_font
	var out := String(r["out"])
	var n := int(r["qty"])
	color = CraftCatsData.color_of(out)
	custom_minimum_size = Vector2(0, HEIGHT)
	tooltip_text = " "                     # non vuoto: così il motore chiede il suggerimento a `_get_tooltip`
	focus_mode = Control.FOCUS_NONE
	style(self, true, color)
	modulate = Color(1, 1, 1, 0.55)
	_out_tex = SlotView.icon(out)
	_title = "%s%s" % [ItemsData.get_item(out)["name"], ("  ×%d" % n) if n > 1 else ""]
	_where = CraftCatsData.short_station(String(r["station"]))
	for k in r["in"]:
		_ings.append([SlotView.icon(String(k)), int(r["in"][k]), 0])


## I numeri secondo la Bisaccia di adesso (`possible` = bastano i materiali e c'è posto per ciò che nasce).
## `have_n` = i conteggi del pannello (Bisaccia e casse vicine), fatti una volta per tutte le righe.
func refresh(possible: bool, have_n := {}) -> void:
	var changed := possible != can
	if changed:
		can = possible
		modulate = Color(1, 1, 1, 1) if can else Color(1, 1, 1, 0.55)
	var i := 0
	for k in r["in"]:
		var have := int(have_n.get(k, 0)) if not have_n.is_empty() else Crafting.have(bag, k)
		if have != int(_ings[i][2]):
			_ings[i][2] = have
			changed = true
		i += 1
	if changed:
		queue_redraw()


func _draw() -> void:
	var h := size.y
	# la striscia del colore e il riquadro dell'icona
	draw_rect(Rect2(0, 6, 4, h - 12), color)
	draw_style_box(_icon_box(color), Rect2(12, 8, 44, 44))
	draw_texture_rect(_out_tex, Rect2(16, 12, 36, 36), false)
	# il nome e il banco
	var name_w := size.x - 66.0 - 96.0
	_text(Vector2(66, 22), _title, 16, TEXT if can else TEXT_OFF, name_w)
	var ww := _font.get_string_size(_where, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
	_text(Vector2(size.x - 12.0 - ww, 20), _where, 11, color.lerp(Color("#9fc8c0"), 0.5), 96.0)
	# gli ingredienti: icona e «ne hai/ne servono»
	var x := 66.0
	for e in _ings:
		draw_texture_rect(e[0], Rect2(x, 33, 18, 18), false)
		var have := int(e[2])
		_text(Vector2(x + 21, 47), "%s/%d" % [str(have) if have < 1000 else "999+", int(e[1])], 12,
			HAVE if have >= int(e[1]) else MISSING, 44.0)
		x += 64.0


func _text(at: Vector2, t: String, fs: int, col: Color, max_w: float) -> void:
	draw_string_outline(_font, at, t, HORIZONTAL_ALIGNMENT_LEFT, max_w, fs, 3, OUTLINE)
	draw_string(_font, at, t, HORIZONTAL_ALIGNMENT_LEFT, max_w, fs, col)


## Il suggerimento solo quando serve (scriverlo per tutte le righe a ogni aggiornamento costava).
func _get_tooltip(_at: Vector2) -> String:
	return Crafting.describe(r, bag) + "\n(clic: crea · Maiusc+clic: crea 5)"


## Lo stile di una riga dell'elenco (anche di quelle semplici del pannello): chiara se si può fare, attenuata se no.
static func style(b: Button, possible: bool, col := TEAL) -> void:
	b.add_theme_color_override("font_color", TEXT if possible else Color("#6f8a86"))
	b.add_theme_color_override("font_hover_color", AMBER if possible else Color("#8fa8a4"))
	b.modulate = Color(1, 1, 1, 1) if possible else Color(1, 1, 1, 0.55)
	for st in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(st, _style(possible, st, col))


## Gli stili delle righe: pochi per colore, si fanno una volta e si condividono.
static func _style(possible: bool, st: String, col: Color) -> StyleBoxFlat:
	var key := "%s:%s:%s" % [col.to_html(false), possible, st]
	if not _styles.has(key):
		var sb := StyleBoxFlat.new()
		var base := Color(0.03, 0.09, 0.1, 0.92).lerp(col, 0.07)
		sb.bg_color = base if st != "hover" else base.lerp(col, 0.14)
		sb.border_color = col if st == "hover" and possible else Color(col, 0.35)
		sb.set_border_width_all(1)
		sb.border_width_left = 0
		sb.set_corner_radius_all(10)
		sb.content_margin_left = 12
		_styles[key] = sb
	return _styles[key]


static func _icon_box(col: Color) -> StyleBoxFlat:
	var key := "box:" + col.to_html(false)
	if not _styles.has(key):
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.02, 0.05, 0.06).lerp(col, 0.22)
		sb.border_color = Color(col, 0.7)
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(8)
		_styles[key] = sb
	return _styles[key]
