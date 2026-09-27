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
## Scrigno dei Seminatori.
const FOUND := [
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
		if found:
			d["source"] = "le rovine dei Seminatori nel %s" % ("Fondo" if int(e["strata"]) >= 4 else "profondo")
		out[id] = d
	return out


static func recipes() -> Array:
	var out := []
	for e in BUILT:
		if e.has("in"):
			out.append({"out": e["id"], "qty": 1, "in": e["in"], "station": e["station"]})
	return out
