class_name MuseumData
extends RefCounted
## Il Museo del Giardino (Roadmap 26, voce 253; regole in `Museum`). Le sale e i loro pezzi vengono **dagli altri dati**
## (reliquie, ricordi delle meraviglie, trofei, pesci rari, varietà dell'orto, gemme, doni dei Giardini perduti, il
## primo unico di ogni serie; fossili e scheletri dall'archeologia): una collezione nuova = una riga qui.
##   name, desc, bonus (per sempre, a sala completa: chiavi di `GearEffects`)

const PIECE_BEAUTY := 2                # bellezza del Giardino per ogni pezzo esposto almeno una volta
const TICK := 5.0

const ITEMS := {
	"vetrina": {"name": "Vetrina del Museo", "kind": "stazione", "icon": ["vetro", "cristallo"], "place": "vetrina", "stack": 20,
		"desc": "Una teca di vetro su un piedistallo: ciò che vi posi, nel Giardino, entra nel Museo."},
}
const RECIPES := [
	{"out": "vetrina", "qty": 1, "in": {"vetro_resina": 3, "legno": 4}, "station": "ceppo"},
]

const HALLS := {
	"reliquie": {"name": "Sala delle reliquie", "desc": "gli attrezzi, i canti e i semi dei Seminatori", "bonus": {"luck": 0.1}},
	"meraviglie": {"name": "Sala delle meraviglie", "desc": "i ricordi dei luoghi più grandi dei mondi", "bonus": {"run": 1.04}},
	"trofei": {"name": "Sala dei trofei di caccia", "desc": "i trofei delle creature rare", "bonus": {"damage": 1.03}},
	"pesci": {"name": "Sala delle acque", "desc": "i pesci rari e leggendari", "bonus": {"fish_luck": 0.1}},
	"orto": {"name": "Sala dell'orto", "desc": "i prodotti delle varietà nate dagli incroci", "bonus": {"grow": 1.1}},
	"gemme": {"name": "Sala delle gemme", "desc": "le quattro gemme dei mondi", "bonus": {"halo": 1.15}},
	"perduti": {"name": "Sala dei Giardini perduti", "desc": "i doni degli Alberi guariti", "bonus": {"regen": 1.08}},
	"unici": {"name": "Sala degli unici", "desc": "il primo oggetto di ogni serie", "bonus": {"magic": 1.05}},
	"fossili": {"name": "Sala dei fossili", "desc": "le ventiquattro parti degli animali antichi", "bonus": {"dig": 1.08}},
	"scheletri": {"name": "Sala degli scheletri", "desc": "gli otto animali antichi ricostruiti", "bonus": {"linfa_regen": 1.08}},
}

static var _pieces := {}


## I pezzi di una sala (id degli oggetti).
static func pieces(hall: String) -> Array:
	if _pieces.is_empty():
		_build()
	return _pieces.get(hall, [])


static func _build() -> void:
	var rel := []
	for c in RelicsData.COLLECTIONS:
		rel.append_array(RelicsData.COLLECTIONS[c]["pieces"])
	_pieces["reliquie"] = rel
	_pieces["meraviglie"] = WondersData.WONDERS.keys().map(func(k: String) -> String: return WondersData.memento_id(k))
	var tro: Array = TrophyItemsData.TROPHY_OF.values().duplicate()
	tro = tro.filter(func(t: Variant) -> bool: return ItemsData.get_item(String(t)).has("name"))
	tro.sort()
	_pieces["trofei"] = tro.slice(0, 16)
	var fish := []
	var all_fish := FishData.all()
	for f in all_fish:
		if String(all_fish[f].get("rar", "")) in ["raro", "leggendario"] and ItemsData.get_item(String(f)).has("name"):
			fish.append(String(f))
	fish.sort()
	_pieces["pesci"] = fish.slice(0, 12)
	var veg := []
	for v in OrchardData.VARIETIES:
		veg.append(String(OrchardData.VARIETIES[v][4]))
	_pieces["orto"] = veg
	_pieces["gemme"] = ["brillaluce", "sanguinella", "lagunite", "nottilite"]
	var lost := []
	for g in LostGardensData.GARDENS:
		for it in (LostGardensData.GARDENS[g].get("gifts", {}) as Dictionary).get("items", {}):
			if String(it) != "linfa_antica":
				lost.append(String(it))
	_pieces["perduti"] = lost
	var uni := []
	for s in UniqueSeriesData.SERIES:
		var its: Array = UniqueSeriesData.SERIES[s].get("items", [])
		if not its.is_empty():
			uni.append(String(its[0]))
	_pieces["unici"] = uni
	var fos := []
	var ske := []
	for a in ArchaeologyData.ANIMALS:                # voce 254
		for p in ArchaeologyData.PARTS:
			fos.append(ArchaeologyData.fossil_id(String(a), String(p[0])))
		ske.append(ArchaeologyData.skeleton_id(String(a)))
	_pieces["fossili"] = fos
	_pieces["scheletri"] = ske


## La sala di un oggetto ("" se non va nel Museo).
static func hall_of(item: String) -> String:
	for h in HALLS:
		if item in pieces(h):
			return String(h)
	return ""


## I pezzi di tutte le sale.
static func total() -> int:
	var n := 0
	for h in HALLS:
		n += pieces(h).size()
	return n
