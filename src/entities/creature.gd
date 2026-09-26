class_name Creature
extends Node2D
## Una creatura qualunque del Giardino: i dati vengono da `CreaturesData`, il modo di muoversi e di attaccare dai
## comportamenti combinati (`Behavior`). Qui ci sono solo la fisica (a terra o in volo), l'animazione, i colpi
## subiti (danno, contraccolpo, lampo bianco) e la barra della vita.

var id := ""
var data: Dictionary
var p: Dictionary                      # parametri dei comportamenti
var world: World
var target: Node2D
var rng := RandomNumberGenerator.new()
var hp := 1
var hp_max := 1
var damage := 0
var defense := 0
var knock := 0.0
var half := Vector2(6, 6)
var speed := 60.0
var fly := false
# stato e intenzioni (scritte dai comportamenti)
var vel := Vector2.ZERO
var on_floor := false
var facing := 1
var want_x := 0.0
var want_fly := Vector2.ZERO
var busy := false                      # un comportamento ha il controllo (es. la carica)
var crouch := 0.0                      # 0-1: si schiaccia prima di saltare
var shake := 0.0                       # trema (rincorsa)
var mouth := false                     # bocca aperta (sputaspore)
var fire: Array[Dictionary] = []       # colpi da sparare: li raccoglie la fauna
var summons: Array[String] = []        # creature chiamate in aiuto: le fa nascere la fauna
var minions := 0                       # quante di quelle chiamate sono ancora vive
var master: Creature                   # chi l'ha chiamata in aiuto (se qualcuno l'ha fatto)
var boss := false                      # un Guardiano (vedi `CreaturesData`)
var enraged := false                   # seconda fase: sotto `p.phase2` della Vita
var calm := false                      # guarito: non attacca più, non fa danno
var stun := 0.0
var ancient: Ancient                   # creatura antica o ancestrale (voce 20b); null per le comuni
var regen_acc := 0.0
var poison_t := 0.0                    # avvelenata da un'arma con il tratto Veleno: perde Vita per qualche secondo
# voce 22: i comportamenti nuovi
var anchored := false                  # ferma dov'è, senza fisica (appesa al soffitto, travestita da roccia)
var upside := false                    # disegnata a testa in giù (appesa al soffitto)
var ghost := false                     # attraversa la terra (chi scava)
var buried := false                    # non si vede (dentro la terra)
var shell := 0.0                       # chiusa nel guscio: ferma, un quarto del danno
var just_hit := false                  # appena colpita (lo legge il guscio)
var chill_t := 0.0                     # rallentata dal freddo (Bastone di lagunite): metà velocità
var burn_t := 0.0                      # voce 51: brucia (elemento brace), perde `burn_dps` al secondo
var burn_dps := 0.0
var weak_t := 0.0                      # voce 51: vulnerabile (elemento vuoto), ogni colpo fa di più
var elem := ""                         # voce 51: il segno dell'ultimo elemento, che aspetta una reazione
var elem_t := 0.0
var _burn_acc := 0.0
var extra := false                     # parte di uno sciame o di un branco: non conta nel tetto delle creature
var _poison_acc := 0.0
var behaviors: Array[Behavior] = []
var _spr: Sprite2D
var _glow: Sprite2D
var _frames: Array = []
var _glows: Array = []
var _anim := 0.0
var _flash := 0.0
var _bar: HpBar
var _base_y := 0.0

static var _art_cache := {}
const POISON_DPS := 4.0


func setup(cid: String, w: World, tgt: Node2D, sd: int) -> void:
	id = cid
	data = CreaturesData.CREATURES[cid]
	p = data.get("p", {})
	world = w
	target = tgt
	rng.seed = sd
	hp_max = int(data["hp"])
	hp = hp_max
	damage = int(data["damage"])
	defense = int(data.get("defense", 0))
	knock = float(data.get("knock", 0.0))
	half = Vector2(data["half"][0], data["half"][1])
	speed = float(data.get("speed", 60))
	fly = bool(data.get("fly", false))
	boss = bool(data.get("boss", false))
	for b in data["behaviors"]:
		behaviors.append(Behavior.make(b))
	var art: Array = data["art"]
	_load_art(String(art[0]), int(art[1]))
	_spr = Sprite2D.new()
	_spr.texture = _frames[0]
	var h: int = (_frames[0] as Texture2D).get_height()
	_spr.offset = Vector2(0, -h / 2.0)
	_spr.position = Vector2(0, half.y)
	if data.get("roll", false):
		# chi rotola gira attorno al proprio centro, non ai piedi
		_spr.offset = Vector2.ZERO
		_spr.position = Vector2(0, half.y - h / 2.0)
	_base_y = _spr.position.y
	add_child(_spr)
	if data.get("glow", false):
		_glow = Sprite2D.new()
		_glow.texture = _glows[0]
		_glow.offset = _spr.offset
		_glow.position = _spr.position
		_glow.modulate = Color(1.8, 1.5, 1.2)
		_glow.z_as_relative = false
		_glow.z_index = 26
		add_child(_glow)
	_bar = HpBar.new()
	_bar.position = Vector2(0, -half.y - 8)
	add_child(_bar)


