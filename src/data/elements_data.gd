class_name ElementsData
extends RefCounted
## Gli elementi (voce 51): li portano i materiali (`MaterialsData.elemento`), gli incantesimi (`SpellsData.elem`) e,
## dalla voce 54, gli innesti. Solo dati; li applica `Elements`.
## Ogni colpo con un elemento lascia sulla creatura il suo **stato** e il suo **segno** per qualche secondo; un colpo
## di un altro elemento su una creatura segnata fa una **reazione**. Ogni creatura ha debolezze (danno ×`WEAK`) e
## resistenze (×`RESIST`), che l'Erbario ricorda quando le scopri.

const WEAK := 1.6
const RESIST := 0.5
const MARK_TIME := 3.0                 # secondi in cui il segno di un elemento aspetta una reazione

## Lo stato che ogni elemento lascia:
##   brucia      perde Vita per `time` secondi (una parte del colpo ogni secondo, `dps`)
##   rallenta    metà velocità per `time` secondi
##   avvelena    perde Vita per `time` secondi (come il tratto Veleno)
##   prosciuga   il Germogliato si cura di una parte del danno (`heal`)
##   vulnerabile per `time` secondi ogni colpo fa il 30% in più
##   acceca      si ferma, stordita, per `time` secondi (i Guardiani no)
const ELEMENTS := {
	"brace": {"name": "Brace", "color": "#ff8a4a", "status": "brucia", "time": 3.0, "dps": 0.15, "desc": "brucia: perde Vita per 3 secondi"},
	"gelo": {"name": "Gelo", "color": "#8ad8ff", "status": "rallenta", "time": 2.5, "desc": "rallenta per 2,5 secondi"},
	"spora": {"name": "Spora", "color": "#b88af0", "status": "avvelena", "time": 4.0, "desc": "avvelena per 4 secondi"},
	"linfa": {"name": "Linfa", "color": "#5cf0d8", "status": "prosciuga", "heal": 0.1, "desc": "ti cura di un decimo del danno"},
	"vuoto": {"name": "Vuoto", "color": "#b070ff", "status": "vulnerabile", "time": 4.0, "desc": "per 4 secondi ogni colpo fa il 30% in più"},
	"luce": {"name": "Luce", "color": "#fff08a", "status": "acceca", "time": 0.7, "desc": "acceca e ferma per un attimo"},
}
const VULNERABLE := 1.3

## Le reazioni: [elementi], nome, e cosa fa: mult (danno del colpo ×), stun (secondi fermi; i Guardiani un terzo),
## chill, area (danno a chi sta attorno, in frazione del colpo, entro `radius` px).
const REACTIONS := [
	{"pair": ["gelo", "brace"], "name": "Vapore", "color": "#e8f4ff", "mult": 1.5, "stun": 1.5, "desc": "stordisce e fa metà danno in più"},
	{"pair": ["spora", "brace"], "name": "Fiammata", "color": "#ffb04a", "mult": 1.0, "area": 0.6, "radius": 56.0,
		"desc": "le spore prendono fuoco e feriscono chi sta attorno"},
	{"pair": ["gelo", "linfa"], "name": "Cristallo", "color": "#9af8f0", "mult": 1.0, "stun": 2.5, "chill": 3.0,
		"desc": "la Linfa gela: ferma a lungo"},
	{"pair": ["vuoto", "luce"], "name": "Squarcio", "color": "#f0d8ff", "mult": 2.5, "desc": "un colpo che fa due volte e mezzo il danno"},
]

