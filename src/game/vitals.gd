class_name Vitals
extends RefCounted
## Vita e Linfa del Germogliato (solo regole, nessun disegno). La Vita si mostra come foglie (10 punti l'una), la Linfa
## come gocce. La Scorza (difesa, dall'equipaggiamento) toglie metà del suo valore a ogni ferita, come una corteccia.
## La Vita ricresce da sola dopo qualche secondo senza ferite; la Linfa sempre.

signal changed
signal died

const HP_MAX := 100
const LINFA_MAX := 20
const REGEN_DELAY := 6.0              # secondi senza ferite prima che la Vita ricresca
const REGEN := 2.0                    # punti di Vita al secondo, dopo l'attesa
const LINFA_REGEN := 1.5              # punti di Linfa al secondo
const POTION_COOLDOWN := 30.0

var hp := HP_MAX
var hp_max := HP_MAX                   # HP_MAX più i doni duraturi (il Guardiano curato: +20)
var linfa := LINFA_MAX
var scorza := 0
var scorza_bonus := 0
var regen_mult := 1.0                  # accessori: la Vita ricresce più in fretta (e l'attesa si accorcia)                  # dalle pozioni (vedi `Boons`)
var potion_wait := 0.0
var _since_hit := 99.0
var _acc := 0.0
var _lacc := 0.0


## Ferita: restituisce i punti tolti davvero (almeno 1).
func hurt(amount: int) -> int:
	if hp <= 0:
		return 0
	var real := maxi(amount - (scorza + scorza_bonus) / 2, 1)
	hp = maxi(hp - real, 0)
	_since_hit = 0.0
	changed.emit()
	if hp == 0:
		died.emit()
	return real


func heal(amount: int) -> void:
	hp = mini(hp + amount, hp_max)
	changed.emit()


func refill() -> void:
	hp = hp_max
	linfa = LINFA_MAX
	_since_hit = 99.0
	changed.emit()


func tick(dt: float) -> void:
	if hp <= 0:
		return
	var before := [hp, linfa]
	_since_hit += dt
	potion_wait = maxf(potion_wait - dt, 0.0)
	if _since_hit >= REGEN_DELAY / regen_mult and hp < hp_max:
		_acc += REGEN * regen_mult * dt
		var k := int(_acc)
		_acc -= k
		hp = mini(hp + k, hp_max)
	if linfa < LINFA_MAX:
		_lacc += LINFA_REGEN * dt
		var k2 := int(_lacc)
		_lacc -= k2
		linfa = mini(linfa + k2, LINFA_MAX)
	if before != [hp, linfa]:
		changed.emit()
