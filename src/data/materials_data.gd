class_name MaterialsData
extends RefCounted
## I materiali dell'equipaggiamento e le loro **proprietà** (voce 49, Roadmap 6 «La materia viva»). Solo dati.
## Gli attrezzi, le armi e le armature di ogni materiale non sono scritti a mano: nascono da forma × materiale
## (`FormsData.item`), e i loro valori vengono dalle proprietà pesate dalla forma. Un materiale nuovo = una riga qui
## (più il suo lingotto): compare con tutta la sua famiglia di oggetti, le ricette e le icone.
##
## Proprietà:
##   tier        grado (0-6): quanto è avanti nel gioco
##   durezza     forza di scavo di picconi e asce (vedi `TileDefs.POWER`)
##   filo        danno di taglio delle armi
##   peso        colpi più lenti, spinta più forte (le mazze ne fanno danno)
##   tenacia     la Scorza delle armature
##   conduzione  quanto porta la Linfa: il danno delle verghe e il loro costo (voce 50)
##   elemento    l'elemento dei colpi (voce 51): "" · brace · gelo · spora · linfa · vuoto · luce
##   risonanza   0-2: posti d'innesto in più (voce 54)
##   label       «di radicite» (label_pl per i nomi al plurale), icon = tavolozza di `ItemIcons`, bar = il lingotto
## I valori dei metalli sono scelti perché le armi e le armature di prima restassero quelle (la prova sta in
## `tools/verifica_dati.gd`).

const MATERIALS := {
	"radicite": {"label": "di radicite", "tier": 1, "durezza": 35, "filo": 9, "peso": 20.0, "tenacia": 1.2, "conduzione": 4,
		"elemento": "", "risonanza": 0, "bar": "lingotto_radicite"},
	"legnoferro": {"label": "di legnoferro", "tier": 2, "durezza": 45, "filo": 12, "peso": 17.5, "tenacia": 2.0, "conduzione": 3,
		"elemento": "", "risonanza": 0, "bar": "lingotto_legnoferro"},
	"ambra": {"label": "d'ambra", "tier": 3, "durezza": 55, "filo": 16, "peso": 15.0, "tenacia": 2.8, "conduzione": 8,
		"elemento": "luce", "risonanza": 1, "bar": "lingotto_ambra"},
	"linfa": {"label": "di Linfa", "tier": 4, "durezza": 65, "filo": 21, "peso": 10.0, "tenacia": 3.8, "conduzione": 14,
		"elemento": "linfa", "risonanza": 1, "bar": "lingotto_linfa", "icon": "cristallo"},
	"vuoto": {"label": "di vuotite forgiata", "tier": 5, "durezza": 75, "filo": 30, "peso": 7.5, "tenacia": 5.0, "conduzione": 10,
		"elemento": "vuoto", "risonanza": 1, "bar": "lingotto_vuoto", "icon": "vuotite"},
	# voce 24: metalli laterali, per chi vuole una strada diversa (più veloce, o più forte prima della Linfa)
	"pallidite": {"label": "di pallidite", "tier": 2, "durezza": 42, "filo": 11, "peso": 7.5, "tenacia": 1.6, "conduzione": 6,
		"elemento": "gelo", "risonanza": 0, "bar": "lingotto_pallidite"},
	"tizzonite": {"label": "di tizzonite", "tier": 3, "durezza": 60, "filo": 18, "peso": 15.0, "tenacia": 3.1, "conduzione": 5,
		"elemento": "brace", "risonanza": 0, "bar": "lingotto_tizzonite"},
	"stellare": {"label": "stellare", "label_pl": "stellari", "tier": 6, "durezza": 85, "filo": 40, "peso": 5.0, "tenacia": 6.0,
		"conduzione": 16, "elemento": "luce", "risonanza": 2, "bar": "lingotto_stellare", "icon": "stelle"},
	# Roadmap 16, voce 159: il metallo del cielo alto. Della forza dell'ambra ma leggerissimo (colpi più svelti), il set
	# intero fa saltare più in alto e protegge dall'aria sottile
	"nimbite": {"label": "di nimbite", "tier": 3, "durezza": 55, "filo": 15, "peso": 4.0, "tenacia": 2.4, "conduzione": 9,
		"elemento": "luce", "risonanza": 1, "bar": "lingotto_nimbite", "icon": "nimbite"},
}

