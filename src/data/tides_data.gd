class_name TidesData
extends RefCounted
## Le maree del mondo (voce 137, Roadmap 15): eventi **a ondate** con un **capo** finale e un **premio**. Si annunciano
## un poco prima (scritta e segno sulla mappa), durano al più una notte (o un giorno), e la loro probabilità dipende dalla
## stagione e dai geni del mondo (`Events.chance_mult`). L'**assedio** attacca le costruzioni: una volta a stagione
## (scelta dell'utente), solo se c'è una base (Focolare e una porta), e si spegne dalle Opzioni («assedi»).
## Campi: name, desc, when (notte/giorno/eclissi), chance, seasons {stagione: ×}, color, waves [quante, creature per
## ondata], pool (le creature delle ondate), boss (il capo: una creatura), reward (tabella di bottino, in
## `src/data/bestiary/maree.gd`), rolls, siege (assedio: si attaccano le porte, le ondate nascono attorno alla base),
## sky (Roadmap 16: solo se il Germogliato è nel cielo; le altre maree lì no).

const ANNOUNCE := 40.0                   # secondi tra l'annuncio e la prima ondata
const WAVE_TIME := 70.0                  # secondi al più per un'ondata (poi arriva la seguente)
const WAVE_CLEAR := 0.7                  # quante della ondata abbattute bastano per chiamare la seguente
const SPAWN_R := [18, 26]                # tessere dal centro (il Germogliato, o la base per l'assedio)

const TIDES := {
	"notte_spore": {"name": "La Notte delle spore", "desc": "Dalle paludi salgono le spore: ondate di creature, e la Madre in fondo",
		"when": "notte", "chance": 0.06, "seasons": {"germoglio": 2.0, "rigoglio": 1.5}, "color": "#b0ff80",
		"waves": [3, 6], "pool": ["tessispore", "rospo_torba", "cappelletto", "grumo_diviso"], "boss": "signore_palude",
		"reward": "marea_spore", "rolls": 2},
	"migrazione": {"name": "La Migrazione", "desc": "I branchi attraversano il mondo e i predatori li seguono: caccia o proteggi",
		"when": "giorno", "chance": 0.06, "seasons": {"raccolto": 2.5, "germoglio": 1.2}, "color": "#e0c080",
		"waves": [3, 5], "pool": ["lupo_lunare", "lupo_ghiaccio", "cinghiale_raccolto"], "herd": ["cervo_iride", "bufalo_radice", "foca_linfa"],
		"boss": "signore_rossa", "reward": "marea_migrazione", "rolls": 2},
	"assedio": {"name": "L'Assedio dei rosicchiatori", "desc": "Vengono per la tua casa: difendi le porte con mura, luce e trappole",
		"when": "notte", "chance": 0.5, "seasons": {}, "color": "#ff9a6a", "siege": true,
		"waves": [4, 7], "pool": ["ratto_catacomba", "radicello_ladro", "ermellino", "formica_ladra"], "boss": "signore_sottobosco",
		"reward": "marea_assedio", "rolls": 3},
	"marea_brace": {"name": "La Marea di brace", "desc": "Dal Fondo sale la brace: le sue creature escono dalla terra",
		"when": "notte", "chance": 0.04, "seasons": {"rigoglio": 2.0}, "color": "#ff7a3a",
		"waves": [3, 6], "pool": ["grumo_diviso", "talpa_cenere", "salamandra_brace", "falco_brace"], "boss": "signore_brace",
		"reward": "marea_brace", "rolls": 2},
	"stormo": {"name": "Lo Stormo", "desc": "Il cielo si riempie d'ali: arrivano a ondate, e l'Aquila le guida",
		"when": "giorno", "chance": 0.05, "seasons": {"rigoglio": 1.6, "raccolto": 1.4}, "color": "#a0d8ff",
		"waves": [3, 6], "pool": ["pavoncella", "damigella_rigoglio", "falena_vampira", "falco_brace"], "boss": "signore_prati",
		"reward": "marea_stormo", "rolls": 2},
	# Roadmap 16, voce 164: solo in cielo (all'alba o al tramonto, se il Germogliato è tra le Chiome)
	"burrasca": {"name": "La Burrasca delle Chiome", "desc": "Il vento del cielo porta gli stormi da caccia, e il loro re li guida",
		"when": "giorno", "sky": true, "chance": 0.3, "seasons": {"rigoglio": 1.3}, "color": "#c8e0ff",
		"waves": [3, 5], "pool": ["garzetta_nubi", "falco_vento", "gazza_vento", "anguilla_vento", "scintilla_viva"],
		"boss": "signore_giardini_vento", "reward": "marea_cielo", "rolls": 2},
	"eclissi_mimi": {"name": "L'Eclissi dei mimi", "desc": "Il sole si spegne e le cose non sono più quello che sembrano",
		"when": "eclissi", "chance": 0.5, "seasons": {}, "color": "#ffb040",
		"waves": [3, 5], "pool": ["eclissimo", "stellamimo", "lucertola_vetro"], "boss": "signore_stellare",
		"reward": "marea_eclissi", "rolls": 2},
}


static func for_time(when: String) -> Array:
	return TIDES.keys().filter(func(k: String) -> bool: return String(TIDES[k]["when"]) == when)
