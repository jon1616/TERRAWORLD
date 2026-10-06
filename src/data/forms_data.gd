class_name FormsData
extends RefCounted
## Le **forme** degli attrezzi, delle armi e delle armature (voce 49; nuove forme nella voce 50). Solo dati e le
## formule che, da una forma e un materiale (`MaterialsData`), fanno l'oggetto: nome, tipo, icona, valori, ricetta.
## L'id dell'oggetto è «forma_materiale» (`spada_radicite`, `corazza_ambra`…).
## Voce 50: nove forme nuove, ognuna con il suo modo di colpire (`AREA`: l'area del colpo in mischia), e le **fasce**
## (`FASCE`) che il Telaio avvolge sul manico di un'arma o di un attrezzo (nei "dati" della casella: `Gear`).
##
## Campi di una forma:
##   name, plural   nome («Gambali», al plurale)          kind   il tipo di oggetto (`ItemsData`)
##   bars, wood     lingotti e legno della ricetta (al Maglio); extra = altri materiali
##   icon           la forma dell'icona, se non ha lo stesso nome (il martello: «mazza»)
##   stats          come la forma pesa le proprietà del materiale (vedi `stats`)

const FORMS := {
	"piccone": {"name": "Piccone", "kind": "piccone", "bars": 12, "wood": 4},
	"ascia": {"name": "Ascia", "kind": "ascia", "bars": 9, "wood": 3},
	"spada": {"name": "Spada", "kind": "spada", "bars": 8, "wood": 0},
	"elmo": {"name": "Elmo", "kind": "elmo", "bars": 15, "wood": 0},
	"corazza": {"name": "Corazza", "kind": "corazza", "bars": 25, "wood": 0},
	"gambali": {"name": "Gambali", "kind": "gambali", "bars": 20, "wood": 0, "plural": true},
	"arco": {"name": "Arco", "kind": "arco", "bars": 10, "wood": 3},
	# voce 50
	"pugnale": {"name": "Pugnale", "kind": "spada", "bars": 5, "wood": 1, "desc": "corto e rapidissimo"},
	"spadone": {"name": "Spadone", "kind": "spada", "bars": 14, "wood": 0, "desc": "lento, largo e pesante"},
	"lancia": {"name": "Lancia", "kind": "spada", "bars": 8, "wood": 6, "desc": "colpisce lontano, in linea"},
	"martello": {"name": "Martello", "kind": "spada", "bars": 16, "wood": 4, "icon": "mazza", "desc": "il peso fa il danno; spinge lontanissimo"},
	"falcione": {"name": "Falce", "kind": "spada", "bars": 11, "wood": 4, "desc": "un giro largo: colpisce davanti e dietro"},
	"frusta": {"name": "Frusta", "kind": "spada", "bars": 5, "wood": 0, "extra": {"seta_radice": 4}, "desc": "lunghissima e svelta, ma spinge poco"},
	"balestra": {"name": "Balestra", "kind": "arco", "bars": 10, "wood": 5, "desc": "lenta, ma il dardo trafigge due creature"},
	"trivella": {"name": "Trivella", "kind": "piccone", "bars": 14, "wood": 2, "desc": "scava molto più in fretta"},
	"verga": {"name": "Verga", "kind": "bastone", "bars": 7, "wood": 3, "extra": {"cristallo_linfa": 2},
		"desc": "tira saette di Linfa: la conduzione del metallo fa il danno"},
	# voce 86: i posti nuovi dell'equipaggiamento
	"guanti": {"name": "Guanti", "kind": "guanti", "bars": 8, "wood": 0, "plural": true, "extra": {"seta_radice": 2},
		"desc": "colpi più rapidi e scavo più svelto, secondo il metallo"},
	"stivali": {"name": "Stivali", "kind": "stivali", "bars": 10, "wood": 0, "plural": true,
		"desc": "corsa e salto un po' più lunghi, secondo il metallo"},
	"mantello": {"name": "Mantello", "kind": "mantello", "bars": 4, "wood": 0, "extra": {"seta_radice": 6},
		"desc": "un mantello bordato di metallo: la Vita ricresce più in fretta"},
	# voce 121: la pesca (valori in `FishingData.rod_stats`)
	"canna": {"name": "Canna", "kind": "canna", "bars": 4, "wood": 6, "extra": {"seta_radice": 2},
		"desc": "pesca; il metallo decide la fortuna, l'attesa e i liquidi (acqua; Linfa e brace con i materiali giusti)"},
	# Roadmap 40, voce 368: le forme degli stili (`StylesData`), solo dei materiali puri (niente leghe: `PURE`)
	"falcelunga": {"name": "Falce lunga", "kind": "spada", "bars": 12, "wood": 5, "icon": "falcelunga",
		"desc": "un giro lunghissimo attorno a te: lenta, colpisce tutto ciò che hai vicino"},
	"manopole": {"name": "Manopole", "kind": "spada", "bars": 6, "wood": 0, "plural": true, "extra": {"seta_radice": 2},
		"icon": "manopole", "desc": "pugni velocissimi e corti: lo Slancio si carica in un attimo"},
	"egida": {"name": "Egida", "kind": "spada", "bars": 18, "wood": 2, "icon": "egida",
		"desc": "uno scudo che colpisce: in mano dà Scorza, e spinge lontano"},
	"bipenne": {"name": "Bipenne", "kind": "spada", "bars": 14, "wood": 4, "icon": "bipenne",
		"desc": "l'ascia da guerra: alta e pesantissima"},
	"randello": {"name": "Randello", "kind": "spada", "bars": 8, "wood": 6, "icon": "randello",
		"desc": "un bastone ferrato: un colpo su quattro stordisce"},
	"fionda": {"name": "Fionda", "kind": "arco", "bars": 4, "wood": 4, "extra": {"seta_radice": 2}, "icon": "fionda",
		"desc": "tira sassi, svelta e leggera"},
	"cerbottana": {"name": "Cerbottana", "kind": "arco", "bars": 5, "wood": 3, "icon": "cerbottana",
		"desc": "soffia spore velocissime che avvelenano"},
	"lanciaspore": {"name": "Lanciaspore", "kind": "arco", "bars": 10, "wood": 2, "extra": {"sacca_spore": 3}, "icon": "lanciaspore",
		"desc": "tre spore a ventaglio a ogni colpo"},
	"tomo": {"name": "Tomo", "kind": "bastone", "bars": 6, "wood": 0, "extra": {"seta_radice": 4, "cristallo_linfa": 1},
		"icon": "tomo", "desc": "tre pagine di Linfa che inseguono le creature"},
	"sfera": {"name": "Sfera", "kind": "bastone", "bars": 8, "wood": 0, "extra": {"cristallo_linfa": 4}, "icon": "sfera",
		"desc": "un globo lento e pesante che attraversa tutto"},
	"scettro": {"name": "Scettro del branco", "kind": "evocatore", "bars": 7, "wood": 3, "extra": {"cristallo_linfa": 2},
		"icon": "scettro", "desc": "richiama un alleato forte come il metallo dello scettro"},
	"dischi": {"name": "Dischi da lancio", "kind": "lancio", "bars": 6, "wood": 0, "plural": true, "icon": "dischi",
		"desc": "tre dischi a ogni lancio; stando fermi il lancio dopo è perfetto"},
	"girandola": {"name": "Girandola", "kind": "lancio", "bars": 6, "wood": 3, "icon": "girandola",
		"desc": "vola, attraversa e torna in mano colpendo di nuovo"},
	"buccina": {"name": "Buccina", "kind": "strumento", "bars": 8, "wood": 0, "icon": "buccina",
		"desc": "note che attraversano; piena l'Ispirazione, il Canto di guerra"},
	"flauto": {"name": "Flauto", "kind": "strumento", "bars": 5, "wood": 2, "icon": "flauto",
		"desc": "note svelte che inseguono; piena l'Ispirazione, il Canto del ristoro"},
	"tamburo": {"name": "Tamburo", "kind": "strumento", "bars": 6, "wood": 4, "extra": {"membrana_ardesia": 2}, "icon": "tamburo",
		"desc": "colpi che rimbombano tutto attorno; piena l'Ispirazione, il Canto della scorza"},
	"virgulto": {"name": "Virgulto", "kind": "ramo", "bars": 3, "wood": 6, "extra": {"gelatina": 2}, "icon": "virgulto",
		"desc": "semi di Rugiada: ferire ti cura, e la Rugiada cura anche i compagni"},
	"semetorre": {"name": "Seme-torre", "kind": "semeguerra", "bars": 4, "wood": 4, "extra": {"humus": 4}, "icon": "semetorre",
		"desc": "piantato sul campo cresce e tira spine da solo per 12 secondi"},
	"semebomba": {"name": "Seme-bomba", "kind": "semeguerra", "bars": 5, "wood": 2, "extra": {"gelatina": 3}, "icon": "semebomba",
		"desc": "lanciato ad arco, scoppia e ferisce tutto attorno"},
	# Roadmap 44, voce 389: gli elmi degli stili (`ArmorData.HELMS`): meno Scorza, più danno del loro stile
	"celata": {"name": "Celata", "kind": "elmo", "bars": 15, "wood": 0, "icon": "celata",
		"desc": "chiusa e pesante: la mischia ferisce di più"},
	"cappuccio_mira": {"name": "Cappuccio da tiro", "kind": "elmo", "bars": 8, "wood": 0, "extra": {"seta_radice": 3},
		"icon": "cappuccio_mira", "desc": "tiene la vista sul bersaglio: archi, fionde e cerbottane feriscono di più"},
	"tiara": {"name": "Diadema", "kind": "elmo", "bars": 10, "wood": 0, "extra": {"cristallo_linfa": 2}, "icon": "tiara",
		"desc": "una corona sottile che porta la Linfa: gli incantesimi feriscono di più"},
	"maschera": {"name": "Maschera del branco", "kind": "elmo", "bars": 12, "wood": 0, "extra": {"seta_radice": 2},
		"icon": "maschera", "desc": "il volto di una bestia: gli alleati degli scettri feriscono di più"},
	"benda": {"name": "Benda del lanciatore", "kind": "elmo", "bars": 6, "wood": 0, "extra": {"seta_radice": 4}, "icon": "benda",
		"desc": "lascia libero lo sguardo: dischi e girandole feriscono di più"},
	"ghirlanda": {"name": "Ghirlanda", "kind": "elmo", "bars": 10, "wood": 0, "extra": {"seta_radice": 2}, "icon": "ghirlanda",
		"desc": "foglie di metallo che vibrano: le note feriscono di più"},
	"velo": {"name": "Velo di rugiada", "kind": "elmo", "bars": 8, "wood": 0, "extra": {"gelatina": 2}, "icon": "velo",
		"desc": "trattiene la Rugiada: i virgulti feriscono (e curano) di più"},
	"cappello_radice": {"name": "Cappello di radice", "kind": "elmo", "bars": 10, "wood": 3, "extra": {"humus": 4},
		"icon": "cappello_radice", "desc": "fa germogliare i semi: semi-torre e semi-bomba feriscono di più"},
}

