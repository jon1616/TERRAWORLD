class_name InnestoPanel
extends UiPage
## Il Banco dell'Innestatrice aperto (voce 47, clic destro sul banco; rifatto nella Roadmap 55 «Il volto chiaro»). A
## sinistra i Semi di mondo e le Fiale nella Bisaccia: clic per scegliere i due Semi genitori (A e B) e fino a due Fiale
## da fissare. A destra le probabilità del Seme figlio (`Genome.odds`: per ogni categoria; i geni mai imparati restano
## «?»), la mutazione e il costo; «Innesta» consuma i genitori, le Fiale e una Linfa antica e mette il figlio nella
## Bisaccia (`Genome.cross`).

const COST := {"linfa_antica": 1}
const MAX_VIALS := 2
const GRAFT := Color("#d890ff")

var parents: Array[int] = []           # caselle della Bisaccia dei due Semi scelti
var vials: Array[String] = []          # Fiale scelte (id dell'oggetto)
var last_child := {}
var _go: Button
var _title: Label
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	visible = false
	build_page("Il Banco dell'Innestatrice", "Due Semi di mondo, una Linfa antica, e nasce un Seme nuovo: le Fiale fissano un gene nel figlio.",
		ItemIcons.make_ui("seme", "sem"), GRAFT)
	_title = page_title
	set_hints([["Clic", "su un Seme: genitore A o B"], ["Clic", "su una Fiala: fissa il suo gene"]])
	split(460.0)
	_detail_scroll.size.y -= 56.0
	list.chosen.connect(_on_pick)
	_go = Button.new()
	_go.text = "Innesta (una Linfa antica)"
	_go.position = Vector2(_detail_scroll.position.x, body.size.y - 44.0)
	_go.size = Vector2(340, 42)
	_go.focus_mode = Control.FOCUS_NONE
	UiFrames.button(_go, Color(0, 0, 0, 0), false, "principale")
	_go.pressed.connect(graft)
	body.add_child(_go)


func open() -> void:
	parents.clear()
	vials.clear()
	last_child = {}
	super.open()
	refresh()


func _unhandled_input(e: InputEvent) -> void:
	if visible and e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE:
		visible = false
		get_viewport().set_input_as_handled()


func _bag() -> Bisaccia:
	return m.character.bisaccia


func _on_pick(id: String) -> void:
	if id.begins_with("s:"):
		_toggle_parent(int(id.substr(2)))
	elif id.begins_with("v:"):
		_toggle_vial(id.substr(2))


func refresh() -> void:
	var b := _bag()
	var items := [{"header": true, "title": "Semi di mondo", "color": UiPalette.LINFA}]
	for i in b.slots.size():
		if String(ItemsData.get_item(b.id_at(i)).get("kind", "")) == "seme_mondo":
			var g := b.data_at(i)
			var mark := ("A" if parents.find(i) == 0 else "B") if i in parents else ""
			items.append({"id": "s:%d" % i, "title": Genome.describe(g), "sub": "vigore %d" % (Genome.vigor(g) if Genome.vigor(g) > 0 else Genome.local_vigor),
				"badge": mark, "badge_col": UiPalette.AMBRA, "on": i in parents, "color": UiPalette.LINFA, "icon": b.id_at(i)})
	items.append({"header": true, "title": "Fiale di gene", "color": GRAFT})
	var seen := {}
	for i in b.slots.size():
		var id := b.id_at(i)
		if GenesData.gene_of_vial(id) != "" and not seen.has(id):
			seen[id] = true
			items.append({"id": "v:" + id, "title": String(ItemsData.get_item(id)["name"]), "sub": "fissa il gene nel figlio",
				"badge": "×%d" % b.count(id), "on": id in vials, "color": GRAFT, "icon": id})
	list.row_h = 62.0
	list.set_items(items, "")
	set_chips([["Linfa antica %d" % b.count("linfa_antica"), UiPalette.AMBRA], ["genitori %d/2" % parents.size(), UiPalette.LINFA],
		["Fiale %d/%d" % [vials.size(), MAX_VIALS], GRAFT]])
	_show()


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
	detail.reset(GRAFT, detail_w())
	if not last_child.is_empty():
		detail.callout("È nato un Seme nuovo", Genome.describe(last_child, true), UiPalette.AMBRA)
		detail.text("", Genome.sheet(last_child))
	if parents.size() < 2:
		detail.empty(ItemIcons.make_ui("seme", "sem"), "Scegli due Semi di mondo",
			"Ne hai scelti %d su 2. Clic su un Seme a sinistra: il primo è il genitore A, il secondo il B." % parents.size(),
			[["linfa_antica", "Costa una Linfa antica, i due Semi e le Fiale scelte."]])
		_go.disabled = true
		return
	var gs := _genomes()
	var od := Genome.odds(gs[0], gs[1], _vial_genes())
	detail.head("Il Seme figlio", "Le probabilità si leggono per i geni imparati (Genario); degli altri si sa il nome o nulla.",
		ItemIcons.make_ui("seme", "sem"), str(Genome.child_vigor(gs[0], gs[1])), "vigore")
	var rows := []
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
			var name := "nessuno" if g == "" else (GenesData.tag(g) if st >= 1 else "[color=#71877f]?[/color]")
			parts.append("%s [b]%s[/b]" % [name, ("%d%%" % roundi(float(e[1]) * 100.0)) if sure else "[color=#71877f]?%[/color]"])
		rows.append("[color=%s]%s[/color]   %s" % [GenesData.CAT_INFO[cat]["color"], GenesData.CAT_INFO[cat]["name"], "  ·  ".join(parts)])
	detail.text("I geni del figlio", "\n".join(rows))
	var mc := Genome.mutation_chance(gs[0], gs[1])
	var mut := "%d%% di mutazione" % roundi(float(mc[0]) * 100.0)
	if String(mc[1]) != "":
		mut += " — i genitori portano una [b]combinazione[/b]: %s" % (GenesData.tag(String(mc[1])) if Genome.state(String(mc[1])) >= 2 else "un gene che non conosci")
	detail.callout("La mutazione", mut, GRAFT)
	var have := _bag().count("linfa_antica")
	detail.stats("Il costo", [["Linfa antica", "1 (ne hai %d)" % have, UiPalette.BUONO if have >= 1 else UiPalette.PERICOLO],
		["Semi", "i due genitori"], ["Fiale", "%d scelte" % vials.size()]])
	_go.disabled = have < int(COST["linfa_antica"])


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
