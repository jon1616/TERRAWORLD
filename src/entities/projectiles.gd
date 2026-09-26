class_name Projectiles
extends Node2D
## I colpi in volo: dardi e incantesimi del Germogliato (colpiscono le creature) e spore delle creature (colpiscono il
## Germogliato). Volano con la loro gravità, si fermano contro la roccia (tranne chi la attraversa). Chi viene colpito
## lo decide `hit`, passato dalla scena. Gli incantesimi dei bastoni (voce 21, `SpellsData`) possono attraversare più
## creature (`pierce`), inseguire la più vicina (`homing`, con `seek`) e portare luce.

const LIFE := 3.0

var world: World
## hit.call(colpo) -> true se il colpo ha preso qualcosa (allora sparisce)
var hit: Callable
## seek.call(punto) -> posizione della creatura più vicina (Vector2.INF se nessuna): per i colpi che inseguono
var seek: Callable
var light: LightMap
var _shots: Array[Dictionary] = []    # {node, vel, grav, damage, player, t, knock, pierce, homing, through, glow, hits}
var _tex := {}
var _light_t := 0.0


func setup(w: World, on_hit: Callable) -> void:
	world = w
	hit = on_hit
	z_index = 5
	_tex["dardo"] = ImageTexture.create_from_image(_dart())
	_tex["spora"] = ImageTexture.create_from_image(_spore(Color("#d8a0ff"), Color("#8a4ad0")))
	_tex["spora_amica"] = ImageTexture.create_from_image(_spore(Color("#c8ffe8"), Color("#3aa08a")))
	_tex["brace"] = ImageTexture.create_from_image(_spore(Color("#fff0a0"), Color("#e07830")))
	_tex["scheggia"] = ImageTexture.create_from_image(_shard())
	_tex["orbita"] = ImageTexture.create_from_image(_spore(Color("#f0d8ff"), Color("#7a44c8")))
	_tex["ragnatela"] = ImageTexture.create_from_image(_web())
	_tex["iride"] = ImageTexture.create_from_image(_spore(Color("#ffffff"), Color("#f080d0")))
	_tex["gelo"] = ImageTexture.create_from_image(_spore(Color("#e8f8ff"), Color("#2a7ad8")))
	_tex["giavellotto"] = ImageTexture.create_from_image(_javelin())
	_tex["polline"] = ImageTexture.create_from_image(_spore(Color("#fff2a8"), Color("#e0a030")))
	_tex["scheggia_nera"] = ImageTexture.create_from_image(_spore(Color("#e0c8ff"), Color("#463464")))


## Un colpo nuovo. `from_player` = dardo del Germogliato, altrimenti spora di una creatura. `opts` per gli
## incantesimi: look, pierce, homing, through, light.
func fire(from: Vector2, vel: Vector2, grav: float, damage: int, from_player: bool, knock := 1.0, opts := {}) -> void:
	var sp := Sprite2D.new()
	var look := String(opts.get("look", "dardo" if from_player else "spora"))
	sp.texture = _tex[look]
	sp.position = from
	if look == "giavellotto":
		pass
	elif look == "ragnatela":
		sp.z_as_relative = false
		sp.z_index = 26
	elif look != "dardo":
		sp.modulate = Color(1.6, 1.3, 2.0) if look == "spora" else Color(1.8, 1.8, 1.8)   # oltre 1 = bagliore
		sp.z_as_relative = false
		sp.z_index = 26
	add_child(sp)
	_shots.append({"node": sp, "vel": vel, "grav": grav, "damage": damage, "player": from_player, "t": 0.0,
		"knock": knock, "pierce": int(opts.get("pierce", 0)), "homing": float(opts.get("homing", 0.0)),
		"through": bool(opts.get("through", false)), "glow": opts.get("light", Color.BLACK), "hits": {},
		"slow": float(opts.get("slow", 0.0)), "chill": float(opts.get("chill", 0.0)), "elem": String(opts.get("elem", ""))})


func count() -> int:
	return _shots.size()