## Voce 368: le forme degli stili si fanno solo con i materiali puri (metalli, metalli del Risveglio, materiali dei geni):
## con le 36 leghe sarebbero 684 oggetti in più senza nulla di nuovo da fare.
const PURE := ["falcelunga", "manopole", "egida", "bipenne", "randello", "fionda", "cerbottana", "lanciaspore", "tomo",
	"sfera", "scettro", "dischi", "girandola", "buccina", "flauto", "tamburo", "virgulto", "semetorre", "semebomba",
	"celata", "cappuccio_mira", "tiara", "maschera", "benda", "ghirlanda", "velo", "cappello_radice"]

## Voce 368: gli effetti propri di alcune forme (righe di `EffectsData`), che valgono tenendola in mano.
const FORM_FX := {"randello": ["forma_randello"], "cerbottana": ["forma_cerbottana"], "manopole": ["forma_manopole"],
	"bipenne": ["forma_bipenne"]}
## Voce 368: la munizione di ogni forma che tira (le altre: i dardi).
const AMMO_OF := {"fionda": "sasso", "cerbottana": "spora", "lanciaspore": "spora"}


## Questa forma si fa con questo materiale?
static func makes(form: String, mat: String) -> bool:
	return not (form in PURE and MaterialsData.get_mat(mat).has("alloy"))

