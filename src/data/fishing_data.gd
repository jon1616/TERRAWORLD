class_name FishingData
extends RefCounted
## Gli attrezzi della pesca (voce 121, Roadmap 14 «Le acque vive»). Le canne di metallo nascono dalla forma «canna» di
## `FormsData` × i materiali (`MaterialsData`): qui c'è la prima, di legno, per cominciare senza metallo, e le regole
## che dal materiale fanno i valori della canna.
##
## Valori di una canna (oggetto di tipo «canna»):
##   fish        la fortuna di pesca: alza la probabilità dei pesci più rari (`FishData.LUCK_BOOST`)
##   fish_speed  quanto dura l'attesa prima che un pesce abbocchi (× l'attesa di base; più basso = più svelto)
##   fish_liq    i liquidi in cui pesca: 0 acqua, 1 Linfa, 2 brace (`LiquidsData`)

## Voce 122: le esche (tipo «esca», campo `bait`: luck = fortuna in più, wait = × l'attesa). A ogni pesce preso si
## consuma la migliore che si ha nella Bisaccia; senza esche si pesca lo stesso, solo più piano e con meno fortuna.
## Gli accessori della pesca (campo `acc`, sommati da `GearEffects`): fish_luck (+ fortuna), fish_wait (× attesa),
## fish_size (taglie più grandi), fish_double (probabilità di due pesci), fish_any (la lenza regge ogni liquido).
const ITEMS := {
	"esca_humus": {"name": "Pallottola d'humus", "kind": "esca", "icon": ["gel", "humus"], "stack": 99,
		"bait": {"luck": 0.1, "wait": 0.9}, "desc": "Terra impastata con la gelatina: i pesci la annusano da lontano."},
	"esca_petali": {"name": "Esca di petali di lume", "kind": "esca", "icon": ["gel", "lucciola"], "stack": 99,
		"bait": {"luck": 0.25, "wait": 0.85}, "desc": "Brilla appena sotto il pelo dell'acqua: di notte non le resiste nessuno."},
	"esca_squama": {"name": "Esca di squama", "kind": "esca", "icon": ["gel", "cristallo"], "stack": 99,
		"bait": {"luck": 0.45, "wait": 0.8}, "desc": "Squame di lume sminuzzate nella Linfa: attira i pesci più grossi."},
	"esca_iridata": {"name": "Esca iridata", "kind": "esca", "icon": ["gel", "iride"], "stack": 99,
		"bait": {"luck": 0.9, "wait": 0.75}, "desc": "Cambia colore nell'acqua: i pesci rari la seguono ovunque."},
	"galleggiante_lume": {"name": "Galleggiante di lume", "kind": "accessorio", "icon": ["goccia", "lucciola"], "stack": 1,
		"acc": {"fish_wait": 0.8}, "desc": "Un galleggiante che brilla: i pesci arrivano prima a guardarlo (attesa −20%)."},
	"amo_ambra": {"name": "Amo d'ambra", "kind": "accessorio", "icon": ["aculeo", "ambra"], "stack": 1,
		"acc": {"fish_luck": 0.3}, "desc": "Un amo d'ambra dorata: i pesci rari abboccano più volentieri (fortuna di pesca +30%)."},
	"sacca_pescatore": {"name": "Sacca del pescatore", "kind": "accessorio", "icon": ["membrana", "seta"], "stack": 1,
		"acc": {"fish_size": 0.15, "fish_double": 0.1}, "desc": "Una sacca di seta sempre umida: pesci più grandi, e a volte due in una volta."},
	"canna_radice": {"name": "Canna di radice", "kind": "canna", "icon": ["canna", "legno"], "stack": 1, "tier": 0,
		"fish": 0.0, "fish_speed": 1.15, "fish_liq": [0],
		"desc": "Un ramo di radice flessibile e un filo di gelatina: pesca nell'acqua. Clic su uno specchio d'acqua: la lenza parte, e quando un pesce abbocca sale da solo."},
}

const RECIPES := [
	{"out": "canna_radice", "qty": 1, "in": {"legno": 10, "gelatina": 3}, "station": "ceppo"},
	{"out": "esca_humus", "qty": 5, "in": {"humus": 3, "gelatina": 1}, "station": ""},
	{"out": "esca_petali", "qty": 5, "in": {"petali_lume": 2, "gelatina": 1}, "station": ""},
	{"out": "esca_squama", "qty": 5, "in": {"squama_lume": 1, "gelatina": 2}, "station": "ceppo"},
	{"out": "esca_iridata", "qty": 5, "in": {"polvere_iridata": 1, "gelatina": 2}, "station": "maglio"},
	{"out": "galleggiante_lume", "qty": 1, "in": {"squama_lume": 4, "legno": 2}, "station": "telaio"},
	{"out": "amo_ambra", "qty": 1, "in": {"lingotto_ambra": 2, "squama_lume": 2}, "station": "maglio"},
	{"out": "sacca_pescatore", "qty": 1, "in": {"seta_radice": 6, "gelatina": 4}, "station": "telaio"},
]

## Voce 122: il tempo. L'attesa si accorcia con la pioggia, i temporali, la nebbia, di notte e all'alba e al tramonto.
const WEATHER_WAIT := {"pioggia": 0.8, "temporale": 0.7, "nebbia": 0.9, "bufera": 1.2}
const NIGHT_WAIT := 0.9
const TWILIGHT_WAIT := 0.75                # quando la luce del giorno sale o scende


## I valori della forma «canna» di un materiale (chiamato da `FormsData.stats`): la fortuna cresce con il grado e con la
## risonanza; l'attesa cala con il grado; la Linfa vuole un materiale di Linfa o di luce (o che la conduca molto), la
## brace un materiale di brace o di grado 5 e oltre.
static func rod_stats(md: Dictionary) -> Dictionary:
	var tier := int(md.get("tier", 1))
	var el := String(md.get("elemento", ""))
	var liq := [0]
	if el.contains("linfa") or el.contains("luce") or int(md.get("conduzione", 0)) >= 12:
		liq.append(1)
	if el.contains("brace") or tier >= 5:
		liq.append(2)
	return {"fish": snappedf(0.15 * tier + 0.1 * int(md.get("risonanza", 0)), 0.01),
		"fish_speed": snappedf(maxf(1.0 - 0.07 * tier, 0.5), 0.01), "fish_liq": liq}


## I liquidi di una canna, in parole: «acqua, Linfa».
static func liquids_text(liq: Array) -> String:
	var out := []
	for t in liq:
		out.append(String(LiquidsData.TYPES[int(t)]["name"]).to_lower())
	return ", ".join(out)


## Il tempo, in parole, quando aiuta (per l'avviso del lancio): «pioggia, alba».
static func weather_wait(weather: String, night: bool, twilight: bool) -> float:
	var k := float(WEATHER_WAIT.get(weather, 1.0))
	if twilight:
		k *= TWILIGHT_WAIT
	elif night:
		k *= NIGHT_WAIT
	return k


## La migliore esca di una Bisaccia (la più fortunata): l'indice della casella, o -1.
static func best_bait(b: Bisaccia) -> int:
	var best := -1
	var bl := -1.0
	for i in b.slots.size():
		var id := b.id_at(i)
		if id == "":
			continue
		var bt: Dictionary = ItemsData.get_item(id).get("bait", {})
		if not bt.is_empty() and float(bt["luck"]) > bl:
			bl = float(bt["luck"])
			best = i
	return best

