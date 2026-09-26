class_name GenesData
extends RefCounted
## I geni dei Semi di mondo (voce 42, piano «Il Giardiniere dei mondi»). Solo dati; le regole (genoma a caso,
## effetti sommati, innesto) stanno in `Genome`.
##
## Un Seme porta un **genoma**: un gene di superficie (sempre) e alcuni geni di altre categorie, al più uno per
## categoria, più il vigore. Ogni categoria corrisponde a una parte del generatore o del mondo mentre si gioca.
##
## Campi di un gene:
##   cat     categoria (`CATEGORIES`)          name, desc   nome dell'universo e cosa fa, in breve
##   rar     rarità 0-3 (`RARITY`)             dom          dominanza 1-5: negli innesti vince più spesso
##   good    true = un dono, false = una prova (colore della scritta)
##   gen     effetti sul generatore            run          effetti mentre si gioca (chiavi in `DEFAULTS`)
##   item    (solo superficie) l'oggetto Seme che porta questo gene
##   vmin    vigore minimo perché compaia in un Seme trovato (i geni rari solo nei mondi più profondi)
##   only    come si ottiene se non a caso: "mutazione" (solo innestando), "firma" (solo dalla firma di un mondo)
##   combo   [a, b]: nasce per mutazione con probabilità alta quando i genitori portano a e b (voce 48)

const CATEGORIES := ["superficie", "forma", "grotte", "sottosuolo", "minerali", "gemme", "rovine", "fauna", "stirpi",
	"flora", "cielo", "tempo", "ombra"]

## Nome della categoria, colore, e dove la Provetta di Linfa trova i suoi geni (voce 46: `Sampling`).
const CAT_INFO := {
	"superficie": {"name": "Superficie", "color": "#8ef0d8", "where": "l'erba della superficie"},
	"forma": {"name": "Forma", "color": "#c8b890", "where": "la terra della superficie"},
	"grotte": {"name": "Grotte", "color": "#8aa8d8", "where": "l'aria delle grotte"},
	"sottosuolo": {"name": "Sottosuolo", "color": "#b89ae8", "where": "le rocce profonde"},
	"minerali": {"name": "Minerali", "color": "#e89a6a", "where": "le vene di minerale"},
	"gemme": {"name": "Gemme", "color": "#f07ab0", "where": "gemme e cristalli"},
	"rovine": {"name": "Rovine", "color": "#e8d27a", "where": "la pietra dei Seminatori"},
	"fauna": {"name": "Fauna", "color": "#d88a6a", "where": "le creature sconfitte"},
	"stirpi": {"name": "Stirpi", "color": "#ffd24a", "where": "le creature rare sconfitte"},
	"flora": {"name": "Flora", "color": "#7ad87a", "where": "alberi e piante"},
	"cielo": {"name": "Cielo", "color": "#9ad8ff", "where": "il cielo aperto"},
	"tempo": {"name": "Tempo", "color": "#a8a8e8", "where": "il cielo aperto"},
	"ombra": {"name": "Ombra", "color": "#a86a8a", "where": "la terra avvizzita"},
}

const RARITY := [
	{"name": "comune", "color": "#b8c8b0", "weight": 100},
	{"name": "robusto", "color": "#8ef0d8", "weight": 40},
	{"name": "antico", "color": "#f0c060", "weight": 12},
	{"name": "stellare", "color": "#d890ff", "weight": 3},
]

## Valori neutri degli effetti. Le chiavi in `MUL` si moltiplicano tra geni, le altre numeriche si sommano; gli array
## si uniscono, i dizionari si fondono, i vero/falso valgono se almeno un gene li accende.
const DEFAULTS := {
	"gen": {"ore": 0.0, "ruins": 1.0, "gems": 1.0},
	"run": {"danger": 0.0, "lumini": 1.0, "rare": 1.0, "grow": 1.0, "night": 0.0, "events": 1.0, "blight": 1.0},
}
const MUL := ["ruins", "gems", "lumini", "rare", "grow", "events", "blight"]

