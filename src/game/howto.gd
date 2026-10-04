class_name HowTo
extends RefCounted
## «Che cos'è e come si fa» di una richiesta (voce 351): il testo che l'Albero-Madre, la Bacheca e il filo mostrano sotto
## una richiesta non compiuta, perché il giocatore sappia sempre che cosa cercare, come e con quali attrezzi.
## Le parole stanno in `HowToData` (conteggi), `MasteryData.PILLARS` (gradi) e `ItemInfo.how_to_get` (oggetti).
## I collegamenti `[url=cap:…]` li apre chi mostra il testo (`open_link`).


## Il blocco per un'offerta dell'Albero ({"item"|"stat"|"grado", "n", "text", "hint"}). `indent` = spazi davanti.
static func offer_text(m: Node, o: Dictionary, indent := "     ") -> String:
	var t := ""
	if o.has("stat"):
		var d := HowToData.of(String(o["stat"]))
		if d.is_empty():
			return ""
		t += "%s[color=#cfeee4]%s[/color]\n" % [indent, d["what"]]
		for step in d["how"]:
			t += "%s[color=#9fc8c0]› %s[/color]\n" % [indent, step]
		var tl := tools_line(m, d.get("tools", []))
		if tl != "":
			t += "%s[color=#ffd08a]Aiuta:[/color] %s\n" % [indent, tl]
		t += "%s%s\n" % [indent, link(String(d["cap"]))]
	elif o.has("grado"):
		var p: Dictionary = MasteryData.PILLARS.get(String(o["grado"]), {})
		if p.is_empty():
			return ""
		t += "%s[color=#cfeee4]Il pilastro «%s»: %s[/color]\n" % [indent, p["name"], p.get("desc", "")]
		t += "%s[color=#9fc8c0]› Fa salire il grado: %s. Il Libro dei pilastri (%s) dice a che punto sei.[/color]\n" % [indent,
			p.get("hint", ""), Keys.label("pilastri")]
		t += "%s%s\n" % [indent, link("pilastri")]
	elif o.has("item"):
		var id := String(o["item"])
		var how := ItemInfo.how_to_get(id)
		var have := Crafting.have(m.character.bisaccia, id) if m.get("character") != null else 0
		if how != "":
			t += "%s[color=#9fc8c0]› %s: %s.[/color]\n" % [indent, String(ItemsData.get_item(id).get("name", id)), how]
		if have > 0:
			t += "%s[color=#9ff0b8]› Ne hai %d tra Bisaccia e casse vicine: «Offri ciò che hai».[/color]\n" % [indent, have]
	return t


## Il tipo di una richiesta della Bacheca → il conteggio di `HowToData` che la spiega.
const BOARD_STAT := {"firma": "firme", "viaggio": "viaggi", "signore": "signori", "marea": "maree_vinte",
	"centrale": "centrali", "studio": "studiate", "sigillo": "sigilli", "legame": "specie_legate",
	"compagno": "compagno_lvl_max", "stanza": "stanze", "mandria": "addomesticate"}


## Una riga per la carta della Bacheca: dove si trova o come si fa (testo semplice, senza colori).
static func board_text(r: Dictionary) -> String:
	var tipo := String(r.get("tipo", ""))
	var cosa := String(r.get("cosa", ""))
	if tipo in ["caccia", "mandria"] and FamiliesData.FAMILIES.has(cosa):
		var where := _family_where(cosa)
		if tipo == "mandria":
			return "Si trovano: %s. Si addomesticano con il loro cibo, o il Laccio quando sono stremate." % where
		return "Si trovano: %s." % where
	if BOARD_STAT.has(tipo):
		var d := HowToData.of(String(BOARD_STAT[tipo]))
		if not d.is_empty():
			return String(d["how"][0])
	if cosa != "" and not ItemsData.get_item(cosa).is_empty():
		var how := ItemInfo.how_to_get(cosa)
		if how != "":
			return "Si ottiene: %s." % how
	return ""


## Dove vive una famiglia, in breve: strati, biomi, cielo, notte.
static func _family_where(fam: String) -> String:
	var where := {}
	for s in FamiliesData.FAMILIES[fam]["members"]:
		var cd: Dictionary = CreaturesData.CREATURES.get(s, {})
		if cd.has("sky"):
			where["nel cielo"] = true
			continue
		for st in cd.get("strata", []):
			where[String(StrataData.STRATA[int(st)]["name"]).to_lower()] = true
		for b in cd.get("biomes", []):
			where[BiomesData.name_of(String(b))] = true
		if cd.get("night", false):
			where["di notte"] = true
	return ", ".join(where.keys()) if not where.is_empty() else "in luoghi speciali"


## Gli attrezzi che aiutano: il nome, e «ce l'hai» o dove si prende.
static func tools_line(m: Node, ids: Array) -> String:
	var parts := []
	for id in ids:
		var it := ItemsData.get_item(String(id))
		if it.is_empty():
			continue
		var have := m.get("character") != null and Crafting.have(m.character.bisaccia, String(id)) > 0
		var how := "ce l'hai" if have else ItemInfo.how_to_get(String(id))
		parts.append("%s [color=#6a8a84](%s)[/color]" % [it["name"], how if how != "" else "da trovare"])
	return "; ".join(parts)


## Il collegamento all'Enciclopedia.
static func link(cap: String) -> String:
	return "[url=cap:%s][color=#8ef0d8]→ Leggi nell'Enciclopedia[/color][/url]" % cap


## Apre un collegamento `cap:` (dal segnale `meta_clicked` di un RichTextLabel).
static func open_link(m: Node, meta: Variant) -> void:
	var s := str(meta)
	if s.begins_with("cap:") and m.get("encyclopedia") != null:
		m.encyclopedia.open(s)
