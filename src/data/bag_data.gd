class_name BagData
extends RefCounted
## La Bisaccia a scomparti (Roadmap 53, 7 ott 2026; l'utente: «la bisaccia si riempie troppo spesso all'inizio,
## obbligandomi a fare spedizioni brevi… sarà divisa in scomparti, ognuno grande come la bisaccia attuale»).
## Solo dati; le regole stanno in `Bisaccia` (le caselle, `sections`) e in `Backpack`.
##   SECTIONS  i nove scomparti, gli stessi tipi delle casse (`StorageData.category_of`): dopo la barra rapida, uno dopo
##             l'altro nelle caselle della Bisaccia. Ognuno parte da `BASE` caselle (una pagina del pannello, quanto la
##             Bisaccia di prima sopra la barra rapida) e cresce con le Bisacce a gradi (`GRADES`).
##   la Raccolta: ciò che si legge o si colleziona (tavolette, pagine, cronache, ricordi, curiosità, fossili, reliquie)
##             sta in una borsa a parte (`Bisaccia.raccolta`) senza limite, che resta addosso come gli scomparti fissi.

const BASE := 30
const PAGE := 30                       # caselle per pagina nel pannello
const RACCOLTA_BASE := 30              # la Raccolta parte da qui e cresce di una pagina quando è piena
## Le grandezze di ogni scomparto con le Bisacce a gradi (le loro «slots» in `BackpackData.BAGS`).
const GRADES := [30, 40, 50, 60, 75, 90]

## [id (il tipo di `StorageData`), nome, icona (forma, materiale), sagoma della casella vuota]
const SECTIONS := [
	["minerali", "Minerali", ["minerale", "radicite"], "minerale"],
	["materiali", "Materiali", ["seta", "legno"], "seta"],
	["costruzione", "Costruire", ["zolla", "ardesia"], "zolla"],
	["equipaggiamento", "Equipaggiamento", ["spada", "legnoferro"], "spada"],
	["pozioni", "Pozioni e cibo", ["pozione", "linfa"], "pozione"],
	["semi", "Semi e geni", ["seme", "muschio"], "seme"],
	["mandria", "Mandria", ["uovo", "ambra"], "uovo"],
	["pesca", "Pesca", ["pesce", "lagunite"], "pesce"],
	["tesori", "Tesori", ["corona", "ambra"], "corona"],
]
const RACCOLTA := ["raccolta", "Raccolta", ["tavoletta", "sem"], "tavoletta"]

## I tipi d'oggetto della Raccolta (più i fossili, gli scheletri e i frammenti delle cronache, riconosciuti dai loro dati).
const RACCOLTA_KINDS := ["tavoletta", "pagina", "ricordo", "reliquia", "curiosita"]


static func ids() -> Array:
	return SECTIONS.map(func(s: Array) -> String: return String(s[0]))


static func info(id: String) -> Array:
	for s in SECTIONS:
		if String(s[0]) == id:
			return s
	return RACCOLTA if id == "raccolta" else []


static func name_of(id: String) -> String:
	var s := info(id)
	return String(s[1]) if not s.is_empty() else id


## Va nella Raccolta? (Tavolette, pagine, ricordi e cronache, reliquie, curiosità, fossili e scheletri.)
static func is_collection(id: String) -> bool:
	var it := ItemsData.get_item(id)
	if it.is_empty():
		return false
	if String(it.get("kind", "")) in RACCOLTA_KINDS or bool(it.get("curiosita", false)):
		return true
	return _archive().has(id)


static var _arch := {}


## I fossili, gli scheletri e i frammenti delle cronache (dai dati dell'archeologia e delle cronache).
static func _archive() -> Dictionary:
	if _arch.is_empty():
		for k in ArchaeologyData.items():
			if k != "pennello":
				_arch[k] = true
		for k in ChroniclesData.items():
			_arch[k] = true
		_arch[""] = false
	return _arch


## Lo scomparto di un oggetto: «raccolta» o un tipo di `SECTIONS`.
static func section_of(id: String) -> String:
	if is_collection(id):
		return "raccolta"
	return StorageData.category_of(id)


## La grandezza degli scomparti con la Bisaccia di questo numero di caselle (il vecchio conteggio «bisaccia_caselle»:
## 40, 50, 60, 72, 84, 100 → 30, 40, 50, 60, 75, 90).
static func size_for_old(slots: int) -> int:
	var old := [40, 50, 60, 72, 84, 100]
	var best := BASE
	for k in old.size():
		if slots >= int(old[k]):
			best = int(GRADES[k])
	return best
