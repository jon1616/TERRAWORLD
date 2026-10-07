class_name Creature
extends Node2D
## Una creatura qualunque del Giardino: i dati vengono da `CreaturesData`, il modo di muoversi e di attaccare dai
## comportamenti combinati (`Behavior`). Qui ci sono solo la fisica (a terra o in volo), l'animazione, i colpi
## subiti (danno, contraccolpo, lampo bianco) e la barra della vita.

## Voce 76: il peso del mondo per tutto ciò che cade (creature, oggetti a terra, dardi, bombe); lo imposta `Gravity`.
static var grav := 1.0
var id := ""
var base := ""                         # la specie (per una variante, voce 55: quella da cui nasce)
var data: Dictionary
var docile := false                    # voce 55: non attacca finché non la colpisci
var hunger := 0.0                      # voce 57: fame (caccia e pascolo), 0 = sazia
var hunt: Creature                     # voce 57: la preda che sta cacciando
var family := ""                       # voce 58: la famiglia (per le migrazioni)
var provoked := false
var tame: BhMandria                    # voce 59: della mandria (segue, recinto, cavalcata); null = selvatica
var affection := 0.0                   # voce 59: affetto dal cibo (100 = addomesticata)
var _docile_dmg := 0
var _wander_t := 0.0
var _wander_dir := 0.0
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
var shot_k := 1.0                      # voce 185: quanto crescono i suoi proiettili (lo scrive `strengthen`)
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
## Roadmap 49, voce 405: le creature selvatiche (nate da `Fauna.add`) prendono la Vita e il danno della modalità, e i boss
## la seconda fase prima (`Modes`).
var wild := false
static var mode_hp := 1.0
static var mode_dmg := 1.0
static var mode_phase := 1.0
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
var tele := 0.0                        # voce 127: un attacco si annuncia (il «!» di `TeleMark`), secondi che restano
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
var acts: Array[Dictionary] = []       # voce 130: ciò che le astuzie chiedono al mondo (le fa `Wiles`)
var last_dmg := 0
var _fury := false                     # voce 135: la furia è già cominciata                      # voce 130: il danno dell'ultimo colpo (chi si divide)
var mind := Mind.new()                 # voce 129: sensi e stati (calma, allerta, caccia, fuga, ritorno)
var _spr: Sprite2D
var _shade: Sprite2D                   # (voce 289) l'ombra di contatto
var _aura: Node2D                       # (voce 291) l'alone e le scintille dei boss
var _glow: Sprite2D
var _frames: Array = []
var _glows: Array = []
var _anim := 0.0
var _walk := 0.0                       # Roadmap 33, voce 325: il passo (cresce con la strada fatta)
var _dy := 0.0                         # lo scarto in alto del disegno di questo fotogramma (passo, volo)
var _flash := 0.0
var _bar: HpBar
var _regen := 0.0                      # voce 79: le rigeneranti
var _base_y := 0.0

static var _art_cache := {}
var _more := {}
const POISON_DPS := 4.0


func setup(cid: String, w: World, tgt: Node2D, sd: int, more_mods := {}) -> void:
	_more = more_mods                          # voce 60: il manto e la grandezza di una creatura allevata
	id = cid
	base = CreaturesData.base_of(cid)
	data = CreaturesData.get_data(cid)
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
	# voce 57: i predatori cacciano, gli erbivori brucano (per ultimi: le loro intenzioni vincono)
	family = FamiliesData.family_of(cid)
	var fd: Dictionary = FamiliesData.FAMILIES.get(family, {})
	if not boss and fd.has("prey"):
		var bc := BhCaccia.new()
		bc.prey = fd["prey"]
		behaviors.append(bc)
		hunger = rng.randf_range(0.0, 0.6)
	elif not boss and String(fd.get("role", "")) == "erbivoro":
		var bp := BhPascola.new()
		bp.pest = fd.get("pest", false)
		behaviors.append(bp)
		hunger = rng.randf_range(0.0, 0.6)
	if data.get("docile", false):
		docile = true
		_docile_dmg = damage
		damage = 0
	mind.setup(self)
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
	if not fly:
		_shade = CreatureFx.shadow_sprite(half.x * 2.0)
		_shade.position = Vector2(0, half.y)
		_spr.add_sibling(_shade)
		move_child(_shade, _spr.get_index())
	if boss and bool(Settings.v("particelle")):
		_aura = CreatureFx.aura(self, half)   # voce 291: la presenza dei boss
	add_child(TeleMark.new())                  # voce 127: il segnale degli attacchi
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
	var marks := StatusMarks.new(self)       # voce 101: le icone degli stati sopra la barra
	marks.position = _bar.position + Vector2(0, -2)
	add_child(marks)


