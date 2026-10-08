class_name AtlasPanel
extends UiPage
## L'Atlante (Roadmap 23; tasto «atlante», O). Rifatto nella Roadmap 55 «Il volto chiaro»: le schede in alto (i mondi,
## i biomi, le meraviglie, le spedizioni); a sinistra l'elenco a schedine con quanto è completo, a destra la voce scelta.
## Ogni scheda è una coppia di funzioni `_rows_<scheda>` (elenco di [chiave, titolo, sotto, 0..1, colore]) e
## `_text_<scheda>` (il testo, impaginato da `UiDetail.bbcode`).

const TABS := [["mondi", "I mondi"], ["biomi", "I biomi"], ["meraviglie", "Le meraviglie"], ["spedizioni", "Le spedizioni"]]
const SEA := Color("#5cf0e0")

var at: Atlas
var tab_id := "mondi"
var sel := ""
var _rows: Array = []


func setup(main: Node2D, atlas: Atlas) -> void:
	m = main
	at = atlas
	key_action = "atlante"
	visible = false
	build_page("L'Atlante", "I mondi che hai visto, le pagine dei biomi, le meraviglie e le spedizioni del Cartografo.",
		ArtLib.tex("interfaccia", "pannello_atlante") if ArtLib.has("interfaccia", "pannello_atlante") else null, SEA)
	set_tabs(TABS.map(func(t: Array) -> String: return String(t[1])), 0)
	tab_changed.connect(func(i: int) -> void: pick_tab(String(TABS[i][0])))
	set_hints([[Keys.label("atlante"), "apri e chiudi"], ["Clic", "scegli"], ["Rotella", "scorri l'elenco"]])
	split()
	list.chosen.connect(func(id: String) -> void:
		sel = id
		detail_top()
		mark_dirty())


func on_open() -> void:
	if at.here():
		at.check()
		if tab_id == "mondi":
			sel = m.world_id


func pick_tab(id: String) -> void:
	tab_id = id
	sel = ""
	for i in TABS.size():
		if String(TABS[i][0]) == id and tab != i:
			choose_tab(i)
	detail_top()
	mark_dirty()


func refresh() -> void:
	_rows = call("_rows_" + tab_id)
	if sel == "" and not _rows.is_empty():
		sel = String(_rows[0][0])
	var items := []
	for r in _rows:
		items.append({"id": String(r[0]), "title": String(r[1]), "badge": String(r[2]), "frac": float(r[3]), "color": r[4],
			"dim": float(r[3]) <= 0.0})
	list.row_h = 58.0
	list.set_items(items, sel)
	set_chips([["%d stelle" % at.total(), Color("#ffd24a")], ["%d pagine complete" % at.pages.done_count(), Color("#8ef0a0")],
		["%d meraviglie" % Wonders.kinds_seen(m.character.stats), Color("#c8a8ff")]])
	detail.reset(SEA, detail_w())
	if sel == "":
		detail.empty(null, "Qui non c'è ancora niente", "Esplora i mondi nati dai Semi: l'Atlante si riempie da solo.")
		return
	detail.bbcode(String(call("_text_" + tab_id, sel)))


# --- la scheda dei mondi (voce 235) ---

func _rows_mondi() -> Array:
	var out := []
	for wid in at.data():
		var e: Dictionary = at.data()[wid]
		var n := (e.get("stelle", {}) as Dictionary).size()
		out.append([String(wid), String(e.get("nome", wid)), "★ %d/%d" % [n, AtlasData.STARS.size()],
			float(n) / AtlasData.STARS.size(), Color("#ffd24a") if n >= AtlasData.STARS.size() else Color("#5cf0e0")])
	out.sort_custom(func(a: Array, b: Array) -> bool: return String(a[1]) < String(b[1]))
	return out


func _text_mondi(wid: String) -> String:
	var e: Dictionary = at.entry(wid)
	if e.is_empty():
		return ""
	var t := "[font_size=26][color=#5cf0e0]%s[/color][/font_size]\n" % e.get("nome", wid)
	t += "Vigore %d" % int(e.get("vigore", 1))
	if wid == m.world_id:
		t += " · [color=#ffd24a]sei qui[/color]"
	t += "\n"
	var genes: Array = e.get("geni", [])
	if not genes.is_empty():
		var names := []
		for g in genes:
			names.append(String(GenesData.GENES.get(String(g), {}).get("name", g)))
		t += "Geni: %s\n" % ", ".join(names)
	t += "\n[b]Le stelle[/b] (%d in tutto l'Atlante; ogni %d un premio)\n" % [at.total(), AtlasData.EVERY]
	var st: Dictionary = e.get("stelle", {})
	for s in AtlasData.STARS:
		var id := String(s[0])
		var done := st.has(id)
		t += "%s [color=%s]%s[/color] — %s\n" % ["★" if done else "☆", "#ffd24a" if done else "#9a8aa4", s[1], AtlasData.star_desc(id)]
	if wid == m.world_id:
		t += "\n[color=#9a8aa4]Mappa scoperta: %.1f%% · Sigilli aperti: %d su %d · Segreti: %d su %d[/color]\n" % [
			at.map_frac() * 100.0, int(m.world_meta.get("sigilli_aperti", 0)), (m.world_meta.get("sigilli", []) as Array).size(),
			int(Secrets.counts_of(m.world_meta)[0]), int(Secrets.counts_of(m.world_meta)[1])]
	return t


# --- la scheda dei biomi (voce 236) ---

