class_name SummonData
## Evocare i Guardiani già risolti (voce 84, Roadmap 12). Solo dati: le regole in `Summons`.
##   CALLS   i Richiami dei Guardiani scritti a mano (uno per Guardiano): la creatura, e il bottino di un'evocazione
##           (più magro del primo incontro: niente Linfa antica, Semi di mondo, Vita per sempre)
##   i Guardiani generati si evocano con il loro **Sigillo** (lo lascia il Cuore la prima volta, con il seme del mondo
##   nei "dati") e un **Seme d'eco** che si consuma
##   ARENA   il Cerchio dei Seminatori: l'evocazione si fa lì vicino, e durante lo scontro attorno non nasce niente

## Voce 373: più i Richiami dei Guardiani della spina (pacchetto `guardiani.gd`, campo «calls»).
static var CALLS: Dictionary = _CALLS.merged(BiomesData.pack("calls"))
const _CALLS := {
	"richiamo_nodo": {"creature": "guardiano_nodo",
		"loot": {"frammento_nodo": [10, 14], "scheggia_vuoto": [3, 6], "lumino": [60, 90]}},
	"richiamo_regina": {"creature": "regina_spore",
		"loot": {"velo_spora": [10, 14], "sacca_spore": [4, 8], "lumino": [80, 110]}},
	"richiamo_colosso": {"creature": "colosso_ardesia",
		"loot": {"nucleo_colosso": [10, 14], "scaglia_ardesia": [8, 12], "lumino": [100, 140]}},
	"richiamo_nero": {"creature": "avvizzitore",
		"loot": {"scheggia_nera": [2, 3], "lumino": [150, 220]}},
}
## Il bottino di un Guardiano generato evocato: i suoi Nuclei (meno del primo incontro).
const GEN_DROP := 6
const ARENA_R := 34                    # tessere: dal Cerchio si evoca entro questa distanza; attorno niente nascite
const REACH := 8                       # tessere: bisogna stare così vicini al Cerchio per evocare

const ITEMS := {
	"richiamo_nodo": {"name": "Radice di richiamo", "kind": "richiamo", "icon": ["tronco", "nodo"], "stack": 10,
		"desc": "Al Cerchio dei Seminatori risveglia il Nodo Avvizzito, se l'hai già affrontato."},
	"richiamo_regina": {"name": "Spora di richiamo", "kind": "richiamo", "icon": ["sacca", "nottilite"], "stack": 10,
		"desc": "Al Cerchio dei Seminatori risveglia la Regina delle Spore, se l'hai già affrontata."},
	"richiamo_colosso": {"name": "Pietra di richiamo", "kind": "richiamo", "icon": ["zolla", "ardesia"], "stack": 10,
		"desc": "Al Cerchio dei Seminatori risveglia il Colosso d'Ardesia, se l'hai già affrontato."},
	"richiamo_nero": {"name": "Guscio di richiamo", "kind": "richiamo", "icon": ["seme", "vuotite"], "stack": 10,
		"desc": "Al Cerchio dei Seminatori risveglia ciò che uscì dal Seme Nero, se l'hai già affrontato."},
	"seme_eco": {"name": "Seme d'eco", "kind": "materiale", "icon": ["seme", "brillaluce"], "stack": 20, "value": 40,
		"used_for": "evocare un Guardiano generato con il suo Sigillo",
		"desc": "Un seme vuoto che ripete l'ultima cosa che ha sentito. Con il Sigillo di un Guardiano, lo richiama."},
	"sigillo_guardiano": {"name": "Sigillo del Guardiano", "kind": "richiamo", "icon": ["tavoletta", "ambra"], "stack": 1,
		"source": "il Cuore di un mondo con un Guardiano generato, la prima volta che lo risolvi",
		"desc": "Ricorda il Guardiano di un mondo. Al Cerchio dei Seminatori, con un Seme d'eco, lo richiama; il Sigillo resta."},
	"cerchio_arena": {"name": "Cerchio dei Seminatori", "kind": "stazione", "icon": ["altare", "brillaluce"],
		"place": "arena", "stack": 99,
		"desc": "Un anello di pietre con le rune: vicino, un Richiamo o un Sigillo risvegliano un Guardiano già affrontato, e attorno non nasce altro finché lo scontro dura."},
}

const RECIPES := [
	{"out": "cerchio_arena", "qty": 1, "in": {"pietra_seminatori": 20, "cristallo_linfa": 4, "torcia": 6}, "station": "maglio"},
	{"out": "richiamo_nodo", "qty": 1, "in": {"frammento_nodo": 8, "legno": 12}, "station": "arena"},
	{"out": "richiamo_regina", "qty": 1, "in": {"velo_spora": 8, "sacca_spore": 4}, "station": "arena"},
	{"out": "richiamo_colosso", "qty": 1, "in": {"nucleo_colosso": 8, "scaglia_ardesia": 6}, "station": "arena"},
	{"out": "richiamo_nero", "qty": 1, "in": {"scheggia_nera": 2, "linfa_antica": 1}, "station": "arena"},
	{"out": "seme_eco", "qty": 1, "in": {"lumino": 40, "cristallo_linfa": 3}, "station": "arena"},
]


static func of_creature(cid: String) -> String:
	for k in CALLS:
		if String(CALLS[k]["creature"]) == cid:
			return k
	return ""
