class_name LanguageData
## La lingua dei Seminatori (voce 68, Roadmap 9): le parole (come si scrivono nella loro lingua e che cosa vogliono
## dire), le frasi delle **stele** e le **tavolette** che insegnano le parole. Solo dati: le regole in `Language`.
## Una stele porta una frase: le parole che conosci si leggono in italiano, le altre restano nella loro lingua. Le
## frasi che indicano un luogo («sigillo di brace dorme sotto, verso l'alba, lontano») lo segnano sulla mappa quando
## le conosci tutte: la stessa stele, riletta più avanti, dice di più.

## parola -> [nella lingua dei Seminatori, in italiano]
const WORDS := {
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

## Le tavolette: quante parole insegnano (prima quelle delle stele di questo mondo).
const TABLET_WORDS := 3
## Ogni stele letta la prima volta insegna una parola dal contesto.
const STELE_WORDS := 1

const ITEMS := {
	"tavoletta_seminatori": {"name": "Tavoletta dei Seminatori", "kind": "tavoletta", "icon": ["tavoletta", "ardesia"],
		"stack": 20, "value": 40,
		"desc": "Una tavoletta di pietra con parole dei Seminatori e il loro senso inciso accanto. Usala: impari tre parole (prima quelle delle stele di questo mondo)."},
}


## La parola nella lingua dei Seminatori.
static func sem(w: String) -> String:
	return String(WORDS.get(w, ["?", "?"])[0])


## La parola in italiano.
static func it(w: String) -> String:
	return String(WORDS.get(w, ["?", "?"])[1])