## Debolezze e resistenze delle creature (tutte ne hanno almeno una debolezza: l'elemento giusto conta sempre).
const _AFFINITY := {
	"pesce_lume": {"weak": ["luce"], "resist": ["gelo"]}, "anguilla_linfa": {"weak": ["gelo"], "resist": ["linfa"]},
	"grumo_muschio": {"weak": ["brace"], "resist": ["spora"]}, "grumo_resina": {"weak": ["gelo"], "resist": ["brace"]},
	"grumo_spore": {"weak": ["brace"], "resist": ["spora"]}, "falena_brace": {"weak": ["gelo"], "resist": ["brace"]},
	"strisciaradice": {"weak": ["brace"], "resist": []}, "scarabeo_ardesia": {"weak": ["vuoto"], "resist": ["gelo"]},
	"sputaspore": {"weak": ["brace"], "resist": ["spora"]}, "guardiano_nodo": {"weak": ["luce"], "resist": ["spora"]},
	"regina_spore": {"weak": ["brace"], "resist": ["spora"]}, "colosso_ardesia": {"weak": ["vuoto"], "resist": ["gelo"]},
	"avvizzitore": {"weak": ["luce", "linfa"], "resist": ["vuoto", "spora"]},
	"avvizzito_errante": {"weak": ["luce"], "resist": ["vuoto"]}, "vagavuoto": {"weak": ["luce"], "resist": ["vuoto"]},
	"corvo_corteccia": {"weak": ["gelo"], "resist": []}, "spinoriccio": {"weak": ["brace"], "resist": []},
	"lucciola_vorace": {"weak": ["vuoto"], "resist": ["luce"]}, "tessiradice": {"weak": ["brace"], "resist": ["spora"]},
	"talpone": {"weak": ["gelo"], "resist": []}, "saltafungo": {"weak": ["brace"], "resist": ["spora"]},
	"ala_ardesia": {"weak": ["vuoto"], "resist": []}, "chiocciola_cristallo": {"weak": ["vuoto"], "resist": ["luce"]},
	"geomimo": {"weak": ["linfa"], "resist": ["gelo"]}, "serpe_linfa": {"weak": ["gelo"], "resist": ["linfa"]},
	"campanula_errante": {"weak": ["vuoto"], "resist": ["luce"]}, "guizzalinfa": {"weak": ["gelo"], "resist": ["linfa"]},
	"mietivuoto": {"weak": ["luce"], "resist": ["vuoto"]}, "tessivuoto": {"weak": ["luce"], "resist": ["vuoto"]},
	"sciame_schegge": {"weak": ["luce"], "resist": ["vuoto"]},
	"madre_grumi": {"weak": ["brace"], "resist": ["spora"]},
	"tessitrice_radici": {"weak": ["brace"], "resist": []}, "serpe_madre": {"weak": ["gelo"], "resist": ["linfa"]},
	"mietitore_cavo": {"weak": ["luce"], "resist": ["vuoto"]},
	# voce 56
	"pecora_muschio": {"weak": ["brace"], "resist": []}, "cornoradice": {"weak": ["brace"], "resist": ["spora"]},
	"lepre_linfa": {"weak": ["vuoto"], "resist": ["linfa"]}, "bruco_lanterna": {"weak": ["brace"], "resist": []},
	"ape_lume": {"weak": ["gelo"], "resist": ["luce"]}, "formica_resina": {"weak": ["gelo"], "resist": ["brace"]},
	"pipistrello_corteccia": {"weak": ["luce"], "resist": ["vuoto"]}, "libellula_brina": {"weak": ["brace"], "resist": ["gelo"]},
	"volpe_ambra": {"weak": ["gelo"], "resist": ["luce"]}, "lince_ardesia": {"weak": ["vuoto"], "resist": ["gelo"]},
	"grande_cervo": {"weak": ["brace"], "resist": ["gelo"]}, "madre_salamandre": {"weak": ["gelo"], "resist": ["brace"]},
}


## Il moltiplicatore di un elemento contro una creatura (1 = niente di speciale).
static func affinity(creature_id: String, elem: String) -> float:
	var a: Dictionary = AFFINITY.get(creature_id, {})
	if elem in a.get("weak", []):
		return WEAK
	if elem in a.get("resist", []):
		return RESIST
	return 1.0


## La reazione tra due elementi ({} se non ce n'è).
static func reaction(a: String, b: String) -> Dictionary:
	for r in REACTIONS:
		if (r["pair"][0] == a and r["pair"][1] == b) or (r["pair"][0] == b and r["pair"][1] == a):
			return r
	return {}


## «[color=#ff8a4a]Brace[/color]»
static func tag(elem: String) -> String:
	var e: Dictionary = ELEMENTS.get(elem, {})
	if e.is_empty():
		return ""
	# voce 101: con l'icona dell'elemento davanti (la Linfa come elemento ha la sua, diversa dalla goccia della barra)
	var ic := ArtLib.bb("interfaccia", "linfa_elemento" if elem == "linfa" else elem)
	return "%s[color=%s]%s[/color]" % [ic, e["color"], e["name"]]


## Voce 92: più quelle dei pacchetti dei biomi (`BiomesData`).
static var AFFINITY: Dictionary = _AFFINITY.merged(BiomesData.pack_creatures("affinity"))
