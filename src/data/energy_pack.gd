extends RefCounted
## Roadmap 19 «La Linfa che scorre»: gli oggetti e le ricette della rete (la Pinza, le vene, i fili; le macchine si
## aggiungono con le loro voci). Un pacchetto come quelli dei biomi (`BiomesData.PACK_FILES`): questo file non nomina
## altre classi.

const DATA := {
	"items": {
		"pinza_vene": {"name": "Pinza delle vene", "kind": "pinza", "icon": ["uncino", "legnoferro"], "stack": 1,
			"desc": "Posa le vene del Flusso e i fili dell'Impulso: clic e trascina per una linea, clic destro per riprendere. Maiusc+rotella: che cosa posare. In mano mostra i fili."},
		"vena_radice": {"name": "Vena di radice", "kind": "vena", "icon": ["radice_viaggio", "legno"], "stack": 999,
			"desc": "Porta fino a 30 pulsi di Linfa. Si posa con la Pinza delle vene, anche nella roccia: scavando non si taglia."},
		"vena_legnoferro": {"name": "Vena di legnoferro", "kind": "vena", "icon": ["radice_viaggio", "legnoferro"], "stack": 999,
			"desc": "Porta fino a 100 pulsi di Linfa. Le creature non la rosicchiano."},
		"vena_ambra": {"name": "Vena d'ambra", "kind": "vena", "icon": ["radice_viaggio", "ambra"], "stack": 999,
			"desc": "Porta fino a 300 pulsi di Linfa."},
		"vena_cristallo": {"name": "Vena di cristallo", "kind": "vena", "icon": ["radice_viaggio", "cristallo"], "stack": 999,
			"desc": "Porta fino a 1000 pulsi: la sola che regge il Flusso di una Radice-madre."},
		"filo_turchese": {"name": "Filo turchese", "kind": "filo", "icon": ["seta", "linfa"], "stack": 999,
			"desc": "Porta l'Impulso: un comando acceso o spento, subito, a tutto ciò che tocca lo stesso filo."},
		"filo_ambra": {"name": "Filo d'ambra", "kind": "filo", "icon": ["seta", "ambra"], "stack": 999,
			"desc": "Porta l'Impulso. I quattro colori passano nella stessa tessera senza toccarsi."},
		"filo_corallo": {"name": "Filo corallo", "kind": "filo", "icon": ["seta", "sanguinella"], "stack": 999,
			"desc": "Porta l'Impulso. I quattro colori passano nella stessa tessera senza toccarsi."},
		"filo_viola": {"name": "Filo viola", "kind": "filo", "icon": ["seta", "nottilite"], "stack": 999,
			"desc": "Porta l'Impulso. I quattro colori passano nella stessa tessera senza toccarsi."},
		"isolante_resina": {"name": "Isolante di gelatina", "kind": "isolante", "icon": ["gel", "ambra"], "stack": 99,
			"desc": "Usalo su una vena: non si collega più alle vene vicine di un altro grado (così due reti si incrociano). Di nuovo per togliere."},
	},
	"recipes": [
		{"out": "pinza_vene", "qty": 1, "in": {"legno": 6, "lingotto_radicite": 2}, "station": "ceppo"},
		{"out": "vena_radice", "qty": 10, "in": {"legno": 4, "gelatina": 1}, "station": "ceppo"},
		{"out": "vena_legnoferro", "qty": 10, "in": {"lingotto_legnoferro": 1, "legno": 2}, "station": "baccello_ardente"},
		{"out": "vena_ambra", "qty": 10, "in": {"lingotto_ambra": 1, "seta_radice": 1}, "station": "maglio"},
		{"out": "vena_cristallo", "qty": 10, "in": {"cristallo_linfa": 2, "lingotto_linfa": 1}, "station": "maglio"},
		{"out": "filo_turchese", "qty": 20, "in": {"seta_radice": 1, "tintura_turchese": 1}, "station": "telaio"},
		{"out": "filo_ambra", "qty": 20, "in": {"seta_radice": 1, "tintura_gialla": 1}, "station": "telaio"},
		{"out": "filo_corallo", "qty": 20, "in": {"seta_radice": 1, "tintura_rossa": 1}, "station": "telaio"},
		{"out": "filo_viola", "qty": 20, "in": {"seta_radice": 1, "tintura_viola": 1}, "station": "telaio"},
		{"out": "isolante_resina", "qty": 5, "in": {"gelatina": 2}, "station": "ceppo"},
	],
}
