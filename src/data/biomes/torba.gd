extends RefCounted
## Le Torbiere di Linfa (voce 92, terre temperate): piane basse di torba scura, mangrovie con le radici ad arco,
## ninfee che brillano di Linfa, nebbia. Le Rane di torba saltano tra i giunchi; l'Airone di torba scende in picchiata
## a prenderle. Tutto il bioma sta in questo file (campi in cima a `BiomesData`); disegni: `TreeArtTemperate._mangrovia`,
## `TemperateDecorArt` 55-57, le creature con `BodyArt`.

const DATA := {
	"id": "torba", "name": "Torbiere di Linfa", "desc": "Torba scura e nebbia bassa: le ninfee brillano di Linfa",
	"trees": 0.12, "hills": 0.2, "lift": 14, "tint": Color(0.76, 1.0, 0.95), "color": "#5cf0d8", "weight": 2,
	"grass": 35,
	"stagni": [5.0, 12, 34, 2, 4],      # voce 118: stagni di superficie (vedi `BiomesData`)
	# voce 120: i pesci degli stagni di questo bioma (campi in cima a `FishData`)
	"fish": {
		"pesce_torbina": {"name": "Torbina", "rar": "comune", "size": [10, 25], "color": "humus", "biomes": ["torba"], "desc": "Scura come l'acqua delle torbiere, che non lascia vedere il fondo."},
		"pesce_luccio_torba": {"name": "Luccio delle torbiere", "rar": "non_comune", "size": [50, 100], "color": "humus", "biomes": ["torba"], "depth": 3, "desc": "Aspetta immobile nell'acqua nera, poi scatta."},
	},
	"turf": {"name": "Torba viva", "layer": "torba", "pal": ["#101c18", "#1a2e28", "#28463c", "#3a6a58", "#6ab890"], "specks": 30},
	"tree": {"id": "mangrovia", "name": "Mangrovia di torba", "glow": Color(1.0, 1.8, 1.6)},
	"veg": [[0.3, 55], [0.37, 56], [0.43, 57], [0.5, "spora"]],
	"decor": {55: {"soft": "pianta"}, 56: {"soft": "pianta", "light": Color(0.1, 0.4, 0.36)}, 57: {}},
	"elem": "linfa",
	"weather": {"nebbia": 2.5, "pioggia": 1.3},
	"gene": "torba",
	"fauna": ["libellula_brina"],
	"lands": [["Torbiere", true], ["Paludi basse", true], ["Stagni", false]],
	# --- il pacchetto ------------------------------------------------------------------------------------------------
	"creatures": {
		"rana_torba": {"name": "Rana di torba", "hp": 20, "damage": 7, "defense": 1, "knock": 0.1, "half": [6, 5], "speed": 70,
			"behaviors": ["salta_verso"], "p": {"jump": 280.0, "sight": 16},
			"loot": "rana_torba", "art": ["rana_torba", 0], "strata": [0], "weight": 8, "biomes": ["torba"], "glow": true,
			"body": {"plan": "anfibio", "w": 16, "h": 12, "pal": ["#0e2018", "#1a3a2a", "#2a5a40", "#4a8a60", "#90d0a0"],
				"eye": "#5cf0d8", "marks": "macchie", "mark": "#5cf0d8", "glow": true},
			"affinity": {"weak": ["gelo"], "resist": ["linfa"]}, "trophy": "cuore_rana"},
		"airone_torba": {"name": "Airone di torba", "hp": 34, "damage": 11, "defense": 1, "knock": 0.2, "half": [9, 8], "speed": 85,
			"fly": true, "behaviors": ["vola", "scatto"],
			"p": {"sight": 28, "hover": 90.0, "wobble": 15.0, "dash_every": 3.0, "dash_speed": 280.0, "dash_time": 0.5},
			"loot": "airone_torba", "art": ["airone_torba", 0], "strata": [0], "weight": 4, "biomes": ["torba"],
			"body": {"plan": "uccello", "w": 26, "h": 20, "pal": ["#1a2a2a", "#2e4646", "#4a6a6a", "#8aa8a8", "#e0f0f0"],
				"eye": "#ffd24a", "wings": "#4a6a6a", "tail": true},
			"affinity": {"weak": ["brace"], "resist": ["gelo"]}, "trophy": "becco_airone"},
	},
	"families": {
		"rane": {"name": "Rane di torba", "members": ["rana_torba"], "fem": true, "role": "neutro", "nest": {"type": "erba", "n": 5}},
		"aironi": {"name": "Aironi di torba", "members": ["airone_torba"], "fem": false, "role": "predatore",
			"prey": ["rane", "saltagrilli", "libellule"]},
	},
	"loot": {
		"rana_torba": [{"item": "pelle_rana", "min": 1, "max": 2, "chance": 1.0}],
		"airone_torba": [{"item": "piuma_airone", "min": 1, "max": 3, "chance": 1.0}],
	},
	"items": {
		"pelle_rana": {"name": "Pelle di rana di torba", "kind": "materiale", "icon": ["seta", "lagunite"], "desc": "Liscia, fresca, non si bagna mai."},
		"piuma_airone": {"name": "Piuma d'airone", "kind": "materiale", "icon": ["penna", "seta"], "desc": "Lunga e grigia, profuma di nebbia."},
		"cappuccio_torba": {"name": "Cappuccio di torba", "kind": "elmo", "icon": ["elmo", "lagunite"], "tier": 3, "defense": 2, "acc": {"respiro": 1.2}, "desc": "Respiro sott'acqua +20%."},
		"veste_torba": {"name": "Veste di torba", "kind": "corazza", "icon": ["corazza", "lagunite"], "tier": 3, "defense": 4, "desc": "Pelle di rana e piume d'airone."},
		"gambali_torba": {"name": "Gambali di torba", "kind": "gambali", "icon": ["gambali", "lagunite"], "tier": 3, "defense": 3, "acc": {"run": 1.04}, "desc": "Corsa +4%."},
		"cuore_rana": {"name": "Cuore di rana", "kind": "trofeo", "icon": ["essenza", "linfa"], "desc": "Lo lasciano solo le creature rare di questa specie."},
		"becco_airone": {"name": "Becco d'airone", "kind": "trofeo", "icon": ["artiglio", "seta"], "desc": "Lo lasciano solo le creature rare di questa specie."},
		"ninfea_perenne": {"name": "Ninfea perenne", "kind": "accessorio", "icon": ["essenza", "linfa"], "unique": true, "stack": 1,
			"acc": {"respiro": 1.6}, "effects": ["anfibio", "respiro_lungo"],
			"story": "Fiorì sulla prima goccia di Linfa caduta nel Giardino. Da allora non ha più chiuso i petali.",
			"source": "si fabbrica con i trofei delle creature rare delle Torbiere di Linfa",
			"desc": "Respiro sott'acqua +60%; nell'acqua sei più svelto e respiri a lungo."},
		"seme_mondo_torba": {"name": "Seme di torba", "kind": "seme_mondo", "icon": ["seme", "lagunite"], "species": "torba", "stack": 1,
			"desc": "Un Seme di mondo umido e scuro: dietro il suo portale, torbiere di Linfa."},
	},
	"recipes": [
		{"out": "cappuccio_torba", "qty": 1, "in": {"pelle_rana": 6, "piuma_airone": 3}, "station": "telaio"},
		{"out": "veste_torba", "qty": 1, "in": {"pelle_rana": 10, "piuma_airone": 4}, "station": "telaio"},
		{"out": "gambali_torba", "qty": 1, "in": {"pelle_rana": 8, "piuma_airone": 3}, "station": "telaio"},
		{"out": "ninfea_perenne", "qty": 1, "in": {"cuore_rana": 1, "becco_airone": 1, "pelle_rana": 8}, "station": "maglio"},
		{"out": "seme_mondo_torba", "qty": 1, "in": {"seme_mondo": 1, "pelle_rana": 10, "piuma_airone": 6}, "station": "altare"},
	],
	"sets": {
		"torba": {"name": "Passo di torba", "pieces": ["cappuccio_torba", "veste_torba", "gambali_torba"],
			"bonus": {"respiro": 1.5, "run": 1.08, "defense": 1}, "desc": "respiro sott'acqua +50%, corsa +8%, +1 Scorza"},
	},
	"genes": {
		"torba": {"cat": "superficie", "name": "Torba", "rar": 1, "dom": 2, "good": true,
			"desc": "piane di torba, nebbia e ninfee di Linfa", "item": "seme_mondo_torba",
			"gen": {"biomes": {"torba": 6, "palude": 2, "prati": 1}}},
	},
}
