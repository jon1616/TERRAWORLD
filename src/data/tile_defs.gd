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
# voce 64: i Sigilli, che solo un potere del Germogliato apre (clic destro: `Powers.open_seal`); il piccone non li scalfisce
const SIG_VELATO := 26                 # sembra ardesia: la Vista della Linfa lo mostra
const SIG_RADICE := 27                 # radice intrecciata a rune: Canto delle radici
const SIG_VUOTO := 28                  # velo del Vuoto: Passo nel Vuoto
const SIG_BRACE := 29                  # muro di brace: Pelle di brace
const PORTA_SEM := 30                  # voce 71: porta dei Seminatori, si apre risolvendo l'enigma del luogo
const PIETRA_BRACE := 31               # voce 74: la brace spenta dall'acqua
## voce 96: la parete finta. Sembra ardesia in tutto (disegno, mappa, nome) ma crolla appena ci spingi contro
## (`Secrets`). Il numero viene dopo le tessere dei biomi (32-46).
const FINTA := 47
## voce 128: i costrutti (blocchi da costruire forma × materiale): una tessera sola, e quale costrutto è lo dice
## `World.build` (`BuildData`); quella trasparente lascia passare la luce (vetrate, ambra, cristalli).
const COSTRUTTO := 48
const COSTRUTTO_T := 49
const TYPES_BASE := 31                 # le tessere scritte qui; quelle dei biomi nuovi vengono dopo (voce 91)
static var TYPES: int = _types()
const SEALS := {"velato": SIG_VELATO, "radice": SIG_RADICE, "vuoto": SIG_VUOTO, "brace": SIG_BRACE}
const SEAL_KIND := {SIG_VELATO: "velato", SIG_RADICE: "radice", SIG_VUOTO: "vuoto", SIG_BRACE: "brace"}
const BUILT := [ASSI, MATTONI, VETRO, COSTRUTTO, COSTRUTTO_T]
const BLIGHTED := [AVV_TERRA, AVV_MUSCHIO, AVV_PIETRA]
## Le erbe: una per bioma di superficie (voce 91: le dice `BiomesData`).
static var GRASSES: Array = _grasses()

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
## La vegetazione dei biomi (26 set 2026, disegni in `BiomeDecorArt`): erbe bassissime e piante di ogni bioma.
## Voce 91: le dicono i file dei biomi (campo `decor`); `DECOR_BASE` = le decorazioni scritte qui.
static var DECOR_BIOME_GRASS: Array = _biome_decor("erba")
static var DECOR_BIOME_PLANTS: Array = _biome_decor("pianta")
const DECOR_BASE := 32
static var DECOR_COUNT: int = _decor_count()
const DECOR_CEILING := [11, 12, 17, 22, 98, 99, 100]   # queste pendono dal blocco sopra (98-100: le corde, voce 415)

## Luce emessa dalle decorazioni (indice = id della decorazione): piccole pozze di luce nel buio, non lampioni
## (con il buio vero del 25 set 2026 una luce di 0,3 si vede per ~6 tessere).
const _DECOR_LIGHT := {
	4: Color(0.15, 0.4, 0.45), 5: Color(0.45, 0.3, 0.1), 6: Color(0.3, 0.15, 0.45),
	10: Color(0.25, 0.6, 0.85), 11: Color(0.2, 0.13, 0.04), 12: Color(0.17, 0.11, 0.03), 13: Color(0.3, 0.17, 0.5),
	15: Color(0.25, 0.14, 0.04), 16: Color(0.4, 0.18, 0.7), 17: Color(0.15, 0.5, 0.55),
	18: Color(0.2, 0.62, 0.6), 20: Color(0.14, 0.2, 0.1), 21: Color(0.75, 0.25, 0.3), 22: Color(0.3, 0.75, 0.8),
	28: Color(0.1, 0.3, 0.3), 30: Color(0.2, 0.5, 0.75), 31: Color(0.6, 0.25, 0.45), 32: Color(0.12, 0.45, 0.45),
	23: Color(0.45, 0.55, 0.15), 24: Color(0.55, 0.12, 0.12), 25: Color(0.12, 0.3, 0.6), 26: Color(0.35, 0.15, 0.55),
}
static var DECOR_LIGHT: Dictionary = _decor_light()


