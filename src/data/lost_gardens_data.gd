class_name LostGardensData
extends RefCounted
## I Giardini perduti (Roadmap 21 «Le radici del cosmo», l'Atto II della storia). Solo dati; le regole in `LostGardens`,
## il luogo in `PassPerduto`. Ogni Giardino è un mondo che nasce da un **Seme del cosmo** (lo dona l'Albero-Madre
## all'inizio del suo capitolo): i geni del mondo, il vigore, il suo Albero perduto (una stazione malata che guarisce)
## e le **tre cure** di un pilastro. Guarito, l'Albero perduto dona (`gifts`) e l'Albero-Madre può crescere.
##   cures: [id, testo, come si fa (per la scheda), che cosa la compie]. Il compimento lo scrive `LostGardens`:
##     {"fish": [pesce, quanti]}           pesci pescati in quel mondo (li conta la pesca)
##     {"item": [oggetto, quanti]}         oggetti portati all'Albero perduto (clic destro)
##     {"power": pulsi}                    una rete viva con almeno tanti pulsi che tocca l'Albero
##     {"tame": famiglia}                  una creatura di quella famiglia nella mandria
##     {"words": quante}                   parole della lingua nera diventate certe in quel mondo
##     {"boss": creatura}                  il Custode del Giardino sconfitto

const ORDER := ["sommerso", "ferro", "selvatico", "muto"]

const GARDENS := {
	"sommerso": {"name": "Il Giardino sommerso", "pillar": "pesca", "vigore": 4, "color": Color("#6ad0ff"),
		"geni": ["sporangio", "sommerso", "laghi_linfa"], "seed": "seme_cosmo_sommerso", "tree": "albero_sommerso",
		"desc": "un Giardino che il mare ha coperto: il suo Albero respira sotto un lago",
		"cures": [
			["pesci", "Pesca tre Carpe della radice", "vivono solo nel lago dell'Albero sommerso", {"fish": ["pesce_carpa_radice", 3]}],
			["acqua", "Portagli dieci Gocce d'acqua viva", "le lascia chi vive nel lago (e la pesca di notte)", {"item": ["goccia_acqua_viva", 10]}],
			["custode", "Sconfiggi la Madre delle maree", "il Custode del Giardino, nella grotta sotto il lago", {"boss": "madre_maree"}],
		],
		"gifts": {"items": {"linfa_antica": 3, "amo_radice_cosmo": 1}}},
	"ferro": {"name": "Il Giardino di ferro", "pillar": "rete", "vigore": 5, "color": Color("#ffc050"),
		"geni": ["resina", "vene_mondo", "rovine_fitte", "cavo"], "seed": "seme_cosmo_ferro", "tree": "albero_ferro",
		"desc": "i Seminatori lo fusero con le loro macchine; ora la Linfa non scorre più",
		"cures": [
			["pulsi", "Dagli centocinquanta pulsi", "una rete viva che tocchi l'Albero di ferro con una vena", {"power": 150}],
			["ingranaggi", "Portagli otto Ingranaggi di radice", "li lasciano le macchine selvatiche del Giardino", {"item": ["ingranaggio_radice", 8]}],
			["custode", "Sconfiggi il Telaio vivo", "il Custode del Giardino, nella sala delle macchine", {"boss": "telaio_vivo"}],
		],
		"gifts": {"items": {"linfa_antica": 3, "cuore_ingranaggio": 1}}},
	"selvatico": {"name": "Il Giardino selvatico", "pillar": "mandria", "vigore": 6, "color": Color("#8ef070"),
		"geni": ["lanterna", "rigoglioso", "fertile", "radici_giganti"], "seed": "seme_cosmo_selvatico", "tree": "albero_selvatico",
		"desc": "tutto è cresciuto senza nessuno: le bestie non ricordano più il Giardiniere",
		"cures": [
			["bestia", "Addomestica un Cervo di rovo", "vivono attorno all'Albero selvatico; mangiano bacche di rovo", {"tame": "cervi_rovo"}],
			["seme", "Portagli dodici Bacche di rovo", "i rovi della radura (e l'orto, se le semini)", {"item": ["bacca_rovo", 12]}],
			["custode", "Sconfiggi il Re dei rovi", "il Custode del Giardino, nel cuore della radura", {"boss": "re_rovi"}],
		],
		"gifts": {"items": {"linfa_antica": 3, "corno_selvatico": 1}}},
	"muto": {"name": "Il Giardino muto", "pillar": "misteri", "vigore": 7, "color": Color("#c090ff"),
		"geni": ["brina", "eco_seminatori", "notti_lunghe", "fungaie"], "seed": "seme_cosmo_muto", "tree": "albero_muto",
		"desc": "il suo Albero ha dimenticato le parole: attorno, un cerchio di stele che nessuno legge",
		"cures": [
			["parole", "Ritrova otto parole nel Giardino muto", "le stele del cerchio attorno all'Albero (Quaderno, tasto U)", {"words": 8}],
			["eco", "Portagli sei Eco di parola", "le lasciano le ombre che vagano nel cerchio", {"item": ["eco_parola", 6]}],
			["custode", "Sconfiggi il Silenzio", "il Custode del Giardino, sotto il cerchio di stele", {"boss": "silenzio"}],
		],
		"gifts": {"items": {"linfa_antica": 3, "voce_ritrovata": 1}}},
}

