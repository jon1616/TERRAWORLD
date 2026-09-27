class_name ChallengesData
## Le sfide dei Semi (voce 82, Roadmap 11). Solo dati: le regole in `Challenges`.
## Un **Sigillo di sfida** (Maglio) si usa su un portale non ancora attraversato: il mondo che nasce porta la sfida.
## La sfida si vince risolvendo il Guardiano del Cuore (curato o sconfitto) nel rispetto della regola; si perde se la
## regola si rompe (il tempo finisce, si appassisce dove non si può). Ogni vittoria alza il **livello** di quella sfida:
## la volta dopo è più dura e rende di più, per sempre. I record (vittorie, livello, tempo migliore) sono del personaggio
## (`Character.sfide`) e si leggono nel Semenzaio e nell'Enciclopedia.
##
## Campi: name, desc (la regola), medal (l'oggetto della prima vittoria), limit (tempo, secondi: meno ogni livello).

const LIST := {
	"buio": {"name": "Senza torce", "desc": "le torce non si accendono: solo la luce di ciò che vive, delle pozioni e degli accessori",
		"medal": "medaglia_buio"},
	"tempo": {"name": "Contro il tempo", "desc": "il Guardiano va risolto prima che scada il tempo (meno a ogni livello)",
		"medal": "medaglia_tempo", "limit": 3000.0, "limit_step": 300.0, "limit_min": 1200.0},
	"avvizzimento": {"name": "L'Avvizzimento avanza", "desc": "l'Avvizzimento corre quattro volte più in fretta e le creature sono più feroci",
		"medal": "medaglia_avvizzimento"},
	"antiche": {"name": "Solo antiche", "desc": "ogni creatura nasce almeno antica (più forte, e più ricca)",
		"medal": "medaglia_antiche"},
	"fragile": {"name": "Vita fragile", "desc": "la Vita massima è la metà (e un po' meno a ogni livello)",
		"medal": "medaglia_fragile"},
	"senza_ritorno": {"name": "Senza ritorno", "desc": "se appassisci una volta, la sfida è persa",
		"medal": "medaglia_ritorno"},
}

## Il premio di una vittoria al livello n (n = 1 la prima volta): quantità × n.
const REWARD := {"linfa_antica": 1, "scheggia_vigore": 8, "lumino": 40}
const BLIGHT_MULT := 4.0
const DANGER := 0.5
const FRAGILE := 0.5
const FRAGILE_STEP := 0.04

const ITEMS := {
	"sigillo_sfida_buio": {"name": "Sigillo di sfida: Senza torce", "kind": "sfida", "icon": ["tavoletta", "vuotite"], "stack": 10,
		"desc": "Usalo su un portale non ancora attraversato: il mondo avrà la sfida «Senza torce»."},
	"sigillo_sfida_tempo": {"name": "Sigillo di sfida: Contro il tempo", "kind": "sfida", "icon": ["tavoletta", "ambra"], "stack": 10,
		"desc": "Usalo su un portale non ancora attraversato: il mondo avrà la sfida «Contro il tempo»."},
	"sigillo_sfida_avvizzimento": {"name": "Sigillo di sfida: L'Avvizzimento avanza", "kind": "sfida", "icon": ["tavoletta", "nottilite"],
		"stack": 10, "desc": "Usalo su un portale non ancora attraversato: il mondo avrà la sfida «L'Avvizzimento avanza»."},
	"sigillo_sfida_antiche": {"name": "Sigillo di sfida: Solo antiche", "kind": "sfida", "icon": ["tavoletta", "brillaluce"], "stack": 10,
		"desc": "Usalo su un portale non ancora attraversato: il mondo avrà la sfida «Solo antiche»."},
	"sigillo_sfida_fragile": {"name": "Sigillo di sfida: Vita fragile", "kind": "sfida", "icon": ["tavoletta", "sanguinella"], "stack": 10,
		"desc": "Usalo su un portale non ancora attraversato: il mondo avrà la sfida «Vita fragile»."},
	"sigillo_sfida_senza_ritorno": {"name": "Sigillo di sfida: Senza ritorno", "kind": "sfida", "icon": ["tavoletta", "tizzonite"],
		"stack": 10, "desc": "Usalo su un portale non ancora attraversato: il mondo avrà la sfida «Senza ritorno»."},
	"medaglia_buio": {"name": "Medaglia del buio", "kind": "accessorio", "icon": ["amuleto", "vuotite"], "stack": 1,
		"acc": {"halo": 1.35}, "source": "la prima vittoria nella sfida «Senza torce»", "desc": "Hai attraversato un mondo senza accendere una torcia."},
	"medaglia_tempo": {"name": "Medaglia del tempo", "kind": "accessorio", "icon": ["amuleto", "ambra"], "stack": 1,
		"acc": {"run": 1.08, "atk_speed": 1.05}, "source": "la prima vittoria nella sfida «Contro il tempo»", "desc": "Più svelto, sempre."},
	"medaglia_avvizzimento": {"name": "Medaglia della cura", "kind": "accessorio", "icon": ["amuleto", "muschio"], "stack": 1,
		"acc": {"regen": 1.25}, "source": "la prima vittoria nella sfida «L'Avvizzimento avanza»", "desc": "Hai tenuto testa all'Avvizzimento."},
	"medaglia_antiche": {"name": "Medaglia delle stirpi", "kind": "accessorio", "icon": ["amuleto", "brillaluce"], "stack": 1,
		"acc": {"luck": 0.12}, "source": "la prima vittoria nella sfida «Solo antiche»", "desc": "Le creature antiche ti lasciano di più."},
	"medaglia_fragile": {"name": "Medaglia del filo", "kind": "accessorio", "icon": ["amuleto", "sanguinella"], "stack": 1,
		"acc": {"damage": 1.08}, "source": "la prima vittoria nella sfida «Vita fragile»", "desc": "Chi ha vissuto su un filo colpisce meglio."},
	"medaglia_ritorno": {"name": "Medaglia dell'intero", "kind": "accessorio", "icon": ["amuleto", "tizzonite"], "stack": 1,
		"acc": {"fall_safe": true, "regen": 1.1}, "source": "la prima vittoria nella sfida «Senza ritorno»", "desc": "Non sei mai caduto."},
}

const RECIPES := [
	{"out": "sigillo_sfida_buio", "qty": 1, "in": {"lumino": 25, "cristallo_linfa": 3}, "station": "maglio"},
	{"out": "sigillo_sfida_tempo", "qty": 1, "in": {"lumino": 25, "cristallo_linfa": 3}, "station": "maglio"},
	{"out": "sigillo_sfida_avvizzimento", "qty": 1, "in": {"lumino": 25, "cristallo_linfa": 3}, "station": "maglio"},
	{"out": "sigillo_sfida_antiche", "qty": 1, "in": {"lumino": 25, "cristallo_linfa": 3}, "station": "maglio"},
	{"out": "sigillo_sfida_fragile", "qty": 1, "in": {"lumino": 25, "cristallo_linfa": 3}, "station": "maglio"},
	{"out": "sigillo_sfida_senza_ritorno", "qty": 1, "in": {"lumino": 25, "cristallo_linfa": 3}, "station": "maglio"},
]


static func of_item(id: String) -> String:
	return id.trim_prefix("sigillo_sfida_") if id.begins_with("sigillo_sfida_") else ""


## Il tempo della sfida «Contro il tempo» al livello n.
static func limit(n: int) -> float:
	var d: Dictionary = LIST["tempo"]
	return maxf(float(d["limit"]) - float(d["limit_step"]) * (n - 1), float(d["limit_min"]))