## Una decorazione «morbida» del pavimento (erba, fiori, felci, piante dei biomi): ci si può seminare sopra e le
## bestie che pascolano la mangiano.
static func is_soft_decor(d: int) -> bool:
	return d in DECOR_GRASS or d in DECOR_FLOWERS or d == DECOR_FERN or d in DECOR_BIOME_GRASS or d in DECOR_BIOME_PLANTS

## Secondi di scavo con il piccone di radicite.
const _HARD := {COSTRUTTO: 0.4, COSTRUTTO_T: 0.3, FINTA: 0.2, DIRT: 0.22, STONE: 0.38, RADICITE: 0.5, LEGNOFERRO: 0.6, AMBRA: 0.7, CRYSTAL: 0.8,
	RADICE: 0.45, SCISTO: 0.5, VUOTITE: 0.75, NODO: 9.0, PIETRA_SEM: 0.8,
	SIG_VELATO: 9.0, SIG_RADICE: 9.0, SIG_VUOTO: 9.0, SIG_BRACE: 9.0, PORTA_SEM: 9.0, PIETRA_BRACE: 3.0,
	AVV_TERRA: 0.25, AVV_MUSCHIO: 0.25, AVV_PIETRA: 0.42,
	PALLIDITE: 0.55, TIZZONITE: 0.8, ASSI: 0.3, MATTONI: 0.45, VETRO: 0.3, PORTA: 1.0}
## Forza di piccone minima (vedi la durezza in `MaterialsData`): radicite 35, legnoferro 45, ambra 55. L'ambra vuole il piccone
## di legnoferro, i cristalli di Linfa quello d'ambra: è il filo della progressione.
## Il Fondo (vuotite) vuole il piccone di legnoferro: non ci si arriva col primo corredo.
const _POWER := {COSTRUTTO: 0, COSTRUTTO_T: 0, FINTA: 0, DIRT: 0, STONE: 0, RADICITE: 0, LEGNOFERRO: 35, AMBRA: 45, CRYSTAL: 55, RADICE: 0, SCISTO: 0,
	VUOTITE: 45, NODO: 999, PIETRA_SEM: 0, SIG_VELATO: 999, SIG_RADICE: 999, SIG_VUOTO: 999, SIG_BRACE: 999, PORTA_SEM: 999, PIETRA_BRACE: 35,
	AVV_TERRA: 0, AVV_MUSCHIO: 0, AVV_PIETRA: 0, PALLIDITE: 35, TIZZONITE: 55, ASSI: 0, MATTONI: 0, VETRO: 0, PORTA: 999}
## Oggetto che si ottiene rompendo la tessera o raccogliendo la decorazione.
const _DROP := {FINTA: "ardesia", PIETRA_BRACE: "pietra_brace", DIRT: "humus", STONE: "ardesia", RADICITE: "minerale_radicite", LEGNOFERRO: "minerale_legnoferro",
	AMBRA: "minerale_ambra", CRYSTAL: "cristallo_linfa", RADICE: "radice_antica", SCISTO: "scisto", VUOTITE: "vuotite",
	NODO: "radice_antica", PIETRA_SEM: "pietra_seminatori",
	AVV_TERRA: "cenere_avvizzita", AVV_MUSCHIO: "cenere_avvizzita", AVV_PIETRA: "ardesia",
	PALLIDITE: "minerale_pallidite", TIZZONITE: "minerale_tizzonite", ASSI: "assi_lanterna", MATTONI: "mattoni_ardesia",
	VETRO: "vetro_resina", PORTA: "porta_lanterna"}
const _DECOR_DROP := {9: "fungo_brace", 10: "fungo_luminoso", 15: "seme_lanterna", 16: "scheggia_vuoto",
	21: "cuore_bocciolo", 22: "stilla_perenne", 23: "brillaluce", 24: "sanguinella", 25: "lagunite", 26: "nottilite"}

