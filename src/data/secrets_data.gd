class_name SecretsData
## I segreti dei mondi (voce 95, Roadmap 12). Solo dati: il generatore li elenca (`PassSegreti`), `Secrets` li
## conta, li riconosce quando ci entri e dà il premio. Un mondo non è finito finché il contatore non è pieno.
##
## Gradi: quanto è nascosto e quanto rende (tabella di bottino, Lumini, probabilità di un oggetto unico).
## Tipi (`KINDS`): nome, grado, frase per la scheda, e da quali appunti del generatore nascono (`from`, letti da
## `PassSegreti`): i posti nascosti che il generatore fa già (reliquiari murati, stanze dei Sigilli, isole sospese,
## luoghi dei Seminatori, la firma) e quelli delle voci 96-97. `size` = il riquadro in tessere attorno al punto che
## conta come «dentro» (si scopre entrandoci).

const GRADES := [
	{"name": "facile", "color": "#9fe070", "loot": "rovina_1", "lumini": 10, "unique": 0.0},
	{"name": "nascosto", "color": "#8ef0d8", "loot": "rovina_2", "lumini": 25, "unique": 0.04},
	{"name": "profondo", "color": "#b890ff", "loot": "rovina_3", "lumini": 60, "unique": 0.12},
	{"name": "leggendario", "color": "#ffd24a", "loot": "rovina_4", "lumini": 150, "unique": 0.4},
]

const KINDS := {
	"reliquiario": {"name": "Reliquiario murato", "grade": 1, "from": "nascondigli", "size": [9, 7],
		"desc": "una stanzetta murata dove i Seminatori nascondevano una reliquia"},
	"stanza_sigillata": {"name": "Stanza sigillata", "grade": 2, "from": "sigilli", "size": [11, 9],
		"desc": "dietro un Sigillo che solo un potere dell'Albero-Madre apre"},
	"isola_sospesa": {"name": "Isola sospesa", "grade": 1, "from": "isole", "size": [30, 16],
		"desc": "un pezzo di terra che galleggia nel cielo"},
	"luogo": {"name": "Luogo dei Seminatori", "grade": 2, "from": "luoghi", "size": [0, 0],
		"desc": "un luogo scritto a mano, con il suo enigma"},
	"firma": {"name": "La firma del mondo", "grade": 3, "from": "firma", "size": [16, 10],
		"desc": "la cosa che si trova solo in questo mondo"},
}

const R_ROD := 45                      # la bacchetta rabdomante sente i segreti entro 45 tessere
const ECHO_N := 3                      # l'Eco dei Seminatori segna sulla mappa i 3 segreti più vicini (a grandi linee)
const ECHO_BLUR := 12                  # di quanto sbaglia il segno dell'Eco (tessere)

const ITEMS := {
	"bacchetta_rabdomante": {"name": "Bacchetta rabdomante", "kind": "accessorio", "icon": ["bastone", "legno"], "stack": 1,
		"desc": "Indossata o in mano vibra vicino a un segreto non ancora trovato: più vibra, più è vicino."},
	"eco_seminatori": {"name": "Eco dei Seminatori", "kind": "mappa", "icon": ["gemma", "sem"], "stack": 20,
		"desc": "Clic: un canto che rimbalza nel mondo. Sulla mappa si segnano, a grandi linee, i tre segreti più vicini."},
}

const RECIPES := [
	{"out": "bacchetta_rabdomante", "qty": 1, "in": {"legno": 8, "lingotto_radicite": 2, "cristallo_linfa": 1}, "station": "ceppo"},
	{"out": "eco_seminatori", "qty": 2, "in": {"cristallo_linfa": 1, "linfa_antica": 1, "pietra_seminatori": 4}, "station": "maglio"},
]
