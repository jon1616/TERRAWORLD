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
	"esplorazione": {"name": "L'esplorazione", "color": Color("#5cf0e0"), "icon": ["mappa", "legno"], "hours": 90,
		"desc": "I mondi nati dai Semi, le firme, i segreti, il cielo e il profondo.",
		"hint": "pianta un Seme nuovo, cerca la firma e i segreti del mondo"},
	"combattimento": {"name": "Il combattimento", "color": Color("#ff8a6a"), "icon": ["spada", "legnoferro"], "hours": 75,
		"desc": "Le creature, i Guardiani, i Signori, le maree e le sfide.",
		"hint": "sconfiggi un Signore, respingi una marea, affronta un Guardiano"},
	"giardino": {"name": "Il Giardino e la base", "color": Color("#8ef070"), "icon": ["mattoni", "legno"], "hours": 50,
		"desc": "Costruire, arredare, fare stanze e progetti.",
		"hint": "costruisci una stanza nuova o un progetto dei Seminatori"},
	"abitanti": {"name": "Gli abitanti", "color": Color("#ffb0d0"), "icon": ["cuore", "ambra"], "hours": 40,
		"desc": "Chi vive nel Giardino: legami, richieste, case, la Bacheca.",
		"hint": "completa una richiesta di un abitante o della Bacheca"},
	"mandria": {"name": "La mandria", "color": Color("#e0c080"), "icon": ["uovo", "muschio"], "hours": 70,
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
	"misteri": {"name": "I misteri e le collezioni", "color": Color("#c090ff"), "icon": ["tavoletta", "sem"], "hours": 60,
		"desc": "La lingua dei Seminatori, le reliquie, gli unici, i trofei, lo studio.",
		"hint": "decifra una stele, completa una serie, studia una specie"},
}

