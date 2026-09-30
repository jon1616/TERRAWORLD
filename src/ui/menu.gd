extends Control
## Menu principale: titolo → scelta o creazione del personaggio → scelta o creazione del mondo → gioco.
## Con `-- --prove` salta tutto e avvia le prove automatiche su un mondo fisso, in una cartella di salvataggi a parte.

const GAME_SCENE := "res://src/game/main.tscn"
const GOLD := Color("#ffb84a")
const TEXT := Color("#eafff6")
const DIM := Color("#9fc8c0")
const TEAL := Color("#2f7a70")
const DANGER := Color("#ff6a5a")       # il rosso dei bottoni che cancellano
const MENU_X := 416.0                   # voce 103: il centro della colonna del menu, nel cielo vuoto a sinistra
const ART_SCALE := 4                    # sfondo (400×225) e logo ingranditi senza sfumare

var _box: VBoxContainer
var _title: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	if "--prove" in OS.get_cmdline_user_args():
		_start_tests.call_deferred()
		return
	# voce 103: sfondo e logo di Nano Banana, con il menu nella metà sinistra (l'Albero-Madre resta libero a destra);
	# senza i file, il cielo e il titolo scritto di prima, al centro
	var art := ArtLib.has("titolo", "sfondo") and ArtLib.has("titolo", "logo")
	var cx := MENU_X if art else 800.0
	if art:
		_make_art_backdrop()
	else:
		_make_backdrop()
		_title = _label("TERRAWORLD", 72, GOLD)
		_title.position = Vector2(cx - 400, 90)
		_title.size = Vector2(800, 90)
		_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(_title)
	var sub := _label("Il Giardino dei Semi", 24, Color("#8ef0d0"))
	sub.position = Vector2(cx - 400, 222 if art else 180)
	sub.size = Vector2(800, 40)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(sub)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiFrames.box("forte"))
	panel.position = Vector2(cx - 280, 290)
	panel.custom_minimum_size = Vector2(560, 0)
	add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	panel.add_child(margin)
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 10)
	margin.add_child(_box)
	_show_title()
	if "--foto-menu" in OS.get_cmdline_user_args():
		_photos()


## Foto delle schermate del menu in prove/ (menu_titolo, menu_personaggi, menu_mondi), poi esce.
func _photos() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prove"))
	var shots := [["menu_titolo", _show_title], ["menu_personaggi", _show_characters], ["menu_nuovo_mondo", _show_new_world], ["menu_impostazioni", _show_settings],
		["menu_mondi", _show_worlds], ["menu_conferma", func() -> void:
			_confirm("Eliminare per sempre il mondo «Esempio»?\nTutto ciò che hai costruito e scavato lì andrà perso.\nI personaggi restano.",
				_show_title, _show_title)]]
	if Session.character == null:
		Session.character = Character.create("Esempio")
	for s in shots:
		(s[1] as Callable).call()
		for k in 10:
			await get_tree().process_frame
		# con hdr_2d l'immagine della finestra è in spazio lineare: senza la conversione la foto viene molto più scura
		# di ciò che si vede sullo schermo (voce 103: lo sfondo sembrava quasi nero)
		var img: Image = await Photo.take(get_viewport())
		img.save_png(ProjectSettings.globalize_path("res://prove/%s.png" % s[0]))
	get_tree().quit()


func _start_tests() -> void:
	Session.test_mode = true
	SavePaths.root = "user://prove_salvataggi"
	var c := Character.create("Prova")
	c.id = "prova"
	Session.character = c
	if "--carica" in OS.get_cmdline_user_args() and not WorldSave.read_meta("mondo_prova").is_empty():
		Session.start_saved_world("mondo_prova")
	else:
		if "--prova-giardino" in OS.get_cmdline_user_args():
			Session.start_new_world("Giardino di prova", 20260924, "giardino_prova", {"giardino": true, "geni": ["brina"]})
		else:
			Session.start_new_world("Mondo di prova", 20260924, "mondo_prova")
	get_tree().change_scene_to_file(GAME_SCENE)


# ---------------------------------------------------------------- schermate

func _show_title() -> void:
	_clear()
	_button("Gioca", _show_characters)
	_button("Enciclopedia", _show_ency, DIM)
	_button("Opzioni", _show_settings, DIM)
	_button("Esci", get_tree().quit)


## L'Enciclopedia anche dal menu, senza personaggio: tutto ciò che si scopre giocando resta nascosto.
var _ency: EncyPanel


func _show_ency() -> void:
	if _ency == null:
		_ency = EncyPanel.new()
		add_child(_ency)
	EncyPages.ch = null
	_ency.open()


