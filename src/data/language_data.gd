class_name LanguageData
## La lingua dei Seminatori (voce 68, Roadmap 9): le parole (come si scrivono nella loro lingua e che cosa vogliono
## dire), le frasi delle **stele** e le **tavolette** che insegnano le parole. Solo dati: le regole in `Language`.
## Una stele porta una frase: le parole che conosci si leggono in italiano, le altre restano nella loro lingua. Le
## frasi che indicano un luogo («sigillo di brace dorme sotto, verso l'alba, lontano») lo segnano sulla mappa quando
## le conosci tutte: la stessa stele, riletta più avanti, dice di più.

## Roadmap 17: tre strati di lingua. Ogni parola: [nella lingua dei Seminatori, in italiano, classe, strato] (classe e
## strato li aggiunge `_all`); `WORDS` le ha tutte. La **lingua comune** (voce 68) si legge ovunque; la **lingua antica**
## sulle stele dei mondi di vigore 3 o più e negli osservatori del cielo; la **lingua del Seme Nero** nelle cripte della
## sua via e nel mondo dove cadde.
## parola -> [nella lingua dei Seminatori, in italiano]
const _COMMON := {
	"seme": ["or", "seme"], "radice": ["vehl", "radice"], "albero": ["tharn", "albero"], "madre": ["ama", "madre"],
	"cuore": ["kesh", "cuore"], "sigillo": ["dun", "sigillo"], "chiave": ["ilth", "chiave"], "porta": ["sem", "porta"],
	"pietra": ["rok", "pietra"], "scrigno": ["varo", "scrigno"], "reliquia": ["nesh", "reliquia"], "stella": ["ist", "stella"],
	"cielo": ["ael", "cielo"], "fondo": ["dhu", "fondo"], "vuoto": ["nul", "vuoto"], "luce": ["lyr", "luce"],
	"buio": ["mor", "buio"], "brace": ["ferk", "brace"], "gelo": ["skae", "gelo"], "linfa": ["sila", "Linfa"],
	"mondo": ["ven", "mondo"], "custode": ["wehr", "custode"], "guardiano": ["orun", "guardiano"],
	"seminatori": ["sehani", "Seminatori"], "segno": ["runa", "segno"], "nero": ["zhar", "nero"],
	"malattia": ["wisk", "malattia"], "primo": ["ain", "primo"], "ultimo": ["eth", "ultimo"], "strada": ["vel", "strada"],
	"dorme": ["sae", "dorme"], "veglia": ["oth", "veglia"], "cerca": ["qir", "cerca"], "apre": ["una", "apre"],
	"chiude": ["tor", "chiude"], "cura": ["ielu", "cura"], "cade": ["fah", "cade"], "nasce": ["bri", "nasce"],
	"piantano": ["sehar", "piantano"], "sotto": ["nae", "sotto"], "sopra": ["ul", "sopra"], "alba": ["ost", "verso l'alba"],
	"tramonto": ["ves", "verso il tramonto"], "vicino": ["pel", "vicino"], "lontano": ["dar", "lontano"],
	"molto": ["ha", "molto"], "qui": ["ki", "qui"], "tutti": ["omne", "tutti"], "giardiniere": ["sehan", "giardiniere"],
	"ritorna": ["reth", "ritorna"],
}

## Le classi della lingua comune (le parole che non sono qui sono «cosa»): i significati possibili di un'ipotesi sono
## sempre della stessa classe e dello stesso strato.
const _CLASS := {
	"dorme": "azione", "veglia": "azione", "cerca": "azione", "apre": "azione", "chiude": "azione", "cura": "azione",
	"cade": "azione", "nasce": "azione", "piantano": "azione", "ritorna": "azione",
	"sotto": "luogo", "sopra": "luogo", "alba": "luogo", "tramonto": "luogo", "vicino": "luogo", "lontano": "luogo", "qui": "luogo",
	"primo": "quanto", "ultimo": "quanto", "molto": "quanto", "tutti": "quanto",
}

## La lingua antica (Roadmap 17, voce 173): [nella lingua, in italiano, classe].
const _ANCIENT := {
	"vento": ["hweh", "vento", "cosa"], "nuvola": ["nebu", "nuvola", "cosa"], "tempesta": ["orrhan", "tempesta", "cosa"],
	"ala": ["pehn", "ala", "cosa"], "occhio": ["iris", "occhio", "cosa"], "isola": ["aelin", "isola", "cosa"],
	"corrente": ["siru", "corrente", "cosa"], "tuono": ["dhrum", "tuono", "cosa"], "fulmine": ["lhaz", "fulmine", "cosa"],
	"cristallo": ["kyrr", "cristallo", "cosa"], "corona": ["kora", "corona", "cosa"], "canto": ["kann", "canto", "cosa"],
	"memoria": ["mnem", "memoria", "cosa"], "ponte": ["brig", "ponte", "cosa"], "torre": ["turra", "torre", "cosa"],
	"nome": ["nom", "nome", "cosa"], "voce": ["voha", "voce", "cosa"], "tempo": ["aev", "tempo", "cosa"],
	"sogno": ["soom", "sogno", "cosa"], "fiume": ["rhen", "fiume", "cosa"], "mare": ["maru", "mare", "cosa"],
	"fuoco": ["pyr", "fuoco", "cosa"],
	"osserva": ["spek", "osserva", "azione"], "vola": ["fleh", "vola", "azione"], "canta": ["kanu", "canta", "azione"],
	"ricorda": ["mnar", "ricorda", "azione"], "scrive": ["skri", "scrive", "azione"], "protegge": ["warn", "protegge", "azione"],
	"attende": ["bid", "attende", "azione"], "sale": ["asca", "sale", "azione"], "brucia": ["bren", "brucia", "azione"],
	"sogna": ["sween", "sogna", "azione"],
	"oltre": ["trah", "oltre", "luogo"], "dentro": ["inn", "dentro", "luogo"], "intorno": ["ymb", "intorno", "luogo"],
	"alto": ["hoh", "in alto", "luogo"],
	"mai": ["nev", "mai", "quanto"], "sempre": ["aeva", "sempre", "quanto"], "uno": ["ein", "uno solo", "quanto"],
	"mille": ["thus", "mille", "quanto"],
}

