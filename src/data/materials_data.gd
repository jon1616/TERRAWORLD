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
	"vuoto": {"label": "di vuotite forgiata", "tier": 5, "durezza": 75, "filo": 27, "peso": 7.5, "tenacia": 5.0, "conduzione": 10,
		"elemento": "vuoto", "risonanza": 1, "bar": "lingotto_vuoto", "icon": "vuotite"},
	# voce 24: metalli laterali, per chi vuole una strada diversa (più veloce, o più forte prima della Linfa)
	"pallidite": {"label": "di pallidite", "tier": 2, "durezza": 42, "filo": 11, "peso": 7.5, "tenacia": 1.6, "conduzione": 6,
		"elemento": "gelo", "risonanza": 0, "bar": "lingotto_pallidite"},
	"tizzonite": {"label": "di tizzonite", "tier": 3, "durezza": 60, "filo": 18, "peso": 15.0, "tenacia": 3.1, "conduzione": 5,
		"elemento": "brace", "risonanza": 0, "bar": "lingotto_tizzonite"},
	"stellare": {"label": "stellare", "label_pl": "stellari", "tier": 6, "durezza": 85, "filo": 34, "peso": 5.0, "tenacia": 6.0,
		"conduzione": 16, "elemento": "luce", "risonanza": 2, "bar": "lingotto_stellare", "icon": "ambra"},
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
}
static var _all := {}
static var _items := {}


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
		"filo": roundi((float(ma["filo"]) + float(mb["filo"])) * 0.5 * 1.1),
		"peso": minf(float(ma["peso"]), float(mb["peso"])),
		"tenacia": snappedf((float(ma["tenacia"]) + float(mb["tenacia"])) * 0.5 * 1.1, 0.1),
		"conduzione": roundi((float(ma["conduzione"]) + float(mb["conduzione"])) * 0.5),
		"elemento": elem, "risonanza": mini(maxi(int(ma["risonanza"]), int(mb["risonanza"])) + 1, 3),
		"bar": "lingotto_" + alloy_id(a, b), "icon": "lega:%s:%s" % [icon_of(a), icon_of(b)], "alloy": [a, b]}


## I lingotti delle leghe (uniti in `ItemsData.all()`).
static func items() -> Dictionary:
	if not _items.is_empty():
		return _items
	for id in all():
		var md: Dictionary = all()[id]
		if md.has("alloy"):
			_items[String(md["bar"])] = {"name": "Lingotto di %s" % md["short"], "kind": "materiale",
				"icon": ["lingotto", md["icon"]], "gen": true,
				"desc": "Lega di %s e %s, fusa al Baccello ardente: %s." % [String(MATERIALS[md["alloy"][0]]["label"]).trim_prefix("di ").trim_prefix("d'"),
					String(MATERIALS[md["alloy"][1]]["label"]).trim_prefix("di ").trim_prefix("d'"), describe(id)]}
	return _items


## Le ricette dei lingotti delle leghe (un lingotto per metallo, due di lega), al Baccello ardente.
static func recipes() -> Array:
	var out := []
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