func _rows_biomi() -> Array:
	var out := []
	for p in BiomePagesData.pages():
		var pr := at.pages.progress(p)
		var done: bool = at.pages.done(p)
		var col: Color = {"sup": Color("#8ef0a0"), "sot": Color("#e0a060"), "cie": Color("#9ad0ff")}[String(p["kind"])]
		out.append([String(p["id"]), String(p["name"]), "%d/%d" % [int(pr[0]), int(pr[1])],
			float(pr[0]) / maxf(float(pr[1]), 1.0), Color("#ffd24a") if done else col])
	return out


func _text_biomi(id: String) -> String:
	var p := BiomePagesData.page(id)
	if p.is_empty():
		return ""
	return at.pages.text_of(p) + "\n\n[color=#6a7a84]Pagine complete: %d su %d[/color]" % [at.pages.done_count(), BiomePagesData.pages().size()]


# --- la scheda delle meraviglie (voce 237) ---

func _rows_meraviglie() -> Array:
	var out := []
	for k in WondersData.WONDERS:
		var seen := int(m.character.stats.get("mer_" + String(k), 0)) == 1
		var d: Dictionary = WondersData.WONDERS[k]
		var got: bool = m.character.bisaccia.count(WondersData.memento_id(String(k))) > 0 or \
			(m.character.erbario.get("oggetti", {}) as Dictionary).has(WondersData.memento_id(String(k)))
		out.append([String(k), String(d["name"]) if seen else "???", "ricordo ✓" if got else ("vista" if seen else ""),
			1.0 if got else (0.5 if seen else 0.0), Color("#ffd24a") if got else Color("#c8a8ff")])
	return out


func _text_meraviglie(k: String) -> String:
	var d: Dictionary = WondersData.WONDERS.get(k, {})
	if d.is_empty():
		return ""
	var seen := int(m.character.stats.get("mer_" + k, 0)) == 1
	var where := "sulla superficie" if str(d["where"]) == "sup" else "nello strato «%s»" % StrataData.STRATA[int(d["where"])]["name"]
	var t := "[font_size=26][color=#c8a8ff]%s[/color][/font_size]\n" % (d["name"] if seen else "Una meraviglia che non hai ancora visto")
	if seen:
		t += "%s\n" % d["desc"]
	t += "Nasce %s%s.\n" % [where, "; è rara" if int(d["weight"]) <= 1 else ""]
	var gn := []
	for g in d.get("genes", []):
		gn.append(String(GenesData.GENES.get(String(g), {}).get("name", g)) if int(m.character.genario.get(String(g), 0)) > 0 else "?")
	t += "La chiamano più spesso i geni: %s\n" % ", ".join(gn)
	var mm: Array = d["memento"]
	t += "\nNel suo cuore: [b]%s[/b] (%s)\n" % [mm[0] if seen else "???", "un ricordo che esiste solo lì" if not seen else mm[3]]
	if at.here():
		var here := []
		for e in at.wonders.list():
			here.append("%s%s" % [WondersData.WONDERS[String(e["k"])]["name"] if e.get("vista", false) else "una meraviglia non ancora vista",
				" (ricordo preso)" if e.get("preso", false) else ""])
		t += "\n[b]In questo mondo[/b]: %s\n" % (", ".join(here) if not here.is_empty() else "nessuna")
	t += "\n[color=#6a7a84]Tipi visti: %d su %d · con i ricordi, al Maglio: il Mappamondo dei Seminatori e la Bussola del cosmo[/color]" % [
		Wonders.kinds_seen(m.character.stats), WondersData.WONDERS.size()]
	return t


# --- la scheda delle spedizioni (voce 238) ---

func _rows_spedizioni() -> Array:
	at.expeditions.fill()
	var out := []
	var list: Array = at.expeditions.open_list()
	for i in list.size():
		var e: Dictionary = list[i]
		var p: Array = at.expeditions.progress(e)
		out.append([str(i), at.expeditions.title(e), "%d/%d" % [int(p[0]), int(p[1])], float(p[0]) / maxf(float(p[1]), 1.0),
			Color("#ffb84a")])
	return out


func _text_spedizioni(key: String) -> String:
	var list: Array = at.expeditions.open_list()
	var i := int(key)
	if i < 0 or i >= list.size():
		return ""
	var e: Dictionary = list[i]
	var d: Dictionary = ExpeditionsData.KINDS[String(e["k"])]
	var p: Array = at.expeditions.progress(e)
	var t := "[font_size=26][color=#ffb84a]%s[/color][/font_size]\n" % at.expeditions.title(e)
	t += "Il Cartografo ti propone questa spedizione. A che punto sei: %d su %d\n\n" % [int(p[0]), int(p[1])]
	t += "[b]Dove cercare[/b]: %s\n" % d["hint"]
	if String(e["k"]) == "meraviglia":
		var gn := []
		for g in WondersData.WONDERS[String(e["t"])]["genes"]:
			gn.append(String(GenesData.GENES.get(String(g), {}).get("name", g)))
		t += "La chiamano più spesso i geni: %s\n" % ", ".join(gn)
	var parts := []
	for it in d["reward"]:
		parts.append("%s ×%d" % [String(ItemsData.get_item(String(it)).get("name", it)), int(d["reward"][it])])
	if d.get("seed", false):
		var gene := String(e.get("gene", ""))
		parts.append("un Seme di mondo" + (" con il gene «%s»" % GenesData.GENES[gene]["name"] if GenesData.GENES.has(gene) else " con un gene raro"))
	t += "\n[b]Premio[/b]: %s\n" % ", ".join(parts)
	t += "\n[color=#6a7a84]Spedizioni compiute: %d · finita una, se ne apre un'altra[/color]" % int(at.expeditions.data().get("fatte", 0))
	return t
