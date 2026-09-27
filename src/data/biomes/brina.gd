extends RefCounted
## I Boschi di brina (voce 40). I campi sono spiegati in cima a `BiomesData`.

const DATA := {
	"id": "brina", "name": "Boschi di brina", "desc": "Muschio gelato, alberi che scintillano, aria ferma",
	"trees": 0.28, "hills": 1.2, "lift": -4, "tint": Color(0.8, 0.95, 1.22), "color": "#bfe8ff", "weight": 2,
	"grass": 24,                  # la tessera (TileDefs.GRASS_BRINA)
	"stagni": [1.5, 10, 20, 3, 5],      # voce 118: stagni di superficie (vedi `BiomesData`)
	"turf": {"name": "Muschio di brina", "layer": "muschio_brina", "pal": ["#1c3048", "#2a4a6a", "#44729a", "#7aaed0", "#d0f0ff"], "specks": 0},
	"tree": {"id": "abete", "name": "Abete di brina", "glow": Color(1.2, 1.5, 1.8)},
	# muschio gelato, cristalli di brina, cespugli di bacche gelate, sassi, campanule turchesi
	"veg": [[0.35, 40], [0.42, 41], [0.49, 42], [0.53, "sassi"], [0.56, "fiore_0"]],
	"decor": {40: {"soft": "erba"}, 41: {"light": Color(0.12, 0.3, 0.42)}, 42: {"soft": "pianta", "light": Color(0.1, 0.16, 0.2)}},
	"elem": "gelo",
	"weather": {"bufera": 3.0},
	"gene": "brina",
	"lands": [["Nevai", false], ["Brume", true], ["Ghiacciai", false]],
	# --- il pacchetto (spostato qui dalle tabelle comuni il 28 set 2026) ---
	"creatures": {
		"cervo_brina": {"name": "Cervo di brina", "hp": 64, "damage": 15, "defense": 3, "knock": 0.5, "half": [9, 8],
			"speed": 55, "behaviors": ["cammina", "carica"],
			"p": {"sight": 22, "charge": 250.0, "charge_range": 12, "charge_time": 1.0, "charge_cool": 3.2},
			"loot": "cervo_brina", "art": ["cervo_brina", 0], "strata": [0], "weight": 6, "biomes": ["brina"],
			"affinity": {"weak": ["brace"], "resist": ["gelo"]}, "trophy": "cuore_brina"},
		"gufo_gelo": {"name": "Gufo del gelo", "hp": 30, "damage": 10, "defense": 1, "knock": 0.1, "half": [7, 6],
			"speed": 80, "fly": true, "behaviors": ["vola", "spara"],
			"p": {"sight": 28, "hover": 70.0, "wobble": 20.0, "rate": 2.4, "shot_speed": 230.0, "shot_grav": 0.0,
				"shot_damage": 8, "slow": 1.5, "shot_look": "gelo"},
			"loot": "gufo_gelo", "art": ["gufo_gelo", 0], "strata": [0], "weight": 5, "glow": true, "biomes": ["brina"],
			"affinity": {"weak": ["brace"], "resist": ["gelo"]}, "trophy": "occhio_gelo"},
	},
	"families": {
		"cervi": {"name": "Cervi di brina", "members": ["cervo_brina"], "fem": false, "role": "erbivoro", "nest": {"type": "erba", "n": 4}, "migrate": true},
		"gufi": {"name": "Gufi del gelo", "members": ["gufo_gelo"], "fem": false, "role": "predatore", "prey": ["lepri", "pipistrelli", "falene", "libellule"]},
	},
	"loot": {
		"cervo_brina": [
			{"item": "vello_brina", "min": 1, "max": 3, "chance": 1.0},
			{"item": "palco_brina", "min": 1, "max": 1, "chance": 0.25},
		],
		"gufo_gelo": [{"item": "piuma_gelo", "min": 1, "max": 2, "chance": 1.0}],
	},
	"items": {
		"vello_brina": {"name": "Vello di brina", "kind": "materiale", "icon": ["seta", "brina"], "desc": "Dal Cervo di brina: caldo dentro, gelato fuori."},
		"palco_brina": {"name": "Palco di brina", "kind": "materiale", "icon": ["artiglio", "brina"], "desc": "Un ramo dei palchi di un Cervo di brina. Non si scioglie mai."},
		"piuma_gelo": {"name": "Piuma del gelo", "kind": "materiale", "icon": ["penna", "brina"], "desc": "Dal Gufo del gelo: leggera come la neve che non cade."},
		"cappuccio_brina": {"name": "Cappuccio di brina", "kind": "elmo", "icon": ["elmo", "brina"], "tier": 3, "defense": 3, "acc": {"run": 1.05}, "desc": "Corsa +5%."},
		"manto_brina": {"name": "Manto di brina", "kind": "corazza", "icon": ["corazza", "brina"], "tier": 3, "defense": 5, "desc": "Vello di cervo cucito con piume del gelo."},
		"gambali_brina": {"name": "Gambali di brina", "kind": "gambali", "icon": ["gambali", "brina"], "tier": 3, "defense": 3, "acc": {"jump": 1.05}, "desc": "Salto +5%."},
		"arco_gelo": {"name": "Arco del gelo", "kind": "arco", "icon": ["arco", "brina"], "tier": 3, "damage": 16, "speed": 2.6, "knockback": 1.0, "multishot": 2, "desc": "Palchi di brina tesi con piume del gelo: due dardi a ogni tiro."},
		"dardo_gelo": {"name": "Dardo del gelo", "kind": "munizione", "icon": ["freccia", "brina"], "damage": 9, "stack": 999, "desc": "Una piuma del gelo in coda: vola dritto e punge freddo."},
		"amuleto_palco": {"name": "Amuleto del palco", "kind": "accessorio", "icon": ["amuleto", "brina"], "acc": {"run": 1.15, "jump": 1.1}, "desc": "Corsa +15%, salto +10%."},
		"cuore_brina": {"name": "Cuore di brina", "kind": "trofeo", "icon": ["essenza", "brina"], "desc": "Lo lasciano solo le creature rare di questa specie."},
		"occhio_gelo": {"name": "Occhio del gelo", "kind": "trofeo", "icon": ["occhio", "brina"], "desc": "Lo lasciano solo le creature rare di questa specie."},
		"corona_palchi": {"name": "Corona di palchi", "kind": "accessorio", "icon": ["corona", "brina"], "acc": {"run": 1.2, "fall_safe": true}, "desc": "Corsa +20%, nessuna ferita da caduta."},
		"occhio_notte_gelo": {"name": "Sguardo del gelo", "kind": "accessorio", "icon": ["occhio", "brina"], "acc": {"halo": 1.5, "stealth": 0.85}, "desc": "Alone più ampio; le creature ti notano più tardi."},
		"seme_mondo_brina": {"name": "Seme di brina", "kind": "seme_mondo", "icon": ["seme", "brina"], "species": "brina", "stack": 1, "desc": "Un Seme di mondo nutrito di brina: dietro il suo portale, boschi gelati e cieli chiari."},
	},
	"recipes": [
		{"out": "cappuccio_brina", "qty": 1, "in": {"vello_brina": 6, "piuma_gelo": 3}, "station": "telaio"},
		{"out": "manto_brina", "qty": 1, "in": {"vello_brina": 10, "piuma_gelo": 4}, "station": "telaio"},
		{"out": "gambali_brina", "qty": 1, "in": {"vello_brina": 8, "piuma_gelo": 3}, "station": "telaio"},
		{"out": "arco_gelo", "qty": 1, "in": {"palco_brina": 2, "piuma_gelo": 6, "legno": 10}, "station": "ceppo"},
		{"out": "dardo_gelo", "qty": 30, "in": {"piuma_gelo": 1, "legno": 2}, "station": "ceppo"},
		{"out": "amuleto_palco", "qty": 1, "in": {"palco_brina": 3, "vello_brina": 4, "lingotto_legnoferro": 3}, "station": "maglio"},
		{"out": "corona_palchi", "qty": 1, "in": {"cuore_brina": 2, "palco_brina": 4}, "station": "maglio"},
		{"out": "occhio_notte_gelo", "qty": 1, "in": {"occhio_gelo": 2, "piuma_gelo": 6}, "station": "maglio"},
		{"out": "seme_mondo_brina", "qty": 1, "in": {"seme_mondo": 1, "vello_brina": 10, "piuma_gelo": 6}, "station": "altare"},
	],
	"sets": {
		"brina": {"name": "Passo di brina", "pieces": ["cappuccio_brina", "manto_brina", "gambali_brina"],
			"bonus": {"defense": 2, "run": 1.12, "fall_safe": true}, "desc": "+2 Scorza, corsa +12%, nessuna ferita da caduta"},
	},
}
