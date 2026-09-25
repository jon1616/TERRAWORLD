class_name NpcData
extends RefCounted
## Gli abitanti (voce 36): viandanti che si fermano al **Focolare** del Germogliato se trovano un **Letto di foglie**
## libero lì vicino, uno per letto. Ognuno arriva quando il mondo è pronto per lui (`requires`) e vende le sue merci in
## cambio di Lumini; tutti comprano tutto (un terzo del valore, vedi `ValueData`). Solo dati; li gestisce `Villagers`.
##
## Campi: name, greet (ciò che dice aprendo il commercio), requires (condizione: vuoto, "station" = una stazione
## piazzata nel mondo, "custodi" = Custodi sconfitti in questo mondo), look (colori per `NpcArt`), goods ([oggetto,
## quantità] in vendita).

## Tessere dal Focolare entro cui contano i letti e in cui gli abitanti passeggiano.
const HOME_RANGE := 25
const WANDER := 8

const NPCS := {
	"viandante": {"name": "La Viandante", "greet": "Ho camminato per tre mondi. Guarda cosa ho nella bisaccia.",
		"requires": {}, "look": {"cloak": "#2f7a70", "trim": "#8ef0d8", "skin": "#c8a07a", "extra": "#d8944a"},
		"goods": [["torcia", 10], ["pozione_rugiada", 1], ["pozione_linfa", 1], ["dardo", 50], ["seme_rugiada", 3],
			["spore_brace", 3], ["baccello_esplosivo", 3], ["mappa_seminatori", 1], ["radice_uncino", 1], ["cesta", 1]]},
	"erborista": {"name": "L'Erborista", "greet": "Ogni foglia è una cura, se sai come chiederglielo.",
		"requires": {"station": "alambicco"}, "look": {"cloak": "#3a6a2a", "trim": "#c8e070", "skin": "#dcb48a", "extra": "#b870d8"},
		"goods": [["pozione_bagliore", 1], ["pozione_scorza", 1], ["pozione_vigore", 1], ["pozione_rigoglio", 1],
			["pozione_passo", 1], ["pozione_notte", 1], ["spore_luminose", 3], ["seme_campanula", 3], ["occhio_tubero", 3],
			["benda_seta", 2]]},
	"forgiatore": {"name": "Il Forgiatore", "greet": "Il Maglio dei Seminatori canta ancora. Io lo ascolto.",
		"requires": {"custodi": 1}, "look": {"cloak": "#5a3a26", "trim": "#ffb040", "skin": "#b08862", "extra": "#a2b0c2"},
		"goods": [["lingotto_radicite", 5], ["lingotto_legnoferro", 5], ["lingotto_pallidite", 5], ["lingotto_ambra", 3],
			["polvere_brace", 5], ["baccello_tonante", 2], ["uncino_cristallo", 1], ["martello_radice", 1],
			["dardo_vuoto", 50], ["giavellotto_aculeo", 20]]},
}