## L'area del colpo in mischia: [larghezza, altezza, spostamento in avanti, anche dietro?]. Le forme non elencate
## usano l'area di sempre (`Combat.MELEE_REACH`).
const AREA := {
	"pugnale": [22, 30, 4, false], "spadone": [40, 44, 10, false], "lancia": [60, 22, 26, false],
	"martello": [30, 46, 6, false], "falcione": [64, 38, 0, true], "frusta": [76, 20, 34, false],
	# voce 368
	"falcelunga": [92, 40, 0, true], "manopole": [18, 26, 4, false], "egida": [26, 40, 4, false],
	"bipenne": [36, 54, 6, false], "randello": [34, 34, 6, false],
}

## Le fasce del Telaio: il materiale che si avvolge (quanti) e cosa cambia (moltiplicatori come i tratti).
const FASCE := {
	"seta": {"name": "seta", "item": "seta_radice", "n": 3, "speed": 1.08, "desc": "+8% velocità del colpo"},
	"membrana": {"name": "membrana", "item": "membrana_ardesia", "n": 2, "knock": 1.3, "desc": "+30% spinta"},
	"scaglie": {"name": "scaglie di serpe", "item": "scaglia_linfa", "n": 2, "damage": 1.06, "desc": "+6% danno"},
	"penne": {"name": "penne", "item": "penna_corteccia", "n": 3, "speed": 1.04, "damage": 1.03, "desc": "+4% velocità, +3% danno"},
	"regale": {"name": "gelatina regale", "item": "gelatina_regale", "n": 1, "speed": 1.05, "damage": 1.08,
		"desc": "+5% velocità, +8% danno"},
}
## Le forme che prendono una fascia (armi e attrezzi con il manico).
const WRAPPABLE := ["piccone", "ascia", "spada", "pugnale", "spadone", "lancia", "martello", "falcione", "frusta", "trivella",
	"verga", "arco", "balestra"]

