class_name BiomesData
extends RefCounted
## I biomi di superficie (voce 13). Solo dati. La superficie di un mondo è divisa in tratti di qualche centinaio di
## colonne, ognuno con il suo bioma (`World.biomes`, uno per colonna); attorno alla partenza sempre la foresta.
##
## Campi:
##   name, desc   nome e frase della scritta che compare entrando
##   grass        la tessera d'erba in cima al terreno
##   trees        probabilità di un albero dove c'è posto (la foresta 0,4)
##   hills        quanto sono mosse le colline (1 = come il generatore di base)
##   lift         di quante tessere si alza (negativo) o si abbassa (positivo) la superficie
##   tint         colore del cielo e delle colline lontane
##   color        colore della scritta
##   weight       quanto spesso compare, rispetto agli altri

const BIOMES := [
	{"id": "foresta", "name": "Foresta-lanterna", "desc": "Alberi-lanterna e muschio turchese",
		"grass": TileDefs.GRASS, "trees": 0.4, "hills": 1.0, "lift": 0, "tint": Color(1, 1, 1), "color": "#8ef0d8",
		"weight": 4},
	{"id": "palude", "name": "Paludi di spore", "desc": "Muschio viola e aria pesante di spore che brillano",
		"grass": TileDefs.GRASS_SPORE, "trees": 0.12, "hills": 0.3, "lift": 12, "tint": Color(0.78, 0.6, 1.12),
		"color": "#c08aff", "weight": 3},
	{"id": "ambra", "name": "Distese d'ambra", "desc": "Erba dorata, rocce calde, pochi alberi",
		"grass": TileDefs.GRASS_AMBRA, "trees": 0.07, "hills": 1.5, "lift": -8, "tint": Color(1.22, 0.9, 0.6),
		"color": "#ffd08a", "weight": 3},
	# voce 40
	{"id": "brina", "name": "Boschi di brina", "desc": "Muschio gelato, alberi che scintillano, aria ferma",
		"grass": TileDefs.GRASS_BRINA, "trees": 0.28, "hills": 1.2, "lift": -4, "tint": Color(0.8, 0.95, 1.22),
		"color": "#bfe8ff", "weight": 2},
	{"id": "cenere", "name": "Cenerarie", "desc": "Pianure di cenere viva: sotto la crosta covano le braci",
		"grass": TileDefs.GRASS_CENERE, "trees": 0.03, "hills": 0.7, "lift": 5, "tint": Color(1.2, 0.82, 0.78),
		"color": "#ff9a7a", "weight": 2},
]

const SPAWN_SAFE := 160                # colonne di foresta attorno alla partenza
const SEG_MIN := 220                   # lunghezza di un tratto di bioma, in colonne
const SEG_MAX := 440
const BLEND := 30                      # colonne di passaggio morbido del terreno tra due biomi


static func index_of(id: String) -> int:
	for k in BIOMES.size():
		if BIOMES[k]["id"] == id:
			return k
	return 0


static func at(w: World, x: int) -> int:
	return w.biomes[clampi(x, 0, w.w - 1)]
