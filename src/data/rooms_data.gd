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
	"stanza": {"name": "Stanza", "need": "", "gives": "nessun bonus: aggiungi degli arredi per darle un tipo"},
}
const ORDER := ["stalla", "laboratorio", "serra", "acquario", "trofei", "biblioteca", "osservatorio", "cantina", "casa"]

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
