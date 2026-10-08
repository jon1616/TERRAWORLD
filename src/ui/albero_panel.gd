class_name AlberoPanel
extends UiPage
## Il pannello dell'Albero-Madre (voce 63; si apre con il clic destro sull'Albero nel Giardino). Rifatto nella Roadmap
## 55 «Il volto chiaro»: a sinistra gli stadi dell'atto come strada a tappe; a destra lo stadio di adesso: le parole
## dell'Albero, le offerte come schede (icona, quanto ne hai portato, la barra, dove cercarle, come si fa, le altre strade),
## i doni che darà; sotto i bottoni «Offri ciò che hai» (anche dalle casse vicine) e «Risveglia l'Albero».

const TREE := Color("#8ef0d8")
const STAGES_W := 380.0

var am: AlberoMadre
var _stages: UiTimeline
var _stages_scroll: ScrollContainer
var _offer: Button
var _wake: Button
var _body: UiDetail
var _scroll: ScrollContainer


func setup(main: Node2D, a: AlberoMadre) -> void:
	m = main
	am = a
	visible = false
	build_page("L'Albero-Madre", "", ItemIcons.make_ui("seme", "sem"), TREE)
	set_hints([["Clic destro", "sull'Albero: apri"], ["Offri", "porta tutto ciò che hai, anche dalle casse vicine"]])
	var r := body_rect()
	_stages_scroll = ScrollContainer.new()
	_stages_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_stages_scroll.size = Vector2(STAGES_W, r.size.y)
	body.add_child(_stages_scroll)
	_stages = UiTimeline.new()
	_stages.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_stages_scroll.add_child(_stages)
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.position = Vector2(STAGES_W + 40.0, 0)
	_scroll.size = Vector2(r.size.x - STAGES_W - 40.0, r.size.y - 64.0)
	body.add_child(_scroll)
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_right", 22)
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(pad)
	_body = UiDetail.new()
	pad.add_child(_body)
	var bar := UiKit.row(14)
	bar.position = Vector2(STAGES_W + 40.0, r.size.y - 48.0)
	bar.size = Vector2(r.size.x - STAGES_W - 40.0, 46)
	body.add_child(bar)
	_offer = Button.new()
	_offer.text = "Offri ciò che hai"
	_offer.custom_minimum_size = Vector2(240, 44)
	_offer.focus_mode = Control.FOCUS_NONE
	UiFrames.button(_offer, TREE)
	_offer.pressed.connect(func() -> void:
		var n := am.offer()
		m.hud.toast("Hai offerto %d oggetti all'Albero-Madre" % n if n > 0 else "Non hai niente di ciò che chiede adesso")
		mark_dirty())
	bar.add_child(_offer)
	_wake = Button.new()
	_wake.text = "Risveglia l'Albero"
	_wake.custom_minimum_size = Vector2(240, 44)
	_wake.focus_mode = Control.FOCUS_NONE
	UiFrames.button(_wake, Color(0, 0, 0, 0), false, "principale")
	_wake.pressed.connect(func() -> void:
		if am.awaken():
			visible = false
		mark_dirty())
	bar.add_child(_wake)


func _unhandled_input(e: InputEvent) -> void:
	if visible and e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE:
		visible = false
		get_viewport().set_input_as_handled()


## Un testo con i collegamenti all'Enciclopedia (voce 351): un clic chiude il pannello e apre la pagina.
func _linked(bb: String, w: float) -> RichTextLabel:
	var rt := UiKit.rich(bb, w)
	rt.mouse_filter = Control.MOUSE_FILTER_PASS
	rt.meta_clicked.connect(func(meta: Variant) -> void:
		visible = false
		HowTo.open_link(m, meta))
	return rt


func refresh() -> void:
	var s := am.stage()
	var n := MotherTreeData.STAGES.size()
	var act := MotherTreeData.act_of(mini(s, n - 1))
	page_sub.text = "Atto %s «%s» · stadio %d di %d" % [["I", "II", "III"][act], MotherTreeData.ACTS[act]["name"], mini(s + 1, n), n]
	set_chips([["Atto %s" % ["I", "II", "III"][act], UiPalette.AMBRA], ["%d stadi compiuti" % s, TREE]])
	var steps := []
	for i in n:
		if MotherTreeData.act_of(i) != act:
			continue                                  # Roadmap 21: si vedono gli stadi dell'atto di adesso
		var st0: Dictionary = MotherTreeData.STAGES[i]
		steps.append({"num": i + 1, "title": String(st0["name"]), "state": "fatto" if i < s else ("ora" if i == s else "poi")})
	_stages.set_steps(steps, TREE, STAGES_W - 30.0)
	var w := _scroll.size.x - 40.0
	_body.reset(TREE, w)
	if am.done():
		_body.head("L'Albero-Madre è sveglio", "", ItemIcons.make_ui("seme", "sem"))
		_body.text("", "[i]Ti guarda con occhi d'ambra. Il Giardino respira con lui, e ogni Seme che lascia cadere porta un mondo un po' più vivo.[/i]")
		_offer.visible = false
		_wake.visible = false
		return
	var st: Dictionary = am.current()
	_body.head(String(st["name"]), "", ItemIcons.make_ui("seme", "sem"), str(s + 1), "stadio")
	var q := UiKit.label("«%s»" % st["say"], UiPalette.GRANDE, Color("#d8eee4"), "racconto")
	q.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	q.custom_minimum_size = Vector2(w, 0)
	_body.add_child(q)
	if not m.giardino.active:
		_body.callout("Lontano dall'Albero", "Le offerte si portano all'Albero, nel Giardino.", UiPalette.AMBRA)
	var asks := _body.section("Chiede")
	var offers: Array = st["offers"]
	for i in offers.size():
		asks.add_child(_offer_card(i, offers[i], w))
	var gifts := _gifts(st["gives"])
	var rows := []
	for g in gifts:
		rows.append(["fatto", g])
	_body.checklist("Quando si risveglia, dona", rows)
	_offer.visible = true
	_wake.visible = true
	_wake.disabled = not am.ready_to_wake()
	_offer.disabled = not m.giardino.active


