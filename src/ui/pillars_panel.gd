class_name PillarsPanel
extends UiPage
## Il Libro dei pilastri (Roadmap 20, voce 216; tasto «pilastri», P). Rifatto nella Roadmap 55 «Il volto chiaro»:
## a sinistra i dieci pilastri come schedine (icona, grado, barra verso il grado dopo); a destra il pilastro scelto:
## l'intestazione con il grado, la barra dei punti, il prossimo passo in evidenza, le righe dei sistemi che lo nutrono,
## e i dieci gradi come una strada a tappe, con il premio di ognuno.

var ms: Mastery
var sel := "storia"


func setup(main: Node2D, mastery: Mastery) -> void:
	m = main
	ms = mastery
	key_action = "pilastri"
	visible = false
	build_page("Il Libro dei pilastri", "Dieci strade lunghe: ognuna sale di grado con ciò che fai nel suo campo, e ogni grado dà un premio.",
		ArtLib.tex("interfaccia", "pannello_pilastri") if ArtLib.has("interfaccia", "pannello_pilastri") else null)
	set_hints([[Keys.label("pilastri"), "apri e chiudi"], ["Clic", "scegli un pilastro"], ["Rotella", "scorri"]])
	split()
	list.chosen.connect(func(id: String) -> void:
		sel = id
		detail_top()
		mark_dirty())
	ms.gained.connect(func(_p: String, _x: float) -> void: mark_dirty())


func _icon(p: String) -> Variant:
	var ic: Array = MasteryData.PILLARS[p].get("icon", [])
	return ItemIcons.make_ui(String(ic[0]), String(ic[1])) if ic.size() >= 2 else null


func refresh() -> void:
	var items := []
	var total := 0
	for p in MasteryData.ORDER:
		var d: Dictionary = MasteryData.PILLARS[p]
		var g := ms.grade(String(p))
		total += g
		items.append({"id": p, "title": String(d["name"]), "sub": String(d["desc"]), "badge": "grado %d" % g,
			"color": d["color"], "frac": progress(String(p)), "icon": _icon(String(p)), "dim": ms.idle(String(p)) < 0.0})
	list.set_items(items, sel)
	set_chips([["%d gradi su %d" % [total, MasteryData.ORDER.size() * MasteryData.GRADES], UiPalette.AMBRA],
		["%d pilastri cominciati" % MasteryData.ORDER.filter(func(p: Variant) -> bool: return ms.idle(String(p)) >= 0.0).size()]])
	_fill(sel)


## Quanto manca al grado dopo, da 0 a 1 (1 al grado massimo).
func progress(p: String) -> float:
	var g := ms.grade(p)
	if g >= MasteryData.GRADES:
		return 1.0
	var a := MasteryData.points_for(p, g)
	var b := MasteryData.points_for(p, g + 1)
	return clampf((ms.points(p) - a) / maxf(b - a, 1.0), 0.0, 1.0)


func _fill(p: String) -> void:
	var d: Dictionary = MasteryData.PILLARS[p]
	var g := ms.grade(p)
	detail.reset(d["color"], detail_w())
	detail.head(String(d["name"]), String(d["desc"]), _icon(p), str(g), "grado")
	var pts := ""
	if g < MasteryData.GRADES:
		pts = "%d punti su %d per il grado %d" % [int(ms.points(p)), int(MasteryData.points_for(p, g + 1)), g + 1]
	else:
		pts = "Grado massimo · %d punti" % int(ms.points(p))
	var idle := ms.idle(p)
	var note := ""
	if idle < 0.0:
		note = "non l'hai ancora cominciato"
	elif idle > 1800.0:
		note = "non lo curi da %d minuti di gioco" % int(idle / 60.0)
	detail.progress(progress(p), pts, note)
	var hint := String(d["hint"])
	detail.callout("Il prossimo passo", hint.substr(0, 1).to_upper() + hint.substr(1))
	var extra := _extra(p)
	if not extra.is_empty():
		detail.text("A che punto sei", "\n".join(extra))
	if m.get("evergreen") != null and g >= MasteryData.GRADES:
		detail.callout("Oltre il grado 10", "%d stelle · una ogni %d punti in più" % [m.evergreen.stars(p),
			roundi(float(MasteryData.PILLARS[p]["hours"]) * 60.0 * Evergreen.STAR_FRAC)], UiPalette.AMBRA)
	var steps := []
	for k in range(1, MasteryData.GRADES + 1):
		var rw := MasteryData.reward(p, k)
		var what := []
		var first_item: Variant = null
		for id in rw.get("items", {}):
			what.append("%s ×%d" % [String(ItemsData.get_item(String(id)).get("name", id)), int(rw["items"][id])])
			if first_item == null:
				first_item = String(id)
		if rw.has("text"):
			what.append(String(rw["text"]))
		steps.append({"num": k, "title": "Grado %d" % k, "text": ", ".join(what),
			"state": "fatto" if k <= g else ("ora" if k == g + 1 else "poi"), "icon": first_item})
	detail.steps("I gradi e i loro premi", steps)


## Le righe dei sistemi che nutrono un pilastro (la bellezza del Giardino, i contratti della rete, i record…).
func _extra(p: String) -> Array:
	var out := []
	if p == "giardino" and m.get("beauty") != null:
		out.append(m.beauty.line())
	if p == "rete" and m.get("contracts") != null:
		out.append(m.contracts.line())
	if p == "pesca" and m.get("angler") != null:
		out.append(m.angler.line())
	if p == "misteri" and m.get("museum") != null:
		out.append(m.museum.line())
	if p == "orto" and m.get("garden") != null:
		out.append(m.garden.line())
	return out.filter(func(s: Variant) -> bool: return String(s).strip_edges() != "")


## La scheda di un pilastro in testo semplice (per le prove e i suggerimenti).
func text_of(p: String) -> String:
	var d: Dictionary = MasteryData.PILLARS[p]
	var t := "%s\n%s\nGrado %d\nIl prossimo passo: %s\n" % [d["name"], d["desc"], ms.grade(p), d["hint"]]
	for ln in _extra(p):
		t += String(ln) + "\n"
	for k in range(1, MasteryData.GRADES + 1):
		t += "%s grado %d\n" % ["✓" if k <= ms.grade(p) else "·", k]
	return t