## Un conteggio del personaggio → i pilastri che nutre (punti per unità ≈ minuti di fatica).
const STATS := {
	"albero": [["storia", 150.0]], "perduti": [["storia", 120.0]], "stelle": [["esplorazione", 10.0]], "stirpi_pure": [["mandria", 90.0]], "ranghi_arma": [["combattimento", 20.0]], "museo": [["misteri", 12.0]], "fossili": [["misteri", 8.0]], "cronache": [["misteri", 40.0]], "medaglie_pesca": [["pesca", 6.0]], "ori_pesca": [["pesca", 12.0]], "gare_pesca": [["pesca", 10.0]], "contratti": [["rete", 40.0]], "traguardi": [["misteri", 60.0]], "sale_museo": [["misteri", 60.0]], "tecniche": [["combattimento", 0.5]], "taglie": [["combattimento", 40.0]], "prove_ondate": [["combattimento", 6.0]], "prove_vinte": [["combattimento", 60.0]], "fiere": [["mandria", 5.0]], "ritrovamenti": [["mandria", 3.0]], "ottimi": [["orto", 5.0]], "piatti": [["orto", 4.0]], "ibridi": [["orto", 45.0]], "medaglie": [["mandria", 15.0]], "ori": [["mandria", 30.0]], "collezione_manti": [["mandria", 20.0]], "spedizioni": [["esplorazione", 30.0]], "meraviglie": [["esplorazione", 30.0]], "ricordi": [["esplorazione", 5.0]], "pagine_biomi": [["esplorazione", 60.0]], "catene": [["storia", 90.0], ["misteri", 20.0]], "cuore": [["storia", 30.0]],
	"guardiani": [["storia", 60.0], ["combattimento", 40.0]], "leggende": [["storia", 120.0]], "seme_primo": [["storia", 300.0]],
	"viaggi": [["esplorazione", 20.0]], "firme": [["esplorazione", 45.0]], "segreti": [["esplorazione", 15.0]],
	"sigilli": [["esplorazione", 20.0]], "reliquiari": [["esplorazione", 15.0], ["misteri", 15.0]], "scrigni": [["esplorazione", 5.0]],
	"mondi_completi": [["esplorazione", 90.0]], "radici_viaggi": [["esplorazione", 3.0]], "nascoste": [["esplorazione", 10.0]],
	"geni_imparati": [["esplorazione", 10.0]], "mutazioni": [["storia", 20.0]],
	"signori": [["combattimento", 45.0]], "grandi_guardiani": [["combattimento", 90.0]], "custodi": [["combattimento", 40.0]],
	"maree_vinte": [["combattimento", 40.0]], "evocati": [["combattimento", 30.0]], "sfide": [["combattimento", 30.0]],
	"occhio_tempesta": [["combattimento", 90.0]], "eventi_vinti": [["combattimento", 15.0]],
	"stanze": [["giardino", 20.0]], "progetti": [["giardino", 40.0]], "isole": [["giardino", 60.0]], "opere": [["giardino", 120.0]], "feste": [["giardino", 30.0], ["abitanti", 15.0]],
	"abitanti": [["abitanti", 60.0]], "visitatori": [["abitanti", 10.0]], "richieste": [["abitanti", 25.0]], "capitoli": [["abitanti", 30.0]], "botteghe": [["abitanti", 3.0]], "bacheca": [["abitanti", 20.0]],
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
const REWARDS := {
	"storia": {
		1: {"items": {"lumino": 80}},
		2: {"bonus": {"regen": 1.03}, "text": "la Vita ricresce +3%"},
		3: {"items": {"linfa_antica": 2}},
		4: {"bonus": {"regen": 1.03}, "text": "la Vita ricresce +3%"},
		5: {"items": {"provetta": 5, "linfa_antica": 2}},
		6: {"bonus": {"regen": 1.03, "luck": 0.03}, "text": "la Vita ricresce +3%, fortuna +3%"},
		7: {"items": {"polvere_iridata": 2, "linfa_antica": 3}},
		8: {"bonus": {"regen": 1.03, "luck": 0.03}, "text": "la Vita ricresce +3%, fortuna +3%"},
		9: {"items": {"linfa_antica": 4, "polvere_iridata": 2}},
		10: {"bonus": {"regen": 1.05, "luck": 0.05, "damage": 1.03}, "text": "la Vita ricresce +5%, fortuna +5%, danno +3%"},
	},
	"esplorazione": {
		1: {"items": {"torcia": 30}},
		2: {"bonus": {"run": 1.02}, "text": "corsa +2%"},
		3: {"items": {"mappa_seminatori": 1}},
		4: {"bonus": {"run": 1.02, "halo": 1.05}, "text": "corsa +2%, alone +5%"},
		5: {"items": {"mappa_sigilli": 1, "provetta": 5}},
		6: {"bonus": {"run": 1.02, "jump": 1.02}, "text": "corsa +2%, salto +2%"},
		7: {"items": {"mappa_firma": 1}},
		8: {"bonus": {"run": 1.02, "halo": 1.05}, "text": "corsa +2%, alone +5%"},
		9: {"items": {"mappa_firma": 1, "mappa_sigilli": 1}},
		10: {"bonus": {"run": 1.04, "jump": 1.03, "dig": 1.08}, "text": "corsa +4%, salto +3%, scavo +8%"},
	},
	"combattimento": {
		1: {"items": {"pozione_rugiada": 3}},
		2: {"bonus": {"damage": 1.02}, "text": "danno +2%"},
		3: {"items": {"pozione_rigoglio": 3}},
		4: {"bonus": {"damage": 1.02, "defense": 1}, "text": "danno +2%, Scorza +1"},
		5: {"items": {"polvere_iridata": 1, "pozione_rugiada": 5}},
		6: {"bonus": {"damage": 1.02, "atk_speed": 1.02}, "text": "danno +2%, colpi +2%"},
		7: {"items": {"polvere_iridata": 2}},
		8: {"bonus": {"damage": 1.02, "defense": 1}, "text": "danno +2%, Scorza +1"},
		9: {"items": {"polvere_iridata": 3, "pozione_rigoglio": 5}},
		10: {"bonus": {"damage": 1.04, "defense": 2, "atk_speed": 1.03}, "text": "danno +4%, Scorza +2, colpi +3%"},
	},
	"giardino": {
		1: {"items": {"lumino": 60}},
		2: {"bonus": {"halo": 1.03}, "text": "alone +3%"},
		3: {"items": {"progetto_torre": 1}},
		4: {"bonus": {"regen": 1.02, "halo": 1.03}, "text": "la Vita ricresce +2%, alone +3%"},
		5: {"items": {"progetto_serra": 1, "lumino": 150}},
		6: {"bonus": {"regen": 1.02, "grow": 1.03}, "text": "la Vita ricresce +2%, l'orto cresce +3%"},
		7: {"items": {"progetto_faro": 1}},
		8: {"bonus": {"regen": 1.02, "halo": 1.03}, "text": "la Vita ricresce +2%, alone +3%"},
		9: {"items": {"progetto_sala_trofei": 1, "lumino": 300}},
		10: {"bonus": {"regen": 1.04, "halo": 1.05, "grow": 1.05}, "text": "la Vita ricresce +4%, alone +5%, l'orto cresce +5%"},
	},
	"abitanti": {
		1: {"items": {"lumino": 60}},
		2: {"bonus": {"luck": 0.02}, "text": "fortuna +2%"},
		3: {"items": {"lumino": 120}},
		4: {"bonus": {"luck": 0.02}, "text": "fortuna +2%"},
		5: {"items": {"linfa_antica": 2, "lumino": 150}},
		6: {"bonus": {"luck": 0.03}, "text": "fortuna +3%"},
		7: {"items": {"polvere_iridata": 1, "lumino": 200}},
		8: {"bonus": {"luck": 0.03}, "text": "fortuna +3%"},
		9: {"items": {"linfa_antica": 3, "lumino": 300}},
		10: {"bonus": {"luck": 0.05, "regen": 1.03}, "text": "fortuna +5%, la Vita ricresce +3%"},
	},
	"mandria": {
		1: {"items": {"laccio": 1}},
		2: {"bonus": {"herd": 1.05}, "text": "la mandria cresce di livello +5%"},
		3: {"items": {"vasetto": 3}},
		4: {"bonus": {"herd": 1.05}, "text": "la mandria cresce +5%"},
		5: {"items": {"laccio": 2, "vasetto": 3}},
		6: {"bonus": {"herd": 1.05, "run": 1.02}, "text": "la mandria cresce +5%, corsa +2%"},
		7: {"items": {"polvere_iridata": 1, "vasetto": 5}},
		8: {"bonus": {"herd": 1.05}, "text": "la mandria cresce +5%"},
		9: {"items": {"polvere_iridata": 2, "laccio": 3}},
		10: {"bonus": {"herd": 1.1, "run": 1.03}, "text": "la mandria cresce +10%, corsa +3%"},
	},
	"orto": {
		1: {"items": {"annaffiatoio": 1}},
		2: {"bonus": {"grow": 1.04}, "text": "l'orto cresce +4%"},
		3: {"items": {"pozione_rugiada": 2}},
		4: {"bonus": {"grow": 1.04}, "text": "l'orto cresce +4%"},
		5: {"items": {"pozione_rigoglio": 3}},
		6: {"bonus": {"grow": 1.04, "regen": 1.02}, "text": "l'orto cresce +4%, la Vita ricresce +2%"},
		7: {"items": {"polvere_iridata": 1}},
		8: {"bonus": {"grow": 1.04}, "text": "l'orto cresce +4%"},
		9: {"items": {"linfa_antica": 2, "pozione_rigoglio": 5}},
		10: {"bonus": {"grow": 1.08, "linfa_regen": 1.05}, "text": "l'orto cresce +8%, la Linfa torna +5%"},
	},
	"pesca": {
		1: {"items": {"esca_petali": 10}},
		2: {"bonus": {"fish_luck": 0.03}, "text": "fortuna di pesca +3%"},
		3: {"items": {"esca_squama": 10}},
		4: {"bonus": {"fish_luck": 0.03, "fish_size": 0.02}, "text": "fortuna di pesca +3%, pesci più grandi"},
		5: {"items": {"amo_ambra": 1}},
		6: {"bonus": {"fish_luck": 0.03, "fish_wait": 0.97}, "text": "fortuna di pesca +3%, abboccano prima"},
		7: {"items": {"esca_iridata": 10}},
		8: {"bonus": {"fish_luck": 0.03, "fish_size": 0.02}, "text": "fortuna di pesca +3%, pesci più grandi"},
		9: {"items": {"esca_iridata": 20, "polvere_iridata": 1}},
		10: {"bonus": {"fish_luck": 0.06, "fish_wait": 0.94, "fish_size": 0.04}, "text": "fortuna di pesca +6%, abboccano prima, pesci più grandi"},
	},
	"rete": {
		1: {"items": {"vena_legnoferro": 20}},
		2: {"bonus": {"pulsi": 1.03}, "text": "le sorgenti danno +3%"},
		3: {"items": {"vena_ambra": 20}},
		4: {"bonus": {"pulsi": 1.03}, "text": "le sorgenti danno +3%"},
		5: {"items": {"cristallo_linfa": 4, "vena_ambra": 20}},
		6: {"bonus": {"pulsi": 1.03}, "text": "le sorgenti danno +3%"},
		7: {"items": {"vena_cristallo": 10}},
		8: {"bonus": {"pulsi": 1.03}, "text": "le sorgenti danno +3%"},
		9: {"items": {"vena_cristallo": 20, "cristallo_linfa": 6}},
		10: {"bonus": {"pulsi": 1.08}, "text": "le sorgenti danno +8%"},
	},
	"misteri": {
		1: {"items": {"tavoletta_seminatori": 1}},
		2: {"bonus": {"magic": 1.02}, "text": "incantesimi +2%"},
		3: {"items": {"tavoletta_seminatori": 2}},
		4: {"bonus": {"magic": 1.02, "luck": 0.02}, "text": "incantesimi +2%, fortuna +2%"},
		5: {"items": {"stilo_seminatori": 1, "provetta": 5}},
		6: {"bonus": {"magic": 1.02}, "text": "incantesimi +2%"},
		7: {"items": {"tavoletta_seminatori": 3, "polvere_iridata": 1}},
		8: {"bonus": {"magic": 1.02, "luck": 0.02}, "text": "incantesimi +2%, fortuna +2%"},
		9: {"items": {"stilo_seminatori": 2, "polvere_iridata": 2}},
		10: {"bonus": {"magic": 1.05, "luck": 0.04, "linfa_regen": 1.05}, "text": "incantesimi +5%, fortuna +4%, la Linfa torna +5%"},
	},
}


static func reward(pillar: String, g: int) -> Dictionary:
	return (REWARDS.get(pillar, {}) as Dictionary).get(g, {})
