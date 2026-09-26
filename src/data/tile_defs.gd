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
const PIETRA_SEM := 12                 # pietra dei Seminatori: i mattoni delle rovine (voce 10)
const GRASS_SPORE := 13                # muschio di spore, viola: le Paludi di spore (voce 13)
const GRASS_AMBRA := 14                # erba d'ambra, dorata: le Distese d'ambra
const AVV_TERRA := 15                  # terra avvizzita: l'Avvizzimento (voce 18) si mangia la terra…
const AVV_MUSCHIO := 16                # …il muschio (e le altre erbe)…
const AVV_PIETRA := 17                 # …e l'ardesia
const PALLIDITE := 18                  # metallo pallido del Sottobosco e delle Caverne (voce 24)
const TIZZONITE := 19                  # metallo di brace del profondo: vuole il piccone d'ambra
# voce 35: costruire. Blocchi dai bordi squadrati (non entrano nella sagoma morbida del terreno naturale)
const ASSI := 20                       # assi di legno di lanterna
const MATTONI := 21                    # mattoni d'ardesia
const VETRO := 22                      # vetro di resina: solido ma lascia passare la luce
const PORTA := 23                      # una porta chiusa: solida, non disegnata (la disegna la stazione)
const GRASS_BRINA := 24                # muschio di brina, azzurro: i Boschi di brina (voce 40)
const GRASS_CENERE := 25               # cenere viva, rosata: le Cenerarie (voce 40)
const TYPES := 25
const BUILT := [ASSI, MATTONI, VETRO]
const BLIGHTED := [AVV_TERRA, AVV_MUSCHIO, AVV_PIETRA]
const GRASSES := [GRASS, GRASS_SPORE, GRASS_AMBRA, GRASS_BRINA, GRASS_CENERE]

const WALL_DIRT := 1
const WALL_STONE := 2
const WALL_ROOT := 3
const WALL_SCISTO := 4
const WALL_VOID := 5
const WALL_SEM := 6                    # parete delle rovine dei Seminatori
const WALL_ASSI := 7                   # pareti da costruire (voce 35)
const WALL_MATTONI := 8
const WALLS := 8

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
const DECOR_RUNE := 18                 # runa dei Seminatori accesa, nelle rovine
const DECOR_ROVO := 19                 # rovo spinoso: punge chi lo tocca (voce 20c)
const DECOR_TRAP := 20                 # runa trappola sul pavimento delle rovine: una scarica di spore, poi si spegne
const DECOR_BOCCIOLO := 21             # Bocciolo del cuore: sui pavimenti delle grotte, dà +10 Vita massima (voce 21)
const DECOR_STILLA := 22               # Stilla perenne: pende dai soffitti profondi, dà Linfa massima
const DECOR_GEMS := [23, 24, 25, 26]   # gemme a grappolo (voce 24): brillaluce, sanguinella, lagunite, nottilite
const DECOR_CROPS := [27, 28, 29, 30, 31, 32]   # il giardino (voce 33): germoglio di coltura e piante mature
const DECOR_COUNT := 32
const DECOR_CEILING := [11, 12, 17, 22]        # queste pendono dal blocco sopra

## Luce emessa dalle decorazioni (indice = id della decorazione): piccole pozze di luce nel buio, non lampioni
## (con il buio vero del 25 set 2026 una luce di 0,3 si vede per ~6 tessere).
const DECOR_LIGHT := {
	4: Color(0.15, 0.4, 0.45), 5: Color(0.45, 0.3, 0.1), 6: Color(0.3, 0.15, 0.45),
	10: Color(0.25, 0.6, 0.85), 11: Color(0.2, 0.13, 0.04), 12: Color(0.17, 0.11, 0.03), 13: Color(0.3, 0.17, 0.5),
	15: Color(0.25, 0.14, 0.04), 16: Color(0.4, 0.18, 0.7), 17: Color(0.15, 0.5, 0.55),
	18: Color(0.2, 0.62, 0.6), 20: Color(0.14, 0.2, 0.1), 21: Color(0.75, 0.25, 0.3), 22: Color(0.3, 0.75, 0.8),
	28: Color(0.1, 0.3, 0.3), 30: Color(0.2, 0.5, 0.75), 31: Color(0.6, 0.25, 0.45), 32: Color(0.12, 0.45, 0.45),
	23: Color(0.45, 0.55, 0.15), 24: Color(0.55, 0.12, 0.12), 25: Color(0.12, 0.3, 0.6), 26: Color(0.35, 0.15, 0.55),
}