const GENES := {
	# --- superficie: i biomi (erano le specie della voce 39) -------------------------------------------------------
	"lanterna": {"cat": "superficie", "name": "Salice-lanterna", "rar": 0, "dom": 3, "good": true,
		"desc": "foreste di alberi-lanterna a perdita d'occhio", "item": "seme_mondo_lanterna",
		"gen": {"biomes": {"foresta": 6, "palude": 2, "ambra": 2}}},
	"sporangio": {"cat": "superficie", "name": "Sporangio", "rar": 0, "dom": 3, "good": true,
		"desc": "paludi di spore quasi ovunque", "item": "seme_mondo_sporangio",
		"gen": {"biomes": {"palude": 6, "foresta": 2, "ambra": 1}}},
	"resina": {"cat": "superficie", "name": "Resina", "rar": 0, "dom": 3, "good": true,
		"desc": "distese d'ambra, calde e aperte", "item": "seme_mondo_resina",
		"gen": {"biomes": {"ambra": 6, "foresta": 2, "palude": 1}}},
	"brina": {"cat": "superficie", "name": "Brina", "rar": 1, "dom": 2, "good": true,
		"desc": "boschi gelati e cieli chiari", "item": "seme_mondo_brina",
		"gen": {"biomes": {"brina": 6, "foresta": 2, "ambra": 1}}},
	"cenere": {"cat": "superficie", "name": "Cenere", "rar": 1, "dom": 2, "good": true,
		"desc": "pianure di cenere e braci", "item": "seme_mondo_cenere",
		"gen": {"biomes": {"cenere": 6, "ambra": 2, "palude": 1}}},
	# --- i tratti della voce 39, ora geni della loro categoria ----------------------------------------------------
	"vene_ricche": {"cat": "minerali", "name": "Vene ricche", "rar": 0, "dom": 3, "good": true,
		"desc": "minerali più abbondanti", "gen": {"ore": 0.035}},
	"rovine_fitte": {"cat": "rovine", "name": "Rovine fitte", "rar": 0, "dom": 3, "good": true,
		"desc": "molte più stanze dei Seminatori", "gen": {"ruins": 1.6}},
	"gemme_ricche": {"cat": "gemme", "name": "Gemme ricche", "rar": 0, "dom": 3, "good": true,
		"desc": "il doppio dei grappoli di gemme", "gen": {"gems": 2.0}},
	"iridescente": {"cat": "stirpi", "name": "Iridescente", "rar": 1, "dom": 2, "good": true,
		"desc": "creature rare molto più frequenti", "run": {"rare": 2.0}},
	"fertile": {"cat": "flora", "name": "Fertile", "rar": 0, "dom": 3, "good": true,
		"desc": "le colture crescono il 60% più in fretta", "run": {"grow": 1.6}},
	"stellato": {"cat": "cielo", "name": "Stellato", "rar": 1, "dom": 2, "good": true,
		"desc": "eventi del cielo molto più frequenti", "run": {"events": 2.2}},
	"brulicante": {"cat": "fauna", "name": "Brulicante", "rar": 0, "dom": 3, "good": false,
		"desc": "più creature e più forti, ma il doppio dei Lumini", "run": {"danger": 1.0, "lumini": 2.0}},
	"quieto": {"cat": "fauna", "name": "Quieto", "rar": 0, "dom": 2, "good": true,
		"desc": "meno creature, e meno Lumini", "run": {"danger": -0.6, "lumini": 0.7}},
	"notti_lunghe": {"cat": "tempo", "name": "Notti lunghe", "rar": 0, "dom": 3, "good": false,
		"desc": "la notte dura molto di più", "run": {"night": 0.08}},
	"avvizzito": {"cat": "ombra", "name": "Avvizzito", "rar": 0, "dom": 4, "good": false,
		"desc": "l'Avvizzimento si allarga il doppio più in fretta", "run": {"blight": 2.0, "danger": 0.3}},
}

## Quanti geni oltre la superficie ha un Seme trovato: uno, più uno ogni due punti di vigore, fino a `MAX_EXTRA`.
const MAX_EXTRA := 4


static func info(g: String) -> Dictionary:
	return GENES.get(g, {})


static func cat_of(g: String) -> String:
	return String(GENES.get(g, {}).get("cat", ""))


## I geni di una categoria.
static func of_cat(cat: String) -> Array:
	var out := []
	for g in GENES:
		if GENES[g]["cat"] == cat:
			out.append(g)
	return out


## Il gene di superficie portato da un oggetto Seme ("" se è un Seme generico).
static func of_item(item_id: String) -> String:
	for g in GENES:
		if String(GENES[g].get("item", "")) == item_id:
			return g
	return ""


## Il nome colorato di un gene, con il colore della rarità (o della prova, se non è un dono).
static func tag(g: String) -> String:
	var d := info(g)
	if d.is_empty():
		return "?"
	var col := String(RARITY[int(d["rar"])]["color"]) if d.get("good", true) else "#ff9a7a"
	return "[color=%s]%s[/color]" % [col, d["name"]]