## I Semi del cosmo (oggetti; i loro dati sono il genoma del Giardino con "perduto").
const ITEMS := {
	"seme_cosmo_sommerso": {"name": "Seme del cosmo: il Giardino sommerso", "kind": "seme_mondo", "icon": ["seme", "lagunite"], "stack": 1, "source": "dono dell'Albero-Madre (Atto II)",
		"desc": "Un Seme che l'Albero-Madre ha trovato in una sua radice: piantato in un'Aiuola apre la strada al Giardino sommerso."},
	"seme_cosmo_ferro": {"name": "Seme del cosmo: il Giardino di ferro", "kind": "seme_mondo", "icon": ["seme", "ambra"], "stack": 1, "source": "dono dell'Albero-Madre (Atto II)",
		"desc": "Un Seme che l'Albero-Madre ha trovato in una sua radice: piantato in un'Aiuola apre la strada al Giardino di ferro."},
	"seme_cosmo_selvatico": {"name": "Seme del cosmo: il Giardino selvatico", "kind": "seme_mondo", "icon": ["seme", "muschio"], "stack": 1, "source": "dono dell'Albero-Madre (Atto II)",
		"desc": "Un Seme che l'Albero-Madre ha trovato in una sua radice: piantato in un'Aiuola apre la strada al Giardino selvatico."},
	"seme_cosmo_muto": {"name": "Seme del cosmo: il Giardino muto", "kind": "seme_mondo", "icon": ["seme", "iride"], "stack": 1, "source": "dono dell'Albero-Madre (Atto II)",
		"desc": "Un Seme che l'Albero-Madre ha trovato in una sua radice: piantato in un'Aiuola apre la strada al Giardino muto."},
}


## Il genoma del Seme del cosmo di un Giardino.
static func genome(id: String) -> Dictionary:
	var g: Dictionary = GARDENS[id]
	return {"geni": (g["geni"] as Array).duplicate(), "vigore": int(g["vigore"]), "perduto": id}


static func name_of(id: String) -> String:
	return String(GARDENS.get(id, {}).get("name", ""))


## Gli Alberi perduti come stazioni: «albero_<giardino>» malato e «albero_<giardino>_vivo» guarito (li unisce
## `StationsData`); non si riprendono.
static func stations() -> Dictionary:
	var out := {}
	for id in GARDENS:
		var g: Dictionary = GARDENS[id]
		out["albero_" + id] = {"name": "L'Albero del " + String(g["name"]).trim_prefix("Il "), "size": [9, 13], "item": "", "fixed": true}
		out["albero_%s_vivo" % id] = {"name": "L'Albero del " + String(g["name"]).trim_prefix("Il "), "size": [9, 13], "item": "",
			"fixed": true, "light": true, "light_color": (g["color"] as Color).lightened(0.2)}
	return out


## Il Giardino di una stazione «albero_…» ("" se non è un Albero perduto) e se è guarito.
static func tree_of(station: String) -> Array:
	for id in GARDENS:
		if station == "albero_" + id:
			return [id, false]
		if station == "albero_%s_vivo" % id:
			return [id, true]
	return ["", false]
