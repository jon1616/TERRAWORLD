extends RefCounted
## Le creature nascoste (voce 97): un pacchetto di contenuto come quello dei biomi (`BiomesData.PACK_FILES`), unito
## alle tabelle comuni. Non nascono mai da sole: le fa uscire `HiddenCreatures` solo quando la loro condizione c'è
## (l'ora, il tempo, la stagione, un oggetto in mano). I loro quattro materiali fanno insieme un oggetto unico.
## Questo file non nomina altre classi (valori per esteso).

const DATA := {
	"creatures": {
		"lucciola_mezzanotte": {"name": "Lucciola di mezzanotte", "hp": 30, "damage": 0, "defense": 0, "knock": 0.0, "half": [6, 6],
			"speed": 90, "fly": true, "behaviors": ["vola", "fugge"], "p": {"sight": 18, "hover": 40.0, "wobble": 40.0, "flee": 14},
			"no_trophy": true, "loot": "lucciola_mezzanotte", "art": ["lucciola_mezzanotte", 0], "strata": [0], "weight": 0, "glow": true,
			"body": {"plan": "insetto", "w": 16, "h": 12, "pal": ["#10102a", "#20204a", "#3a3a7a", "#8a8ad0", "#f0f0ff"],
				"eye": "#fff0a0", "wings": "#c0c0ff", "marks": "macchie", "mark": "#fff0a0", "glow": true},
			"affinity": {"weak": ["luce"], "resist": ["vuoto"]}},
		"spirito_temporale": {"name": "Spirito del temporale", "hp": 60, "damage": 14, "defense": 2, "knock": 0.0, "half": [8, 10],
			"speed": 110, "fly": true, "behaviors": ["vola", "scatto"],
			"p": {"sight": 30, "hover": 60.0, "wobble": 30.0, "dash_every": 2.2, "dash_speed": 320.0, "dash_time": 0.4},
			"no_trophy": true, "loot": "spirito_temporale", "art": ["spirito_temporale", 0], "strata": [0], "weight": 0, "glow": true,
			"body": {"plan": "fluttuante", "w": 18, "h": 22, "pal": ["#1a2030", "#2e3a50", "#4a6080", "#a0c0f0", "#ffffa0"],
				"eye": "#ffffa0", "marks": "punte", "mark": "#ffffa0", "glow": true},
			"affinity": {"weak": ["spora"], "resist": ["luce", "gelo"]}},
		"cervo_gelo_bianco": {"name": "Cervo bianco del Gelo", "hp": 80, "damage": 0, "defense": 3, "knock": 0.4, "half": [11, 9],
			"speed": 130, "behaviors": ["fugge"], "p": {"flee": 20},
			"no_trophy": true, "loot": "cervo_gelo_bianco", "art": ["cervo_gelo_bianco", 0], "strata": [0], "weight": 0, "glow": true,
			"body": {"plan": "quadrupede", "w": 26, "h": 22, "pal": ["#8aa0b0", "#b8d0dc", "#e0f0f8", "#f8ffff", "#ffffff"],
				"eye": "#5cf0d8", "horns": 2, "glow": true},
			"affinity": {"weak": ["brace"], "resist": ["gelo"]}},
		"gatto_lanterna": {"name": "Gatto delle lanterne", "hp": 40, "damage": 0, "defense": 1, "knock": 0.2, "half": [7, 6],
			"speed": 100, "behaviors": ["fugge"], "p": {"flee": 10},
			"no_trophy": true, "loot": "gatto_lanterna", "art": ["gatto_lanterna", 0], "strata": [1, 2, 3], "weight": 0, "glow": true,
			"body": {"plan": "quadrupede", "w": 18, "h": 14, "pal": ["#1a1a20", "#2e2e38", "#4a4a58", "#7a7a8a", "#c0c0d0"],
				"eye": "#5cf0d8", "tail": true, "marks": "strisce", "mark": "#5cf0d8", "glow": true},
			"affinity": {"weak": ["luce"], "resist": ["vuoto"]}},
	},
	"families": {
		"nascoste": {"name": "Creature nascoste", "members": ["lucciola_mezzanotte", "spirito_temporale", "cervo_gelo_bianco", "gatto_lanterna"],
			"fem": true, "role": "neutro"},
	},
	"loot": {
		"lucciola_mezzanotte": [{"item": "polline_mezzanotte", "min": 1, "max": 2, "chance": 1.0}],
		"spirito_temporale": [{"item": "scintilla_temporale", "min": 1, "max": 2, "chance": 1.0}],
		"cervo_gelo_bianco": [{"item": "corno_bianco", "min": 1, "max": 1, "chance": 1.0}],
		"gatto_lanterna": [{"item": "baffo_lanterna", "min": 1, "max": 2, "chance": 1.0}],
	},
	"items": {
		"polline_mezzanotte": {"name": "Polline di mezzanotte", "kind": "materiale", "icon": ["polvere", "nottilite"], "desc": "Brilla solo quando nessuno lo guarda."},
		"scintilla_temporale": {"name": "Scintilla del temporale", "kind": "materiale", "icon": ["essenza", "brillaluce"], "desc": "Un pezzo di fulmine che non ha voluto cadere."},
		"corno_bianco": {"name": "Corno bianco", "kind": "materiale", "icon": ["artiglio", "seta"], "desc": "Più freddo della neve, più leggero dell'aria."},
		"baffo_lanterna": {"name": "Baffo di lanterna", "kind": "materiale", "icon": ["penna", "cristallo"], "desc": "Il Gatto delle lanterne lo perde solo se lo lasci andare."},
		"lanterna_quattro": {"name": "Lanterna delle quattro ore", "kind": "accessorio", "icon": ["lanterna", "nottilite"], "unique": true, "stack": 1,
			"acc": {"halo": 1.6, "luck": 0.25, "stealth": 0.8}, "effects": ["notturno", "caccia_lumini"],
			"story": "Dentro brillano insieme la notte fonda, il temporale, il gelo e il buio sotto terra: le quattro ore in cui le cose nascoste escono.",
			"source": "si fabbrica con i materiali delle quattro creature nascoste",
			"desc": "Alone molto più ampio, più fortuna, le creature ti notano più tardi; più forte di notte; più Lumini."},
	},
	"recipes": [
		{"out": "lanterna_quattro", "qty": 1, "in": {"polline_mezzanotte": 2, "scintilla_temporale": 2, "corno_bianco": 1, "baffo_lanterna": 2}, "station": "maglio"},
	],
}