## Le Opzioni (27 set 2026): la stessa schermata del menu di pausa in gioco (`OptionsPanel`).
var _options: OptionsPanel


func _show_settings() -> void:
	if _options == null:
		_options = OptionsPanel.new()
		add_child(_options)
		_options.closed.connect(_show_title)
	_options.open()


func _show_characters() -> void:
	_clear()
	_heading("Scegli il personaggio")
	var list := Character.list()
	if list.is_empty():
		_note("Nessun personaggio: creane uno.")
	for c in list:
		var b := _button("%s   ·   %s di gioco" % [c.name, _hours(c.play_time)], func() -> void:
			Session.character = c
			_show_worlds())
		_with_delete(b, func() -> void:
			_confirm("Eliminare per sempre il personaggio «%s»?\nLa sua Bisaccia, l'Erbario e i progressi andranno persi." % c.name,
				func() -> void:
					Character.delete(c.id)
					_show_characters(),
				_show_characters))
	_button("＋ Nuovo personaggio", _show_new_character, GOLD)
	_button("Indietro", _show_title, DIM)


func _show_new_character() -> void:
	_clear()
	_heading("Nuovo personaggio")
	var name_edit := _field("Nome del Germogliato", "")
	_button("Crea", func() -> void:
		var n := name_edit.text.strip_edges()
		if n == "":
			return
		var c := Character.create(n)
		c.save()
		Session.character = c
		_show_worlds(), GOLD)
	_button("Indietro", _show_characters, DIM)
	name_edit.grab_focus()


func _show_worlds() -> void:
	_clear()
	_heading("%s — scegli il mondo" % Session.character.name)
	var list := WorldSave.list_main()             # 28 set 2026: solo i Giardini; i mondi dei Semi stanno dentro
	if list.is_empty():
		_note("Nessun mondo: piantane uno.")
	for m in list:
		var id: String = m["id"]
		var vig := int(m.get("vigore", 1))
		var kids := _children_of(id)
		var b := _button("%s   ·   %sseme %s   ·   %s di gioco%s" % [m.get("nome", id), ("vigore %d   ·   " % vig) if vig > 1 else "", m.get("seme", "?"), _hours(float(m.get("tempo_di_gioco", 0.0))),
			("   ·   %d mondi nati dai Semi" % kids) if kids > 0 else ""], func() -> void:
			Session.start_saved_world(id)
			get_tree().change_scene_to_file(GAME_SCENE))
		var wname := String(m.get("nome", id))
		_with_delete(b, func() -> void:
			_confirm("Eliminare per sempre il mondo «%s»?\nTutto ciò che hai costruito e scavato lì andrà perso%s.\nI personaggi restano." % [wname,
				(", insieme ai %d mondi nati dai suoi Semi" % kids) if kids > 0 else ""],
				func() -> void:
					WorldSave.delete(id)
					_show_worlds(),
				_show_worlds))
	_button("＋ Nuovo mondo", _show_new_world, GOLD)
	_button("Indietro", _show_characters, DIM)


## Quanti mondi nati dai Semi stanno dentro un Giardino.
func _children_of(id: String) -> int:
	var n := 0
	for m in WorldSave.list():
		if bool(m.get("dentro", false)) and String(m.get("casa", "")) == id:
			n += 1
	return n


func _show_new_world() -> void:
	_clear()
	_heading("Nuovo Giardino")
	var name_edit := _field("Nome del Giardino", "")
	var seed_edit := _field("Seme (vuoto = a caso)", "")
	# voce 62: la partita comincia nel Giardino; questo gene va nel primo Seme che l'Albero-Madre lascia cadere, e
	# sceglie i biomi del primo mondo (a ogni clic il successivo)
	var kinds := [""] + GenesData.of_cat("superficie")
	var pick := [0]
	var kind_btn := _button("", Callable(), TEXT)
	var show_kind := func() -> void:
		var g := String(kinds[pick[0]])
		kind_btn.text = "Primo Seme: %s" % ("tutti i biomi" if g == "" else "%s (%s)" % [GenesData.GENES[g]["name"],
			GenesData.GENES[g]["desc"]])
	show_kind.call()
	kind_btn.pressed.connect(func() -> void:
		pick[0] = (pick[0] + 1) % kinds.size()
		show_kind.call())
	_button("Pianta il seme", func() -> void:
		var n := name_edit.text.strip_edges()
		if n == "":
			n = "Giardino senza nome"
		var s := seed_edit.text.strip_edges()
		var sd := int(s) if s.is_valid_int() else (s.hash() & 0x7fffffff if s != "" else randi() & 0x7fffffff)
		var g := String(kinds[pick[0]])
		Session.start_new_world(n, sd, "", {"giardino": true} if g == "" else {"giardino": true, "geni": [g]})
		get_tree().change_scene_to_file(GAME_SCENE), GOLD)
	_button("Indietro", _show_worlds, DIM)
	name_edit.grab_focus()


