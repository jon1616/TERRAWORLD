class_name CompanionsData
extends RefCounted
## I compagni (voce 37). Solo dati; li gestisce `Companions`.
##   PETS     compagni che seguono il Germogliato (si chiamano e si congedano con il clic sull'oggetto): uno alla volta,
##            ognuno con il suo dono: `light` (luce attorno), `magnet` (gli oggetti vengono attirati da più lontano),
##            `linfa` (la Linfa ricresce più in fretta)
##   ALLIES   creature alleate richiamate dai bastoni evocatori: combattono le creature vicine e poi tornano; `max`
##            quante insieme (più gli accessori con `allies`); costano Linfa a ogni richiamo.
## Campi degli alleati: art [forma, variante] di `CreatureArt`, tint (colore), fly, speed, damage, hp (solo per la
## barra), shoot (secondi tra un colpo e l'altro, 0 = mischia), size.

## Roadmap 43, voce 388: più gli animaletti dei pacchetti (campo «pets»; un dono anche in «acc», sommato da `GearEffects`).
static var PETS: Dictionary = _PETS.merged(BiomesData.pack("pets"))

const _PETS := {
	"lucciolina": {"name": "Lucciolina", "art": ["lucciola", 0], "light": Color(1.3, 1.4, 0.7), "fly": true},
	"grumetto": {"name": "Grumetto", "art": ["grumo", 0], "magnet": 2.2, "fly": false},
	"spiritello": {"name": "Spiritello di Linfa", "art": ["guizzalinfa", 0], "linfa": 1.3, "fly": true},
}

const ALLIES := {
	"grumo_amico": {"name": "Grumo amico", "art": ["grumo", 0], "tint": Color(0.7, 1.4, 1.1), "fly": false,
		"speed": 150.0, "damage": 10, "shoot": 0.0},
	"falena_amica": {"name": "Falena amica", "art": ["falena", 0], "tint": Color(1.3, 1.2, 0.9), "fly": true,
		"speed": 190.0, "damage": 16, "shoot": 0.0},
	"vagavuoto_amico": {"name": "Vagavuoto domato", "art": ["vagavuoto", 0], "tint": Color(1.1, 1.0, 1.4), "fly": true,
		"speed": 130.0, "damage": 22, "shoot": 1.2},
}

const MAX_ALLIES := 2
const SUMMON_LINFA := 10
const SIGHT := 14.0                    # tessere entro cui un alleato vede le creature
