class_name LayoutCheck
extends RefCounted
## Il controllo dell'impaginazione (voce 268; l'utente: «nessuna sovrapposizione o taglio di nessun tipo»). Guarda ogni
## Control visibile dei rami dati (il pannello aperto: ciò che gli sta sotto è coperto dal suo sfondo) e segnala:
## - FUORI: un elemento esce dallo schermo (1600×900);
## - RIQUADRO: un elemento esce dal riquadro (Panel/PanelContainer) che lo contiene;
## - TAGLIO: un testo non ci sta (una Label più stretta del suo testo e tagliata, un elemento più basso della sua misura
##   minima, un RichTextLabel che non mostra tutto e non scorre);
## - SOVRAPPOSTI: due testi (Label, RichTextLabel, pulsanti, campi) che si coprono, se nessuno contiene l'altro.
## Dentro le liste che scorrono e i pannelli che ritagliano il contenuto (`clip_contents`) conta solo la parte che si
## vede: essere tagliati lì è voluto. Restituisce un elenco di righe leggibili; vuoto = tutto a posto.

const SCREEN := Rect2(0, 0, 1600, 900)
const TOL := 1.5


static func scan(roots: Array) -> Array[String]:
	var out: Array[String] = []
	var texts: Array[Control] = []
	var clips := {}
	for r in roots:
		if r == null:
			continue
		if r is Control:
			if not (r as Control).is_visible_in_tree():
				continue
			_visit(r as Control, SCREEN, out, texts, clips)
		_walk(r, SCREEN, out, texts, clips)
	for i in texts.size():
		var a := texts[i]
		var ra := _text_rect(a).intersection(clips[a])
		for j in range(i + 1, texts.size()):
			var b := texts[j]
			if a.is_ancestor_of(b) or b.is_ancestor_of(a):
				continue
			var rb := _text_rect(b).intersection(clips[b])
			var inter := ra.intersection(rb)
			if inter.size.x > 2.0 and inter.size.y > 2.0:
				out.append("SOVRAPPOSTI: %s  ×  %s" % [_name(a), _name(b)])
	return out


## `clip` = la parte dello schermo dove i figli si vedono.
static func _walk(n: Node, clip: Rect2, out: Array[String], texts: Array[Control], clips: Dictionary) -> void:
	var inner := clip
	if n is Control and ((n as Control).clip_contents or n is ScrollContainer):
		inner = clip.intersection((n as Control).get_global_rect())
	for c in n.get_children():
		if c is CanvasLayer and not (c as CanvasLayer).visible:
			continue
		if c is Control:
			var ctl := c as Control
			if not ctl.is_visible_in_tree():
				continue
			if not _visit(ctl, inner, out, texts, clips):
				continue
		_walk(c, inner, out, texts, clips)


## Controlla un elemento; falso se non si vede affatto (tutto fuori dalla zona visibile): allora non si guardano nemmeno i
## suoi figli.
static func _visit(ctl: Control, clip: Rect2, out: Array[String], texts: Array[Control], clips: Dictionary) -> bool:
	var r := ctl.get_global_rect()
	if r.size.x > 0.0 and r.size.y > 0.0:
		var vis := r.intersection(clip)
		if vis.size.x <= 0.0 or vis.size.y <= 0.0:
			return false
	_check(ctl, clip, out)
	if _is_text(ctl) and ctl.size.x > 0.0 and ctl.size.y > 0.0:
		texts.append(ctl)
		clips[ctl] = clip
	return true


static func _is_text(c: Control) -> bool:
	if c is Label:
		return (c as Label).text.strip_edges() != ""
	if c is RichTextLabel:
		return (c as RichTextLabel).get_parsed_text().strip_edges() != ""
	return c is Button or c is LineEdit