## Fotogrammi di una forma e variante (messi da parte la prima volta: tutte le creature uguali li condividono).
func _load_art(shape: String, variant: int) -> void:
	var key := "%s_%d" % [shape, variant]
	if not _art_cache.has(key):
		var fr := CreatureArt.frames(shape, variant)
		var t_fr := []
		var t_gl := []
		for im in fr["frames"]:
			t_fr.append(ImageTexture.create_from_image(im))
		for im in fr["glow"]:
			t_gl.append(ImageTexture.create_from_image(im))
		_art_cache[key] = [t_fr, t_gl]
	_frames = _art_cache[key][0]
	_glows = _art_cache[key][1]


## Il Guardiano guarito: smette di attaccare, cambia aspetto (variante 1) e sale piano verso il Cuore.
func make_calm() -> void:
	calm = true
	damage = 0
	busy = false
	shake = 0.0
	var art: Array = data["art"]
	_load_art(String(art[0]), 1)
	_bar.visible = false


## Più forte negli strati profondi: Vita e danno moltiplicati.
func strengthen(mult: float, dmg_mult := -1.0) -> void:
	hp_max = int(round(hp_max * mult))
	hp = hp_max
	damage = int(round(damage * (mult if dmg_mult < 0.0 else dmg_mult)))


func rect() -> Rect2:
	return Rect2(position - half, half * 2.0)


## C'è terreno davanti ai piedi (per non cadere nei burroni mentre si gironzola)?
func ground_ahead(dir: int) -> bool:
	var x := floori((position.x + dir * (half.x + 2.0)) / 16.0)
	var y := floori((position.y + half.y + 2.0) / 16.0)
	return world.solid(x, y) or world.solid(x, y + 1)


## C'è un muro davanti (alto almeno due tessere, perché una la supera il gradino automatico)?
func wall_ahead(dir: int) -> bool:
	var x := floori((position.x + dir * (half.x + 2.0)) / 16.0)
	var y := floori((position.y + half.y - 1.0) / 16.0)
	return world.solid(x, y) and world.solid(x, y - 1)


func _process(dt: float) -> void:
	dt = minf(dt, 1.0 / 30.0)
	stun = maxf(stun - dt, 0.0)
	enraged = boss and hp < hp_max * float(p.get("phase2", 0.0))
	if calm:
		want_fly = Vector2(sin(_anim) * 10.0, -6.0)
	elif stun <= 0.0 or boss:
		for b in behaviors:
			b.tick(self, dt)
	if chill_t > 0.0:
		chill_t -= dt
		want_x *= 0.45
		want_fly *= 0.45
	if anchored:
		vel = Vector2.ZERO
	elif ghost:
		# dentro la terra nuota verso dove vuole; fuori vola con il suo slancio e ricade
		if world.solid(floori(position.x / 16.0), floori(position.y / 16.0)):
			vel = vel.move_toward(want_fly if stun <= 0.0 else Vector2.ZERO, 500.0 * dt)
		else:
			vel.y = minf(vel.y + 900.0 * dt, 520.0)
		position += vel * dt
		position.y = minf(position.y, world.h * 16.0 - 24.0)
		on_floor = false
	else:
		if fly:
			vel = vel.move_toward(want_fly if stun <= 0.0 or boss else Vector2.ZERO, (900.0 if busy else 360.0) * dt)
		else:
			vel.y = minf(vel.y + 900.0 * dt, 520.0)
			if on_floor and not busy:
				vel.x = move_toward(vel.x, want_x * speed if stun <= 0.0 else 0.0, 700.0 * dt)
		var was := on_floor
		var r := TileBody.move(world, position, half, vel, dt, on_floor and not fly)
		position = r["pos"]
		vel = r["vel"]
		on_floor = r["floor"]
		if on_floor and not was:
			crouch = -0.6                  # si schiaccia atterrando
	_animate(dt)
	if ancient:
		ancient.tick(self, dt)
	elem_t = maxf(elem_t - dt, 0.0)
	weak_t = maxf(weak_t - dt, 0.0)
	if burn_t > 0.0:
		burn_t -= dt
		_burn_acc += burn_dps * dt
		var kb := int(_burn_acc)
		if kb > 0:
			_burn_acc -= kb
			hp -= kb
			_bar.set_value(float(hp) / hp_max)
			modulate = Color(1.6, 0.9, 0.5)
	if poison_t > 0.0:
		poison_t -= dt
		_poison_acc += POISON_DPS * dt
		var k := int(_poison_acc)
		if k > 0:
			_poison_acc -= k
			hp -= k                        # se arriva a zero la fauna se ne accorge e la toglie con il bottino
			_bar.set_value(float(hp) / hp_max)
			modulate = Color(0.7, 1.4, 0.6)
	elif chill_t > 0.0:
		modulate = Color(0.7, 0.95, 1.5)
	elif burn_t > 0.0:
		pass
	elif modulate.g > 1.0 or modulate.b > 1.0 or modulate.r > 1.0:
		modulate = Color.WHITE


