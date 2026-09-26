class_name InnestoPanel
extends Control
## Il Banco dell'Innestatrice aperto (voce 47, clic destro sul banco). A sinistra i Semi di mondo e le Fiale nella
## Bisaccia: clic per scegliere i due Semi genitori e fino a due Fiale da fissare. A destra le probabilità del Seme
## figlio (`Genome.odds`: per ogni categoria; i geni mai imparati restano «?»), la mutazione e il costo; «Innesta»
## consuma i genitori, le Fiale e una Linfa antica e mette il figlio nella Bisaccia (`Genome.cross`).

const COST := {"linfa_antica": 1}
const MAX_VIALS := 2

var m: Node2D
var parents: Array[int] = []           # caselle della Bisaccia dei due Semi scelti
var vials: Array[String] = []          # Fiale scelte (id dell'oggetto)
var last_child := {}
var _list: VBoxContainer
var _detail: RichTextLabel
var _go: Button
var _title: Label
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0.01, 0.03, 0.04)
	bg.size = Vector2(1600, 900)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_title = Label.new()
	_title.position = Vector2(120, 40)
	_title.text = "Banco dell'Innestatrice — due Semi di mondo, una Linfa antica, e nasce un Seme nuovo"
	_title.add_theme_font_size_override("font_size", 26)
	_title.add_theme_color_override("font_color", Color("#8ef0d8"))
	add_child(_title)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(120, 110)
	scroll.size = Vector2(620, 720)
	add_child(scroll)
	_list = VBoxContainer.new()
	_list.custom_minimum_size = Vector2(600, 0)
	_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_list)
	_detail = RichTextLabel.new()
	_detail.bbcode_enabled = true
	_detail.position = Vector2(780, 110)
	_detail.size = Vector2(720, 660)
	_detail.add_theme_font_size_override("normal_font_size", 16)
	add_child(_detail)
	_go = Button.new()
	_go.text = "Innesta (una Linfa antica)"
	_go.position = Vector2(780, 790)
	_go.size = Vector2(360, 40)
	ErbarioPanel._frame(_go, Color("#ffb84a"))
	_go.pressed.connect(graft)
	add_child(_go)
	var hint := Label.new()
	hint.text = "Esc per chiudere · clic su un Seme per sceglierlo come genitore, su una Fiala per fissarne il gene"
	hint.position = Vector2(120, 850)
	hint.add_theme_color_override("font_color", Color("#6a8a84"))
	add_child(hint)


func open() -> void:
	parents.clear()
	vials.clear()
	last_child = {}
	visible = true
	refresh()


func _unhandled_input(e: InputEvent) -> void:
	if visible and e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE:
		visible = false
		get_viewport().set_input_as_handled()


func _bag() -> Bisaccia:
	return m.character.bisaccia


func refresh() -> void:
	for c in _list.get_children():
		c.queue_free()
	var b := _bag()
	var head := Label.new()
	head.text = "Semi di mondo"
	head.add_theme_color_override("font_color", Color("#8ef0d8"))
	_list.add_child(head)
	for i in b.slots.size():
		if String(ItemsData.get_item(b.id_at(i)).get("kind", "")) == "seme_mondo":
			var g := b.data_at(i)
			var mark := ("A · " if parents.find(i) == 0 else "B · ") if i in parents else ""
			_row(mark + "%s (vigore %d)" % [Genome.describe(g), Genome.vigor(g) if Genome.vigor(g) > 0 else Genome.local_vigor],
				i in parents, func() -> void: _toggle_parent(i))
	var head2 := Label.new()
	head2.text = "Fiale di gene (fissano quel gene nel figlio)"
	head2.add_theme_color_override("font_color", Color("#8ef0d8"))
	_list.add_child(head2)
	var seen := {}
	for i in b.slots.size():
		var id := b.id_at(i)
		if GenesData.gene_of_vial(id) != "" and not seen.has(id):
			seen[id] = true
			_row("%s ×%d" % [ItemsData.get_item(id)["name"], b.count(id)], id in vials, func() -> void: _toggle_vial(id))
	_show()


func _row(text: String, on: bool, action: Callable) -> void:
	var btn := Button.new()
	btn.text = text
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.custom_minimum_size = Vector2(600, 40)
	btn.add_theme_font_size_override("font_size", 15)
	btn.add_theme_color_override("font_color", Color("#ffd08a") if on else Color("#cfeee4"))
	ErbarioPanel._frame(btn, Color("#ffb84a") if on else Color("#2f7a70"))
	btn.pressed.connect(action)
	_list.add_child(btn)


func _toggle_parent(i: int) -> void:
	if i in parents:
		parents.erase(i)
	elif parents.size() < 2:
		parents.append(i)
	last_child = {}
	refresh()


