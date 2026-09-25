class_name CreaturesData
extends RefCounted
## Le creature del Giardino: statistiche, comportamenti, bottino, dove vivono. Solo dati.
##
## Campi:
##   name, hp, damage (al contatto), defense (toglie metà del suo valore a ogni colpo), knock (0-1: quanto resiste al
##   contraccolpo), half [x, y] (mezza misura del corpo in px), speed (px/s), fly (vola, niente gravità)
##   behaviors  comportamenti combinabili (vedi `Behavior.make`): salta_verso · cammina · vola · carica · spara · fermo
##   p          parametri dei comportamenti (salto, carica, spara…)
##   loot       tabella di `LootData`
##   art        forma per `CreatureArt.frames` (con la variante di colore)
##   strata     strati in cui compare (indici di `StrataData.STRATA`): 0 superficie, 1 sottobosco di radici, 2 caverne
##              d'ardesia, 3 profondità della Linfa, 4 il Fondo; weight = quanto spesso, rispetto alle altre dello strato.
##              Vita e danno si moltiplicano per il `danger` dello strato in cui la creatura compare.
##   glow       brilla nel buio
##   night      compare solo di notte (vedi `DayCycle`)
##   biomes     in superficie compare solo in questi biomi (`BiomesData`); sotto terra non conta
##   boss       un Guardiano: non compare da solo, non sparisce lontano, ha la barra in alto