## Secondi di scavo con il piccone di radicite.
const HARD := {DIRT: 0.22, GRASS: 0.22, STONE: 0.38, RADICITE: 0.5, LEGNOFERRO: 0.6, AMBRA: 0.7, CRYSTAL: 0.8,
	RADICE: 0.45, SCISTO: 0.5, VUOTITE: 0.75, NODO: 9.0, PIETRA_SEM: 0.8,
	GRASS_SPORE: 0.22, GRASS_AMBRA: 0.22, GRASS_BRINA: 0.22, GRASS_CENERE: 0.22, AVV_TERRA: 0.25, AVV_MUSCHIO: 0.25, AVV_PIETRA: 0.42,
	PALLIDITE: 0.55, TIZZONITE: 0.8, ASSI: 0.3, MATTONI: 0.45, VETRO: 0.3, PORTA: 1.0}
## Forza di piccone minima (vedi `ItemsData.METALS`): radicite 35, legnoferro 45, ambra 55. L'ambra vuole il piccone
## di legnoferro, i cristalli di Linfa quello d'ambra: è il filo della progressione.
## Il Fondo (vuotite) vuole il piccone di legnoferro: non ci si arriva col primo corredo.
const POWER := {DIRT: 0, GRASS: 0, STONE: 0, RADICITE: 0, LEGNOFERRO: 35, AMBRA: 45, CRYSTAL: 55, RADICE: 0, SCISTO: 0,
	VUOTITE: 45, NODO: 999, PIETRA_SEM: 0, GRASS_SPORE: 0, GRASS_AMBRA: 0, GRASS_BRINA: 0, GRASS_CENERE: 0,
	AVV_TERRA: 0, AVV_MUSCHIO: 0, AVV_PIETRA: 0, PALLIDITE: 35, TIZZONITE: 55, ASSI: 0, MATTONI: 0, VETRO: 0, PORTA: 999}
## Oggetto che si ottiene rompendo la tessera o raccogliendo la decorazione.
const DROP := {DIRT: "humus", GRASS: "humus", STONE: "ardesia", RADICITE: "minerale_radicite", LEGNOFERRO: "minerale_legnoferro",
	AMBRA: "minerale_ambra", CRYSTAL: "cristallo_linfa", RADICE: "radice_antica", SCISTO: "scisto", VUOTITE: "vuotite",
	NODO: "radice_antica", PIETRA_SEM: "pietra_seminatori", GRASS_SPORE: "humus", GRASS_AMBRA: "humus", GRASS_BRINA: "humus", GRASS_CENERE: "humus",
	AVV_TERRA: "cenere_avvizzita", AVV_MUSCHIO: "cenere_avvizzita", AVV_PIETRA: "ardesia",
	PALLIDITE: "minerale_pallidite", TIZZONITE: "minerale_tizzonite", ASSI: "assi_lanterna", MATTONI: "mattoni_ardesia",
	VETRO: "vetro_resina", PORTA: "porta_lanterna"}
const DECOR_DROP := {9: "fungo_brace", 10: "fungo_luminoso", 15: "seme_lanterna", 16: "scheggia_vuoto",
	21: "cuore_bocciolo", 22: "stilla_perenne", 23: "brillaluce", 24: "sanguinella", 25: "lagunite", 26: "nottilite"}

