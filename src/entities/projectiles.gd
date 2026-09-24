class_name Projectiles
extends Node2D
## I colpi in volo: dardi del Germogliato (colpiscono le creature) e spore delle creature (colpiscono il Germogliato).
## Volano con la loro gravità, si fermano contro la roccia. Chi viene colpito lo decide `hit`, passato dalla scena.

const LIFE := 3.0

var world: World
## hit.call(colpo) -> true se il colpo ha preso qualcosa (allora sparisce)
var hit: Callable
var _shots: Array[Dictionary] = []    # {node, vel, grav, damage, player, t, knock}
var _tex := {}


func setup(w: World, on_hit: Callable) -> void:
	world = w
	hit = on_hit
	z_index = 5
	_tex["dardo"] = ImageTexture.create_from_image(_dart())
	_tex["spora"] = ImageTexture.create_from_image(_spore())


## Un colpo nuovo. `from_player` = dardo del Germogliato, altrimenti spora di una creatura.
func fire(from: Vector2, vel: Vector2, grav: float, damage: int, from_player: bool, knock := 1.0) -> void:
	var sp := Sprite2D.new()
	sp.texture = _tex["dardo" if from_player else "spora"]
	sp.position = from
	if not from_player:
		sp.modulate = Color(1.6, 1.3, 2.0)   # le spore brillano (colore oltre 1 = bagliore)
		sp.z_as_relative = false
		sp.z_index = 26
	add_child(sp)
	_shots.append({"node": sp, "vel": vel, "grav": grav, "damage": damage, "player": from_player, "t": 0.0,
		"knock": knock})


func count() -> int:
	return _shots.size()


func _process(dt: float) -> void:
	dt = minf(dt, 1.0 / 30.0)
	for i in range(_shots.size() - 1, -1, -1):
		var s := _shots[i]
		var sp: Sprite2D = s["node"]
		var v: Vector2 = s["vel"]
		v.y += float(s["grav"]) * dt
		s["vel"] = v
		sp.position += v * dt
		sp.rotation = v.angle()
		s["t"] = float(s["t"]) + dt
		var c := Vector2i(floori(sp.position.x / 16.0), floori(sp.position.y / 16.0))
		var gone := float(s["t"]) > LIFE or world.solid(c.x, c.y) or not world.inside(c.x, c.y)
		if not gone and hit.is_valid():
			gone = hit.call(s)
		if gone:
			Fx.puff(get_parent(), sp.position, Color(1.2, 1.0, 0.7) if s["player"] else Color(1.4, 0.9, 1.8))
			sp.queue_free()
			_shots.remove_at(i)


static func _dart() -> Image:
	var im := Image.create_empty(10, 3, false, Image.FORMAT_RGBA8)
	for x in 7:
		im.set_pixel(x, 1, Color("#8a5a3a"))
	im.set_pixel(0, 0, Color("#3fb89a"))
	im.set_pixel(0, 2, Color("#3fb89a"))
	im.set_pixel(1, 0, Color("#2a8a72"))
	im.set_pixel(1, 2, Color("#2a8a72"))
	im.set_pixel(7, 1, Color("#c8d4e0"))
	im.set_pixel(8, 1, Color("#e8f0f8"))
	im.set_pixel(9, 1, Color("#ffffff"))
	im.set_pixel(7, 0, Color("#7a8aa0"))
	im.set_pixel(7, 2, Color("#7a8aa0"))
	return im


static func _spore() -> Image:
	var im := Image.create_empty(6, 6, false, Image.FORMAT_RGBA8)
	for y in 6:
		for x in 6:
			var d := Vector2(x - 2.5, y - 2.5).length()
			if d < 2.2:
				im.set_pixel(x, y, Color("#d8a0ff") if d < 1.2 else Color("#8a4ad0"))
			elif d < 3.0:
				im.set_pixel(x, y, Color(0.54, 0.29, 0.82, 0.5))
	return im
