class_name MasteryData
extends RefCounted
## I dieci pilastri del gioco e la loro maestria (Roadmap 20, voce 214; filosofia in CLAUDE.md, «I pilastri»). Solo dati:
## le regole stanno in `Mastery`. I punti valgono circa **un minuto** di quell'attività: il grado 10 di un pilastro arriva
## nelle sue ore obiettivo (`hours`, dal piano «Le dieci strade»), e la curva (`CURVE`) fa arrivare i primi gradi presto.
##   pillars  id → nome, colore, icona [forma, materiale], ore, descrizione, «hint» (il passo tipico, per il Libro)
##   STATS    un conteggio del personaggio (`Objectives.bump`) → [[pilastro, punti per unità], …]
##   STATION  la stazione di una ricetta fabbricata → pilastro (punti `CRAFT_PTS`; l'equipaggiamento `GEAR_PTS`)

const GRADES := 10
const CURVE := 2.0                      # il grado 1 all'1% delle ore del pilastro (la prima ora di gioco), il 5 al 25%
const CRAFT_PTS := 1.0
const GEAR_PTS := 3.0
const CELLS_PER_PT := 250.0            # celle della mappa scoperte per un punto di esplorazione
const KILL_HP_PER_PT := 60.0           # punti di Vita delle creature sconfitte per un punto di combattimento
const BLOCK_PTS := 0.05                # un blocco posato (Giardino)
const WORD_PTS := 6.0                  # una parola dei Seminatori diventata certa (misteri)

const ORDER := ["storia", "esplorazione", "combattimento", "giardino", "abitanti", "mandria", "orto", "pesca", "rete",
	"misteri"]

const PILLARS := {
	"storia": {"name": "La storia", "color": Color("#ffd24a"), "icon": ["seme", "sem"], "hours": 120,
		"desc": "L'Albero-Madre, le catene dei Seminatori, il Seme Nero.",
		"hint": "porta all'Albero-Madre ciò che chiede, segui le catene"},
	"esplorazione": {"name": "L'esplorazione", "color": Color("#5cf0e0"), "icon": ["mappa", "legno"], "hours": 70,
		"desc": "I mondi nati dai Semi, le firme, i segreti, il cielo e il profondo.",
		"hint": "pianta un Seme nuovo, cerca la firma e i segreti del mondo"},
	"combattimento": {"name": "Il combattimento", "color": Color("#ff8a6a"), "icon": ["spada", "legnoferro"], "hours": 60,
		"desc": "Le creature, i Guardiani, i Signori, le maree e le sfide.",
		"hint": "sconfiggi un Signore, respingi una marea, affronta un Guardiano"},
	"giardino": {"name": "Il Giardino e la base", "color": Color("#8ef070"), "icon": ["mattoni", "legno"], "hours": 50,
		"desc": "Costruire, arredare, fare stanze e progetti.",
		"hint": "costruisci una stanza nuova o un progetto dei Seminatori"},
	"abitanti": {"name": "Gli abitanti", "color": Color("#ffb0d0"), "icon": ["cuore", "ambra"], "hours": 30,
		"desc": "Chi vive nel Giardino: legami, richieste, case, la Bacheca.",
		"hint": "completa una richiesta di un abitante o della Bacheca"},
	"mandria": {"name": "La mandria", "color": Color("#e0c080"), "icon": ["uovo", "muschio"], "hours": 40,
		"desc": "Addomesticare, allevare, cavalcare.",
		"hint": "addomestica una famiglia nuova, fai nascere un uovo"},
	"orto": {"name": "L'orto e la cucina", "color": Color("#b0e060"), "icon": ["seme", "muschio"], "hours": 30,
		"desc": "Seminare, raccogliere, cucinare e distillare.",
		"hint": "semina e raccogli, cucina al paiolo, distilla all'alambicco"},
	"pesca": {"name": "La pesca", "color": Color("#8ad8ff"), "icon": ["pesce", "lagunite"], "hours": 25,
		"desc": "Le acque di ogni mondo e ciò che ci vive.",
		"hint": "pesca una specie che non hai ancora"},
	"rete": {"name": "La rete di Linfa", "color": Color("#6ff0c0"), "icon": ["radice_viaggio", "linfa"], "hours": 35,
		"desc": "Vene, fili, macchine e le Centrali dei Seminatori.",
		"hint": "costruisci una macchina nuova, risveglia una Centrale"},
	"misteri": {"name": "I misteri e le collezioni", "color": Color("#c090ff"), "icon": ["tavoletta", "sem"], "hours": 50,
		"desc": "La lingua dei Seminatori, le reliquie, gli unici, i trofei, lo studio.",
		"hint": "decifra una stele, completa una serie, studia una specie"},
}