## Vene di minerale (lette da `PassMinerali`): tessera, profondità minima, strati in cui compare (vedi `StrataData`),
## in quali rocce, frequenza e soglia del rumore (soglia più alta = vene più rare).
const _ORES := [
	{"type": RADICITE, "min_depth": 4, "strata": [0, 1, 2], "in": [DIRT, STONE], "freq": 0.11, "threshold": 0.5},
	{"type": LEGNOFERRO, "min_depth": 60, "strata": [1, 2, 3], "in": [STONE, SCISTO], "freq": 0.12, "threshold": 0.52},
	{"type": AMBRA, "min_depth": 200, "strata": [2, 3, 4], "in": [STONE, SCISTO, VUOTITE], "freq": 0.13, "threshold": 0.54},
	{"type": PALLIDITE, "min_depth": 30, "strata": [1, 2], "in": [STONE, RADICE], "freq": 0.12, "threshold": 0.56},
	{"type": TIZZONITE, "min_depth": 300, "strata": [3, 4], "in": [SCISTO, VUOTITE, STONE], "freq": 0.13, "threshold": 0.57},
]
## Roadmap 52: più le vene e le sacche dei pacchetti (campo «veins»: le terre comuni, i metalli della spina e del dopo con
## «vmin»/«vmax» = i vigori dei mondi in cui ci sono, le gemme).
static var ORES: Array = _ORES + BiomesData.pack_list("veins")
const _NAMES := {COSTRUTTO: "Costruzione", COSTRUTTO_T: "Vetrata", FINTA: "Ardesia", DIRT: "Humus", STONE: "Ardesia", RADICITE: "Radicite", LEGNOFERRO: "Legnoferro", AMBRA: "Ambra fossile", CRYSTAL: "Cristallo di Linfa",
	RADICE: "Radice antica", SCISTO: "Scisto di Linfa", VUOTITE: "Vuotite", NODO: "Nodo avvizzito",
	PIETRA_SEM: "Pietra dei Seminatori",
	AVV_TERRA: "Terra avvizzita", AVV_MUSCHIO: "Muschio avvizzito", AVV_PIETRA: "Ardesia avvizzita",
	PALLIDITE: "Pallidite", TIZZONITE: "Tizzonite", ASSI: "Assi di lanterna", MATTONI: "Mattoni d'ardesia",
	VETRO: "Vetro di resina", PORTA: "Porta", PORTA_SEM: "Porta dei Seminatori", PIETRA_BRACE: "Pietra di brace", SIG_VELATO: "Sigillo velato", SIG_RADICE: "Sigillo di radice",
	SIG_VUOTO: "Velo del Vuoto", SIG_BRACE: "Muro di brace"}

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
const P_PIETRA_BRACE := ["#1e1216", "#2e1a1c", "#442424", "#5e3028", "#7c4030"]

## Strati del terreno dai contorni morbidi, dal basso verso l'alto: ogni strato disegna la forma morbida delle celle
## dei tipi elencati. Il primo è la sagoma di tutto il terreno.
const _TERRAIN_LAYERS := [
	{"id": "ardesia", "types": [FINTA, DIRT, STONE, RADICITE, LEGNOFERRO, AMBRA, CRYSTAL, RADICE, SCISTO, VUOTITE, NODO,
		PIETRA_SEM, AVV_TERRA, AVV_MUSCHIO, AVV_PIETRA, PALLIDITE, TIZZONITE, SIG_VELATO, SIG_RADICE, SIG_VUOTO, SIG_BRACE, PORTA_SEM, PIETRA_BRACE],
		"pal": P_STONE},
	{"id": "humus", "types": [DIRT], "pal": P_DIRT},
	{"id": "terra_avv", "types": [AVV_TERRA, AVV_MUSCHIO], "pal": P_AVV_TERRA},
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
	# voce 64: i Sigilli (il velato è ardesia vera e propria a vederlo; gli altri pietra lavorata con le rune accese)
	{"id": "sig_velato", "types": [SIG_VELATO], "pal": P_STONE},
	{"id": "sig_radice", "types": [SIG_RADICE], "pal": P_RADICE, "square": true, "glow": true},
	{"id": "sig_vuoto", "types": [SIG_VUOTO], "pal": P_VUOTITE, "square": true, "glow": true},
	{"id": "sig_brace", "types": [SIG_BRACE], "pal": P_TIZZONITE, "square": true, "glow": true},
	# voce 71: la porta dei Seminatori dei luoghi (pietra lavorata con le rune d'oro)
	{"id": "porta_sem", "types": [PORTA_SEM], "pal": P_SEM, "square": true, "glow": true},
	# voce 74: la pietra di brace (acqua sulla brace liquida): scura, con le braci ancora accese
	{"id": "pietra_brace", "types": [PIETRA_BRACE], "pal": P_PIETRA_BRACE, "glow": true},
]

