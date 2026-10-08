class_name CharacterCard
extends Control
## La scheda del Germogliato, in basso a sinistra della Bisaccia aperta (28 set 2026: prima compariva nella casella
## Esamina vuota; con Esamina riprogettata ha il suo posto fisso). Rifatta nella Roadmap 55 «Il volto chiaro»: il nome,
## Vita, Linfa e Scorza in etichette, gli effetti dell'equipaggiamento in colonna (solo quelli che ci sono), set, firma
## e reliquie, i doni in fondo. Le parti le dà `CharacterSheet.parts` (`parts`, lo passa `main`); senza, il testo di
## `sheet`.

var sheet: Callable
var parts: Callable
var text: RichTextLabel
var _box: VBoxContainer
var _scroll: ScrollContainer
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
	title.position = Vector2(16, 10)
	UiFonts.set_role(title, "titolo", 25, UiPalette.AMBRA)
	add_child(title)
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.position = Vector2(16, 48)
	_scroll.size = size - Vector2(24, 58)
	add_child(_scroll)
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 8)
	_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_box)
	text = RichTextLabel.new()                 # (il testo in una riga, per chi lo legge: prove, suggerimenti)
	text.bbcode_enabled = true
	text.visible = false
	add_child(text)
	bag.changed.connect(func() -> void: _dirty = true)


func refresh() -> void:
	_dirty = false
	text.text = String(sheet.call()) if sheet.is_valid() else ""
	UiKit.clear(_box)
	if not parts.is_valid():
		var r := UiKit.rich(text.text, _scroll.size.x - 12.0, 15)
		_box.add_child(r)
		return
	var p: Dictionary = parts.call()
	var w := _scroll.size.x - 12.0
	_box.add_child(UiKit.label(String(p["name"]), 18, UiPalette.AMBRA_CHIARA, "nome"))
	var vit := HFlowContainer.new()
	vit.add_theme_constant_override("h_separation", 6)
	vit.add_theme_constant_override("v_separation", 5)
	vit.custom_minimum_size = Vector2(w, 0)
	for r in p["vitals"]:
		vit.add_child(UiKit.chip("%s %s" % [r[0], r[1]], r[2], null, 13))
	_box.add_child(vit)
	var eff: Array = p["effects"]
	if eff.is_empty():
		_box.add_child(UiKit.label("Nessun effetto dall'equipaggiamento", 14, UiPalette.TESTO_MUTO, "corsivo"))
	else:
		var pairs := eff.filter(func(r: Array) -> bool: return r.size() > 1)
		if not pairs.is_empty():
			_box.add_child(UiKit.stats(pairs, 14))
		for r in eff:
			if (r as Array).size() == 1:
				_box.add_child(UiKit.label("· " + String(r[0]), 14, UiPalette.TESTO_SPENTO, "chiaro"))
	for e in p["extra"]:
		_box.add_child(UiKit.rich(String(e), w, 14))
	var tail := UiKit.stats(p["tail"], 13)
	_box.add_child(UiKit.section("Doni e collezioni", tail))


func _process(_dt: float) -> void:
	if _dirty and is_visible_in_tree():
		refresh()