## Voce 52: le **leghe**. Al Baccello ardente un lingotto di due metalli diversi dà due lingotti di lega (i metalli
## base sono solo quelli di `MATERIALS`: niente leghe di leghe). Ogni lega è un materiale nuovo, con tutta la sua
## famiglia di oggetti. Le proprietà nascono da quelle dei due metalli (`_alloy`): più dura del più tenero ma meno del più
## duro, un po' più affilata e tenace della media, leggera come il più leggero, più risonante; e se i due metalli hanno
## due elementi diversi la lega li porta **tutti e due**, alternati colpo dopo colpo (gelo e brace: ogni due colpi un
## Vapore). Nessuna lega è la migliore in tutto. I nomi sono scritti a mano (`ALLOY_NAMES`).
const ALLOY_NAMES := {
	"radicite+legnoferro": "ferrobruno", "radicite+ambra": "ambrarossa", "radicite+linfa": "linfarossa",
	"radicite+vuoto": "ombrarossa", "radicite+pallidite": "rosalba", "radicite+tizzonite": "fiammarossa",
	"radicite+stellare": "stellarossa", "legnoferro+ambra": "ferrambra", "legnoferro+linfa": "ferrolinfa",
	"legnoferro+vuoto": "ferronero", "legnoferro+pallidite": "ferropallido", "legnoferro+tizzonite": "ferrobrace",
	"legnoferro+stellare": "ferrostella", "ambra+linfa": "ambralinfa", "ambra+vuoto": "ambranera",
	"ambra+pallidite": "ambrachiara", "ambra+tizzonite": "ambrarsa", "ambra+stellare": "ambrastella",
	"linfa+vuoto": "linfanera", "linfa+pallidite": "linfalba", "linfa+tizzonite": "linfardente",
	"linfa+stellare": "linfastella", "vuoto+pallidite": "vuotalba", "vuoto+tizzonite": "vuotobrace",
	"vuoto+stellare": "stellanera", "pallidite+tizzonite": "vaporite", "pallidite+stellare": "stellalba",
	"tizzonite+stellare": "stellardente",
	# Roadmap 16: le leghe della nimbite
	"radicite+nimbite": "nemborosso", "legnoferro+nimbite": "ferronembo", "ambra+nimbite": "ambranembo",
	"linfa+nimbite": "linfanembo", "vuoto+nimbite": "nembonero", "pallidite+nimbite": "nembalba",
	"tizzonite+nimbite": "nembobrace", "stellare+nimbite": "stellanembo",
}
## Voce 53: i **materiali dei geni**. Ognuno si trova solo nei mondi con il suo gene (`genes`): scavando certe tessere
## (`raw.tiles`, sotto `min_depth` tessere dalla superficie, o in cielo con `sky`) o dalle creature (`raw.kill`: "any"
## o "ancient"), con probabilità `chance`. Il grezzo si fonde al Baccello ardente (3 per lingotto); poi tutta la
## famiglia di oggetti, come ogni metallo. Niente leghe con questi (sarebbero migliaia di oggetti in più).
const GENE_MATERIALS := {
	"ferro_brina": {"label": "di ferro di brina", "short": "ferro di brina", "tier": 3, "durezza": 52, "filo": 15, "peso": 9.0,
		"tenacia": 2.6, "conduzione": 7, "elemento": "gelo", "risonanza": 1, "icon": "brina", "genes": ["geodi_brina", "brina"],
		"raw": {"id": "scaglie_brina", "name": "Scaglie di ferro di brina", "shape": "scaglia", "tiles": [TileDefs.GRASS_BRINA],
			"min_depth": 30, "chance": 0.3}},
	"ossidiana_brace": {"label": "d'ossidiana di brace", "short": "ossidiana di brace", "tier": 4, "durezza": 62, "filo": 22,
		"peso": 14.0, "tenacia": 3.0, "conduzione": 4, "elemento": "brace", "risonanza": 0, "icon": "sanguinella", "genes": ["fiumi_brace"],
		"raw": {"id": "ossidiana", "name": "Ossidiana di brace", "shape": "gemma", "tiles": [TileDefs.GRASS_CENERE], "min_depth": 60, "chance": 0.35}},
	"micelio_duro": {"label": "di micelio duro", "short": "micelio duro", "tier": 2, "durezza": 38, "filo": 10, "peso": 4.0,
		"tenacia": 2.2, "conduzione": 9, "elemento": "spora", "risonanza": 1, "icon": "fungo", "genes": ["fungaie", "radice_madre"],
		"raw": {"id": "micelio", "name": "Micelio duro", "shape": "fungo", "tiles": [TileDefs.GRASS_SPORE], "min_depth": 25, "chance": 0.3}},
	"linfite": {"label": "di linfite", "short": "linfite", "tier": 5, "durezza": 70, "filo": 20, "peso": 6.0, "tenacia": 3.5,
		"conduzione": 22, "elemento": "linfa", "risonanza": 2, "icon": "lagunite", "genes": ["laghi_linfa", "radice_madre"],
		"raw": {"id": "linfite_grezza", "name": "Linfite grezza", "shape": "cristallo", "tiles": [TileDefs.CRYSTAL], "min_depth": 300, "chance": 0.2}},
	"radicite_pura": {"label": "di radicite pura", "short": "radicite pura", "tier": 2, "durezza": 44, "filo": 13, "peso": 18.0,
		"tenacia": 2.2, "conduzione": 5, "elemento": "", "risonanza": 1, "icon": "brace", "genes": ["radicite_diffusa"],
		"raw": {"id": "radicite_grezza_pura", "name": "Radicite pura", "shape": "minerale", "tiles": [TileDefs.RADICITE], "min_depth": 0, "chance": 0.12}},
	"ambra_dorata": {"label": "d'ambra dorata", "short": "ambra dorata", "tier": 4, "durezza": 64, "filo": 20, "peso": 12.0,
		"tenacia": 3.4, "conduzione": 12, "elemento": "luce", "risonanza": 1, "icon": "brillaluce", "genes": ["metalli_nobili"],
		"raw": {"id": "ambra_dorata_grezza", "name": "Ambra dorata", "shape": "gemma", "tiles": [TileDefs.AMBRA], "min_depth": 0, "chance": 0.12}},
	"ferro_stellato": {"label": "di ferro stellato", "short": "ferro stellato", "tier": 6, "durezza": 88, "filo": 30, "peso": 4.0,
		"tenacia": 5.5, "conduzione": 20, "elemento": "luce", "risonanza": 2, "icon": "iride", "genes": ["vene_stellari"],
		"raw": {"id": "frammento_stellato", "name": "Frammento stellato", "shape": "stella",
			"tiles": [TileDefs.RADICITE, TileDefs.LEGNOFERRO, TileDefs.AMBRA, TileDefs.PALLIDITE, TileDefs.TIZZONITE], "min_depth": 0, "chance": 0.04}},
	"vuoto_cavo": {"label": "di vuoto cavo", "short": "vuoto cavo", "tier": 6, "durezza": 80, "filo": 31, "peso": 3.0, "tenacia": 4.5,
		"conduzione": 18, "elemento": "vuoto", "risonanza": 2, "icon": "nottilite", "genes": ["cuore_cavo"],
		"raw": {"id": "vuoto_cavo_grezzo", "name": "Scheggia di vuoto cavo", "shape": "cristallo", "tiles": [TileDefs.VUOTITE], "min_depth": 0, "chance": 0.1}},
	"sospesite": {"label": "di sospesite", "short": "sospesite", "tier": 4, "durezza": 40, "filo": 12, "peso": 1.0, "tenacia": 2.0,
		"conduzione": 10, "elemento": "luce", "risonanza": 3, "icon": "muschio", "genes": ["isole_sospese"],
		"raw": {"id": "zolla_sospesa", "name": "Zolla sospesa", "shape": "zolla", "tiles": [TileDefs.GRASS, TileDefs.DIRT], "sky": true, "chance": 0.25}},
	"nerume": {"label": "di nerume", "short": "nerume", "tier": 5, "durezza": 68, "filo": 26, "peso": 11.0, "tenacia": 3.2,
		"conduzione": 6, "elemento": "vuoto", "risonanza": 1, "icon": "nodo", "genes": ["cuore_nero", "avvizzito"],
		"raw": {"id": "nerume_grezzo", "name": "Nerume", "shape": "polvere", "tiles": [TileDefs.AVV_TERRA, TileDefs.AVV_MUSCHIO, TileDefs.AVV_PIETRA],
			"min_depth": 0, "chance": 0.15}},
	"chitina": {"label": "di chitina", "short": "chitina", "tier": 3, "durezza": 40, "filo": 14, "peso": 6.0, "tenacia": 4.2,
		"conduzione": 2, "elemento": "", "risonanza": 0, "icon": "cenere", "genes": ["brulicante"],
		"raw": {"id": "chitina_grezza", "name": "Lastra di chitina", "shape": "scaglia", "kill": "any", "chance": 0.1}},
	"osso_antico": {"label": "d'osso antico", "short": "osso antico", "tier": 5, "durezza": 60, "filo": 25, "peso": 16.0, "tenacia": 4.0,
		"conduzione": 8, "elemento": "", "risonanza": 2, "icon": "seta", "genes": ["ancestrale"],
		"raw": {"id": "osso_antico_grezzo", "name": "Osso antico", "shape": "aculeo", "kill": "ancient", "chance": 0.5}},
}
## Roadmap 31, voce 306: il **carattere** di ogni materiale (l'utente: «oggetti dello stesso tipo e grado ma di materiali
## diversi danno gli stessi bonus»). Un bonus suo, scelto dal tema del suo set e dalle sue proprietà, con le chiavi di
## `GearEffects` (i moltiplicatori come differenza da 1: 0,06 = +6%). Il valore è quello di un pezzo «intero»; ogni pezzo
## ne prende la sua parte (`SHARE`). Le leghe prendono metà del carattere di ciascuno dei due metalli (`trait_of`).
const TRAITS := {
	"radicite": {"regen": 0.08},                     # Radici salde: la Vita ricresce
	"legnoferro": {"defense": 1.0},                  # Corteccia di ferro: Scorza
	"pallidite": {"run": 0.06},                      # Passo di luna: corsa
	"ambra": {"halo": 0.12},                         # Luce fossile: alone
	"tizzonite": {"thorns": 4.0},                    # Brace viva: chi ti tocca si brucia
	"linfa": {"linfa_regen": 0.10},                  # Linfa che scorre
	"vuoto": {"stealth": -0.08},                     # Ombra del Vuoto: le creature ti vedono più tardi
	"stellare": {"luck": 0.05},                      # Stella del Giardino: fortuna
	"nimbite": {"jump": 0.06},                       # Passo di nembo: salto
	# i materiali dei geni
	"ferro_brina": {"fresco": 0.15, "regen": 0.04},
	"ossidiana_brace": {"caldo": 0.15, "damage": 0.03},
	"micelio_duro": {"filtro": 0.15, "regen": 0.06},
	"linfite": {"magic": 0.07},
	"radicite_pura": {"dig": 0.08},
	"ambra_dorata": {"luck": 0.04, "halo": 0.06},
	"ferro_stellato": {"luck": 0.04, "run": 0.04},
	"vuoto_cavo": {"stealth": -0.08, "magic": 0.04},
	"sospesite": {"jump": 0.08, "quota": 0.15},
	"nerume": {"damage": 0.04, "thorns": 2.0},
	"chitina": {"defense": 1.0, "thorns": 2.0},
	"osso_antico": {"damage": 0.03, "atk_speed": 0.03},
}
## Quanto del carattere prende ogni pezzo: un'armatura intera di cinque pezzi ne prende 1,75 (tre pezzi da un quarto,
## guanti e stivali da metà); l'arma o l'attrezzo in mano metà; l'amuleto metà, l'anello tre decimi (voce 308).
const SHARE := {"armatura": 0.25, "accessorio": 0.5, "mano": 0.5, "amuleto": 0.5, "anello": 0.3}
## Le chiavi del carattere che si sommano (le altre moltiplicano; come in `GearEffects._add`).
const ADDITIVE := ["luck", "thorns", "defense", "caldo", "acqua", "fresco", "filtro", "quota", "quieto"]

