class_name EventsData
extends RefCounted
## Gli eventi del mondo (voce 34): ogni notte e ogni giorno c'è una probabilità che succeda qualcosa. Solo dati; li
## tira e li applica `Events`.
##
## Campi: name, desc (scritta all'inizio), when ("notte" o "giorno"), chance (per notte o per giorno), color,
##   danger    pericolo in più (più creature e più forti, vedi `DangerData`)
##   rare      moltiplicatore delle creature rare
##   pool      creature che nascono più spesso durante l'evento (60% delle nascite)
##   stars     secondi tra una stella cadente e l'altra ([min, max]): la Pioggia di stelle
##   goal      creature da sconfiggere per vincere l'evento; reward = tabella di bottino (tirata `rolls` volte)
##   wild      moltiplicatore dei semi selvatici del giardino

const EVENTS := {
	"pioggia_stelle": {"name": "Pioggia di stelle", "desc": "Il cielo del Giardino lascia cadere le sue stelle: raccoglile",
		"when": "notte", "chance": 0.3, "color": "#fff2a8", "stars": [8.0, 18.0]},
	"notte_avvizzita": {"name": "Notte dell'Avvizzimento", "desc": "Gli Avvizziti si svegliano tutti insieme. Resisti fino all'alba",
		"when": "notte", "chance": 0.12, "color": "#b0a060", "danger": 2.0, "pool": ["avvizzito_errante"],
		"goal": 40, "reward": "alba", "rolls": 3},
	# Roadmap 16, voce 164: non si tira mai da solo, lo avvia `Chiome` quando smette di piovere
	"arcobaleno": {"name": "Arcobaleno", "desc": "Dopo la pioggia, l'arcobaleno: le creature rare del cielo escono allo scoperto",
		"when": "speciale", "chance": 0.0, "color": "#ffe8a0", "rare": 3.0,
		"pool": ["farfalla_prisma", "balena_stelle", "girandola_viva", "medusa_nuvola", "stella_errante"]},
	# Roadmap 19, voce 207: solo nei mondi con una rete (`rete`), sei volte più spesso con il gene «Tempeste di Linfa»
	# (`linfa_tempeste` dei geni, letto da `Events`)
	"tempesta_linfa": {"name": "Tempesta di Linfa", "desc": "La Linfa del mondo ribolle: le sorgenti danno di più, ma le vene tese si spezzano",
		"when": "giorno", "chance": 0.06, "color": "#6ff0e0", "rete": true, "pool": ["lucciola_vena"]},
	"fioritura": {"name": "Fioritura", "desc": "Il Giardino fiorisce: le creature rare escono allo scoperto",
		"when": "giorno", "chance": 0.15, "color": "#ff9ad8", "rare": 2.0, "wild": 3.0},
}


## Gli eventi possibili in un momento della giornata.
static func for_time(when: String) -> Array:
	return EVENTS.keys().filter(func(k: String) -> bool: return EVENTS[k]["when"] == when)
