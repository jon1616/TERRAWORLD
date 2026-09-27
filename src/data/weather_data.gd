class_name WeatherData
## Il tempo atmosferico dei mondi (voce 75, Roadmap 10). Solo dati: lo sceglie e lo applica `Weather`. Vale solo in
## superficie (sotto terra non piove), e non nel Giardino. Ogni tempo:
##   rain     gocce (e le pozze che si riempiono, l'orto che cresce di più: grow)
##   snow     fiocchi; slow: la corsa rallenta
##   ash      cenere: ferisce chi resta allo scoperto (senza parete dietro), `ash_dps`
##   fog      nebbia: velo sul mondo e le creature vedono meno lontano (`sight`)
##   storm    fulmini che cadono in superficie vicino al Germogliato
##   wind     forza del vento [min, max] in px/s²: spinge chi è in aria, le planate, i dardi e gli incantesimi
##   tint     colore del cielo; weights: quanto è probabile in ogni stagione (indice di `SeasonsData.SEASONS`)

const STATES := {
	"sereno": {"name": "Sereno", "desc": "cielo pulito", "wind": [0.0, 30.0], "tint": Color(1, 1, 1),
		"weights": [4, 5, 3, 3]},
	"pioggia": {"name": "Pioggia", "desc": "le pozze si riempiono e l'orto cresce di più", "rain": 1.0, "grow": 1.4,
		"wind": [20.0, 70.0], "tint": Color(0.78, 0.84, 0.92), "weights": [3, 1, 2, 0]},
	"temporale": {"name": "Temporale", "desc": "pioggia fitta, vento forte e fulmini", "rain": 1.8, "grow": 1.4, "storm": true,
		"wind": [80.0, 160.0], "tint": Color(0.55, 0.6, 0.72), "weights": [1, 2, 1, 0]},
	"nebbia": {"name": "Nebbia", "desc": "si vede poco, e anche le creature vedono meno", "fog": 0.45, "sight": 0.6,
		"wind": [0.0, 15.0], "tint": Color(0.82, 0.86, 0.86), "weights": [2, 0, 3, 2]},
	"bufera": {"name": "Bufera di brina", "desc": "neve e vento gelato: si corre più piano", "snow": 1.5, "slow": 0.8,
		"wind": [120.0, 200.0], "tint": Color(0.8, 0.88, 1.0), "weights": [0, 0, 0, 3]},
	"cenere": {"name": "Tempesta di cenere", "desc": "la cenere ferisce chi resta allo scoperto: riparati sotto un tetto",
		"ash": 1.0, "fog": 0.3, "sight": 0.8, "wind": [90.0, 170.0], "tint": Color(0.85, 0.66, 0.6), "weights": [1, 2, 1, 0]},
}

## Ogni quanti secondi il tempo può cambiare (un quinto di giorno).
const CHANGE := 240.0
## Quanto ferisce la cenere (ogni 2 secondi) e quanto un fulmine vicino.
const ASH_DAMAGE := 2
const BOLT_DAMAGE := 18
const BOLT_EVERY := [5.0, 11.0]
const BOLT_RANGE := 3                  # tessere: chi è così vicino al fulmine è ferito
## Ogni quanti secondi la pioggia versa un po' d'acqua in una conca della superficie.
const PUDDLE_EVERY := 1.5

const ITEMS := {
	"fulgorite": {"name": "Fulgorite", "kind": "materiale", "icon": ["gemma", "brillaluce"], "stack": 99, "value": 60,
		"source": "dove cade un fulmine, durante i temporali", "desc": "Sabbia fusa da un fulmine, ancora crepitante."},
	"amuleto_tempesta": {"name": "Amuleto della tempesta", "kind": "accessorio", "icon": ["amuleto", "brillaluce"], "stack": 1,
		"acc": {"air_jumps": 1, "run": 1.06}, "desc": "Un fulmine chiuso nel vetro: un salto in aria in più."},
	"mantello_vento": {"name": "Mantello del vento", "kind": "accessorio", "icon": ["mantello", "muschio"], "stack": 1,
		"acc": {"glide": true, "vento": 0.4}, "desc": "Plani tenendo il salto, e il vento ti spinge poco."},
}

const RECIPES := [
	{"out": "amuleto_tempesta", "qty": 1, "in": {"fulgorite": 6, "lingotto_legnoferro": 3}, "station": "maglio"},
	{"out": "mantello_vento", "qty": 1, "in": {"seta_radice": 8, "fulgorite": 2}, "station": "telaio"},
]
