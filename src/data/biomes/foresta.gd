extends RefCounted
## La Foresta-lanterna: il bioma di partenza (deve restare il primo dell'elenco di `BiomesData`). I campi sono spiegati
## in cima a `BiomesData`.

const DATA := {
	"id": "foresta", "name": "Foresta-lanterna", "desc": "Alberi-lanterna e muschio turchese",
	"trees": 0.4, "hills": 1.0, "lift": 0, "tint": Color(1, 1, 1), "color": "#8ef0d8", "weight": 4,
	"grass": 2,                  # la tessera (TileDefs.GRASS)
	"turf": {"name": "Muschio", "layer": "muschio", "pal": ["#0f3a3a", "#16574f", "#23776a", "#3aa08a", "#72d4b0"], "specks": 90},
	"tree": {"id": "lanterna", "name": "Albero-lanterna", "glow": Color(1.6, 1.5, 1.3)},
	# muschio basso, felci, campanule, cespugli di bacche-lanterna
	"veg": [[0.45, "fronda"], [0.52, "felce"], [0.6, "fiori"], [0.66, 33]],
	"decor": {33: {"soft": "pianta", "light": Color(0.18, 0.11, 0.03)}},
	"elem": "linfa",
	"gene": "lanterna",
	"lands": [["Foreste", true], ["Selve", true], ["Boschi", false]],
	"items": {
		"seme_mondo_lanterna": {"name": "Seme di salice-lanterna", "kind": "seme_mondo", "icon": ["seme", "linfa"], "species": "lanterna", "stack": 1, "desc": "Un Seme di mondo nutrito di semi-lanterna: dietro il suo portale, foreste di alberi-lanterna a perdita d'occhio."},
	},
	"recipes": [
		{"out": "seme_mondo_lanterna", "qty": 1, "in": {"seme_mondo": 1, "seme_lanterna": 10, "legno": 30}, "station": "altare"},
	],
}
