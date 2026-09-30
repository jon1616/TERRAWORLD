class_name CraftCatsData
extends RefCounted
## Le categorie del pannello «Creare» (26 set 2026, richiesta dell'utente: ricette colorate per tipo; rifatte il 30 set
## 2026: «i banchi da produzione principali non li riconosco in mezzo a trappole e congegni»). Quindici categorie in
## quattro gruppi (`GROUPS`), ognuna divisa in **sottocategorie** (le intestazioni della griglia e i bottoni sopra di
## essa). `CATS` = [id, nome, colore, gruppo]. Chi decide dove va una ricetta è `place_of`: il tipo dell'oggetto
## (`kind`), la sua forma, il banco, e per le stazioni il loro id. Il colore tinge la casella della ricetta, il bottone
## della categoria e le intestazioni. «Richiami e altro» prende ciò che non sta altrove.

const GROUPS := ["Equipaggiamento", "Consumi e materiali", "Costruire", "Il mondo"]
const CATS := [
	["armi", "Armi", Color("#ff6f5e"), 0],
	["armature", "Armature", Color("#6ab4ff"), 0],
	["accessori", "Accessori", Color("#c890ff"), 0],
	["attrezzi", "Attrezzi", Color("#ffb84a"), 0],
	["pozioni", "Pozioni e cibo", Color("#ff86c8"), 1],
	["materiali", "Materiali", Color("#d8b070"), 1],
	["pesca", "Pesca", Color("#4ac0f0"), 1],
	["banchi", "Banchi e casse", Color("#f0e2c0"), 2],
	["blocchi", "Blocchi e pareti", Color("#7ed67a"), 2],
	["arredi", "Arredi", Color("#c8966a"), 2],
	["trappole", "Trappole e fattorie", Color("#e0708e"), 2],
	["totem", "Totem", Color("#b8d860"), 2],
	["giardino", "Giardino e mandria", Color("#5ee0c8"), 3],
	["rete", "Linfa e macchine", Color("#8ef0e8"), 3],
	["altro", "Richiami e altro", Color("#a0b4b0"), 3],
]
const WORK := Color("#ffd24a")         # le lavorazioni del Maglio e del Telaio (tratti, innesti, fasce)

## L'ordine delle sottocategorie fisse dentro la loro categoria (quelle fatte dai dati, come le serie di arredi o i
## materiali dei costrutti, vengono dopo, nell'ordine in cui compaiono).
const SUB_ORDER := ["Spade", "Pugnali", "Spadoni", "Lance", "Martelli", "Falci", "Fruste", "Armi uniche",
	"Archi", "Balestre", "Munizioni", "Bastoni", "Verghe", "Evocatori", "Da lancio",
	"Elmi", "Corazze", "Gambali", "Guanti", "Stivali", "Mantelli", "Ali",
	"Accessori", "Anelli", "Amuleti", "Compagni",
	"Picconi", "Trivelle", "Asce", "Bisacce e tasche", "Esplorazione", "Attrezzi da lavoro",
	"Pozioni", "Cibo", "Cure e rimedi",
	"Canne", "Esche",
	"Banchi da lavoro", "Casse e vetrine", "Altari e luoghi",
	"Blocchi", "Blocchi grezzi", "Mattoni", "Lastre", "Levigati", "Colonne", "Travi", "Tegole", "Piastrelle",
	"Vetrate", "Pareti", "Luci e passerelle", "Tinture e progetti",
	"Essenziali",
	"Trappole", "Fattorie",
	"Aiuole e Semi", "Mandria", "Acque e liquidi",
	"Sorgenti", "Riserve", "Macchine", "Comandi", "Nodi", "Vene e fili", "Attrezzi della rete",
	"Richiami", "Esche dei Signori", "Sigilli di sfida", "Trofei", "Altro"]

## I banchi da lavoro veri e propri: si riconoscono per primi.
const BENCHES := ["ceppo", "baccello_ardente", "maglio", "alambicco", "telaio", "scalpellino", "mola", "paiolo",
	"banco_innesti"]
const PLACES := ["altare", "cerchio_arena", "bacheca", "radice_viandante", "tenda_campo"]
const BASIC_FURNITURE := ["porta_lanterna", "lampada_lanterna", "tavolo_radice", "sedia_radice", "letto_foglie", "focolare"]
const HERD := ["recinto", "incubatrice", "cuccia", "alveare_costruito"]
const FARMS := ["esca", "esca_legnoferro", "esca_ambra", "tramoggia", "tramoggia_ambra", "nastro", "radice_ancora"]
const FORM_PLURAL := {"spada": "Spade", "pugnale": "Pugnali", "spadone": "Spadoni", "lancia": "Lance",
	"martello": "Martelli", "falcione": "Falci", "frusta": "Fruste", "balestra": "Balestre", "verga": "Verghe",
	"trivella": "Trivelle"}
