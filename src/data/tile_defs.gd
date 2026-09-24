class_name TileDefs
extends RefCounted
## Dati delle tessere: identificatori, nomi, durezza, tavolozze, strati del terreno, luce emessa. Solo dati.
## Stile «Radici e Linfa» (scelto dall'utente il 24 set 2026): terra scura intrecciata di radici, roccia blu ardesia,
## muschio turchese al posto dell'erba, luce che viene dalle cose vive.

const AIR := 0
const DIRT := 1
const GRASS := 2
const STONE := 3
const COPPER := 4
const IRON := 5
const GOLD := 6
const CRYSTAL := 7
const TYPES := 7

const WALL_DIRT := 1
const WALL_STONE := 2

# decorazioni (0 = nessuna): stanno su una cella d'aria, appoggiate al blocco sotto oppure appese a quello sopra
const DECOR_GRASS := [1, 2, 3]         # fronde di muschio
const DECOR_FLOWERS := [4, 5, 6]       # campanule luminose (turchese, ambra, viola)
const DECOR_ROCKS := [7, 8]
const DECOR_MUSHROOM := 9
const DECOR_GLOW := 10                 # fungo luminoso
const DECOR_ROOTS := [11, 12]          # radici pendenti dal soffitto, con la punta accesa
const DECOR_SPORE := 13                # sacca di spore
const DECOR_FERN := 14                 # felce arricciata
const DECOR_COUNT := 14
const DECOR_CEILING := [11, 12]        # queste pendono dal blocco sopra

## Luce emessa dalle decorazioni (indice = id della decorazione).
const DECOR_LIGHT := {
	4: Color(0.2, 0.55, 0.6), 5: Color(0.6, 0.4, 0.12), 6: Color(0.4, 0.2, 0.6),
	10: Color(0.3, 0.8, 1.15), 11: Color(0.55, 0.34, 0.1), 12: Color(0.45, 0.28, 0.08), 13: Color(0.45, 0.25, 0.75),
}

## Secondi di scavo con il piccone di rame.
const HARD := {DIRT: 0.22, GRASS: 0.22, STONE: 0.38, COPPER: 0.5, IRON: 0.6, GOLD: 0.7, CRYSTAL: 0.8}
const NAMES := {DIRT: "Humus", GRASS: "Muschio", STONE: "Ardesia", COPPER: "Rame", IRON: "Ferro", GOLD: "Oro", CRYSTAL: "Cristallo di Linfa"}

## Luce emessa dai blocchi.
const LIGHT_CRYSTAL := Color(0.55, 0.9, 1.25)

const P_DIRT := ["#34202a", "#4a2e3c", "#62404e", "#7c5262", "#9a6a7a"]
const P_STONE := ["#2a3650", "#3a4966", "#4c5e80", "#62779c", "#8298bc"]
const P_GRASS := ["#0f3a3a", "#16574f", "#23776a", "#3aa08a", "#72d4b0"]
const P_COPPER := ["#5a2a14", "#9a4a22", "#d4783a", "#ffb070"]
const P_IRON := ["#3a4250", "#6a7688", "#a2b0c2", "#dce6f2"]
const P_GOLD := ["#6a4a0c", "#b0861c", "#eec04a", "#fff2a8"]
const P_CRYSTAL := ["#0a2a36", "#12566a", "#1f8a9a", "#5cc8cc", "#b8f4f0"]
const P_ROOT := ["#2a1810", "#4a2c1a", "#6e4426", "#9a6636"]

## Strati del terreno dai contorni morbidi, dal basso verso l'alto: ogni strato disegna la forma morbida delle celle
## dei tipi elencati. Il primo è la sagoma di tutto il terreno.
const TERRAIN_LAYERS := [
	{"id": "ardesia", "types": [DIRT, GRASS, STONE, COPPER, IRON, GOLD, CRYSTAL], "pal": P_STONE},
	{"id": "humus", "types": [DIRT, GRASS], "pal": P_DIRT},
	{"id": "muschio", "types": [GRASS], "pal": P_GRASS},
	{"id": "rame", "types": [COPPER], "pal": P_COPPER},
	{"id": "ferro", "types": [IRON], "pal": P_IRON},
	{"id": "oro", "types": [GOLD], "pal": P_GOLD},
	{"id": "cristallo", "types": [CRYSTAL], "pal": P_CRYSTAL, "glow": true},
]

## Colore sulla mappa (strumenti e, in futuro, minimappa).
const MAP_COLOR := {DIRT: "#50343c", GRASS: "#3aa08a", STONE: "#434f6c", COPPER: "#d4783a", IRON: "#a2b0c2", GOLD: "#eec04a", CRYSTAL: "#3ac0c8"}


static func palette_of(type: int) -> Array[Color]:
	match type:
		DIRT:
			return Px.pal(P_DIRT)
		GRASS:
			return Px.pal(P_GRASS)
		COPPER:
			return Px.pal(P_COPPER)
		IRON:
			return Px.pal(P_IRON)
		GOLD:
			return Px.pal(P_GOLD)
		CRYSTAL:
			return Px.pal(P_CRYSTAL)
	return Px.pal(P_STONE)


static func dust_colors(type: int) -> Array[Color]:
	return palette_of(type)