## Le forme che c'erano prima della voce 50 (i loro oggetti di metallo contano nell'Erbario).
const BASE := ["piccone", "ascia", "spada", "elmo", "corazza", "gambali", "arco"]

## Voce 306: quale parte del carattere del materiale (`MaterialsData.SHARE`) prende ogni forma: le armature e gli
## accessori quando si indossano (nel loro `acc`), le armi e gli attrezzi quando si tengono in mano (nel loro `mano`).
const TRAIT_PART := {"elmo": "armatura", "corazza": "armatura", "gambali": "armatura", "guanti": "accessorio",
	"stivali": "accessorio", "mantello": "accessorio", "celata": "armatura", "cappuccio_mira": "armatura",
	"tiara": "armatura", "maschera": "armatura", "benda": "armatura", "ghirlanda": "armatura", "velo": "armatura",
	"cappello_radice": "armatura"}

## La Scorza di un pezzo d'armatura = tenacia del materiale × questo.
const ARMOR := {"elmo": 1.0, "corazza": 1.6, "gambali": 1.0}
## Velocità dei colpi di una spada = SPEED_BASE − SPEED_PESO × peso (più pesante = più lenta).
const SPEED_BASE := 3.0
const SPEED_PESO := 0.04
const BAR_STEP := 0.1                  # voce 99: lingotti in più per grado del materiale


static func item_id(form: String, mat: String) -> String:
	return "%s_%s" % [form, mat]


