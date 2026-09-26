class_name SlotView
extends Panel
## Una casella di oggetto nello stile «Radici e Linfa»: icona, quantità, bordo turchese (ambra se scelta).
## Usata dalla barra rapida e dalla Bisaccia.

signal clicked(index: int, button: int)

const SIZE := 56
const AMBER := Color("#ffb84a")
const TEAL := Color("#2f7a70")

static var _icons := {}
## Per le schede degli oggetti: () -> {"bag", "hand", "price"?} della partita in corso (lo imposta `TipsHook`).
static var context := Callable()

var index := 0
var _icon: TextureRect
var _count: Label
var _selected := false
var slot_data := {}                    # l'oggetto intero della casella: {"id", "n", "tratto", "dati"}
var tip_extra := {}                    # per questa casella: {"price": "buy", "cost": N} o {"equipped": true}


static func icon(id: String) -> Texture2D:
	if not _icons.has(id):
		_icons[id] = ImageTexture.create_from_image(ItemIcons.of(id))
	return _icons[id]


func _init() -> void:
	custom_minimum_size = Vector2(SIZE, SIZE)
	size = Vector2(SIZE, SIZE)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_icon = TextureRect.new()
	_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.position = Vector2(4, 4)
	_icon.size = Vector2(48, 48)
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_icon)
	_count = Label.new()
	_count.position = Vector2(4, SIZE - 22)
	_count.size = Vector2(SIZE - 8, 20)
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_count.add_theme_font_size_override("font_size", 14)
	_count.add_theme_color_override("font_color", Color("#eafff6"))
	_count.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_count.add_theme_constant_override("outline_size", 5)
	_count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_count)
	_restyle()
	Tips.attach(self, _tip)


## La scheda dell'oggetto nella casella (26 set 2026: suggerimenti ricchi, ricette e provenienza in Esamina).
func _tip() -> Variant:
	if slot_data.is_empty():
		return null
	var ctx: Dictionary = (context.call() as Dictionary).duplicate() if context.is_valid() else {}
	ctx.merge(tip_extra, true)
	return ItemTip.card(slot_data, ctx)


func set_item(id: String, n: int, tratto := "", dati := {}) -> void:
	_icon.texture = icon(id) if id != "" else null
	_count.text = str(n) if n > 1 else ""
	slot_data = {"id": id, "n": n, "tratto": tratto, "dati": dati} if id != "" else {}
	# un filo dorato sotto l'icona se c'è un tratto
	_count.add_theme_color_override("font_color", Color("#ffd08a") if tratto != "" else Color.WHITE)
	if tratto != "" and n <= 1:
		_count.text = "✦"


func set_selected(on: bool) -> void:
	if on != _selected:
		_selected = on
		_restyle()


func _restyle() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.2, 0.22, 0.92) if _selected else Color(0.03, 0.09, 0.11, 0.8)
	sb.set_border_width_all(3 if _selected else 2)
	sb.border_color = AMBER if _selected else TEAL
	sb.set_corner_radius_all(18)
	if _selected:
		sb.shadow_color = Color(1.0, 0.72, 0.3, 0.35)
		sb.shadow_size = 8
	add_theme_stylebox_override("panel", sb)


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed:
		clicked.emit(index, e.button_index)
		accept_event()
