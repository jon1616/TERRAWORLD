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


## Fa cadere n oggetti in un punto, con una piccola spinta a caso verso l'alto. `dati`: quelli propri di un oggetto
## unico (un Seme con il suo genoma, voce 41), che arrivano nella Bisaccia così come sono.
func spawn(id: String, n: int, pos: Vector2, dati := {}) -> void:
	if n <= 0 or not ItemsData.has(id):
		return
	for d in _items:
		if dati.is_empty() and not d.has("dati") and d["id"] == id and (d["node"] as Sprite2D).position.distance_to(pos) < 12.0:
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
	if not dati.is_empty():
		_items[-1]["dati"] = dati.duplicate(true)


## L'oggetto a terra più vicino a un punto, entro `r` pixel (per i suggerimenti): {"id", "n", "dati", "key"} o {}.
func at(p: Vector2, r: float) -> Dictionary:
	var best := {}
	var bd := r
	for e in _items:
		var d := (e["node"] as Node2D).position.distance_to(p)
		if d < bd:
			bd = d
			best = e
	if best.is_empty():
		return {}
	return {"id": best["id"], "n": best["n"], "dati": best.get("dati", {}), "key": best["node"]}


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
		# il posto nella Bisaccia (40 caselle da guardare) si chiede solo per chi è abbastanza vicino da essere attirato:
		# con centinaia di oggetti a terra lo si chiedeva per tutti a ogni fotogramma
		var room := dist < MAGNET * magnet_mult and bisaccia.room_for(d["id"]) > 0
		if room:
			# attratto: vola verso il giocatore, senza badare ai blocchi
			vel = vel.move_toward((target - sp.position).normalized() * 220.0, 900.0 * dt)
			sp.position += vel * dt
			d["rest"] = false
		elif d.get("rest", false) and world.solid(floori(sp.position.x / 16.0), floori((sp.position.y + HALF.y + 1.0) / 16.0)):
			pass                                 # fermo sul pavimento: dorme finché il pavimento resta
		else:
			vel.y = minf(vel.y + 700.0 * dt, 400.0)
			vel.x = move_toward(vel.x, 0.0, 200.0 * dt)
			var r := TileBody.move(world, sp.position, HALF, vel, dt, false)
			sp.position = r["pos"]
			vel = r["vel"]
			d["rest"] = bool(r["floor"]) and absf(vel.x) < 1.0
		d["vel"] = vel
		sp.offset.y = sin(float(d["t"]) * 3.0) * 1.0
		if room and dist < PICK:
			var n: int = d["n"]
			var left := bisaccia.add_stack({"id": d["id"], "n": n, "dati": d["dati"]}) if d.has("dati") else bisaccia.add(d["id"], n)
			picked.emit(d["id"], n - left)
			if left <= 0:
				sp.queue_free()
				_items.remove_at(i)
				continue
			d["n"] = left
		if float(d["t"]) > LIFE:
			sp.queue_free()
			_items.remove_at(i)
