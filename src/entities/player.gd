class_name Player
extends Node2D
## Il personaggio: movimento, salto e animazione. Fermo e corsa usano gli sprite di Nano Banana (`HeroSprites`); le
## altre pose (salto, colpo, mira, torcia) sono ancora disegnate dal codice: nascono da una posa
## (angoli di braccia e gambe) e vengono messi da parte la prima volta che servono.

## Il corpo che urta i blocchi: 10 x 30 pixel. Lo sprite è alto 36 (Nano Banana, 26 set 2026) ma il corpo resta sotto
## i 32 dei cunicoli alti 2 blocchi (scelta dell'utente): il germoglio e la punta dei capelli sporgono sopra.
const HALF := Vector2(5, 15)
# Valori di base, senza modificatori (24 set 2026, richiesta dell'utente: più lento, salto di 3 blocchi, più fluido).
const RUN := 95.0                      # velocità massima di corsa, px/s (~6 tessere al secondo)
const ACCEL_GROUND := 750.0            # accelerazione a terra: ~0,13 s per arrivare alla velocità piena
const DECEL_GROUND := 950.0            # frenata a terra quando si lasciano i tasti
const ACCEL_AIR := 520.0               # controllo in aria, un po' più morbido
const GRAV := 820.0
const JUMP := 297.0                    # salto pieno 3,36 tessere (h = v²/2g, uguale a ogni frequenza): basta per 3 blocchi
const JUMP_CUT := 1.6                  # gravità in più in salita se si lascia il tasto (salto corto)
const MAX_FALL := 520.0
const GLIDE_FALL := 75.0               # caduta massima planando (Foglia planante, tenendo Spazio)
const MAX_DT := 1.0 / 30.0             # oltre questo passo il movimento si divide in più passi

var world: World
## Comandi simulati quando `control` è falso (prove automatiche, in futuro i bot): direzione -1/0/1 e salto tenuto.
var auto_dir := 0.0
var auto_jump := false
var vel := Vector2.ZERO
var on_floor := false
var facing := 1
var control := true
var swinging := false
var force_swing := false
var swing_period := 0.3               # secondi per un giro dell'attrezzo (le armi lo cambiano, vedi `Combat`)
var run_mult := 1.0                    # accessori (vedi `GearEffects`)
var boon_run := 1.0                    # Pozione del passo lungo (vedi `Boons`)
var slow_t := 0.0                      # invischiato in una ragnatela (voce 22): corre a metà per qualche secondo
var jump_mult := 1.0
var glide := false
# voce 31: muoversi meglio
var air_jumps := 0                     # salti in aria concessi dagli accessori (Baccello di vento, Seme di tempesta)
var wall_climb := false                # Artigli di corteccia: scivolare lungo le pareti e saltarci via
var hook := Vector2.INF                # punto a cui è agganciato il rampino (INF = sganciato)
var hook_speed := 330.0
var _air_left := 0
var _wall := 0                         # -1/1: parete toccata a sinistra/destra mentre si scivola
signal air_jumped
var aim := NAN                         # angolo del braccio che mira con l'arco (NAN = non mira)
var tool_tex: Texture2D
var carry := false                     # tiene in mano una torcia o una lanterna: si vede sempre, a braccio avanti
var carry_glow := Color.BLACK          # colore della fiamma in cima (nero = niente fiamma)
var flame: Sprite2D
var _flicker := 0.0
var rig: Node2D
var spr: Sprite2D
var tool: Sprite2D
var eye: Sprite2D                      # l'occhio d'ambra, disegnato sopra il buio: brilla nelle grotte
var look := {}                         # armatura indossata: posto -> metallo (vedi `set_look`)
var _look_key_source := ""             # l'equipaggiamento da cui è stato calcolato `look`
var _look_key := ""
## Caduta: altezza massima raggiunta in aria, per le ferite da caduta (segnale `landed` con le tessere di caduta).
var _air_top := 0.0
var _was_floor := true
signal landed(tiles: float)
signal jumped
var anim_t := 0.0
var swing_t := 0.0
var coyote := 0.0
var jump_buf := 0.0
var step_vis := 0.0
var _cache := {}
var _run_t := 0.0                      # posa della corsa degli sprite nuovi (vedi `HeroSprites`)
var _idle_t := 0.0                     # tempo del respiro
var _takeoff_t := 0.0                  # la posa della spinta, appena staccati da terra
var _land_t := 0.0                     # la posa dell'atterraggio, appena toccato terra


