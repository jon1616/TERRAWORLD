extends RefCounted
## Le Paludi di spore. I campi sono spiegati in cima a `BiomesData`.

const DATA := {
	"id": "palude", "name": "Paludi di spore", "desc": "Muschio viola e aria pesante di spore che brillano",
	"trees": 0.12, "hills": 0.3, "lift": 12, "tint": Color(0.78, 0.6, 1.12), "color": "#c08aff", "weight": 3,
	"grass": 13,                  # la tessera (TileDefs.GRASS_SPORE)
	"turf": {"name": "Muschio di spore", "layer": "muschio_spore", "pal": ["#2a1640", "#43235e", "#633a86", "#8a58b4", "#c49af0"], "specks": 90},
	"tree": {"id": "fungo", "name": "Fungo-albero", "glow": Color(1.5, 1.2, 1.8)},
	# erba di spore bassa, canne, funghetti, sacche di spore, funghi luminosi, campanule viola
	"veg": [[0.28, 34], [0.36, 35], [0.44, 36], [0.5, "spora"], [0.55, "bagliore"], [0.6, "fiore_2"]],
	"decor": {34: {"soft": "erba"}, 35: {"soft": "pianta", "light": Color(0.18, 0.1, 0.28)},
		36: {"soft": "pianta", "light": Color(0.22, 0.1, 0.32)}},
	"elem": "spora",
	"gene": "sporangio",
}
