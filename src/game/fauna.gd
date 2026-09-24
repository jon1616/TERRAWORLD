class_name Fauna
extends Node2D
## Le creature vive attorno al Germogliato: le fa comparire secondo lo strato (fuori dalla visuale, non troppo
## lontano), le toglie quando ci si allontana molto, raccoglie i loro spari e, quando muoiono, lascia il bottino.
## Chi colpisce chi lo decide `Combat`; qui c'è solo la popolazione.

const S := 16

var world: World
var player: Player
var drops: Drops
var shots: Projectiles
var enabled := true                    # le prove lo spengono per non essere disturbate
var list: Array[Creature] = []
var kills := 0
var _t := 0.0
var _rng := RandomNumberGenerator.new()

signal killed(c: Creature)


func setup(w: World, p: Player, d: Drops, pr: Projectiles) -> void:
	world = w
	player = p
	drops = d
	shots = pr
	_rng.seed = w.world_seed ^ 0x5EED
	z_index = 3
	for k in w.creatures.size():
		var sd: Dictionary = w.creatures[k]
		var sc: Vector2i = sd["cell"]
		add(String(sd["id"]), Vector2(sc.x * S + 8, sc.y * S + 8), w.world_seed + k)


## Fa nascere una creatura in un punto (centro del corpo).
func add(id: String, pos: Vector2, sd: int = -1) -> Creature:
	var c := Creature.new()
	c.setup(id, world, player, sd if sd >= 0 else _rng.randi())
	c.position = pos
	add_child(c)
	list.append(c)
	return c


func clear() -> void:
	for c in list:
		c.queue_free()
	list.clear()


## La creatura muore: sbuffo, bottino a terra, via dalla scena.
func kill(c: Creature) -> void:
	if not list.has(c):
		return
	list.erase(c)
	kills += 1
	var loot := LootData.roll(String(c.data["loot"]), _rng)
	for id in loot:
		drops.spawn(id, int(loot[id]), c.position)
	Fx.puff(self, c.position, Color(1.3, 1.2, 1.0))
	killed.emit(c)
	c.queue_free()


func _process(dt: float) -> void:
	for c in list:
		if not c.fire.is_empty():
			var f := c.fire
			shots.fire(f["from"], f["vel"], f["grav"], f["damage"], false)
			c.fire = {}
	for i in range(list.size() - 1, -1, -1):
		var c := list[i]
		if c.position.distance_to(player.position) > CreaturesData.DESPAWN * S or c.position.y > world.h * S:
			c.queue_free()
			list.remove_at(i)
	if not enabled:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = CreaturesData.SPAWN_EVERY
	if list.size() < CreaturesData.MAX_ALIVE:
		try_spawn()


## Prova a far nascere una creatura in un punto a caso attorno al giocatore (fuori dalla visuale). Restituisce la
## creatura o null se il punto scelto non andava bene (si riprova al giro dopo).
func try_spawn() -> Creature:
	var pc := Vector2i(floori(player.position.x / S), floori(player.position.y / S))
	var ang := _rng.randf() * TAU
	var dist := _rng.randf_range(CreaturesData.SPAWN_MIN, CreaturesData.SPAWN_MAX)
	var c := pc + Vector2i(roundi(cos(ang) * dist), roundi(sin(ang) * dist * 0.6))
	if not world.inside(c.x, c.y) or c.y < 2:
		return null
	var stratum := StrataData.at(world, c.x, c.y)
	var choices := CreaturesData.of_stratum(stratum)
	if choices.is_empty():
		return null
	var id := _pick(choices)
	var fly: bool = CreaturesData.CREATURES[id].get("fly", false)
	# uno spazio d'aria di 2×2; chi non vola ha bisogno anche del terreno sotto (lo si cerca scendendo un poco)
	for k in 12:
		var y := c.y + (k if not fly else 0)
		if _free(c.x, y) and (fly or world.solid(c.x, y + 1)):
			if world.torch_near(Vector2i(c.x, y), 8.0):
				return null                # la luce delle torce tiene lontane le creature
			var cr := add(id, Vector2(c.x * S + 8, (y + 1) * S - CreaturesData.CREATURES[id]["half"][1] - 0.1))
			cr.strengthen(float(StrataData.STRATA[stratum]["danger"]))
			return cr
		if fly:
			break
	return null


func _free(x: int, y: int) -> bool:
	return not world.solid(x, y) and not world.solid(x, y - 1) and not world.solid(x + 1, y) \
			and not world.solid(x + 1, y - 1)


func _pick(choices: Array) -> String:
	var tot := 0
	for e in choices:
		tot += int(e[1])
	var r := _rng.randi_range(1, tot)
	for e in choices:
		r -= int(e[1])
		if r <= 0:
			return String(e[0])
	return String(choices[0][0])
