class_name CropsData
extends RefCounted
## Il giardino del Germogliato (voce 33): ciò che si coltiva. Si pianta il seme (clic con il seme in mano) su un
## terreno adatto: nasce un germoglio (decorazione `SPROUT`), che dopo `grow` secondi diventa la pianta matura
## (`decor`); clic destro sulla pianta matura (o scavarla) = raccolto e semi. Il tempo corre anche lontano dalla
## visuale. L'annaffiatoio dimezza il tempo che manca, una volta per pianta. Solo dati; li usa `Garden`.
##
## Campi: name, seed (oggetto da piantare), decor (pianta matura), grow (secondi), soil (tessere sotto: "erba" =
## muschi ed erbe, "terra" = anche humus e ardesia), deep (solo sotto terra: i funghi luminosi vogliono il buio),
## harvest ({oggetto: [min, max]}), seeds ([min, max] semi che tornano).

const SPROUT := 27                     # il germoglio di una coltura, uguale per tutte

const CROPS := {
	"rugiada": {"name": "Erba di rugiada", "seed": "seme_rugiada", "decor": 28, "grow": 180.0, "soil": "erba",
		"harvest": {"foglia_rugiada": [2, 4]}, "seeds": [1, 2]},
	"brace": {"name": "Funghi di brace", "seed": "spore_brace", "decor": 29, "grow": 240.0, "soil": "terra",
		"harvest": {"fungo_brace": [2, 3]}, "seeds": [1, 2]},
	"luminoso": {"name": "Funghi luminosi", "seed": "spore_luminose", "decor": 30, "grow": 300.0, "soil": "terra",
		"deep": true, "harvest": {"fungo_luminoso": [2, 3]}, "seeds": [1, 1]},
	"campanula": {"name": "Campanula lume", "seed": "seme_campanula", "decor": 31, "grow": 360.0, "soil": "erba",
		"harvest": {"petali_lume": [2, 3]}, "seeds": [1, 2]},
	"tubero": {"name": "Tubero di Linfa", "seed": "occhio_tubero", "decor": 32, "grow": 420.0, "soil": "erba",
		"harvest": {"tubero_linfa": [1, 3]}, "seeds": [1, 2]},
}

## Semi selvatici: raccogliendo certe decorazioni ogni tanto cade un seme (decorazioni di `TileDefs`).
const WILD := [
	[[1, 2, 3], "seme_rugiada", 0.08],     # fronde di muschio
	[[4, 5, 6], "seme_campanula", 0.12],   # campanule luminose
	[[9], "spore_brace", 0.25],            # funghi di brace
	[[10], "spore_luminose", 0.25],        # funghi luminosi
	# la vegetazione dei biomi (26 set 2026)
	[[33], "seme_lanterna", 0.1],          # cespuglio di bacche-lanterna
	[[35, 36], "spore_luminose", 0.15],    # canne e funghetti delle paludi
	[[38, 39], "seme_campanula", 0.1],     # cardo e fiore di resina
	[[42], "seme_rugiada", 0.15],          # cespuglio di brina
	[[44, 45], "spore_brace", 0.12],       # braci e stecchi delle cenerarie
]


## La coltura di un seme ("" se non è un seme da giardino).
static func of_seed(item: String) -> String:
	for k in CROPS:
		if CROPS[k]["seed"] == item:
			return k
	return ""


## La coltura di una pianta matura (decorazione), o "".
static func of_decor(d: int) -> String:
	for k in CROPS:
		if int(CROPS[k]["decor"]) == d:
			return k
	return ""


## Il terreno va bene per questa coltura?
static func soil_ok(crop: String, tile: int) -> bool:
	if TileDefs.is_grass(tile):
		return true
	return String(CROPS[crop]["soil"]) == "terra" and tile in [TileDefs.DIRT, TileDefs.STONE, TileDefs.SCISTO]