## Una scheda per offerta: icona, nome, quanto ne hai portato, la barra, dove cercare, come si fa, le altre strade.
func _offer_card(i: int, raw: Dictionary, w: float) -> Control:
	var o: Dictionary = am.offer_of(i)
	var p := am.progress(i)
	var ok := int(p[0]) >= int(p[1])
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", UiFrames.box("sezione", "normale", Color(UiPalette.BUONO if ok else TREE, 0.35)))
	pc.custom_minimum_size = Vector2(w, 0)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	pc.add_child(vb)
	var top := UiKit.row(10)
	if o.has("item"):
		top.add_child(UiKit.icon_rect(String(o["item"]), 34))
	var what := String(o["text"]) if o.has("text") else String(ItemsData.get_item(String(o["item"]))["name"])
	var nm := UiKit.label(what, UiPalette.GRANDE, UiPalette.TESTO, "forte")
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nm.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(nm)
	if o.has("item") and not ok:
		var have := Crafting.have(m.character.bisaccia, String(o["item"]))
		if have > 0:
			top.add_child(UiKit.chip("ne hai %d" % have, UiPalette.BUONO))
	var cnt := UiKit.label("%d / %d" % [int(p[0]), int(p[1])], UiPalette.GRANDE, UiPalette.BUONO if ok else UiPalette.AMBRA_CHIARA, "numeri")
	cnt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(cnt)
	vb.add_child(top)
	vb.add_child(UiKit.bar(float(p[0]) / maxf(float(p[1]), 1.0), UiPalette.BUONO if ok else TREE, w - 30.0, 7.0))
	if not ok:
		vb.add_child(UiKit.para(String(o["hint"]), w - 30.0, UiPalette.TESTO_PX - 1, UiPalette.TESTO_SPENTO))
		var how := HowTo.offer_text(m, o).strip_edges()        # (voce 351) che cos'è, come si fa, che cosa aiuta
		if how != "":
			vb.add_child(_linked(how, w - 30.0))
	if raw.has("any"):                                         # voce 217: le altre strade
		for j in (raw["any"] as Array).size():
			if j == am.alt(i):
				continue
			var oa: Dictionary = raw["any"][j]
			var wa := String(oa["text"]) if oa.has("text") else String(ItemsData.get_item(String(oa["item"]))["name"])
			var pa := am._progress_of(i, j)
			var alt := UiKit.row(8)
			alt.add_child(UiKit.chip("oppure", Color("#b8a0d8")))
			alt.add_child(UiKit.label("%s  %d/%d" % [wa, int(pa[0]), int(pa[1])], UiPalette.TESTO_PX, UiPalette.TESTO, "chiaro"))
			vb.add_child(alt)
			if not ok and int(pa[0]) < int(pa[1]):
				var how2 := HowTo.offer_text(m, oa, "").strip_edges()
				if how2 != "":
					vb.add_child(_linked(how2, w - 30.0))
	return pc


func _gifts(gv: Dictionary) -> Array:
	var gifts := []
	if gv.has("aiuola"):
		gifts.append("un'Aiuola in più nel Giardino")
	if gv.has("power"):
		var pw: Dictionary = PowersData.POWERS[gv["power"]]
		gifts.append("il potere %s[color=#ffd24a]«%s»[/color]: %s" % [ArtLib.bb("interfaccia", "potere_" + String(gv["power"])),
			pw["name"], pw["desc"]])
	if gv.has("npc"):
		gifts.append("arriva al Giardino %s" % NpcData.name_of(String(gv["npc"])))
	if gv.has("graft"):
		gifts.append("il Banco dell'Innestatrice sa innestare i geni di %s" % ", ".join(gv["graft"]))
	if gv.has("seed"):
		gifts.append("un Seme del cosmo: la strada per %s" % LostGardensData.name_of(String(gv["seed"])))
	if gv.has("items"):
		var names := []
		for id in gv["items"]:
			names.append("%s ×%d" % [String(ItemsData.get_item(String(id)).get("name", id)), int(gv["items"][id])])
		gifts.append("il corredo della rete: %s" % ", ".join(names))
	if gv.has("phase"):
		gifts.append("l'Albero cresce")
	return gifts
