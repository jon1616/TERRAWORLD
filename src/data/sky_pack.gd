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
	},
	"recipes": [
		{"out": "fagiolo_nuvola", "qty": 2, "in": {"legno": 6, "gelatina": 2, "humus": 4}, "station": "ceppo"},
		{"out": "piuma_lenta", "qty": 1, "in": {"penna_corteccia": 4, "gelatina": 3, "legno": 4}, "station": "ceppo"},
	],
}
