class_name CuriositiesData
extends RefCounted
## Le curiosità degli strati (Roadmap 30, voce 304): piccoli ritrovamenti unici, sei per strato, da mettere nel Museo
## (una sala per serie, `MuseumData.HALLS`, con il suo premio per sempre). Da dove vengono:
##   - i baccelli dormienti del loro strato, una volta su `POD_CHANCE` (quelle che non hai ancora trovato più spesso);
##   - gli zaini perduti e le tane (`PassIncontri`), una volta su `CHEST_CHANCE`;
##   - in superficie anche le piante, una volta su `PLANT_CHANCE`.
## Chi ne trova una la vede annunciata (`Harvest`), e il conteggio «curiosita» nutre i misteri.

const POD_CHANCE := 0.035
const CHEST_CHANCE := 0.4
const PLANT_CHANCE := 0.004

const SERIES := [
	{"hall": "cur_prati", "name": "Curiosità dei prati", "bonus": {"jump": 1.03}, "items": [
		["cur_chiocciola", "Chiocciola vuota", "guscio", "Una chiocciola bianca, vuota da chissà quanto: dentro si sente il vento."],
		["cur_piuma_vento", "Piuma di vento", "penna", "Una piuma che non cade mai dritta."],
		["cur_ghianda_ambra", "Ghianda d'ambra", "seme", "Una ghianda chiusa in una goccia d'ambra, come un ricordo."],
		["cur_sasso_bucato", "Sasso bucato", "minerale", "Guardandoci attraverso, dicono, si vedono i Seminatori."],
		["cur_fiore_pressato", "Fiore pressato", "pappo", "Qualcuno l'ha seccato tra due pagine, tanto tempo fa."],
		["cur_moneta_viandante", "Moneta del viandante", "lumino", "Una moneta di un paese che non c'è più."]]},
	{"hall": "cur_radici", "name": "Curiosità delle radici", "bonus": {"regen": 1.05}, "items": [
		["cur_nodo_parlante", "Nodo di radice parlante", "radice_viaggio", "Se lo avvicini all'orecchio, mormora."],
		["cur_bacca_fossile", "Bacca fossile", "seme", "Una bacca diventata pietra, ancora rossa dentro."],
		["cur_ciondolo_legno", "Ciondolo di legno", "collana", "Intagliato a mano: un Germogliato che sorride."],
		["cur_dente_talpa", "Dente di talpa gigante", "aculeo", "Lungo come un dito: meglio non chiedersi di chi fosse."],
		["cur_semi_intrecciati", "Semi intrecciati", "seme", "Una collana di semi di dieci alberi diversi."],
		["cur_lucciola_ambra", "Lucciola nell'ambra", "goccia", "Brilla ancora, dopo mille anni."]]},
	{"hall": "cur_ardesia", "name": "Curiosità dell'ardesia", "bonus": {"dig": 1.05}, "items": [
		["cur_ammonite", "Ammonite d'ardesia", "guscio", "Una spirale perfetta, di quando qui c'era un mare."],
		["cur_punta_antica", "Punta di freccia antica", "freccia", "Selce scheggiata: qualcuno cacciava qui, prima dei Seminatori?"],
		["cur_dado_pietra", "Dado di pietra", "gemma", "Sei facce, sei segni della lingua comune."],
		["cur_specchio_mica", "Specchietto di mica", "specchio", "Rimanda la luce di una torcia che non c'è."],
		["cur_osso_inciso", "Osso inciso", "artiglio", "Qualcuno ci ha contato i giorni: trecentoventi tacche."],
		["cur_cristallo_gemello", "Cristallo gemello", "cristallo", "Due cristalli cresciuti abbracciati."]]},
	{"hall": "cur_linfa", "name": "Curiosità della Linfa", "bonus": {"linfa_regen": 1.05}, "items": [
		["cur_goccia_pietra", "Goccia pietrificata", "goccia", "Linfa diventata pietra mentre cadeva."],
		["cur_perla_linfa", "Perla di Linfa", "gemma", "Nata in un lago sotterraneo, tiepida al tatto."],
		["cur_conchiglia_lago", "Conchiglia di lago", "guscio", "Viene da un lago che nessuno ha mai visto."],
		["cur_scaglia_canto", "Scaglia che canta", "scaglia", "Vibra piano quando c'è Linfa vicino."],
		["cur_bottone_seminatori", "Bottone dei Seminatori", "lumino", "Anche i Seminatori perdevano i bottoni."],
		["cur_idolo", "Piccolo idolo", "altare", "Una figurina con le braccia a forma di radici."]]},
	{"hall": "cur_vuoto", "name": "Curiosità del Vuoto", "bonus": {"luck": 0.05}, "items": [
		["cur_sasso_galleggia", "Sasso che galleggia", "minerale", "Lascialo andare: resta lì, a mezz'aria."],
		["cur_chiave_senza_porta", "Chiave senza porta", "chiave", "Apre qualcosa, da qualche parte, in qualche mondo."],
		["cur_clessidra", "Clessidra vuota", "vetro", "La sabbia è finita. Il tempo no."],
		["cur_eco", "Eco imprigionata", "sacca", "Scuotila: ripete l'ultima parola che hai detto."],
		["cur_stella_nera", "Stella nera", "stella", "Una stella che invece di brillare assorbe la luce."],
		["cur_seme_vuoto", "Seme del Vuoto", "seme", "Un seme leggerissimo: forse non è mai stato piantato."]]},
]


static func items() -> Dictionary:
	var out := {}
	var mats := ["seta", "radice", "ardesia", "linfa", "vuotite"]
	for k in SERIES.size():
		for e in SERIES[k]["items"]:
			out[e[0]] = {"name": e[1], "kind": "curiosita", "icon": [e[2], mats[k]], "stack": 20, "curiosita": true,
				"desc": "%s Una curiosità: nel Museo del Giardino, con le altre della serie «%s»." % [e[3], SERIES[k]["name"]]}
	return out


## Gli id delle curiosità di uno strato.
static func of_stratum(s: int) -> Array:
	return (SERIES[clampi(s, 0, SERIES.size() - 1)]["items"] as Array).map(func(e: Array) -> String: return String(e[0]))


## Una curiosità dello strato: quelle in `known` (già trovate) escono quattro volte meno.
static func pick(s: int, rng: RandomNumberGenerator, known := {}) -> String:
	var ids := of_stratum(s)
	var tot := 0
	for id in ids:
		tot += 1 if known.has(id) else 4
	var r := rng.randi_range(1, tot)
	for id in ids:
		r -= 1 if known.has(id) else 4
		if r <= 0:
			return String(id)
	return String(ids[0])


static func count_all() -> int:
	return SERIES.size() * 6
