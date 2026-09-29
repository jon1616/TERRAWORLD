class_name WondersData
extends RefCounted
## Le meraviglie (Roadmap 23, voce 237): dodici luoghi naturali fuori misura, generati da `PassMeraviglie` (da due a
## tre per mondo, secondo il caso, il vigore e i geni). Vederle (la mappa le scopre) le segna nell'Atlante; al loro centro
## c'è un **cuore della meraviglia** (stazione) che dona, una volta per mondo, il suo ricordo: un materiale che esiste solo
## lì, per gli oggetti dell'esploratore (ricette in fondo: ogni ricordo serve a uno dei tre accessori). Le regole in `Wonders`.
##   name, desc   nome e frase (avviso, Atlante)
##   where        "sup" (sulla superficie) o lo strato (1-4) dove nasce
##   weight       quanto spesso (le rare: 1)
##   genes        i geni che la chiamano (peso ×4 se il mondo ne ha uno)
##   memento      [nome del ricordo, forma dell'icona, materiale dell'icona, frase]

const WONDERS := {
	"arco_pietra": {"name": "L'Arco di pietra", "desc": "Un arco d'ardesia alto come dieci alberi: nessuno sa chi l'abbia piegato.",
		"where": "sup", "weight": 3, "genes": ["montagne", "altopiano", "frastagliato"],
		"memento": ["Scaglia dell'Arco", "geode", "ardesia", "Una scheggia d'ardesia liscia come il vetro, calda al tatto."]},
	"cratere_stella": {"name": "Il Cratere della stella", "desc": "Qui cadde una stella: il fondo è ancora di cristallo.",
		"where": "sup", "weight": 3, "genes": ["stellato", "cuore_stellare", "vene_stellari"],
		"memento": ["Polvere di stella caduta", "stella", "stelle", "Brilla anche nella Bisaccia."]},
	"ponte_giganti": {"name": "Il Ponte dei giganti", "desc": "Una lingua di roccia sospesa sopra una voragine senza fondo apparente.",
		"where": "sup", "weight": 3, "genes": ["voragini", "arcipelago"],
		"memento": ["Chiave del Ponte", "chiave", "ardesia", "Una pietra a forma di chiave, trovata dove il ponte si regge."]},
	"pozzo_abisso": {"name": "Il Pozzo senza fondo", "desc": "Un pozzo perfetto che scende dalla superficie fino alle Profondità.",
		"where": "sup", "weight": 2, "genes": ["cavo", "abissale"],
		"memento": ["Eco del Pozzo", "occhio", "vuotite", "Se lo avvicini all'orecchio senti cadere un sasso che non tocca mai terra."]},
	"radice_cosmo": {"name": "La Radice del cosmo", "desc": "Una radice delle Chiome è scesa fin qui e ha trapassato la terra.",
		"where": "sup", "weight": 1, "genes": ["radici_giganti", "radice_madre", "radici_vive"],
		"memento": ["Midollo della Radice", "radice_viaggio", "radice", "Il cuore di una radice che viene dal cielo."]},
	"albero_fossile": {"name": "L'Albero fossile", "desc": "Un albero-lanterna dei primi giorni, diventato ambra in piedi.",
		"where": 1, "weight": 3, "genes": ["resina", "ancestrale"],
		"memento": ["Baccello fossile", "gemma", "ambra", "Un baccello d'ambra con dentro un seme che non è mai nato."]},
	"scheletro_gigante": {"name": "Lo Scheletro del Gigante", "desc": "Le ossa di una bestia più grande di qualunque Guardiano.",
		"where": 1, "weight": 1, "genes": ["ancestrale", "rovine_sepolte"],
		"memento": ["Vertebra del Gigante", "guscio", "pallidite", "Pesa come una pietra, ma è un osso."]},
	"foresta_cristallo": {"name": "La Foresta di cristallo", "desc": "Una sala dove i cristalli di Linfa crescono come alberi.",
		"where": 2, "weight": 3, "genes": ["cristalli_giganti", "cristalli_vivi"],
		"memento": ["Ramo di cristallo", "gemma", "cristallo", "Un ramo di cristallo che canta se lo muovi."]},
	"lago_nascosto": {"name": "Il Lago nascosto", "desc": "Un lago intero, fermo e scuro, sotto la roccia.",
		"where": 2, "weight": 3, "genes": ["sommerso", "sorgenti"],
		"memento": ["Perla del Lago nascosto", "gemma", "lagunite", "Non ha mai visto il sole."]},
	"coppa_linfa": {"name": "La Coppa di Linfa", "desc": "Una coppa di cristallo grande come una casa, piena di Linfa.",
		"where": 3, "weight": 2, "genes": ["laghi_linfa", "sorgenti"],
		"memento": ["Goccia della Coppa", "gel", "linfa", "Una goccia di Linfa che non si asciuga."]},
	"geode_gigante": {"name": "La Geode gigante", "desc": "Una sfera cava di cristallo in cui si può camminare.",
		"where": 3, "weight": 3, "genes": ["geodi_fitti", "geodi_brina"],
		"memento": ["Cuore della Geode", "geode", "cristallo", "Il cristallo più puro, dal centro della sfera."]},
	"occhio_brace": {"name": "L'Occhio di brace", "desc": "Un lago di brace rotondo che guarda il soffitto come un occhio.",
		"where": 4, "weight": 1, "genes": ["fiumi_brace", "cenere"],
		"memento": ["Pupilla di brace", "occhio", "brace", "Non si spegne. Non scotta. Guarda."]},
}

