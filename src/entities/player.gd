class_name Player
extends Node2D
## Il personaggio: movimento, salto e animazione. Le pose le disegna `HeroAnimator` con gli sprite di Nano Banana
## (fermo, corsa, salto, colpo, mira, torcia); se mancano i file, il disegno del codice (`CharacterArt`): pose fatte di
## angoli di braccia e gambe, messe da parte la prima volta che servono.

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
var gliding := false                   # sta planando adesso (per la posa)
var hurt_t := 0.0                      # appena ferito: le pose della ferita (vedi `HeroAnimator.hurt`)
var wilting := false                   # appassito (Vita finita): le pose dell'appassire finché non rinasce
var wilt_t := 0.0
var hand_world := Vector2.INF          # il pugno nel mondo, se la posa lo ha (la corda del rampino parte da qui)
# voce 31: muoversi meglio
var air_jumps := 0                     # salti in aria concessi dagli accessori (Baccello di vento, Seme di tempesta)
var wall_climb := false                # Artigli di corteccia: scivolare lungo le pareti e saltarci via
var hook := Vector2.INF                # punto a cui è agganciato il rampino (INF = sganciato)
var hook_speed := 330.0
var in_liquid := false                 # voce 73: nuota (acqua o Linfa fino al petto)
var wind := 0.0                        # voce 75: il vento (px/s², solo in superficie), lo imposta `Weather`
var effect_run := 1.0                  # voce 85: gli effetti (Slancio, Pinne, Vento alle spalle)
var harsh_run := 1.0                   # voce 93: i rigori delle terre estreme (freddo, polvere)
var harsh_jump := 1.0
var weather_run := 1.0                 # voce 75: la bufera rallenta la corsa
var grav_mult := 1.0                   # voce 76: il peso del mondo (gene Lieve, Arcipelago), lo imposta `Gravity`
var lift := 0.0                        # voce 76: dentro una corrente ascensionale, la velocità di salita (solo tenendo Salto)
var wings := {}                        # voce 90: le ali indossate (`FlightData.WINGS`), vuoto = niente volo
var fly_left := 0.0                    # voce 90: l'autonomia che resta, in secondi
var flying := false                    # voce 90: vola adesso (posa, ali, vento)
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
## Roadmap 52, voce 415: le corde. `climbing` = aggrappato; `auto_down` = Giù per le prove (come `auto_jump`).
var climbing := false
var auto_down := false
const CLIMB_UP := 72.0                 # px/s su una corda (la catena ×1,5, la liana ×0,8: `TileDefs.CLIMB_SPEED`)
const CLIMB_SIDE := 45.0               # di lato, aggrappati: spostandosi fuori dalla corda la si lascia
var _was_floor := true
signal landed(tiles: float)
signal jumped
var anim_t := 0.0
var swing_t := 0.0
var coyote := 0.0
var jump_buf := 0.0
var step_vis := 0.0
var _cache := {}
var hero: HeroAnimator                 # gli sprite nuovi del Germogliato (vedi `HeroAnimator`)
var _takeoff_t := 0.0                  # la posa della spinta, appena staccati da terra
var _land_t := 0.0                     # la posa dell'atterraggio, appena toccato terra


func setup(wd: World) -> void:
	world = wd
	hero = HeroAnimator.new(self)
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
	if Keys.pressed(e, "salto"):
		jump_buf = 0.14


func _ready() -> void:
	process_priority = -1              # si muove prima che la scena sposti la camera: niente scatti di un fotogramma


## Il movimento gira a ogni fotogramma disegnato (non a 60 passi fissi): fluido anche sugli schermi a 120/144 Hz.
func _process(delta: float) -> void:
	var dir := auto_dir
	var held := auto_jump
	var fo := get_viewport().gui_get_focus_owner()
	var typing: bool = fo is LineEdit and fo.is_visible_in_tree()   # si scrive nella ricerca delle ricette (se si vede)
	if control and not typing:
		dir = 0.0
		if Keys.held("sinistra"):
			dir -= 1.0
		if Keys.held("destra"):
			dir += 1.0
		held = Keys.held("salto")
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
## Voce 127: la schivata (la sbloccano gli accessori: `GearEffects` scrive dash_ok e dash_cd_mult).
var dash_ok := false
var dash_cd_mult := 1.0
var dash_t := 0.0
var dash_cd_t := 0.0
var dash_dir := 1.0


## Uno scatto nella direzione dir (-1, 1; 0 = dove guarda). Falso se non si può (niente oggetto, in ricarica).
func try_dash(dir: float) -> bool:
	if not dash_ok or dash_cd_t > 0.0 or hook != Vector2.INF:
		return false
	dash_dir = signf(dir) if dir != 0.0 else float(facing)
	dash_t = DashData.TIME
	dash_cd_t = DashData.COOLDOWN * dash_cd_mult
	return true