static func _check(c: Control, clip: Rect2, out: Array[String]) -> void:
	var r := c.get_global_rect()
	if r.size.x <= 0.0 or r.size.y <= 0.0:
		return
	if r.size.x >= SCREEN.size.x - 1.0 and r.size.y >= SCREEN.size.y - 1.0:
		return
	var clipped := clip != SCREEN
	if clipped:
		r = r.intersection(clip)
	if r.position.x < SCREEN.position.x - TOL or r.position.y < SCREEN.position.y - TOL \
			or r.end.x > SCREEN.end.x + TOL or r.end.y > SCREEN.end.y + TOL:
		out.append("FUORI: %s %s" % [_name(c), _rect(r)])
	var box := _box_of(c)
	if box != null and not clipped:
		var rb := box.get_global_rect()
		if r.position.x < rb.position.x - TOL or r.position.y < rb.position.y - TOL \
				or r.end.x > rb.end.x + TOL or r.end.y > rb.end.y + TOL:
			out.append("RIQUADRO: %s esce da %s" % [_name(c), _name(box)])
	var cut := _cut(c)
	if cut != "":
		out.append("TAGLIO: %s — %s" % [_name(c), cut])


static func _cut(c: Control) -> String:
	if c is Label:
		var l := c as Label
		if l.autowrap_mode == TextServer.AUTOWRAP_OFF:
			var widest := _text_width(l)
			if widest > l.size.x + 2.0 and (l.clip_text or l.text_overrun_behavior != TextServer.OVERRUN_NO_TRIMMING):
				return "il testo è largo %d, lo spazio %d («%s»)" % [widest, l.size.x, l.text.left(30)]
		var ms := l.get_minimum_size()
		if l.size.y + 1.0 < ms.y and not l.clip_text:
			return "alto %d, ne servono %d" % [l.size.y, ms.y]
	elif c is RichTextLabel:
		var rt := c as RichTextLabel
		if not rt.fit_content and not rt.scroll_active and rt.get_content_height() > rt.size.y + 2.0:
			return "contenuto alto %d, spazio %d, senza scorrimento" % [rt.get_content_height(), rt.size.y]
	elif c is Button:
		var b := c as Button
		var ms2 := b.get_minimum_size()
		if b.text != "" and b.clip_text and (b.size.x + 1.0 < ms2.x or b.size.y + 1.0 < ms2.y):
			return "pulsante più piccolo del suo testo"
	return ""


static func _text_width(l: Label) -> float:
	var font := l.get_theme_font("font")
	var fs := l.get_theme_font_size("font_size")
	var widest := 0.0
	for line in l.text.split("\n"):
		widest = maxf(widest, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
	return widest


## Il riquadro che contiene l'elemento: il primo Panel o PanelContainer tra gli antenati.
static func _box_of(c: Control) -> Control:
	var p := c.get_parent()
	while p != null:
		if p is Panel or p is PanelContainer:
			return p as Control
		if p is CanvasLayer or not (p is Control):
			return null
		p = p.get_parent()
	return null


## Dove sta davvero il testo: per una Label, la parte occupata dalle parole secondo l'allineamento.
static func _text_rect(c: Control) -> Rect2:
	var r := c.get_global_rect()
	if c is Label:
		var l := c as Label
		var w := minf(_text_width(l), r.size.x)
		var h := minf(l.get_minimum_size().y, r.size.y)
		var x := r.position.x
		if l.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER:
			x += (r.size.x - w) * 0.5
		elif l.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
			x += r.size.x - w
		var y := r.position.y
		if l.vertical_alignment == VERTICAL_ALIGNMENT_CENTER:
			y += (r.size.y - h) * 0.5
		elif l.vertical_alignment == VERTICAL_ALIGNMENT_BOTTOM:
			y += r.size.y - h
		return Rect2(x, y, w, h)
	if c is RichTextLabel:
		var rt := c as RichTextLabel
		return Rect2(r.position, Vector2(r.size.x, minf(r.size.y, rt.get_content_height())))
	return r


static func _name(c: Node) -> String:
	var s := c.get_class()
	if c.get_script() != null and (c.get_script() as Script).get_global_name() != "":
		s = (c.get_script() as Script).get_global_name()
	var t := ""
	if c is Label:
		t = (c as Label).text
	elif c is Button:
		t = (c as Button).text
	elif c is RichTextLabel:
		t = (c as RichTextLabel).get_parsed_text()
	t = t.strip_edges().replace("\n", " ").left(28)
	var par := c.get_parent()
	var ps: String = "" if par == null else String(par.name)
	return "%s«%s»(in %s)" % [s, t, ps] if t != "" else "%s(in %s)" % [s, ps]


static func _rect(r: Rect2) -> String:
	return "[%d,%d %d×%d]" % [r.position.x, r.position.y, r.size.x, r.size.y]
