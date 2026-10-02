class_name GradeData
extends RefCounted
## Roadmap 33, voce 324: la tinta di ogni zona (una correzione di colore a tutto schermo, `ZoneGrade`). Solo dati.
##   shadow    il colore delle ombre: moltiplica le parti scure (il nero resta nero: il buio pieno non si alza)
##   gain      il colore delle luci: moltiplica tutto
##   sat       la saturazione (1 = com'è)
##   contrast  il contrasto attorno al grigio medio (1 = com'è)
## Sotto terra conta lo strato; in superficie l'elemento del bioma (`BiomesData`, campo "elem").

const NEUTRAL := {"shadow": Color(1, 1, 1), "gain": Color(1, 1, 1), "sat": 1.0, "contrast": 1.0}

## Gli strati (indice = `StrataData`): superficie, Sottobosco, Caverne d'ardesia, Profondità della Linfa, il Fondo.
const STRATA := [
	{"shadow": Color(0.95, 1.0, 1.05), "gain": Color(1.02, 1.01, 0.98), "sat": 1.06, "contrast": 1.02},
	{"shadow": Color(1.1, 0.9, 0.98), "gain": Color(1.03, 0.99, 0.96), "sat": 1.0, "contrast": 1.05},
	{"shadow": Color(0.85, 0.95, 1.16), "gain": Color(0.98, 1.0, 1.04), "sat": 0.92, "contrast": 1.07},
	{"shadow": Color(0.84, 1.08, 1.08), "gain": Color(0.98, 1.03, 1.03), "sat": 1.06, "contrast": 1.05},
	{"shadow": Color(1.03, 0.85, 1.2), "gain": Color(1.0, 0.97, 1.04), "sat": 0.96, "contrast": 1.1},
]

## La superficie, secondo l'elemento del bioma.
const ELEMENTS := {
	"brace": {"shadow": Color(1.14, 0.95, 0.84), "gain": Color(1.05, 1.0, 0.92), "sat": 1.05, "contrast": 1.05},
	"gelo": {"shadow": Color(0.88, 0.98, 1.16), "gain": Color(0.97, 1.0, 1.05), "sat": 0.95, "contrast": 1.03},
	"spora": {"shadow": Color(1.03, 0.94, 1.1), "gain": Color(1.0, 1.0, 1.0), "sat": 1.04, "contrast": 1.03},
	"linfa": {"shadow": Color(0.9, 1.07, 1.06), "gain": Color(0.99, 1.02, 1.02), "sat": 1.06, "contrast": 1.02},
	"vuoto": {"shadow": Color(1.0, 0.88, 1.13), "gain": Color(0.99, 0.97, 1.03), "sat": 0.96, "contrast": 1.06},
	"luce": {"shadow": Color(1.04, 1.0, 0.92), "gain": Color(1.05, 1.03, 0.95), "sat": 1.05, "contrast": 1.02},
}
const FADE := 2.0                      # secondi per passare da una tinta all'altra


## La tinta di una zona.
static func of(stratum: int, elem: String) -> Dictionary:
	if stratum <= 0:
		return ELEMENTS.get(elem, STRATA[0])
	return STRATA[clampi(stratum, 0, STRATA.size() - 1)]
