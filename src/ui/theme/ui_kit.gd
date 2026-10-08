class_name UiKit
extends RefCounted
## I pezzi dell'interfaccia (Roadmap 55 «Il volto chiaro»): ogni pannello e ogni scheda si compone di questi, così il
## gioco ha un solo stile. Regole (guida `ARTE.md`, «Il volto chiaro»):
##   - i nomi e i titoli in Alegreya (`title`), tutto il resto in Alegreya Sans (`label`, `rich`);
##   - una sezione = un titoletto in maiuscoletto (`caps`) e sotto il suo contenuto; tra le sezioni `UiPalette.SEZIONE`;
##   - i numeri chiave in etichette tonde (`chip`), i comandi come tasti disegnati (`hint`), mai in una frase;
##   - il prossimo passo in un riquadro evidenziato (`callout`); il vuoto spiegato (`empty`), mai un riquadro nero;
##   - tre colori con un significato: BUONO, PERICOLO, AMBRA; il resto in TESTO, TESTO_SPENTO, TESTO_MUTO.



static func label(text: String, px := UiPalette.TESTO_PX, col := UiPalette.TESTO, role := "testo") -> Label:
	var l := Label.new()
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiFonts.set_role(l, role, px, col)
	return l


## Un testo che va a capo nella larghezza `w`.
static func para(text: String, w: float, px := UiPalette.TESTO_PX, col := UiPalette.TESTO_SPENTO, role := "chiaro") -> Label:
	var l := label(text, px, col, role)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(w, 0)
	return l


static func title(text: String, px := UiPalette.TITOLO, col := UiPalette.AMBRA) -> Label:
	return label(text, px, col, "titolo")


static func name_label(text: String, px := UiPalette.SOTTOTITOLO, col := UiPalette.TESTO) -> Label:
	return label(text, px, col, "nome")


static var _caps_font: FontVariation


## Il titoletto di una sezione: maiuscolo, piccolo, spaziato, spento.
static func caps(text: String, col := UiPalette.TESTO_MUTO) -> Label:
	if _caps_font == null:
		_caps_font = FontVariation.new()
		_caps_font.base_font = UiFonts.get_font("forte")
		_caps_font.spacing_glyph = 2
	var l := Label.new()
	l.text = text.to_upper()
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_override("font", _caps_font)
	l.add_theme_font_size_override("font_size", UiPalette.MINI)
	l.add_theme_color_override("font_color", col)
	return l


## Un testo con i colori (BBCode), alto quanto il suo contenuto.
static func rich(bb: String, w := 0.0, px := UiPalette.TESTO_PX) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for k in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size", "mono_font_size"]:
		r.add_theme_font_size_override(k, px)
	r.add_theme_font_override("normal_font", UiFonts.get_font("chiaro"))
	r.add_theme_color_override("default_color", UiPalette.TESTO_SPENTO)
	if w > 0.0:
		r.custom_minimum_size = Vector2(w, 0)
	r.text = bb
	return r


## Un'etichetta tonda: un numero chiave, un tipo, una rarità. Con `icon` (Texture2D) l'icona a sinistra.
static func chip(text: String, accent := Color(0, 0, 0, 0), icon: Texture2D = null, px := UiPalette.NOTA) -> PanelContainer:
	var pc := PanelContainer.new()
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.add_theme_stylebox_override("panel", UiFrames.box("chip", "normale", accent))
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 5)
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.add_child(hb)
	if icon != null:
		hb.add_child(icon_rect(icon, px + 2))
	var col := UiPalette.TESTO if accent.a <= 0.0 else Color(accent, 1.0).lightened(0.35)
	hb.add_child(label(text, px, col, "forte" if accent.a > 0.0 else "testo"))
	return pc


## Un tasto disegnato (il nome del tasto in un riquadro tondo, come sulla tastiera).
static func keycap(key: String) -> PanelContainer:
	var pc := PanelContainer.new()
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#1f3133")
	sb.border_color = Color(UiPalette.BORDO_CHIARO, 0.6)
	sb.set_border_width_all(1)
	sb.border_width_bottom = 3
	sb.set_corner_radius_all(5)
	sb.anti_aliasing = true
	sb.content_margin_left = 7
	sb.content_margin_right = 7
	sb.content_margin_top = 0
	sb.content_margin_bottom = 1
	pc.add_theme_stylebox_override("panel", sb)
	pc.add_child(label(key, UiPalette.NOTA, UiPalette.TESTO, "forte"))
	return pc


## Un comando: il tasto e che cosa fa.
static func hint(key: String, what: String) -> HBoxContainer:
	var hb := HBoxContainer.new()
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_theme_constant_override("separation", 7)
	for k in key.split("/"):
		hb.add_child(keycap(k.strip_edges()))
	hb.add_child(label(what, UiPalette.NOTA, UiPalette.TESTO_SPENTO, "chiaro"))
	return hb


