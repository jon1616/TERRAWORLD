class_name GardenIslandsData
extends RefCounted
## Le isole del Giardino (Roadmap 22, voce 228): nascono accanto all'isola dell'Albero-Madre quando la bellezza del
## Giardino (`GardenBeauty`, la più alta raggiunta) arriva alla loro soglia. Solo dati; le costruisce `GardenIslands`.
##   need   la bellezza che serve          dx, dy  il centro rispetto al centro del Giardino e alla sua superficie
##   half   mezza larghezza                bridge  "passerelle" (un ponte dall'isola grande) o "corrente" (sale da sotto)
##   gift   la cosa che c'è solo lì (la legge `GardenIslands`)

const ORDER := ["orto", "bestie", "bottega", "cielo"]

const ISLANDS := {
	"orto": {"name": "L'isola dell'orto", "need": 60, "dx": -175, "dy": 8, "half": 26, "bridge": "passerelle",
		"desc": "terra grassa e una polla d'acqua: le colture qui crescono una volta e mezza più in fretta", "gift": "orto"},
	"bestie": {"name": "L'isola delle bestie", "need": 150, "dx": 175, "dy": 6, "half": 26, "bridge": "passerelle",
		"desc": "un prato con un recinto e un'incubatrice: ogni giorno ci arriva una creatura mansueta da addomesticare",
		"gift": "bestie"},
	"bottega": {"name": "L'isola della bottega", "need": 300, "dx": -150, "dy": -48, "half": 20, "bridge": "corrente",
		"desc": "roccia viva: le sue vene di minerale ricrescono ogni giorno", "gift": "miniera"},
	"cielo": {"name": "L'isola del cielo", "need": 500, "dx": 150, "dy": -62, "half": 18, "bridge": "corrente",
		"desc": "un'isola di nuvole: ogni notte ci cade polvere di stelle", "gift": "stelle"},
}

## Le vene della miniera viva dell'isola della bottega: [tessera, quante al giorno].
const MINE := [[TileDefs.RADICITE, 10], [TileDefs.LEGNOFERRO, 8], [TileDefs.AMBRA, 5], [TileDefs.CRYSTAL, 3]]
const ORTO_GROW := 1.5
const STARS_PER_NIGHT := 4
