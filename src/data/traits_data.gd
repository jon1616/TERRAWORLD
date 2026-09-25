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
}

## Peso del «nessun tratto» in ogni tiro.
const NONE_WEIGHT := 18
## Rinnovare il tratto al Maglio costa questo.
const REFORGE_COST := {"polvere_brace": 3}


## La categoria di un oggetto per i tratti ("" = niente tratti: materiali, blocchi, consumabili…).
static func category_of(id: String) -> String:
	match String(ItemsData.get_item(id).get("kind", "")):
		"spada", "arco":
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
		if cat in TRAITS[t]["for"] and t != avoid:
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


## Moltiplicatore (o somma, per «scorza») di un effetto per un tratto.
static func effect(tratto: String, key: String) -> float:
	var t: Dictionary = TRAITS.get(tratto, {})
	return float(t.get(key, 0.0 if key == "scorza" else 1.0))


## «Spada di radice [Spina]»
static func full_name(id: String, tratto: String) -> String:
	var n := String(ItemsData.get_item(id).get("name", id))
	return n if tratto == "" else "%s [%s]" % [n, TRAITS[tratto]["name"]]


## Suggerimento di una casella: nome, e il tratto con il suo effetto.
static func tooltip(id: String, tratto: String) -> String:
	if tratto == "":
		return String(ItemsData.get_item(id).get("name", ""))
	return "%s\nTratto %s: %s" % [ItemsData.get_item(id).get("name", id), TRAITS[tratto]["name"], TRAITS[tratto]["desc"]]
