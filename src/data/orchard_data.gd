class_name OrchardData
extends RefCounted
## Qualità e incroci dell'orto (Roadmap 24, voce 244; regole in `Orchard`).
## La **qualità** di un raccolto: un punto per ogni cura (`CARE`), due per il seme scelto; comune sotto `GOOD`, buona,
## ottima da `GREAT`. Buona = raccolto × `GOOD_MULT`; ottima = × `GREAT_MULT` e un **seme scelto** (`scelto_<coltura>`,
## che ripiantato vale `CHOSEN` punti).
## Gli **incroci**: raccogliendo una pianta matura con accanto (entro `NEAR` colonne, stessa riga o quella vicina) una
## pianta matura di un'altra coltura, se la coppia è in `HYBRIDS` c'è `CROSS` di probabilità (di più se ottima) di un seme
## della varietà nuova. Le varietà sono colture come le altre (`CROPS`, unite a `CropsData.CROPS`); la pianta matura ha
## il disegno di un genitore.

const GOOD := 2
const GREAT := 4
const GOOD_MULT := 1.5
const GREAT_MULT := 2.0
const CHOSEN := 2
const NEAR := 3
const CROSS := 0.15
const CROSS_GREAT := 0.25
const CARE := ["annaffiata", "aratura", "serra", "linfa", "isola"]
const NAMES := ["comune", "buona", "ottima"]

## [coltura A, coltura B, varietà]
const HYBRIDS := [
	["rugiada", "campanula", "campanula_rugiada"],
	["rugiada", "tubero", "tubero_dolce"],
	["brace", "luminoso", "fiammafredda"],
	["brace", "tubero", "tubero_fumante"],
	["campanula", "tubero", "bulbo_lume"],
	["luminoso", "campanula", "campanula_ombra"],
	["rugiada", "brace", "erba_vapore"],
	["luminoso", "tubero", "tubero_notturno"],
	["campanula", "brace", "fiore_brace"],
	["rugiada", "luminoso", "muschio_stellato"],
	["fiore_vento", "campanula", "campanula_vento"],
	["fiore_vento", "rugiada", "erba_nuvola"],
]

## Le varietà: [nome, disegno del genitore (decorazione), secondi, terreno, prodotto, nome del prodotto, frase]
const VARIETIES := {
	"campanula_rugiada": ["Campanula di rugiada", 31, 330.0, "erba", "nettare_rugiada", "Nettare di rugiada", "Dolce e fresco: la cucina lo ama."],
	"tubero_dolce": ["Tubero dolce", 32, 380.0, "erba", "tubero_dolce", "Tubero dolce", "Un tubero di Linfa che sa di miele."],
	"fiammafredda": ["Fungo fiammafredda", 29, 300.0, "terra", "cappello_fiammafredda", "Cappello di fiammafredda", "Brucia di un fuoco che non scotta."],
	"tubero_fumante": ["Tubero fumante", 32, 400.0, "erba", "tubero_fumante", "Tubero fumante", "Esce dalla terra già caldo."],
	"bulbo_lume": ["Bulbo lume", 31, 400.0, "erba", "bulbo_lume", "Bulbo lume", "Un bulbo che fa luce anche tagliato."],
	"campanula_ombra": ["Campanula d'ombra", 30, 360.0, "terra", "petali_ombra", "Petali d'ombra", "Petali scuri che assorbono la luce."],
	"erba_vapore": ["Erba di vapore", 28, 260.0, "erba", "foglia_vapore", "Foglia di vapore", "Tiepida anche nella neve."],
	"tubero_notturno": ["Tubero notturno", 30, 420.0, "terra", "tubero_notturno", "Tubero notturno", "Cresce al buio e ci vede, dicono."],
	"fiore_brace": ["Fiore di brace", 31, 340.0, "erba", "petali_brace", "Petali di brace", "Rossi e caldi come le Cenerarie."],
	"muschio_stellato": ["Muschio stellato", 28, 300.0, "terra", "muschio_stellato", "Muschio stellato", "Brilla di puntini come un cielo."],
	"campanula_vento": ["Campanula di vento", 85, 320.0, "erba", "petali_brezza", "Petali di brezza", "Leggeri: volano via se non li chiudi."],
	"erba_nuvola": ["Erba di nuvola", 85, 280.0, "erba", "ciuffo_nuvola", "Ciuffo di nuvola", "Morbido come una nuvola del Mare di nubi."],
}


static func seed_of(v: String) -> String:
	return "seme_" + v


## Le varietà come colture (campi di `CropsData`).
static func crops() -> Dictionary:
	var out := {}
	for v in VARIETIES:
		var e: Array = VARIETIES[v]
		out[v] = {"name": String(e[0]), "seed": seed_of(v), "decor": int(e[1]), "grow": float(e[2]), "soil": String(e[3]),
			"harvest": {String(e[4]): [2, 3]}, "seeds": [1, 1], "ibrido": true}
	return out


## Gli oggetti: i semi e i prodotti delle varietà, i semi scelti di tutte le colture.
static func items(all_crops: Dictionary) -> Dictionary:
	var out := {}
	for v in VARIETIES:
		var e: Array = VARIETIES[v]
		out[seed_of(v)] = {"name": "Seme di %s" % String(e[0]).to_lower(), "kind": "seme", "icon": ["seme", "iride"], "stack": 99,
			"source": "incrocio", "desc": "Nato da un incrocio nell'orto. Piantalo: %s." % String(e[0]).to_lower()}
		out[String(e[4])] = {"name": String(e[5]), "kind": "materiale", "icon": ["tubero", "iride"], "stack": 99, "desc": String(e[6])}
	for c in all_crops:
		out["scelto_" + String(c)] = {"name": "Seme scelto: %s" % String(all_crops[c]["name"]).to_lower(), "kind": "seme",
			"icon": ["seme", "ambra"], "stack": 99, "source": "raccolto ottimo",
			"desc": "Dal raccolto migliore: la pianta che ne nasce parte già con due punti di qualità."}
	return out


## La varietà di un incrocio fra due colture ("" se non ce n'è).
static func hybrid(a: String, b: String) -> String:
	for h in HYBRIDS:
		if (String(h[0]) == a and String(h[1]) == b) or (String(h[0]) == b and String(h[1]) == a):
			return String(h[2])
	return ""
