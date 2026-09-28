class_name Mind
extends RefCounted
## Il cervello di una creatura (voce 129, Roadmap 15 «Il mondo abitato»): i **sensi** e gli **stati**, uguali per tutte.
## I comportamenti non cambiano: chiedono ancora `Behavior.sees`, che ora passa di qui.
## - Vista: la distanza del comportamento («sight»), accorciata dall'Ombra, dalla nebbia e dal **buio** attorno al
##   Germogliato (`lit`, lo misura `Senses`); chi vive solo sotto terra vede al buio.
## - Udito: scavo, colpi, esplosioni, passi di corsa lasciano un **rumore** (`noise`): chi lo sente va a guardare.
## - Olfatto: il Germogliato ferito (`blood`) si fiuta da lontano, anche al buio; un'esca in mano attira.
## - Stati: calma, allerta (va a vedere un punto), caccia (ti vede), fuga (ferita grave), ritorno (troppo lontana da casa).
## - Memoria: persa di vista, ti insegue ancora un poco, poi ti cerca dove ti ha visto l'ultima volta.

const CALM := "calma"
const ALERT := "allerta"
const HUNT := "caccia"
const FLEE := "fuga"
const HOME := "ritorno"
const NAMES := {CALM: "tranquilla", ALERT: "all'erta", HUNT: "a caccia", FLEE: "in fuga", HOME: "torna a casa"}

const DARK_SIGHT := 0.55                 # al buio pieno si vede a questa frazione della distanza
const MEMORY := 3.0                      # secondi in cui insegue ancora chi ha perso di vista
const MEMORY_REACH := 1.6                # … fino a questa volta la sua vista
const SEARCH := 5.0                      # secondi in cui cerca il punto dove ti ha visto (o sentito)
const SMELL_BLOOD := 14.0                # tessere: il Germogliato ferito si fiuta da qui
const BLOOD_BELOW := 0.35                # … sotto questa frazione della Vita
const BAIT_REACH := 10.0                 # tessere: un'esca in mano attira chi la fiuta
const FLEE_BELOW := 0.2                  # sotto questa frazione della Vita alcune fuggono
const FLEE_TIME := 4.0
const HOME_LEASH := 60.0                 # tessere dal punto in cui è nata oltre cui torna indietro
const LISTEN := 0.25                     # ogni quanto ascolta i rumori

## Le cose del mondo che tutti sentono (le scrive `Senses`).
static var lit := 1.0                    # 0-1: quanta luce c'è sul Germogliato
static var blood := false                # il Germogliato è ferito gravemente
static var bait := false                 # tiene in mano un'esca
static var noises: Array = []            # [{pos, r (px), t}]

var state := CALM
var goal := Vector2.INF                  # dove va a guardare (allerta, ritorno)
var last_seen := Vector2.INF
var home := Vector2.INF
var dark := false                        # vede al buio
var brave := true                        # non fugge mai
var hunter := false                      # fiuta il sangue (i predatori)
var lead: Creature                       # voce 130: il pastore che segue quando è calma (`BhPastore`)
var _mem := 0.0
var _search := 0.0
var _flee := 0.0
var _listen := 0.0
var _heard := -1                         # l'ultimo rumore sentito (numero)
static var _count := 0                   # quanti rumori sono stati fatti (per non sentire due volte lo stesso)


func setup(c: Creature) -> void:
	var st: Array = c.data.get("strata", [0])
	dark = bool(c.data.get("dark_sight", false)) or not (0 in st) or c.boss
	hunter = c.hunger > 0.0 and FamiliesData.FAMILIES.get(c.family, {}).has("prey")
	# le prede e le docili fuggono sempre; le altre una volta su tre; i Guardiani e le antiche mai
	var role := String(FamiliesData.FAMILIES.get(c.family, {}).get("role", ""))
	brave = c.boss or c.ancient != null or not (role == "erbivoro" or c.docile or c.rng.randf() < 0.33)


## Un rumore nel mondo: chi è entro `tiles` tessere (per l'Ombra, meno) lo sente e va a vedere.
static func noise(pos: Vector2, tiles: float) -> void:
	_count += 1
	noises.append({"pos": pos, "r": tiles * 16.0 * Behavior.stealth, "t": 0.6, "n": _count})


