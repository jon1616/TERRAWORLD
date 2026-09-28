class_name EncyPages
extends RefCounted
## Le pagine dell'Enciclopedia (27 set 2026): i capitoli scritti (`EncyGuideData`, `EncyCraftData`, `EncySeedsData`)
## con i numeri e i cataloghi in linea riempiti dai dati del gioco, i cataloghi completi (oggetti, creature, geni,
## materiali, forme, tratti, stazioni) e le schede delle singole voci. Tutto nasce dai dati: un contenuto nuovo
## compare da solo.
## Ciò che il personaggio non ha ancora scoperto resta «???» (`show_all` lo mostra: «anticipazioni»).
## Indirizzi: "cap:id", "cat:id" (o "cat:oggetti:categoria"), "item:id", "cr:id", "gene:id".

const ALIAS := {"erbario": "obiettivi"}
const CATALOGS := [["oggetti", "Oggetti"], ["creature", "Creature"], ["famiglie", "Famiglie"], ["geni", "Geni"],
	["materiali", "Materiali"], ["forme", "Forme"], ["tratti", "Tratti"], ["stazioni", "Banchi e stazioni"],
	["obiettivi_elenco", "Obiettivi"], ["glossario", "Glossario dei Seminatori"]]

static var ch: Character                 # il personaggio (null nel menu: tutto da scoprire)
static var show_all := false
static var _re: RegEx


static func chapters() -> Array:
	var out := []
	out.append_array(EncyGuideData.CHAPTERS)
	out.append_array(EncyCraftData.CHAPTERS)
	out.append_array(EncySeedsData.CHAPTERS)
	out.append_array(EncyStoryData.CHAPTERS)
	out.append_array(EncyLawsData.CHAPTERS)
	out.append_array(EncyWorldData.CHAPTERS)           # Roadmap 15: il mondo abitato
	out.append_array(EncySkyData.CHAPTERS)             # Roadmap 16: le Chiome del cielo
	return out


static func chapter(id: String) -> Dictionary:
	id = String(ALIAS.get(id, id))
	for c in chapters():
		if String(c["id"]) == id:
			return c
	return {}


## Una pagina per indirizzo: [titolo, testo BBCode, icona (id di un oggetto o "")].
static func page(addr: String) -> Array:
	var kind := addr.get_slice(":", 0)
	var id := addr.substr(kind.length() + 1)
	match kind:
		"cap":
			var c := chapter(id)
			if c.is_empty():
				return ["?", "Pagina non trovata.", ""]
			return [String(c["name"]), fill(String(c["text"])), ""]
		"cat":
			return EncyCatalogs.catalog(id)
		"item":
			return [String(ItemsData.get_item(id).get("name", id)), EncyCatalogs.item_page(id), id]
		"cr":
			return [String(CreaturesData.get_data(id).get("name", id)), EncyCatalogs.creature_page(id), ""]
		"gene":
			return [String(GenesData.GENES.get(id, {}).get("name", id)), EncyCatalogs.gene_page(id), ""]
	return ["?", "", ""]


## Riempie {numero} e {cat_…} con i dati di adesso.
static func fill(text: String) -> String:
	if _re == null:
		_re = RegEx.create_from_string("\\{([a-z_0-9]+)\\}")
	var nums := numbers()
	var out := text
	for mt in _re.search_all(text):
		var key := mt.get_string(1)
		var val := ""
		if nums.has(key):
			val = str(nums[key])
		elif key.begins_with("k_"):
			val = "[b]%s[/b]" % Keys.labels(key.substr(2))
		else:
			val = EncyCatalogs.inline(key)
		out = out.replace("{%s}" % key, val)
	return out