func _step(dt: float, dir: float, held: bool) -> void:
	slow_t = maxf(slow_t - dt, 0.0)
	dash_cd_t = maxf(dash_cd_t - dt, 0.0)
	if hook != Vector2.INF:
		_hook_step(dt)
		return
	if _climb_step(dt, dir, held):
		return
	if on_floor:
		_air_left = air_jumps
	var target := dir * RUN * run_mult * boon_run * (0.45 if slow_t > 0.0 else 1.0)
	var cx := floori(position.x / 16.0)
	var cy := floori(position.y / 16.0)
	# Roadmap 52, voce 412: il pavimento sotto i piedi (il ghiaccio scivola, il fango appiccica)
	var fy := floori((position.y + HALF.y + 2.0) / 16.0)
	var ft := world.tile(cx, fy) if on_floor else 0
	var pk := world.plat_kind(cx, fy) if on_floor and ft == 0 else 0     # voce 416: la passerella sotto i piedi
	var stick := TileDefs.STICK[ft] if ft > 0 else 1.0
	var slip := TileDefs.SLIP[ft] if ft > 0 else TileDefs.PLAT_SLIP[pk]
	target *= stick
	in_liquid = world.liq(cx, cy) >= 3 and bool(LiquidsData.TYPES[world.liq_type(cx, cy)]["swim"])
	if in_liquid:
		target *= LiquidsData.SWIM_RUN
	target *= weather_run * effect_run * harsh_run
	# voce 90: il volo. Tenendo Salto in aria, passata la spinta del salto, le ali sollevano finché dura la barra
	# (comincia quando la spinta del salto cala, poi continua finché si tiene Salto)
	flying = not wings.is_empty() and not on_floor and not in_liquid and held and fly_left > 0.0 \
		and (flying or vel.y > -JUMP * 0.35) and not (lift > 0.0 and held)
	if flying:
		target *= float(wings["speed"])
	if on_floor:
		fly_left = minf(fly_left + float(wings.get("time", 0.0)) * float(wings.get("recharge", 0.0)) * dt, float(wings.get("time", 0.0)))
	elif lift > 0.0 and not wings.is_empty():
		fly_left = minf(fly_left + float(wings["time"]) * float(wings["recharge"]) * FlightData.CURRENT_RECHARGE * dt, float(wings["time"]))
	var accel := ACCEL_AIR
	if on_floor:
		accel = ACCEL_GROUND if dir != 0.0 and signf(dir) == signf(vel.x if vel.x != 0.0 else dir) else DECEL_GROUND
		if slip < 1.0:
			# sul ghiaccio si parte quasi come sempre, ma per fermarsi o girarsi la presa è poca
			accel *= minf(slip * 4.0, 1.0) if accel == ACCEL_GROUND else slip
	if not on_floor and not in_liquid and wind != 0.0:
		target += wind * 0.35 * (2.2 if gliding or flying else 1.0)    # voce 75: il vento porta chi è in aria, e chi plana o vola di più
	var vx0 := vel.x
	vel.x = move_toward(vel.x, target, accel * dt)
	if dash_t > 0.0:
		# voce 127: la schivata vince sul resto del movimento orizzontale e ferma la caduta per un attimo
		dash_t -= dt
		vel.x = dash_dir * DashData.SPEED
		vel.y = minf(vel.y, 20.0)
	jump_buf -= dt
	if jump_buf > 0.0 and coyote > 0.0:
		vel.y = -JUMP * sqrt(jump_mult * harsh_jump * stick * TileDefs.PLAT_JUMP[pk])   # ×jump in altezza (e la Passerella del vento)
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
	gliding = glide and held and vel.y > 0.0 and not on_floor
	if in_liquid:
		# voce 73: nell'acqua si galleggia piano, e tenendo il salto si nuota verso l'alto
		vel.y = minf(vel.y + GRAV * LiquidsData.SWIM_GRAV * dt, LiquidsData.SWIM_FALL)
		if held:
			vel.y = move_toward(vel.y, -LiquidsData.SWIM_UP, 900.0 * dt)
		_air_top = position.y                # nell'acqua non si cade
	elif flying:
		# voce 90: sale verso la sua velocità di salita; in un mondo leggero la barra dura di più
		if vel.y > -float(wings["rise"]):
			vel.y = move_toward(vel.y, -float(wings["rise"]), 1500.0 * dt)
		else:
			vel.y += GRAV * grav_mult * dt          # più veloce della sua salita: la spinta del salto cala da sé
		fly_left = maxf(fly_left - dt * clampf(grav_mult, 0.5, 1.5), 0.0)
	elif lift > 0.0 and held:
		# 29 set 2026 (richiesta dell'utente): la corrente solleva solo tenendo premuto Salto (su); senza, ci si passa
		# voce 76: la corrente ascensionale solleva, e chi ne esce riparte da qui a contare la caduta
		vel.y = move_toward(vel.y, -lift, 1500.0 * dt)
		_air_top = position.y
	else:
		vel.y = minf(vel.y + GRAV * grav_mult * dt, GLIDE_FALL if gliding else MAX_FALL)
		if vel.y < 0.0 and not held:
			vel.y += GRAV * grav_mult * (JUMP_CUT - 1.0) * dt
	var through := control and Keys.held("giu")
	var vy_fall := vel.y                    # voce 415: la velocità di caduta prima di toccare (il rimbalzo)
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
	if on_floor and not _was_floor and vy_fall > 110.0:
		# voce 415: il Cuscino di bava rimanda in alto chi ci cade, e non fa male
		var bc := Vector2i(floori(position.x / 16.0), floori((position.y + HALF.y + 2.0) / 16.0))
		var bt := world.tile(bc.x, bc.y)
		var bb := TileDefs.BOUNCE[bt] if bt > 0 else TileDefs.PLAT_BOUNCE[world.plat_kind(bc.x, bc.y)]
		if bb > 0.0:
			vel.y = -vy_fall * bb
			on_floor = false
			_air_top = position.y
			_was_floor = false
			return
	if not on_floor:
		_air_top = position.y if _was_floor else minf(_air_top, position.y)
	elif not _was_floor:
		# l'atterraggio si vede di più dopo una caduta vera
		_land_t = 0.14 if position.y - _air_top > 24.0 else 0.07
		landed.emit((position.y - _air_top) / 16.0 * grav_mult)   # voce 76: in un mondo leggero si cade più piano
	_was_floor = on_floor


