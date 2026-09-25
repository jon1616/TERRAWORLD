class_name Ally
extends Node2D
## Un compagno (voce 37): un piccolo compagno che segue il Germogliato (`pet`) o una creatura alleata che combatte per
## lui (`CompanionsData.ALLIES`). Senza nemici vicini sta accanto al Germogliato (chi non vola saltella, chi vola
## ondeggia); con una creatura entro `SIGHT` le va addosso (o le tira colpi da lontano). Non si fa male. Se resta
## troppo indietro ricompare accanto al Germogliato.

const S := 16

var id := ""
var data: Dictionary
var pet := false
var m: Node2D
var target: Creature
var vel := Vector2.ZERO
var on_floor := false
var half := Vector2(5, 5)
var _spr: Sprite2D
var _frames: Array = []
var _anim := 0.0
var _hop := 0.0
var _shot := 0.0
var _hit := {}                          # creatura -> secondi prima di poterla colpire di nuovo
var _slot := 0                          # posto attorno al Germogliato (per non stare tutti uguali)


func setup(aid: String, is_pet: bool, main: Node2D, slot: int) -> void:
	id = aid
	pet = is_pet
	m = main
	_slot = slot
	data = CompanionsData.PETS[aid] if pet else CompanionsData.ALLIES[aid]
	var art: Array = data["art"]
	var fr := CreatureArt.frames(String(art[0]), int(art[1]))
	for im in fr["frames"]:
		_frames.append(ImageTexture.create_from_image(im))
	_spr = Sprite2D.new()
	_spr.texture = _frames[0]
	var h: int = (_frames[0] as Texture2D).get_height()
	half = Vector2((_frames[0] as Texture2D).get_width() * 0.3, h * 0.4)
	_spr.offset = Vector2(0, -h / 2.0)
	_spr.position = Vector2(0, half.y)
	_spr.modulate = data.get("tint", Color.WHITE)
	if pet:
		_spr.scale = Vector2(0.7, 0.7)
	add_child(_spr)
	# un segno per riconoscerli: una fogliolina turchese sopra la testa
	var leaf := Sprite2D.new()
	var li := Image.create_empty(3, 2, false, Image.FORMAT_RGBA8)
	li.fill(Color("#72d4b0"))
	leaf.texture = ImageTexture.create_from_image(li)
	leaf.position = Vector2(0, -half.y - 5)
	leaf.z_as_relative = false
	leaf.z_index = 27
	add_child(leaf)


func _process(dt: float) -> void:
	dt = minf(dt, 1.0 / 30.0)
	var p: Node2D = m.player
	if position.distance_to(p.position) > 30.0 * S:
		position = p.position + Vector2(-20, -10)           # rimasto indietro: ricompare accanto
		vel = Vector2.ZERO
	for k in _hit.keys():
		_hit[k] = float(_hit[k]) - dt
		if float(_hit[k]) <= 0.0:
			_hit.erase(k)
	if not pet:
		_find_target()
	var goal: Vector2 = p.position + Vector2((-18 - _slot * 14) * p.facing, -10 if data["fly"] else 0)
	if target != null:
		goal = target.position
		if float(data["shoot"]) > 0.0:
			goal = target.position + Vector2(0, -60)          # chi tira colpi sta un po' sopra
	if data["fly"]:
		var to := goal - position
		var want := to.normalized() * float(data.get("speed", 120.0)) if to.length() > 8.0 else Vector2.ZERO
		want.y += sin(_anim * 3.0 + _slot) * 20.0
		vel = vel.move_toward(want, 500.0 * dt)
		position += vel * dt
	else:
		vel.y = minf(vel.y + 900.0 * dt, 500.0)
		_hop -= dt
		if on_floor:
			vel.x = move_toward(vel.x, 0.0, 600.0 * dt)
			if _hop <= 0.0 and absf(goal.x - position.x) > 14.0:
				_hop = 0.35
				vel = Vector2(signf(goal.x - position.x) * float(data.get("speed", 120.0)), -240.0)
		var r := TileBody.move(m.world, position, half, vel, dt, on_floor)
		position = r["pos"]
		vel = r["vel"]
		on_floor = r["floor"]
	if absf(vel.x) > 2.0:
		_spr.scale.x = absf(_spr.scale.x) * signf(vel.x)
	_anim += dt
	_spr.texture = _frames[int(_anim * 8.0) % _frames.size()]
	if not pet:
		_attack(dt)


## Il bersaglio: la creatura più vicina entro la vista (non i Guardiani calmi).
func _find_target() -> void:
	if target != null and (not is_instance_valid(target) or not m.fauna.list.has(target)):
		target = null
	if target != null and target.position.distance_to(position) < CompanionsData.SIGHT * S:
		return
	target = null
	var best := CompanionsData.SIGHT * S
	for c in m.fauna.list:
		if c.calm:
			continue
		var d: float = c.position.distance_to(m.player.position)
		if d < best:
			best = d
			target = c


func _attack(dt: float) -> void:
	if target == null:
		return
	var dmg := roundi(int(data["damage"]) * m.combat.magic_mult)
	if float(data["shoot"]) > 0.0:
		_shot -= dt
		if _shot <= 0.0:
			_shot = float(data["shoot"])
			var dir := (target.position - position).normalized()
			m.shots.fire(position + dir * 6.0, dir * 300.0, 0.0, dmg, true, 0.3, {"look": "orbita"})
		return
	if not _hit.has(target) and Rect2(position - half, half * 2.0).grow(3.0).intersects(target.rect()):
		_hit[target] = 0.6
		m.combat._strike(target, dmg, position.x, 0.6)
