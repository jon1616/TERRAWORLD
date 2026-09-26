class_name SignaturesData
extends RefCounted
## Le firme dei mondi (voce 44, regola d'oro del piano: ogni mondo ha almeno una cosa che si trova solo lì). Solo
## dati; il luogo lo costruisce `PassFirma`, il ritrovamento lo segue `Signature`.
## Ogni mondo ne ha una, scelta dal suo seme e dai suoi geni (`likes`: i geni che la rendono più probabile, ×4).
## Voce 48: `gene` = il gene raro che la Provetta preleva vicino alla firma (si ottiene solo lì).
## Dentro c'è uno **scrigno della firma** con un bottino ricco, la Linfa antica per gli innesti e il **ricordo** del
## luogo (un oggetto da collezione che esiste solo lì).
##   where   "superficie", "cielo" o uno strato (1-4)
##   ricordo l'oggetto ricordo (in `ITEMS`)

const SIGNATURES := {
	"albero_colossale": {"name": "l'Albero colossale", "where": "superficie", "likes": ["rigoglioso", "lanterna"],
		"desc": "un albero-lanterna alto come una montagna, con uno scrigno tra i rami", "ricordo": "ricordo_albero", "gene": "radice_madre"},
	"cratere_stelle": {"name": "il Cratere delle stelle", "where": "superficie", "likes": ["stellato", "pianure"],
		"desc": "il cratere lasciato da una stella caduta, che ancora brilla", "ricordo": "ricordo_cratere", "gene": "cuore_stellare"},
	"foresta_pietrificata": {"name": "la Foresta pietrificata", "where": "superficie", "likes": ["spoglio", "cenere", "resina"],
		"desc": "un bosco di alberi diventati pietra", "ricordo": "ricordo_foresta", "gene": "eco_seminatori"},
	"pozzo_senza_fondo": {"name": "il Pozzo senza fondo", "where": "superficie", "likes": ["voragini", "altopiano"],
		"desc": "un pozzo dei Seminatori che scende dritto fino al Fondo", "ricordo": "ricordo_pozzo", "gene": "eco_seminatori"},
	"arco_radici": {"name": "l'Arco di radici", "where": "cielo", "likes": ["radici_giganti", "montagne"],
		"desc": "una radice del cosmo che si inarca sopra il mondo", "ricordo": "ricordo_arco", "gene": "radice_madre"},
	"isola_sospesa": {"name": "l'Isola sospesa", "where": "cielo", "likes": ["conca", "brina"],
		"desc": "un'isola di terra e alberi che galleggia nel cielo", "ricordo": "ricordo_isola", "gene": "cuore_stellare"},
	"grotta_lucciole": {"name": "la Grotta delle lucciole", "where": 1, "likes": ["fungaie", "sporangio"],
		"desc": "una grotta illuminata da migliaia di funghi e campanule", "ricordo": "ricordo_lucciole", "gene": "radice_madre"},
	"cuore_radice": {"name": "il Nodo delle radici", "where": 1, "likes": ["radici_giganti", "compatto"],
		"desc": "un groviglio enorme di radici antiche, cavo nel mezzo", "ricordo": "ricordo_nodo", "gene": "radice_madre"},
	"serra_sepolta": {"name": "la Serra sepolta", "where": 2, "likes": ["rovine_fitte", "rovine_sepolte", "fertile"],
		"desc": "la serra dei Seminatori, sepolta e intatta", "ricordo": "ricordo_serra", "gene": "eco_seminatori"},
	"colonne_ambra": {"name": "la Sala delle colonne d'ambra", "where": 2, "likes": ["resina", "metalli_nobili"],
		"desc": "una caverna sorretta da colonne d'ambra fossile", "ricordo": "ricordo_colonne", "gene": "eco_seminatori"},
	"alveare_cristallo": {"name": "l'Alveare di cristallo", "where": 3, "likes": ["alveare", "cristalli_giganti", "laghi_linfa"],
		"desc": "celle di cristallo di Linfa, una dentro l'altra", "ricordo": "ricordo_alveare", "gene": "cuore_stellare"},
	"bolla_vuoto": {"name": "la Bolla del Vuoto", "where": 4, "likes": ["abissale", "notti_lunghe"],
		"desc": "una bolla perfettamente tonda nel Fondo, dove il Vuoto trattiene il respiro", "ricordo": "ricordo_bolla", "gene": "cuore_stellare"},
}

