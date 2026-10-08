class_name PassStradeRiapri
extends GenPass
## Voce 453: la strada del sottosuolo riaperta dove le strutture costruite dopo di lei l'hanno chiusa (`PassStrade.reopen`).
## Prima della partenza e del collaudatore.


func title() -> String:
	return "Strada riaperta"


func run(w: World, c: GenContext) -> void:
	PassStrade.reopen(w, c)
