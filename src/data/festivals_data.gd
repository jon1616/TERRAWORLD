class_name FestivalsData
extends RefCounted
## Le feste di stagione del Giardino (Roadmap 22, voce 230). Solo dati; le fa `Festivals`. Il primo giorno di ogni
## stagione, se la bellezza del Giardino arriva a `NEED`, nel Giardino c'è la festa: un compito da fare entro la fine
## del giorno (un conteggio del personaggio che sale di `n` durante la festa), i premi, e un oggetto che si ottiene solo
## alla sua festa.

const NEED := 80

const FESTIVALS := {
	"germoglio": {"name": "La Fioritura dei semi", "stat": "semine", "n": 20, "task": "Semina venti colture durante la festa",
		"reward": {"lumino": 200, "seme_rugiada": 10}, "unique": "corona_fiori", "color": Color("#b0e060")},
	"rigoglio": {"name": "La Festa delle acque", "stat": "pesci", "n": 15, "task": "Pesca quindici pesci durante la festa",
		"reward": {"lumino": 200, "esca_squama": 10}, "unique": "lanterna_acque", "color": Color("#6ad0ff")},
	"raccolto": {"name": "La Festa del raccolto", "stat": "raccolti", "n": 30, "task": "Raccogli trenta colture durante la festa",
		"reward": {"lumino": 250, "miele_lume": 5}, "unique": "cesto_raccolto", "color": Color("#ffc050")},
	"gelo": {"name": "Il Fuoco d'inverno", "stat": "prodotti", "n": 15, "task": "Raccogli quindici prodotti della mandria durante la festa",
		"reward": {"lumino": 250, "pozione_rugiada": 5}, "unique": "sciarpa_brace", "color": Color("#ff8a6a")},
}

## Gli oggetti che si ottengono solo alle feste (uniti in `ItemsData.all()`).
const ITEMS := {
	"corona_fiori": {"name": "Corona di fiori della festa", "kind": "elmo", "icon": ["corona", "muschio"], "stack": 1, "defense": 1,
		"acc": {"halo": 1.15, "regen": 1.05}, "source": "alla Fioritura dei semi, nel Giardino",
		"desc": "Alone +15%, la Vita ricresce +5%. Si ottiene solo alla festa di primavera."},
	"lanterna_acque": {"name": "Lanterna delle acque", "kind": "accessorio", "icon": ["lanterna", "lagunite"], "stack": 1,
		"acc": {"fish_luck": 0.15, "respiro": 1.2}, "source": "alla Festa delle acque, nel Giardino",
		"desc": "Fortuna di pesca +15%, respiro +20%. Si ottiene solo alla festa d'estate."},
	"cesto_raccolto": {"name": "Cesto del raccolto", "kind": "accessorio", "icon": ["cesta", "ambra"], "stack": 1,
		"acc": {"grow": 1.1, "luck": 0.05}, "source": "alla Festa del raccolto, nel Giardino",
		"desc": "L'orto cresce +10%, fortuna +5%. Si ottiene solo alla festa d'autunno."},
	"sciarpa_brace": {"name": "Sciarpa di brace", "kind": "accessorio", "icon": ["seta", "brace"], "stack": 1,
		"acc": {"caldo": 0.5, "herd": 1.1}, "source": "al Fuoco d'inverno, nel Giardino",
		"desc": "Freddo: protegge a metà; la mandria cresce +10%. Si ottiene solo alla festa d'inverno."},
}
