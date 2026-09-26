class_name BreedData
extends RefCounted
## L'allevamento (voce 60, Roadmap 7): le doti che una creatura della mandria porta nel sangue e passa ai figli.
## Solo dati; le regole stanno in `Breeding`.
##
## Doti (nella scheda, `rec["doti"]`):
##   vita, danno, resa   numeri (1 = come la specie): i figli prendono la media dei genitori, con un poco di
##                       deriva e a volte un salto (`JUMP`); si alleva scegliendo i migliori, generazione dopo
##                       generazione, fino ai tetti di `STATS`
##   manto               il colore del mantello (`COATS`): i comuni si ereditano facilmente, i rari compaiono di rado
##                       e più spesso nelle stirpi lunghe; un genitore con un manto raro lo passa a metà dei figli
##   gen                 la generazione (0 = presa in natura): conta per i manti rari
##   gigante             rarissimo: la creatura è più grande e più forte
## La taglia, l'elemento e l'indole restano quelli della variante (`FamiliesData`): il figlio li prende da uno dei
## due genitori, e a volte (`PART_MUT`) ne esce uno nuovo.

const STATS := {
	"vita": {"name": "Vita", "min": 0.7, "max": 1.8},
	"danno": {"name": "Forza", "min": 0.7, "max": 1.8},
	"resa": {"name": "Resa", "min": 0.7, "max": 2.0},
}

## Manti. chance = probabilità che compaia in un figlio (i rari crescono con la generazione), tint/amount = colore
## (`VariantArt`), glow = il corpo brilla, bonus = doti moltiplicate, min_gen = generazione minima per comparire.
const COATS := {
	"": {"name": "comune"},
	"chiaro": {"name": "chiaro", "tint": Color("#f4ecd8"), "amount": 0.35, "chance": 0.10},
	"scuro": {"name": "scuro", "tint": Color("#3c2c44"), "amount": 0.4, "chance": 0.10},
	"fulvo": {"name": "fulvo", "tint": Color("#e0903c"), "amount": 0.4, "chance": 0.10},
	"muschiato": {"name": "muschiato", "tint": Color("#5ec8a0"), "amount": 0.4, "chance": 0.08},
	"albino": {"name": "albino", "rare": true, "tint": Color(1, 1, 1), "amount": 0.8, "chance": 0.03,
		"bonus": {"resa": 1.15}},
	"ombra": {"name": "d'ombra", "rare": true, "tint": Color("#1a1024"), "amount": 0.75, "chance": 0.025,
		"bonus": {"danno": 1.12}},
	"dorato": {"name": "dorato", "rare": true, "tint": Color("#ffd24a"), "amount": 0.7, "chance": 0.02, "glow": true,
		"bonus": {"resa": 1.3}},
	"cristallino": {"name": "cristallino", "rare": true, "tint": Color("#9ae8ff"), "amount": 0.7, "chance": 0.015,
		"glow": true, "bonus": {"vita": 1.2}},
	"stellato": {"name": "stellato", "rare": true, "tint": Color("#2a3a80"), "amount": 0.65, "chance": 0.01, "stars": true,
		"bonus": {"vita": 1.1, "danno": 1.1}, "min_gen": 2},
	"iridato": {"name": "iridato", "rare": true, "tint": Color("#ff9ae8"), "amount": 0.6, "chance": 0.006, "glow": true,
		"rainbow": true, "bonus": {"vita": 1.15, "danno": 1.15, "resa": 1.15}, "min_gen": 3},
}

const GIANT := 0.015                   # un figlio gigante (di più nelle stirpi lunghe)
const GIANT_SCALE := 1.3
const GIANT_BONUS := {"vita": 1.3, "danno": 1.2}
const DRIFT := 0.05                    # di quanto un numero può scostarsi dalla media dei genitori
const JUMP := 0.08                     # probabilità di un salto in su di un numero
const JUMP_SIZE := 0.15
const PART_MUT := 0.08                 # taglia, elemento o indole nuovi
const RARE_GEN := 0.25                 # +25% di probabilità di manto raro per ogni generazione
const RARE_INHERIT := 0.5              # un genitore raro passa il suo manto
const BREED_TIME := 480.0              # secondi di coppia contenta nello stesso recinto per un uovo
const COOLDOWN := 900.0                # secondi prima che la stessa coppia faccia un altro uovo
const MIN_LVL := 3                     # livello minimo per mettersi in coppia


static func coat(id: String) -> Dictionary:
	return COATS.get(id, COATS[""])


static func is_rare(id: String) -> bool:
	return coat(id).get("rare", false)
