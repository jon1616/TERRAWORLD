extends RefCounted
## Le Distese d'ambra. I campi sono spiegati in cima a `BiomesData`.

const DATA := {
	"id": "ambra", "name": "Distese d'ambra", "desc": "Erba dorata, rocce calde, pochi alberi",
	"trees": 0.07, "hills": 1.5, "lift": -8, "tint": Color(1.22, 0.9, 0.6), "color": "#ffd08a", "weight": 3,
	"grass": 14,                  # la tessera (TileDefs.GRASS_AMBRA)
	"turf": {"name": "Erba d'ambra", "layer": "erba_ambra", "pal": ["#4a3210", "#6e4c16", "#9a7022", "#c89a3a", "#f0d27a"], "specks": 90},
	"tree": {"id": "acacia", "name": "Acacia d'ambra", "glow": Color(1.7, 1.4, 0.9)},
	# erba dorata, cardi, fiori di resina, sassi caldi, campanule d'ambra
	"veg": [[0.35, 37], [0.43, 38], [0.5, 39], [0.56, "sassi"], [0.6, "fiore_1"]],
	"decor": {37: {"soft": "erba"}, 38: {"soft": "pianta", "light": Color(0.25, 0.17, 0.04)},
		39: {"soft": "pianta", "light": Color(0.22, 0.12, 0.02)}},
	"elem": "luce",
	"gene": "resina",
}