## Mette accanto a un bottone della lista un piccolo «Elimina» (rosso), che chiede sempre conferma.
func _with_delete(b: Button, on_delete: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var i := b.get_index()
	_box.remove_child(b)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(b)
	var d := Button.new()
	d.text = "Elimina"
	d.tooltip_text = "Elimina per sempre (chiede conferma)"
	d.custom_minimum_size = Vector2(110, 46)
	d.add_theme_font_size_override("font_size", 16)
	d.add_theme_color_override("font_color", DANGER)
	d.add_theme_color_override("font_hover_color", Color("#ffb0a0"))
	UiFrames.button(d, DANGER)
	d.pressed.connect(on_delete)
	row.add_child(d)
	_box.add_child(row)
	_box.move_child(row, i)


## La conferma prima di cancellare: la domanda e due bottoni. «No» è il primo (e ha il fuoco): Invio non cancella.
func _confirm(question: String, on_yes: Callable, on_no: Callable) -> void:
	_clear()
	_heading("Sei sicuro?")
	var l := _label(question, 20, TEXT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_box.add_child(l)
	var no := _button("No, torna indietro", on_no, GOLD)
	_button("Sì, elimina per sempre", on_yes, DANGER)
	no.grab_focus.call_deferred()


# ---------------------------------------------------------------- mattoni dell'interfaccia

## Voce 103: lo sfondo del Giardino (arte/titolo/sfondo.png, 400×225) a tutto schermo e il logo sopra il menu.
func _make_art_backdrop() -> void:
	var bg := TextureRect.new()
	bg.texture = ArtLib.tex("titolo", "sfondo")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var lt := ArtLib.tex("titolo", "logo")
	var logo := TextureRect.new()
	logo.texture = lt
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	logo.size = lt.get_size() * ART_SCALE
	logo.position = Vector2(MENU_X - logo.size.x * 0.5, 72).round()
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(logo)


func _make_backdrop() -> void:
	var sky := TextureRect.new()
	var gt := GradientTexture2D.new()
	var gr := Gradient.new()
	gr.offsets = PackedFloat32Array([0.0, 0.5, 0.8, 1.0])
	gr.colors = PackedColorArray([Color("#123e52"), Color("#3f8a98"), Color("#f0ae88"), Color("#ffe2b4")])
	gt.gradient = gr
	gt.fill_to = Vector2(0, 1)
	gt.width = 4
	gt.height = 256
	sky.texture = gt
	sky.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sky.stretch_mode = TextureRect.STRETCH_SCALE
	sky.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(sky)
	var imgs := [
		NatureArt.root_arches(512, 260, 9001, Color("#5a92a4"), Color("#86bcc4")),
		NatureArt.lantern_forest(400, 260, 9002, Color("#2e6474"), Color("#ffd49a")),
		NatureArt.lantern_forest(400, 260, 9003, Color("#10303e"), Color("#ffc070")),
	]
	for k in imgs.size():
		var im: Image = imgs[k]
		im.resize(im.get_width() * 2, 520, Image.INTERPOLATE_NEAREST)
		var tr := TextureRect.new()
		tr.texture = ImageTexture.create_from_image(im)
		tr.stretch_mode = TextureRect.STRETCH_TILE
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		tr.offset_top = -520 + k * 70
		add_child(tr)


func _clear() -> void:
	for c in _box.get_children():
		c.queue_free()


func _label(text: String, size: int, col: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0.02, 0.06, 0.08))
	l.add_theme_constant_override("outline_size", 8)
	return l


func _heading(text: String) -> void:
	var l := _label(text, 26, GOLD)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(l)


func _note(text: String) -> void:
	var l := _label(text, 18, DIM)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(l)


func _button(text: String, action: Callable, col := TEXT) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 46)
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", col)
	b.add_theme_color_override("font_hover_color", GOLD)
	UiFrames.button(b)
	if action.is_valid():
		b.pressed.connect(action)
	_box.add_child(b)
	return b


func _field(placeholder: String, text: String) -> LineEdit:
	var e := LineEdit.new()
	e.placeholder_text = placeholder
	e.text = text
	e.custom_minimum_size = Vector2(0, 44)
	e.add_theme_font_size_override("font_size", 20)
	_box.add_child(e)
	return e


static func _hours(seconds: float) -> String:
	var m := int(seconds / 60.0)
	return "%d h %02d min" % [m / 60, m % 60] if m >= 60 else "%d min" % m
