class_name TileDefs
extends RefCounted
## Dati delle tessere: identificatori, nomi, durezza, tavolozze, luce emessa. Solo dati, nessun disegno.

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

# decorazioni (0 = nessuna): stanno su una cella d'aria appoggiate al blocco sotto
const DECOR_GRASS := [1, 2, 3]
const DECOR_FLOWERS := [4, 5, 6]
const DECOR_ROCKS := [7, 8]
const DECOR_MUSHROOM := 9
const DECOR_GLOW := 10
const DECOR_COUNT := 10

## Secondi di scavo con il piccone di rame.
const HARD := {DIRT: 0.22, GRASS: 0.22, STONE: 0.38, COPPER: 0.5, IRON: 0.6, GOLD: 0.7, CRYSTAL: 0.8}
const NAMES := {DIRT: "Terra", GRASS: "Erba", STONE: "Pietra", COPPER: "Rame", IRON: "Ferro", GOLD: "Oro", CRYSTAL: "Cristallo di Linfa"}

## Luce emessa (valori oltre 1 = raggio più ampio).
const LIGHT_CRYSTAL := Color(0.85, 0.52, 1.35)
const LIGHT_GLOW_DECOR := Color(0.3, 0.8, 1.15)

const P_DIRT := ["#56341f", "#6e4429", "#875636", "#a06a44", "#bb8458"]
const P_STONE := ["#454a57", "#596070", "#6f7788", "#8890a2", "#a6aebf"]
const P_GRASS := ["#1f4a1c", "#2f6a28", "#3f8733", "#56a53f", "#7cc452"]
const P_COPPER := ["#6e3818", "#a0542a", "#cf7a3e", "#f0a868"]
const P_IRON := ["#4a4b55", "#7d7e8a", "#b0b1bc", "#e4e5ee"]
const P_GOLD := ["#7a5a0c", "#b68a18", "#e6bd34", "#fff08a"]
const P_CRYSTAL := ["#2e1a5c", "#6a44d0", "#9a74ff", "#cdb4ff", "#f6f0ff"]

## Colore sulla mappa (strumenti e, in futuro, minimappa).
const MAP_COLOR := {DIRT: "#7a4e33", GRASS: "#3f8733", STONE: "#676d7a", COPPER: "#cf7a3e", IRON: "#c0c0cc", GOLD: "#f0c83a", CRYSTAL: "#b08aff"}


static func palette_of(type: int) -> Array[Color]:
	match type:
		DIRT, GRASS:
			return Px.pal(P_DIRT)
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
	if type == GRASS:
		return Px.pal(P_GRASS)
	return palette_of(type)