## I valori di una forma fatta di un materiale.
static func stats(form: String, mat: String) -> Dictionary:
	return stats_md(form, MaterialsData.get_mat(mat))


## Voce 370: il metallo «virtuale» di una fase della spina, per le armi firma (`firma_stats`): il filo della curva
## (`SpineData`) un po' sopra quello del metallo della fase (le armi firma si trovano, non si fabbricano), e le altre
## proprietà dal metallo della fase.
const FIRMA_BONUS := 1.15
const PHASE_METALS := ["radicite", "legnoferro", "ambra", "linfa", "vuoto", "stellare", "corallite", "sanguinite",
	"cuorelegno", "eterite", "astrite", "primambra"]


static func virtual_mat(phase: int) -> Dictionary:
	var t := clampi((phase + 1) / 2, 1, 12)
	var md := MaterialsData.get_mat(String(PHASE_METALS[t - 1])).duplicate()
	md["filo"] = 9.0 * pow(1.16, maxi(phase, 1) - 1) * FIRMA_BONUS
	md["conduzione"] = float(md["conduzione"]) * FIRMA_BONUS
	return md


## I valori di un'arma firma: la sua forma fatta del metallo virtuale della sua fase.
static func firma_stats(form: String, phase: int) -> Dictionary:
	return stats_md(form, virtual_mat(phase))