func setup(wd: World) -> void:
	world = wd
	rig = Node2D.new()
	add_child(rig)
	tool = Sprite2D.new()
	tool.offset = Vector2(4.5, -4.5)
	tool.visible = false
	rig.add_child(tool)
	spr = Sprite2D.new()
	spr.position = Vector2(0, -3)
	rig.add_child(spr)
	rig.move_child(tool, 1)
	# la fiamma della torcia in mano: un punto acceso sopra il buio (la luce vera la dà `Boons`)
	var fi := Image.create_empty(5, 6, false, Image.FORMAT_RGBA8)
	for q in [[2, 0, "#ffe8b0"], [1, 1, "#ffc060"], [2, 1, "#fff4d0"], [3, 1, "#ffc060"], [1, 2, "#ff9a30"],
			[2, 2, "#ffe0a0"], [3, 2, "#ff9a30"], [2, 3, "#ffb040"], [1, 3, "#e06a20"], [3, 3, "#e06a20"]]:
		fi.set_pixel(int(q[0]), int(q[1]), Color(String(q[2])))
	flame = Sprite2D.new()
	flame.texture = ImageTexture.create_from_image(fi)
	flame.z_as_relative = false
	flame.z_index = 26
	flame.visible = false
	rig.add_child(flame)
	var ei := Image.create_empty(1, 2, false, Image.FORMAT_RGBA8)
	ei.fill(CharacterArt.EYE)
	eye = Sprite2D.new()
	eye.texture = ImageTexture.create_from_image(ei)
	eye.modulate = Color(2.4, 1.6, 0.7)
	eye.z_as_relative = false
	eye.z_index = 27
	rig.add_child(eye)


func _unhandled_input(e: InputEvent) -> void:
	if not control:
		return
	if e is InputEventKey and e.pressed and not e.echo and (e.keycode == KEY_SPACE or e.keycode == KEY_W or e.keycode == KEY_UP):
		jump_buf = 0.14


func _ready() -> void:
	process_priority = -1              # si muove prima che la scena sposti la camera: niente scatti di un fotogramma


## Il movimento gira a ogni fotogramma disegnato (non a 60 passi fissi): fluido anche sugli schermi a 120/144 Hz.
func _process(delta: float) -> void:
	var dir := auto_dir
	var held := auto_jump
	var typing := get_viewport().gui_get_focus_owner() is LineEdit   # si scrive nella ricerca delle ricette
	if control and not typing:
		dir = 0.0
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			dir -= 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			dir += 1.0
		held = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	elif control and typing:
		dir = 0.0
		held = false
	elif auto_jump and on_floor:
		jump_buf = 0.14
	var left := delta
	while left > 0.0:
		var dt := minf(left, MAX_DT)
		left -= dt
		_step(dt, dir, held)
	step_vis = move_toward(step_vis, 0.0, 120.0 * delta)
	if dir != 0.0 and not swinging:
		facing = 1 if dir > 0.0 else -1
	_animate(delta)


## Cambia l'armatura disegnata (da {posto: id} dell'equipaggiamento).
func set_look(equip: Dictionary) -> void:
	var l := {}
	for k in equip:
		var ic: Array = ItemsData.get_item(equip[k]).get("icon", [])
		if ic.size() == 2:
			l[k] = String(ic[1])
	look = l
	_look_key = str(l)
	_cache.clear()


## Spostato di colpo (specchio, portale, rinascita, prove): la caduta ricomincia da qui, altrimenti atterrando dopo
## un salto in aria contava tutta la distanza del viaggio come una caduta (e il Germogliato appassiva).
func reset_fall() -> void:
	_air_top = position.y


