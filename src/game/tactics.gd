class_name Tactics
extends Node
## Le tattiche di gruppo (voce 131, Roadmap 15): le creature che nascono insieme (sciami e branchi, `FaunaExtra`) sono
## un gruppo (meta "grp") e si muovono come tale, usando il cervello (`Mind`) senza riscrivere i comportamenti:
## - i **branchi** a terra accerchiano: il più vicino attacca, gli altri girano ai lati (`Mind.flank`);
## - gli **sciami** in volo girano in cerchio attorno al bersaglio e scendono a ondate (`Mind.slot`);
## - il **capobranco** guida il branco (`Mind.lead`): se cade, gli altri fuggono (lo fa `Wiles` alla morte);
## - le **colonie** difendono il nido: avvicinarsi a un nido chiama le creature della sua famiglia;
## - le **prede** fuggono insieme: una ferita o in fuga avvisa le compagne vicine della sua famiglia.

const EVERY := 0.3
const FLANK := 52.0                      # px: quanto al lato del bersaglio va chi accerchia
const RING := 38.0                       # px: il raggio del cerchio degli sciami
const WAVE := 3.0                        # secondi di un giro d'ondata (due in cerchio, uno in picchiata)
const NEST_R := 7.0                      # tessere: così vicino a un nido la colonia accorre
const NEST_CALL := 26.0                  # tessere: da quanto lontano accorre
const WARN_R := 10.0                     # tessere: quanto lontano una preda avvisa le compagne

var m: Node2D
var _t := 0.0
var _clock := 0.0
var _nest_t := 0.0
var alarms := 0                          # conteggi (prove)
var defended := 0


func setup(main: Node2D) -> void:
	m = main


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	_clock += dt
	_t -= dt
	if _t > 0.0:
		return
	_t = EVERY
	var groups := {}
	for c in m.fauna.list:
		if c.has_meta("grp"):
			var g: int = c.get_meta("grp")
			if not groups.has(g):
				groups[g] = []
			groups[g].append(c)
		_prey_alarm(c)
	for g in groups:
		_group(groups[g])
	_nest_t -= EVERY
	if _nest_t <= 0.0:
		_nest_t = 1.0
		_nests()


## Un gruppo che caccia: a terra accerchia, in volo gira e scende a ondate.
func _group(list: Array) -> void:
	var hunting := list.filter(func(c: Creature) -> bool: return c.mind.state == Mind.HUNT)
	if hunting.size() < 2:
		for c in list:
			c.mind.slot = Vector2.ZERO
		return
	var tp: Vector2 = m.player.position
	hunting.sort_custom(func(a: Creature, b: Creature) -> bool: return a.position.distance_to(tp) < b.position.distance_to(tp))
	for i in hunting.size():
		var c: Creature = hunting[i]
		if c.fly:
			var ang := TAU * float(i) / hunting.size() + _clock * 0.8
			var dive := fmod(_clock + i * 0.7, WAVE) > WAVE - 1.0
			c.mind.slot = Vector2.ZERO if dive else Vector2(cos(ang), sin(ang) * 0.6) * RING
		elif i == 0:
			c.mind.flank = 0.0                   # il più vicino va dritto
		elif absf(c.position.x - tp.x) > 4.0 * 16.0:
			# gli altri girano dalla parte opposta a quella da cui arriva il primo
			var side := -signf(hunting[0].position.x - tp.x)
			if side == 0.0:
				side = 1.0
			c.mind.flank = side * FLANK * (1.0 if i % 2 == 1 else 0.6)


## Una preda (erbivora o docile) ferita o in fuga avvisa le compagne vicine della sua famiglia, che fuggono con lei.
func _prey_alarm(c: Creature) -> void:
	var role := String(FamiliesData.FAMILIES.get(c.family, {}).get("role", ""))
	if role != "erbivoro" and not c.docile:
		return
	var hurt: bool = c.hp < c.mind.last_hp
	c.mind.last_hp = c.hp
	if not hurt and not (c.mind.state == Mind.FLEE and not c.mind.warned):
		return
	c.mind.warned = true
	if c.mind.state != Mind.FLEE:
		c.mind.force_flee(3.0)
	alarms += 1
	for o in m.fauna.list:
		if o != c and o.family == c.family and o.tame == null and o.position.distance_to(c.position) < WARN_R * 16.0 \
				and o.mind.state != Mind.FLEE:
			o.mind.force_flee(4.0)
			o.mind.warned = true


## Le colonie difendono i nidi: vicino a un nido le creature della sua famiglia vengono a vedere (e poi attaccano).
func _nests() -> void:
	if m.ecology == null:
		return
	var pc: Vector2i = m.player_cell()
	for k in m.ecology.nests:
		var parts := String(k).split(",")
		var nc := Vector2i(int(parts[0]), int(parts[1]))
		if Vector2(nc - pc).length() > NEST_R:
			continue
		var fam := String(m.ecology.nests[k]["fam"])
		if String(FamiliesData.FAMILIES.get(fam, {}).get("role", "")) == "erbivoro":
			continue
		for c in m.fauna.list:
			if c.family == fam and c.tame == null and not c.docile and c.mind.state != Mind.HUNT \
					and c.position.distance_to(m.player.position) < NEST_CALL * 16.0:
				c.mind.alarm(m.player.position)
				defended += 1
