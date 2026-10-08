class_name CharacterCard
extends Control
## La scheda del Germogliato, in basso a sinistra della Bisaccia aperta (28 set 2026: prima compariva nella casella
## Esamina vuota; con Esamina riprogettata ha il suo posto fisso). Vita, Linfa, Scorza, effetti dell'equipaggiamento,
## set, firma, reliquie, doni: il testo lo fa `CharacterSheet` (lo passa `main` in `ExaminePanel.sheet`).

var sheet: Callable
var text: RichTextLabel
var _dirty := true


func setup(rect: Rect2, bag: Bisaccia) -> void:
	position = rect.position
	size = rect.size
	mouse_filter = Control.MOUSE_FILTER_STOP
	var frame := Panel.new()
	frame.size = size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", CraftingPanel.panel_box(Color("#2f7a70")))
	add_child(frame)
	var title := Label.new()
	title.text = "Il Germogliato"
	title.position = Vector2(14, 8)
	UiFonts.apply(title, 3, UiPalette.AMBRA)
	title.position.y = 10
	add_child(title)
	text = RichTextLabel.new()
	text.bbcode_enabled = true
	text.scroll_active = true
	text.position = Vector2(14, 48)
	text.size = size - Vector2(24, 58)
	text.add_theme_font_size_override("normal_font_size", 15)
	text.add_theme_color_override("default_color", Color("#dcefe8"))
	add_child(text)
	bag.changed.connect(func() -> void: _dirty = true)


func refresh() -> void:
	_dirty = false
	text.text = String(sheet.call()) if sheet.is_valid() else ""


func _process(_dt: float) -> void:
	if _dirty and is_visible_in_tree():
		refresh()