## Fotogrammi di una forma e variante (messi da parte la prima volta: tutte le creature uguali li condividono).
func _load_art(shape: String, variant: int) -> void:
	var mods: Dictionary = data.get("art_mods", {}).duplicate()
	mods.merge(_more, true)
	var key := "%s_%d_%s" % [shape, variant, str(mods)]
	if not _art_cache.has(key):
		var fr := CreatureArt.frames(shape, variant)
		if not mods.is_empty():
			fr = VariantArt.apply(fr, mods)            # voce 55: colori, misura e segni della variante
		var t_fr := []
		var t_gl := []
		for im in fr["frames"]:
			t_fr.append(ImageTexture.create_from_image(CreatureFx.shade(im)))   # voce 290: contorno colorato, luce
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
	var dm := mult if dmg_mult < 0.0 else dmg_mult
	if wild:
		mult *= mode_hp                     # Roadmap 49, voce 405: la modalità del Giardino
		dm *= mode_dmg
	shot_k *= mult                          # voce 185: anche i proiettili crescono con lo strato e il vigore
	hp_max = int(round(hp_max * mult))
	hp = hp_max
	damage = int(round(damage * dm))


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
	if data.has("regen") and hp > 0 and hp < hp_max:
		_regen += hp_max * float(data["regen"]) * dt
		if _regen >= 1.0:
			hp = mini(hp + int(_regen), hp_max)
			_regen -= int(_regen)
			_bar.set_value(float(hp) / hp_max)
	enraged = boss and hp < hp_max * minf(float(p.get("phase2", 0.0)) * mode_phase, ModesData.PHASE_MAX)
	if enraged and not _fury and data.has("fury"):
		_fury = true                               # voce 135: la furia di un Signore, a metà Vita
		for b in data["fury"]:
			behaviors.append(Behavior.make(String(b)))
		speed *= 1.25
		telegraph(0.8)
		if get_parent():
			Fx.puff(get_parent(), position, Color(1.8, 0.8, 0.5))
	if tame != null:
		tame.tick(self, dt)                    # voce 59: della mandria, niente comportamenti selvatici
		if tame.mode == "cavalcata":
			_animate(dt)
			return
	elif calm:
		want_fly = Vector2(sin(_anim) * 10.0, -6.0)
	elif docile and not provoked:
		_wander(dt)                            # docile: gironzola finché qualcuno non la colpisce
		for b in behaviors:
			if b is BhPascola:
				b.tick(self, dt)               # ma bruca e scappa dai predatori (voce 57)
	elif stun <= 0.0 or boss:
		mind.tick(self, dt)                    # voce 129: prima i sensi, poi i comportamenti, poi la fuga
		for b in behaviors:
			b.tick(self, dt)
		mind.after(self)
	# voce 58: i branchi in migrazione vanno tutti dalla stessa parte (se non cacciano, non scappano, non combattono)
	var fauna := get_parent()
	if fauna != null and "migration" in fauna and fauna.migration.has(family) and hunt == null \
			and (docile and not provoked or not Behavior.sees(self, float(p.get("sight", 20)))):
		var dir: float = fauna.migration[family]
		if fly:
			want_fly = Vector2(dir * speed * 0.7, want_fly.y)
		else:
			want_x = dir * 0.8
			facing = int(dir)
			if on_floor and wall_ahead(facing):
				vel.y = -260.0
				on_floor = false
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
			vel.y = minf(vel.y + 900.0 * grav * dt, 520.0)
		position += vel * dt
		position.y = minf(position.y, world.h * 16.0 - 24.0)
		on_floor = false
	else:
		if fly:
			vel = vel.move_toward(want_fly if stun <= 0.0 or boss else Vector2.ZERO, (900.0 if busy else 360.0) * dt)
		else:
			vel.y = minf(vel.y + 900.0 * grav * dt, 520.0)
			if on_floor and not busy:
				vel.x = move_toward(vel.x, want_x * speed * _floor_slow() if stun <= 0.0 else 0.0, 700.0 * dt)
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
	var lean := 0.0
	_dy = 0.0
	if id.begins_with("grumo"):
		if not on_floor:
			sq = Vector2(0.85, 1.18)
		else:
			var c := crouch if crouch > 0.0 else -crouch
			sq = Vector2(1.0 + c * 0.3, 1.0 - c * 0.3)
			if crouch < 0.0:
				crouch = move_toward(crouch, 0.0, dt * 4.0)
	elif not anchored and not buried and shell <= 0.0 and not data.get("roll", false):
		_life_motion(dt)
		sq = _sq
		lean = _lean
	if _flash > 0.0:
		sq *= 1.0 + _flash * 0.9                # colpita: un sobbalzo (voce 325)
	_spr.scale = Vector2(sx * sq.x, sq.y * (-1.0 if upside and anchored else 1.0))
	_spr.position.y = (-half.y if upside and anchored else _base_y) + _dy
	if data.get("roll", false) and busy and absf(vel.x) > 20.0:
		_spr.rotation += vel.x * dt / maxf(half.x, 1.0)
	elif not busy or lean != 0.0:
		_spr.rotation = lean
	_spr.visible = not buried
	if _shade:
		_shade.visible = on_floor and not buried and not upside
	# (voce 289) da ferma respira: la metà alta scende di un pixel e risale
	var idle := on_floor and not moving and not busy and not buried and shake <= 0.0
	_spr.material = CreatureFx.breath() if idle else null
	if _glow:
		_glow.scale = _spr.scale
		_glow.position = _spr.position
		_glow.rotation = _spr.rotation
		_glow.visible = not buried
	_spr.position.x = randf_range(-1.0, 1.0) if shake > 0.0 else 0.0
	_flash = maxf(_flash - dt, 0.0)
	_spr.modulate = Color(3, 3, 3) if _flash > 0.0 else (Color(1.35, 0.8, 0.8) if enraged and not calm else Color.WHITE)
	if _aura:
		_aura.visible = not calm and not buried
		var rage := enraged and not calm
		if rage != bool(_aura.get_meta("rage", false)):
			_aura.set_meta("rage", rage)
			var sparks := _aura.get_node("scintille") as CPUParticles2D
			sparks.color_ramp = Fx.fade(Color(2.4, 0.6, 0.4) if rage else Color(2.0, 1.1, 0.5))
			(_aura.get_node("alone") as Sprite2D).self_modulate = Color(1.3, 0.6, 0.6) if rage else Color.WHITE


