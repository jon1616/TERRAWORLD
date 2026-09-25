class_name TraitsData
extends RefCounted
## I tratti dell'equipaggiamento (voce 15): ogni arma, attrezzo, armatura o accessorio nasce con un tratto a caso (o
## nessuno), che ne cambia un poco i valori. Si rinnovano al Maglio dei Seminatori. Solo dati e due piccole funzioni.
## I nomi sono sostantivi dell'universo (genere neutro nel nome dell'oggetto: «Spada di radice [Spina]»).
##
## Campi: name, desc, for (categorie: arma · attrezzo · armatura · accessorio), weight (quanto spesso),
## e gli effetti come moltiplicatori o somme:
##   damage, speed, knock, dig  moltiplicano danno, velocità del colpo, spinta, velocità di scavo e di abbattimento
##   scorza                     Scorza in più (somma)
##   run, halo                  moltiplicano corsa e alone (come gli accessori, vedi `GearEffects`)

const TRAITS := {
	# armi e attrezzi
	"spina": {"name": "Spina", "desc": "+15% danno", "for": ["arma", "attrezzo"], "weight": 10, "damage": 1.15},
	"vento": {"name": "Vento", "desc": "+12% velocità del colpo", "for": ["arma", "attrezzo"], "weight": 10, "speed": 1.12},
	"radice_profonda": {"name": "Radice profonda", "desc": "+40% spinta", "for": ["arma"], "weight": 8, "knock": 1.4},
	"linfa_viva": {"name": "Linfa viva", "desc": "+10% danno, +10% velocità", "for": ["arma", "attrezzo"], "weight": 3,
		"damage": 1.1, "speed": 1.1},
	"tenacia": {"name": "Tenacia", "desc": "+25% velocità di scavo e di taglio", "for": ["attrezzo"], "weight": 10, "dig": 1.25},
	"seccume": {"name": "Seccume", "desc": "−15% danno", "for": ["arma", "attrezzo"], "weight": 6, "damage": 0.85},
	"crepa": {"name": "Crepa", "desc": "−10% velocità del colpo", "for": ["arma", "attrezzo"], "weight": 6, "speed": 0.9},
	# armature
	"corteccia": {"name": "Corteccia", "desc": "+1 Scorza", "for": ["armatura"], "weight": 10, "scorza": 1},
	"muschio_fitto": {"name": "Muschio fitto", "desc": "+2 Scorza", "for": ["armatura"], "weight": 4, "scorza": 2},
	"piuma": {"name": "Piuma", "desc": "+5% corsa", "for": ["armatura"], "weight": 8, "run": 1.05},
	"tarlo": {"name": "Tarlo", "desc": "−1 Scorza", "for": ["armatura"], "weight": 5, "scorza": -1},
	# accessori
	"fiore": {"name": "Fiore", "desc": "+1 Scorza", "for": ["accessorio"], "weight": 10, "scorza": 1},
	"brezza": {"name": "Brezza", "desc": "+4% corsa", "for": ["accessorio"], "weight": 10, "run": 1.04},
	"lucciola": {"name": "Lucciola", "desc": "+15% alone", "for": ["accessorio"], "weight": 8, "halo": 1.15},
	# tratti che non escono mai a caso: si innestano al Maglio con le Essenze delle creature antiche (voce 20b)
	"furia": {"name": "Furia", "desc": "+25% danno", "for": ["arma", "attrezzo"], "weight": 0, "essence": true, "damage": 1.25},
	"guscio": {"name": "Guscio", "desc": "+3 Scorza", "for": ["armatura", "accessorio"], "weight": 0, "essence": true, "scorza": 3},
	"fulmine": {"name": "Fulmine", "desc": "+22% velocità del colpo", "for": ["arma", "attrezzo"], "weight": 0, "essence": true, "speed": 1.22},
	"vastita": {"name": "Vastità", "desc": "+60% spinta, +10% danno", "for": ["arma"], "weight": 0, "essence": true,
		"knock": 1.6, "damage": 1.1},
	"veleno": {"name": "Veleno", "desc": "i colpi avvelenano le creature", "for": ["arma"], "weight": 0, "essence": true, "poison": 1.0},
	"spine": {"name": "Spine", "desc": "chi ti tocca si ferisce (8 per colpo)", "for": ["armatura"], "weight": 0, "essence": true, "thorns": 8},
	"linfa_lenta": {"name": "Linfa lenta", "desc": "la Vita ricresce il 40% più in fretta", "for": ["armatura", "accessorio"],
		"weight": 0, "essence": true, "regen": 1.4},
	"fortuna": {"name": "Fortuna", "desc": "le creature lasciano più bottino", "for": ["accessorio", "armatura"], "weight": 0,
		"essence": true, "luck": 1.0},
	"lucciola_viva": {"name": "Lucciola viva", "desc": "+40% alone", "for": ["accessorio", "armatura"], "weight": 0,
		"essence": true, "halo": 1.4},
	"scoppio": {"name": "Scoppio", "desc": "le creature abbattute scoppiano e feriscono quelle vicine", "for": ["arma"],
		"weight": 0, "essence": true, "burst": 0.5},
	"ombra": {"name": "Ombra", "desc": "le creature ti notano più tardi", "for": ["armatura", "accessorio"], "weight": 0,
		"essence": true, "stealth": 0.7},
}