## Una fila di comandi: [[tasto, cosa fa], …].
static func hints(pairs: Array) -> HBoxContainer:
	var hb := HBoxContainer.new()
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_theme_constant_override("separation", 22)
	for pr in pairs:
		hb.add_child(hint(String(pr[0]), String(pr[1])))
	return hb


## Un riquadro evidenziato: il prossimo passo, un avviso, una cosa da non perdere.
static func callout(head: String, bb: String, accent := UiPalette.AMBRA, w := 0.0) -> PanelContainer:
	var pc := PanelContainer.new()
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.add_theme_stylebox_override("panel", UiFrames.box("sezione", "normale", Color(accent, 0.8)))
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 4)
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.add_child(vb)
	if head != "":
		vb.add_child(caps(head, Color(accent, 1.0)))
	vb.add_child(rich(bb, maxf(w - 28.0, 0.0)))
	if w > 0.0:
		pc.custom_minimum_size = Vector2(w, 0)
	return pc


## Una sezione: il titoletto e sotto il contenuto.
static func section(head: String, content: Control) -> VBoxContainer:
	var vb := VBoxContainer.new()
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_theme_constant_override("separation", UiPalette.RIGA + 2)
	var hb := HBoxContainer.new()
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_theme_constant_override("separation", 10)
	hb.add_child(caps(head))
	var line := UiRule.new()
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(line)
	vb.add_child(hb)
	vb.add_child(content)
	return vb


## I valori in due colonne allineate: [[nome, valore, colore?], …].
static func stats(rows: Array, px := UiPalette.TESTO_PX) -> GridContainer:
	var g := GridContainer.new()
	g.columns = 2
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	g.add_theme_constant_override("h_separation", 18)
	g.add_theme_constant_override("v_separation", 4)
	for r in rows:
		var row: Array = r
		g.add_child(label(String(row[0]), px, UiPalette.TESTO_MUTO, "chiaro"))
		var col: Color = row[2] if row.size() > 2 and row[2] is Color else UiPalette.TESTO
		g.add_child(label(str(row[1]), px, col, "forte"))
	return g


## Una barra morbida (avanzamento, Vita, crescita).
static func bar(frac: float, col: Color, w := 0.0, h := 8.0) -> UiBar:
	var b := UiBar.new()
	b.frac = frac
	b.color = col
	b.custom_minimum_size = Vector2(w, h)
	return b


## Un'icona (Texture2D, Image o id di un oggetto) grande `px`, morbida.
static func icon_rect(v: Variant, px := 32.0) -> TextureRect:
	var t := TextureRect.new()
	t.texture = TipView.icon_of(v)
	t.custom_minimum_size = Vector2(px, px)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	if t.texture != null and t.texture.get_width() <= 16:
		t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST     # un disegno a pixel piccolo: a quadretti netti
	return t


## Il vuoto spiegato: un'icona, che cosa manca e i modi per cominciare ([[icona o id, testo], …]).
static func empty(icon: Variant, head: String, text: String, ways: Array, w := 520.0) -> VBoxContainer:
	var vb := VBoxContainer.new()
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 10)
	if icon != null:
		var ic := UiMedal.new()
		ic.icon = TipView.icon_of(icon)
		ic.custom_minimum_size = Vector2(84, 84)
		ic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		vb.add_child(ic)
	var t := name_label(head, UiPalette.SOTTOTITOLO, UiPalette.AMBRA_CHIARA)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(t)
	var p := para(text, w, UiPalette.TESTO_PX, UiPalette.TESTO_SPENTO)
	p.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vb.add_child(p)
	if not ways.is_empty():
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 8)
		box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		for wy in ways:
			var hb := HBoxContainer.new()
			hb.add_theme_constant_override("separation", 10)
			hb.add_child(icon_rect(wy[0], 28))
			hb.add_child(para(String(wy[1]), w - 60.0, UiPalette.TESTO_PX, UiPalette.TESTO))
			box.add_child(hb)
		var pc := PanelContainer.new()
		pc.add_theme_stylebox_override("panel", UiFrames.box("sezione"))
		pc.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		pc.add_child(box)
		vb.add_child(pc)
	return vb


## Un contenitore che scorre in verticale (la barra sottile del tema), con dentro `child` largo quanto lui.
static func vscroll(child: Control) -> ScrollContainer:
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(child)
	return sc


## Una colonna con lo spazio tra le sezioni.
static func column(sep := UiPalette.SEZIONE) -> VBoxContainer:
	var vb := VBoxContainer.new()
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_theme_constant_override("separation", sep)
	return vb


static func row(sep := 10) -> HBoxContainer:
	var hb := HBoxContainer.new()
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_theme_constant_override("separation", sep)
	return hb


## Toglie e libera tutti i figli di un contenitore.
static func clear(c: Node) -> void:
	for ch in c.get_children():
		c.remove_child(ch)
		ch.queue_free()
