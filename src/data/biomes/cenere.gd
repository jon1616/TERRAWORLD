extends RefCounted
## Le Cenerarie (voce 40). I campi sono spiegati in cima a `BiomesData`.

const DATA := {
	"id": "cenere", "name": "Cenerarie", "desc": "Pianure di cenere viva: sotto la crosta covano le braci",
	"trees": 0.03, "hills": 0.7, "lift": 5, "tint": Color(1.2, 0.82, 0.78), "color": "#ff9a7a", "weight": 2,
	"grass": 25,                  # la tessera (TileDefs.GRASS_CENERE)
	"turf": {"name": "Cenere viva", "layer": "cenere_viva", "pal": ["#3a2a30", "#5a3e44", "#7e565a", "#a8766e", "#e0a888"], "specks": 0},
	"tree": {"id": "tizzone", "name": "Tizzone", "glow": Color(1.9, 1.2, 0.8)},
	# ciuffi bruciati, braci nella cenere, stecchi carbonizzati, sassi, funghi di brace
	"veg": [[0.3, 43], [0.36, 44], [0.43, 45], [0.5, "sassi"], [0.54, "fungo"]],
	"decor": {43: {"soft": "erba"}, 44: {"light": Color(0.42, 0.16, 0.04)}, 45: {"soft": "pianta", "light": Color(0.18, 0.07, 0.02)}},
	"elem": "brace",
	"weather": {"cenere": 3.0},
	"gene": "cenere",
}
