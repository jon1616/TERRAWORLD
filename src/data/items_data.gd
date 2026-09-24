class_name ItemsData
extends RefCounted
## Tutti gli oggetti del gioco. Solo dati: nessuna logica di gioco qui.
##
## Campi di un oggetto:
##   name   nome visibile
##   kind   materiale · blocco · piccone · ascia · spada · arco · munizione · torcia · stazione · piattaforma ·
##          elmo · corazza · gambali · consumabile
##   icon   [forma, materiale] per `ItemIcons.make`
##   stack  quanti per casella (predefinito: 999 per materiali e blocchi, 1 per attrezzi e armature)
##   tier   grado: 0 legno/pietra, 1 rame, 2 ferro, 3 oro
##   power  forza del piccone o dell'ascia (vedi `TileDefs.POWER`)
##   damage, speed (colpi al secondo), knockback, defense, heal
##   place  tessera (id di `TileDefs`) o stazione (id di `StationsData`) che l'oggetto piazza
##   desc   descrizione breve
##
## Le famiglie di metallo (attrezzi e armature di rame, ferro, oro) sono generate da `METALS` × `GEAR` in `all()`:
## un metallo nuovo = una riga in `METALS`.

const ITEMS := {
	# materiali grezzi
	"legno": {"name": "Legno", "kind": "materiale", "icon": ["tronco", "legno"], "desc": "Dagli alberi-lanterna. Leggero, fibroso, utile a tutto."},
	"humus": {"name": "Humus", "kind": "blocco", "icon": ["zolla", "humus"], "place": TileDefs.DIRT, "desc": "Terra scura intrecciata di radici."},
	"ardesia": {"name": "Ardesia", "kind": "blocco", "icon": ["zolla", "ardesia"], "place": TileDefs.STONE, "desc": "Roccia blu a strati."},
	"minerale_rame": {"name": "Minerale di rame", "kind": "materiale", "icon": ["minerale", "rame"], "desc": "Noduli di rame nella roccia."},
	"minerale_ferro": {"name": "Minerale di ferro", "kind": "materiale", "icon": ["minerale", "ferro"], "desc": "Più in profondità, più duro."},
	"minerale_oro": {"name": "Minerale d'oro", "kind": "materiale", "icon": ["minerale", "oro"], "desc": "Serve un piccone di ferro per staccarlo."},
	"cristallo_linfa": {"name": "Cristallo di Linfa", "kind": "materiale", "icon": ["cristallo", "cristallo"], "desc": "Linfa dell'Albero-Madre, indurita nel profondo."},
	"gel": {"name": "Gel", "kind": "materiale", "icon": ["gel", "muschio"], "desc": "Appiccicoso, brucia bene."},
	"fungo": {"name": "Fungo d'ambra", "kind": "materiale", "icon": ["fungo", "rame"], "desc": "Cresce nelle grotte vicine alla superficie."},
	"fungo_luminoso": {"name": "Fungo luminoso", "kind": "materiale", "icon": ["fungo", "cristallo"], "desc": "Brilla nel profondo."},
	# lingotti (la fornace fonde i minerali)
	"lingotto_rame": {"name": "Lingotto di rame", "kind": "materiale", "icon": ["lingotto", "rame"], "tier": 1},
	"lingotto_ferro": {"name": "Lingotto di ferro", "kind": "materiale", "icon": ["lingotto", "ferro"], "tier": 2},
	"lingotto_oro": {"name": "Lingotto d'oro", "kind": "materiale", "icon": ["lingotto", "oro"], "tier": 3},
	# oggetti da piazzare
	"torcia": {"name": "Torcia", "kind": "torcia", "icon": ["torcia", "legno"], "stack": 999, "desc": "Luce calda per le grotte."},
	"piattaforma": {"name": "Piattaforma di legno", "kind": "piattaforma", "icon": ["piattaforma", "legno"], "desc": "Ci si sale saltando da sotto."},
	"banco_lavoro": {"name": "Banco da lavoro", "kind": "stazione", "icon": ["banco", "legno"], "place": "banco_lavoro", "stack": 99},
	"fornace": {"name": "Fornace", "kind": "stazione", "icon": ["fornace", "ardesia"], "place": "fornace", "stack": 99},
	"incudine": {"name": "Incudine di ferro", "kind": "stazione", "icon": ["incudine", "ferro"], "place": "incudine", "stack": 99},
	# legno: il primo equipaggiamento
	"arco_legno": {"name": "Arco di legno", "kind": "arco", "icon": ["arco", "legno"], "tier": 0, "damage": 5, "speed": 1.6, "knockback": 1.0},
	"freccia": {"name": "Freccia", "kind": "munizione", "icon": ["freccia", "ardesia"], "damage": 4, "stack": 999},
	"spada_legno": {"name": "Spada di legno", "kind": "spada", "icon": ["spada", "legno"], "tier": 0, "damage": 6, "speed": 2.4, "knockback": 3.0},
	# consumabili
	"pozione_cura": {"name": "Pozione di Linfa", "kind": "consumabile", "icon": ["pozione", "linfa"], "heal": 50, "stack": 30, "desc": "Cura 50 punti vita."},
}

