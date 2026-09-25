class_name GuardiansData
extends RefCounted
## I Guardiani dei Cuori (voce 19): ogni mondo ha il suo, secondo il vigore del Seme da cui è nato. Il primo mondo il
## Nodo Avvizzito, poi la Regina delle Spore, poi il Colosso d'Ardesia; oltre si ricomincia, sempre più forti
## (`Portal.vigor_mult`). Sconfitto lascia il suo materiale (bottino della creatura), curato ne lascia un altro
## (`cure`); entrambi aprono lo stesso grado di equipaggiamento. Solo dati.
##
## Campi: creature (id di `CreaturesData`), cure {oggetto: quantità} dal Guardiano curato, pages (pagine di `LoreData`
## per sconfitto e curato), color (della scritta al risveglio), wake (frase del risveglio).

const LIST := [
	{"id": "nodo", "creature": "guardiano_nodo", "cure": {"linfa_guardiano": 30},
		"pages": {"sconfitto": "guardiano_sconfitto", "curato": "guardiano_curato"}, "color": "#d8b070",
		"wake": "Il Guardiano del Cuore si risveglia"},
	{"id": "regina", "creature": "regina_spore", "cure": {"polline_regina": 30},
		"pages": {"sconfitto": "regina_sconfitta", "curato": "regina_curata"}, "color": "#c08aff",
		"wake": "Lo sciame si alza: la Regina difende il suo Cuore"},
	{"id": "colosso", "creature": "colosso_ardesia", "cure": {"pietra_battente": 30},
		"pages": {"sconfitto": "colosso_sconfitto", "curato": "colosso_curato"}, "color": "#8298bc",
		"wake": "La montagna si muove: il Colosso si risveglia"},
]


## Il Guardiano di un mondo con quel vigore (1 = il primo mondo).
static func for_vigor(v: int) -> Dictionary:
	return LIST[posmod(v - 1, LIST.size())]