## Vene di minerale (lette da `PassMinerali`): tessera, profondità minima, strati in cui compare (vedi `StrataData`),
## in quali rocce, frequenza e soglia del rumore (soglia più alta = vene più rare).
const ORES := [
	{"type": RADICITE, "min_depth": 4, "strata": [0, 1, 2], "in": [DIRT, STONE], "freq": 0.11, "threshold": 0.5},
	{"type": LEGNOFERRO, "min_depth": 60, "strata": [1, 2, 3], "in": [STONE, SCISTO], "freq": 0.12, "threshold": 0.52},
	{"type": AMBRA, "min_depth": 200, "strata": [2, 3, 4], "in": [STONE, SCISTO, VUOTITE], "freq": 0.13, "threshold": 0.54},
	{"type": PALLIDITE, "min_depth": 30, "strata": [1, 2], "in": [STONE, RADICE], "freq": 0.12, "threshold": 0.56},
	{"type": TIZZONITE, "min_depth": 300, "strata": [3, 4], "in": [SCISTO, VUOTITE, STONE], "freq": 0.13, "threshold": 0.57},
]
const NAMES := {DIRT: "Humus", GRASS: "Muschio", STONE: "Ardesia", RADICITE: "Radicite", LEGNOFERRO: "Legnoferro", AMBRA: "Ambra fossile", CRYSTAL: "Cristallo di Linfa",
	RADICE: "Radice antica", SCISTO: "Scisto di Linfa", VUOTITE: "Vuotite", NODO: "Nodo avvizzito",
	PIETRA_SEM: "Pietra dei Seminatori", GRASS_SPORE: "Muschio di spore", GRASS_AMBRA: "Erba d'ambra",
	GRASS_BRINA: "Muschio di brina", GRASS_CENERE: "Cenere viva",
	AVV_TERRA: "Terra avvizzita", AVV_MUSCHIO: "Muschio avvizzito", AVV_PIETRA: "Ardesia avvizzita",
	PALLIDITE: "Pallidite", TIZZONITE: "Tizzonite", ASSI: "Assi di lanterna", MATTONI: "Mattoni d'ardesia",
	VETRO: "Vetro di resina", PORTA: "Porta"}

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
const P_PALLIDITE := ["#4e4e66", "#8a8aa6", "#c4c4dc", "#f4f4ff"]
const P_TIZZONITE := ["#4a1010", "#9a2a1a", "#e0582a", "#ffc070"]
const P_ASSI := ["#3a2430", "#5a3a48", "#7a5462", "#9a7080"]
const P_MATTONI := ["#2a3650", "#4c5e80", "#62779c", "#8298bc"]
const P_VETRO := ["#6a8a70", "#a8c8a0", "#d8f0c8", "#ffffff"]
const P_CRYSTAL := ["#0a2a36", "#12566a", "#1f8a9a", "#5cc8cc", "#b8f4f0"]
const P_ROOT := ["#2a1810", "#4a2c1a", "#6e4426", "#9a6636"]
const P_RADICE := ["#4a2c22", "#6a3e2c", "#8a5638", "#a8704a", "#c89066"]
const P_SCISTO := ["#263a40", "#34505a", "#446872", "#58848c", "#7aa6aa"]
const P_GRASS_SPORE := ["#2a1640", "#43235e", "#633a86", "#8a58b4", "#c49af0"]
const P_GRASS_AMBRA := ["#4a3210", "#6e4c16", "#9a7022", "#c89a3a", "#f0d27a"]
const P_GRASS_BRINA := ["#1c3048", "#2a4a6a", "#44729a", "#7aaed0", "#d0f0ff"]
const P_GRASS_CENERE := ["#3a2a30", "#5a3e44", "#7e565a", "#a8766e", "#e0a888"]
const P_AVV_TERRA := ["#2e2a28", "#433d38", "#5a534b", "#736a5e", "#8e8574"]
const P_AVV_MUSCHIO := ["#2a2a22", "#3e3d30", "#57553f", "#72704f", "#949060"]
const P_AVV_PIETRA := ["#2a2c30", "#3c3f45", "#51555c", "#686d74", "#858a90"]
const P_SEM := ["#2c3a3a", "#405656", "#587270", "#74908c", "#9cb6b0"]
const P_NODO := ["#3a3832", "#54524a", "#6e6c60", "#8a887a", "#a8a694"]
const P_VUOTITE := ["#34284a", "#463662", "#5a467c", "#745c9c", "#967cc4"]