static var _all := {}
static var _items := {}


## Il carattere di un materiale (le leghe: metà di ciascuno dei due metalli). {} se non ne ha.
static func trait_of(mat: String) -> Dictionary:
	var md := get_mat(mat)
	if md.has("alloy"):
		var out := {}
		for part in md["alloy"]:
			var t: Dictionary = TRAITS.get(String(part), SpineData.TRAITS.get(String(part), {}))
			for k in t:
				out[k] = float(out.get(k, 0.0)) + float(t[k]) * 0.5
		return out
	return TRAITS.get(mat, SpineData.TRAITS.get(mat, {}))


## Il carattere come effetti di un pezzo (`acc`), per la sua parte: {"run": 1.03, "luck": 0.025…}.
static func trait_acc(mat: String, share: float) -> Dictionary:
	var out := {}
	var t := trait_of(mat)
	for k in t:
		var v := float(t[k]) * share
		out[k] = snappedf(v, 0.001) if k in ADDITIVE else snappedf(1.0 + v, 0.001)
	return out


## Due gruppi di effetti in uno (i moltiplicatori si moltiplicano, le somme si sommano).
static func merge_acc(a: Dictionary, b: Dictionary) -> Dictionary:
	var out := a.duplicate()
	for k in b:
		if not out.has(k):
			out[k] = b[k]
		elif k in ADDITIVE:
			out[k] = snappedf(float(out[k]) + float(b[k]), 0.001)
		else:
			out[k] = snappedf(float(out[k]) * float(b[k]), 0.001)
	return out