static func stats_md(form: String, md: Dictionary) -> Dictionary:
	var filo := float(md["filo"])
	var peso := float(md["peso"])
	var out := {}
	match form:
		"piccone", "ascia":
			out["power"] = int(md["durezza"])
			out["damage"] = int(filo * 0.6)
			out["speed"] = 2.6
		"spada":
			out["damage"] = roundi(filo)
			out["speed"] = snappedf(SPEED_BASE - SPEED_PESO * peso, 0.01)
			out["knockback"] = 4.0
		"elmo", "corazza", "gambali":
			out["defense"] = roundi(float(md["tenacia"]) * float(ARMOR[form]))
		"celata", "cappuccio_mira", "tiara", "maschera", "benda", "ghirlanda", "velo", "cappello_radice":
			# Roadmap 44, voce 389: l'elmo di uno stile
			out["defense"] = maxi(roundi(float(md["tenacia"]) * ArmorData.HELM_DEF), 1)
			out["acc"] = {"st_" + String(ArmorData.HELMS[form][0]): ArmorData.helm_bonus(int(md["tier"]))}
		"arco":
			out["damage"] = int(filo * 0.55)
			out["speed"] = snappedf(1.6 + 0.15 * float(md["tier"]), 0.01)
			out["knockback"] = 1.2
		"pugnale":
			out["damage"] = roundi(filo * 0.65)          # voce 185: era 0,7, batteva la spada in tutto dal grado 3
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 1.55, 0.01)
			out["knockback"] = 1.5
		"spadone":
			out["damage"] = roundi(filo * 1.45 + peso * 0.2)
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 0.62, 0.01)
			out["knockback"] = 6.0
		"lancia":
			out["damage"] = roundi(filo * 1.1)
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 0.85, 0.01)
			out["knockback"] = 2.5
		"martello":
			out["damage"] = roundi(filo * 1.2 + peso * 0.4)   # voce 185: era filo 0,8 + peso 0,6: con i metalli leggeri crollava
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 0.55, 0.01)
			out["knockback"] = 9.0
		"falcione":
			out["damage"] = roundi(filo * 1.1)
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 0.75, 0.01)
			out["knockback"] = 3.0
		"frusta":
			out["damage"] = roundi(filo * 0.75)
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 1.1, 0.01)
			out["knockback"] = 0.5
		"balestra":
			out["damage"] = roundi(filo * 0.85)
			out["speed"] = snappedf((1.6 + 0.15 * float(md["tier"])) * 0.55, 0.01)
			out["knockback"] = 2.5
			out["pierce"] = 2
		"trivella":
			out["power"] = int(md["durezza"]) + 5
			out["damage"] = int(filo * 0.4)
			out["speed"] = 2.6
			out["dig"] = 1.6
		"guanti":
			out["defense"] = roundi(float(md["tenacia"]) * 0.5)
			out["acc"] = {"atk_speed": snappedf(1.0 + 0.02 * float(md["tier"]), 0.001),
				"dig": snappedf(1.0 + 0.04 * float(md["tier"]), 0.001)}
		"stivali":
			out["defense"] = roundi(float(md["tenacia"]) * 0.6)
			out["acc"] = {"run": snappedf(1.0 + 0.02 * float(md["tier"]), 0.001),
				"jump": snappedf(1.0 + 0.015 * float(md["tier"]), 0.001)}
		"mantello":
			out["defense"] = roundi(float(md["tenacia"]) * 0.4)
			out["acc"] = {"regen": snappedf(1.0 + 0.04 * float(md["tier"]), 0.001)}
		"canna":
			out.merge(FishingData.rod_stats(md))
		# Roadmap 40, voce 368: le forme degli stili (le formule tenute alla pari con `tools/armi.gd`)
		"falcelunga":
			out["damage"] = roundi(filo * 1.25)
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 0.6, 0.01)
			out["knockback"] = 4.0
		"manopole":
			out["damage"] = roundi(filo * 0.42)
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 2.1, 0.01)
			out["knockback"] = 0.8
		"egida":
			out["damage"] = roundi(filo * 0.75)
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 0.8, 0.01)
			out["knockback"] = 8.0
			out["guard"] = roundi(float(md["tenacia"]) * 1.6)
		"bipenne":
			out["damage"] = roundi(filo * 1.35 + peso * 0.2)
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 0.6, 0.01)
			out["knockback"] = 5.0
		"randello":
			out["damage"] = roundi(filo * 0.95)
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 0.95, 0.01)
			out["knockback"] = 6.0
		"fionda":
			out["damage"] = roundi(filo * 0.42)
			out["speed"] = snappedf((1.6 + 0.15 * float(md["tier"])) * 1.5, 0.01)
			out["knockback"] = 1.0
		"cerbottana":
			out["damage"] = roundi(filo * 0.26)
			out["speed"] = snappedf((1.6 + 0.15 * float(md["tier"])) * 1.9, 0.01)
			out["knockback"] = 0.3
		"lanciaspore":
			out["damage"] = roundi(filo * 0.3)
			out["speed"] = snappedf((1.6 + 0.15 * float(md["tier"])) * 0.8, 0.01)
			out["knockback"] = 0.6
			out["multishot"] = 3
		"tomo":
			out["damage"] = roundi((filo * 0.75 + float(md["conduzione"]) * 0.6) * 0.6)
			out["speed"] = 1.8
			out["knockback"] = 0.5
			out["spell"] = "pagine"
			out["linfa"] = 3 + int(md["tier"]) / 2
		"sfera":
			out["damage"] = roundi((filo * 0.75 + float(md["conduzione"]) * 0.6) * 2.4)
			out["speed"] = 0.9
			out["knockback"] = 3.0
			out["spell"] = "globo"
			out["linfa"] = 4 + int(md["tier"])
		"scettro":
			# l'alleato del grado del metallo, e la sua forza: il filo del metallo contro il danno dell'alleato
			var ally := "grumo_amico" if int(md["tier"]) <= 3 else ("falena_amica" if int(md["tier"]) <= 7 else "vagavuoto_amico")
			out["ally"] = ally
			out["ally_power"] = snappedf(filo * 0.7 / float({"grumo_amico": 10, "falena_amica": 16, "vagavuoto_amico": 22}[ally]), 0.01)
			out["damage"] = 1
		"dischi":
			out["damage"] = roundi(filo * 0.5)
			out["speed"] = 2.0
			out["knockback"] = 1.0
		"girandola":
			out["damage"] = roundi(filo * 1.2)
			out["speed"] = 1.0
			out["knockback"] = 2.0
		"buccina":
			out["damage"] = roundi(filo * 1.0)
			out["speed"] = 1.4
			out["knockback"] = 1.5
		"flauto":
			out["damage"] = roundi(filo * 0.7)
			out["speed"] = 2.2
			out["knockback"] = 0.5
		"tamburo":
			out["damage"] = roundi(filo * 1.2)
			out["speed"] = 1.0
			out["knockback"] = 4.0
		"virgulto":
			out["damage"] = roundi(filo * 0.8)
			out["speed"] = 1.8
			out["knockback"] = 1.0
		"semetorre":
			out["damage"] = roundi(filo * 0.45)
			out["speed"] = 0.8
			out["knockback"] = 1.0
		"semebomba":
			out["damage"] = roundi(filo * 1.8)
			out["speed"] = 0.9
			out["knockback"] = 4.0
		"verga":
			# Roadmap 39, voce 365: il filo fa il grosso del danno (con la sola conduzione la verga di primambra faceva 54
			# contro i 236 della spada); la conduzione resta il pregio dei metalli che la portano bene
			out["damage"] = roundi(filo * 0.75 + float(md["conduzione"]) * 0.6)
			out["speed"] = 2.2
			out["knockback"] = 1.0
			out["spell"] = "saetta"
			out["linfa"] = 2 + int(md["tier"]) / 2
	return out