func _toggle_vial(id: String) -> void:
	if id in vials:
		vials.erase(id)
	elif vials.size() < MAX_VIALS:
		# una Fiala per categoria: la nuova prende il posto di quella della stessa categoria
		var cat := GenesData.cat_of(GenesData.gene_of_vial(id))
		# voce 63: le categorie si aprono con gli stadi dell'Albero-Madre
		if not cat in m.albero.graftable():
			m.hud.toast("L'Albero-Madre non sa ancora innestare i geni di %s: crescerà" % cat)
			return
		for v in vials.duplicate():
			if GenesData.cat_of(GenesData.gene_of_vial(v)) == cat:
				vials.erase(v)
		vials.append(id)
	last_child = {}
	refresh()


func _genomes() -> Array:
	return [_bag().data_at(parents[0]), _bag().data_at(parents[1])]


func _vial_genes() -> Array:
	return vials.map(func(v: String) -> String: return GenesData.gene_of_vial(v))


func _show() -> void:
	var t := ""
	if not last_child.is_empty():
		t += "[font_size=22][color=#ffd08a]È nato un Seme nuovo![/color][/font_size]\n%s\n%s\n" % [Genome.describe(last_child, true),
			Genome.sheet(last_child)]
	if parents.size() < 2:
		t += "[color=#9fc8c0]Scegli due Semi di mondo (%d su 2).[/color]\n" % parents.size()
		_detail.text = t
		_go.disabled = true
		return
	var gs := _genomes()
	var od := Genome.odds(gs[0], gs[1], _vial_genes())
	t += "[color=#8ef0d8]Il Seme figlio[/color] · vigore %d · [color=#6a8a84]le probabilità si leggono per i geni imparati (Genario)[/color]\n" % Genome.child_vigor(gs[0], gs[1])
	for cat in GenesData.CATEGORIES:
		if not od.has(cat):
			continue
		var parts := []
		# le probabilità si leggono solo per i geni imparati (la superficie è scritta sul Seme); di quelli visti si sa il
		# nome, degli altri nulla
		var sure := true
		for e in od[cat]:
			var g := String(e[0])
			if g != "" and cat != "superficie" and Genome.state(g) < 2:
				sure = false
		for e in od[cat]:
			var g := String(e[0])
			var st := 2 if cat == "superficie" else Genome.state(g)
			var name := "nessuno" if g == "" else (GenesData.tag(g) if st >= 1 else "[color=#6a8a84]?[/color]")
			parts.append("%s %s" % [name, ("%d%%" % roundi(float(e[1]) * 100.0)) if sure else "[color=#6a8a84]?%[/color]"])
		t += "[color=%s]%s[/color]: %s\n" % [GenesData.CAT_INFO[cat]["color"], GenesData.CAT_INFO[cat]["name"], " · ".join(parts)]
	var mc := Genome.mutation_chance(gs[0], gs[1])
	t += "\n[color=#d890ff]Mutazione: %d%%[/color]%s\n" % [roundi(float(mc[0]) * 100.0),
		(" — i genitori portano una [b]combinazione[/b]: %s" % (GenesData.tag(String(mc[1])) if Genome.state(String(mc[1])) >= 2 else "un gene che non conosci"))
		if String(mc[1]) != "" else ""]
	var have := _bag().count("linfa_antica")
	t += "[color=#9fc8c0]Costo: una Linfa antica (ne hai %d), i due Semi e le Fiale scelte.[/color]" % have
	_go.disabled = have < int(COST["linfa_antica"])
	_detail.text = t


## Innesta i due Semi scelti. Vero se è nato un Seme.
func graft() -> bool:
	if parents.size() < 2 or _bag().count("linfa_antica") < int(COST["linfa_antica"]):
		return false
	var gs := _genomes()
	var child := Genome.cross(gs[0], gs[1], _vial_genes(), _rng)
	var b := _bag()
	# prima le caselle dei genitori (dalla più alta: gli indici restano validi), poi Fiale e Linfa
	var idx := parents.duplicate()
	idx.sort()
	idx.reverse()
	for i in idx:
		b.take_one(i)
	for v in vials:
		b.remove(v, 1)
	b.remove("linfa_antica", int(COST["linfa_antica"]))
	for g in Genome.genes(child):
		if Genome.state(String(g)) == 0:
			Genome.known[String(g)] = 1
	if b.add_stack({"id": Genome.item_of(child), "n": 1, "dati": child}) > 0:
		m.drops.spawn(Genome.item_of(child), 1, m.player.position, child)
	m.objectives.bump("innesti")
	if child.has("mutato"):
		m.objectives.bump("mutazioni")
	m.sfx.play("crea")
	parents.clear()
	vials.clear()
	last_child = child
	refresh()
	return true