## Le proprietà numeriche (per le leghe e per le schede).
const PROPS := ["durezza", "filo", "peso", "tenacia", "conduzione"]
const PROP_NAMES := {"durezza": "Durezza", "filo": "Filo", "peso": "Peso", "tenacia": "Tenacia", "conduzione": "Conduzione",
	"risonanza": "Risonanza"}


## I materiali, leghe comprese (calcolati una volta).
static func all() -> Dictionary:
	if not _all.is_empty():
		return _all
	_all = MATERIALS.duplicate(true)
	var keys := MATERIALS.keys()
	for i in keys.size():
		for j in range(i + 1, keys.size()):
			var a := String(keys[i])
			var b := String(keys[j])
			_all[alloy_id(a, b)] = _alloy(a, b)
	for g in GENE_MATERIALS:
		var md: Dictionary = GENE_MATERIALS[g].duplicate(true)
		md["bar"] = "lingotto_" + g
		md["gene"] = true
		_all[g] = md
	# Roadmap 39, voce 363: i metalli del Risveglio (dati in `SpineData`), come i materiali dei geni ma senza gene
	for g in SpineData.METALS:
		var md: Dictionary = SpineData.METALS[g].duplicate(true)
		md["bar"] = "lingotto_" + g
		md["spina"] = true
		_all[g] = md
	return _all


