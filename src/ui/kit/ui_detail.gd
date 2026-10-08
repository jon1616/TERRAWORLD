class_name UiDetail
extends VBoxContainer
## La colonna di dettaglio dei pannelli (Roadmap 55): la cosa scelta raccontata sempre con gli stessi pezzi, in
## quest'ordine quando servono: intestazione (medaglione, nome, che cos'è, un numero grande a destra), etichette, barra
## di avanzamento, il prossimo passo in evidenza, le sezioni (valori, elenchi con lo stato, tappe, testo), le note.
## Si svuota con `reset(colore, larghezza)` e si riempie chiamando i pezzi in ordine.

var color := UiPalette.AMBRA
var w := 900.0


func _init() -> void:
	add_theme_constant_override("separation", UiPalette.SEZIONE)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_EXPAND_FILL


func reset(col: Color, width: float) -> UiDetail:
	color = col
	w = width
	UiKit.clear(self)
	return self


## L'intestazione: medaglione con l'icona (se c'è), il nome, la riga che dice che cos'è; a destra un numero grande con
## la sua didascalia (il grado, il rango, le stelle).
func head(name: String, what := "", icon: Variant = null, big := "", caption := "") -> void:
	var hb := UiKit.row(16)
	if icon != null:
		var md := UiMedal.new()
		md.ring = color
		md.icon = TipView.icon_of(icon) if not (icon is Texture2D) else icon
		md.custom_minimum_size = Vector2(76, 76)
		hb.add_child(md)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(UiKit.name_label(name, 30, color.lerp(UiPalette.TESTO, 0.3)))
	if what != "":
		vb.add_child(UiKit.para(what, w - (260.0 if big != "" else 120.0), UiPalette.TESTO_PX, UiPalette.TESTO_SPENTO))
	hb.add_child(vb)
	if big != "":
		var gv := VBoxContainer.new()
		gv.alignment = BoxContainer.ALIGNMENT_CENTER
		gv.custom_minimum_size = Vector2(90, 0)
		var gl := UiKit.title(big, 44, color)
		gl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		gv.add_child(gl)
		if caption != "":
			var gc := UiKit.caps(caption)
			gc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			gv.add_child(gc)
		hb.add_child(gv)
	add_child(hb)


## Etichette tonde in fila: [[testo, colore?], …].
func chips(list: Array) -> void:
	var hb := HFlowContainer.new()
	hb.add_theme_constant_override("h_separation", 8)
	hb.add_theme_constant_override("v_separation", 6)
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in list:
		var a: Array = c if c is Array else [c]
		hb.add_child(UiKit.chip(String(a[0]), a[1] if a.size() > 1 and a[1] is Color else Color(0, 0, 0, 0)))
	add_child(hb)


## Una barra di avanzamento con la sua riga sotto (e una nota spenta, facoltativa).
func progress(frac: float, text: String, note := "") -> void:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	vb.add_child(UiKit.bar(frac, color, w, 10.0))
	var hb := UiKit.row(12)
	hb.add_child(UiKit.label(text, UiPalette.NOTA + 1, UiPalette.TESTO_SPENTO, "chiaro"))
	if note != "":
		hb.add_child(UiKit.label("· " + note, UiPalette.NOTA + 1, UiPalette.TESTO_MUTO, "corsivo"))
	vb.add_child(hb)
	add_child(vb)


## Il prossimo passo (o un'altra cosa da non perdere) in un riquadro del colore della voce.
func callout(caption: String, bb: String, col := Color(0, 0, 0, 0)) -> void:
	add_child(UiKit.callout(caption, "[color=#%s]%s[/color]" % [UiPalette.TESTO.to_html(false), bb],
		color if col.a <= 0.0 else col, w))


## Una sezione con il suo titoletto; restituisce la colonna dove mettere il contenuto.
func section(caption: String) -> VBoxContainer:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", UiPalette.RIGA)
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(UiKit.section(caption, vb))
	return vb


## Una sezione di valori in colonna: [[nome, valore, colore?], …].
func stats(caption: String, rows: Array) -> void:
	if rows.is_empty():
		return
	section(caption).add_child(UiKit.stats(rows))


## Una sezione di testo con i colori.
func text(caption: String, bb: String) -> void:
	if bb.strip_edges() == "":
		return
	var r := UiKit.rich(bb, w)
	if caption == "":
		add_child(r)
	else:
		section(caption).add_child(r)


## Un elenco con lo stato di ogni riga: [[stato («fatto», «ora», «poi», «no»), testo (BBCode), nota?, icona?], …].
## Fatto = il segno del colore della voce; ora = in ambra; poi = spento; no = in rosso.
func checklist(caption: String, rows: Array) -> void:
	if rows.is_empty():
		return
	var vb := section(caption) if caption != "" else self
	for r in rows:
		var a: Array = r
		var st := String(a[0])
		var hb := UiKit.row(10)
		var mark := UiKit.label({"fatto": "✓", "ora": "➤", "no": "✕"}.get(st, "·"), UiPalette.TESTO_PX,
			{"fatto": color, "ora": UiPalette.AMBRA, "no": UiPalette.PERICOLO}.get(st, UiPalette.TESTO_MUTO), "forte")
		mark.custom_minimum_size = Vector2(16, 0)
		hb.add_child(mark)
		if a.size() > 3 and a[3] != null:
			hb.add_child(UiKit.icon_rect(a[3], 24))
		var tcol := UiPalette.TESTO if st in ["fatto", "ora"] else UiPalette.TESTO_SPENTO
		var body := "[color=#%s]%s[/color]" % [tcol.to_html(false), String(a[1])]
		if a.size() > 2 and String(a[2]) != "":
			body += "  [color=#%s]%s[/color]" % [UiPalette.TESTO_MUTO.to_html(false), String(a[2])]
		var rt := UiKit.rich(body, w - 60.0)
		rt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hb.add_child(rt)
		vb.add_child(hb)