## I ricordi: oggetti da collezione, uno per firma (uniti in `ItemsData.all()`), e la Linfa antica degli innesti.
const ITEMS := {
	"linfa_antica": {"name": "Linfa antica", "kind": "materiale", "icon": ["goccia", "linfa"], "stack": 99,
		"desc": "Linfa dei primi giorni del mondo, densa e dorata. Serve agli innesti dei Semi di mondo (una per innesto, al Banco dell'Innestatrice)."},
	"ricordo_albero": {"name": "Foglia dell'Albero colossale", "kind": "ricordo", "icon": ["foglia", "linfa"], "stack": 1,
		"desc": "Una foglia grande come uno scudo, caduta dall'Albero colossale. Esiste solo in un mondo."},
	"ricordo_cratere": {"name": "Scheggia di stella", "kind": "ricordo", "icon": ["gemma", "brillaluce"], "stack": 1,
		"desc": "Un frammento della stella del Cratere, ancora tiepido. Esiste solo in un mondo."},
	"ricordo_foresta": {"name": "Pigna di pietra", "kind": "ricordo", "icon": ["seme", "ardesia"], "stack": 1,
		"desc": "Una pigna della Foresta pietrificata, pesante come un sasso. Esiste solo in un mondo."},
	"ricordo_pozzo": {"name": "Eco del Pozzo", "kind": "ricordo", "icon": ["goccia", "vuotite"], "stack": 1,
		"desc": "Una goccia che contiene il suono del Pozzo senza fondo. Esiste solo in un mondo."},
	"ricordo_arco": {"name": "Scorza dell'Arco", "kind": "ricordo", "icon": ["scaglia", "radice"], "stack": 1,
		"desc": "Un pezzo di corteccia della radice del cosmo. Esiste solo in un mondo."},
	"ricordo_isola": {"name": "Zolla sospesa", "kind": "ricordo", "icon": ["gemma", "muschio"], "stack": 1,
		"desc": "Una zolla che non vuole cadere. Esiste solo in un mondo."},
	"ricordo_lucciole": {"name": "Lanterna di lucciole", "kind": "ricordo", "icon": ["goccia", "lucciola"], "stack": 1,
		"desc": "Lucciole che non se ne vanno mai. Esiste solo in un mondo."},
	"ricordo_nodo": {"name": "Cuore di radice", "kind": "ricordo", "icon": ["seme", "radice"], "stack": 1,
		"desc": "Il nocciolo del Nodo delle radici, che batte piano. Esiste solo in un mondo."},
	"ricordo_serra": {"name": "Vaso dei Seminatori", "kind": "ricordo", "icon": ["goccia", "ambra"], "stack": 1,
		"desc": "Un vaso della Serra sepolta, con la terra ancora umida. Esiste solo in un mondo."},
	"ricordo_colonne": {"name": "Capitello d'ambra", "kind": "ricordo", "icon": ["gemma", "ambra"], "stack": 1,
		"desc": "La cima di una colonna d'ambra fossile. Esiste solo in un mondo."},
	"ricordo_alveare": {"name": "Cella di cristallo", "kind": "ricordo", "icon": ["gemma", "cristallo"], "stack": 1,
		"desc": "Una cella dell'Alveare di cristallo, perfetta. Esiste solo in un mondo."},
	"ricordo_bolla": {"name": "Respiro del Vuoto", "kind": "ricordo", "icon": ["goccia", "vuotite"], "stack": 1,
		"desc": "Un po' del silenzio della Bolla, chiuso in una goccia. Esiste solo in un mondo."},
}


## La firma di un mondo, dal suo seme e dai suoi geni (sempre la stessa per lo stesso mondo).
static func choose(world_seed: int, genes: Array) -> String:
	var rng := RandomNumberGenerator.new()
	rng.seed = world_seed ^ 0x51C0
	var tot := 0
	var ws := {}
	for id in SIGNATURES:
		var w := 1
		for g in SIGNATURES[id]["likes"]:
			if g in genes:
				w = 4
		ws[id] = w
		tot += w
	var v := rng.randi_range(1, tot)
	for id in ws:
		v -= int(ws[id])
		if v <= 0:
			return id
	return String(SIGNATURES.keys()[0])
