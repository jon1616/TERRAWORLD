class_name Drops
extends Node2D
## Gli oggetti caduti a terra (da uno scavo, da un albero, da una creatura): cadono, rimbalzano un poco, vengono
## attirati verso il Germogliato quando è vicino e finiscono nella Bisaccia se c'è posto. Non si salvano.

const HALF := Vector2(4, 4)
const MAGNET := 16.0 * 5.0            # raggio in cui gli oggetti vengono attirati
var magnet_mult := 1.0                 # il Grumetto (voce 37) li attira da più lontano
const PICK := 12.0                    # distanza a cui entrano nella Bisaccia
const LIFE := 600.0                   # secondi prima di sparire, se nessuno li raccoglie

var world: World
var player: Player
var bisaccia: Bisaccia
var _items: Array[Dictionary] = []   # {node, id, n, vel, t}
var _icons := {}
var _rng := RandomNumberGenerator.new()

signal picked(id: String, n: int)


func setup(w: World, p: Player, b: Bisaccia) -> void:
	world = w
	player = p
	bisaccia = b
	z_index = 5


## Fa cadere n oggetti in un punto, con una piccola spinta a caso verso l'alto.
func spawn(id: String, n: int, pos: Vector2) -> void:
	if n <= 0 or not ItemsData.has(id):
		return
	for d in _items:
		if d["id"] == id and (d["node"] as Sprite2D).position.distance_to(pos) < 12.0:
			d["n"] = int(d["n"]) + n
			return
	if not _icons.has(id):
		_icons[id] = ImageTexture.create_from_image(ItemIcons.of(id))
	var sp := Sprite2D.new()
	sp.texture = _icons[id]
	sp.scale = Vector2(0.75, 0.75)
	sp.position = pos
	add_child(sp)
	_items.append({"node": sp, "id": id, "n": n, "vel": Vector2(_rng.randf_range(-40, 40), -_rng.randf_range(60, 120)), "t": 0.0})


func count() -> int:
	return _items.size()


func _process(dt: float) -> void:
	var target := player.position
	for i in range(_items.size() - 1, -1, -1):
		var d: Dictionary = _items[i]
		var sp: Sprite2D = d["node"]
		d["t"] = float(d["t"]) + dt
		var vel: Vector2 = d["vel"]
		var dist := sp.position.distance_to(target)
		var room := bisaccia.room_for(d["id"]) > 0
		if room and dist < MAGNET * magnet_mult:
			# attratto: vola verso il giocatore, senza badare ai blocchi
			vel = vel.move_toward((target - sp.position).normalized() * 220.0, 900.0 * dt)
			sp.position += vel * dt
		else:
			vel.y = minf(vel.y + 700.0 * dt, 400.0)
			vel.x = move_toward(vel.x, 0.0, 200.0 * dt)
			var r := TileBody.move(world, sp.position, HALF, vel, dt, false)
			sp.position = r["pos"]
			vel = r["vel"]
		d["vel"] = vel
		sp.offset.y = sin(float(d["t"]) * 3.0) * 1.0
		if room and dist < PICK:
			var n: int = d["n"]
			var left := bisaccia.add(d["id"], n)
			picked.emit(d["id"], n - left)
			if left <= 0:
				sp.queue_free()
				_items.remove_at(i)
				continue
			d["n"] = left
		if float(d["t"]) > LIFE:
			sp.queue_free()
			_items.remove_at(i)
