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
	Tips.attach(self, _tip)                # la scheda di ciò che nasce, con gli ingredienti (26 set 2026)
	focus_mode = Control.FOCUS_NONE
	style(self, true, color)
	modulate = Color(1, 1, 1, 0.55)
	_out_tex = SlotView.icon(out)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR    # le icone da 48 disegnate più piccole (8 ott 2026)
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


## La scheda della ricetta, solo quando il mouse ci passa sopra: l'oggetto che nasce (come in una casella), poi gli
## ingredienti con quanti ne hai (anche nelle casse vicine), il banco e i comandi.
func _tip() -> Variant:
	var ctx: Dictionary = (SlotView.context.call() as Dictionary).duplicate() if SlotView.context.is_valid() else {}
	var c := ItemTip.card({"id": String(r["out"]), "n": int(r.get("qty", 1))}, ctx)
	if c == null:
		return null
	if not c.blocks.is_empty() and String(c.blocks[-1]["t"]) == "hint":
		c.blocks.pop_back()
	c.sep()
	var rows := []
	for k in r["in"]:
		var need := int(r["in"][k])
		var have := Crafting.have(bag, String(k))
		var there := Crafting.in_pool(String(k))
		rows.append([String(ItemsData.get_item(String(k)).get("name", k)), "%d / %d%s" % [mini(have, need), need,
			("  (%d nelle casse)" % there) if there > 0 else ""], TipCard.GOOD if have >= need else TipCard.BAD])
	c.line("Serve", TipCard.GOLD)
	c.stats(rows)
	var st := String(r.get("station", ""))
	c.line("Banco: %s" % (String(StationsData.STATIONS[st]["name"]) if StationsData.STATIONS.has(st) else "a mano, ovunque"),
		TipCard.SOFT)
	c.hint("Clic: crea · Maiusc+clic: crea 5")
	return c


## Lo stile di una riga dell'elenco (anche di quelle semplici del pannello): chiara se si può fare, attenuata se no.
static func style(b: Button, possible: bool, col := TEAL) -> void:
	b.add_theme_color_override("font_color", TEXT if possible else Color("#6f8a86"))
	b.add_theme_color_override("font_hover_color", AMBER if possible else Color("#8fa8a4"))
	b.modulate = Color(1, 1, 1, 1) if possible else Color(1, 1, 1, 0.55)
	UiFrames.button(b, Color(0, 0, 0, 0) if col == UiPalette.BORDO else col)
	b.add_theme_color_override("font_pressed_color", AMBER if possible else Color("#8fa8a4"))


static func _icon_box(col: Color) -> StyleBox:
	return UiFrames.box("casella", "normale", col)
