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
const RADICE := 8                      # radice gigante del Sottobosco (voce 5b)
const SCISTO := 9                      # scisto di Linfa, la roccia delle Profondità della Linfa
const VUOTITE := 10                    # la roccia del Fondo, vicino al Vuoto
const NODO := 11                       # nodo avvizzito attorno al Cuore del mondo: non si scava, si cura (voce 8)
const TYPES := 11

const WALL_DIRT := 1
const WALL_STONE := 2
const WALL_ROOT := 3
const WALL_SCISTO := 4
const WALL_VOID := 5
const WALLS := 5

# decorazioni (0 = nessuna): stanno su una cella d'aria, appoggiate al blocco sotto oppure appese a quello sopra
const DECOR_GRASS := [1, 2, 3]         # fronde di muschio
const DECOR_FLOWERS := [4, 5, 6]       # campanule luminose (turchese, ambra, viola)
const DECOR_ROCKS := [7, 8]
const DECOR_MUSHROOM := 9
const DECOR_GLOW := 10                 # fungo luminoso
const DECOR_ROOTS := [11, 12]          # radici pendenti dal soffitto, con la punta accesa
const DECOR_SPORE := 13                # sacca di spore
const DECOR_FERN := 14                 # felce arricciata
const DECOR_SPROUT := 15               # germoglio d'albero-lanterna piantato: diventerà un albero
const DECOR_SHARD := 16                # scheggia del Vuoto: spunta dal pavimento del Fondo e brilla viola
const DECOR_LINFA := 17                # goccia di Linfa che pende dai soffitti delle Profondità della Linfa
const DECOR_COUNT := 17
const DECOR_CEILING := [11, 12, 17]        # queste pendono dal blocco sopra

## Luce emessa dalle decorazioni (indice = id della decorazione).
const DECOR_LIGHT := {
	4: Color(0.2, 0.55, 0.6), 5: Color(0.6, 0.4, 0.12), 6: Color(0.4, 0.2, 0.6),
	10: Color(0.3, 0.8, 1.15), 11: Color(0.55, 0.34, 0.1), 12: Color(0.45, 0.28, 0.08), 13: Color(0.45, 0.25, 0.75),
	15: Color(0.35, 0.2, 0.06), 16: Color(0.5, 0.22, 0.85), 17: Color(0.2, 0.7, 0.75),
}

## Secondi di scavo con il piccone di radicite.
const HARD := {DIRT: 0.22, GRASS: 0.22, STONE: 0.38, RADICITE: 0.5, LEGNOFERRO: 0.6, AMBRA: 0.7, CRYSTAL: 0.8,
	RADICE: 0.45, SCISTO: 0.5, VUOTITE: 0.75, NODO: 9.0}
## Forza di piccone minima (vedi `ItemsData.METALS`): radicite 35, legnoferro 45, ambra 55. L'ambra vuole il piccone
## di legnoferro, i cristalli di Linfa quello d'ambra: è il filo della progressione.
## Il Fondo (vuotite) vuole il piccone di legnoferro: non ci si arriva col primo corredo.
const POWER := {DIRT: 0, GRASS: 0, STONE: 0, RADICITE: 0, LEGNOFERRO: 35, AMBRA: 45, CRYSTAL: 55, RADICE: 0, SCISTO: 0,
	VUOTITE: 45, NODO: 999}
## Oggetto che si ottiene rompendo la tessera o raccogliendo la decorazione.
const DROP := {DIRT: "humus", GRASS: "humus", STONE: "ardesia", RADICITE: "minerale_radicite", LEGNOFERRO: "minerale_legnoferro",
	AMBRA: "minerale_ambra", CRYSTAL: "cristallo_linfa", RADICE: "radice_antica", SCISTO: "scisto", VUOTITE: "vuotite",
	NODO: "radice_antica"}
const DECOR_DROP := {9: "fungo_brace", 10: "fungo_luminoso", 15: "seme_lanterna", 16: "scheggia_vuoto"}

