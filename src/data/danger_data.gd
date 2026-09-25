class_name DangerData
extends RefCounted
## Il pericolo di una zona (voce 20): un numero che dice quante creature ci possono essere, quanto spesso nascono e
## quanto sono frequenti le creature antiche. Dipende da dove si è, non da un valore unico per tutto il mondo:
## in superficie di giorno pochissime creature, di notte qualcuna in più, sempre di più scendendo, nel buio,
## nelle terre avvizzite e nei mondi più vigorosi. Solo dati e una funzione.
## Richiesta dell'utente (25 set 2026): «non voglio che in superficie mi nascano decine di mostri incessantemente:
## in base alla zona e alla sua difficoltà devo trovare pericoli adeguati».

## Pericolo di base di ogni strato (`StrataData`, stesso ordine).
const STRATUM := [1.0, 2.5, 3.5, 4.5, 5.5]
const NIGHT := 1.5                     # di notte, in superficie
const BLIGHT := 1.5                    # nelle terre avvizzite
const VIGOR := 1.0                     # per ogni punto di vigore oltre il primo
## Quante creature al massimo attorno al giocatore, per livello di pericolo (indice = pericolo arrotondato giù).
const CAP := [0, 2, 4, 5, 7, 8, 9, 10, 11, 12]
## Ogni quanto si prova a far nascere una creatura: SPAWN_EVERY / pericolo secondi.
const SPAWN_EVERY := 7.0
## Distanza in tessere: appena fuori dalla visuale (che è larga circa 50 tessere).
const SPAWN_MIN := 28
const SPAWN_MAX := 44
## Sotto terra le creature nascono solo al buio (luce vista sotto questa soglia): le torce sono un vero riparo.
const DARK := 0.15
## Moltiplicatore del danno delle creature (le ferite di prima erano troppo leggere).
const DAMAGE := 1.35


## Il pericolo in una cella del mondo.
static func at(w: World, c: Vector2i, night: bool, vigor: int) -> float:
	var s := StrataData.at(w, c.x, c.y)
	var d: float = STRATUM[s]
	if s == 0 and night:
		d += NIGHT
	if s == 0 and Blight.surface_blighted(w, c.x):
		d += BLIGHT
	d += VIGOR * (vigor - 1)
	return d


static func cap(danger: float) -> int:
	return CAP[clampi(floori(danger), 0, CAP.size() - 1)]
