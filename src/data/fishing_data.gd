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

const ITEMS := {
	"canna_radice": {"name": "Canna di radice", "kind": "canna", "icon": ["canna", "legno"], "stack": 1, "tier": 0,
		"fish": 0.0, "fish_speed": 1.15, "fish_liq": [0],
		"desc": "Un ramo di radice flessibile e un filo di gelatina: pesca nell'acqua. Clic su uno specchio d'acqua: la lenza parte, e quando un pesce abbocca sale da solo."},
}

const RECIPES := [
	{"out": "canna_radice", "qty": 1, "in": {"legno": 10, "gelatina": 3}, "station": "ceppo"},
]


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
