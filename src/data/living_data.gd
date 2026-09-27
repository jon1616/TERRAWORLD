class_name LivingData
## La terra viva (voce 77, Roadmap 10): mondi che cambiano mentre li si esplora, e anche quando non ci sei. Solo dati:
## li usa `LivingEarth`. Ogni legge è un gene (in `GenesData`, parte `run`):
##   regrow  (Radici vive)     i cunicoli scavati nel Sottobosco e sopra si richiudono di radice dopo `REGROW` secondi;
##                             li fermano la luce di una torcia vicina e le pareti costruite (le radici non le passano)
##   crystal (Cristalli vivi)  i cristalli di Linfa crescono di una tessera ogni `CRYSTAL_EVERY` secondi, e mentre sei
##                             via di una ogni `CRYSTAL_AWAY` secondi (al massimo `CRYSTAL_AWAY_MAX`)
##   falling (Frane)           la terra senza appoggio frana: humus ed erba cadono finché trovano un pavimento

const REGROW := 240.0                  # secondi di gioco (o di assenza) prima che una ferita si richiuda
const REGROW_RETRY := 60.0             # ferita tenuta aperta (torcia, parete, il Germogliato vicino): si riprova dopo
const REGROW_NEAR := 4                 # tessere: le radici non crescono addosso al Germogliato
const TORCH_KEEP := 3.5                # tessere: la luce di una torcia tiene lontane le radici
const MAX_WOUNDS := 4000
const MAX_STRATUM := 1                 # fino al Sottobosco di radici (0 = sotto la superficie, 1 = Sottobosco)

const CRYSTAL_EVERY := 20.0
const CRYSTAL_AWAY := 600.0
const CRYSTAL_AWAY_MAX := 150
const CRYSTAL_SEEDS := 500             # punti di crescita tenuti a mente (cristalli che toccano l'aria)

const FALL_STEP := 0.06                # secondi per tessera di una zolla che cade
const FALL_HURT := 4                   # una zolla che cade in testa
const FALLING := [TileDefs.DIRT, TileDefs.GRASS, TileDefs.GRASS_SPORE, TileDefs.GRASS_AMBRA, TileDefs.GRASS_BRINA,
	TileDefs.GRASS_CENERE, TileDefs.AVV_TERRA, TileDefs.AVV_MUSCHIO]

## Pareti costruite dal Germogliato: le radici non le attraversano.
const BUILT_WALLS := [TileDefs.WALL_ASSI, TileDefs.WALL_MATTONI]
