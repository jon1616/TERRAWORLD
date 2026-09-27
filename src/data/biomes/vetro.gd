extends RefCounted
## I Deserti di vetro (voce 93, terre estreme): dune di sabbia fusa in vetro che taglia, cactus trasparenti, tempeste
## di schegge. **Sete** (`HarshData`): allo scoperto la barra sale; ripara la Borraccia di rana (pelle delle Torbiere e
## bava delle Colline dei cappelli) o l'Acqua di Linfa. Il vetro ferisce i piedi: servono gli Stivali di scaglie.
## Tutto il bioma sta in questo file (campi in cima a `BiomesData`); disegni in `TreeArtExtreme` e `ExtremeDecorArt`.

const DATA := {
	"id": "vetro", "name": "Deserti di vetro", "desc": "Dune di vetro che tagliano, e nessuna ombra: portati da bere",
	"trees": 0.03, "hills": 0.8, "lift": 3, "tint": Color(1.2, 1.1, 0.85), "color": "#f4f0b0", "weight": 1,
	"grass": 36,
	"stagni": [0.0, 0, 0, 0, 0],      # voce 118: stagni di superficie (vedi `BiomesData`)
	"turf": {"name": "Sabbia di vetro", "layer": "sabbia_vetro", "pal": ["#3a3420", "#5a5230", "#8a8450", "#c8c890", "#f4fff0"], "specks": 120},
	"tree": {"id": "vetrocacto", "name": "Cactus di vetro", "glow": Color(1.6, 1.8, 1.5)},
	"veg": [[0.12, 58], [0.18, 59], [0.22, 60], [0.26, "sassi"]],
	"decor": {58: {"soft": "erba"}, 59: {"light": Color(0.2, 0.25, 0.18)}, 60: {}},
	"elem": "luce",
	"weather": {"tempesta_vetro": 3.0},
	"harsh": {"kind": "sete", "rate": 0.02, "night": 0.4},
	"hurt_tile": {"dmg": 3, "text": "Il vetro taglia i piedi!"},
	"gene": "vetro",
	"lands": [["Deserti", false], ["Dune", true], ["Distese di vetro", true]],
	"creatures": {
		"scorpione_vetro": {"name": "Scorpione di vetro", "hp": 48, "damage": 14, "defense": 5, "knock": 0.4, "half": [9, 5],
			"speed": 70, "behaviors": ["cammina", "carica"],
			"p": {"sight": 18, "charge": 240.0, "charge_range": 7, "charge_time": 0.5, "charge_cool": 2.4},
			"loot": "scorpione_vetro", "art": ["scorpione_vetro", 0], "strata": [0], "weight": 6, "biomes": ["vetro"], "glow": true,
			"body": {"plan": "insetto", "w": 22, "h": 14, "pal": ["#3a4038", "#5a6a58", "#8aa890", "#c8e8d0", "#f4fff8"],
				"eye": "#ff4a4a", "marks": "punte", "mark": "#f4fff8", "glow": true},
			"affinity": {"weak": ["gelo"], "resist": ["luce"]}, "trophy": "pungiglione_vetro"},
		"verme_dune": {"name": "Verme delle dune", "hp": 60, "damage": 16, "defense": 3, "knock": 0.7, "half": [10, 5],
			"speed": 120, "behaviors": ["scava"], "p": {"sight": 24},
			"loot": "verme_dune", "art": ["verme_dune", 0], "strata": [0], "weight": 3, "biomes": ["vetro"],
			"body": {"plan": "serpe", "w": 26, "h": 12, "pal": ["#4a3a20", "#7a6030", "#b09050", "#e0c890", "#fff4d0"],
				"eye": "#ffd24a", "marks": "strisce", "mark": "#4a3a20"},
			"affinity": {"weak": ["gelo"], "resist": ["brace"]}, "trophy": "anello_verme"},
	},
	"families": {
		"scorpioni": {"name": "Scorpioni di vetro", "members": ["scorpione_vetro"], "fem": false, "role": "predatore",
			"prey": ["saltagrilli", "lepri"], "nest": {"type": "tana", "n": 4}},
		"vermi": {"name": "Vermi delle dune", "members": ["verme_dune"], "fem": false, "role": "scavatore"},
	},
	"loot": {
		"scorpione_vetro": [{"item": "chela_vetro", "min": 1, "max": 2, "chance": 1.0}],
		"verme_dune": [{"item": "sabbia_fusa", "min": 2, "max": 4, "chance": 1.0}],
	},
	"items": {
		"chela_vetro": {"name": "Chela di vetro", "kind": "materiale", "icon": ["artiglio", "iride"], "desc": "Trasparente e affilata come il deserto."},
		"sabbia_fusa": {"name": "Sabbia fusa", "kind": "materiale", "icon": ["polvere", "ambra"], "desc": "Quello che il Verme delle dune lascia: vetro ancora morbido."},
		"elmo_vetro": {"name": "Elmo di vetro", "kind": "elmo", "icon": ["elmo", "iride"], "tier": 4, "defense": 5, "acc": {"acqua": 0.15}, "desc": "Sete: protegge un poco."},
		"corazza_vetro": {"name": "Corazza di vetro", "kind": "corazza", "icon": ["corazza", "iride"], "tier": 4, "defense": 8, "desc": "Chele di vetro fuse insieme."},
		"gambali_vetro": {"name": "Gambali di vetro", "kind": "gambali", "icon": ["gambali", "iride"], "tier": 4, "defense": 5, "desc": "Brillano al sole del deserto."},
		"pungiglione_vetro": {"name": "Pungiglione di vetro", "kind": "trofeo", "icon": ["artiglio", "iride"], "desc": "Lo lasciano solo le creature rare di questa specie."},
		"anello_verme": {"name": "Anello del verme", "kind": "trofeo", "icon": ["anello", "ambra"], "desc": "Lo lasciano solo le creature rare di questa specie."},
		"clessidra_dune": {"name": "Clessidra delle dune", "kind": "accessorio", "icon": ["lanterna", "iride"], "unique": true, "stack": 1,
			"acc": {"acqua": 0.5, "run": 1.1}, "effects": ["slancio", "cielo_aperto"],
			"story": "La sabbia dentro scende verso l'alto. Chi la porta ha sempre un po' di tempo in più prima di aver sete.",
			"source": "si fabbrica con i trofei delle creature rare dei Deserti di vetro",
			"desc": "Sete: protegge a metà; corsa +10%; sotto il cielo aperto e dopo ogni creatura vai più svelto."},
		"seme_mondo_vetro": {"name": "Seme di vetro", "kind": "seme_mondo", "icon": ["seme", "iride"], "species": "vetro", "stack": 1,
			"desc": "Un Seme di mondo trasparente e caldo: dietro il suo portale, deserti di vetro."},
		# la preparazione: si fa con i materiali di altri biomi
		"borraccia_rana": {"name": "Borraccia di rana", "kind": "accessorio", "icon": ["essenza", "lagunite"], "acc": {"acqua": 0.6},
			"desc": "Sete: protegge al 60%. Pelle delle Torbiere di Linfa, chiusa con la bava dei lumaconi."},
		"stivali_scaglie": {"name": "Stivali di scaglie", "kind": "stivali", "icon": ["stivali", "cenere"], "tier": 3, "defense": 2,
			"acc": {"passo": true}, "desc": "Il vetro e la brace non feriscono i piedi. Squame delle Cenerarie, elitre dei Prati di vento."},
		"acqua_linfa": {"name": "Acqua di Linfa", "kind": "consumabile", "icon": ["pozione", "linfa"], "boon": ["riparo_sete", 240.0], "stack": 20,
			"desc": "Per 4 minuti niente sete."},
	},
	"recipes": [
		{"out": "elmo_vetro", "qty": 1, "in": {"chela_vetro": 6, "sabbia_fusa": 6, "lingotto_ambra": 3}, "station": "maglio"},
		{"out": "corazza_vetro", "qty": 1, "in": {"chela_vetro": 10, "sabbia_fusa": 8, "lingotto_ambra": 5}, "station": "maglio"},
		{"out": "gambali_vetro", "qty": 1, "in": {"chela_vetro": 8, "sabbia_fusa": 6, "lingotto_ambra": 4}, "station": "maglio"},
		{"out": "clessidra_dune", "qty": 1, "in": {"pungiglione_vetro": 1, "anello_verme": 1, "sabbia_fusa": 12}, "station": "maglio"},
		{"out": "seme_mondo_vetro", "qty": 1, "in": {"seme_mondo": 1, "sabbia_fusa": 12, "chela_vetro": 6}, "station": "altare"},
		{"out": "borraccia_rana", "qty": 1, "in": {"pelle_rana": 6, "bava_lumacone": 4}, "station": "telaio"},
		{"out": "stivali_scaglie", "qty": 1, "in": {"squama_brace": 6, "elitra_grillo": 4}, "station": "maglio"},
		{"out": "acqua_linfa", "qty": 2, "in": {"cristallo_linfa": 1, "pelle_rana": 1}, "station": "alambicco"},
	],
	"sets": {
		"vetro": {"name": "Guscio di vetro", "pieces": ["elmo_vetro", "corazza_vetro", "gambali_vetro"],
			"bonus": {"defense": 4, "acqua": 0.35}, "desc": "+4 Scorza, sete: protegge un altro 35%"},
	},
	"genes": {
		"vetro": {"cat": "superficie", "name": "Vetro", "rar": 2, "dom": 2, "good": false,
			"desc": "deserti di vetro sotto un sole senza ombra", "item": "seme_mondo_vetro",
			"gen": {"biomes": {"vetro": 6, "ambra": 2, "cenere": 1}}},
	},
}