func _animate(dt: float) -> void:
	_anim += dt
	var f := 0
	var moving := fly or absf(vel.x) > 5.0
	if data.get("disguise", false):
		# il primo fotogramma è il travestimento (una roccia); sveglia cammina con gli altri due
		f = 0 if anchored else 1 + (int(_anim * 7.0) % 2 if moving else 0)
	elif shell > 0.0 and _frames.size() > 2:
		f = 2
	elif _frames.size() > 1:
		if mouth:
			f = 1
		elif moving:
			f = int(_anim * (12.0 if fly else 7.0)) % 2
	_spr.texture = _frames[f]
	if _glow:
		_glow.texture = _glows[f]
	var sx := float(facing)
	var sq := Vector2.ONE
	if id.begins_with("grumo"):
		if not on_floor:
			sq = Vector2(0.85, 1.18)
		else:
			var c := crouch if crouch > 0.0 else -crouch
			sq = Vector2(1.0 + c * 0.3, 1.0 - c * 0.3)
			if crouch < 0.0:
				crouch = move_toward(crouch, 0.0, dt * 4.0)
	_spr.scale = Vector2(sx * sq.x, sq.y * (-1.0 if upside and anchored else 1.0))
	_spr.position.y = -half.y if upside and anchored else _base_y
	if data.get("roll", false) and busy and absf(vel.x) > 20.0:
		_spr.rotation += vel.x * dt / maxf(half.x, 1.0)
	elif _spr.rotation != 0.0 and not busy:
		_spr.rotation = 0.0
	_spr.visible = not buried
	if _glow:
		_glow.scale = _spr.scale
		_glow.position = _spr.position
		_glow.rotation = _spr.rotation
		_glow.visible = not buried
	_spr.position.x = randf_range(-1.0, 1.0) if shake > 0.0 else 0.0
	_flash = maxf(_flash - dt, 0.0)
	_spr.modulate = Color(3, 3, 3) if _flash > 0.0 else (Color(1.35, 0.8, 0.8) if enraged and not calm else Color.WHITE)


## Colpo subito: toglie Vita (meno metà della difesa), spinge via, fa lampeggiare. True se la creatura muore.
func take_hit(dmg: int, from_x: float, force: float) -> bool:
	if weak_t > 0.0:
		dmg = roundi(dmg * ElementsData.VULNERABLE)
	var real := maxi(dmg - defense / 2, 1)
	if shell > 0.0:
		real = maxi(real / 4, 1)               # chiusa nel guscio
	elif "guscio" in data["behaviors"]:
		shell = float(p.get("shell_time", 2.5))   # si chiude dopo il primo colpo (lo tiene aperto `BhGuscio`)
	just_hit = true
	hp -= real
	_flash = 0.12
	stun = maxf(stun, 0.22)                 # non accorcia uno stordimento più lungo (reazioni, voce 51)
	var dir := signf(position.x - from_x)
	if dir == 0.0:
		dir = 1.0
	var k := (1.0 - knock) * force
	if boss:
		_bar.visible = false               # la Vita di un Guardiano sta nella barra in alto
	vel = Vector2(dir * 70.0 * k, -150.0 * k if not fly else -60.0 * k)
	on_floor = false
	_bar.set_value(float(hp) / float(hp_max))
	Fx.float_text(get_parent(), position + Vector2(0, -half.y - 6), str(real), Color("#ffe0a0"))
	return hp <= 0