const CREATURES := {
	# i grumi: gocce di muschio, resina o spore che si sono animate e saltellano
	"grumo_muschio": {"name": "Grumo di muschio", "hp": 14, "damage": 6, "defense": 0, "knock": 0.0, "half": [6, 5],
		"speed": 80, "behaviors": ["salta_verso"], "p": {"jump": 260.0, "sight": 20},
		"loot": "grumo", "art": ["grumo", 0], "strata": [0, 1], "weight": 10},
	"grumo_resina": {"name": "Grumo di resina", "hp": 22, "damage": 8, "defense": 1, "knock": 0.1, "half": [6, 5],
		"speed": 85, "behaviors": ["salta_verso"], "p": {"jump": 280.0, "sight": 22},
		"loot": "grumo_resina", "art": ["grumo", 1], "strata": [1, 2], "weight": 8},
	"grumo_spore": {"name": "Grumo di spore", "hp": 30, "damage": 11, "defense": 2, "knock": 0.2, "half": [6, 5],
		"speed": 95, "behaviors": ["salta_verso"], "p": {"jump": 300.0, "sight": 24},
		"loot": "grumo_spore", "art": ["grumo", 2], "strata": [0, 2, 3], "weight": 6, "biomes": ["palude"]},
	# falena di brace: vola ondeggiando verso la luce (e verso di te), le ali lasciano scintille
	"falena_brace": {"name": "Falena di brace", "hp": 12, "damage": 8, "defense": 0, "knock": 0.0, "half": [6, 5],
		"speed": 70, "fly": true, "behaviors": ["vola"], "p": {"sight": 26, "wobble": 30.0},
		"loot": "falena", "art": ["falena", 0], "strata": [0, 1, 2], "weight": 5, "glow": true},
	# strisciaradice: una radice che ha imparato a strisciare
	"strisciaradice": {"name": "Strisciaradice", "hp": 20, "damage": 9, "defense": 2, "knock": 0.3, "half": [9, 5],
		"speed": 45, "behaviors": ["cammina"], "p": {"sight": 24},
		"loot": "strisciaradice", "art": ["strisciaradice", 0], "strata": [1, 2], "weight": 6, "glow": true},
	# scarabeo d'ardesia: guscio di roccia, carica a testa bassa quando ti vede sulla sua linea
	"scarabeo_ardesia": {"name": "Scarabeo d'ardesia", "hp": 45, "damage": 14, "defense": 6, "knock": 0.6,
		"half": [9, 6], "speed": 40, "behaviors": ["cammina", "carica"],
		"p": {"sight": 20, "charge": 230.0, "charge_range": 10, "charge_time": 0.8, "charge_cool": 3.0},
		"loot": "scarabeo", "art": ["scarabeo", 0], "strata": [0, 2, 3, 4], "weight": 4, "biomes": ["ambra"]},
	# sputaspore: una pianta ferma che sputa spore a chi si avvicina
	"sputaspore": {"name": "Sputaspore", "hp": 28, "damage": 6, "defense": 2, "knock": 1.0, "half": [6, 7],
		"speed": 0, "behaviors": ["fermo", "spara"],
		"p": {"sight": 18, "rate": 2.4, "shot_speed": 190.0, "shot_grav": 180.0, "shot_damage": 12},
		"loot": "sputaspore", "art": ["sputaspore", 0], "strata": [0, 3, 4], "weight": 4, "glow": true, "biomes": ["palude"]},
	# il primo Guardiano: un nodo di radici enorme attorno al Cuore del mondo, ammalato dall'Avvizzimento.
	# Fase 1: ondeggia e scaglia ventagli di spore, ogni tanto scatta addosso. Fase 2 (metà Vita): più veloce, evoca grumi.
	"guardiano_nodo": {"name": "Il Nodo Avvizzito", "hp": 900, "damage": 20, "defense": 8, "knock": 1.0, "half": [20, 20],
		"speed": 60, "fly": true, "behaviors": ["vola", "ventaglio", "scatto", "evoca"],
		"p": {"sight": 70, "wobble": 25.0, "leash": 26, "fan_rate": 2.8, "fan_n": 5, "fan_spread": 0.8,
			"shot_speed": 170.0, "shot_grav": 40.0, "shot_damage": 16, "dash_every": 6.0, "dash_speed": 300.0,
			"dash_time": 0.55, "summon_every": 8.0, "summon": "grumo_spore", "summon_max": 3, "phase2": 0.5},
		"loot": "guardiano", "art": ["guardiano", 0], "strata": [], "weight": 0, "glow": true, "boss": true},
	# la Regina delle Spore, Guardiana dei mondi di vigore 2: una medusa di spore enorme che vola, scaglia ventagli
	# larghi, scatta e chiama sputaspore e grumi di spore
	"regina_spore": {"name": "La Regina delle Spore", "hp": 1300, "damage": 24, "defense": 10, "knock": 1.0,
		"half": [22, 20], "speed": 75, "fly": true, "behaviors": ["vola", "ventaglio", "scatto", "evoca"],
		"p": {"sight": 70, "wobble": 40.0, "leash": 26, "fan_rate": 2.2, "fan_n": 7, "fan_spread": 1.3,
			"shot_speed": 160.0, "shot_grav": 30.0, "shot_damage": 20, "dash_every": 5.0, "dash_speed": 330.0,
			"dash_time": 0.5, "summon_every": 7.0, "summon": "grumo_spore", "summon_max": 4, "phase2": 0.5},
		"loot": "regina", "art": ["regina", 0], "strata": [], "weight": 0, "glow": true, "boss": true},
	# il Colosso d'Ardesia, Guardiano dei mondi di vigore 3: una montagna di scaglie che cammina, carica e scaglia rocce
	"colosso_ardesia": {"name": "Il Colosso d'Ardesia", "hp": 2200, "damage": 32, "defense": 16, "knock": 1.0,
		"half": [24, 22], "speed": 45, "behaviors": ["cammina", "carica", "spara", "evoca"],
		"p": {"sight": 70, "charge": 280.0, "charge_range": 20, "charge_time": 1.0, "charge_cool": 4.0, "rate": 2.6,
			"shot_speed": 230.0, "shot_grav": 420.0, "shot_damage": 26, "summon_every": 9.0,
			"summon": "scarabeo_ardesia", "summon_max": 2, "phase2": 0.5},
		"loot": "colosso", "art": ["colosso", 0], "strata": [], "weight": 0, "glow": true, "boss": true},
	# avvizzito errante: un guscio di radici svuotato dall'Avvizzimento; cammina in superficie, solo di notte
	"avvizzito_errante": {"name": "Avvizzito errante", "hp": 32, "damage": 11, "defense": 2, "knock": 0.3, "half": [5, 11],
		"speed": 42, "behaviors": ["cammina"], "p": {"sight": 30}, "loot": "avvizzito", "art": ["avvizzito", 0],
		"strata": [0], "weight": 12, "night": true, "glow": true},
	# vagavuoto: un occhio di vuotite che fluttua nel Fondo e scaglia schegge
	"vagavuoto": {"name": "Vagavuoto", "hp": 40, "damage": 14, "defense": 4, "knock": 0.3, "half": [8, 7],
		"speed": 55, "fly": true, "behaviors": ["vola", "spara"],
		"p": {"sight": 24, "wobble": 40.0, "rate": 3.0, "shot_speed": 210.0, "shot_grav": 60.0, "shot_damage": 16},
		"loot": "vagavuoto", "art": ["vagavuoto", 0], "strata": [4], "weight": 6, "glow": true},
}

## Tetto di creature, ritmo e distanza delle nascite: vedi `DangerData` (voce 20).
## Distanza (tessere) oltre cui una creatura sparisce.
const DESPAWN := 90


## Le creature che possono comparire in uno strato, con il loro peso: [[id, peso], …]. Quelle della notte solo di notte.
static func of_stratum(s: int, night := false, biome := "") -> Array:
	var out := []
	for id in CREATURES:
		var c: Dictionary = CREATURES[id]
		if s == 0 and c.has("biomes") and not biome in c["biomes"]:
			continue
		# nelle terre avvizzite gli Avvizziti erranti camminano anche di giorno
		if s in c["strata"] and (night or not c.get("night", false) or biome == "avvizzito"):
			out.append([id, int(c["weight"])])
	return out
