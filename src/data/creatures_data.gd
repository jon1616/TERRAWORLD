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
##   group      [min, max]: nasce in sciame (le compagne non contano nel tetto delle creature)
##   roll       rotola quando carica (il disegno gira su sé stesso)
##   disguise   il primo fotogramma è un travestimento (va con il comportamento «mimo»)
## Comportamenti della voce 22: agguato (appesa al soffitto, cade addosso), scava (nuota nella terra), teletrasporto,
## guscio (colpita si chiude), bombarda (lascia cadere colpi dall'alto), mimo (travestita finché non ti avvicini).
## Parametri nuovi: hover (quanto vola alta sopra il bersaglio), slow e shot_look (ragnatele che invischiano).

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
	# voce 73: le creature d'acqua (nascono solo nei liquidi, `water`); il pesce è docile, l'anguilla morde
	"pesce_lume": {"name": "Pesce lume", "hp": 16, "damage": 4, "defense": 0, "knock": 1.0, "half": [6, 4],
		"speed": 55, "fly": true, "behaviors": ["nuota"], "p": {"sight": 10}, "loot": "pesce_lume", "art": ["pesce", 0],
		"strata": [], "weight": 8, "water": true, "docile": true, "glow": true, "no_trophy": true},
	"anguilla_linfa": {"name": "Anguilla di Linfa", "hp": 48, "damage": 13, "defense": 2, "knock": 0.8, "half": [12, 4],
		"speed": 80, "fly": true, "behaviors": ["nuota"], "p": {"sight": 16, "bite": true}, "loot": "anguilla_linfa",
		"art": ["anguilla", 0], "strata": [], "weight": 4, "water": true, "glow": true, "no_trophy": true},
	# voce 72: l'Avvizzitore, il Seme Nero cresciuto, Guardiano del mondo dove cadde: vola, scaglia ventagli fitti,
	# scatta e chiama gli avvizziti erranti
	"avvizzitore": {"name": "L'Avvizzitore", "hp": 3600, "damage": 38, "defense": 20, "knock": 1.0,
		"half": [32, 30], "speed": 80, "fly": true, "behaviors": ["vola", "ventaglio", "scatto", "evoca"],
		"p": {"sight": 80, "wobble": 35.0, "leash": 30, "fan_rate": 1.8, "fan_n": 9, "fan_spread": 1.6,
			"shot_speed": 190.0, "shot_grav": 25.0, "shot_damage": 26, "dash_every": 4.5, "dash_speed": 360.0,
			"dash_time": 0.5, "summon_every": 7.0, "summon": "avvizzito_errante", "summon_max": 4, "phase2": 0.5},
		"loot": "avvizzitore", "art": ["avvizzitore", 0], "strata": [], "weight": 0, "glow": true, "boss": true},
	# avvizzito errante: un guscio di radici svuotato dall'Avvizzimento; cammina in superficie, solo di notte
	"avvizzito_errante": {"name": "Avvizzito errante", "hp": 32, "damage": 11, "defense": 2, "knock": 0.3, "half": [5, 11],
		"speed": 42, "behaviors": ["cammina"], "p": {"sight": 30}, "loot": "avvizzito", "art": ["avvizzito", 0],
		"strata": [0], "weight": 12, "night": true, "glow": true},
	# vagavuoto: un occhio di vuotite che fluttua nel Fondo e scaglia schegge
	"vagavuoto": {"name": "Vagavuoto", "hp": 40, "damage": 14, "defense": 4, "knock": 0.3, "half": [8, 7],
		"speed": 55, "fly": true, "behaviors": ["vola", "spara"],
		"p": {"sight": 24, "wobble": 40.0, "rate": 3.0, "shot_speed": 210.0, "shot_grav": 60.0, "shot_damage": 16},
		"loot": "vagavuoto", "art": ["vagavuoto", 0], "strata": [4], "weight": 6, "glow": true},
	# --- voce 22: il bestiario si allarga ---
	# superficie: il corvo di corteccia vola alto e si getta in picchiata
	"corvo_corteccia": {"name": "Corvo di corteccia", "hp": 18, "damage": 8, "defense": 0, "knock": 0.0, "half": [8, 6],
		"speed": 90, "fly": true, "behaviors": ["vola", "scatto"],
		"p": {"sight": 26, "hover": 70.0, "wobble": 25.0, "dash_every": 3.5, "dash_speed": 260.0, "dash_time": 0.45},
		"loot": "corvo", "art": ["corvo", 0], "strata": [0], "weight": 6, "biomes": ["foresta", "ambra"]},
	# lo spinoriccio cammina, poi si appallottola e carica rotolando
	"spinoriccio": {"name": "Spinoriccio", "hp": 26, "damage": 10, "defense": 3, "knock": 0.3, "half": [7, 6],
		"speed": 40, "behaviors": ["cammina", "carica"], "roll": true,
		"p": {"sight": 18, "charge": 210.0, "charge_range": 9, "charge_time": 1.1, "charge_cool": 3.5},
		"loot": "spinoriccio", "art": ["spinoriccio", 0], "strata": [0, 1], "weight": 5, "biomes": ["ambra", "foresta"]},
	# di notte: sciami di lucciole voraci
	"lucciola_vorace": {"name": "Lucciola vorace", "hp": 7, "damage": 5, "defense": 0, "knock": 0.0, "half": [4, 3],
		"speed": 85, "fly": true, "behaviors": ["vola"], "p": {"sight": 30, "wobble": 45.0}, "group": [3, 5],
		"loot": "lucciola", "art": ["lucciola", 0], "strata": [0], "weight": 8, "night": true, "glow": true},
	# sottobosco: il tessiradice aspetta appeso al soffitto, cade addosso e tira ragnatele che invischiano
	"tessiradice": {"name": "Tessiradice", "hp": 30, "damage": 11, "defense": 2, "knock": 0.3, "half": [8, 5],
		"speed": 60, "behaviors": ["agguato", "cammina", "spara"],
		"p": {"sight": 20, "drop_x": 3, "rate": 3.0, "shot_speed": 200.0, "shot_grav": 150.0, "shot_damage": 4,
			"slow": 2.5, "shot_look": "ragnatela"},
		"loot": "tessiradice", "art": ["tessiradice", 0], "strata": [1, 2], "weight": 6, "glow": true},
	# il talpone nuota nella terra e salta fuori a mordere
	"talpone": {"name": "Talpone di humus", "hp": 34, "damage": 12, "defense": 3, "knock": 0.6, "half": [8, 6],
		"speed": 110, "behaviors": ["scava"], "p": {"sight": 22},
		"loot": "talpone", "art": ["talpone", 0], "strata": [1, 2], "weight": 4},
	"saltafungo": {"name": "Saltafungo", "hp": 24, "damage": 9, "defense": 1, "knock": 0.1, "half": [6, 7],
		"speed": 70, "behaviors": ["salta_verso"], "p": {"jump": 250.0, "sight": 18},
		"loot": "saltafungo", "art": ["saltafungo", 0], "strata": [1, 2], "weight": 6, "glow": true},
	# caverne: l'ala d'ardesia svolazza sopra la testa e scatta
	"ala_ardesia": {"name": "Ala d'ardesia", "hp": 28, "damage": 12, "defense": 2, "knock": 0.1, "half": [7, 5],
		"speed": 95, "fly": true, "behaviors": ["vola", "scatto"],
		"p": {"sight": 26, "hover": 40.0, "wobble": 55.0, "dash_every": 3.0, "dash_speed": 280.0, "dash_time": 0.4},
		"loot": "ala_ardesia", "art": ["ala_ardesia", 0], "strata": [2, 3], "weight": 6, "glow": true},
	# la chiocciola di cristallo si chiude nel guscio quando la colpisci
	"chiocciola_cristallo": {"name": "Chiocciola di cristallo", "hp": 60, "damage": 12, "defense": 8, "knock": 0.7,
		"half": [8, 6], "speed": 22, "behaviors": ["cammina", "guscio"], "p": {"sight": 16, "shell_time": 2.5},
		"loot": "chiocciola", "art": ["chiocciola", 0], "strata": [2, 3], "weight": 4, "glow": true},
	# il geomimo sembra un mucchio di rocce con i cristalli; si sveglia quando gli sei addosso
	"geomimo": {"name": "Geomimo", "hp": 70, "damage": 18, "defense": 6, "knock": 0.6, "half": [7, 7],
		"speed": 90, "behaviors": ["mimo", "salta_verso"], "disguise": true, "p": {"wake": 3.5, "jump": 300.0, "sight": 24},
		"loot": "geomimo", "art": ["geomimo", 0], "strata": [2, 3, 4], "weight": 3, "glow": true},
	# profondità della Linfa: la serpe nuota nell'aria e scatta
	"serpe_linfa": {"name": "Serpe di Linfa", "hp": 45, "damage": 16, "defense": 3, "knock": 0.3, "half": [9, 4],
		"speed": 110, "fly": true, "behaviors": ["vola", "scatto"],
		"p": {"sight": 30, "wobble": 60.0, "dash_every": 2.6, "dash_speed": 320.0, "dash_time": 0.4},
		"loot": "serpe", "art": ["serpe", 0], "strata": [3], "weight": 6, "glow": true},
	# la campanula errante fluttua alta e fa piovere polline che scotta
	"campanula_errante": {"name": "Campanula errante", "hp": 40, "damage": 10, "defense": 2, "knock": 0.2,
		"half": [7, 8], "speed": 55, "fly": true, "behaviors": ["vola", "bombarda"],
		"p": {"sight": 28, "hover": 80.0, "wobble": 20.0, "rate": 1.8, "shot_damage": 18, "shot_look": "polline"},
		"loot": "campanula", "art": ["campanula", 0], "strata": [3, 4], "weight": 5, "glow": true},
	# il guizzalinfa sparisce e ti ricompare accanto
	"guizzalinfa": {"name": "Guizzalinfa", "hp": 35, "damage": 15, "defense": 2, "knock": 0.2, "half": [5, 6],
		"speed": 80, "behaviors": ["cammina", "teletrasporto"], "p": {"sight": 28, "blink_every": 3.0},
		"loot": "guizzalinfa", "art": ["guizzalinfa", 0], "strata": [3, 4], "weight": 5, "glow": true},
	# il Fondo: il mietivuoto scatta rasoterra con le falci
	"mietivuoto": {"name": "Mietivuoto", "hp": 60, "damage": 22, "defense": 5, "knock": 0.5, "half": [6, 10],
		"speed": 75, "behaviors": ["cammina", "scatto"],
		"p": {"sight": 26, "dash_every": 3.0, "dash_speed": 340.0, "dash_time": 0.35},
		"loot": "mietivuoto", "art": ["mietivuoto", 0], "strata": [4], "weight": 5, "glow": true},
	"tessivuoto": {"name": "Tessivuoto", "hp": 55, "damage": 18, "defense": 5, "knock": 0.4, "half": [9, 6],
		"speed": 70, "behaviors": ["agguato", "cammina", "spara"],
		"p": {"sight": 22, "drop_x": 3, "rate": 2.6, "shot_speed": 220.0, "shot_grav": 150.0, "shot_damage": 8,
			"slow": 3.0, "shot_look": "ragnatela"},
		"loot": "tessivuoto", "art": ["tessivuoto", 0], "strata": [4], "weight": 4, "glow": true},
	"sciame_schegge": {"name": "Sciame di schegge", "hp": 12, "damage": 10, "defense": 2, "knock": 0.0, "half": [4, 4],
		"speed": 100, "fly": true, "behaviors": ["vola"], "p": {"sight": 28, "wobble": 50.0}, "group": [3, 5],
		"loot": "sciame", "art": ["sciame", 0], "strata": [4], "weight": 4, "glow": true},
	# --- voce 40: le creature dei biomi nuovi ---
	# Boschi di brina: il cervo carica a testa bassa; il gufo del gelo tira schegge fredde che rallentano
	"cervo_brina": {"name": "Cervo di brina", "hp": 64, "damage": 15, "defense": 3, "knock": 0.5, "half": [9, 8],
		"speed": 55, "behaviors": ["cammina", "carica"],
		"p": {"sight": 22, "charge": 250.0, "charge_range": 12, "charge_time": 1.0, "charge_cool": 3.2},
		"loot": "cervo_brina", "art": ["cervo_brina", 0], "strata": [0], "weight": 6, "biomes": ["brina"]},
	"gufo_gelo": {"name": "Gufo del gelo", "hp": 30, "damage": 10, "defense": 1, "knock": 0.1, "half": [7, 6],
		"speed": 80, "fly": true, "behaviors": ["vola", "spara"],
		"p": {"sight": 28, "hover": 70.0, "wobble": 20.0, "rate": 2.4, "shot_speed": 230.0, "shot_grav": 0.0,
			"shot_damage": 8, "slow": 1.5, "shot_look": "gelo"},
		"loot": "gufo_gelo", "art": ["gufo_gelo", 0], "strata": [0], "weight": 5, "glow": true, "biomes": ["brina"]},
	# Cenerarie: la salamandra salta addosso; i fatui di cenere arrivano a gruppetti e scattano
	"salamandra_brace": {"name": "Salamandra di brace", "hp": 46, "damage": 13, "defense": 2, "knock": 0.3,
		"half": [10, 4], "speed": 75, "behaviors": ["salta_verso"], "p": {"jump": 230.0, "sight": 20},
		"loot": "salamandra", "art": ["salamandra", 0], "strata": [0], "weight": 6, "glow": true, "biomes": ["cenere"]},
	# voce 56: le famiglie nuove (disegni in `FaunaArt`). Erbivori docili, colonie, volanti, predatori.
	"pecora_muschio": {"name": "Pecora di muschio", "hp": 30, "damage": 5, "defense": 1, "knock": 0.3, "half": [8, 6],
		"speed": 40, "behaviors": ["cammina"], "p": {"sight": 10}, "docile": true,
		"loot": "pecora_muschio", "art": ["pecora_muschio", 0], "strata": [0], "weight": 7, "biomes": ["foresta", "palude"]},
	"cornoradice": {"name": "Cornoradice", "hp": 70, "damage": 14, "defense": 3, "knock": 0.6, "half": [11, 8],
		"speed": 50, "behaviors": ["cammina", "carica"], "docile": true,
		"p": {"sight": 18, "charge": 240.0, "charge_range": 10, "charge_time": 0.9, "charge_cool": 3.5},
		"loot": "cornoradice", "art": ["cornoradice", 0], "strata": [0], "weight": 3, "biomes": ["foresta", "ambra"]},
	"lepre_linfa": {"name": "Lepre di Linfa", "hp": 12, "damage": 0, "defense": 0, "knock": 0.0, "half": [6, 6],
		"speed": 110, "behaviors": ["fugge"], "p": {"flee": 14},
		"loot": "lepre_linfa", "art": ["lepre_linfa", 0], "strata": [0], "weight": 6, "glow": true, "biomes": ["foresta", "brina", "ambra"]},
	"bruco_lanterna": {"name": "Bruco di lanterna", "hp": 16, "damage": 4, "defense": 1, "knock": 0.2, "half": [9, 4],
		"speed": 20, "behaviors": ["cammina"], "p": {"sight": 8}, "docile": true,
		"loot": "bruco_lanterna", "art": ["bruco_lanterna", 0], "strata": [0, 1], "weight": 5, "glow": true, "biomes": ["foresta"]},
	"ape_lume": {"name": "Ape di lume", "hp": 8, "damage": 5, "defense": 0, "knock": 0.0, "half": [5, 4],
		"speed": 90, "fly": true, "behaviors": ["vola"], "p": {"sight": 14, "wobble": 30.0}, "group": [3, 5],
		"loot": "ape_lume", "art": ["ape_lume", 0], "strata": [0], "weight": 4, "glow": true, "biomes": ["foresta", "palude", "ambra"]},
	"formica_resina": {"name": "Formica di resina", "hp": 7, "damage": 4, "defense": 1, "knock": 0.0, "half": [5, 3],
		"speed": 70, "behaviors": ["cammina"], "p": {"sight": 12}, "group": [4, 6],
		"loot": "formica_resina", "art": ["formica_resina", 0], "strata": [1, 2], "weight": 5},
	"pipistrello_corteccia": {"name": "Pipistrello di corteccia", "hp": 14, "damage": 7, "defense": 0, "knock": 0.0,
		"half": [7, 4], "speed": 100, "fly": true, "behaviors": ["vola"], "p": {"sight": 22, "wobble": 40.0},
		"loot": "pipistrello", "art": ["pipistrello", 0], "strata": [1, 2], "weight": 5},
	"libellula_brina": {"name": "Libellula di brina", "hp": 10, "damage": 6, "defense": 0, "knock": 0.0, "half": [8, 4],
		"speed": 120, "fly": true, "behaviors": ["vola"], "p": {"sight": 18, "wobble": 20.0},
		"loot": "libellula", "art": ["libellula_brina", 0], "strata": [0], "weight": 5, "glow": true, "biomes": ["brina", "palude"]},
	"volpe_ambra": {"name": "Volpe d'ambra", "hp": 36, "damage": 12, "defense": 1, "knock": 0.3, "half": [9, 6],
		"speed": 95, "behaviors": ["cammina", "carica"],
		"p": {"sight": 22, "charge": 270.0, "charge_range": 9, "charge_time": 0.6, "charge_cool": 2.6},
		"loot": "volpe", "art": ["volpe_ambra", 0], "strata": [0], "weight": 3, "biomes": ["ambra", "foresta"]},
	"lince_ardesia": {"name": "Lince d'ardesia", "hp": 50, "damage": 16, "defense": 3, "knock": 0.4, "half": [9, 7],
		"speed": 90, "behaviors": ["cammina", "carica"],
		"p": {"sight": 24, "charge": 290.0, "charge_range": 10, "charge_time": 0.7, "charge_cool": 2.8},
		"loot": "lince", "art": ["lince_ardesia", 0], "strata": [2, 3], "weight": 3, "glow": true},
	# voce 56: i Custodi dei biomi, nelle loro tane sotto la superficie (disegni ingranditi: `art_mods`)
	"grande_cervo": {"name": "Il Grande Cervo di brina", "hp": 700, "damage": 22, "defense": 5, "knock": 1.0, "half": [20, 18],
		"speed": 80, "behaviors": ["cammina", "carica", "evoca"],
		"p": {"sight": 40, "charge": 330.0, "charge_range": 18, "charge_time": 1.1, "charge_cool": 3.0, "summon_every": 7.0,
			"summon": "cervo_brina", "summon_max": 3, "phase2": 0.5},
		"loot": "grande_cervo", "art": ["cervo_brina", 0], "art_mods": {"scale": 2.2, "tint": Color("#d0f0ff"), "tint_amount": 0.3},
		"strata": [], "weight": 0, "glow": true, "boss": true},
	"madre_salamandre": {"name": "La Madre delle salamandre", "hp": 650, "damage": 20, "defense": 4, "knock": 1.0, "half": [22, 10],
		"speed": 90, "behaviors": ["salta_verso", "evoca"],
		"p": {"jump": 380.0, "sight": 40, "summon_every": 5.5, "summon": "salamandra_brace", "summon_max": 4, "phase2": 0.5},
		"loot": "madre_salamandre", "art": ["salamandra", 0], "art_mods": {"scale": 2.4, "tint": Color("#ff7a3a"), "tint_amount": 0.25},
		"strata": [], "weight": 0, "glow": true, "boss": true},
	"fatuo_cenere": {"name": "Fatuo di cenere", "hp": 20, "damage": 9, "defense": 0, "knock": 0.0, "half": [5, 6],
		"speed": 90, "fly": true, "behaviors": ["vola", "scatto"], "group": [2, 3],
		"p": {"sight": 26, "hover": 40.0, "wobble": 40.0, "dash_every": 3.2, "dash_speed": 250.0, "dash_time": 0.4},
		"loot": "fatuo_cenere", "art": ["fatuo_cenere", 0], "strata": [0], "weight": 5, "glow": true, "biomes": ["cenere"]},
	# --- voce 27: i Custodi degli strati (boss intermedi, nelle tane o richiamati all'Altare; vedi `KeepersData`) ---
	# la Madre dei grumi: salti enormi, e nella seconda fase chiama i suoi piccoli
	"madre_grumi": {"name": "La Madre dei grumi", "hp": 450, "damage": 14, "defense": 2, "knock": 1.0, "half": [22, 17],
		"speed": 95, "behaviors": ["salta_verso", "evoca"],
		"p": {"jump": 430.0, "sight": 40, "summon_every": 5.0, "summon": "grumo_muschio", "summon_max": 5, "phase2": 0.5},
		"loot": "madre_grumi", "art": ["madre_grumi", 0], "strata": [], "weight": 0, "glow": true, "boss": true},
	# la Tessitrice delle radici: cammina, carica e ricopre tutto di ragnatele; poi chiama i Tessiradice
	"tessitrice_radici": {"name": "La Tessitrice delle radici", "hp": 650, "damage": 18, "defense": 5, "knock": 1.0,
		"half": [26, 12], "speed": 75, "behaviors": ["cammina", "carica", "spara", "evoca"],
		"p": {"sight": 40, "charge": 260.0, "charge_range": 14, "charge_time": 0.9, "charge_cool": 4.0, "rate": 1.4,
			"shot_speed": 240.0, "shot_grav": 120.0, "shot_damage": 10, "slow": 3.0, "shot_look": "ragnatela",
			"summon_every": 7.0, "summon": "tessiradice", "summon_max": 3, "phase2": 0.5},
		"loot": "tessitrice", "art": ["tessitrice", 0], "strata": [], "weight": 0, "glow": true, "boss": true},
	# la Serpe madre: nuota nell'aria delle Profondità, scatta e scaglia ventagli di Linfa
	"serpe_madre": {"name": "La Serpe madre", "hp": 800, "damage": 22, "defense": 5, "knock": 1.0, "half": [30, 9],
		"speed": 125, "fly": true, "behaviors": ["vola", "scatto", "ventaglio", "evoca"],
		"p": {"sight": 45, "wobble": 50.0, "dash_every": 3.5, "dash_speed": 360.0, "dash_time": 0.5, "fan_rate": 2.4,
			"fan_n": 5, "fan_spread": 0.9, "shot_speed": 200.0, "shot_grav": 30.0, "shot_damage": 18,
			"summon_every": 9.0, "summon": "serpe_linfa", "summon_max": 2, "phase2": 0.5},
		"loot": "serpe_madre", "art": ["serpe_madre", 0], "strata": [], "weight": 0, "glow": true, "boss": true},
	# il Mietitore cavo: sparisce e ricompare, scatta con la falce, chiama sciami di schegge
	"mietitore_cavo": {"name": "Il Mietitore cavo", "hp": 850, "damage": 26, "defense": 9, "knock": 1.0, "half": [12, 21],
		"speed": 95, "behaviors": ["cammina", "scatto", "teletrasporto", "evoca"],
		"p": {"sight": 40, "dash_every": 2.8, "dash_speed": 380.0, "dash_time": 0.4, "blink_every": 4.0,
			"summon_every": 8.0, "summon": "sciame_schegge", "summon_max": 4, "phase2": 0.5},
		"loot": "mietitore", "art": ["mietitore", 0], "strata": [], "weight": 0, "glow": true, "boss": true},
}

static var _variants := {}


## I dati di una creatura: di una specie, o di una sua variante («specie~taglia~elemento~indole», voce 55, costruita
## da `FamiliesData.make` e messa da parte).
static func get_data(id: String) -> Dictionary:
	if CREATURES.has(id):
		return CREATURES[id]
	if not _variants.has(id):
		# voce 66: le creature delle stagioni nascono da una specie, con i loro colori e il loro bottino
		_variants[id] = SeasonsData.make(id) if SeasonsData.CREATURES.has(id) else FamiliesData.make(id)
	return _variants[id]


## La specie di una creatura (di una variante: la specie da cui nasce).
static func base_of(id: String) -> String:
	return id.get_slice("~", 0)


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