## Roadmap 52, voce 415: corde, liane e catene. Toccandone una e tenendo Salto (su) o Giù ci si aggrappa: si sale, si
## scende, o si resta appesi senza cadere; spostandosi di lato si lascia la corda. In cima, tenendo Salto, un piccolo
## balzo porta sul bordo.
func _climb_step(dt: float, dir: float, held: bool) -> bool:
	var cx := floori(position.x / 16.0)
	var sp := maxf(TileDefs.CLIMB_SPEED[world.decor_at(cx, floori(position.y / 16.0))],
		TileDefs.CLIMB_SPEED[world.decor_at(cx, floori((position.y + HALF.y - 2.0) / 16.0))])
	var down := Keys.held("giu") if control else auto_down
	if sp <= 0.0:
		if climbing and held:
			vel.y = -JUMP * 0.62
		climbing = false
		return false
	if not climbing and not (held or down):
		return false
	climbing = true
	vel.x = dir * CLIMB_SIDE
	vel.y = -CLIMB_UP * sp if held else (CLIMB_UP * sp if down else 0.0)
	var r := TileBody.move(world, position, HALF, vel, dt, false, true)
	position = r["pos"]
	on_floor = r["floor"]
	_air_top = position.y                  # aggrappati non si cade
	_air_left = air_jumps
	_was_floor = on_floor
	jump_buf = 0.0
	coyote = 0.0
	if on_floor and down:
		climbing = false
	return true


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
	hand_world = Vector2.INF
	hurt_t -= dt
	if hero.hurt(dt):
		return
	# le mosse degli accessori vincono su ciò che si tiene in mano (il rampino stesso è «in mano»)
	if not sw and is_nan(aim) and hero.special(dt):
		return
	if sw and hero.swing(dt):
		return
	if not sw and not is_nan(aim) and hero.aim_pose():
		return
	if not sw and is_nan(aim) and carry and hero.carry_pose(key, dt):
		return
	if key in ["idle", "jump", "fall"] or key.begins_with("run"):
		if not sw and is_nan(aim) and not carry and hero.ground(key, dt):
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
	_flame(dt)


## La fiamma della torcia in mano, in cima all'attrezzo: tremola.
func _flame(dt: float) -> void:
	if flame.visible:
		_flicker += dt
		flame.position = tool.position + Vector2(0, -9).rotated(tool.rotation) + Vector2(-0.5, 0)
		var f := 1.0 + 0.18 * sin(_flicker * 17.0) + 0.1 * sin(_flicker * 29.0)
		flame.modulate = carry_glow * f
		flame.scale = Vector2(1.0, 0.9 + 0.15 * sin(_flicker * 13.0))
