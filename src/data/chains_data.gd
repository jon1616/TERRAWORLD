class_name ChainsData
## Le catene di ricerca tra i mondi (voce 69, Roadmap 9): un indizio dice **di che geni** deve essere fatto un mondo;
## piantando un Seme con quei geni, il mondo nuovo ha una **cripta dei Seminatori** (`PassCatene`) con un leggio: lì
## c'è il pezzo di storia, il premio e l'indizio della tappa dopo. Così si progettano i Semi per seguire la storia.
## - La catena lunga, scritta a mano: «La via del Seme Nero» (cinque tappe, porta al Seme Nero della voce 72).
## - Le catene brevi, generate senza fine dai geni che il personaggio ha già visto (`Chains.make_short`).
## Solo dati: le regole in `Chains`.

## need: "geni" = tutti questi geni nel mondo; "vigore" = almeno questo vigore.
## reward: oggetti; "seme_nero": true = il Seme Nero (voce 72).
const LONG := {
	"id": "seme_nero", "name": "La via del Seme Nero",
	"steps": [
		{"name": "Il sussurro delle radici", "need": {"geni": ["radici_giganti"]},
			"clue": "Tra le radici del Giardino una voce sottile: «Le radici giganti ricordano. Sotto un mondo di radici giganti i Seminatori scavarono una cripta.» Pianta un Seme con il gene Radici giganti.",
			"found": "Sul leggio, parole incise a fatica: «Siamo stati noi a piantarlo. Il seme che cadde non era nostro, ma lo accogliemmo. Da lì cominciò la malattia.»",
			"reward": {"tavoletta_seminatori": 2, "lumino": 120}},
		{"name": "L'avvertimento", "need": {"geni": ["avvizzito"], "vigore": 2},
			"clue": "«Dove la malattia è più forte lasciammo un avvertimento.» Cerca in un mondo con il gene Avvizzito, di vigore 2 o più.",
			"found": "«Non curate il seme nero con la Linfa: la beve. Non bruciatelo: si sparge. Si cura solo dal suo cuore, dove è caduto.»",
			"reward": {"linfa_antica": 2, "pozione_rugiada": 2}},
		{"name": "La stella caduta", "need": {"geni": ["stellato"]},
			"clue": "«Cadde in una notte di stelle.» Sotto un cielo con il gene Stellato c'è la cripta della caduta.",
			"found": "Un disegno di stelle, e una stella nera tra le altre. «Non veniva da nessun giardino. Veniva dal Vuoto, e il Vuoto ha fame.»",
			"reward": {"polvere_iridata": 2, "tavoletta_seminatori": 2}},
		{"name": "Il gelo che ricorda", "need": {"geni": ["brina", "fungaie"]},
			"clue": "«Nel gelo, dove i funghi respirano, nascondemmo la mappa.» Un mondo di Brina con il gene Fungaie.",
			"found": "La mappa è una frase: «Il cuore nero nasce da due semi malati in notti lunghe.» Innestando un Seme Avvizzito con uno di Notti lunghe può nascere il gene Cuore nero.",
			"reward": {"linfa_antica": 3, "fiala_avvizzito": 1, "fiala_notti_lunghe": 1}},
		{"name": "Il cuore nero", "need": {"geni": ["cuore_nero"]},
			"clue": "«Solo un mondo dal cuore nero conserva l'ultima cripta.» Pianta un Seme con il gene Cuore nero (nasce per mutazione, più spesso innestando Avvizzito e Notti lunghe).",
			"found": "Nell'ultima cripta, dentro una teca di radici, un seme nero che pulsa piano. «Chi lo pianta scende dove cadde. Curalo, o spezzalo: noi non ne avemmo il coraggio.»",
			"reward": {"seme_nero": 1}},
	],
}

const ITEMS := {
	"seme_nero": {"name": "Seme Nero", "kind": "seme_mondo", "icon": ["seme", "vuotite"], "stack": 1, "value": 0,
		"source": "l'ultima tappa della catena «La via del Seme Nero»",
		"desc": "Il seme che cadde dal Vuoto e portò la malattia nei mondi. Piantato in un'Aiuola apre il mondo dove cadde: lì il suo cuore si può curare o spezzare."},
}

## Catene brevi: chi le racconta, e i premi (due voci a caso; "seme_raro" = un Seme di mondo con un gene raro).
const SHORT_INTRO := ["Una mappa strappata in uno scrigno dice", "Il Cartografo ha sentito dire", "Una stele spezzata ricorda",
	"Un abitante ha sognato", "Una tavoletta consumata racconta", "Le radici del Giardino sussurrano"]
const SHORT_NAMES := ["Il segreto dei Seminatori", "La cripta dimenticata", "Il deposito sepolto", "La camera dei semi",
	"Il rifugio del giardiniere", "La teca nascosta", "La soglia di pietra", "Il pozzo delle rune"]
const SHORT_REWARDS := [{"seme_raro": 1}, {"linfa_antica": 2}, {"tavoletta_seminatori": 3}, {"polvere_iridata": 2},
	{"lumino": 250}, {"pozione_rugiada": 3}, {"provetta": 4}]
## Quante catene brevi aperte insieme.
const SHORT_OPEN := 2
## Dopo quanti viaggi comincia la catena lunga, e dopo quanti le brevi.
const START_LONG := 1
const START_SHORT := 3