static func alloy_id(a: String, b: String) -> String:
	var keys := MATERIALS.keys()
	if keys.find(a) > keys.find(b):
		var t := a
		a = b
		b = t
	return "lega_%s_%s" % [a, b]


## Le proprietà di una lega di due metalli.
static func _alloy(a: String, b: String) -> Dictionary:
	var ma: Dictionary = MATERIALS[a]
	var mb: Dictionary = MATERIALS[b]
	var name := String(ALLOY_NAMES.get("%s+%s" % [a, b], "%s-%s" % [a, b]))
	var ea := String(ma["elemento"])
	var eb := String(mb["elemento"])
	var elem := ea if eb == "" or ea == eb else (eb if ea == "" else "%s+%s" % [ea, eb])
	return {"label": "di " + name, "short": name, "tier": maxi(int(ma["tier"]), int(mb["tier"])),
		"durezza": roundi(maxf(float(ma["durezza"]), float(mb["durezza"])) * 0.95),
		# voce 185: filo ×1,05 (era 1,1) e peso a metà tra il più leggero e la media (era il più leggero): la lega
		# tizzonite-nimbite batteva di un terzo i metalli del suo grado (`tools/armi.gd`)
		"filo": roundi((float(ma["filo"]) + float(mb["filo"])) * 0.5 * 1.05),
		"peso": (minf(float(ma["peso"]), float(mb["peso"])) + (float(ma["peso"]) + float(mb["peso"])) * 0.5) * 0.5,
		"tenacia": snappedf((float(ma["tenacia"]) + float(mb["tenacia"])) * 0.5 * 1.1, 0.1),
		"conduzione": roundi((float(ma["conduzione"]) + float(mb["conduzione"])) * 0.5),
		"elemento": elem, "risonanza": mini(maxi(int(ma["risonanza"]), int(mb["risonanza"])) + 1, 3),
		"bar": "lingotto_" + alloy_id(a, b), "icon": "lega:%s:%s" % [icon_of(a), icon_of(b)], "alloy": [a, b]}