## Colore sulla mappa (strumenti e, in futuro, minimappa).
const _MAP_COLOR := {COSTRUTTO: "#9a8aa0", COSTRUTTO_T: "#b8e0e0", FINTA: "#434f6c", DIRT: "#50343c", STONE: "#434f6c", RADICITE: "#d4783a", LEGNOFERRO: "#a2b0c2", AMBRA: "#eec04a", CRYSTAL: "#3ac0c8",
	RADICE: "#8a5638", SCISTO: "#32687c", VUOTITE: "#463464", NODO: "#ff40a0",
	PIETRA_SEM: "#e8fff8",
	AVV_TERRA: "#5a534b", AVV_MUSCHIO: "#72704f", AVV_PIETRA: "#51555c", PALLIDITE: "#c4c4dc", TIZZONITE: "#e0582a",
	ASSI: "#7a5462", MATTONI: "#62779c", VETRO: "#d8f0c8", PORTA: "#9a7080",
	SIG_VELATO: "#434f6c", SIG_RADICE: "#c8905a", SIG_VUOTO: "#b890ff", SIG_BRACE: "#ff7a30", PORTA_SEM: "#ffd24a", PIETRA_BRACE: "#5a2c24"}


static func palette_of(type: int) -> Array[Color]:
	if _EXTRA.has(type):
		return Px.pal(_EXTRA[type]["pal"])              # voci 91 e 94: le tessere dei biomi
	match type:
		DIRT:
			return Px.pal(P_DIRT)
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
		SIG_VELATO:
			return Px.pal(P_STONE)
		SIG_RADICE:
			return Px.pal(P_RADICE)
		SIG_VUOTO:
			return Px.pal(P_VUOTITE)
		SIG_BRACE:
			return Px.pal(P_TIZZONITE)
		PIETRA_SEM, PORTA_SEM:
			return Px.pal(P_SEM)
		PIETRA_BRACE:
			return Px.pal(P_PIETRA_BRACE)
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


# ---------------------------------------------------------------- Roadmap 52: il tipo e il comportamento delle tessere

