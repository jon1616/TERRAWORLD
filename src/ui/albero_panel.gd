class_name AlberoPanel
extends Control
## Il pannello dell'Albero-Madre (voce 63; si apre con il clic destro sull'Albero nel Giardino): a sinistra gli stadi
## (fatti, quello di adesso, quelli che verranno), a destra lo stadio di adesso con le parole dell'Albero, le offerte con
## quanto manca e dove cercarle, i doni che darà, e i bottoni «Offri» (porta tutto ciò che hai, anche dalle casse
## vicine) e «Risveglia» (quando c'è tutto).

var m: Node2D
var am: AlberoMadre
var _stages: VBoxContainer
var _body: RichTextLabel
var _offer: Button
var _wake: Button
var _title: Label
var _dirty := true


func setup(main: Node2D, a: AlberoMadre) -> void:
	m = main
	am = a
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0.01, 0.03, 0.04, 0.97)
	bg.size = Vector2(1600, 900)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_title = Label.new()
	_title.position = Vector2(120, 40)
	_title.add_theme_font_size_override("font_size", 30)
	_title.add_theme_color_override("font_color", Color("#8ef0d8"))
	add_child(_title)
	_stages = VBoxContainer.new()
	_stages.position = Vector2(120, 100)
	_stages.add_theme_constant_override("separation", 4)
	add_child(_stages)
	_body = RichTextLabel.new()
	_body.bbcode_enabled = true
	_body.position = Vector2(560, 100)
	_body.size = Vector2(920, 620)
	_body.add_theme_font_size_override("normal_font_size", 17)
	add_child(_body)
	_offer = Button.new()
	_offer.text = "Offri ciò che hai"
	_offer.position = Vector2(560, 740)
	_offer.size = Vector2(240, 44)
	_offer.focus_mode = Control.FOCUS_NONE
	ErbarioPanel._frame(_offer, Color("#2f7a70"))
	_offer.pressed.connect(func() -> void:
		var n := am.offer()
		m.hud.toast("Hai offerto %d oggetti all'Albero-Madre" % n if n > 0 else "Non hai niente di ciò che chiede adesso")
		_dirty = true)
	add_child(_offer)
	_wake = Button.new()
	_wake.text = "Risveglia l'Albero"
	_wake.position = Vector2(820, 740)
	_wake.size = Vector2(240, 44)
	_wake.focus_mode = Control.FOCUS_NONE
	ErbarioPanel._frame(_wake, Color("#ffb84a"))
	_wake.pressed.connect(func() -> void:
		if am.awaken():
			visible = false
		_dirty = true)
	add_child(_wake)
	var hint := Label.new()
	hint.text = "Esc per chiudere · le offerte si portano anche a più riprese · la riga in alto a sinistra ricorda sempre che cosa chiede l'Albero"
	hint.position = Vector2(120, 850)
	hint.add_theme_color_override("font_color", Color("#6a8a84"))
	add_child(hint)


func open() -> void:
	visible = true
	_dirty = true


func _unhandled_input(e: InputEvent) -> void:
	if visible and e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE:
		visible = false
		get_viewport().set_input_as_handled()


func _process(_dt: float) -> void:
	if visible and _dirty:
		_dirty = false
		_refresh()


func _refresh() -> void:
	var s := am.stage()
	var n := MotherTreeData.STAGES.size()
	var act := MotherTreeData.act_of(mini(s, n - 1))
	_title.text = "L'Albero-Madre — Atto %s «%s» — stadio %d su %d" % [["I", "II", "III"][act], MotherTreeData.ACTS[act]["name"], s, n]
	for c in _stages.get_children():
		c.queue_free()
	for i in n:
		if MotherTreeData.act_of(i) != act:
			continue                                  # Roadmap 21: si vedono gli stadi dell'atto di adesso
		var l := Label.new()
		var st: Dictionary = MotherTreeData.STAGES[i]
		l.text = ("✓ " if i < s else ("▶ " if i == s else "   ")) + String(st["name"])
		l.add_theme_font_size_override("font_size", 18 if i == s else 16)
		l.add_theme_color_override("font_color", Color("#8ef0d8") if i < s else (Color("#ffb84a") if i == s else Color("#4a6a64")))
		_stages.add_child(l)
	if am.done():
		_body.text = "[font_size=24][color=#ffd08a]L'Albero-Madre è sveglio.[/color][/font_size]\n\n[color=#cfeee4]Ti guarda con occhi d'ambra. Il Giardino respira con lui, e ogni Seme che lascia cadere porta un mondo un po' più vivo.[/color]"
		_offer.visible = false
		_wake.visible = false
		return
	var st: Dictionary = am.current()
	var t := "[font_size=24][color=#ffd08a]%s[/color][/font_size]\n[i][color=#cfeee4]«%s»[/color][/i]\n\n" % [st["name"], st["say"]]
	t += "[color=#8ef0d8]Chiede:[/color]\n"
	var offers: Array = st["offers"]
	for i in offers.size():
		var o: Dictionary = am.offer_of(i)
		var p := am.progress(i)
		var ok := int(p[0]) >= int(p[1])
		var what := String(o["text"]) if o.has("text") else String(ItemsData.get_item(String(o["item"]))["name"])
		var extra := ""
		if o.has("item") and not ok:
			var have := Crafting.have(m.character.bisaccia, String(o["item"]))
			extra = "  [color=#9ff0b8](ne hai %d)[/color]" % have if have > 0 else ""
		t += "  %s [color=%s]%s  %d/%d[/color]%s\n" % ["✓" if ok else "•", "#9ff0b8" if ok else "#ffffff", what, int(p[0]), int(p[1]), extra]
		if not ok:
			t += "     [color=#6a8a84]%s[/color]\n" % o["hint"]
		if (offers[i] as Dictionary).has("any"):               # voce 217: le altre strade
			for j in (offers[i]["any"] as Array).size():
				if j == am.alt(i):
					continue
				var oa: Dictionary = offers[i]["any"][j]
				var wa := String(oa["text"]) if oa.has("text") else String(ItemsData.get_item(String(oa["item"]))["name"])
				var pa := am._progress_of(i, j)
				t += "     [color=#b8a0d8]oppure[/color] [color=#cfeee4]%s  %d/%d[/color]\n" % [wa, int(pa[0]), int(pa[1])]
	var gv: Dictionary = st["gives"]
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
	t += "\n[color=#8ef0d8]Dona:[/color]\n"
	for g in gifts:
		t += "  • [color=#cfeee4]%s[/color]\n" % g
	_body.text = t
	_offer.visible = true
	_wake.visible = true
	_wake.disabled = not am.ready_to_wake()
	_offer.disabled = not m.giardino.active
	if not m.giardino.active:
		_body.text += "\n[color=#ffb84a]Le offerte si portano all'Albero, nel Giardino.[/color]"
