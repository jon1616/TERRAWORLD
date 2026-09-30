class_name GlyphPanel
extends Control
## La ruota dei glifi (Roadmap 17, voce 174): la frase del sigillo di uno scrigno a parola con il posto vuoto, che tipo
## di parola manca, e le parole che si possono scegliere (quelle viste, della stessa classe; in italiano se sono certe).
## Un clic sceglie (`WordChests.answer`); Esc o clic fuori chiude.

var wc: WordChests
var origin := Vector2i(-1, -1)
var _box: PanelContainer
var _text: RichTextLabel
var _grid: GridContainer


func setup(w: WordChests) -> void:
	wc = w
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	size = Vector2(1600, 900)
	var dim := ColorRect.new()
	dim.color = Color(0, 0.01, 0.02, 0.6)
	dim.size = size
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	_box = PanelContainer.new()
	_box.add_theme_stylebox_override("panel", UiFrames.padded("forte", "normale", Color("#e0b060"), Vector2(24, 22)))
	add_child(_box)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	_box.add_child(v)
	var title := Label.new()
	title.text = "Scrigno a parola"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color("#ffd08a"))
	v.add_child(title)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.fit_content = true
	_text.scroll_active = false
	_text.custom_minimum_size = Vector2(780, 0)
	_text.add_theme_font_size_override("normal_font_size", 18)
	v.add_child(_text)
	_grid = GridContainer.new()
	_grid.columns = 6
	_grid.add_theme_constant_override("h_separation", 8)
	_grid.add_theme_constant_override("v_separation", 8)
	v.add_child(_grid)
	var hint := Label.new()
	hint.text = "Esc per chiudere"
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color("#6a8a84"))
	v.add_child(hint)


func open(o: Vector2i, e: Dictionary) -> void:
	origin = o
	var lg: Language = wc.m.language
	var words: Array = e["words"]
	var gap := int(e["gap"])
	var sem := []
	var tr := []
	for i in words.size():
		if i == gap:
			sem.append("[color=#ffd08a]____[/color]")
			tr.append("[color=#ffd08a]____[/color]")
		else:
			sem.append(LanguageData.sem(String(words[i])))
			tr.append(lg.word_bb(String(words[i])))
	var cls := String(LanguageData.class_of(String(words[gap])))
	_text.text = "[font_size=26][color=#6ff0b8]%s[/color][/font_size]\n\n%s\n\n[color=#9fc8c0]Sul coperchio è incisa una frase, ma una parola manca: è %s. Scegli la parola giusta tra quelle che hai visto; se sbagli il sigillo si richiude per un po'. La frase è di una stele di questo mondo: leggere le altre aiuta.[/color]" % [
		" ".join(sem), "  ".join(tr), LexiconPanel.CLASS_NAME.get(cls, "una parola")]
	for c in _grid.get_children():
		c.queue_free()
	var ch := wc.choices(e)
	if ch.is_empty():
		_text.text += "\n\n[color=#a07060]Non hai ancora visto nessuna parola di questo tipo: leggi qualche stele.[/color]"
	for w in ch:
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.text = "%s%s" % [LanguageData.sem(w), (" · " + LanguageData.it(w)) if lg.known(w) else ""]
		b.custom_minimum_size = Vector2(122, 36)
		b.add_theme_font_size_override("font_size", 15)
		var word := String(w)
		b.pressed.connect(func() -> void:
			visible = false
			if wc.answer(origin, word):
				wc.m.interact.touch(origin))           # aperto: si apre come uno scrigno qualunque
		_grid.add_child(b)
	visible = true
	_box.reset_size()
	await get_tree().process_frame
	_box.reset_size()
	_box.position = (size - _box.size) / 2.0


func _input(e: InputEvent) -> void:
	if not visible:
		return
	if e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE:
		visible = false
		get_viewport().set_input_as_handled()
