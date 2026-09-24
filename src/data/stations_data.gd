class_name StationsData
extends RefCounted
## Stazioni di fabbricazione: si piazzano nel mondo e permettono le ricette che le nominano quando il giocatore è vicino.
## size = tessere occupate (larghezza, altezza); item = l'oggetto che la piazza.
##   ceppo             il Ceppo del Giardiniere: si lavora il legno (la prima stazione)
##   baccello_ardente  un baccello di pietra che cova la brace: fonde i minerali in lingotti
##   maglio            il Maglio dei Seminatori: forgia attrezzi e armature di metallo

const STATIONS := {
	"ceppo": {"name": "Ceppo del Giardiniere", "size": [3, 2], "item": "ceppo"},
	"baccello_ardente": {"name": "Baccello ardente", "size": [3, 2], "item": "baccello_ardente", "light": true},
	"maglio": {"name": "Maglio dei Seminatori", "size": [2, 2], "item": "maglio"},
}

## Distanza massima (in tessere) per usare una stazione.
const REACH := 5