## I lingotti delle leghe (uniti in `ItemsData.all()`).
static func items() -> Dictionary:
	if not _items.is_empty():
		return _items
	for g in GENE_MATERIALS:
		var gd: Dictionary = GENE_MATERIALS[g]
		var raw: Dictionary = gd["raw"]
		var genes := ", ".join((gd["genes"] as Array).map(func(x: String) -> String: return String(GenesData.GENES[x]["name"])))
		var where := "dalle creature" if raw.has("kill") else "scavando"
		_items[String(raw["id"])] = {"name": raw["name"], "kind": "materiale", "icon": [raw["shape"], gd["icon"]], "tier": gd["tier"],
			"value": 6 * int(gd["tier"]), "source": "%s, nei mondi con il gene %s" % [where, genes],
			"desc": "Un materiale che esiste solo nei mondi con il gene %s. Al Baccello ardente, tre ne fanno un lingotto di %s." % [genes, gd["short"]]}
		_items["lingotto_" + g] = {"name": "Lingotto di %s" % gd["short"], "kind": "materiale", "icon": ["lingotto", gd["icon"]],
			"tier": gd["tier"],
			"desc": "%s. %s. Carattere: %s." % [String(gd["short"]).substr(0, 1).to_upper() + String(gd["short"]).substr(1), describe(g),
				_trait_words(g)]}
	for g in SpineData.METALS:
		var sd: Dictionary = SpineData.METALS[g]
		var sr: Dictionary = sd["raw"]
		var deep: String = ["", "dal Sottobosco in giù", "dalle Caverne in giù", "dalle Profondità in giù", "nel Fondo"][int(sr["stratum"])]
		_items[String(sr["id"])] = {"name": sr["name"], "kind": "materiale", "icon": [sr["shape"], sd["icon"]], "tier": sd["tier"],
			"value": 8 * int(sd["tier"]),
			"source": "scavando la roccia %s nei mondi di vigore %d e oltre, dopo il Risveglio del Cuore; dalle creature antiche di quei mondi" % [deep, int(sr["vigor"])],
			"desc": "%s Al Baccello ardente, tre ne fanno un lingotto." % sd["desc"]}
		_items["lingotto_" + g] = {"name": "Lingotto di %s" % sd["short"], "kind": "materiale", "icon": ["lingotto", sd["icon"]],
			"tier": sd["tier"],
			"desc": "%s. %s. Carattere: %s." % [String(sd["short"]).substr(0, 1).to_upper() + String(sd["short"]).substr(1), describe(g),
				_trait_words(g)]}
	for id in all():
		var md: Dictionary = all()[id]
		if md.has("alloy"):
			_items[String(md["bar"])] = {"name": "Lingotto di %s" % md["short"], "kind": "materiale",
				"icon": ["lingotto", md["icon"]], "gen": true,
				"desc": "Lega di %s e %s, fusa al Baccello ardente: %s. Carattere: %s." % [String(MATERIALS[md["alloy"][0]]["label"]).trim_prefix("di ").trim_prefix("d'"),
					String(MATERIALS[md["alloy"][1]]["label"]).trim_prefix("di ").trim_prefix("d'"), describe(id), _trait_words(id)]}
	return _items