var _sq := Vector2.ONE
var _lean := 0.0


## Roadmap 33, voce 325: il movimento fatto dal codice, per tutte le creature (avevano due fotogrammi quasi uguali).
## A terra il corpo sobbalza a ogni passo e si inclina nella corsa; in aria si allunga salendo e si schiaccia cadendo;
## atterrando si schiaccia e torna; chi vola ondeggia, batte e si inclina dove va. Scrive `_sq`, `_lean`, `_dy`.
func _life_motion(dt: float) -> void:
	_sq = Vector2.ONE
	var run := clampf(vel.x / maxf(speed, 1.0), -1.3, 1.3)
	_lean = 0.0
	if fly:
		var ph := float(get_instance_id() % 97)
		_dy = sin(_anim * 3.0 + ph) * clampf(half.y * 0.18, 0.8, 2.0)
		_lean = clampf(vel.x / maxf(speed, 1.0), -1.0, 1.0) * 0.14
		_sq = Vector2(1.0 - sin(_anim * 17.0 + ph) * 0.04, 1.0 + sin(_anim * 17.0 + ph) * 0.06)
		return
	if not on_floor:
		_sq = Vector2(0.9, 1.12) if vel.y < -30.0 else (Vector2(1.05, 0.96) if vel.y > 120.0 else Vector2.ONE)
		_lean = run * 0.05
		return
	if absf(vel.x) > 5.0:
		_walk += absf(vel.x) * dt / maxf(half.x * 1.4, 4.0)
		_dy = -absf(sin(_walk * PI)) * clampf(half.y * 0.14, 0.6, 2.2)
		_lean = run * 0.07
	if crouch < 0.0:
		var c := -crouch
		_sq = Vector2(1.0 + c * 0.22, 1.0 - c * 0.22)
		crouch = move_toward(crouch, 0.0, dt * 4.0)
	elif crouch > 0.0:
		_sq = Vector2(1.0 + crouch * 0.18, 1.0 - crouch * 0.18)


