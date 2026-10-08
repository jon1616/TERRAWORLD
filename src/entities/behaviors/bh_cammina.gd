class_name BhCammina
extends Behavior
## Cammina: verso il bersaglio se lo vede, altrimenti gironzola cambiando verso ogni tanto. Salta i gradini alti due
## tessere; mentre gironzola si gira davanti ai burroni.
## Roadmap 54, voce 426: salta solo i muri che può superare (`Creature.can_hop`). Davanti a un muro troppo alto ti
## aspetta lì sotto, guardandoti; dopo `WAIT` secondi lascia perdere e se ne va per un po' (`GIVE_UP`), poi riprova.
## Gironzolando, un muro troppo alto la fa girare come un burrone.

const WAIT := 3.0
const GIVE_UP := 5.0

var wander := 0.0
var dir := 1.0
var _blocked := 0.0                    # da quanto è ferma davanti a un muro che non sa saltare
var _away := 0.0                       # ha lasciato perdere: gironzola per tanto


func tick(c: Creature, dt: float) -> void:
	if c.busy:
		return
	_away = maxf(_away - dt, 0.0)
	var chasing := false
	if _away <= 0.0 and Behavior.sees(c, float(c.p.get("sight", 20))):
		chasing = true
		# voce 131: chi accerchia punta al fianco del bersaglio, arrivato si stringe
		var gx: float = c.target.position.x + c.mind.flank
		if c.mind.flank != 0.0 and absf(gx - c.position.x) < 12.0:
			c.mind.flank = 0.0
		dir = signf(gx - c.position.x)
		if absf(gx - c.position.x) < 4.0:
			dir = 0.0
	elif _away <= 0.0 and c.mind.wander_dir(c) != 0.0:
		dir = c.mind.wander_dir(c)             # voce 129: va a vedere un rumore, o a cercarti dove ti ha visto
		if c.on_floor and not c.ground_ahead(int(dir)):
			dir = 0.0
	else:
		wander -= dt
		if wander <= 0.0:
			wander = c.rng.randf_range(2.0, 5.0)
			dir = [-1.0, 1.0, 0.0][c.rng.randi_range(0, 2)]
		if c.on_floor and dir != 0.0 and not c.ground_ahead(int(dir)):
			dir = -dir
	if c.on_floor and dir != 0.0 and c.wall_ahead(int(dir)) and not c.can_hop(int(dir)):
		if chasing:
			# un muro troppo alto tra lei e te: aspetta lì sotto, poi lascia perdere
			c.facing = int(dir)
			dir = 0.0
			_blocked += dt
			if _blocked > WAIT:
				_blocked = 0.0
				_away = GIVE_UP
				wander = GIVE_UP
				dir = -float(c.facing)
		else:
			dir = -dir                         # gironzolando: si gira, come davanti a un burrone
	elif dir != 0.0:
		_blocked = 0.0
	c.want_x = dir
	if dir != 0.0:
		c.facing = int(dir)
	if c.on_floor and dir != 0.0 and c.wall_ahead(int(dir)) and c.can_hop(int(dir)):
		c.vel.y = -Creature.HOP
		c.on_floor = false