## Peso del «nessun tratto» in ogni tiro.
const NONE_WEIGHT := 18
## Rinnovare il tratto al Maglio costa questo.
const REFORGE_COST := {"polvere_brace": 3}


## La categoria di un oggetto per i tratti ("" = niente tratti: materiali, blocchi, consumabili…).
static func category_of(id: String) -> String:
	match String(ItemsData.get_item(id).get("kind", "")):
		"spada", "arco", "bastone":
			return "arma"
		"piccone", "ascia":
			return "attrezzo"
		"elmo", "corazza", "gambali":
			return "armatura"
		"accessorio":
			return "accessorio"
	return ""


## Un tratto a caso per un oggetto ("" = nessuno). `avoid`: un tratto da non ripetere (rinnovo al Maglio).
static func roll(id: String, rng: RandomNumberGenerator = null, avoid := "") -> String:
	var cat := category_of(id)
	if cat == "":
		return ""
	var pool := [["", NONE_WEIGHT]]
	for t in TRAITS:
		if cat in TRAITS[t]["for"] and t != avoid and int(TRAITS[t]["weight"]) > 0:
			pool.append([t, int(TRAITS[t]["weight"])])
	if avoid != "":
		pool.remove_at(0)                      # rinnovando si vuole sempre un tratto
	var tot := 0
	for e in pool:
		tot += int(e[1])
	var v := (rng.randi_range(1, tot) if rng else randi_range(1, tot))
	for e in pool:
		v -= int(e[1])
		if v <= 0:
			return String(e[0])
	return ""


## Moltiplicatore (o somma, per «scorza», «thorns», «poison», «luck», «burst») di un effetto per un tratto.
static func effect(tratto: String, key: String) -> float:
	var t: Dictionary = TRAITS.get(tratto, {})
	return float(t.get(key, 0.0 if key in ADDITIVE else 1.0))


## Gli effetti che si sommano (partono da zero) invece di moltiplicare.
const ADDITIVE := ["scorza", "thorns", "poison", "luck", "burst"]


## Si può innestare questa essenza su questo oggetto? (il tratto che dà deve valere per la sua categoria)
static func can_graft(essence: String, id: String) -> bool:
	var tr := String(ItemsData.get_item(essence).get("graft", ""))
	return tr != "" and TRAITS.has(tr) and category_of(id) in TRAITS[tr]["for"]


## «Spada di radice [Spina]»
static func full_name(id: String, tratto: String) -> String:
	var n := String(ItemsData.get_item(id).get("name", id))
	return n if tratto == "" else "%s [%s]" % [n, TRAITS[tratto]["name"]]


## Suggerimento di una casella: nome, e il tratto con il suo effetto.
static func tooltip(id: String, tratto: String) -> String:
	if tratto == "":
		return String(ItemsData.get_item(id).get("name", ""))
	return "%s\nTratto %s: %s" % [ItemsData.get_item(id).get("name", id), TRAITS[tratto]["name"], TRAITS[tratto]["desc"]]
