class_name TileDefs
extends RefCounted
## Dati delle tessere: identificatori, nomi, durezza, tavolozze, strati del terreno, luce emessa. Solo dati.
## Stile «Radici e Linfa» (scelto dall'utente il 24 set 2026): terra scura intrecciata di radici, roccia blu ardesia,
## muschio turchese al posto dell'erba, luce che viene dalle cose vive.

const AIR := 0
const DIRT := 1
const GRASS := 2
const STONE := 3
const RADICITE := 4
const LEGNOFERRO := 5
const AMBRA := 6
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

## Secondi di scavo con il piccone di radicite.
const HARD := {DIRT: 0.22, GRASS: 0.22, STONE: 0.38, RADICITE: 0.5, LEGNOFERRO: 0.6, AMBRA: 0.7, CRYSTAL: 0.8}
## Forza di piccone minima (vedi `ItemsData.METALS`): radicite 35, legnoferro 45, ambra 55. L'ambra vuole il piccone
## di legnoferro, i cristalli di Linfa quello d'ambra: è il filo della progressione.
const POWER := {DIRT: 0, GRASS: 0, STONE: 0, RADICITE: 0, LEGNOFERRO: 35, AMBRA: 45, CRYSTAL: 55}
## Oggetto che si ottiene rompendo la tessera o raccogliendo la decorazione.
const DROP := {DIRT: "humus", GRASS: "humus", STONE: "ardesia", RADICITE: "minerale_radicite", LEGNOFERRO: "minerale_legnoferro",
	AMBRA: "minerale_ambra", CRYSTAL: "cristallo_linfa"}
const DECOR_DROP := {9: "fungo_brace", 10: "fungo_luminoso"}

## Vene di minerale (lette da `PassMinerali`): tessera, profondità minima, dove può comparire, frequenza e soglia del
## rumore (soglia più alta = vene più rare).
const ORES := [
	{"type": RADICITE, "min_depth": 4, "in": [DIRT, STONE], "freq": 0.11, "threshold": 0.5},
	{"type": LEGNOFERRO, "min_depth": 60, "in": [STONE], "freq": 0.12, "threshold": 0.52},
	{"type": AMBRA, "min_depth": 180, "in": [STONE], "freq": 0.13, "threshold": 0.55},
]
const NAMES := {DIRT: "Humus", GRASS: "Muschio", STONE: "Ardesia", RADICITE: "Radicite", LEGNOFERRO: "Legnoferro", AMBRA: "Ambra fossile", CRYSTAL: "Cristallo di Linfa"}

## Luce emessa dai blocchi.
const LIGHT_CRYSTAL := Color(0.55, 0.9, 1.25)

const P_DIRT := ["#34202a", "#4a2e3c", "#62404e", "#7c5262", "#9a6a7a"]
const P_STONE := ["#2a3650", "#3a4966", "#4c5e80", "#62779c", "#8298bc"]
const P_GRASS := ["#0f3a3a", "#16574f", "#23776a", "#3aa08a", "#72d4b0"]
const P_RADICITE := ["#5a2414", "#963a22", "#cc6034", "#f8a070"]
## Brace: arancio caldo delle cose accese (punte delle radici, baccelli, funghi di brace).
const P_BRACE := ["#5a2a14", "#9a4a22", "#d4783a", "#ffb070"]
const P_LEGNOFERRO := ["#3a4250", "#6a7688", "#a2b0c2", "#dce6f2"]
const P_AMBRA := ["#6a4a0c", "#b0861c", "#eec04a", "#fff2a8"]
const P_CRYSTAL := ["#0a2a36", "#12566a", "#1f8a9a", "#5cc8cc", "#b8f4f0"]
const P_ROOT := ["#2a1810", "#4a2c1a", "#6e4426", "#9a6636"]

## Strati del terreno dai contorni morbidi, dal basso verso l'alto: ogni strato disegna la forma morbida delle celle
## dei tipi elencati. Il primo è la sagoma di tutto il terreno.
const TERRAIN_LAYERS := [
	{"id": "ardesia", "types": [DIRT, GRASS, STONE, RADICITE, LEGNOFERRO, AMBRA, CRYSTAL], "pal": P_STONE},
	{"id": "humus", "types": [DIRT, GRASS], "pal": P_DIRT},
	{"id": "muschio", "types": [GRASS], "pal": P_GRASS},
	{"id": "radicite", "types": [RADICITE], "pal": P_RADICITE},
	{"id": "legnoferro", "types": [LEGNOFERRO], "pal": P_LEGNOFERRO},
	{"id": "ambra", "types": [AMBRA], "pal": P_AMBRA},
	{"id": "cristallo", "types": [CRYSTAL], "pal": P_CRYSTAL, "glow": true},
]

## Colore sulla mappa (strumenti e, in futuro, minimappa).
const MAP_COLOR := {DIRT: "#50343c", GRASS: "#3aa08a", STONE: "#434f6c", RADICITE: "#d4783a", LEGNOFERRO: "#a2b0c2", AMBRA: "#eec04a", CRYSTAL: "#3ac0c8"}


static func palette_of(type: int) -> Array[Color]:
	match type:
		DIRT:
			return Px.pal(P_DIRT)
		GRASS:
			return Px.pal(P_GRASS)
		RADICITE:
			return Px.pal(P_RADICITE)
		LEGNOFERRO:
			return Px.pal(P_LEGNOFERRO)
		AMBRA:
			return Px.pal(P_AMBRA)
		CRYSTAL:
			return Px.pal(P_CRYSTAL)
	return Px.pal(P_STONE)


static func dust_colors(type: int) -> Array[Color]:
	return palette_of(type)