## Un conteggio del personaggio → i pilastri che nutre (punti per unità ≈ minuti di fatica).
const STATS := {
	"albero": [["storia", 150.0]], "catene": [["storia", 90.0], ["misteri", 20.0]], "cuore": [["storia", 30.0]],
	"guardiani": [["storia", 60.0], ["combattimento", 40.0]], "leggende": [["storia", 120.0]], "seme_primo": [["storia", 300.0]],
	"viaggi": [["esplorazione", 20.0]], "firme": [["esplorazione", 45.0]], "segreti": [["esplorazione", 15.0]],
	"sigilli": [["esplorazione", 20.0]], "reliquiari": [["esplorazione", 15.0], ["misteri", 15.0]], "scrigni": [["esplorazione", 5.0]],
	"mondi_completi": [["esplorazione", 90.0]], "radici_viaggi": [["esplorazione", 3.0]], "nascoste": [["esplorazione", 10.0]],
	"geni_imparati": [["esplorazione", 10.0]], "mutazioni": [["storia", 20.0]],
	"signori": [["combattimento", 45.0]], "grandi_guardiani": [["combattimento", 90.0]], "custodi": [["combattimento", 40.0]],
	"maree_vinte": [["combattimento", 40.0]], "evocati": [["combattimento", 30.0]], "sfide": [["combattimento", 30.0]],
	"occhio_tempesta": [["combattimento", 90.0]], "eventi_vinti": [["combattimento", 15.0]],
	"stanze": [["giardino", 20.0]], "progetti": [["giardino", 40.0]],
	"abitanti": [["abitanti", 60.0]], "richieste": [["abitanti", 25.0]], "bacheca": [["abitanti", 20.0]],
	"addomesticate": [["mandria", 20.0]], "uova": [["mandria", 5.0]], "schiuse": [["mandria", 15.0]],
	"uova_allevate": [["mandria", 30.0]], "manti_rari": [["mandria", 60.0]], "coppie": [["mandria", 10.0]],
	"cavalcate": [["mandria", 5.0]], "prodotti": [["mandria", 1.0]], "mandria_prede": [["mandria", 2.0]],
	"alleati": [["mandria", 3.0]],
	"semine": [["orto", 1.0]], "raccolti": [["orto", 1.5]], "purificate": [["orto", 2.0]],
	"pesci": [["pesca", 0.3]], "specie_pescate": [["pesca", 10.0]], "pesci_leggendari": [["pesca", 60.0]],
	"macchine": [["rete", 8.0]], "centrali": [["rete", 60.0]], "primo_circuito": [["rete", 20.0]],
	"stele": [["misteri", 8.0]], "scrigni_parola": [["misteri", 12.0]], "unici": [["misteri", 20.0]],
	"serie_unici": [["misteri", 90.0]], "oggetti_trofeo": [["misteri", 20.0]], "studiate": [["misteri", 20.0]],
}

## La stazione di una ricetta → il pilastro che nutre fabbricando.
const STATION := {"paiolo": "orto", "alambicco": "orto", "frantoio": "rete", "arena": "combattimento",
	"scalpellino": "giardino", "altare": "combattimento", "mola": "combattimento"}
## I tipi di oggetto fabbricato che contano per un pilastro, qualunque sia la stazione.
const KIND := {"stazione": "giardino", "blocco": "giardino", "parete": "giardino", "esca": "pesca", "canna": "pesca",
	"vena": "rete", "filo": "rete", "coltura": "orto", "seme": "orto"}


## I punti per arrivare al grado g (cumulativi).
static func points_for(pillar: String, g: int) -> float:
	if g <= 0:
		return 0.0
	var total := float(PILLARS[pillar]["hours"]) * 60.0
	return roundf(total * pow(float(g) / GRADES, CURVE))


## Il grado con questi punti.
static func grade_of(pillar: String, pts: float) -> int:
	var g := 0
	while g < GRADES and pts >= points_for(pillar, g + 1):
		g += 1
	return g


## I premi dei gradi (voce 215): pilastro → grado → {"items": {…}, "bonus": {chiavi di `GearEffects`}, "text"}.
const REWARDS := {}


static func reward(pillar: String, g: int) -> Dictionary:
	return (REWARDS.get(pillar, {}) as Dictionary).get(g, {})