## Le tappe (gradi, ranghi, stadi): vedi `UiTimeline`.
func steps(caption: String, list: Array) -> void:
	var tl := UiTimeline.new()
	tl.set_steps(list, color, w)
	section(caption).add_child(tl)


## Una nota spenta in fondo.
func note(s: String) -> void:
	if s != "":
		add_child(UiKit.para(s, w, UiPalette.NOTA + 1, UiPalette.TESTO_MUTO, "corsivo"))


## Il vuoto: niente da mostrare (con i modi per cominciare).
func empty(icon: Variant, caption: String, s: String, ways := []) -> void:
	var e := UiKit.empty(icon, caption, s, ways, minf(w, 560.0))
	e.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(e)


static var _re_head: RegEx
static var _re_sec: RegEx


## Impagina un testo dei moduli del gioco (BBCode) con i pezzi del dettaglio. Le forme che riconosce:
##   «[font_size=N][color=#c]Nome[/color][/font_size]» in prima riga  → l'intestazione (la riga dopo = che cos'è)
##   «[b]Titolo[/b]» da solo (o con una parentesi dopo)             → una sezione (la parentesi diventa una nota)
##   righe che cominciano con ✓ ★ (fatte) · ☆ (da fare) ✕ ✗ (no) ➤ (ora)  → un elenco con lo stato
##   una riga vuota                                                 → fine del paragrafo
## Il resto resta testo con i suoi colori. `icon` va nel medaglione dell'intestazione.
func bbcode(bb: String, icon: Variant = null) -> void:
	if _re_head == null:
		_re_head = RegEx.create_from_string("^\\[font_size=\\d+\\](?:\\[color=#?([0-9a-fA-F]{6,8})\\])?(.*?)(?:\\[/color\\])?\\[/font_size\\](.*)$")
		_re_sec = RegEx.create_from_string("^\\[b\\]([^\\[]+)\\[/b\\]\\s*(\\(.*\\))?\\s*:?\\s*$")
	var lines := bb.split("\n")
	var i := 0
	if not lines.is_empty():
		var mh := _re_head.search(lines[0])
		if mh != null:
			if mh.get_string(1) != "":
				color = Color("#" + mh.get_string(1))
			var what := mh.get_string(3).strip_edges()
			i = 1
			if what == "" and lines.size() > 1 and lines[1].strip_edges() != "" and not _is_mark(lines[1]) \
					and _re_sec.search(lines[1]) == null:
				what = lines[1]
				i = 2
			head(_plain(mh.get_string(2)), _plain(what), icon)
	var target: Control = self
	var para := []
	var checks := []
	for k in range(i, lines.size() + 1):
		var ln: String = lines[k] if k < lines.size() else ""
		var is_sec := k < lines.size() and _re_sec.search(ln) != null
		var is_mark := k < lines.size() and _is_mark(ln)
		# un paragrafo finisce a una riga vuota, a una sezione o a un elenco; un elenco a qualunque altra riga
		if not para.is_empty() and (ln.strip_edges() == "" or is_sec or is_mark):
			target.add_child(UiKit.rich("\n".join(para), w))
			para.clear()
		if not checks.is_empty() and not is_mark:
			_checks_into(target, checks)
			checks.clear()
		if k == lines.size():
			break
		if is_sec:
			var ms := _re_sec.search(ln)
			var vb := section(ms.get_string(1).strip_edges())
			target = vb
			if ms.get_string(2) != "":
				vb.add_child(UiKit.label(ms.get_string(2).trim_prefix("(").trim_suffix(")"), UiPalette.NOTA + 1,
					UiPalette.TESTO_MUTO, "corsivo"))
		elif is_mark:
			checks.append(ln)
		elif ln.strip_edges() != "":
			para.append(ln)


static func _is_mark(ln: String) -> bool:
	var t := ln.strip_edges()
	for mk in ["✓", "★", "·", "☆", "✕", "✗", "➤"]:
		if t.begins_with(mk + " ") or t.begins_with(mk + " "):
			return true
	return false


func _checks_into(target: Control, rows: Array) -> void:
	var out := []
	for ln in rows:
		var t := String(ln).strip_edges()
		var mk := t.substr(0, 1)
		var st := "poi"
		if mk in ["✓", "★"]:
			st = "fatto"
		elif mk in ["✕", "✗"]:
			st = "no"
		elif mk == "➤":
			st = "ora"
		out.append([st, t.substr(2)])
	var keep := get_child_count()
	checklist("", out)
	if target != self:
		# `checklist` senza titolo scrive in fondo al dettaglio: le righe passano nella sezione aperta
		var moved := []
		for k in range(keep, get_child_count()):
			moved.append(get_child(k))
		for n in moved:
			remove_child(n)
			target.add_child(n)


static func _plain(s: String) -> String:
	var re := RegEx.create_from_string("\\[[^\\]]*\\]")
	return re.sub(s, "", true).strip_edges()

