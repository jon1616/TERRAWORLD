class_name AtlasData
extends RefCounted
## L'Atlante dei mondi (Roadmap 23, voce 235): le cinque stelle di un mondo e i premi delle stelle. Le regole in `Atlas`.
##   STARS: [id, nome, che cosa chiede] (l'ordine è quello delle stelle nella scheda)
##   REWARDS: ogni `EVERY` stelle in tutto un premio (oltre l'ultimo si ricomincia dal `LOOP`-esimo)

const STARS := [
	["mappa", "La mappa", "scopri il %d%% del mondo sulla mappa"],
	["firma", "La firma", "trova la firma del mondo, la cosa che c'è solo lì"],
	["guardiano", "Il Guardiano", "cura o sconfiggi il Guardiano del Cuore"],
	["sigilli", "I Sigilli", "apri metà dei luoghi sigillati"],
	["segreti", "I segreti", "trova tutti i segreti del mondo"],
]
const MAP_FRAC := 0.05                 # la stella della mappa: il 5% delle celle (voce 441: un mondo è di 3,6 milioni di celle, le stesse ~180.000 di prima)
const SEALS_FRAC := 0.5
const TICK := 5.0                      # ogni quanti secondi si guardano le stelle

const EVERY := 5
const LOOP := 8
const REWARDS := [
	{"polvere_iridata": 2, "mappa_seminatori": 1},
	{"linfa_antica": 2, "mappa_sigilli": 1},
	{"polvere_iridata": 3, "mappa_firma": 1},
	{"tavoletta_seminatori": 3, "provetta": 3},
	{"linfa_antica": 3, "polvere_iridata": 3},
	{"mappa_seminatori": 2, "mappa_firma": 2},
	{"polvere_iridata": 5, "linfa_antica": 3},
	{"tavoletta_seminatori": 5, "mappa_sigilli": 2},
	{"polvere_iridata": 4, "linfa_antica": 2},
	{"mappa_firma": 2, "provetta": 5},
]


static func star_name(id: String) -> String:
	for s in STARS:
		if String(s[0]) == id:
			return String(s[1])
	return id


static func star_desc(id: String) -> String:
	for s in STARS:
		if String(s[0]) == id:
			return String(s[2]) % int(MAP_FRAC * 100.0) if id == "mappa" else String(s[2])
	return ""


## Il premio della n-esima cinquina di stelle (n da 1).
static func reward(n: int) -> Dictionary:
	var i := n - 1
	if i >= REWARDS.size():
		i = LOOP + (i - REWARDS.size()) % (REWARDS.size() - LOOP)
	return REWARDS[i]