const KIND_SUB := {"arco": "Archi", "bastone": "Bastoni", "evocatore": "Evocatori", "munizione": "Munizioni",
	"esplosivo": "Da lancio", "ricurvo": "Da lancio", "giavellotto": "Da lancio",
	"elmo": "Elmi", "corazza": "Corazze", "gambali": "Gambali", "guanti": "Guanti", "stivali": "Stivali",
	"accessorio": "Accessori", "anello": "Anelli", "amuleto": "Amuleti", "compagno": "Compagni",
	"piccone": "Picconi", "ascia": "Asce"}
const KIND_CAT := {"arco": "armi", "bastone": "armi", "evocatore": "armi", "munizione": "armi", "esplosivo": "armi",
	"ricurvo": "armi", "giavellotto": "armi", "elmo": "armature", "corazza": "armature", "gambali": "armature",
	"guanti": "armature", "stivali": "armature", "accessorio": "accessori", "anello": "accessori",
	"amuleto": "accessori", "compagno": "accessori", "piccone": "attrezzi", "ascia": "attrezzi"}
const BUILD_PLURAL := {"grezzo": "Blocchi grezzi", "mattoni": "Mattoni", "lastre": "Lastre", "levigato": "Levigati",
	"colonna": "Colonne", "travi": "Travi", "tegole": "Tegole", "piastrelle": "Piastrelle", "vetrata": "Vetrate"}
const EXPLORE := ["mappa", "bussola", "cannocchiale", "radice_ritorno", "specchio", "lanterna", "rampino", "pennello",
	"stilo"]
const ROLE_SUB := {"sorgente": "Sorgenti", "riserva": "Riserve", "macchina": "Macchine", "comando": "Comandi",
	"nodo": "Nodi"}

static var _of := {}
static var _sub := {}


## L'indice in `CATS` della categoria di un oggetto.
static func of(id: String) -> int:
	if not _of.has(id):
		_of[id] = index_of(String(place_of(id, "")[0]))
	return _of[id]


static func index_of(cat_id: String) -> int:
	for i in CATS.size():
		if String(CATS[i][0]) == cat_id:
			return i
	return CATS.size() - 1


## La sottocategoria di una ricetta (il banco conta per pozioni, cibo e materiali).
static func sub_of(r: Dictionary) -> String:
	var key := "%s|%s" % [r["out"], r.get("station", "")]
	if not _sub.has(key):
		_sub[key] = String(place_of(String(r["out"]), String(r.get("station", "")))[1])
	return _sub[key]


static func color_of(id: String) -> Color:
	return CATS[of(id)][2]


## Il posto di un oggetto nel pannello: [id della categoria, sottocategoria].
static func place_of(id: String, station: String) -> Array:
	var it := ItemsData.get_item(id)
	var kind := String(it.get("kind", ""))
	var form := String(it.get("form", ""))
	var place := str(it.get("place", id))             # («place» è un numero per i blocchi)
	if String(it.get("cat", "")) == "rete" or MachinesData.is_machine(place):
		return ["rete", String(ROLE_SUB.get(String(MachinesData.get_machine(place).get("role", "")), "Macchine"))]
	match kind:
		"spada":
			return ["armi", String(FORM_PLURAL.get(form, "Armi uniche"))]
		"arco", "bastone", "piccone":
			return [KIND_CAT[kind], String(FORM_PLURAL.get(form, KIND_SUB[kind]))]
		"mantello":
			return ["armature", "Ali" if it.has("wings") else "Mantelli"]
		"bisaccia", "tasca", "basto":
			return ["attrezzi", "Bisacce e tasche"]         # Roadmap 30: lo zaino
		"martello", "annaffiatoio":
			return ["attrezzi", "Attrezzi da lavoro"]
		"canna":
			return ["pesca", "Canne"]
		"esca":
			return ["pesca", "Esche"]
		"consumabile", "cura", "dono":
			if station == "alambicco":
				return ["pozioni", "Pozioni"]
			if station in ["paiolo", "baccello_ardente"]:
				return ["pozioni", "Cibo"]
			return ["pozioni", "Cure e rimedi"]
		"materiale", "essenza":
			return ["materiali", "A mano" if station == "" else short_station(station)]
		"blocco":
			return ["blocchi", _build_form(id) if it.has("build") else "Blocchi"]
		"parete":
			return ["blocchi", "Pareti"]
		"torcia", "piattaforma":
			return ["blocchi", "Luci e passerelle"]
		"tintura", "progetto":
			return ["blocchi", "Tinture e progetti"]
		"pinza", "occhio":
			return ["rete", "Attrezzi della rete"]
		"vena", "filo", "isolante":
			return ["rete", "Vene e fili"]
		"seme", "coltura", "seme_mondo", "fiala", "provetta", "purifica", "fagiolo":
			return ["giardino", "Aiuole e Semi"]
		"uovo", "vasetto", "laccio", "creatura":
			return ["giardino", "Mandria"]
		"secchio", "contenitore":
			return ["giardino", "Acque e liquidi"]
		"richiamo", "richiamo_grande":
			return ["altro", "Richiami"]
		"esca_signore":
			return ["altro", "Esche dei Signori"]
		"sfida":
			return ["altro", "Sigilli di sfida"]
		"trofeo":
			return ["altro", "Trofei"]
		"stazione":
			return _station_place(id, place)
	if kind in KIND_CAT:
		return [KIND_CAT[kind], KIND_SUB[kind]]
	if kind in EXPLORE:
		return ["attrezzi", "Esplorazione"]
	return ["altro", "Altro"]


