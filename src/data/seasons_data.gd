class_name SeasonsData
extends RefCounted
## Le stagioni (voce 66, Roadmap 8): ogni mondo attraversa quattro stagioni di `DAYS` giorni ciascuna (un giorno = 20
## minuti), sfasate secondo il seme (due mondi non sono mai nella stessa stagione allo stesso momento). Ogni stagione
## cambia quali famiglie si vedono di più (`roles`, `families`), quanto crescono le colture, gli eventi e un poco il
## colore del mondo; e porta **una creatura che c'è solo allora** (`CREATURES`: nasce in superficie, lascia il suo
## materiale, con cui si fa l'accessorio della stagione) e **un gene che si cattura solo allora** (Provetta di Linfa
## nell'aria della superficie: `GenesData`, categoria «tempo»): innestato in un Seme, il mondo che ne nasce resta per
## sempre in quella stagione. Solo dati; le regole stanno in `Seasons`.

const DAYS := 3
const SEASONAL_CHANCE := 0.07          # una nascita in superficie su quindici circa è la creatura della stagione

const SEASONS := [
	{"id": "germoglio", "name": "Germoglio", "desc": "si apre tutto: erbivori e colonie ovunque, le colture crescono in fretta",
		"color": Color("#8ef0a8"), "roles": {"erbivoro": 1.6, "colonia": 1.5}, "families": {}, "grow": 1.4, "events": 1.0,
		"tint": Color(0.98, 1.05, 0.98), "creature": "lepre_germoglio", "gene": "germoglio_eterno"},
	{"id": "rigoglio", "name": "Rigoglio", "desc": "il caldo pieno: i volanti riempiono il cielo, le notti sono brevi",
		"color": Color("#ffd870"), "roles": {"volante": 1.6, "predatore": 1.2}, "families": {}, "grow": 1.2, "events": 1.2,
		"tint": Color(1.06, 1.03, 0.92), "creature": "libellula_rigoglio", "gene": "rigoglio_lungo"},
	{"id": "raccolto", "name": "Raccolto", "desc": "le foglie si fanno d'ambra: i predatori cacciano, i branchi migrano, più eventi",
		"color": Color("#ff9a50"), "roles": {"predatore": 1.6}, "families": {"volpi": 1.5}, "grow": 1.0, "events": 1.5,
		"tint": Color(1.1, 0.95, 0.85), "creature": "volpe_raccolto", "gene": "raccolto_doro"},
	{"id": "gelo", "name": "Gelo", "desc": "tutto rallenta: poche api e pochi erbivori, ma i cervi e i gufi del gelo scendono",
		"color": Color("#a8e0ff"), "roles": {"erbivoro": 0.6, "colonia": 0.3}, "families": {"cervi": 2.5, "gufi": 2.0,
		"libellule": 1.8}, "grow": 0.5, "events": 0.8, "tint": Color(0.9, 0.97, 1.12), "creature": "cervo_gelo",
		"gene": "gelo_perenne"},
]

## Le creature delle stagioni: nascono da una specie (`base`) con colori, misura e bottino loro.
const CREATURES := {
	"lepre_germoglio": {"base": "lepre_linfa", "season": "germoglio", "name": "Lepre del germoglio", "loot": "stagione_germoglio",
		"hp": 2.0, "mods": {"tint": Color("#b8ffc8"), "tint_amount": 0.55, "glow_body": true, "scale": 1.2}},
	"libellula_rigoglio": {"base": "libellula_brina", "season": "rigoglio", "name": "Libellula del rigoglio",
		"loot": "stagione_rigoglio", "hp": 2.0, "mods": {"tint": Color("#ffe070"), "tint_amount": 0.6, "glow_body": true, "scale": 1.2}},
	"volpe_raccolto": {"base": "volpe_ambra", "season": "raccolto", "name": "Volpe del raccolto", "loot": "stagione_raccolto",
		"hp": 2.2, "mods": {"tint": Color("#ff7a30"), "tint_amount": 0.55, "glow_body": true, "scale": 1.2}},
	"cervo_gelo": {"base": "cervo_brina", "season": "gelo", "name": "Cervo del gelo", "loot": "stagione_gelo",
		"hp": 2.5, "mods": {"tint": Color("#e8f8ff"), "tint_amount": 0.65, "glow_body": true, "scale": 1.25}},
}

