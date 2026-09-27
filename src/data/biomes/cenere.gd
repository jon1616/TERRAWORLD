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
	"lands": [["Cenerarie", true], ["Lande", true], ["Roghi", false]],
	# --- il pacchetto (spostato qui dalle tabelle comuni il 28 set 2026) ---
	"creatures": {
		"salamandra_brace": {"name": "Salamandra di brace", "hp": 46, "damage": 13, "defense": 2, "knock": 0.3,
			"half": [10, 4], "speed": 75, "behaviors": ["salta_verso"], "p": {"jump": 230.0, "sight": 20},
			"loot": "salamandra", "art": ["salamandra", 0], "strata": [0], "weight": 6, "glow": true, "biomes": ["cenere"],
			"affinity": {"weak": ["gelo"], "resist": ["brace"]}, "trophy": "coda_brace"},
		"fatuo_cenere": {"name": "Fatuo di cenere", "hp": 20, "damage": 9, "defense": 0, "knock": 0.0, "half": [5, 6],
			"speed": 90, "fly": true, "behaviors": ["vola", "scatto"], "group": [2, 3],
			"p": {"sight": 26, "hover": 40.0, "wobble": 40.0, "dash_every": 3.2, "dash_speed": 250.0, "dash_time": 0.4},
			"loot": "fatuo_cenere", "art": ["fatuo_cenere", 0], "strata": [0], "weight": 5, "glow": true, "biomes": ["cenere"],
			"affinity": {"weak": ["linfa"], "resist": ["brace"]}, "trophy": "fiamma_fatua"},
	},
	"families": {
		"salamandre": {"name": "Salamandre di brace", "members": ["salamandra_brace"], "fem": true, "role": "predatore", "prey": ["bruchi", "formiche", "lepri"], "nest": {"type": "tana", "n": 4}},
		"fatui": {"name": "Fatui di cenere", "members": ["fatuo_cenere"], "fem": false, "role": "neutro"},
	},
	"loot": {
		"salamandra": [
			{"item": "squama_brace", "min": 1, "max": 2, "chance": 1.0},
			{"item": "fungo_brace", "min": 1, "max": 1, "chance": 0.2},
		],
		"fatuo_cenere": [{"item": "cenere_viva", "min": 1, "max": 2, "chance": 0.9}],
	},
	"items": {
		"squama_brace": {"name": "Squama di salamandra", "kind": "materiale", "icon": ["scaglia", "cenere"], "desc": "Dalla schiena di una Salamandra di brace: ancora tiepida."},
		"cenere_viva": {"name": "Cenere viva", "kind": "materiale", "icon": ["polvere", "brace"], "desc": "Quello che resta di un Fatuo di cenere: una polvere che non si spegne."},
		"elmo_squame": {"name": "Elmo di squame", "kind": "elmo", "icon": ["elmo", "cenere"], "tier": 3, "defense": 4, "acc": {"damage": 1.04}, "desc": "Danno +4%."},
		"corazza_squame": {"name": "Corazza di squame", "kind": "corazza", "icon": ["corazza", "cenere"], "tier": 3, "defense": 6, "desc": "Squame di salamandra su legnoferro."},
		"gambali_squame": {"name": "Gambali di squame", "kind": "gambali", "icon": ["gambali", "cenere"], "tier": 3, "defense": 4, "desc": "Pesanti, ma tengono il calore."},
		"lama_salamandra": {"name": "Lama della salamandra", "kind": "spada", "icon": ["spada", "cenere"], "tier": 3, "damage": 19, "speed": 2.5, "knockback": 2.2, "desc": "Una lama di squame ancora tiepide."},
		"cuore_brace": {"name": "Cuore di brace", "kind": "accessorio", "icon": ["amuleto", "brace"], "acc": {"damage": 1.08, "thorns": 6}, "desc": "Danno +8%; chi ti tocca si scotta (6)."},
		"coda_brace": {"name": "Coda di brace", "kind": "trofeo", "icon": ["artiglio", "brace"], "desc": "La lasciano solo le creature rare di questa specie."},
		"fiamma_fatua": {"name": "Fiamma fatua", "kind": "trofeo", "icon": ["essenza", "brace"], "desc": "La lasciano solo le creature rare di questa specie."},
		"frusta_brace": {"name": "Frusta di coda", "kind": "spada", "icon": ["lama", "brace"], "tier": 4, "damage": 23, "speed": 3.2, "knockback": 1.5, "poison": true, "desc": "Una coda di salamandra che schiocca: ogni colpo brucia (avvelena)."},
		"lanterna_fatua": {"name": "Lanterna fatua", "kind": "accessorio", "icon": ["lanterna", "brace"], "acc": {"halo": 1.6, "magic": 1.1}, "desc": "Alone molto più ampio, incantesimi +10%."},
		"seme_mondo_cenere": {"name": "Seme di cenere", "kind": "seme_mondo", "icon": ["seme", "cenere"], "species": "cenere", "stack": 1, "desc": "Un Seme di mondo nutrito di cenere viva: dietro il suo portale, pianure di cenere e braci."},
	},
	"recipes": [
		{"out": "elmo_squame", "qty": 1, "in": {"squama_brace": 8, "lingotto_legnoferro": 4}, "station": "maglio"},
		{"out": "corazza_squame", "qty": 1, "in": {"squama_brace": 12, "lingotto_legnoferro": 6}, "station": "maglio"},
		{"out": "gambali_squame", "qty": 1, "in": {"squama_brace": 10, "lingotto_legnoferro": 5}, "station": "maglio"},
		{"out": "lama_salamandra", "qty": 1, "in": {"squama_brace": 8, "cenere_viva": 4, "lingotto_legnoferro": 5}, "station": "maglio"},
		{"out": "cuore_brace", "qty": 1, "in": {"cenere_viva": 10, "squama_brace": 3}, "station": "alambicco"},
		{"out": "frusta_brace", "qty": 1, "in": {"coda_brace": 2, "squama_brace": 8}, "station": "maglio"},
		{"out": "lanterna_fatua", "qty": 1, "in": {"fiamma_fatua": 2, "cenere_viva": 8}, "station": "maglio"},
		{"out": "seme_mondo_cenere", "qty": 1, "in": {"seme_mondo": 1, "cenere_viva": 12, "squama_brace": 6}, "station": "altare"},
	],
	"sets": {
		"cenere": {"name": "Cuore di brace", "pieces": ["elmo_squame", "corazza_squame", "gambali_squame"],
			"bonus": {"defense": 3, "damage": 1.1, "thorns": 12}, "desc": "+3 Scorza, +10% danno, chi ti tocca si brucia (12)"},
	},
}
