class_name ChestsData
## I gradi delle casse (28 set 2026, richiesta dell'utente: «un sistema di tier delle casse costruibili o trovabili,
## con capienze crescenti»). Solo dati. Le stazioni stanno in `StationsData` (qui solo quante caselle e da cosa sono
## fatte), gli oggetti e le ricette nascono da `BUILT` (`items()`, `recipes()`), il disegno da `mat` (`CompactArt`).
##   BUILT  si fabbricano, dal legno dei primi passi ai metalli del fine gioco
##   FOUND  si trovano soltanto, piene, nelle rovine (più grandi più si scende); vuote si portano via e si riusano

const BUILT := [
	{"id": "cesta", "name": "Cesta di radici", "slots": 20, "mat": "legno"},
	{"id": "cassa_legnoferro", "name": "Cassa di legnoferro", "slots": 30, "mat": "legnoferro",
		"in": {"legno": 12, "lingotto_legnoferro": 4}, "station": "ceppo"},
	{"id": "forziere_ambra", "name": "Forziere d'ambra", "slots": 40, "mat": "ambra",
		"in": {"legno": 12, "lingotto_ambra": 5}, "station": "maglio"},
	{"id": "scrigno_linfa", "name": "Scrigno di Linfa", "slots": 50, "mat": "cristallo",
		"in": {"lingotto_linfa": 5, "cristallo_linfa": 8}, "station": "maglio"},
	{"id": "arca_vuoto", "name": "Arca del Vuoto", "slots": 70, "mat": "vuotite",
		"in": {"lingotto_vuoto": 6, "scheggia_vuoto": 10}, "station": "maglio"},
	{"id": "arca_stellare", "name": "Arca stellare", "slots": 100, "mat": "brillaluce",
		"in": {"lingotto_stellare": 6, "cristallo_linfa": 10}, "station": "maglio"},
]

## Le casse trovate: in quali strati delle rovine (1 Sottobosco … 4 il Fondo) e con che probabilità al posto dello
## Scrigno dei Seminatori. Roadmap 45, voce 392: più le casse dei biomi dei pacchetti (campo «chests»: "biome", "where"
## superficie/sotto/cielo, "key" per le sigillate), che le rovine e gli osservatori mettono con `biome_roll`.
static var FOUND: Array = _FOUND + BiomesData.pack_list("chests")
## Voce 393: i mimi (campo «mimics»: la stazione, la creatura, la cassa di cui hanno l'aspetto).
static var MIMICS: Array = BiomesData.pack_list("mimics")
const BIOME_CHEST := 0.24                # in una rovina, la cassa del bioma al posto dello scrigno
const BIOME_SEALED := 0.1                # la sigillata
const BIOME_MIMIC := 0.06                # il mimo

const _FOUND := [
	{"id": "scrigno", "name": "Scrigno dei Seminatori", "slots": 20, "mat": "sem"},
	{"id": "scrigno_antico", "name": "Scrigno antico dei Seminatori", "slots": 40, "mat": "ambra", "strata": 3, "chance": 0.5},
	{"id": "arca_seminatori", "name": "Arca dei Seminatori", "slots": 60, "mat": "brillaluce", "strata": 4, "chance": 0.6},
]


static func all() -> Array:
	return BUILT + FOUND


static func is_chest(id: String) -> bool:
	for e in all():
		if String(e["id"]) == id:
			return true
	return false


static func is_found(id: String) -> bool:
	for e in FOUND:
		if String(e["id"]) == id:
			return true
	return false


static func info(id: String) -> Dictionary:
	for e in all():
		if String(e["id"]) == id:
			return e
	return {}


## Gli oggetti delle casse nuove (la Cesta e lo Scrigno ci sono già in `ItemsData`).
static func items() -> Dictionary:
	var out := {}
	for e in all():
		var id := String(e["id"])
		if id in ["cesta", "scrigno"]:
			continue
		var found := is_found(id)
		var d := {"name": e["name"], "kind": "stazione", "icon": ["scrigno" if found else "cesta", e["mat"]], "place": id,
			"stack": 99, "desc": "%s: tiene %d pile di oggetti." % [
				"Si trova nelle rovine profonde. Vuoto, si porta via e si riusa" if found else "Una cassa", int(e["slots"])]}
		if found and e.has("biome"):
			d["source"] = "%s, sotto il suo bioma" % ("gli osservatori del cielo" if String(e["where"]) == "cielo" else "le rovine dei Seminatori")
			d["desc"] = "Una cassa dei biomi%s. Vuota, si porta via e si riusa: tiene %d pile di oggetti." % [
				" (si apre con la sua chiave)" if e.has("key") else "", int(e["slots"])]
		elif found:
			d["source"] = "le rovine dei Seminatori nel %s" % ("Fondo" if int(e["strata"]) >= 4 else "profondo")
		out[id] = d
	return out


static func recipes() -> Array:
	var out := []
	for e in BUILT:
		if e.has("in"):
			out.append({"out": e["id"], "qty": 1, "in": e["in"], "station": e["station"]})
	return out


## Voce 393: il mimo di una stazione ({} se non lo è).
static func mimic_of(id: String) -> Dictionary:
	for e in MIMICS:
		if String(e["id"]) == id:
			return e
	return {}


## Voce 392: le stazioni delle casse dei biomi e dei mimi (le unisce `StationsData`).
static func stations() -> Dictionary:
	var out := {}
	for e in FOUND:
		if e.has("biome"):
			out[String(e["id"])] = {"name": e["name"], "size": [2, 2], "item": e["id"], "slots": int(e["slots"]), "light": true,
				"light_color": Color(0.55, 0.4, 0.2) if e.has("key") else Color(0.3, 0.5, 0.45)}
	for mi in MIMICS:
		var ch := info(String(mi["chest"]))
		out[String(mi["id"])] = {"name": ch.get("name", "Cassa"), "size": [2, 2], "item": "", "fixed": true, "light": true,
			"light_color": Color(0.3, 0.5, 0.45)}
	return out


## Il bioma di una cella: del cielo, del sottosuolo (dal pavimento sotto) o della superficie della colonna.
static func biome_at(w: Object, c: Vector2i, stratum: int) -> String:
	var sky := SkyData.zone_at(w, c.x, c.y)
	if sky != "":
		return sky
	if stratum >= 1:
		for dy in 14:
			if w.solid(c.x, c.y + dy):
				var t: int = w.tile(c.x, c.y + dy)
				for u in BiomesData.UNDER:
					if int(u.get("floor", -1)) == t:
						return String(u["id"])
				break
	return String(BiomesData.BIOMES[BiomesData.at(w, c.x)]["id"])


## Voce 392: quale cassa del bioma (o mimo) mettere al posto di uno scrigno in `c` ("" = lo scrigno di sempre).
static func biome_roll(w: Object, c: Vector2i, stratum: int, rng: RandomNumberGenerator) -> String:
	var b := biome_at(w, c, stratum)
	var r := rng.randf()
	if r < BIOME_MIMIC:
		return "mimo_cassa_" + b if not mimic_of("mimo_cassa_" + b).is_empty() else ""
	if r < BIOME_MIMIC + BIOME_SEALED:
		return "cassa_%s_sigillata" % b if is_found("cassa_%s_sigillata" % b) else ""
	if r < BIOME_MIMIC + BIOME_SEALED + BIOME_CHEST:
		return "cassa_" + b if is_found("cassa_" + b) else ""
	return ""