## L'oggetto di una forma e un materiale, come le voci di `ItemsData.ITEMS`.
static func item(form: String, mat: String) -> Dictionary:
	var fd: Dictionary = FORMS[form]
	var md := MaterialsData.get_mat(mat)
	var label := String(md.get("label_pl", md["label"])) if fd.get("plural", false) else String(md["label"])
	var it := {"name": "%s %s" % [fd["name"], label], "kind": fd["kind"], "icon": [String(fd.get("icon", form)), MaterialsData.icon_of(mat)],
		"tier": md["tier"], "form": form, "mat": mat}
	if fd.has("desc"):
		it["desc"] = "%s %s: %s." % [fd["name"], label, fd["desc"]]
	if not form in BASE or md.has("alloy") or md.has("gene") or md.has("spina"):
		it["gen"] = true                     # l'Erbario non li conta (sono centinaia): vedi `Erbario.entries`
	it.merge(stats(form, mat))
	# voce 368: lo scudo in mano dà Scorza; gli effetti propri della forma; la munizione
	if it.has("guard"):
		it["mano_guard"] = {"defense": int(it["guard"])}
	if FORM_FX.has(form):
		it["effects"] = (FORM_FX[form] as Array).duplicate()
	if AMMO_OF.has(form):
		it["ammo"] = AMMO_OF[form]
	# voce 306: il carattere del materiale, indossato o in mano
	if TRAIT_PART.has(form):
		it["acc"] = MaterialsData.merge_acc(it.get("acc", {}), MaterialsData.trait_acc(mat, float(MaterialsData.SHARE[TRAIT_PART[form]])))
	elif not MaterialsData.trait_of(mat).is_empty():
		it["mano"] = MaterialsData.trait_acc(mat, float(MaterialsData.SHARE["mano"]))
	if it.has("mano_guard"):
		it["mano"] = MaterialsData.merge_acc(it.get("mano", {}), it["mano_guard"])
		it.erase("mano_guard")
	return it


## La ricetta di una forma e un materiale (al Maglio).
static func recipe(form: String, mat: String) -> Dictionary:
	var fd: Dictionary = FORMS[form]
	# voce 99: ogni grado del materiale chiede il 10% di lingotti in più (prima costavano uguale a ogni grado)
	var tier := int(MaterialsData.get_mat(mat).get("tier", 1))
	var needs := {String(MaterialsData.get_mat(mat)["bar"]): ceili(int(fd["bars"]) * (1.0 + BAR_STEP * (tier - 1)))}
	if int(fd["wood"]) > 0:
		needs["legno"] = int(fd["wood"])
	for k in fd.get("extra", {}):
		needs[k] = int(fd["extra"][k])
	return {"out": item_id(form, mat), "qty": 1, "in": needs, "station": "maglio"}