## Un passo di movimento. Lo spostamento usa la velocità media del passo (prima e dopo la gravità): è il calcolo
## esatto per un'accelerazione costante, così il salto è alto uguale a 60 come a 144 fotogrammi al secondo.
func _step(dt: float, dir: float, held: bool) -> void:
	slow_t = maxf(slow_t - dt, 0.0)
	if hook != Vector2.INF:
		_hook_step(dt)
		return
	if on_floor:
		_air_left = air_jumps
	var target := dir * RUN * run_mult * boon_run * (0.45 if slow_t > 0.0 else 1.0)
	var accel := ACCEL_AIR
	if on_floor:
		accel = ACCEL_GROUND if dir != 0.0 and signf(dir) == signf(vel.x if vel.x != 0.0 else dir) else DECEL_GROUND
	var vx0 := vel.x
	vel.x = move_toward(vel.x, target, accel * dt)
	jump_buf -= dt
	if jump_buf > 0.0 and coyote > 0.0:
		vel.y = -JUMP * sqrt(jump_mult)       # l'altezza cresce col quadrato della velocità: ×jump in altezza
		_takeoff_t = 0.1
		jumped.emit()
		jump_buf = 0.0
		coyote = 0.0
	elif jump_buf > 0.0 and _wall != 0:
		# salto dalla parete: via dal muro e in su
		vel = Vector2(-_wall * 210.0, -JUMP * 0.95 * sqrt(jump_mult))
		jumped.emit()
		jump_buf = 0.0
		_wall = 0
	elif jump_buf > 0.0 and _air_left > 0:
		# salto in aria: un soffio di vento sotto i piedi
		_air_left -= 1
		vel.y = -JUMP * 0.9 * sqrt(jump_mult)
		_takeoff_t = 0.1
		air_jumped.emit()
		jump_buf = 0.0
	var vy0 := vel.y
	vel.y = minf(vel.y + GRAV * dt, GLIDE_FALL if glide and held and vel.y > 0.0 else MAX_FALL)
	if vel.y < 0.0 and not held:
		vel.y += GRAV * (JUMP_CUT - 1.0) * dt
	var through := control and (Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN))
	var avg := Vector2((vx0 + vel.x) * 0.5, (vy0 + vel.y) * 0.5)
	var r := TileBody.move(world, position, HALF, avg, dt, on_floor, through)
	position = r["pos"]
	var rv: Vector2 = r["vel"]
	if rv.x == 0.0 and avg.x != 0.0:
		vel.x = 0.0
	if rv.y == 0.0 and avg.y != 0.0:
		vel.y = 0.0
	on_floor = r["floor"]
	step_vis += r["stepped"]
	coyote = 0.1 if on_floor else coyote - dt
	# artigli: in aria, spingendo contro una parete, si scivola piano e ci si può saltare via
	_wall = 0
	if wall_climb and not on_floor and dir != 0.0:
		var wx := floori((position.x + dir * (HALF.x + 1.5)) / 16.0)
		if world.solid(wx, floori(position.y / 16.0)) and world.solid(wx, floori((position.y - 8.0) / 16.0)):
			_wall = int(dir)
			vel.y = minf(vel.y, 70.0)
			_air_top = position.y              # scivolando non ci si fa male
			_air_left = air_jumps
	if not on_floor:
		_air_top = position.y if _was_floor else minf(_air_top, position.y)
	elif not _was_floor:
		# l'atterraggio si vede di più dopo una caduta vera
		_land_t = 0.14 if position.y - _air_top > 24.0 else 0.07
		landed.emit((position.y - _air_top) / 16.0)
	_was_floor = on_floor


## Appeso al rampino: tirato verso il punto d'aggancio, senza gravità; arrivato resta appeso. Il salto sgancia.
func _hook_step(dt: float) -> void:
	jump_buf -= dt
	if jump_buf > 0.0:
		hook = Vector2.INF
		jump_buf = 0.0
		vel.y = -JUMP * 0.8
		jumped.emit()
		return
	var to := hook - (position + Vector2(0, -6))
	vel = to.normalized() * hook_speed if to.length() > 12.0 else Vector2.ZERO
	var r := TileBody.move(world, position, HALF, vel, dt, false, false)
	position = r["pos"]
	on_floor = r["floor"]
	_air_top = position.y                  # tirati dal rampino non si cade
	_was_floor = on_floor
	_air_left = air_jumps


