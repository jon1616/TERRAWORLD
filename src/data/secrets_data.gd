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
	# voce 97 (`PassSegretiAnomalie`)
	"camera_enigma": {"name": "Camera-enigma", "grade": 1, "from": "camere", "size": [0, 0],
		"desc": "una piccola camera dei Seminatori: si entra risolvendo i suoi tre meccanismi"},
	"visione": {"name": "Visione dei Seminatori", "grade": 1, "from": "visioni", "size": [0, 0],
		"desc": "un cerchio di pietre accese: entrandoci si vede qualcosa che è successo tanto tempo fa"},
	"anomalia": {"name": "Anomalia", "grade": 3, "from": "anomalie", "size": [0, 0],
		"desc": "una sola per mondo, e non sempre: qualcosa che non dovrebbe esserci"},
	# voce 96: costruiti apposta (`PassSegretiStanze`)
	"passaggio": {"name": "Passaggio nascosto", "grade": 0, "from": "passaggi", "size": [0, 0],
		"desc": "un cunicolo tra due grotte, chiuso da pareti finte"},
	"stanza_murata": {"name": "Stanza murata", "grade": 1, "from": "stanze_murate", "size": [0, 0],
		"desc": "una stanzetta dietro una parete finta, con uno scrigno"},
	"tesoro_sepolto": {"name": "Tesoro sepolto", "grade": 2, "from": "tesori", "size": [0, 0],
		"desc": "uno scrigno sotto terra: la mappa che lo indica sta in una stanza murata dello stesso mondo"},
	"nido_nascosto": {"name": "Nido nascosto", "grade": 2, "from": "nidi_nascosti", "size": [0, 0],
		"desc": "una tana chiusa nella roccia: dentro dorme una creatura rara"},
	"firma": {"name": "La firma del mondo", "grade": 3, "from": "firma", "size": [16, 10],
		"desc": "la cosa che si trova solo in questo mondo"},
}

## Voce 97: le anomalie (una per mondo, a volte nessuna: `ANOMALY_CHANCE`) e le visioni.
const ANOMALY_CHANCE := 0.7
const ANOMALIES := {
	"bolla": {"name": "Bolla di gravità rovesciata", "desc": "una colonna d'aria dove si cade verso l'alto"},
	"lago_cantante": {"name": "Lago che canta", "desc": "un laghetto circondato di cristallo cantante: vibra quando ti avvicini"},
	"albero_primo": {"name": "Albero antichissimo", "desc": "un albero più vecchio del mondo stesso"},
	"stella": {"name": "Stella che non si spegne", "desc": "una stella caduta in un cratere, ancora accesa"},
}
const VISIONS := [
	["Il primo Seme", "Vedi mani grandi che scavano la terra nera del Vuoto e ci lasciano cadere un seme. Il seme non germoglia. Le mani aspettano. Poi, dal nulla, una radice."],
	["La stele spezzata", "Un Seminatore scrive su una stele il nome di un mondo. Si ferma, cancella, riscrive. Alla fine spezza la pietra e la seppellisce."],
	["La notte senza stelle", "Il cielo del Giardino è pieno di stelle, poi una alla volta si spengono. L'ultima non si spegne: cade."],
	["Il Giardiniere", "Qualcuno cammina tra le Aiuole con un annaffiatoio di radice. Si volta, e per un attimo ti sembra di vedere il tuo viso."],
	["La porta chiusa", "Una porta dei Seminatori si chiude da dentro. Dietro, qualcuno canta piano per non avere paura."],
	["Il Seme Nero", "Un seme scuro passa di mano in mano. Nessuno vuole piantarlo. Qualcuno lo pianta di notte, da solo."],
]

const R_ROD := 45                      # la bacchetta rabdomante sente i segreti entro 45 tessere
const ECHO_N := 3                      # l'Eco dei Seminatori segna sulla mappa i 3 segreti più vicini (a grandi linee)
const ECHO_BLUR := 12                  # di quanto sbaglia il segno dell'Eco (tessere)

const ITEMS := {
	"mappa_tesoro": {"name": "Mappa del tesoro", "kind": "mappa", "icon": ["mappa", "legno"], "stack": 1,
		"source": "in uno scrigno di una stanza murata (dietro una parete finta)",
		"desc": "Clic: segna sulla mappa dove è sepolto il tesoro di questo mondo. Poi bisogna scavare."},
	"bacchetta_rabdomante": {"name": "Bacchetta rabdomante", "kind": "accessorio", "icon": ["bastone", "legno"], "stack": 1,
		"desc": "Indossata o in mano vibra vicino a un segreto non ancora trovato: più vibra, più è vicino."},
	"eco_seminatori": {"name": "Eco dei Seminatori", "kind": "mappa", "icon": ["gemma", "sem"], "stack": 20,
		"desc": "Clic: un canto che rimbalza nel mondo. Sulla mappa si segnano, a grandi linee, i tre segreti più vicini."},
}

const RECIPES := [
	{"out": "bacchetta_rabdomante", "qty": 1, "in": {"legno": 8, "lingotto_radicite": 2, "cristallo_linfa": 1}, "station": "ceppo"},
	{"out": "eco_seminatori", "qty": 2, "in": {"cristallo_linfa": 1, "linfa_antica": 1, "pietra_seminatori": 4}, "station": "maglio"},
]