## Il cuore di `Behavior.sees`: vede il bersaglio entro `tiles` tessere?
func sees(c: Creature, tiles: float) -> bool:
	var tp := c.target.position
	var d := tp.distance_to(c.position)
	var r := tiles * 16.0 * Behavior.stealth * Behavior.fog * Behavior.effect_stealth
	if not dark:
		r *= lerpf(DARK_SIGHT, 1.0, clampf(lit, 0.0, 1.0))
	if blood and hunter:
		r = maxf(r, SMELL_BLOOD * 16.0)
	if bait:
		r = maxf(r, BAIT_REACH * 16.0 * Behavior.stealth)
	if d < r:
		last_seen = tp
		_mem = MEMORY
		if state != FLEE:
			state = HUNT
		return true
	if _mem > 0.0 and d < r * MEMORY_REACH:
		last_seen = tp
		return true                              # ti ha appena perso: insegue ancora un poco
	return false


## Ogni fotogramma, prima dei comportamenti: memoria, rumori, fuga, casa.
func tick(c: Creature, dt: float) -> void:
	if home == Vector2.INF:
		home = c.position
	if _mem > 0.0:
		_mem -= dt
		if _mem <= 0.0 and state == HUNT:
			_look(last_seen)                     # ti ha perso: ti cerca dove ti ha visto
	if _search > 0.0:
		_search -= dt
		if _search <= 0.0 and state == ALERT:
			state = CALM
			goal = Vector2.INF
	if _flee > 0.0:
		_flee -= dt
		if _flee <= 0.0:
			state = CALM
	elif not brave and c.hp < c.hp_max * FLEE_BELOW and c.hp > 0 and c.tame == null:
		_flee = FLEE_TIME
		state = FLEE
	_listen -= dt
	if _listen <= 0.0:
		_listen = LISTEN
		if state == CALM or state == ALERT or state == HOME:
			for n in noises:
				if int(n["n"]) > _heard and (n["pos"] as Vector2).distance_to(c.position) < float(n["r"]):
					_heard = int(n["n"])
					_look(n["pos"])
		if state == CALM and c.position.distance_to(home) > HOME_LEASH * 16.0 and c.tame == null:
			state = HOME
			goal = home
		elif state == HOME and c.position.distance_to(home) < 6.0 * 16.0:
			state = CALM
			goal = Vector2.INF


## Voce 130: fugge per `t` secondi, anche se è coraggiosa (un ladro con il bottino, il gregge senza pastore, la luce).
func force_flee(t: float) -> void:
	_flee = maxf(_flee, t)
	state = FLEE


func _look(at: Vector2) -> void:
	state = ALERT
	goal = at
	_search = SEARCH


## Dopo i comportamenti: chi fugge va via dal bersaglio (vince su tutto il resto).
func after(c: Creature) -> void:
	if state != FLEE or c.target == null:
		return
	var away := signf(c.position.x - c.target.position.x)
	if away == 0.0:
		away = float(c.facing)
	if c.fly:
		c.want_fly = Vector2(away * c.speed, -c.speed * 0.4)
	else:
		c.want_x = away
		c.facing = int(away)
		if c.on_floor and c.wall_ahead(c.facing):
			c.vel.y = -260.0
			c.on_floor = false


## Per i comportamenti che gironzolano: se c'è un punto da guardare (allerta, ritorno) la direzione verso di esso,
## altrimenti 0 (gironzola come sempre).
func wander_dir(c: Creature) -> float:
	if state == CALM and is_instance_valid(lead) and absf(lead.position.x - c.position.x) > 4.0 * 16.0:
		return signf(lead.position.x - c.position.x)   # voce 130: segue il pastore
	if goal == Vector2.INF or not (state == ALERT or state == HOME):
		return 0.0
	var dx := goal.x - c.position.x
	if absf(dx) < 12.0:
		if state == ALERT:
			goal = Vector2.INF                   # arrivata: si guarda attorno finché dura l'allerta
		return 0.0
	return signf(dx)


## Lo stato da mostrare (scheda della creatura, segno sopra la testa).
func label() -> String:
	return String(NAMES.get(state, ""))


static func reset() -> void:
	noises.clear()
	lit = 1.0
	blood = false
	bait = false
