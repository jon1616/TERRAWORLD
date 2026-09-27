class_name NeroData
## Il Seme Nero (voce 72, Roadmap 9): l'origine dell'Avvizzimento. Il Seme Nero (premio dell'ultima tappa della «Via del
## Seme Nero», voce 69), piantato in un'Aiuola, apre **il mondo dove cadde** (`world_meta["nero"]`): Avvizzimento
## ovunque, e nella cupola del Cuore non un Guardiano come gli altri ma **l'Avvizzitore**, il seme stesso cresciuto.
## Come ogni Guardiano si può **sconfiggere** o **curare** (Rugiada sui quattro nodi), e la scelta vale per **tutti i
## mondi** (`Character.seme_nero`): spezzato, l'Avvizzimento smette di allargarsi ovunque; curato, si ritira ovunque.
## Non chiude il gioco: apre il fine gioco (Roadmap 11).

const GUARDIAN := {"id": "avvizzitore", "creature": "avvizzitore", "cure": {"linfa_del_seme": 5, "linfa_antica": 5},
	"pages": {"sconfitto": "nero_spezzato", "curato": "nero_curato"}, "color": "#b070ff",
	"wake": "Il Seme Nero si apre: ciò che ne esce ti riconosce"}
## Ciò che lascia sconfitto (tabella in `LootData`: «avvizzitore»).

const ITEMS := {
	"scheggia_nera": {"name": "Scheggia del Seme Nero", "kind": "materiale", "icon": ["gemma", "vuotite"], "stack": 99, "value": 200,
		"desc": "Un pezzo del guscio del Seme Nero, freddo e duro. Al Maglio diventa un amuleto di chi l'ha spezzato."},
	"linfa_del_seme": {"name": "Linfa del Seme guarito", "kind": "materiale", "icon": ["goccia", "linfa"], "stack": 99, "value": 200,
		"source": "l'Avvizzitore curato, dove cadde il Seme Nero",
		"desc": "La linfa che scorre nel Seme Nero una volta guarito: chiara come il primo giorno. Al Maglio diventa un amuleto."},
	"amuleto_seme_spezzato": {"name": "Amuleto del seme spezzato", "kind": "accessorio", "icon": ["amuleto", "vuotite"], "stack": 1, "value": 800,
		"acc": {"damage": 1.15, "atk_speed": 1.08, "thorns": 6}, "desc": "Il guscio del seme che hai spezzato: chi lo porta colpisce più forte."},
	"amuleto_seme_guarito": {"name": "Amuleto del seme guarito", "kind": "accessorio", "icon": ["amuleto", "linfa"], "stack": 1, "value": 800,
		"acc": {"regen": 1.5, "linfa_regen": 1.3, "halo": 1.4}, "desc": "Il seme che hai curato: la Vita e la Linfa tornano in fretta."},
}

const RECIPES := [
	{"out": "amuleto_seme_spezzato", "qty": 1, "in": {"scheggia_nera": 3, "lingotto_ambra": 5}, "station": "maglio"},
	{"out": "amuleto_seme_guarito", "qty": 1, "in": {"linfa_del_seme": 3, "cristallo_linfa": 5}, "station": "maglio"},
]

## Il nome del mondo dove cadde.
const WORLD_NAME := "Dove cadde il Seme Nero"
