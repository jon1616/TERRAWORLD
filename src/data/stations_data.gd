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
##   cesta             Cesta di radici: tiene oggetti (`slots`)
##   scrigno           Scrigno dei Seminatori: nelle rovine, pieno di bottino; vuoto si porta via
##   alambicco         Alambicco di Linfa (voce 25): le pozioni
##   telaio            Telaio di foglie: vesti di seta, mantelli, bende
##   mola              Mola del gemmaio: anelli, bastoni e lame di gemma
## fixed = non si riprende col piccone; light_color = colore della luce (altrimenti brace); slots = contenitore

const STATIONS := {
	"ceppo": {"name": "Ceppo del Giardiniere", "size": [3, 2], "item": "ceppo"},
	"baccello_ardente": {"name": "Baccello ardente", "size": [3, 2], "item": "baccello_ardente", "light": true},
	"maglio": {"name": "Maglio dei Seminatori", "size": [2, 2], "item": "maglio"},
	"alambicco": {"name": "Alambicco di Linfa", "size": [2, 2], "item": "alambicco", "light": true,
		"light_color": Color(0.3, 0.9, 0.9)},
	"telaio": {"name": "Telaio di foglie", "size": [3, 2], "item": "telaio"},
	"mola": {"name": "Mola del gemmaio", "size": [2, 2], "item": "mola"},
	"paiolo": {"name": "Paiolo di radice", "size": [2, 2], "item": "paiolo", "light": true},
	# voce 35: porte e arredi (la porta chiusa riempie le sue celle di tessere `PORTA`, vedi `Masonry`)
	"porta": {"name": "Porta", "size": [1, 3], "item": "porta_lanterna"},
	"porta_aperta": {"name": "Porta aperta", "size": [1, 3], "item": "porta_lanterna"},
	"lampada": {"name": "Lampada di lanterna", "size": [1, 2], "item": "lampada_lanterna", "light": true,
		"light_color": Color(1.5, 1.1, 0.6)},
	"tavolo": {"name": "Tavolo di radice", "size": [3, 2], "item": "tavolo_radice"},
	"sedia": {"name": "Sedia di radice", "size": [1, 2], "item": "sedia_radice"},
	"letto": {"name": "Letto di foglie", "size": [3, 2], "item": "letto_foglie"},
	"radice_viandante": {"name": "Radice viandante", "size": [2, 3], "item": "radice_viandante", "light": true,
		"light_color": Color(0.6, 1.4, 1.3)},
	"focolare": {"name": "Focolare del Giardino", "size": [2, 2], "item": "focolare", "light": true,
		"light_color": Color(1.8, 1.0, 0.5)},
	# voce 27: l'Altare dei Seminatori (richiama i Custodi) e i bozzoli delle tane dei Custodi
	"altare": {"name": "Altare dei Seminatori", "size": [3, 2], "item": "altare", "light": true,
		"light_color": Color(0.2, 0.6, 0.55)},
	"bozzolo_madre_grumi": {"name": "Bozzolo della Madre dei grumi", "size": [3, 3], "item": "", "fixed": true,
		"light": true, "light_color": Color(0.3, 0.9, 0.8)},
	"bozzolo_tessitrice": {"name": "Bozzolo della Tessitrice", "size": [3, 3], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.9, 0.7, 0.3)},
	"bozzolo_serpe_madre": {"name": "Bozzolo della Serpe madre", "size": [3, 3], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.3, 0.8, 0.9)},
	"bozzolo_mietitore": {"name": "Bozzolo del Mietitore", "size": [3, 3], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.7, 0.4, 1.0)},
	"bozzolo_grande_cervo": {"name": "Bozzolo del Grande Cervo", "size": [3, 3], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.6, 0.9, 1.1)},
	"bozzolo_madre_salamandre": {"name": "Bozzolo della Madre delle salamandre", "size": [3, 3], "item": "", "fixed": true,
		"light": true, "light_color": Color(1.2, 0.6, 0.3)},
	"bozzolo_rotto": {"name": "Bozzolo vuoto", "size": [3, 3], "item": "", "fixed": true},
	# voce 28: il reliquiario dei nascondigli murati, con una reliquia dentro
	"reliquiario": {"name": "Reliquiario dei Seminatori", "size": [2, 2], "item": "", "fixed": true, "slots": 10,
		"light": true, "light_color": Color(0.9, 0.75, 0.35)},
	"cesta": {"name": "Cesta di radici", "size": [2, 2], "item": "cesta", "slots": 20},
	"scrigno": {"name": "Scrigno dei Seminatori", "size": [2, 2], "item": "scrigno", "slots": 20, "light": true,
		"light_color": Color(0.2, 0.6, 0.55)},
	# il fagotto di foglie dove il Germogliato è appassito, con la sua Bisaccia (voce 20): sparisce svuotato
	"fagotto": {"name": "Fagotto del Germogliato", "size": [1, 1], "item": "", "fixed": true, "slots": 30, "light": true,
		"light_color": Color(0.9, 0.7, 0.35)},
	"cuore_mondo": {"name": "Cuore del mondo", "size": [3, 3], "item": "", "fixed": true, "light": true,
		"light_color": Color(1.3, 0.85, 0.4)},
	"cuore_vivo": {"name": "Cuore del mondo", "size": [3, 3], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.6, 1.6, 1.5)},
	"portale": {"name": "Portale di radici", "size": [3, 4], "item": "seme_mondo", "fixed": true, "light": true,
		"light_color": Color(0.5, 1.3, 1.4)},
	# voce 58: i nidi e le tane (nascono dal mondo; clic destro: un uovo, o nutrirli; con piccone o ascia si distruggono)
	"nido_erba": {"name": "Nido d'erba", "size": [2, 1], "item": "", "fixed": true},
	"nido_tana": {"name": "Tana", "size": [2, 1], "item": "", "fixed": true, "light": true, "light_color": Color(0.5, 0.4, 0.1)},
	"nido_alveare": {"name": "Alveare di lume", "size": [2, 2], "item": "", "fixed": true, "light": true,
		"light_color": Color(1.0, 0.7, 0.2)},
	"nido_formicaio": {"name": "Formicaio di resina", "size": [3, 2], "item": "", "fixed": true},
	# voce 59: il Recinto (anche mangiatoia: le caselle) e l'Incubatrice
	"recinto": {"name": "Recinto di radici", "size": [3, 2], "item": "recinto", "slots": 12},
	"incubatrice": {"name": "Incubatrice di muschio", "size": [2, 2], "item": "incubatrice", "slots": 4, "light": true,
		"light_color": Color(0.4, 0.9, 0.7)},
	# voce 47: il Banco dell'Innestatrice (clic destro: `InnestoPanel`)
	"banco_innesti": {"name": "Banco dell'Innestatrice", "size": [3, 2], "item": "banco_innesti", "light": true,
		"light_color": Color(0.5, 1.1, 0.9)},
	# voce 46: la pianta-seme selvatica (clic destro: una Fiala di gene o un Seme selvatico, vedi `Sampling`)
	"pianta_seme": {"name": "Pianta-seme", "size": [1, 2], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.9, 0.8, 0.35)},
	# voce 45: l'Aiuola del Giardino, dove si piantano i Semi di mondo (diventa un portale della stessa misura)
	"aiuola": {"name": "Aiuola del Giardino", "size": [3, 4], "item": "aiuola", "light": true,
		"light_color": Color(0.35, 0.8, 0.7)},
}

## Distanza massima (in tessere) per usare una stazione.
const REACH := 5
