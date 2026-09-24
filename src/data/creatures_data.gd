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
##   strata     strati in cui compare: 0 superficie, 1 sottobosco di radici, 2 caverne d'ardesia, 3 profondità della
##              Linfa, 4 il Fondo (voce 5b); weight = quanto spesso, rispetto alle altre dello stesso strato
##   glow       brilla nel buio

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
		"loot": "grumo_spore", "art": ["grumo", 2], "strata": [2, 3], "weight": 6},
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
		"loot": "scarabeo", "art": ["scarabeo", 0], "strata": [2, 3], "weight": 4},
	# sputaspore: una pianta ferma che sputa spore a chi si avvicina
	"sputaspore": {"name": "Sputaspore", "hp": 28, "damage": 6, "defense": 2, "knock": 1.0, "half": [6, 7],
		"speed": 0, "behaviors": ["fermo", "spara"],
		"p": {"sight": 18, "rate": 2.4, "shot_speed": 190.0, "shot_grav": 180.0, "shot_damage": 12},
		"loot": "sputaspore", "art": ["sputaspore", 0], "strata": [3, 4], "weight": 4, "glow": true},
}

## Quante creature al massimo attorno al giocatore, e ogni quanto si prova a farne comparire una.
const MAX_ALIVE := 7
const SPAWN_EVERY := 2.0
## Distanza in tessere: compaiono fuori dalla visuale ma non troppo lontano; spariscono se ci si allontana molto.
const SPAWN_MIN := 30
const SPAWN_MAX := 50
const DESPAWN := 90


## Lo strato di una profondità (provvisorio: la voce 5b lo prende dalla tabella degli strati).
static func stratum_of(depth: int) -> int:
	if depth < 20:
		return 0
	if depth < 120:
		return 1
	if depth < 350:
		return 2
	if depth < 600:
		return 3
	return 4


## Le creature che possono comparire in uno strato, con il loro peso: [[id, peso], …].
static func of_stratum(s: int) -> Array:
	var out := []
	for id in CREATURES:
		var c: Dictionary = CREATURES[id]
		if s in c["strata"]:
			out.append([id, int(c["weight"])])
	return out