## Il tipo di una tessera dei pacchetti: suolo, roccia, comune (le terre in sacche), minerale, gemma, blocco ("" le altre).
static var KIND: Dictionary = _kinds()
## Il comportamento (campi in cima a `tools/vastita_gen/terre.py`), in tabelle per numero di tessera: le leggono il
## movimento a ogni passo (`Player`, `Creature`), le cadute (`Life`), l'orto, le frane, il freddo, i passi, gli scoppi.
static var FALLS: PackedByteArray = _flag("cade")          # frana senza appoggio (`LivingEarth`)
static var QUIET: PackedByteArray = _flag("quiet")         # i passi non fanno rumore (`Senses`)
static var WARM: PackedByteArray = _flag("warm")           # scalda chi le sta vicino nel freddo (`Harshness`)
static var BLAST: PackedByteArray = _flag("blast")         # le esplosioni non la rompono (`Throwing`)
static var SLIP: PackedFloat32Array = _num("slip", 1.0)    # la presa del pavimento (il ghiaccio 0,12)
static var STICK: PackedFloat32Array = _num("stick", 1.0)  # la corsa sopra (il fango 0,55)
static var SOFT: PackedFloat32Array = _num("soft", 1.0)    # quanto resta della ferita di una caduta (la neve 0,35)
static var FERTILE: PackedFloat32Array = _num("fertile", 1.0)   # la crescita dell'orto piantato sopra
static var FOSSIL: PackedFloat32Array = _num("fossil", 0.0)     # la probabilità di un fossile scavandola
static var SUPPORT: Dictionary = _support()                # la roccia che regge una terra che frana
## Voce 413: le vene dei metalli della spina e del dopo «dormono» finché il Cuore non si risveglia (`CuoreDesto.apply`
## accende `awake_on`, come `CreaturesData.awake_on`): si vedono, ma danno solo la roccia.
static var DORMANT: PackedByteArray = _flag("dorme")
## Voce 415: i blocchi con una fisica (i campi dei blocchi in `tools/vastita_gen/terre.py`).
static var BOUNCE: PackedFloat32Array = _num("bounce", 0.0)     # chi ci cade sopra rimbalza (`Player`)
static var FRAGILE: PackedFloat32Array = _num("fragile", 0.0)   # secondi prima che crolli sotto chi ci sta (`Grounds`)
static var SPIKE: PackedFloat32Array = _num("spike", 0.0)       # la ferita alle creature che lo toccano (`Grounds`)
static var LIQ_PASS: PackedByteArray = _flag("liq")             # i liquidi ci passano attraverso (`Liquids`)
## Le corde (campo «climbs» dei pacchetti: {decorazione: {item, speed}}): ci si arrampica (`Player._climb_step`).
static var CLIMBS: Dictionary = BiomesData.pack("climbs")
static var CLIMB_SPEED: PackedFloat32Array = _climb_speed()
static var DECOR_DROP: Dictionary = _decor_drop()
## Voce 416: le passerelle (campo «plats»: {tipo: {item, name, pal, soft, bounce, spike, slip, jump}}); il tipo 1 è la
## Passerella di radice di sempre. Tabelle per tipo, lette come quelle delle tessere.
static var PLATS: Dictionary = BiomesData.pack("plats")
## Voce 418: le spine dei biomi e la ragnatela (campo «thorns»: {decorazione: {id, name, biomes, mult, slow, poison,
## shatter, web, drop}}), toccate da `Hazards`, messe da `PassSpine`, disegnate da `ThornArt`.
static var THORNS: Dictionary = BiomesData.pack("thorns")
static var PLAT_SOFT: PackedFloat32Array = _plat_num("soft", 1.0)
static var PLAT_BOUNCE: PackedFloat32Array = _plat_num("bounce", 0.0)
static var PLAT_SPIKE: PackedFloat32Array = _plat_num("spike", 0.0)
static var PLAT_SLIP: PackedFloat32Array = _plat_num("slip", 1.0)
static var PLAT_JUMP: PackedFloat32Array = _plat_num("jump", 1.0)


