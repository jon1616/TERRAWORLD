class_name HeroAnimator
extends RefCounted
## Il Germogliato disegnato con gli sprite di Nano Banana (`HeroSprites`, 26 set 2026): sceglie la posa di ogni
## animazione e mette l'attrezzo nel pugno. Staccato da `Player` perché il file non crescesse oltre le 400 righe:
## `Player` fa il movimento e chiama qui da `_animate` (`swing`, `aim_pose`, `carry_pose`, `ground`); ogni funzione
## restituisce falso se mancano i file, e allora il disegno del codice (`CharacterArt`) fa da riserva.

var p: Player
var run_t := 0.0                       # posa della corsa
var idle_t := 0.0                      # tempo del respiro


func _init(player: Player) -> void:
	p = player


## Fermo, corsa e salto con gli sprite nuovi del Germogliato (vedi `HeroSprites`). Falso se mancano i file.
func ground(key: String, dt: float) -> bool:
	var hero := HeroSprites.data()
	var air := key == "jump" or key == "fall"
	var anim := "salto" if air or (p._land_t > 0.0 and hero.has("salto")) else "fermo" if key == "idle" else "corsa"
	if not hero.has(anim):
		return false
	var d: Dictionary = hero[anim]
	var k := 0
	p.swing_t = 0.0                          # il prossimo colpo ricomincia dall'inizio
	if anim == "salto":
		# la posa dalla velocità verticale: spinta appena staccati, poi salita, cima e caduta; a terra l'atterraggio
		if not air:
			k = HeroSprites.Salto.ATTERRA
		elif p._takeoff_t > 0.0:
			k = HeroSprites.Salto.SPINTA
		elif p.vel.y < HeroSprites.SALTO_SU:
			k = HeroSprites.Salto.SALITA
		elif p.vel.y < -HeroSprites.SALTO_SU:
			k = HeroSprites.Salto.CIMA
		else:
			k = HeroSprites.Salto.CADUTA
	elif anim == "corsa":
		idle_t = 0.0
		# 12 pose al secondo a piena corsa, più lente se si va piano
		run_t += dt * absf(p.vel.x) / Player.RUN * 12.0
		k = int(run_t) % 8
	else:
		run_t = 0.0
		idle_t += dt
		k = HeroSprites.breath_frame(idle_t)
	_show(d, k)
	p.tool.visible = false
	p.flame.visible = false
	return true


## Il colpo (scavare, abbattere, colpire) con gli sprite nuovi: la posa segue il giro dell'attrezzo (`swing_period`),
## l'attrezzo sta nel pugno trovato dall'importatore e ruota con il braccio. Falso se manca la tavola.
func swing(dt: float) -> bool:
	var hero := HeroSprites.data()
	if not hero.has("colpo") or not hero["colpo"].has("hands"):
		return false
	var d: Dictionary = hero["colpo"]
	p.swing_t += dt
	var n: int = (d["tex"] as Array).size()
	var k := mini(int(fmod(p.swing_t, p.swing_period) / p.swing_period * n), n - 1)
	var top_left := _show(d, k)
	p.flame.visible = false
	p.tool.visible = p.tool_tex != null
	if p.tool.visible:
		var hand: Dictionary = d["hands"][k]
		p.tool.texture = p.tool_tex
		p.tool.position = _fist(d, k, top_left)
		# l'angolo del braccio dall'importatore (gradi dall'alto, in senso orario) nella convenzione di `CharacterArt`
		# (0 = giù, PI/2 = avanti), poi lo stesso orientamento dell'attrezzo del disegno del codice
		var a := PI - deg_to_rad(float(hand["gradi"]))
		p.tool.offset = Vector2(4.5, -4.5)
		p.tool.rotation = atan2(cos(a), sin(a)) + PI * 0.25
	return true


## Una posa degli sprite nuovi: piedi sul fondo del corpo, centro sul centro, occhio che brilla. Restituisce l'angolo
## in alto a sinistra dello sprite (per mettere l'attrezzo nel pugno).
func _show(d: Dictionary, k: int) -> Vector2:
	# i piedi sul fondo del corpo, il centro della sagoma sul centro del corpo; l'occhio alto 2 pixel, bagliore al centro
	var sz: Vector2i = d["size"]
	p.spr.texture = d["tex"][k]
	var top_left := Vector2(-roundf(float(d["anchor"])), Player.HALF.y - sz.y + p.step_vis)
	p.spr.position = top_left + Vector2(sz) * 0.5
	var e: Vector2 = d["eye"][k]
	p.eye.visible = e != Vector2.INF
	if p.eye.visible:
		p.eye.position = top_left + e + Vector2(0.5, 1.0)
	p.rig.scale.x = p.facing
	return top_left