static func numbers() -> Dictionary:
	return {"hp": Vitals.HP_MAX, "linfa": Vitals.LINFA_MAX, "regen_delay": roundi(Vitals.REGEN_DELAY),
		"regen": ItemTip.num(Vitals.REGEN, 1), "linfa_regen": ItemTip.num(Vitals.LINFA_REGEN, 1),
		"potion_cd": roundi(Vitals.POTION_COOLDOWN), "fall_safe": roundi(Life.FALL_SAFE), "fall_hurt": Life.FALL_HURT,
		"bag": 40, "min_specchio": roundi(WaterBody.MIN_VOLUME), "day_min": roundi(DayCycle.DAY / 60.0), "season_days": SeasonsData.DAYS, "chest_reach": 10,
		"craft_reach": 5, "max_slots": TraitsData.MAX_SLOTS, "weak": ItemTip.num(ElementsData.WEAK, 1),
		"resist": ItemTip.num(ElementsData.RESIST, 1), "vigor_pct": roundi(VigorData.CREATURE_STEP * 100.0),
		"vigor_pct2": roundi(VigorData.CREATURE_STEP_HIGH * 100.0), "vigor_soft": VigorData.CREATURE_SOFT,
		"stages": MotherTreeData.STAGES.size(), "n_obiettivi": ObjectivesData.LIST.size(),
		"farm_zona": FarmData.ZONE, "farm_tetto": FarmData.ZONE_CAP, "farm_minuti": roundi(FarmData.ZONE_TIME / 60.0),
		"n_parole": LanguageData.WORDS.size(), "parole_note": ch.lingua.size() if ch != null else 0}


## Il personaggio conosce già questa cosa? (senza personaggio, nel menu: no)
static func known_item(id: String) -> bool:
	return show_all or (ch != null and (ch.erbario.get("oggetti", {}) as Dictionary).has(id))


static func known_creature(id: String) -> bool:
	return show_all or (ch != null and (ch.erbario.get("creature", {}) as Dictionary).has(id))


static func known_gene(g: String) -> bool:
	return show_all or GenesData.cat_of(g) == "superficie" or (ch != null and Genome.state(g) > 0)


static func link(addr: String, name: String) -> String:
	return "[url=%s]%s[/url]" % [addr, name]


static func item_link(id: String) -> String:
	if not known_item(id):
		return "[color=#5a706c]???[/color]"
	return link("item:" + id, String(ItemsData.get_item(id).get("name", id)))


static func creature_link(id: String) -> String:
	if not known_creature(id):
		return "[color=#5a706c]???[/color]"
	return link("cr:" + id, String(CreaturesData.get_data(id).get("name", id)))


## Tutte le parole che si cercano: [indirizzo, titolo, testo in cui cercare].
static func index() -> Array:
	var out := []
	for c in chapters():
		out.append(["cap:" + String(c["id"]), String(c["name"]), String(c["name"]) + " " + String(c["text"])])
	for k in CATALOGS:
		out.append(["cat:" + String(k[0]), "Catalogo: " + String(k[1]), String(k[1])])
	var items := ItemsData.all()
	for id in items:
		if not (items[id] as Dictionary).get("gen", false) and known_item(String(id)):
			out.append(["item:" + String(id), String(items[id]["name"]), String(items[id]["name"]) + " " + String(items[id].get("desc", ""))])
	for id in CreaturesData.CREATURES:
		if known_creature(String(id)):
			out.append(["cr:" + String(id), String(CreaturesData.CREATURES[id]["name"]), String(CreaturesData.CREATURES[id]["name"])])
	for g in GenesData.GENES:
		if known_gene(String(g)):
			out.append(["gene:" + String(g), String(GenesData.GENES[g]["name"]), String(GenesData.GENES[g]["name"]) + " " + String(GenesData.GENES[g].get("desc", ""))])
	return out


## La ricerca: prima i titoli che cominciano con le parole, poi i titoli che le contengono, poi i testi.
static func search(q: String) -> Array:
	q = q.strip_edges().to_lower()
	if q.length() < 2:
		return []
	var a := []
	var b := []
	var c := []
	for e in index():
		var t := String(e[1]).to_lower()
		if t.begins_with(q):
			a.append(e)
		elif t.contains(q):
			b.append(e)
		elif String(e[2]).to_lower().contains(q):
			c.append(e)
	a.append_array(b)
	a.append_array(c)
	return a.slice(0, 60)
