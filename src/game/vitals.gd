class_name Vitals
extends RefCounted
## Vita e Linfa del Germogliato (solo regole, nessun disegno). La Vita si mostra come foglie (10 punti l'una), la Linfa
## come gocce. La Scorza (difesa, dall'equipaggiamento) toglie una parte di ogni ferita, come una corteccia (`reduce`).
## La Vita ricresce da sola dopo qualche secondo senza ferite; la Linfa sempre.

signal changed
signal died

const HP_MAX := 100
const LINFA_MAX := 20
const REGEN_DELAY := 10.0             # secondi senza ferite prima che la Vita ricresca (voce 20: prima 6, troppo facile)
const REGEN := 1.2                    # punti di Vita al secondo per 100 di Vita massima, dopo l'attesa (prima 2)
                                       # voce 185: cresce con la Vita massima (con 300 di Vita 3,6 al secondo), se no
                                       # i doni di Vita valevano solo per il primo colpo e la Vita non tornava più
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
var song_scorza := 0                   # voce 367: il Canto della scorza del tamburo (`Styles`)
var ability_scorza := 0                # voce 383: lo scudo di un'abilità (`Abilities`)
var regen_mult := 1.0
var effect_regen := 1.0                # voce 85: gli effetti (Radicato)
var zone_regen := 1.0                  # voce 87: lo Stendardo del riposo
var harsh_regen := 1.0                 # voce 93: la sete ferma la ricrescita
var death_guard: Callable              # voce 85: () -> true se un effetto salva dall'appassire (Seconda radice)
var boon_regen := 1.0                  # Pozione di rigoglio (vedi `Boons`)
var room_regen := 1.0                  # voce 142: dentro una casa la Vita ricresce più in fretta (`Rooms`)
var linfa_regen_mult := 1.0            # accessori: la Linfa ricresce più in fretta
var pet_linfa := 1.0                   # lo Spiritello di Linfa (voce 37)
var poison_t := 0.0                    # avvelenato da una creatura Velenosa: perde Vita per qualche secondo
var _pacc := 0.0
const POISON_DPS := 3.0                  # accessori: la Vita ricresce più in fretta (e l'attesa si accorcia)                  # dalle pozioni (vedi `Boons`)
var potion_wait := 0.0
var cause := ""                        # voce 188: di che cosa è stata l'ultima ferita (per il Diario)
var _since_hit := 99.0
var _acc := 0.0
var _lacc := 0.0


## Ferita: restituisce i punti tolti davvero (almeno 1). `why` = di che cosa (voce 188: il Diario conta di che cosa si
## appassisce, per bilanciare con le partite vere).
func hurt(amount: int, why := "altro") -> int:
	if hp <= 0:
		return 0
	cause = why
	var real := reduce(amount, scorza + scorza_bonus + set_scorza + song_scorza + ability_scorza)
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


## La ferita che resta dopo la Scorza (una regola sola: la usa anche `FightModel`, voce 179). Voce 184: la Scorza toglie
## una **parte** della ferita, SCORZA_K / (SCORZA_K + Scorza): con 10 di Scorza metà, con 30 tre quarti. Prima toglieva
## metà del suo valore: contava all'inizio e non contava più niente contro le creature forti (−14% nel Fondo al vigore
## 5 con lo stellare), e il giocatore non aveva motivo di equipaggiarsi.
const SCORZA_K := 10.0


static func reduce(amount: int, total_scorza: int) -> int:
	if amount <= 0:
		return 0
	return maxi(roundi(amount * SCORZA_K / (SCORZA_K + maxf(total_scorza, 0))), 1)


## La parte di ogni ferita che la Scorza toglie (0-1), per le schede.
static func scorza_share(total_scorza: int) -> float:
	return 1.0 - SCORZA_K / (SCORZA_K + maxf(total_scorza, 0))


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
			cause = "il veleno"
			_since_hit = 0.0
			if hp == 0:
				changed.emit()
				died.emit()
				return
	_since_hit += dt
	potion_wait = maxf(potion_wait - dt, 0.0)
	if harsh_regen > 0.0 and _since_hit >= REGEN_DELAY / (regen_mult * boon_regen * effect_regen * zone_regen * room_regen) and hp < hp_max:
		_acc += REGEN * hp_max / HP_MAX * regen_mult * boon_regen * effect_regen * zone_regen * harsh_regen * room_regen * dt
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