## La lingua del Seme Nero (voce 173): [nella lingua, in italiano, classe].
const _BLACK := {
	"fame": ["khar", "fame", "cosa"], "ombra": ["zhul", "ombra", "cosa"], "ferita": ["vrakh", "ferita", "cosa"],
	"bocca": ["ghom", "bocca", "cosa"], "verita": ["xel", "verità", "cosa"], "prezzo": ["druk", "prezzo", "cosa"],
	"patto": ["zhan", "patto", "cosa"], "catena": ["khel", "catena", "cosa"], "silenzio": ["shul", "silenzio", "cosa"],
	"sete": ["zirth", "sete", "cosa"], "rinascita": ["nekh", "rinascita", "cosa"],
	"divora": ["gorz", "divora", "azione"], "inganna": ["lugh", "inganna", "azione"], "tradisce": ["trakh", "tradisce", "azione"],
	"spezza": ["brakh", "spezza", "azione"], "guarisce": ["sanh", "guarisce", "azione"], "chiama": ["xhor", "chiama", "azione"],
	"nasconde": ["mhul", "nasconde", "azione"],
	"ovunque": ["omvr", "ovunque", "luogo"], "altrove": ["elsk", "altrove", "luogo"], "laggiu": ["dhun", "laggiù", "luogo"],
	"troppo": ["khu", "troppo", "quanto"], "nulla": ["nix", "nulla", "quanto"], "ogni": ["okh", "ogni", "quanto"],
}

const LAYERS := {"comune": {"name": "La lingua comune", "color": "#6ff0b8", "hyp": 2},
	"antica": {"name": "La lingua antica", "color": "#8ac8f0", "hyp": 3},
	"nera": {"name": "La lingua del Seme Nero", "color": "#b89ae0", "hyp": 3}}
const LAYER_ORDER := ["comune", "antica", "nera"]
const HYP_OPTIONS := 3                  # quanti significati possibili ha un'ipotesi (quello vero compreso)

static var WORDS: Dictionary = _all()


static func _all() -> Dictionary:
	var out := {}
	for w in _COMMON:
		out[w] = [_COMMON[w][0], _COMMON[w][1], String(_CLASS.get(w, "cosa")), "comune"]
	for w in _ANCIENT:
		out[w] = [_ANCIENT[w][0], _ANCIENT[w][1], _ANCIENT[w][2], "antica"]
	for w in _BLACK:
		out[w] = [_BLACK[w][0], _BLACK[w][1], _BLACK[w][2], "nera"]
	return out


static func class_of(w: String) -> String:
	return String(WORDS.get(w, ["", "", "cosa", "comune"])[2])


static func layer_of(w: String) -> String:
	return String(WORDS.get(w, ["", "", "cosa", "comune"])[3])


static func words_of(layer: String) -> Array:
	return WORDS.keys().filter(func(w: String) -> bool: return layer_of(w) == layer)


## I significati possibili di una parola (le parole, non i testi): quella vera e altre della stessa classe e dello
## stesso strato, sempre le stesse per quella parola, in un ordine fisso che non tradisce quella giusta.
static func options(w: String) -> Array:
	var pool := WORDS.keys().filter(func(x: String) -> bool: return x != w and class_of(x) == class_of(w) and layer_of(x) == layer_of(w))
	pool.sort()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(w + "|opzioni")
	var out := [w]
	while out.size() < HYP_OPTIONS and not pool.is_empty():
		out.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))
	out.sort_custom(func(a: String, b: String) -> bool: return hash(a + w) < hash(b + w))
	return out


## La parola del tipo di Sigillo (voce 64) nelle frasi.
const SEAL_WORD := {"velato": "buio", "radice": "radice", "vuoto": "vuoto", "brace": "brace"}

