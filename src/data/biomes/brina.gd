extends RefCounted
## I Boschi di brina (voce 40). I campi sono spiegati in cima a `BiomesData`.

const DATA := {
	"id": "brina", "name": "Boschi di brina", "desc": "Muschio gelato, alberi che scintillano, aria ferma",
	"trees": 0.28, "hills": 1.2, "lift": -4, "tint": Color(0.8, 0.95, 1.22), "color": "#bfe8ff", "weight": 2,
	"grass": TileDefs.GRASS_BRINA,
	"turf": {"name": "Muschio di brina", "layer": "muschio_brina", "pal": TileDefs.P_GRASS_BRINA, "specks": 0},
	"tree": {"id": "abete", "name": "Abete di brina", "glow": Color(1.2, 1.5, 1.8)},
	# muschio gelato, cristalli di brina, cespugli di bacche gelate, sassi, campanule turchesi
	"veg": [[0.35, 40], [0.42, 41], [0.49, 42], [0.53, "sassi"], [0.56, "fiore_0"]],
	"decor": {40: {"soft": "erba"}, 41: {"light": Color(0.12, 0.3, 0.42)}, 42: {"soft": "pianta", "light": Color(0.1, 0.16, 0.2)}},
	"elem": "gelo",
	"weather": {"bufera": 3.0},
	"gene": "brina",
}
