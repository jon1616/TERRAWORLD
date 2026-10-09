class_name BackpackData
extends RefCounted
## Lo zaino (Roadmap 30, 30 set 2026; l'utente: «aumentando gli oggetti raccoglibili lo zaino è troppo poco capiente»).
## Solo dati; le regole stanno in `Bisaccia` (caselle) e in `Backpack` (`src/game/`).
##   BAGS      le Bisacce a gradi (voce 295): usarne una porta la Bisaccia a `slots` caselle, per sempre; il contenuto
##             resta. Si fanno al Telaio con i materiali di strati sempre più profondi.
##   DISPENSA  la Dispensa del Giardiniere (voce 298): una cassa che appartiene al personaggio, uguale in ogni mondo.
##             La stazione la apre; il Seme della Dispensa (clic) ci manda il superfluo da ovunque, il Cuore della
##             Dispensa (clic) la apre da ovunque. Al primo uso ognuno la ingrandisce (`DISPENSA_SLOTS`).
##   BASTI     il basto della mandria (voce 299): clic = sulla prima creatura che ti segue senza basto (o con uno più
##             piccolo). Finché ti segue porta `slots` caselle più una ogni due livelli: la Bisaccia ci mette ciò che non
##             entra più in lei.

const BASE := 40                       # la Bisaccia di partenza (`Bisaccia.SIZE`)
const PAGE := 30                       # caselle per pagina nel pannello (sopra la barra rapida)

## Roadmap 53: «slots» = le caselle di ogni scomparto (`BagData.GRADES`), non più di tutta la Bisaccia.
const BAGS := [
	{"id": "bisaccia_seta", "name": "Bisaccia di seta", "slots": 40, "mat": "seta",
		"in": {"seta_radice": 12, "legno": 20, "gelatina": 6}},
	{"id": "bisaccia_radicite", "name": "Bisaccia cucita di radicite", "slots": 50, "mat": "radicite",
		"in": {"seta_radice": 16, "lingotto_radicite": 8, "corda_liana": 4}},
	{"id": "bisaccia_legnoferro", "name": "Bisaccia di legnoferro", "slots": 60, "mat": "legnoferro",
		"in": {"seta_radice": 20, "lingotto_legnoferro": 10, "corda_liana": 6}},
	{"id": "bisaccia_ambra", "name": "Bisaccia d'ambra", "slots": 75, "mat": "ambra",
		"in": {"seta_radice": 24, "lingotto_ambra": 10, "cristallo_linfa": 4}},
	{"id": "bisaccia_linfa", "name": "Bisaccia della Linfa", "slots": 90, "mat": "linfa",
		"in": {"seta_radice": 30, "lingotto_linfa": 10, "polvere_iridata": 2, "linfa_antica": 1}},
]


## Gli scomparti della Bisaccia (3 ott 2026, richiesta dell'utente): caselle fisse per tipo che restano addosso quando si
## appassisce (regole in `Compartments`). kinds = i tipi d'oggetto che prendono; ghost = la sagoma della casella vuota.
const COMPARTMENTS := [
	{"id": "munizioni", "name": "Munizioni", "slots": 4, "kinds": ["munizione", "esplosivo", "giavellotto"], "ghost": "freccia"},
	{"id": "torce", "name": "Torce", "slots": 2, "kinds": ["torcia"], "ghost": "torcia"},
	{"id": "soldi", "name": "Lumini", "slots": 2, "kinds": ["moneta"], "ghost": "lumino"},
]

## grado 1 (la stazione), 2 (il Seme), 3 (il Cuore); (voce 352, 4 ott 2026: «ho già riempito la dispensa da 200»)
## 4 la Radice, 5 il Geode, 6 la Stella della Dispensa, con i metalli dei gradi avanti: la base cresce con la partita.
const DISPENSA_SLOTS := [60, 120, 200, 320, 480, 720]
## Ciò che il Seme della Dispensa manda sempre (oltre a ciò che la Dispensa contiene già): i tipi che arrivano a mucchi.
const SURPLUS_KINDS := ["materiale", "blocco", "parete", "pesce", "coltura", "seme", "essenza"]
const BASTI := [
	{"id": "basto_radice", "name": "Basto di radice", "slots": 8, "mat": "radice",
		"in": {"legno": 16, "seta_radice": 6, "corda_liana": 3}, "station": "telaio"},
	{"id": "basto_legnoferro", "name": "Basto di legnoferro", "slots": 14, "mat": "legnoferro",
		"in": {"lingotto_legnoferro": 6, "seta_radice": 10, "corda_liana": 4}, "station": "telaio"},
	{"id": "basto_ambra", "name": "Basto d'ambra", "slots": 20, "mat": "ambra",
		"in": {"lingotto_ambra": 6, "seta_radice": 14, "cristallo_linfa": 2}, "station": "telaio"},
]


