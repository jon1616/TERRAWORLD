extends RefCounted
## Il pacchetto del cielo (Roadmap 16): gli oggetti e le ricette che non stanno nel file di un bioma del cielo (per
## salire, per l'aria sottile, i materiali in comune). Unito alle tabelle comuni come i pacchetti del bestiario
## (`BiomesData.PACK_FILES`). Questo file non nomina altre classi (valori per esteso).

const DATA := {
	"items": {
		# voce 157: arrivare in cielo
		"fagiolo_nuvola": {"name": "Fagiolo di nuvola", "kind": "fagiolo", "icon": ["seme", "cielo"], "stack": 20,
			"desc": "Piantalo nella terra all'aperto: in un minuto sale una liana di passerelle, 40 tessere verso il cielo."},
		"piuma_lenta": {"name": "Piuma lenta", "kind": "accessorio", "icon": ["penna", "nuvola"], "stack": 1,
			"acc": {"glide": true, "fall_safe": true}, "desc": "Le cadute non fanno male; tenendo il salto in caduta si plana."},
		# voce 158: l'aria sottile (materiali del cielo basso)
		"maschera_nuvola": {"name": "Maschera di nuvola", "kind": "accessorio", "icon": ["velo", "nuvola"], "stack": 1,
			"acc": {"quota": 0.6}, "desc": "Aria sottile: protegge al 60%. Una nuvola stretta sul viso, che respira per te."},
		"mantello_piume": {"name": "Mantello di piume del cielo", "kind": "accessorio", "icon": ["mantello", "cielo"], "stack": 1,
			"acc": {"quota": 0.5, "glide": true}, "desc": "Aria sottile: protegge a metà; si plana tenendo il salto."},
		"elisir_respiro": {"name": "Elisir del respiro alto", "kind": "consumabile", "icon": ["pozione", "celeste"],
			"boon": ["respiro_alto", 300.0], "stack": 20, "desc": "Per 5 minuti l'aria sottile non ti tocca."},
	},
	"recipes": [
		{"out": "maschera_nuvola", "qty": 1, "in": {"nuvola": 25, "terra_cielo": 10, "gelatina": 4}, "station": "ceppo"},
		{"out": "mantello_piume", "qty": 1, "in": {"piuma_lenta": 1, "nuvola": 20, "cristallo_celeste": 4}, "station": "maglio"},
		{"out": "elisir_respiro", "qty": 2, "in": {"nuvola": 6, "cristallo_celeste": 1, "gelatina": 2}, "station": "alambicco"},
		{"out": "fagiolo_nuvola", "qty": 2, "in": {"legno": 6, "gelatina": 2, "humus": 4}, "station": "ceppo"},
		{"out": "piuma_lenta", "qty": 1, "in": {"penna_corteccia": 4, "gelatina": 3, "legno": 4}, "station": "ceppo"},
	],
}
