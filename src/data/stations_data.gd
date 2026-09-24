class_name StationsData
extends RefCounted
## Stazioni di fabbricazione: si piazzano nel mondo e permettono le ricette che le nominano quando il giocatore è vicino.
## size = tessere occupate (larghezza, altezza); item = l'oggetto che la piazza.

const STATIONS := {
	"banco_lavoro": {"name": "Banco da lavoro", "size": [3, 2], "item": "banco_lavoro"},
	"fornace": {"name": "Fornace", "size": [3, 2], "item": "fornace", "light": true},
	"incudine": {"name": "Incudine di ferro", "size": [2, 1], "item": "incudine"},
}

## Distanza massima (in tessere) per usare una stazione.
const REACH := 5
