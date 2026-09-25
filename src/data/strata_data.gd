class_name StrataData
extends RefCounted
## Gli strati di profondità (voce 5b): scendendo il mondo cambia identità. Solo dati, più due piccole funzioni per
## sapere in che strato cade una cella. Profondità = tessere sotto la superficie di quella colonna.
##
## Campi:
##   name, desc   nome visibile e frase che compare entrando
##   top          profondità dove comincia (il confine ondeggia: vedi `offset`)
##   rock         la roccia dello strato (id di `TileDefs`); pocket = le sacche dentro la roccia
##   wall         la parete di fondo dello strato
##   ambient      chiarore minimo dove non arriva luce (`LightMap`): nero pieno, come deciso il 25 set 2026
##   danger       moltiplicatore di Vita e danno delle creature che compaiono qui
##   color        colore della scritta d'ingresso

const STRATA := [
	{"id": "superficie", "name": "Superficie", "desc": "Muschio, alberi-lanterna e cielo aperto",
		"top": 0, "rock": TileDefs.STONE, "pocket": TileDefs.DIRT, "wall": TileDefs.WALL_DIRT,
		"ambient": Color(0, 0, 0), "danger": 1.0, "color": "#8ef0d8"},
	{"id": "sottobosco", "name": "Sottobosco di radici", "desc": "La terra è intrecciata di radici enormi",
		"top": 22, "rock": TileDefs.STONE, "pocket": TileDefs.DIRT, "wall": TileDefs.WALL_ROOT,
		"ambient": Color(0, 0, 0), "danger": 1.15, "color": "#ffb070"},
	{"id": "caverne", "name": "Caverne d'ardesia", "desc": "Grandi vuoti di roccia blu: qui si fa sul serio",
		"top": 140, "rock": TileDefs.STONE, "pocket": TileDefs.DIRT, "wall": TileDefs.WALL_STONE,
		"ambient": Color(0, 0, 0), "danger": 1.4, "color": "#8298bc"},
	{"id": "linfa", "name": "Profondità della Linfa", "desc": "La roccia trasuda Linfa: cristalli e funghi che brillano",
		"top": 340, "rock": TileDefs.SCISTO, "pocket": TileDefs.STONE, "wall": TileDefs.WALL_SCISTO,
		"ambient": Color(0, 0, 0), "danger": 1.8, "color": "#5cc8cc"},
	{"id": "fondo", "name": "Il Fondo", "desc": "Qui il mondo finisce e comincia il Vuoto",
		"top": 560, "rock": TileDefs.VUOTITE, "pocket": TileDefs.SCISTO, "wall": TileDefs.WALL_VOID,
		"ambient": Color(0, 0, 0), "danger": 2.3, "color": "#c08aff"},
]


## Di quanto si sposta il confine tra gli strati in una colonna: ondeggia, così non si vede una riga dritta.
static func offset(x: int, sd: int) -> int:
	var p := float(sd % 997)
	return int(sin(x * 0.011 + p) * 9.0 + sin(x * 0.037 + p * 1.7) * 4.0)


## Lo strato di una cella (indice in `STRATA`), dalla profondità e dalla colonna.
static func index(x: int, depth: int, sd: int) -> int:
	var d := depth - offset(x, sd)
	for k in range(STRATA.size() - 1, 0, -1):
		if d >= int(STRATA[k]["top"]):
			return k
	return 0


static func at(w: World, x: int, y: int) -> int:
	return index(x, w.depth(x, y), w.world_seed)


## Profondità (senza ondeggiare) dove comincia lo strato k.
static func top(k: int) -> int:
	return int(STRATA[k]["top"])
