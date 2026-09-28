class_name Throwing
extends Node
## Ciò che si lancia (voce 32), con il clic verso il mouse:
##   esplosivo   un baccello che vola ad arco, rimbalza e dopo la miccia scoppia: rompe la roccia attorno (fino alla
##               sua forza, campo `blast`), ferisce le creature e anche il Germogliato se è troppo vicino
##   ricurvo     un seme ricurvo che vola avanti, rallenta e torna in mano; ferisce ogni creatura che attraversa (uno
##               alla volta: finché non è tornato non se ne lancia un altro)
##   giavellotto si consuma come un dardo e attraversa qualche creatura (lo muove `Projectiles`)

const S := 16
const GRAV := 520.0

var m: Node2D
var _bombs: Array[Dictionary] = []    # {node, vel, t, blast}
var _rang: Dictionary = {}             # il seme ricurvo in volo: {node, vel, t, back, dmg, hits, item}
var _cool := 0.0
var blasts := 0                        # scoppi (per le prove)


func setup(main: Node2D) -> void:
	m = main


## Lancia l'oggetto in mano verso un punto. True se è partito qualcosa.
func throw(id: String, target: Vector2) -> bool:
	if _cool > 0.0:
		return false
	var it := ItemsData.get_item(id)
	var from: Vector2 = m.player.position + Vector2(0, -8)
	var dir := (target - from).normalized()
	m.player.facing = 1 if dir.x >= 0.0 else -1
	match String(it.get("kind", "")):
		"esplosivo":
			if not m.character.bisaccia.remove(id, 1):
				return false
			var sp := _sprite(id)
			sp.position = from
			_bombs.append({"node": sp, "vel": dir * 300.0 + Vector2(0, -60), "t": 0.0, "blast": it["blast"]})
			_cool = 0.5
		"ricurvo":
			if not _rang.is_empty():
				return false
			var th: Dictionary = it["throw"]
			var sp2 := _sprite(id)
			sp2.position = from
			_rang = {"node": sp2, "vel": dir * float(th["speed"]), "t": 0.0, "back": false, "item": id,
				"out": float(th["range"]) * S / float(th["speed"]), "speed": float(th["speed"]),
				"dmg": roundi(int(it["damage"]) * m.combat._boon()), "hits": {}}
		"giavellotto":
			if not m.character.bisaccia.remove(id, 1):
				return false
			m.shots.fire(from + dir * 8.0, dir * 420.0, 180.0, roundi(int(it["damage"]) * m.combat._boon()), true,
				float(it.get("knockback", 1.2)) / 3.0, {"look": "giavellotto", "pierce": int(it.get("pierce", 1))})
			_cool = 0.35
		_:
			return false
	m.sfx.play("tira", from)
	return true


func _sprite(id: String) -> Sprite2D:
	var sp := Sprite2D.new()
	sp.texture = SlotView.icon(id)
	sp.scale = Vector2(0.75, 0.75)
	sp.z_index = 6
	m.fx.add_child(sp)
	return sp


func _process(dt: float) -> void:
	_cool = maxf(_cool - dt, 0.0)
	for i in range(_bombs.size() - 1, -1, -1):
		var b := _bombs[i]
		var sp: Sprite2D = b["node"]
		var v: Vector2 = b["vel"]
		v.y += GRAV * Creature.grav * dt
		var np := sp.position + v * dt
		# rimbalza sulla roccia, perdendo slancio
		if m.world.solid(floori(np.x / S), floori(sp.position.y / S)):
			v.x = -v.x * 0.4
			np.x = sp.position.x
		if m.world.solid(floori(np.x / S), floori(np.y / S)):
			v.y = -v.y * 0.35
			v.x *= 0.7
			np.y = sp.position.y
		sp.position = np
		sp.rotation += v.x * dt * 0.05
		b["vel"] = v
		b["t"] = float(b["t"]) + dt
		var bl: Dictionary = b["blast"]
		# la miccia: il baccello lampeggia sempre più in fretta
		sp.modulate = Color(2.0, 1.4, 1.0) if int(float(b["t"]) * (4.0 + float(b["t"]) * 8.0)) % 2 == 0 else Color.WHITE
		if float(b["t"]) >= float(bl["fuse"]):
			explode(sp.position, bl)
			sp.queue_free()
			_bombs.remove_at(i)
	_move_rang(dt)


## Il seme ricurvo: avanti per un tratto, poi torna al Germogliato; ferisce ciò che tocca (ognuno una volta per tratto).
func _move_rang(dt: float) -> void:
	if _rang.is_empty():
		return
	var sp: Sprite2D = _rang["node"]
	_rang["t"] = float(_rang["t"]) + dt
	var hand: Vector2 = m.player.position + Vector2(0, -8)
	if not _rang["back"] and (float(_rang["t"]) >= float(_rang["out"]) \
			or m.world.solid(floori(sp.position.x / S), floori(sp.position.y / S))):
		_rang["back"] = true
		_rang["hits"] = {}
	if _rang["back"]:
		_rang["vel"] = (hand - sp.position).normalized() * float(_rang["speed"]) * 1.1
		if sp.position.distance_to(hand) < 14.0:
			sp.queue_free()
			_rang = {}
			return
	sp.position += (_rang["vel"] as Vector2) * dt
	sp.rotation += dt * 18.0
	var hits: Dictionary = _rang["hits"]
	for c in m.fauna.list.duplicate():
		if not hits.has(c) and c.rect().grow(4.0).has_point(sp.position):
			hits[c] = true
			m.combat._strike(c, int(_rang["dmg"]), sp.position.x, 0.5)


## Lo scoppio di un baccello: roccia rotta fino alla sua forza, creature ferite, il Germogliato se è vicino.
func explode(at: Vector2, bl: Dictionary) -> void:
	blasts += 1
	Mind.noise(at, Senses.BLAST_NOISE)            # voce 129: tutti vengono a vedere
	var r: float = float(bl["radius"])
	var power := int(bl["power"])
	var ctr := Vector2i(floori(at.x / S), floori(at.y / S))
	for y in range(ctr.y - ceili(r), ctr.y + ceili(r) + 1):
		for x in range(ctr.x - ceili(r), ctr.x + ceili(r) + 1):
			var q := Vector2i(x, y)
			if Vector2(q - ctr).length() > r or not m.world.inside(x, y) or y >= m.world.h - 1:
				continue
			var t: int = m.world.tile(x, y)
			if t != TileDefs.AIR and int(TileDefs.POWER.get(t, 999)) <= power and m.world.tree_at(q + Vector2i(0, -1)).x < 0:
				m.actions.break_tile(q)
	var dmg := int(bl["damage"])
	for c in m.fauna.list.duplicate():
		if c.position.distance_to(at) < (r + 1.0) * S:
			m.combat._strike(c, dmg, at.x, 1.2)
	if m.player.position.distance_to(at) < (r + 0.5) * S:
		m.combat.hurt_player(int(dmg * 0.4), at.x)
	Fx.puff(m.fx, at, Color(2.6, 1.6, 0.7))
	Fx.dust(m.fx, at, Px.pal(TileDefs.P_BRACE))
	m.sfx.play("scoppio", at)
	var lm: LightMap = m.light           # il lampo dura un attimo (si cattura la luce, non il nodo)
	lm.set_extra("scoppio", [[ctr, Color(3.0, 2.0, 1.0)]])
	get_tree().create_timer(0.18).timeout.connect(func() -> void: lm.set_extra("scoppio", []))