## Metalli: grado, forza di piccone e ascia, danno della spada, difesa dell'armatura (elmo, corazza, gambali).
const METALS := {
	"rame": {"label": "di rame", "tier": 1, "power": 35, "damage": 9, "speed": 2.2, "defense": [1, 2, 1]},
	"ferro": {"label": "di ferro", "tier": 2, "power": 45, "damage": 12, "speed": 2.3, "defense": [2, 3, 2]},
	"oro": {"label": "d'oro", "tier": 3, "power": 55, "damage": 16, "speed": 2.4, "defense": [3, 4, 3]},
}

## Modelli delle famiglie di metallo: tipo, costo in lingotti (+ legno), stazione.
const GEAR := {
	"piccone": {"name": "Piccone", "bars": 12, "wood": 4},
	"ascia": {"name": "Ascia", "bars": 9, "wood": 3},
	"spada": {"name": "Spada", "bars": 8, "wood": 0},
	"elmo": {"name": "Elmo", "bars": 15, "wood": 0},
	"corazza": {"name": "Corazza", "bars": 25, "wood": 0},
	"gambali": {"name": "Gambali", "bars": 20, "wood": 0},
}

## Barra rapida di prova (finché non c'è l'inventario, voce 4).
const DEMO_HOTBAR := ["piccone_rame", "piccone_oro", "ascia_rame", "spada_rame", "spada_oro", "arco_legno", "torcia",
	"lingotto_rame", "elmo_ferro", "pozione_cura"]

## Oggetti che nascono da qualcosa che non è una tabella (es. alberi abbattuti, voce 4).
const OTHER_SOURCES := {"legno": "alberi"}

static var _all := {}


## Tutti gli oggetti, famiglie di metallo comprese (calcolati una volta).
static func all() -> Dictionary:
	if not _all.is_empty():
		return _all
	var out := ITEMS.duplicate(true)
	for m in METALS:
		var md: Dictionary = METALS[m]
		for g in GEAR:
			var gd: Dictionary = GEAR[g]
			var it := {"name": "%s %s" % [gd["name"], md["label"]], "kind": g, "icon": [g, m], "tier": md["tier"]}
			match g:
				"piccone", "ascia":
					it["power"] = md["power"]
					it["damage"] = int(md["damage"] * 0.6)
					it["speed"] = 2.6
				"spada":
					it["damage"] = md["damage"]
					it["speed"] = md["speed"]
					it["knockback"] = 4.0
				"elmo":
					it["defense"] = md["defense"][0]
				"corazza":
					it["defense"] = md["defense"][1]
				"gambali":
					it["defense"] = md["defense"][2]
			out["%s_%s" % [g, m]] = it
	_all = out
	return _all


static func get_item(id: String) -> Dictionary:
	return all().get(id, {})


static func has(id: String) -> bool:
	return all().has(id)


static func stack_of(id: String) -> int:
	var it := get_item(id)
	if it.has("stack"):
		return int(it["stack"])
	return 999 if String(it.get("kind", "")) in ["materiale", "blocco", "munizione", "piattaforma"] else 1


## Che cosa fa il clic con l'oggetto in mano (per ora: scava, colpisci, piazza una torcia).
static func use_of(id: String) -> String:
	match String(get_item(id).get("kind", "")):
		"piccone":
			return "scava"
		"ascia", "spada":
			return "colpo"
		"torcia":
			return "torcia"
	return ""
