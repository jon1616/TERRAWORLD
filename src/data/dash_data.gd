class_name DashData
extends RefCounted
## La schivata (voce 127, Roadmap 15; scelta dell'utente: **solo con gli oggetti che la sbloccano**, niente scatto di
## base). Con uno di questi indossato il tasto «schiva» fa uno scatto breve nella direzione in cui si va (o si guarda),
## con un attimo d'invulnerabilità. Effetti degli accessori (`GearEffects`): dash (sblocca), dash_cd (× la ricarica).

const SPEED := 300.0                     # px/s durante lo scatto
const TIME := 0.16                       # secondi
const COOLDOWN := 1.4                    # secondi tra due schivate (× dash_cd)
const INVULN := 0.3                      # secondi d'invulnerabilità

const ITEMS := {
	"cavigliere_vento": {"name": "Cavigliere di vento", "kind": "accessorio", "icon": ["membrana", "seta"], "stack": 1,
		"acc": {"dash": true}, "desc": "Penne di corteccia legate alle caviglie: col tasto della schivata scatti di lato, e per un attimo niente ti tocca."},
	"fascia_lampo": {"name": "Fascia-lampo", "kind": "accessorio", "icon": ["membrana", "brillaluce"], "stack": 1,
		"acc": {"dash": true, "dash_cd": 0.6, "run": 1.04},
		"desc": "Una fascia con dentro la luce di un fulmine: schivate molto più frequenti, e si corre un poco più svelti."},
}

const RECIPES := [
	{"out": "cavigliere_vento", "qty": 1, "in": {"seta_radice": 4, "penna_corteccia": 3, "lingotto_radicite": 3}, "station": "telaio"},
	{"out": "fascia_lampo", "qty": 1, "in": {"cavigliere_vento": 1, "lingotto_ambra": 4, "fulgorite": 2}, "station": "maglio"},
]
