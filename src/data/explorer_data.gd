class_name ExplorerData
extends RefCounted
## Gli attrezzi dell'esploratore (Roadmap 23, voce 239; regole in `ExplorerTools`): meno strada a vuoto, più scoperte.
##   Tenda da campo      una stazione: clic destro = si rinasce lì e si pianta il campo (niente creature entro `CAMP_R`)
##   Cannocchiale        clic lontano = scopre la mappa attorno al punto guardato (`SCOPE_R`), costa Linfa
##   Bussola             clic = dove sta la meraviglia più vicina non ancora vista, in questo mondo
##   Radice di ritorno   si consuma: riporta al Giardino

const CAMP_R := 24.0
const SCOPE_R := 14
const SCOPE_REACH := 160.0
const SCOPE_LINFA := 3
const SCOPE_WAIT := 1.5

const ITEMS := {
	"tenda_campo": {"name": "Tenda da campo", "kind": "stazione", "icon": ["tenda", "seta"], "place": "tenda_campo", "stack": 5,
		"desc": "Piantala dove esplori; clic destro: rinasci qui e le creature non nascono attorno al campo."},
	"cannocchiale": {"name": "Cannocchiale di ambra", "kind": "cannocchiale", "icon": ["occhio", "ambra"], "stack": 1,
		"desc": "Guarda lontano: il clic scopre la mappa attorno al punto che guardi (3 Linfa)."},
	"bussola_meraviglie": {"name": "Bussola delle meraviglie", "kind": "bussola", "icon": ["occhio", "iride"], "stack": 1,
		"desc": "Il clic dice dove sta la meraviglia più vicina che non hai ancora visto, in questo mondo."},
	"radice_ritorno": {"name": "Radice di ritorno", "kind": "radice_ritorno", "icon": ["radice_viaggio", "radice"], "stack": 20,
		"desc": "Spezzala: ti riporta al Giardino, da qualunque mondo."},
}
const RECIPES := [
	{"out": "tenda_campo", "qty": 1, "in": {"legno": 20, "seta_radice": 4, "gelatina": 4}, "station": "telaio"},
	{"out": "cannocchiale", "qty": 1, "in": {"lingotto_ambra": 3, "cristallo_linfa": 2}, "station": "maglio"},
	{"out": "bussola_meraviglie", "qty": 1, "in": {"lingotto_legnoferro": 4, "polvere_iridata": 1, "cristallo_linfa": 1}, "station": "maglio"},
	{"out": "radice_ritorno", "qty": 3, "in": {"legno": 6, "gelatina": 2, "seme_lanterna": 1}, "station": "ceppo"},
]