## Il pugno di una posa, dal .json dell'importatore.
func _fist(d: Dictionary, k: int, top_left: Vector2) -> Vector2:
	var hp: Array = d["hands"][k]["mano"]
	return top_left + Vector2(float(hp[0]), float(hp[1]))


## La mira (arco, bastoni, rampino): la posa con il braccio più vicino alla direzione del mouse; l'arma nel pugno segue
## l'angolo vero. `aim` è nella convenzione di `CharacterArt` (0 = giù, PI/2 = avanti, PI = su).
func aim_pose() -> bool:
	var hero := HeroSprites.data()
	if not hero.has("mira") or not hero["mira"].has("hands"):
		return false
	var d: Dictionary = hero["mira"]
	var want := 180.0 - rad_to_deg(p.aim)                 # gradi dall'alto, in senso orario
	var k := 0
	var best := INF
	for i in (d["hands"] as Array).size():
		var diff := absf(float(d["hands"][i]["gradi"]) - want)
		diff = minf(diff, 360.0 - diff)
		if diff < best:
			best = diff
			k = i
	var top_left := _show(d, k)
	p.flame.visible = false
	p.tool.visible = p.tool_tex != null
	if p.tool.visible:
		var a := roundi(p.aim / PI * 12.0) * PI / 12.0
		p.tool.texture = p.tool_tex
		p.tool.position = _fist(d, k, top_left)
		p.tool.offset = Vector2(4.5, -4.5)
		p.tool.rotation = atan2(cos(a), sin(a)) + PI * 0.25
	return true


## La torcia (o una lanterna) in mano: in piedi la prima posa, di corsa le 8 della corsa, in aria la posa più alta.
func carry_pose(key: String, dt: float) -> bool:
	var hero := HeroSprites.data()
	if not hero.has("torcia") or not hero["torcia"].has("hands"):
		return false
	var d: Dictionary = hero["torcia"]
	var k := 0
	if key == "jump" or key == "fall":
		k = 4                                          # la posa più alta della corsa
	elif key.begins_with("run"):
		run_t += dt * absf(p.vel.x) / Player.RUN * 12.0
		k = 1 + int(run_t) % 8
	p.swing_t = 0.0
	var top_left := _show(d, k)
	p.tool.visible = p.tool_tex != null
	if p.tool.visible:
		p.tool.texture = p.tool_tex
		p.tool.position = _fist(d, k, top_left)
		# tenuta dritta, il manico nel pugno
		p.tool.offset = Vector2(0, -5)
		p.tool.rotation = 0.15
	p.flame.visible = p.tool.visible and p.carry_glow != Color.BLACK
	p._flame(dt)
	return true


## Le mosse degli accessori: appeso al rampino (tirato o fermo al punto d'aggancio), scivolando lungo una parete
## (di spalle al muro, con le mani ad artiglio) e planando (due pose che oscillano piano). Falso se non è il caso.
func special(dt: float) -> bool:
	var hero := HeroSprites.data()
	if not hero.has("speciali"):
		return false
	var d: Dictionary = hero["speciali"]
	var k := -1
	if p.hook != Vector2.INF:
		k = HeroSprites.Speciali.TIRATO if p.vel.length() > 20.0 else HeroSprites.Speciali.APPESO
		p.facing = 1 if p.hook.x >= p.position.x else -1
	elif p._wall != 0 and not p.on_floor:
		k = HeroSprites.Speciali.PARETE
	elif p.gliding or p.flying:
		idle_t += dt
		var beat := 9.0 if p.flying else 3.0          # voce 90: in volo le braccia battono con le ali
		k = HeroSprites.Speciali.PLANA_A if int(idle_t * beat) % 2 == 0 else HeroSprites.Speciali.PLANA_B
	if k < 0:
		return false
	var top_left := _show(d, k)
	if k == HeroSprites.Speciali.PARETE:
		p.rig.scale.x = -p._wall                     # di spalle al muro
	p.tool.visible = false
	p.flame.visible = false
	if d.has("hands"):
		p.hand_world = p.position + p.rig.position + Vector2(_fist(d, k, top_left).x * p.rig.scale.x,
			_fist(d, k, top_left).y)
	return true


## Ferito (due pose per un attimo) o appassito (quattro pose lente, poi resta nell'ultima finché non rinasce):
## vincono su tutto il resto. Falso se non è il caso o se manca la tavola.
func hurt(dt: float) -> bool:
	var hero := HeroSprites.data()
	if not hero.has("colpito"):
		return false
	var k := -1
	if p.wilting:
		p.wilt_t += dt
		k = 2 + mini(int(p.wilt_t / HeroSprites.WILT_STEP), 3)
	elif p.hurt_t > 0.0:
		k = 0 if p.hurt_t > HeroSprites.HURT_TIME * 0.5 else 1
	if k < 0:
		return false
	_show(hero["colpito"], k)
	p.tool.visible = false
	p.flame.visible = false
	return true