## Alla morte (la chiama `Fauna`): il disegno si solleva e svanisce.
func fade_out() -> void:
	CreatureFx.ghost(get_parent(), _spr, position + _spr.position)


## Colpo subito: toglie Vita (meno metà della difesa), spinge via, fa lampeggiare. True se la creatura muore.
## Gironzola senza badare a nessuno (le docili non provocate, voce 55).
func _wander(dt: float) -> void:
	_wander_t -= dt
	if _wander_t <= 0.0:
		_wander_t = rng.randf_range(1.5, 4.0)
		_wander_dir = [-1.0, 0.0, 1.0][rng.randi_range(0, 2)]
	if fly:
		want_fly = Vector2(_wander_dir * speed * 0.4, sin(_anim * 1.3) * 12.0)
		return
	if on_floor and _wander_dir != 0.0 and not ground_ahead(int(_wander_dir)):
		_wander_dir = -_wander_dir
	want_x = _wander_dir * 0.5
	if _wander_dir != 0.0:
		facing = int(_wander_dir)


## Una docile colpita si arrabbia: attacca e fa danno come le altre.
func provoke() -> void:
	if docile and not provoked:
		provoked = true
		damage = _docile_dmg


## Il primo fotogramma (l'icona nelle schede dei suggerimenti).
func icon() -> Texture2D:
	return _frames[0] if not _frames.is_empty() else null


const HIT_STUN := 0.22                 # ogni colpo ferma la creatura per un attimo (lo legge anche `FightModel`)


## Il colpo che passa la difesa di una creatura (una regola sola: la usa anche `FightModel`, voce 179).
static func through(dmg: int, def: int) -> int:
	return maxi(dmg - def / 2, 1)


func take_hit(dmg: int, from_x: float, force: float) -> bool:
	provoke()
	if weak_t > 0.0:
		dmg = roundi(dmg * ElementsData.VULNERABLE)
	var real := through(dmg, defense)
	for b in behaviors:
		if b is BhScudo and (b as BhScudo).blocks(self, from_x):
			real = maxi(real / 5, 1)               # voce 130: lo scudo para davanti
			if get_parent():
				Fx.puff(get_parent(), position + Vector2(facing * half.x, 0), Color(1.6, 1.6, 1.8))
			break
	last_dmg = real
	if shell > 0.0:
		real = maxi(real / 4, 1)               # chiusa nel guscio
	elif "guscio" in data["behaviors"]:
		shell = float(p.get("shell_time", 2.5))   # si chiude dopo il primo colpo (lo tiene aperto `BhGuscio`)
	just_hit = true
	hp -= real
	_flash = 0.12
	stun = maxf(stun, HIT_STUN)             # non accorcia uno stordimento più lungo (reazioni, voce 51)
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


## Voce 127: un attacco sta per partire. Il «!» resta acceso almeno `t` secondi (`TeleMark`).
func telegraph(t: float) -> void:
	tele = maxf(tele, t)


## Voce 403: sopra un costrutto appiccicoso (cera, seta, argilla, muschio) si cammina più lenti.
func _floor_slow() -> float:
	var fx := floori(position.x / 16.0)
	var fy := floori((position.y + half.y + 2.0) / 16.0)
	if not world.inside(fx, fy):
		return 1.0
	var t: int = world.tile(fx, fy)
	if t != TileDefs.COSTRUTTO and t != TileDefs.COSTRUTTO_T:
		return 1.0
	return BuildData.slow_of(world.build[fy * world.w + fx])

