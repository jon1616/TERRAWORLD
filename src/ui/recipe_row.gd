class_name RecipeRow
extends Button
## Una riga dell'elenco «Creare» (`CraftingPanel`): l'icona grande dell'oggetto, il nome con la quantità e, sotto, gli
## ingredienti con le loro icone e quanti ne servono. Si costruisce una volta sola (`setup`) e si riusa: a ogni cambio
## della Bisaccia `refresh` cambia solo i colori (attenuata se non si può fare, rossi gli ingredienti che mancano), e
## solo quelli cambiati. Il suggerimento (cosa serve e quanto se ne ha) si scrive quando il mouse ci passa sopra.
## Rifare tutte le righe da capo costava 106 ms con 171 ricette (26 set 2026): per questo non si ricreano mai.
## `style` e gli stili condivisi servono anche alle righe semplici del pannello (rinnovo del tratto, innesti).

const HEIGHT := 56
const AMBER := Color("#ffb84a")
const TEAL := Color("#2f7a70")
const TEXT := Color("#eafff6")
const TEXT_OFF := Color("#8aa6a2")
const HAVE := Color("#cfeee4")
const MISSING := Color("#ff7a6a")

static var _styles := {}               # "si/no:stato" -> StyleBoxFlat condiviso da tutte le righe

var r: Dictionary
var bag: Bisaccia
var can := true                        # disegnata come possibile: `refresh` la cambia se non lo è
var _name: Label
var _need: Array[Label] = []
var _enough: Array[int] = []           # per ingrediente: -1 = ancora da colorare, 0 = manca, 1 = basta


## Costruisce la riga della ricetta `recipe`, letta dalla Bisaccia `b`.
func setup(recipe: Dictionary, b: Bisaccia) -> void:
	r = recipe
	bag = b
	var out := String(r["out"])
	var n := int(r["qty"])
	custom_minimum_size = Vector2(0, HEIGHT)
	tooltip_text = " "                     # non vuoto: così il motore chiede il suggerimento a `_get_tooltip`
	style(self, true)
	add_child(_icon(out, Vector2(10, 10), 36))
	_name = Label.new()
	_name.text = "%s%s" % [ItemsData.get_item(out)["name"], (" ×%d" % n) if n > 1 else ""]
	_name.position = Vector2(54, 3)
	_name.add_theme_font_size_override("font_size", 16)
	_name.add_theme_color_override("font_color", TEXT)
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_name)
	var x := 54.0
	for k in r["in"]:
		var need := int(r["in"][k])
		add_child(_icon(String(k), Vector2(x, 30), 20))
		var cnt := Label.new()
		cnt.text = str(need)
		cnt.position = Vector2(x + 21, 30)
		cnt.add_theme_font_size_override("font_size", 13)
		cnt.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(cnt)
		_need.append(cnt)
		_enough.append(-1)
		x += 30.0 + 8.0 * str(need).length()


func _icon(id: String, at: Vector2, side: int) -> TextureRect:
	var ic := TextureRect.new()
	ic.texture = SlotView.icon(id)
	ic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.position = at
	ic.size = Vector2(side, side)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return ic


## I colori secondo la Bisaccia di adesso (`possible` = bastano i materiali e c'è posto per ciò che nasce).
func refresh(possible: bool) -> void:
	if possible != can:
		can = possible
		style(self, can)
		_name.add_theme_color_override("font_color", TEXT if can else TEXT_OFF)
	var i := 0
	for k in r["in"]:
		var enough := 1 if Crafting.have(bag, k) >= int(r["in"][k]) else 0   # anche dalle casse vicine
		if enough != _enough[i]:               # si ricolora solo ciò che è cambiato
			_enough[i] = enough
			_need[i].add_theme_color_override("font_color", HAVE if enough == 1 else MISSING)
		i += 1


## Il suggerimento solo quando serve (scriverlo per tutte le righe a ogni aggiornamento costava).
func _get_tooltip(_at: Vector2) -> String:
	return Crafting.describe(r, bag)


## Lo stile di una riga dell'elenco (anche di quelle semplici del pannello): chiara se si può fare, attenuata se no.
static func style(b: Button, possible: bool) -> void:
	b.add_theme_color_override("font_color", TEXT if possible else Color("#6f8a86"))
	b.add_theme_color_override("font_hover_color", AMBER if possible else Color("#8fa8a4"))
	b.modulate = Color(1, 1, 1, 1) if possible else Color(1, 1, 1, 0.62)
	for st in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(st, _style(possible, st))


## Gli stili delle righe sono solo otto: si fanno una volta e si condividono.
static func _style(possible: bool, st: String) -> StyleBoxFlat:
	var key := "%s:%s" % [possible, st]
	if not _styles.has(key):
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.04, 0.14, 0.16, 0.9) if st != "hover" else Color(0.08, 0.22, 0.24, 0.95)
		sb.border_color = AMBER if st == "hover" and possible else TEAL
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(14)
		sb.content_margin_left = 10
		_styles[key] = sb
	return _styles[key]