const MIN_COUNT := 2
const EXTRA_VIGOR := 4                  # dal vigore 4 una meraviglia in più

## Gli oggetti dell'esploratore che nascono dai ricordi (al Maglio dei Seminatori).
const GEAR := {
	"mappamondo": {"name": "Mappamondo dei Seminatori", "kind": "accessorio", "icon": ["stella", "sem"],
		"acc": {"run": 1.08, "halo": 1.3}, "desc": "Fatto con i ricordi di quattro meraviglie: corsa +8%, alone più ampio."},
	"bussola_cosmo": {"name": "Bussola del cosmo", "kind": "accessorio", "icon": ["occhio", "stelle"],
		"acc": {"run": 1.12, "jump": 1.06, "halo": 1.5}, "desc": "Fatta con i ricordi delle meraviglie più rare: corsa +12%, salto +6%, alone ampio."},
	"sigillo_viandante": {"name": "Sigillo del viandante", "kind": "accessorio", "icon": ["collana", "ambra"],
		"acc": {"run": 1.05, "respiro": 1.4, "dash_cd": 0.85}, "desc": "Cinque ricordi di luoghi lontani: corsa +5%, fiato più lungo sott'acqua, schivata più pronta."},
}
const RECIPES := [
	{"out": "mappamondo", "qty": 1, "in": {"ricordo_arco_pietra": 1, "ricordo_cratere_stella": 1, "ricordo_foresta_cristallo": 1,
		"ricordo_geode_gigante": 1, "polvere_iridata": 3}, "station": "maglio"},
	{"out": "bussola_cosmo", "qty": 1, "in": {"mappamondo": 1, "ricordo_radice_cosmo": 1, "ricordo_scheletro_gigante": 1,
		"ricordo_occhio_brace": 1, "linfa_antica": 4}, "station": "maglio"},
	{"out": "sigillo_viandante", "qty": 1, "in": {"ricordo_ponte_giganti": 1, "ricordo_pozzo_abisso": 1, "ricordo_albero_fossile": 1,
		"ricordo_lago_nascosto": 1, "ricordo_coppa_linfa": 1, "polvere_iridata": 3}, "station": "maglio"},
]


static func memento_id(k: String) -> String:
	return "ricordo_" + k


## I ricordi e gli oggetti dell'esploratore (uniti in `ItemsData.all()`).
static func items() -> Dictionary:
	var out := {}
	for k in WONDERS:
		var mm: Array = WONDERS[k]["memento"]
		out[memento_id(k)] = {"name": String(mm[0]), "kind": "materiale", "icon": [String(mm[1]), String(mm[2])],
			"source": "meraviglia", "desc": "%s Si trova solo nel cuore di %s." % [mm[3], String(WONDERS[k]["name"]).to_lower()]}
	for k in GEAR:
		out[k] = GEAR[k]
	return out