func _process(dt: float) -> void:
	dt = minf(dt, 1.0 / 30.0)
	for i in range(_shots.size() - 1, -1, -1):
		var s := _shots[i]
		var sp: Sprite2D = s["node"]
		var v: Vector2 = s["vel"]
		v.y += float(s["grav"]) * dt
		var hm := float(s["homing"])
		if hm > 0.0 and seek.is_valid():
			var goal: Vector2 = seek.call(sp.position)
			if goal != Vector2.INF:
				# gira verso la creatura a velocità costante (hm = radianti al secondo)
				var ang := v.angle_to(goal - sp.position)
				v = v.rotated(clampf(ang, -hm * dt, hm * dt))
		s["vel"] = v
		sp.position += v * dt
		sp.rotation = v.angle()
		s["t"] = float(s["t"]) + dt
		var c := Vector2i(floori(sp.position.x / 16.0), floori(sp.position.y / 16.0))
		var gone: bool = float(s["t"]) > LIFE or not world.inside(c.x, c.y) or (world.solid(c.x, c.y) and not s["through"])
		if not gone and hit.is_valid():
			gone = hit.call(s)
		if gone:
			Fx.puff(get_parent(), sp.position, Color(1.2, 1.0, 0.7) if s["player"] else Color(1.4, 0.9, 1.8))
			sp.queue_free()
			_shots.remove_at(i)
	_light_t -= dt
	if light and _light_t <= 0.0:
		_light_t = 0.08
		var ls := []
		for s in _shots:
			if s["glow"] != Color.BLACK:
				var p: Vector2 = (s["node"] as Node2D).position
				ls.append([Vector2i(floori(p.x / 16.0), floori(p.y / 16.0)), s["glow"]])
		light.set_extra("colpi", ls)


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


static func _spore(core: Color, rim: Color) -> Image:
	var im := Image.create_empty(6, 6, false, Image.FORMAT_RGBA8)
	for y in 6:
		for x in 6:
			var d := Vector2(x - 2.5, y - 2.5).length()
			if d < 2.2:
				im.set_pixel(x, y, core if d < 1.2 else rim)
			elif d < 3.0:
				im.set_pixel(x, y, Color(rim.r, rim.g, rim.b, 0.5))
	return im


## Giavellotto: un'asta di legno con la punta d'aculeo.
static func _javelin() -> Image:
	var im := Image.create_empty(16, 3, false, Image.FORMAT_RGBA8)
	for x in 12:
		im.set_pixel(x, 1, Color("#8a5a3a") if x % 3 else Color("#6a4028"))
	for x in range(12, 16):
		im.set_pixel(x, 1, Color("#fff2a8") if x > 13 else Color("#eec04a"))
	im.set_pixel(13, 0, Color("#b0861c"))
	im.set_pixel(13, 2, Color("#b0861c"))
	im.set_pixel(0, 0, Color("#3aa08a"))
	im.set_pixel(0, 2, Color("#3aa08a"))
	return im


## Ragnatela: una rete di fili chiari, che invischia chi prende.
static func _web() -> Image:
	var im := Image.create_empty(9, 9, false, Image.FORMAT_RGBA8)
	var c := Color(0.9, 0.92, 0.85, 0.9)
	for k in 9:
		im.set_pixel(k, 4, c)
		im.set_pixel(4, k, c)
		im.set_pixel(k, k, c)
		im.set_pixel(8 - k, k, c)
	for q in [Vector2i(2, 3), Vector2i(3, 2), Vector2i(5, 2), Vector2i(6, 3), Vector2i(6, 5), Vector2i(5, 6),
			Vector2i(3, 6), Vector2i(2, 5)]:
		im.set_pixel(q.x, q.y, c)
	return im


## Scheggia di cristallo: una lama sottile turchese che attraversa le creature.
static func _shard() -> Image:
	var im := Image.create_empty(12, 5, false, Image.FORMAT_RGBA8)
	for x in 12:
		var hw := 2.0 * sin(PI * (x + 0.5) / 12.0)
		for y in 5:
			var d := absf(y - 2.0)
			if d <= hw:
				im.set_pixel(x, y, Color("#e8ffff") if d < 0.6 else (Color("#5cc8cc") if d < 1.3 else Color("#1f8a9a")))
	return im
