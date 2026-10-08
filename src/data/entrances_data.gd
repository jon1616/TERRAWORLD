class_name EntrancesData
extends RefCounted
## Gli ingressi del sottosuolo (voce 467, Roadmap 60 «La superficie da cartolina»): come si scende senza scavare per
## forza. Uno vicino alla partenza (sempre una galleria), poi uno ogni `EVERY` colonne, di una forma a caso secondo il
## peso (`w`). Li fa `PassIngressi`; una forma nuova = una riga qui e una funzione `_<id>` lì.
##   galleria  una galleria che scende serpeggiando (`steps` passi)
##   fianco    una caverna aperta sul fianco di un pendio: una sala (`size` = larghezza, altezza) con la bocca a valle
##   dolina    un imbuto largo `top` che si stringe in un pozzo profondo `depth`, con le liane sulle pareti
##   pozzo     un pozzo dritto largo 3 e profondo `depth`, con la liana lungo una parete
## Questo file non nomina altre classi.

const EVERY := [170, 250]
const SPAWN := {"x": 16, "steps": 75}
const KINDS := {
	"galleria": {"w": 4, "steps": [60, 170]},
	"fianco": {"w": 3, "size": [[18, 30], [9, 14]]},
	"dolina": {"w": 2, "top": [14, 24], "depth": [40, 70]},
	"pozzo": {"w": 2, "depth": [45, 90]},
}
