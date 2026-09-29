class_name ArchaeologyData
extends RefCounted
## L'archeologia (Roadmap 26, voce 254; regole in `Archaeology`, giacimenti da `PassGiacimenti`). Nelle grotte degli
## strati 1-4 ci sono i **giacimenti fossili** (stazione `giacimento`): con il **Pennello** in mano, clic destro più
## volte (`BRUSHES`) e ne esce un fossile di uno degli animali antichi di quello strato. Tre fossili dello stesso animale
## al Maglio fanno il suo **scheletro**. Fossili e scheletri vanno nel Museo (sale «fossili» e «scheletri»).
##   ANIMALS: id → [nome, strato, parti ([id della parte, nome]), materiale dell'icona]

const BRUSHES := 8
const PER_WORLD := 26                  # quanti giacimenti prova a mettere un mondo
const PARTS := [["cranio", "Cranio"], ["ossa", "Ossa"], ["artiglio", "Artiglio"]]

const ANIMALS := {
	"grumo_primo": ["Grumo primordiale", 1, "muschio"],
	"serpe_radici": ["Serpe delle radici", 1, "radice"],
	"cervo_antico": ["Cervo dalle mille corna", 2, "ardesia"],
	"talpa_gigante": ["Talpa gigante", 2, "pallidite"],
	"pesce_corazza": ["Pesce corazzato", 3, "linfa"],
	"uccello_foglia": ["Uccello-foglia", 3, "cristallo"],
	"drago_brace": ["Drago di brace", 4, "brace"],
	"colosso_vuoto": ["Colosso del Vuoto", 4, "vuotite"],
}


static func fossil_id(animal: String, part: String) -> String:
	return "fossile_%s_%s" % [animal, part]


static func skeleton_id(animal: String) -> String:
	return "scheletro_" + animal


## Gli animali di uno strato.
static func of_stratum(st: int) -> Array:
	var out := []
	for a in ANIMALS:
		if int(ANIMALS[a][1]) == st:
			out.append(String(a))
	return out


static func items() -> Dictionary:
	var out := {
		"pennello": {"name": "Pennello dell'archeologo", "kind": "pennello", "icon": ["benda", "legno"], "stack": 1,
			"desc": "Con il clic destro su un giacimento fossile, spazzola via la roccia: dopo qualche colpo esce un fossile."},
	}
	for a in ANIMALS:
		var d: Array = ANIMALS[a]
		for p in PARTS:
			out[fossil_id(a, String(p[0]))] = {"name": "%s: %s" % [String(p[1]), String(d[0]).to_lower()], "kind": "materiale",
				"icon": ["guscio", String(d[2])], "stack": 20, "source": "giacimento fossile",
				"desc": "Un fossile %s, dai giacimenti dello strato %d. Tre parti diverse fanno lo scheletro." % [String(d[0]).to_lower(), int(d[1])]}
		out[skeleton_id(a)] = {"name": "Scheletro: %s" % String(d[0]).to_lower(), "kind": "trofeo", "icon": ["guscio", "sem"], "stack": 5,
			"desc": "Ricostruito al Maglio con le sue tre parti: il pezzo più bello del Museo."}
	return out


static func recipes() -> Array:
	var out := [{"out": "pennello", "qty": 1, "in": {"legno": 3, "seta_radice": 2}, "station": "ceppo"}]
	for a in ANIMALS:
		var need := {}
		for p in PARTS:
			need[fossil_id(a, String(p[0]))] = 1
		out.append({"out": skeleton_id(a), "qty": 1, "in": need, "station": "maglio"})
	return out