static func basto_of(id: String) -> Dictionary:
	for b in BASTI:
		if String(b["id"]) == id:
			return b
	return {}


## Le caselle del basto di una creatura della mandria: quelle del basto più una ogni due livelli.
static func basto_slots(id: String, lvl: int) -> int:
	return int(basto_of(id).get("slots", 0)) + mini(lvl, 20) / 2       # (Roadmap 32: oltre il 20 non cresce)


const DISPENSA_ITEMS := {
	"dispensa": {"name": "Dispensa del Giardiniere", "kind": "stazione", "place": "dispensa", "icon": ["cesta", "cristallo"],
		"stack": 1, "desc": "Una cassa che è tua, non del mondo: ciò che ci metti lo ritrovi in ogni Dispensa, in ogni mondo. %d caselle." % 60},
	"seme_dispensa": {"name": "Seme della Dispensa", "kind": "dispensa", "grado": 2, "icon": ["seme", "cristallo"], "stack": 1,
		"desc": "Clic: da qualunque mondo manda nella Dispensa ciò che contiene già e i materiali (non la barra rapida). La prima volta la porta a 120 caselle."},
	"cuore_dispensa": {"name": "Cuore della Dispensa", "kind": "dispensa", "grado": 3, "icon": ["cuore", "ambra"], "stack": 1,
		"desc": "Clic: apre la Dispensa dove sei, in qualunque mondo. La prima volta la porta a 200 caselle."},
	"radice_dispensa": {"name": "Radice della Dispensa", "kind": "dispensa", "grado": 4, "icon": ["cuore", "linfa"], "stack": 1,
		"desc": "Clic: apre la Dispensa dove sei. La prima volta la porta a 320 caselle: le sue radici scendono più a fondo."},
	"geode_dispensa": {"name": "Geode della Dispensa", "kind": "dispensa", "grado": 5, "icon": ["gemma", "vuotite"], "stack": 1,
		"desc": "Clic: apre la Dispensa dove sei. La prima volta la porta a 480 caselle: dentro il geode c'è più spazio che fuori."},
	"stella_dispensa": {"name": "Stella della Dispensa", "kind": "dispensa", "grado": 6, "icon": ["cuore", "stelle"], "stack": 1,
		"desc": "Clic: apre la Dispensa dove sei. La prima volta la porta a 720 caselle, l'ultima grandezza."},
}
const DISPENSA_RECIPES := [
	{"out": "dispensa", "qty": 1, "in": {"legno": 30, "lingotto_radicite": 6, "seme_lanterna": 2}, "station": "ceppo"},
	{"out": "seme_dispensa", "qty": 1, "in": {"lingotto_legnoferro": 6, "cristallo_linfa": 3, "seme_lanterna": 4}, "station": "maglio"},
	{"out": "cuore_dispensa", "qty": 1, "in": {"lingotto_ambra": 8, "linfa_antica": 2, "polvere_iridata": 2}, "station": "maglio"},
	{"out": "radice_dispensa", "qty": 1, "in": {"cuore_dispensa": 1, "lingotto_linfa": 8, "seta_radice": 20, "linfa_antica": 2}, "station": "maglio"},
	{"out": "geode_dispensa", "qty": 1, "in": {"radice_dispensa": 1, "lingotto_vuoto": 8, "cristallo_linfa": 10, "polvere_iridata": 3}, "station": "maglio"},
	{"out": "stella_dispensa", "qty": 1, "in": {"geode_dispensa": 1, "lingotto_stellare": 8, "linfa_antica": 4, "polvere_iridata": 4}, "station": "maglio"},
]


static func bag_of(id: String) -> Dictionary:
	for b in BAGS:
		if String(b["id"]) == id:
			return b
	return {}


static func items() -> Dictionary:
	var out := {}
	for b in BAGS:
		out[b["id"]] = {"name": b["name"], "kind": "bisaccia", "icon": ["sacca", b["mat"]], "stack": 1, "slots": b["slots"],
			"desc": "Usala: ogni scomparto della tua Bisaccia diventa di %d caselle, per sempre (ciò che contiene resta)." % int(b["slots"])}
	out.merge(DISPENSA_ITEMS.duplicate(true))
	for b in BASTI:
		out[b["id"]] = {"name": b["name"], "kind": "basto", "icon": ["velo", b["mat"]], "stack": 1, "slots": b["slots"],
			"desc": "Clic: lo metti alla prima creatura della mandria che ti segue. Finché ti segue porta %d caselle (una in più ogni due livelli): ciò che non entra nella Bisaccia va lì." % int(b["slots"])}
	return out


static func recipes() -> Array:
	var out := []
	for b in BAGS:
		out.append({"out": b["id"], "qty": 1, "in": b["in"], "station": "telaio"})
	out.append_array(DISPENSA_RECIPES.duplicate(true))
	for b in BASTI:
		out.append({"out": b["id"], "qty": 1, "in": b["in"], "station": b["station"]})
	return out