static func _plat_num(key: String, def: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(16)
	out.fill(def)
	for k in PLATS:
		if PLATS[k].has(key):
			out[int(k)] = float(PLATS[k][key])
	return out


## L'oggetto che lascia una passerella di questo tipo.
static func plat_item(kind: int) -> String:
	return String(PLATS.get(kind, {}).get("item", "passerella"))


static func _climb_speed() -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(256)
	for d in CLIMBS:
		out[int(d)] = float(CLIMBS[d]["speed"])
	return out


## Ciò che lascia ogni decorazione tolta: quelle scritte qui più le corde.
static func _decor_drop() -> Dictionary:
	var out := _DECOR_DROP.duplicate()
	for d in CLIMBS:
		out[int(d)] = String(CLIMBS[d]["item"])
	var th: Dictionary = BiomesData.pack("thorns")
	for d in th:
		if String(th[d].get("drop", "")) != "":
			out[int(d)] = String(th[d]["drop"])         # voce 418: la ragnatela lascia seta
	return out
static var awake_on := false


## Ciò che lascia una tessera rotta adesso (le vene che dormono danno l'ardesia).
static func drop_of(t: int) -> String:
	if DORMANT[t] == 1 and not awake_on:
		return "ardesia"
	return String(DROP.get(t, ""))


static func kind_of(t: int) -> String:
	return String(KIND.get(t, ""))


static func _kinds() -> Dictionary:
	var out := {}
	var ex := _extra()
	for t in ex:
		if ex[t].has("kind"):
			out[int(t)] = String(ex[t]["kind"])
	return out


static func _flag(key: String) -> PackedByteArray:
	var out := PackedByteArray()
	out.resize(256)
	var ex := _extra()
	for t in ex:
		if ex[t].get(key, false):
			out[int(t)] = 1
	return out


static func _num(key: String, def: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(256)
	out.fill(def)
	var ex := _extra()
	for t in ex:
		if ex[t].has(key):
			out[int(t)] = float(ex[t][key])
	return out


static func _support() -> Dictionary:
	var out := {}
	var ex := _extra()
	for t in ex:
		if ex[t].has("support"):
			out[int(t)] = int(ex[t]["support"])
	return out


## È una delle erbe (muschio, muschio di spore, erba d'ambra)? Ci crescono alberi e germogli.
static func is_grass(t: int) -> bool:
	return t in GRASSES


## Che cosa diventa una tessera toccata dall'Avvizzimento (-1 = non si ammala).
static func blighted_of(t: int) -> int:
	if is_grass(t):
		return AVV_MUSCHIO
	var k := kind_of(t)                       # Roadmap 52: le terre e le rocce dei biomi si ammalano come humus e ardesia
	if k == "suolo":
		return AVV_TERRA
	if k == "roccia" or k == "comune":
		return AVV_PIETRA
	match t:
		DIRT:
			return AVV_TERRA
		STONE:
			return AVV_PIETRA
	return -1



# ---------------------------------------------------------------- voci 91 e 94: le tabelle che nascono dai biomi

## Le tessere che portano i biomi: le erbe dei biomi di superficie e le tessere nuove dei biomi del sottosuolo (campo
## `tiles`), tutte nella stessa forma: {name, hard, power, drop, pal, layer, specks, grass, square, glow}.
static func _extra() -> Dictionary:
	var out := {}
	for b in BiomesData.BIOMES:
		var t: Dictionary = b["turf"]
		out[int(b["grass"])] = {"name": t["name"], "hard": 0.22, "power": 0, "drop": "humus", "pal": t["pal"],
			"layer": t["layer"], "specks": int(t.get("specks", 0)), "grass": true}
	var tiles := BiomesData.pack("tiles")
	for k in tiles:
		out[int(k)] = tiles[k]
	return out


static func _tile_of() -> Dictionary:
	var out := {}
	for t in DROP:
		if not out.has(String(DROP[t])):
			out[String(DROP[t])] = int(t)
	return out


static func _types() -> int:
	var n := maxi(TYPES_BASE, COSTRUTTO_T)
	for t in _extra():
		n = maxi(n, int(t))
	return n


static func _grasses() -> Array:
	var out := []
	var ex := _extra()
	for t in ex:
		if ex[t].get("grass", false):
			out.append(int(t))
	return out


## Una tabella scritta a mano più una voce per ogni tessera dei biomi (il campo `key` della tessera).
static func _with_tiles(base: Dictionary, key: String) -> Dictionary:
	var out := base.duplicate()
	var ex := _extra()
	for t in ex:
		out[int(t)] = ex[t][key] if key != "map" else String(ex[t]["pal"][3])
	return out


static var HARD: Dictionary = _with_tiles(_HARD, "hard")
static var POWER: Dictionary = _with_tiles(_POWER, "power")
static var DROP: Dictionary = _with_tiles(_DROP, "drop")
static var NAMES: Dictionary = _with_tiles(_NAMES, "name")
## Roadmap 52: la tessera che lascia un oggetto (il contrario di DROP, per le schede: le tessere sono più di cento).
static var TILE_OF: Dictionary = _tile_of()
static var MAP_COLOR: Dictionary = _with_tiles(_MAP_COLOR, "map")
static var TERRAIN_LAYERS: Array = _layers()
## Roadmap 16: quanto la luce attraversa ogni tessera solida (0,5 la roccia; le nuvole la lasciano passare) e la luce
## che fanno da sé (cristallo celeste, polvere di stelle): campi "pass" ed "emit" delle tessere dei pacchetti.
static var LIGHT_PASS: PackedFloat32Array = _light_pass()
static var LIGHT_EMIT: PackedColorArray = _light_emit()
static var _EXTRA: Dictionary = _extra()


## Gli strati del terreno: quelli scritti a mano; le tessere dei biomi nella sagoma (tranne le squadrate) e le erbe
## sotto l'humus; uno strato per erba dopo la terra avvizzita (nell'ordine dei biomi), poi quelli del sottosuolo.
static func _layers() -> Array:
	var out := []
	var ex := _extra()
	for l in _TERRAIN_LAYERS:
		var e: Dictionary = (l as Dictionary).duplicate(true)
		for t in ex:
			if (e["id"] == "ardesia" and not ex[t].get("square", false)) or (e["id"] == "humus" and ex[t].get("grass", false)):
				(e["types"] as Array).append(int(t))
		out.append(e)
		if e["id"] == "terra_avv":
			for b in BiomesData.BIOMES:
				out.append({"id": String(b["turf"]["layer"]), "types": [int(b["grass"])], "pal": b["turf"]["pal"]})
	var tiles := BiomesData.pack("tiles")
	for t in tiles:
		var d: Dictionary = tiles[t]
		var l2 := {"id": String(d["layer"]), "types": [int(t)], "pal": d["pal"]}
		if d.get("square", false):
			l2["square"] = true
		if d.get("glow", false):
			l2["glow"] = true
		out.append(l2)
	return out


## Lo strato del terreno di una tessera dei biomi (per la trama: i puntini chiari).
static func turf_of_layer(layer: String) -> Dictionary:
	for t in _EXTRA:
		if _EXTRA[t]["layer"] == layer:
			return _EXTRA[t]
	return {}


## Le decorazioni dei biomi, di superficie e del sottosuolo.
static func _all_decor() -> Dictionary:
	var out := {}
	for b in BiomesData.BIOMES + BiomesData.UNDER + BiomesData.SKY:
		out.merge(b.get("decor", {}))
	return out


static func _biome_decor(soft: String) -> Array:
	var out := []
	var all := _all_decor()
	for d in all:
		if String(all[d].get("soft", "")) == soft:
			out.append(int(d))
	return out


static func _decor_count() -> int:
	var n := maxi(DECOR_BASE, PodsData.LAST)            # voce 301: i baccelli dormienti (92-97)
	for d in BiomesData.pack("climbs"):                 # voce 415: le corde (98-100)
		n = maxi(n, int(d))
	for d in BiomesData.pack("thorns"):                 # voce 418: le spine e la ragnatela (101-105)
		n = maxi(n, int(d))
	for d in _all_decor():
		n = maxi(n, int(d))
	return n


static func _decor_light() -> Dictionary:
	var out := _DECOR_LIGHT.duplicate()
	for d in PodsData.KINDS:                            # voce 301: i baccelli che brillano appena
		if PodsData.KINDS[d].has("light"):
			out[int(d)] = PodsData.KINDS[d]["light"]
	var all := _all_decor()
	for d in all:
		if all[d].has("light"):
			out[int(d)] = all[d]["light"]
	return out


static func _light_pass() -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(256)
	out.fill(0.5)
	var ex := _extra()
	for t in ex:
		if ex[t].has("pass"):
			out[int(t)] = float(ex[t]["pass"])
	return out


static func _light_emit() -> PackedColorArray:
	var out := PackedColorArray()
	out.resize(256)
	out.fill(Color(0, 0, 0))
	var ex := _extra()
	for t in ex:
		if ex[t].has("emit"):
			var e: Array = ex[t]["emit"]
			out[int(t)] = Color(float(e[0]), float(e[1]), float(e[2]))
	return out