## Strati del terreno dai contorni morbidi, dal basso verso l'alto: ogni strato disegna la forma morbida delle celle
## dei tipi elencati. Il primo è la sagoma di tutto il terreno.
const TERRAIN_LAYERS := [
	{"id": "ardesia", "types": [DIRT, GRASS, STONE, RADICITE, LEGNOFERRO, AMBRA, CRYSTAL, RADICE, SCISTO, VUOTITE, NODO,
		PIETRA_SEM, GRASS_SPORE, GRASS_AMBRA, AVV_TERRA, AVV_MUSCHIO, AVV_PIETRA, PALLIDITE, TIZZONITE, GRASS_BRINA,
		GRASS_CENERE],
		"pal": P_STONE},
	{"id": "humus", "types": [DIRT, GRASS, GRASS_SPORE, GRASS_AMBRA, GRASS_BRINA, GRASS_CENERE], "pal": P_DIRT},
	{"id": "terra_avv", "types": [AVV_TERRA, AVV_MUSCHIO], "pal": P_AVV_TERRA},
	{"id": "muschio", "types": [GRASS], "pal": P_GRASS},
	{"id": "muschio_spore", "types": [GRASS_SPORE], "pal": P_GRASS_SPORE},
	{"id": "erba_ambra", "types": [GRASS_AMBRA], "pal": P_GRASS_AMBRA},
	{"id": "muschio_brina", "types": [GRASS_BRINA], "pal": P_GRASS_BRINA},
	{"id": "cenere_viva", "types": [GRASS_CENERE], "pal": P_GRASS_CENERE},
	{"id": "muschio_avv", "types": [AVV_MUSCHIO], "pal": P_AVV_MUSCHIO},
	{"id": "pietra_avv", "types": [AVV_PIETRA], "pal": P_AVV_PIETRA},
	{"id": "radice", "types": [RADICE], "pal": P_RADICE},
	{"id": "scisto", "types": [SCISTO], "pal": P_SCISTO},
	{"id": "vuotite", "types": [VUOTITE], "pal": P_VUOTITE},
	{"id": "nodo", "types": [NODO], "pal": P_NODO},
	{"id": "pietra_sem", "types": [PIETRA_SEM], "pal": P_SEM},
	{"id": "radicite", "types": [RADICITE], "pal": P_RADICITE},
	{"id": "legnoferro", "types": [LEGNOFERRO], "pal": P_LEGNOFERRO},
	{"id": "ambra", "types": [AMBRA], "pal": P_AMBRA},
	{"id": "pallidite", "types": [PALLIDITE], "pal": P_PALLIDITE},
	{"id": "tizzonite", "types": [TIZZONITE], "pal": P_TIZZONITE},
	{"id": "assi", "types": [ASSI], "pal": P_ASSI, "square": true},
	{"id": "mattoni", "types": [MATTONI], "pal": P_MATTONI, "square": true},
	{"id": "vetro", "types": [VETRO], "pal": P_VETRO, "square": true},
	{"id": "cristallo", "types": [CRYSTAL], "pal": P_CRYSTAL, "glow": true},
]

## Colore sulla mappa (strumenti e, in futuro, minimappa).
const MAP_COLOR := {DIRT: "#50343c", GRASS: "#3aa08a", STONE: "#434f6c", RADICITE: "#d4783a", LEGNOFERRO: "#a2b0c2", AMBRA: "#eec04a", CRYSTAL: "#3ac0c8",
	RADICE: "#8a5638", SCISTO: "#32687c", VUOTITE: "#463464", NODO: "#ff40a0",
	PIETRA_SEM: "#e8fff8", GRASS_SPORE: "#8a58b4", GRASS_AMBRA: "#c89a3a", GRASS_BRINA: "#7aaed0", GRASS_CENERE: "#a8766e",
	AVV_TERRA: "#5a534b", AVV_MUSCHIO: "#72704f", AVV_PIETRA: "#51555c", PALLIDITE: "#c4c4dc", TIZZONITE: "#e0582a",
	ASSI: "#7a5462", MATTONI: "#62779c", VETRO: "#d8f0c8", PORTA: "#9a7080"}


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
		PIETRA_SEM:
			return Px.pal(P_SEM)
		GRASS_SPORE:
			return Px.pal(P_GRASS_SPORE)
		GRASS_AMBRA:
			return Px.pal(P_GRASS_AMBRA)
		GRASS_BRINA:
			return Px.pal(P_GRASS_BRINA)
		GRASS_CENERE:
			return Px.pal(P_GRASS_CENERE)
		AVV_TERRA:
			return Px.pal(P_AVV_TERRA)
		AVV_MUSCHIO:
			return Px.pal(P_AVV_MUSCHIO)
		AVV_PIETRA:
			return Px.pal(P_AVV_PIETRA)
		PALLIDITE:
			return Px.pal(P_PALLIDITE)
		TIZZONITE:
			return Px.pal(P_TIZZONITE)
		ASSI, PORTA:
			return Px.pal(P_ASSI)
		MATTONI:
			return Px.pal(P_MATTONI)
		VETRO:
			return Px.pal(P_VETRO)
	return Px.pal(P_STONE)


static func dust_colors(type: int) -> Array[Color]:
	return palette_of(type)


## È una delle erbe (muschio, muschio di spore, erba d'ambra)? Ci crescono alberi e germogli.
static func is_grass(t: int) -> bool:
	return t in GRASSES


## Che cosa diventa una tessera toccata dall'Avvizzimento (-1 = non si ammala).
static func blighted_of(t: int) -> int:
	match t:
		DIRT:
			return AVV_TERRA
		GRASS, GRASS_SPORE, GRASS_AMBRA, GRASS_BRINA, GRASS_CENERE:
			return AVV_MUSCHIO
		STONE:
			return AVV_PIETRA
	return -1
