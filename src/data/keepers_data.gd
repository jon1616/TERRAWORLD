class_name KeepersData
extends RefCounted
## I Custodi degli strati (voce 27): boss intermedi, uno per strato sotto la superficie, tra l'inizio e il Guardiano.
## Ognuno dorme in un **bozzolo** dentro la sua tana (passata Tane) e si schiude quando il Germogliato si avvicina; una
## volta sconfitto si può richiamare all'**Altare dei Seminatori** con il suo **richiamo**, per tornare a cercare il suo
## bottino. Solo dati; li gestisce `Keepers`. Le creature stanno in `CreaturesData` (con `boss`), gli oggetti in
## `KeeperItemsData`.
##
## Campi: creature, stratum (dove sta la tana), wake (frase quando si sveglia), color (della scritta), summon (oggetto
## che lo richiama), page (pagina di storia la prima volta che lo si sconfigge), lair (stile della tana: decorazione).

const KEEPERS := {
	"madre_grumi": {"creature": "madre_grumi", "stratum": 1, "wake": "Il bozzolo si squarcia: i grumi hanno una madre",
		"color": "#8ef0d8", "summon": "richiamo_madre", "page": "custode_madre", "lair": TileDefs.DECOR_SPORE},
	"tessitrice": {"creature": "tessitrice_radici", "stratum": 2, "wake": "Fili ovunque. Qualcosa scende dal soffitto",
		"color": "#e8d8b0", "summon": "richiamo_tessitrice", "page": "custode_tessitrice", "lair": TileDefs.DECOR_ROOTS[0]},
	"serpe_madre": {"creature": "serpe_madre", "stratum": 3, "wake": "La Linfa si solleva e prende la forma di un serpente",
		"color": "#5cc8cc", "summon": "richiamo_serpe", "page": "custode_serpe", "lair": TileDefs.DECOR_LINFA},
	"mietitore": {"creature": "mietitore_cavo", "stratum": 4, "wake": "Il Vuoto ha mandato qualcuno a mietere",
		"color": "#c08aff", "summon": "richiamo_mietitore", "page": "custode_mietitore", "lair": TileDefs.DECOR_SHARD},
}

## Tessere dal bozzolo entro cui il Custode si schiude; oltre `LEASH` torna a dormire (e guarisce).
const WAKE := 14.0
const LEASH := 70.0


## Il Custode che nasce da una creatura (per id della creatura), o "".
static func of_creature(cid: String) -> String:
	for k in KEEPERS:
		if KEEPERS[k]["creature"] == cid:
			return k
	return ""


## Il Custode richiamato da un oggetto, o "".
static func of_summon(item: String) -> String:
	for k in KEEPERS:
		if KEEPERS[k]["summon"] == item:
			return k
	return ""