## Le stazioni che non sono macchine: banchi, casse, arredi, totem, trappole, il giardino.
static func _station_place(id: String, place: String) -> Array:
	if place in BENCHES:
		return ["banchi", "Banchi da lavoro"]
	if ChestsData.is_chest(place) or place == "vetrina":
		return ["banchi", "Casse e vetrine"]
	if place in PLACES:
		return ["banchi", "Altari e luoghi"]
	if id in BASIC_FURNITURE or place in BASIC_FURNITURE:
		return ["arredi", "Essenziali"]
	if place.begins_with("arredo_"):
		var mat := _furniture_mat(place)
		return ["arredi", mat.left(1).to_upper() + mat.substr(1)]
	if place.begins_with("totem_"):
		var t := place.trim_prefix("totem_")
		t = t.substr(0, t.rfind("_"))
		return ["totem", String(ZonesData.TYPES.get(t, {}).get("name", t.capitalize()))]
	if place.begins_with("trappola_") or place == "leva_trappole":
		return ["trappole", "Trappole"]
	if place in FARMS:
		return ["trappole", "Fattorie"]
	if place == "aiuola":
		return ["giardino", "Aiuole e Semi"]
	if place in HERD:
		return ["giardino", "Mandria"]
	if place.begins_with("fonte_"):
		return ["giardino", "Acque e liquidi"]
	return ["altro", "Altro"]


## La forma di un costrutto («costr_<forma>_<materiale>»), come nome della sottocategoria: nove forme (in ognuna tutti
## i materiali) sono più facili da scorrere di ventotto materiali.
static func _build_form(id: String) -> String:
	for f in BuildData.FORMS:
		if id.begins_with("costr_%s_" % String(f["id"])):
			return String(BUILD_PLURAL.get(String(f["id"]), String(f["id"]).capitalize()))
	return "Blocchi"


static func _furniture_mat(place: String) -> String:
	for m in FurnitureData.MATS:
		if place.ends_with("_" + String(m[0])):
			for md in BuildData.MATERIALS:
				if String(md["id"]) == String(m[0]):
					return String(md["label"])
			return String(m[0])
	return place


## Il nome breve di una stazione per la riga della ricetta: «Maglio dei Seminatori» → «Maglio».
static func short_station(sid: String) -> String:
	if sid == "":
		return "a mano"
	var n := String(StationsData.STATIONS[sid]["name"])
	for cut in [" dei ", " del ", " della ", " dell'", " di "]:
		var i := n.find(cut)
		if i > 0:
			return n.substr(0, i)
	return n


static var _sections: Array = []


## Tutte le sottocategorie che hanno ricette, in ordine: [indice della categoria, nome]. Si calcola una volta.
static func sections() -> Array:
	if not _sections.is_empty():
		return _sections
	var seen := {}
	var list := []
	for r in RecipesData.all():
		var k := of(String(r["out"]))
		var s := sub_of(r)
		var key := "%d|%s" % [k, s]
		if seen.has(key):
			continue
		seen[key] = true
		var rank := SUB_ORDER.find(s)
		list.append([k, s, rank if rank >= 0 else 500, list.size()])
	list.sort_custom(func(a: Array, b: Array) -> bool:
		if a[0] != b[0]:
			return a[0] < b[0]
		if a[2] != b[2]:
			return a[2] < b[2]
		return a[3] < b[3])
	for e in list:
		_sections.append([e[0], e[1]])
	return _sections
