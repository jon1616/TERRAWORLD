class_name AwakenData
## Il risveglio dell'equipaggiamento (voce 355, Roadmap 37, 4 ott 2026). L'utente, dopo sei ore: «ci sono molte armi ed
## equipaggiamenti, ma la differenza di forza e di bonus che offrono è poca: il sistema è un po' piatto». Due armi dello
## stesso grado si usavano allo stesso modo, e i bonus erano piccoli (+3%, +5%). Ora al Maglio ogni arma, armatura e
## mantello si può **risvegliare** una volta, con i materiali del profondo (voce 354): prende un **modo suo**, uguale per
## la sua forma, che cambia come si combatte (la spada lancia onde, la lancia trafigge chi sta dietro, il martello fa
## tremare la terra…), più forza (`DAMAGE`, `DEFENSE`). Il modo è un effetto di `EffectsData` (id «ris_…»), letto da
## `Effects` dalla casella ("dati.risveglio").
## Il costo cresce con il grado del materiale dell'oggetto: un'arma di radicite si risveglia con il Midollo del
## Sottobosco, una di vuotite forgiata con i Frammenti del Fondo. **Una forma nuova = una riga in `FORM`.**

## forma (o tipo dell'oggetto, se non ha forma) → effetto
const FORM := {
	"spada": "ris_onda", "pugnale": "ris_sangue", "spadone": "ris_schianto", "lancia": "ris_trafigge",
	"martello": "ris_scossa", "falcione": "ris_mietitura", "frusta": "ris_strappo", "arco": "ris_divide",
	"balestra": "ris_divide", "verga": "ris_eco", "bastone": "ris_eco",
	"elmo": "ris_vigile", "corazza": "ris_rovo", "gambali": "ris_fuga", "guanti": "ris_presa", "stivali": "ris_slancio",
	"mantello": "ris_nebbia",
}
const DAMAGE := 1.12                   # un'arma risvegliata colpisce il 12% più forte
const DEFENSE := 2                     # un pezzo d'armatura risvegliato dà 2 di Scorza in più

## Il materiale del profondo secondo il grado del materiale dell'oggetto (1 radicite … 6 stellare), e quanti ne servono.
const DEEP := {1: "midollo_radice", 2: "midollo_radice", 3: "cuore_ardesia", 4: "linfa_nera", 5: "frammento_vuoto", 6: "frammento_vuoto"}
const DEEP_N := 6
const EXTRA := {"linfa_antica": 1}


## La forma di un oggetto: il suo campo "form", o il tipo.
static func form_of(id: String) -> String:
	var it := ItemsData.get_item(id)
	return String(it.get("form", it.get("kind", "")))


static func effect_of(id: String) -> String:
	return String(FORM.get(form_of(id), ""))


## Il costo per risvegliare un oggetto: {oggetto: quanti}.
static func cost_of(id: String) -> Dictionary:
	var it := ItemsData.get_item(id)
	var tier := 2
	if it.has("mat"):
		tier = int(MaterialsData.get_mat(String(it["mat"])).get("tier", 2))
	var out := {String(DEEP[clampi(tier, 1, 6)]): DEEP_N}
	out.merge(EXTRA)
	return out