## Le frasi che indicano un luogo: {kind} = la parola del tipo, {deep} {dir} {dist} = dove, rispetto alla stele.
## [tipo di luogo, parole, nome del segno sulla mappa]
const HINTS := {
	"sigillo": [["{kind}", "sigillo", "dorme", "{deep}", "{dir}", "{dist}"], "Sigillo"],
	"reliquiario": [["reliquia", "seminatori", "dorme", "{deep}", "{dir}", "{dist}"], "Reliquiario"],
	"firma": [["segno", "mondo", "veglia", "{deep}", "{dir}", "{dist}"], "La firma del mondo"],
	"cuore": [["cuore", "mondo", "dorme", "fondo", "guardiano", "veglia"], "Il Cuore del mondo"],
	"tana": [["custode", "dorme", "{deep}", "{dir}", "{dist}"], "Tana di un Custode"],
	"luogo": [["pietra", "seminatori", "veglia", "{deep}", "{dir}", "{dist}"], "Un luogo dei Seminatori"],
}

## Le frasi della storia (non indicano luoghi): il filo che porta al Seme Nero (voce 72).
const LORE := [
	["seminatori", "piantano", "mondo"],
	["madre", "dorme", "giardiniere", "cura", "albero"],
	["seme", "nero", "cade", "cielo"],
	["malattia", "nasce", "seme", "nero"],
	["primo", "seme", "dorme", "fondo", "cielo"],
	["ultimo", "giardiniere", "ritorna"],
	["tutti", "mondo", "nasce", "seme"],
	["chiave", "apre", "porta", "seminatori"],
	["guardiano", "veglia", "cuore", "malattia", "cerca", "cuore"],
	["luce", "linfa", "cura", "malattia"],
]

## Roadmap 17, voce 173: le frasi della lingua antica (stele degli osservatori del cielo e dei mondi di vigore 3 o più)
## e della lingua del Seme Nero (le stele del suo mondo). Ogni parola dei due strati compare in almeno una frase (la
## prova lo controlla).
const LORE_ANCIENT := [
	["seminatori", "osserva", "stella", "sempre", "alto"],
	["isola", "vola", "oltre", "nuvola", "vento", "canta"],
	["occhio", "tempesta", "veglia", "dentro", "tuono", "fulmine"],
	["corona", "cristallo", "protegge", "nome", "seminatori"],
	["memoria", "scrive", "pietra", "tempo", "mai", "dorme"],
	["torre", "ponte", "cielo", "mille", "isola"],
	["fiume", "mare", "sale", "oltre", "fondo"],
	["guardiano", "ricorda", "primo", "seme", "canto"],
	["voce", "seminatori", "canta", "sogno", "mondo"],
	["fuoco", "brucia", "mai", "cristallo", "sempre", "luce"],
	["ala", "corrente", "sale", "alto", "occhio", "attende"],
	["uno", "nome", "apre", "tutti", "porta"],
	["giardiniere", "sogna", "intorno", "albero", "madre"],
]
const LORE_BLACK := [
	["seme", "nero", "fame", "divora", "ogni", "luce"],
	["patto", "seminatori", "nero", "prezzo", "silenzio"],
	["bocca", "vuoto", "chiama", "ovunque"],
	["seme", "nero", "inganna", "guarisce", "nulla"],
	["catena", "spezza", "ferita", "rinascita"],
	["verita", "laggiu", "nasconde", "ombra", "sete"],
	["seminatori", "tradisce", "troppo", "altrove"],
	["ogni", "ferita", "nasconde", "seme", "altrove"],
]
## Le iscrizioni nella lingua nera sui leggii della via del Seme Nero (una per tappa, indice in `LORE_BLACK`) e che cosa
## dicono davvero: si legge solo quando ogni loro parola è certa (e allora c'è anche un dono, una volta).
const CRYPT_TRUTH := [
	[1, "Il patto: i Seminatori accolsero il seme per il suo potere, e pagarono il prezzo in silenzio."],
	[0, "Il seme non si nutre di Linfa: si nutre della fame, e divora ogni luce che gli si avvicina."],
	[2, "Non cadde per caso. Fu chiamato: una bocca nel Vuoto chiama ancora, da ogni parte."],
	[7, "Ogni ferita dei mondi nasconde un seme più piccolo, altrove: curare il Cuore non basta a tutto."],
	[4, "Spezzarlo è una rinascita, curarlo è una catena: nessuna delle due strade è senza prezzo."],
]
const CRYPT_GIFT := {"linfa_antica": 2, "tavoletta_seminatori": 1}

## Le tavolette: quante parole **confermano** (Roadmap 17: tra quelle viste o ipotizzate, prima quelle di questo mondo).
const TABLET_WORDS := 2

const ITEMS := {
	"tavoletta_seminatori": {"name": "Tavoletta dei Seminatori", "kind": "tavoletta", "icon": ["tavoletta", "ardesia"],
		"stack": 20, "value": 40,
		"desc": "Una tavoletta di pietra con parole dei Seminatori e il loro senso inciso accanto. Usala: conferma due parole che hai già visto sulle stele (prima quelle di questo mondo)."},
}


## La parola nella lingua dei Seminatori.
static func sem(w: String) -> String:
	return String(WORDS.get(w, ["?", "?"])[0])


## La parola in italiano.
static func it(w: String) -> String:
	return String(WORDS.get(w, ["?", "?"])[1])
