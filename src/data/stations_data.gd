class_name StationsData
extends RefCounted
## Stazioni di fabbricazione: si piazzano nel mondo e permettono le ricette che le nominano quando il giocatore è vicino.
## size = tessere occupate (larghezza, altezza); item = l'oggetto che la piazza.
##   ceppo             il Ceppo del Giardiniere: si lavora il legno (la prima stazione)
##   baccello_ardente  un baccello di pietra che cova la brace: fonde i minerali in lingotti
##   maglio            il Maglio dei Seminatori: forgia attrezzi e armature di metallo
##   cuore_mondo       il Cuore del mondo, malato: nasce nel Fondo con il mondo, non si fabbrica né si sposta
##   cuore_vivo        il Cuore dopo il Guardiano (sconfitto o curato): brilla e dona un Seme di mondo
##   portale           il portale di radici che cresce da un Seme di mondo
## fixed = non si riprende col piccone; light_color = colore della luce (altrimenti brace)

const STATIONS := {
	"ceppo": {"name": "Ceppo del Giardiniere", "size": [3, 2], "item": "ceppo"},
	"baccello_ardente": {"name": "Baccello ardente", "size": [3, 2], "item": "baccello_ardente", "light": true},
	"maglio": {"name": "Maglio dei Seminatori", "size": [2, 2], "item": "maglio"},
	"cuore_mondo": {"name": "Cuore del mondo", "size": [3, 3], "item": "", "fixed": true, "light": true,
		"light_color": Color(1.3, 0.85, 0.4)},
	"cuore_vivo": {"name": "Cuore del mondo", "size": [3, 3], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.6, 1.6, 1.5)},
	"portale": {"name": "Portale di radici", "size": [3, 4], "item": "seme_mondo", "fixed": true, "light": true,
		"light_color": Color(0.5, 1.3, 1.4)},
}

## Distanza massima (in tessere) per usare una stazione.
const REACH := 5
