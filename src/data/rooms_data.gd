class_name RoomsData
extends RefCounted
## Le stanze (voce 142, Roadmap 15): che cosa fa di un posto chiuso una stanza, i tipi (riconosciuti dagli arredi, in
## quest'ordine: vince il primo che va bene) e che cosa moltiplicano. La logica sta in `Rooms`.
## Una stanza: celle libere chiuse da blocchi, con una **parete dietro ogni cella** e **una porta** nel contorno, al più
## `MAX_CELLS` celle. Il **comfort** (0-100) viene dalla bellezza degli arredi e dei blocchi del contorno, dalle luci e
## dalle serie complete; moltiplica il bonus del tipo (× (1 + comfort / 100)).

const MAX_CELLS := 260
const MIN_CELLS := 6
const MAX_SIDE := 32
const BENCHES := ["ceppo", "maglio", "telaio", "alambicco", "mola", "scalpellino", "baccello_ardente", "paiolo", "banco_innesti"]
const CONTAINERS_MIN := 2

## tipo → nome, che cosa serve (per la scheda e l'Enciclopedia), che cosa dà.
const TYPES := {
	"stalla": {"name": "Stalla", "need": "un Recinto-mangiatoia o un'Incubatrice", "gives": "la mandria produce di più (in tutto il mondo)"},
	"laboratorio": {"name": "Laboratorio", "need": "almeno due banchi da lavoro", "gives": "più probabilità di qualità alta creando qui dentro"},
	"serra": {"name": "Serra", "need": "almeno tre colture o tre vasi fioriti", "gives": "le colture qui dentro crescono molto più in fretta"},
	"acquario": {"name": "Acquario", "need": "almeno sei celle di liquido e due specie di pesci nei contenitori", "gives": "fortuna di pesca in tutto il mondo"},
	"trofei": {"name": "Sala dei trofei", "need": "almeno tre trofei diversi nei contenitori", "gives": "più danno contro le famiglie dei trofei esposti"},
	"biblioteca": {"name": "Biblioteca", "need": "due scaffali, un tavolo e una luce", "gives": "le tavolette dei Seminatori insegnano una parola in più"},
	"osservatorio": {"name": "Osservatorio", "need": "due finestre e un tavolo, sopra la terra", "gives": "gli eventi e le stelle cadenti arrivano più spesso"},
	"cantina": {"name": "Cantina", "need": "due contenitori con cibo o pozioni", "gives": "cibi e pozioni bevuti qui durano di più"},
	"casa": {"name": "Casa", "need": "un letto", "gives": "qui dentro la Vita ricresce più in fretta; gli abitanti ci stanno più volentieri"},
	# Roadmap 47, voce 402: le stanze con un mestiere
	"forgia": {"name": "Forgia", "need": "un Baccello ardente e un Maglio", "gives": "fondendo qui, a volte i lingotti sono di più"},
	"alchimia": {"name": "Laboratorio di Linfa", "need": "un Alambicco e due luci", "gives": "pozioni e piatti fatti qui, a volte uno in più"},
	"officina": {"name": "Officina", "need": "tre banchi tra Maglio, Telaio, Mola, Scalpellino e Banco degli innesti",
		"gives": "la tempra al Maglio costa meno Schegge"},
	"serra_calda": {"name": "Serra calda", "need": "almeno tre colture e un camino", "gives": "le colture crescono ancora più in fretta, anche al freddo"},
	"sala_armi": {"name": "Sala d'armi", "need": "almeno sei armi diverse nei contenitori",
		"gives": "le arti delle armi crescono più in fretta (in tutto il mondo)"},
	"stanza": {"name": "Stanza", "need": "", "gives": "nessun bonus: aggiungi degli arredi per darle un tipo"},
}
const ORDER := ["stalla", "forgia", "alchimia", "officina", "laboratorio", "serra_calda", "serra", "acquario", "trofei", "sala_armi",
	"biblioteca", "osservatorio", "cantina", "casa"]

## Il comfort: quanto conta ogni cosa, e i nomi dei livelli.
const PER_LIGHT := 3
const LIGHT_MAX := 12
const PER_SERIES := 10
const WALL_BEAUTY := 3                   # × la bellezza media dei costrutti del contorno
const CRAMPED := 12                      # sotto queste celle la stanza è stretta (−10)
const LEVELS := [[0, "spoglia"], [20, "accogliente"], [40, "bella"], [70, "splendida"]]

## I bonus di base (poi × (1 + comfort / 100)).
const REGEN := 0.5                       # casa: + la ricrescita della Vita
const QUALITY := 0.1                     # laboratorio: fortuna della qualità
const GROW := 0.6                        # serra: + la crescita
const HERD := 0.2                        # stalla: + i prodotti
const FISH := 0.05                       # acquario: fortuna di pesca
const TROPHY := 0.08                     # sala dei trofei: + danno contro quelle famiglie
const EVENTS := 0.25                     # osservatorio: + probabilità degli eventi
const BOON := 0.3                        # cantina: + la durata di cibi e pozioni
## Roadmap 47 (voci 401-402).
const BOSS_TROPHY := 0.15                # sala dei trofei: + danno contro il boss del trofeo esposto
const FORGE := 0.2                       # forgia: probabilità di metà lingotti in più al Baccello ardente
const ALCHEMY := 0.25                    # laboratorio di Linfa: probabilità di metà in più all'Alambicco e al Paiolo
const WORKSHOP := 0.2                    # officina: la tempra costa questa parte in meno (× comfort)
const WARM := 1.0                        # serra calda: + la crescita (più della serra)
const ARMS := 0.25                       # sala d'armi: + i punti delle arti
const WORKSHOP_BENCHES := ["maglio", "telaio", "mola", "scalpellino", "banco_innesti"]


## Voce 401: il boss di un trofeo («trofeo_<creatura>», o «trofeo_<id del Guardiano>»; "" se non è il trofeo di un boss).
static func boss_of_trophy(id: String) -> String:
	if not id.begins_with("trofeo_"):
		return ""
	var rest := id.substr(7)
	var cd: Dictionary = CreaturesData.CREATURES.get(rest, {})
	if cd.get("boss", false):
		return rest
	for g in GuardiansData.LIST:
		if String(g["id"]) == rest:
			return String(g["creature"])
	return ""
## Voce 144: il riparo dai rigori dentro una stanza (× questo), meno `PER_ISO` per ogni punto d'isolamento medio del
## contorno (0-3); un camino ferma il freddo.
const SHELTER := 0.5
const PER_ISO := 0.2


static func level(comfort: int) -> String:
	var out := "spoglia"
	for l in LEVELS:
		if comfort >= int(l[0]):
			out = String(l[1])
	return out