func _animate(dt: float) -> void:
	var key := "idle"
	var pose: Dictionary
	if not on_floor and coyote <= 0.0:
		key = "jump" if vel.y < 0.0 else "fall"
		pose = CharacterArt.pose_jump() if vel.y < 0.0 else CharacterArt.pose_fall()
	elif absf(vel.x) > 12.0:
		anim_t += dt * absf(vel.x) / RUN * 20.0
		var k := int(anim_t) % 8
		key = "run%d" % k
		pose = CharacterArt.pose_run(k)
	else:
		anim_t = 0.0
		pose = CharacterArt.pose_idle()
	var sw := swinging or force_swing
	# gli sprite nuovi (fermo, corsa, salto) quando le mani sono libere; il resto lo disegna ancora `CharacterArt`
	_takeoff_t -= dt
	_land_t -= dt
	if key in ["idle", "jump", "fall"] or key.begins_with("run"):
		if not sw and is_nan(aim) and not carry and _hero(key, dt):
			return
	var a := 0.0
	if sw:
		swing_t += dt
		var ph := fmod(swing_t, swing_period) / swing_period
		var step := int(ph * 7.0)
		a = lerpf(3.3, 0.35, step / 6.0)
		pose["fa_u"] = a
		pose["fa_l"] = a
		key += "_s%d" % step
	else:
		swing_t = 0.0
		if not is_nan(aim):
			# mira: il braccio punta verso il bersaglio (angolo a scatti, così le pose restano poche)
			var q := roundi(aim / PI * 12.0)
			a = q * PI / 12.0
			pose["fa_u"] = a
			pose["fa_l"] = a
			key += "_a%d" % q
		elif carry:
			# torcia o lanterna in mano: il braccio avanti, un po' alzato
			a = 2.0
			pose["fa_u"] = a
			pose["fa_l"] = a + 0.3
			key += "_c"
	if not _cache.has(key):
		var d := CharacterArt.character(pose, look)
		_cache[key] = {"tex": ImageTexture.create_from_image(d["img"]), "hand": d["hand"], "eye": d["eye"]}
	var entry: Dictionary = _cache[key]
	spr.texture = entry["tex"]
	spr.position = Vector2(0, HALF.y - 16.0 + step_vis)     # il disegno del codice è 24 x 32, i piedi in fondo
	eye.position = spr.position + (entry["eye"] as Vector2) - Vector2(12, 16)
	eye.visible = true
	rig.scale.x = facing
	var holding := carry and not sw and is_nan(aim)
	tool.visible = (sw or not is_nan(aim) or carry) and tool_tex != null
	if tool.visible:
		tool.texture = tool_tex
		var hand: Vector2 = entry["hand"]
		tool.position = spr.position + hand - Vector2(12, 16)
		if holding:
			# tenuta dritta, il manico nella mano
			tool.offset = Vector2(0, -5)
			tool.rotation = 0.15
		else:
			tool.offset = Vector2(4.5, -4.5)
			tool.rotation = atan2(cos(a), sin(a)) + PI * 0.25
	flame.visible = holding and tool.visible and carry_glow != Color.BLACK
	if flame.visible:
		_flicker += dt
		flame.position = tool.position + Vector2(0, -9).rotated(tool.rotation) + Vector2(-0.5, 0)
		var f := 1.0 + 0.18 * sin(_flicker * 17.0) + 0.1 * sin(_flicker * 29.0)
		flame.modulate = carry_glow * f
		flame.scale = Vector2(1.0, 0.9 + 0.15 * sin(_flicker * 13.0))


## Fermo, corsa e salto con gli sprite nuovi del Germogliato (vedi `HeroSprites`). Falso se mancano i file.
func _hero(key: String, dt: float) -> bool:
	var hero := HeroSprites.data()
	var air := key == "jump" or key == "fall"
	var anim := "salto" if air or (_land_t > 0.0 and hero.has("salto")) else "fermo" if key == "idle" else "corsa"
	if not hero.has(anim):
		return false
	var d: Dictionary = hero[anim]
	var k := 0
	if anim == "salto":
		# la posa dalla velocità verticale: spinta appena staccati, poi salita, cima e caduta; a terra l'atterraggio
		if not air:
			k = HeroSprites.Salto.ATTERRA
		elif _takeoff_t > 0.0:
			k = HeroSprites.Salto.SPINTA
		elif vel.y < HeroSprites.SALTO_SU:
			k = HeroSprites.Salto.SALITA
		elif vel.y < -HeroSprites.SALTO_SU:
			k = HeroSprites.Salto.CIMA
		else:
			k = HeroSprites.Salto.CADUTA
	elif anim == "corsa":
		_idle_t = 0.0
		# 12 pose al secondo a piena corsa, più lente se si va piano
		_run_t += dt * absf(vel.x) / RUN * 12.0
		k = int(_run_t) % 8
	else:
		_run_t = 0.0
		_idle_t += dt
		k = HeroSprites.breath_frame(_idle_t)
	var sz: Vector2i = d["size"]
	spr.texture = d["tex"][k]
	# i piedi sul fondo del corpo, il centro della sagoma sul centro del corpo
	var top_left := Vector2(-roundf(float(d["anchor"])), HALF.y - sz.y + step_vis)
	spr.position = top_left + Vector2(sz) * 0.5
	var e: Vector2 = d["eye"][k]
	eye.visible = e != Vector2.INF
	if eye.visible:
		eye.position = top_left + e + Vector2(0.5, 1.0)        # l'occhio è alto 2 pixel: il bagliore al centro
	rig.scale.x = facing
	tool.visible = false
	flame.visible = false
	return true