## I materiali e gli accessori delle stagioni.
const ITEMS := {
	"fiore_germoglio": {"name": "Fiore del germoglio", "kind": "materiale", "icon": ["foglia", "muschio"], "stack": 99,
		"source": "dalla Lepre del germoglio (solo nella stagione del Germoglio)",
		"desc": "Un fiore che non appassisce, strappato alla Lepre del germoglio."},
	"polline_rigoglio": {"name": "Polline del rigoglio", "kind": "materiale", "icon": ["polvere", "ambra"], "stack": 99,
		"source": "dalla Libellula del rigoglio (solo nel Rigoglio)",
		"desc": "Polline d'oro caldo come il mezzogiorno d'estate."},
	"foglia_raccolto": {"name": "Foglia del raccolto", "kind": "materiale", "icon": ["foglia", "brace"], "stack": 99,
		"source": "dalla Volpe del raccolto (solo nel Raccolto)",
		"desc": "Una foglia d'ambra rossa: brucia piano senza consumarsi."},
	"cristallo_gelo": {"name": "Cristallo del gelo", "kind": "materiale", "icon": ["cristallo", "cristallo"], "stack": 99,
		"source": "dal Cervo del gelo (solo nel Gelo)",
		"desc": "Ghiaccio che non si scioglie mai, caduto dalle corna del Cervo del gelo."},
	"corona_germoglio": {"name": "Corona del germoglio", "kind": "accessorio", "icon": ["corona", "muschio"], "stack": 1,
		"acc": {"regen": 1.4}, "desc": "La Vita ricresce il 40% più in fretta."},
	"ali_rigoglio": {"name": "Ali del rigoglio", "kind": "accessorio", "icon": ["ali", "ambra"], "stack": 1,
		"acc": {"jump": 1.2, "run": 1.08}, "desc": "Salti più alti e corri un po' più in fretta."},
	"mantello_raccolto": {"name": "Mantello del raccolto", "kind": "accessorio", "icon": ["mantello", "brace"], "stack": 1,
		"acc": {"luck": 0.15}, "desc": "Più fortuna nel bottino (+15%)."},
	"cuore_gelo": {"name": "Cuore del gelo", "kind": "accessorio", "icon": ["cuore", "cristallo"], "stack": 1,
		"acc": {"defense": 4, "fall_safe": true}, "desc": "+4 Scorza, e nessuna ferita da caduta."},
}

const RECIPES := [
	{"out": "corona_germoglio", "qty": 1, "in": {"fiore_germoglio": 6, "lingotto_radicite": 4}, "station": "telaio"},
	{"out": "ali_rigoglio", "qty": 1, "in": {"polline_rigoglio": 6, "seta_radice": 6}, "station": "telaio"},
	{"out": "mantello_raccolto", "qty": 1, "in": {"foglia_raccolto": 6, "lana_muschio": 6}, "station": "telaio"},
	{"out": "cuore_gelo", "qty": 1, "in": {"cristallo_gelo": 6, "lingotto_legnoferro": 4}, "station": "maglio"},
]

const LOOT := {
	"stagione_germoglio": [{"item": "fiore_germoglio", "min": 1, "max": 2, "chance": 1.0}, {"item": "pelo_lepre", "min": 1, "max": 2, "chance": 0.6}],
	"stagione_rigoglio": [{"item": "polline_rigoglio", "min": 1, "max": 2, "chance": 1.0}, {"item": "ala_libellula", "min": 1, "max": 1, "chance": 0.5}],
	"stagione_raccolto": [{"item": "foglia_raccolto", "min": 1, "max": 2, "chance": 1.0}, {"item": "pelliccia_volpe", "min": 1, "max": 1, "chance": 0.5}],
	"stagione_gelo": [{"item": "cristallo_gelo", "min": 1, "max": 2, "chance": 1.0}, {"item": "vello_brina", "min": 1, "max": 2, "chance": 0.6}],
}

## La stagione (indice) del giorno `day` in un mondo con questo seme; `fixed` (1-4) = stagione fissata da un gene.
static func index(day: int, world_seed: int, fixed := 0) -> int:
	if fixed >= 1 and fixed <= SEASONS.size():
		return fixed - 1
	return ((maxi(day, 1) - 1 + posmod(world_seed, SEASONS.size() * DAYS)) / DAYS) % SEASONS.size()


## I dati di una creatura della stagione, costruiti dalla sua specie.
static func make(id: String) -> Dictionary:
	var sd: Dictionary = CREATURES[id]
	var d: Dictionary = (CreaturesData.CREATURES[String(sd["base"])] as Dictionary).duplicate(true)
	d["name"] = sd["name"]
	d["loot"] = sd["loot"]
	d["season"] = sd["season"]
	d["hp"] = roundi(int(d["hp"]) * float(sd["hp"]))
	d["damage"] = roundi(int(d["damage"]) * 1.3)
	d["docile"] = false
	var mods: Dictionary = d.get("art_mods", {}).duplicate()
	mods.merge(sd["mods"], true)
	d["art_mods"] = mods
	return d