## Le ricette dei lingotti delle leghe (un lingotto per metallo, due di lega), al Baccello ardente.
static func recipes() -> Array:
	var out := []
	for g in GENE_MATERIALS:
		out.append({"out": "lingotto_" + g, "qty": 1, "in": {String(GENE_MATERIALS[g]["raw"]["id"]): 3}, "station": "baccello_ardente"})
	for g in SpineData.METALS:
		out.append({"out": "lingotto_" + g, "qty": 1, "in": {String(SpineData.METALS[g]["raw"]["id"]): 3}, "station": "baccello_ardente"})
	for id in all():
		var md: Dictionary = all()[id]
		if md.has("alloy"):
			out.append({"out": md["bar"], "qty": 2, "in": {String(MATERIALS[md["alloy"][0]]["bar"]): 1,
				String(MATERIALS[md["alloy"][1]]["bar"]): 1}, "station": "baccello_ardente"})
	return out


static func get_mat(id: String) -> Dictionary:
	return all().get(id, {})


## La tavolozza dell'icona di un materiale.
static func icon_of(id: String) -> String:
	return String(get_mat(id).get("icon", id)) if all().has(id) else String(MATERIALS.get(id, {}).get("icon", id))


## «Durezza 45 · Filo 12 · Peso 17 · Tenacia 2 · Conduzione 3» (per la scheda in Esamina).
static func describe(id: String) -> String:
	var md := get_mat(id)
	var parts := []
	for p in PROPS:
		parts.append("%s %s" % [PROP_NAMES[p], str(md[p]) if not md[p] is float else ("%.1f" % md[p]).trim_suffix(".0")])
	return " · ".join(parts)


## Il carattere in parole minuscole, per le descrizioni dei lingotti (che si scrivono quando i dati si caricano: qui
## niente `TipWordsData`, che nomina `FormsData` e farebbe un giro di dipendenze).
static func _trait_words(id: String) -> String:
	var names := {"regen": "la Vita ricresce", "defense": "Scorza", "run": "corsa", "halo": "alone", "thorns": "spine",
		"linfa_regen": "la Linfa ricresce", "stealth": "le creature ti vedono più tardi", "luck": "fortuna", "jump": "salto",
		"fresco": "protezione dal calore", "caldo": "protezione dal freddo", "filtro": "protezione dalla polvere",
		"quota": "protezione dall'aria sottile", "quieto": "protezione dal peso del Vuoto", "magic": "incantesimi", "dig": "scavo", "damage": "danno", "atk_speed": "colpi"}
	var parts := []
	var t := trait_of(id)
	for k in t:
		parts.append(String(names.get(k, k)))
	return ", ".join(parts) if not parts.is_empty() else "nessuno"


## Voce 306: il carattere in parole, per un pezzo intero: «Corsa +6%» (o «» se il materiale non ne ha).
static func trait_text(id: String) -> String:
	var acc := trait_acc(id, 1.0)
	var parts := []
	for k in acc:
		parts.append(String(TipWordsData.acc_line(String(k), acc[k])[0]))
	return ", ".join(parts)
