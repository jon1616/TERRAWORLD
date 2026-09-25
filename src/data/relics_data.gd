class_name RelicsData
extends RefCounted
## Le reliquie dei Seminatori (voce 28): dodici oggetti nascosti nei **reliquiari**, dentro stanze murate senza porta
## sparse nel profondo (passata Nascondigli). Si raccolgono in tre **collezioni**: trovati tutti i pezzi di una
## collezione (basta averli avuti nella Bisaccia una volta: li ricorda l'Erbario), il Germogliato riceve il suo bonus
## per sempre. La **Mappa dei Seminatori** indica il reliquiario più vicino non ancora aperto. Solo dati; gli oggetti
## sono uniti in `ItemsData.all()`, i bonus li somma `GearEffects`.

const COLLECTIONS := {
	"attrezzi": {"name": "Attrezzi dei Seminatori", "strata": [1, 2],
		"pieces": ["zappa_seminatori", "falcetto_seminatori", "annaffiatoio_seminatori", "sementiera_seminatori"],
		"bonus": {"dig": 1.15, "luck": 0.1}, "desc": "scavo +15%, un po' più di fortuna"},
	"canti": {"name": "Canti dei Seminatori", "strata": [2, 3],
		"pieces": ["tavoletta_alba", "tavoletta_giorno", "tavoletta_tramonto", "tavoletta_notte"],
		"bonus": {"linfa_regen": 1.25, "magic": 1.1}, "desc": "Linfa +25%, incantesimi +10%"},
	"semi": {"name": "Semi perduti", "strata": [3, 4],
		"pieces": ["seme_antico_ambra", "seme_antico_cristallo", "seme_antico_brace", "seme_antico_vuoto"],
		"bonus": {"regen": 1.25, "defense": 3}, "desc": "la Vita ricresce il 25% più in fretta, +3 Scorza"},
}

const _R := "Una reliquia dei Seminatori, da un reliquiario nascosto. Trovale tutte e quattro della sua collezione."

const ITEMS := {
	"zappa_seminatori": {"name": "Zappa dei Seminatori", "kind": "reliquia", "icon": ["piccone", "sem"], "stack": 1, "desc": _R},
	"falcetto_seminatori": {"name": "Falcetto dei Seminatori", "kind": "reliquia", "icon": ["falce", "sem"], "stack": 1, "desc": _R},
	"annaffiatoio_seminatori": {"name": "Annaffiatoio dei Seminatori", "kind": "reliquia", "icon": ["goccia", "sem"], "stack": 1, "desc": _R},
	"sementiera_seminatori": {"name": "Sementiera dei Seminatori", "kind": "reliquia", "icon": ["sacca", "sem"], "stack": 1, "desc": _R},
	"tavoletta_alba": {"name": "Tavoletta dell'alba", "kind": "reliquia", "icon": ["tavoletta", "ambra"], "stack": 1, "desc": _R},
	"tavoletta_giorno": {"name": "Tavoletta del giorno", "kind": "reliquia", "icon": ["tavoletta", "cristallo"], "stack": 1, "desc": _R},
	"tavoletta_tramonto": {"name": "Tavoletta del tramonto", "kind": "reliquia", "icon": ["tavoletta", "brace"], "stack": 1, "desc": _R},
	"tavoletta_notte": {"name": "Tavoletta della notte", "kind": "reliquia", "icon": ["tavoletta", "vuotite"], "stack": 1, "desc": _R},
	"seme_antico_ambra": {"name": "Seme antico d'ambra", "kind": "reliquia", "icon": ["seme", "ambra"], "stack": 1, "desc": _R},
	"seme_antico_cristallo": {"name": "Seme antico di cristallo", "kind": "reliquia", "icon": ["seme", "cristallo"], "stack": 1, "desc": _R},
	"seme_antico_brace": {"name": "Seme antico di brace", "kind": "reliquia", "icon": ["seme", "brace"], "stack": 1, "desc": _R},
	"seme_antico_vuoto": {"name": "Seme antico del Vuoto", "kind": "reliquia", "icon": ["seme", "vuotite"], "stack": 1, "desc": _R},
	"mappa_seminatori": {"name": "Mappa dei Seminatori", "kind": "mappa", "icon": ["mappa", "sem"], "stack": 20, "desc": "Una mappa incisa su una lastra sottile. Usala: indica il reliquiario nascosto più vicino che non hai ancora aperto e lo segna sulla mappa."},
}

const RECIPES := [
	{"out": "mappa_seminatori", "qty": 1, "in": {"pietra_seminatori": 5, "legno": 2, "gelatina": 2}, "station": "altare"},
]


## La collezione di una reliquia, o "".
static func collection_of(id: String) -> String:
	for c in COLLECTIONS:
		if id in COLLECTIONS[c]["pieces"]:
			return c
	return ""


## Le collezioni complete, secondo gli oggetti già trovati (`Character.erbario["oggetti"]`).
static func complete(found: Dictionary) -> Array:
	var out := []
	for c in COLLECTIONS:
		var all_in := true
		for p in COLLECTIONS[c]["pieces"]:
			if not found.has(p):
				all_in = false
		if all_in:
			out.append(c)
	return out