## Vene di minerale (lette da `PassMinerali`): tessera, profondità minima, strati in cui compare (vedi `StrataData`),
## in quali rocce, frequenza e soglia del rumore (soglia più alta = vene più rare).
const ORES := [
	{"type": RADICITE, "min_depth": 4, "strata": [0, 1, 2], "in": [DIRT, STONE], "freq": 0.11, "threshold": 0.5},
	{"type": LEGNOFERRO, "min_depth": 60, "strata": [1, 2, 3], "in": [STONE, SCISTO], "freq": 0.12, "threshold": 0.52},
	{"type": AMBRA, "min_depth": 200, "strata": [2, 3, 4], "in": [STONE, SCISTO, VUOTITE], "freq": 0.13, "threshold": 0.54},
]
const NAMES := {DIRT: "Humus", GRASS: "Muschio", STONE: "Ardesia", RADICITE: "Radicite", LEGNOFERRO: "Legnoferro", AMBRA: "Ambra fossile", CRYSTAL: "Cristallo di Linfa",
	RADICE: "Radice antica", SCISTO: "Scisto di Linfa", VUOTITE: "Vuotite", NODO: "Nodo avvizzito"}

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
const P_RADICE := ["#4a2c22", "#6a3e2c", "#8a5638", "#a8704a", "#c89066"]
const P_SCISTO := ["#263a40", "#34505a", "#446872", "#58848c", "#7aa6aa"]
const P_NODO := ["#3a3832", "#54524a", "#6e6c60", "#8a887a", "#a8a694"]
const P_VUOTITE := ["#34284a", "#463662", "#5a467c", "#745c9c", "#967cc4"]

## Strati del terreno dai contorni morbidi, dal basso verso l'alto: ogni strato disegna la forma morbida delle celle
## dei tipi elencati. Il primo è la sagoma di tutto il terreno.
const TERRAIN_LAYERS := [
	{"id": "ardesia", "types": [DIRT, GRASS, STONE, RADICITE, LEGNOFERRO, AMBRA, CRYSTAL, RADICE, SCISTO, VUOTITE, NODO],
		"pal": P_STONE},
	{"id": "humus", "types": [DIRT, GRASS], "pal": P_DIRT},
	{"id": "muschio", "types": [GRASS], "pal": P_GRASS},
	{"id": "radice", "types": [RADICE], "pal": P_RADICE},
	{"id": "scisto", "types": [SCISTO], "pal": P_SCISTO},
	{"id": "vuotite", "types": [VUOTITE], "pal": P_VUOTITE},
	{"id": "nodo", "types": [NODO], "pal": P_NODO},
	{"id": "radicite", "types": [RADICITE], "pal": P_RADICITE},
	{"id": "legnoferro", "types": [LEGNOFERRO], "pal": P_LEGNOFERRO},
	{"id": "ambra", "types": [AMBRA], "pal": P_AMBRA},
	{"id": "cristallo", "types": [CRYSTAL], "pal": P_CRYSTAL, "glow": true},
]

## Colore sulla mappa (strumenti e, in futuro, minimappa).
const MAP_COLOR := {DIRT: "#50343c", GRASS: "#3aa08a", STONE: "#434f6c", RADICITE: "#d4783a", LEGNOFERRO: "#a2b0c2", AMBRA: "#eec04a", CRYSTAL: "#3ac0c8",
	RADICE: "#8a5638", SCISTO: "#32687c", VUOTITE: "#463464", NODO: "#ff40a0"}


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
		RADICE:
			return Px.pal(P_RADICE)
		SCISTO:
			return Px.pal(P_SCISTO)
		VUOTITE:
			return Px.pal(P_VUOTITE)
		NODO:
			return Px.pal(P_NODO)
	return Px.pal(P_STONE)


static func dust_colors(type: int) -> Array[Color]:
	return palette_of(type)
