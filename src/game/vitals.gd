class_name Vitals
extends RefCounted
## Vita e Linfa del Germogliato (solo regole, nessun disegno). La Vita si mostra come foglie (10 punti l'una), la Linfa
## come gocce. La Scorza (difesa, dall'equipaggiamento) toglie metà del suo valore a ogni ferita, come una corteccia.
## La Vita ricresce da sola dopo qualche secondo senza ferite; la Linfa sempre.

signal changed
signal died

const HP_MAX := 100
const LINFA_MAX := 20
const REGEN_DELAY := 10.0             # secondi senza ferite prima che la Vita ricresca (voce 20: prima 6, troppo facile)
const REGEN := 1.2                    # punti di Vita al secondo, dopo l'attesa (prima 2)
const LINFA_REGEN := 1.5              # punti di Linfa al secondo
const POTION_COOLDOWN := 30.0

signal wounded(amount: int)                 # voce 85: una ferita (gli effetti)
var hp := HP_MAX
var hp_max := HP_MAX                   # HP_MAX più i doni duraturi (il Guardiano curato: +20)
var linfa := LINFA_MAX
var linfa_max := LINFA_MAX             # LINFA_MAX più le Stille perenni assorbite (voce 21)
var scorza := 0
var scorza_bonus := 0
var set_scorza := 0                    # Scorza in più dei set completi (vedi `GearEffects`)
var regen_mult := 1.0
var effect_regen := 1.0                # voce 85: gli effetti (Radicato)
var death_guard: Callable              # voce 85: () -> true se un effetto salva dall'appassire (Seconda radice)
var boon_regen := 1.0                  # Pozione di rigoglio (vedi `Boons`)
var linfa_regen_mult := 1.0            # accessori: la Linfa ricresce più in fretta
var pet_linfa := 1.0                   # lo Spiritello di Linfa (voce 37)
var poison_t := 0.0                    # avvelenato da una creatura Velenosa: perde Vita per qualche secondo
var _pacc := 0.0
const POISON_DPS := 3.0                  # accessori: la Vita ricresce più in fretta (e l'attesa si accorcia)                  # dalle pozioni (vedi `Boons`)
var potion_wait := 0.0
var _since_hit := 99.0
var _acc := 0.0
var _lacc := 0.0


## Ferita: restituisce i punti tolti davvero (almeno 1).
func hurt(amount: int) -> int:
	if hp <= 0:
		return 0
	var real := maxi(amount - (scorza + scorza_bonus + set_scorza) / 2, 1)
	_since_hit = 0.0
	if hp - real <= 0 and death_guard.is_valid() and bool(death_guard.call()):
		changed.emit()
		wounded.emit(real)
		return real
	hp = maxi(hp - real, 0)
	changed.emit()
	wounded.emit(real)
	if hp == 0:
		died.emit()
	return real


func heal(amount: int) -> void:
	hp = mini(hp + amount, hp_max)
	changed.emit()


func refill() -> void:
	hp = hp_max
	linfa = linfa_max
	_since_hit = 99.0
	changed.emit()


func tick(dt: float) -> void:
	if hp <= 0:
		return
	var before := [hp, linfa]
	if poison_t > 0.0:
		poison_t -= dt
		_pacc += POISON_DPS * dt
		var pk := int(_pacc)
		if pk > 0:
			_pacc -= pk
			hp = maxi(hp - pk, 0)
			_since_hit = 0.0
			if hp == 0:
				changed.emit()
				died.emit()
				return
	_since_hit += dt
	potion_wait = maxf(potion_wait - dt, 0.0)
	if _since_hit >= REGEN_DELAY / (regen_mult * boon_regen * effect_regen) and hp < hp_max:
		_acc += REGEN * regen_mult * boon_regen * effect_regen * dt
		var k := int(_acc)
		_acc -= k
		hp = mini(hp + k, hp_max)
	if linfa < linfa_max:
		_lacc += LINFA_REGEN * linfa_regen_mult * pet_linfa * dt
		var k2 := int(_lacc)
		_lacc -= k2
		linfa = mini(linfa + k2, linfa_max)
	if before != [hp, linfa]:
		changed.emit()
