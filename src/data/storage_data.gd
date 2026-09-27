class_name StorageData
extends RefCounted
## Le casse (26 set 2026, richiesta dell'utente): quanto lontano la creazione pesca dalle casse, quanto lontano
## arriva «Nelle casse vicine», le impostazioni di ogni cassa e i tipi di oggetti che una cassa può raccogliere.
## Solo dati; le regole stanno in `Storage`.
##
## Impostazioni di una cassa (`world_meta["casse"]["x,y"]`):
##   nome     scritto sopra la cassa nel mondo (vuoto = nessuna scritta)
##   creare   la creazione usa i suoi ingredienti (se è abbastanza vicina)
##   tipo     che cosa raccoglie da «Nelle casse vicine» oltre agli oggetti che contiene già ("" = solo quelli;
##            "nulla" = niente, nemmeno quelli: una cassa chiusa)

const CRAFT_REACH := 10                # tessere: le casse entro questa distanza danno gli ingredienti
const STACK_REACH := 12                # tessere: «Nelle casse vicine»
const LABEL_REACH := 18                # tessere: si vede il nome delle casse

## Le casse del gioco (le altre stazioni con caselle: la creazione non tocca da sé la mangiatoia e l'Incubatrice).
const DEFAULT_CRAFT := {"cesta": true, "scrigno": true, "reliquiario": true, "recinto": false, "incubatrice": false}
const NO_SETTINGS := ["fagotto", "esca", "esca_legnoferro", "esca_ambra"]   # le esche non sono dispense

## I tipi, nell'ordine del menu. kinds = tipi di oggetto di `ItemsData`; prefix = inizio dell'id.
const CATEGORIES := [
	["", "Ciò che contiene già"],
	["minerali", "Minerali, lingotti e gemme"],
	["materiali", "Materiali (legno, creature, piante…)"],
	["costruzione", "Blocchi, pareti, torce e mobili"],
	["equipaggiamento", "Attrezzi, armi e armature"],
	["pozioni", "Pozioni e cibo"],
	["semi", "Semi, colture, Fiale e Provette"],
	["mandria", "Uova, vasetti e lacci"],
	["tesori", "Trofei, Essenze, reliquie e ricordi"],
	["nulla", "Niente (cassa chiusa)"],
]
const KINDS := {
	"costruzione": ["blocco", "piattaforma", "parete", "torcia", "stazione"],
	"equipaggiamento": ["piccone", "ascia", "spada", "arco", "bastone", "munizione", "elmo", "corazza", "gambali", "guanti", "stivali", "mantello", "amuleto", "anello",
		"accessorio", "rampino", "esplosivo", "ricurvo", "giavellotto", "martello", "annaffiatoio", "lanterna",
		"evocatore", "specchio"],
	"pozioni": ["consumabile", "cura", "dono"],
	"semi": ["seme", "seme_mondo", "coltura", "purifica", "fiala", "provetta"],
	"mandria": ["uovo", "vasetto", "creatura", "laccio", "compagno"],
	"tesori": ["trofeo", "essenza", "reliquia", "ricordo", "richiamo", "mappa", "moneta"],
}
const ORE_PREFIX := ["minerale_", "lingotto_", "gemma_"]


## Il tipo di un oggetto (una chiave di `CATEGORIES`).
static func category_of(id: String) -> String:
	var it := ItemsData.get_item(id)
	var kind := String(it.get("kind", ""))
	for c in KINDS:
		if kind in KINDS[c]:
			return c
	for p in ORE_PREFIX:
		if id.begins_with(p):
			return "minerali"
	var icon: Array = it.get("icon", [])
	if not icon.is_empty() and String(icon[0]) in ["gemma", "lingotto", "minerale", "cristallo"]:
		return "minerali"
	return "materiali"


static func category_name(c: String) -> String:
	for e in CATEGORIES:
		if e[0] == c:
			return String(e[1])
	return c
