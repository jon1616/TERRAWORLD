class_name Combat
extends Node
## Il combattimento: colpi in mischia a ogni giro dell'attrezzo in mano (danno, velocità e spinta dall'oggetto), l'arco
## che tira dardi verso il mouse consumandoli dalla Bisaccia, le ferite del Germogliato (contatto con le creature e
## spore) con qualche istante di invulnerabilità, la spinta indietro e il lampeggio.

const MELEE_REACH := Vector2(26, 34)   # area del colpo davanti al Germogliato
const INVULN := 0.7                    # secondi senza ferite dopo un colpo subito
const DART_SPEED := 380.0
const DART_GRAV := 260.0
const DIG_PERIOD := 0.3
## Voce 185 (Roadmap 18): piccone e ascia colpiscono le creature a metà (facevano l'85% della spada dello stesso metallo:
## un attrezzo non deve fare da arma).
const TOOL_HIT := 0.5                # il gesto di piccone e ascia
## L'arco usa i dardi migliori che ci sono. (Voce 351, 4 ott 2026) L'elenco nasce dai dati: tutti gli oggetti di tipo
## «munizione», dal danno più alto. Prima era scritto a mano con cinque dardi, e i sei dardi dei biomi e del cielo
## (gelo, folgore, prisma, nubi, falco, stella) si fabbricavano ma l'arco non li tirava mai.
static var AMMO: Array = _ammo_list()


static func _ammo_list() -> Array:
	var all: Dictionary = ItemsData.all()
	var out := []
	for id in all:
		if String(all[id].get("kind", "")) == "munizione":
			out.append(String(id))
	out.sort_custom(func(a: String, b: String) -> bool:
		var da := int(all[a].get("damage", 0))
		var db := int(all[b].get("damage", 0))
		return da > db if da != db else a < b)
	return out

signal struck(c: Creature, dmg: int)        # voce 85: un colpo andato a segno (gli effetti)
var m: Node2D                          # la scena di gioco
var player: Player
var fauna: Fauna
var shots: Projectiles
var vitals: Vitals
var bisaccia: Bisaccia
var invuln := 0.0
var _hit_set := {}                     # creature già colpite in questo giro dell'arma
var _cycle := -1
var _bow_t := 0.0
var auto_aim := Vector2.INF            # per le prove: punto verso cui tirare senza mouse
var auto_fire := false
var god := false
var _alt := 0                          # voce 52: l'elemento del prossimo colpo di una lega con due elementi
var dmg_mult := 1.0                    # accessori: danno × (vedi `GearEffects`)
var hit_mult: Callable                 # voce 85: () -> moltiplicatore delle condizioni (`Effects.hit_mult`)
var spd_mult := 1.0                    # accessori: colpi più rapidi
var magic_mult := 1.0                  # vesti di seta: incantesimi più forti
var style_mult := 1.0                  # voce 389: l'elmo e il set dello stile dell'arma in mano (`GearEffects`)
var ally_mult := 1.0                   # voce 389: gli alleati degli scettri (Maschera del branco)
var boon_thorns := 0                   # Pozione di spine
var thorns := 0                        # tratto Spine dell'equipaggiamento: danno a chi ti tocca                       # per le prove: il Germogliato non si ferisce


func setup(main: Node2D) -> void:
	m = main
	player = m.player
	fauna = m.fauna
	shots = m.shots
	vitals = m.vitals
	bisaccia = m.character.bisaccia


## Il colpo di un proiettile: i dardi prendono le creature, le spore il Germogliato.
func on_shot(s: Dictionary) -> bool:
	var pos: Vector2 = (s["node"] as Node2D).position
	if int(s.get("ally", -1)) >= 0:
		return m.herd.fight.shot(s, pos)        # Roadmap 32: il colpo di un compagno
	if not s["player"] and m.herd.fight.shot_hits_ally(s, pos):
		return true                             # un colpo selvatico preso da un compagno
	if s["player"]:
		var hits: Dictionary = s["hits"]
		for c in fauna.list.duplicate():
			if not hits.has(c) and c.rect().grow(2.0).has_point(pos):
				hits[c] = true
				if float(s["chill"]) > 0.0:
					c.chill_t = maxf(c.chill_t, float(s["chill"]))   # onda di lagunite: rallenta
				_strike(c, int(s["damage"]), pos.x - signf(s["vel"].x) * 10.0, float(s["knock"]), String(s.get("elem", "")))
				_gesture_hit(s, c, pos)                    # voce 356: si divide, scoppia
				if String(s.get("style", "")) != "" and m.get("styles") != null:
					m.styles.note_hit(String(s["style"]), c, int(s["damage"]))   # voce 367: Ispirazione, Rugiada
				if int(s["pierce"]) <= 0:
					return true
				s["pierce"] = int(s["pierce"]) - 1
				return false
		return false
	if Rect2(player.position - Player.HALF, Player.HALF * 2.0).has_point(pos):
		if float(s.get("slow", 0.0)) > 0.0 and not god:
			if player.slow_t <= 0.0:
				m.hud.toast("Invischiato nella ragnatela!")
			player.slow_t = maxf(player.slow_t, float(s["slow"]))
		hurt_player(int(s["damage"]), pos.x, "un proiettile")
		return true
	return false


var shards_made := 0                    # voce 356: schegge nate dai colpi che si dividono (per le prove)
var _last_dmg := 0                      # voce 367: il danno dell'ultimo giro (la scossa dello Slancio)


## Voce 356: i moduli di un colpo che ha preso una creatura (`GesturesData`): le schegge e lo scoppio attorno.
func _gesture_hit(s: Dictionary, c: Creature, pos: Vector2) -> void:
	var sp: Array = s.get("split", [])
	if sp.size() == 2:
		var v: Vector2 = s["vel"]
		var n := int(sp[0])
		shards_made += n
		for k in n:
			var dir := v.normalized().rotated((k - (n - 1) / 2.0) * 0.6 + PI * 0.15 * (1 if k % 2 else -1))
			shots.fire(pos + dir * 10.0, dir * maxf(v.length() * 0.8, 200.0), 0.0, maxi(roundi(int(s["damage"]) * float(sp[1])), 1),
				true, 0.4, {"look": "scheggia", "elem": String(s.get("elem", ""))})
	var bm: Array = s.get("boom", [])
	if bm.size() == 2:
		Fx.puff(m.fx, pos, Color(1.8, 1.3, 0.7))
		for o in fauna.list.duplicate():
			if o != c and is_instance_valid(o) and o.position.distance_to(pos) < float(bm[0]) * 16.0:
				_strike(o, maxi(roundi(int(s["damage"]) * float(bm[1])), 1), pos.x, 0.6, String(s.get("elem", "")))


## Voce 356: le opzioni di un colpo con i moduli del materiale dell'arma (pierce e homing si sommano, gli altri si
## aggiungono). Restituisce [opzioni, moltiplicatore della velocità].
static func gesture_opts(opts: Dictionary, mat: String, extra: Dictionary = {}) -> Array:
	var mods: Dictionary = GesturesData.of_mat(mat).get("mods", {})
	if not extra.is_empty():
		mods = GesturesData.merge_mods(mods, extra)     # voce 370: i moduli propri di un'arma firma
	var out := opts.duplicate()
	for k in mods:
		match String(k):
			"pierce":
				out["pierce"] = int(out.get("pierce", 0)) + int(mods[k])
			"homing":
				out["homing"] = maxf(float(out.get("homing", 0.0)), float(mods[k]))
			"speed":
				pass
			_:
				out[k] = mods[k]
	return [out, float(mods.get("speed", 1.0))]


func _process(dt: float) -> void:
	invuln = maxf(invuln - dt, 0.0)
	player.visible = invuln <= 0.0 or int(invuln * 16.0) % 2 == 0
	if not m.built:
		return
	_contact()
	var item: Dictionary = m.hud.current()
	var it := ItemsData.get_item(item["id"])
	var use: String = item["use"]
	var active: bool = m.actions.enabled and not m.hud.is_open()
	# il ritmo del gesto: le armi secondo la loro velocità, gli attrezzi da scavo sempre uguali
	var tr := String(item.get("tratto", ""))
	var st := Gear.stats(item)                  # voce 50: forma, materiale, tratto e fascia
	var spd := float(st["speed"]) * spd_mult
	player.swing_period = 1.0 / spd if use == "colpo" and spd > 0.0 else DIG_PERIOD
	_melee(st, use, tr)
	_bow(it, st, use, active, dt, tr)


## Colpi in mischia: ogni giro dell'attrezzo colpisce una volta ogni creatura nell'area del colpo (voce 50: l'area
## dipende dalla forma, `FormsData.AREA`: la lancia e la frusta lontano in linea, la falce anche dietro).
func _melee(st: Dictionary, use: String, tr := "") -> void:
	var sw: bool = player.swinging or player.force_swing
	var dmg := roundi(float(st["damage"]) * _boon() * (1.0 if use == "colpo" else TOOL_HIT))
	if not sw or dmg <= 0 or not use in ["colpo", "scava", "abbatti"]:
		_cycle = -1
		return
	var cyc := int(player.swing_t / player.swing_period)
	if cyc != _cycle:
		# voce 367: lo Slancio della mischia (il giro appena finito ha colpito qualcosa?)
		if _cycle >= 0 and use == "colpo" and m.get("styles") != null:
			m.styles.melee_cycle(not _hit_set.is_empty(), _last_dmg)
		_cycle = cyc
		_hit_set.clear()
		if use == "colpo":
			m.sfx.play("colpo")
			Mind.noise(player.position, Senses.SWING_NOISE)   # voce 129: i colpi si sentono
	var ph := fmod(player.swing_t, player.swing_period) / player.swing_period
	if ph < 0.15:
		return                             # l'attrezzo è ancora alzato
	var area := melee_area(String(st["form"]) if use == "colpo" else "")
	if use == "colpo" and m.get("styles") != null:
		dmg = roundi(dmg * float(m.styles.melee_mult()))      # voce 367: lo Slancio pieno
	_last_dmg = dmg
	for c in fauna.list.duplicate():
		if not _hit_set.has(c) and area.intersects(c.rect()):
			_hit_set[c] = true
			_strike(c, dmg, player.position.x, float(st["knockback"]) / 3.0, String(st["elem"]))


## L'area del colpo in mischia di una forma, attorno al Germogliato.
func melee_area(form: String) -> Rect2:
	var a: Array = FormsData.AREA.get(form, [MELEE_REACH.x, MELEE_REACH.y, 6, false])
	var size := Vector2(float(a[0]), float(a[1]))
	var top := 12.0 - size.y                     # il fondo dell'area resta all'altezza dei piedi
	if bool(a[3]):
		return Rect2(player.position + Vector2(-size.x * 0.5, top), size)       # davanti e dietro
	var x := player.position.x + (float(a[2]) if player.facing > 0 else -float(a[2]) - size.x)
	return Rect2(Vector2(x, player.position.y + top), size)


## Arco: tenendo premuto tira un dardo a ogni giro (secondo la velocità dell'arco), finché ci sono dardi.
func _bow(it: Dictionary, st: Dictionary, use: String, active: bool, dt: float, tr := "") -> void:
	_bow_t = maxf(_bow_t - dt, 0.0)
	var aiming := use == "tira" and (auto_fire or (active and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)))
	if not aiming:
		player.aim = NAN
		return
	var target: Vector2 = auto_aim if auto_aim != Vector2.INF else m.fx.get_global_mouse_position()
	var from := player.position + Vector2(0, -6)
	var d := target - from
	player.facing = 1 if d.x >= 0.0 else -1
	player.aim = atan2(absf(d.x), d.y)
	if _bow_t > 0.0:
		return
	var ammo := ""
	var want := String(it.get("ammo", "dardo"))           # voce 368: dardi, sassi o spore secondo l'arma
	for a in AMMO:
		if String(ItemsData.get_item(a).get("ammo", "dardo")) == want and bisaccia.count(a) > 0:
			ammo = a
			break
	if ammo == "":
		m.hud.toast({"dardo": "Niente dardi", "sasso": "Niente sassi da fionda", "spora": "Niente spore da soffiare"}.get(want, "Niente munizioni"))
		_bow_t = 1.0
		return
	_bow_t = 1.0 / (maxf(float(st["speed"]), 0.1) * spd_mult)
	bisaccia.remove(ammo, 1)
	m.sfx.play("tira")
	# voce 372: la munizione conta un poco da sola e un poco con l'arma (`AmmoData.K`), e porta il suo modo
	var ad := float(ItemsData.get_item(ammo).get("damage", 0))
	var dmg := roundi((float(st["damage"]) * (1.0 + ad * AmmoData.K) + ad) * _boon())
	# un po' di anticipo sulla caduta, così il dardo va dove si mira anche lontano
	var flight := d.length() / DART_SPEED
	var v := d.normalized() * DART_SPEED
	var dg := DART_GRAV * Creature.grav           # voce 76: in un mondo leggero il dardo cade meno
	v.y -= 0.5 * dg * minf(flight, 0.8)
	var n := int(it.get("multishot", 1))       # l'Arco iridato (e il Lanciaspore) tira più colpi a ventaglio con uno solo
	var go := gesture_opts({"pierce": int(st["pierce"]), "elem": String(st["elem"])}, String(st["mat"]), it.get("mods", {}))   # voce 356
	var am: Dictionary = AmmoData.MODS.get(ammo, {})
	if not am.is_empty():
		var pure := am.duplicate()
		for k in ["elem", "chill", "speed"]:
			pure.erase(k)
		var mo := GesturesData.merge_mods(go[0], pure)
		if am.has("elem") and String(st["elem"]) == "":
			mo["elem"] = am["elem"]
		elif String(st["elem"]) != "":
			mo["elem"] = String(st["elem"])
		if am.has("chill"):
			mo["chill"] = float(am["chill"])
		go = [mo, float(go[1]) * float(am.get("speed", 1.0))]
	if want != "dardo":
		(go[0] as Dictionary)["look"] = "scheggia" if want == "sasso" else "spora_amica"
	for k in n:
		shots.fire(from + d.normalized() * 8.0, v.rotated((k - (n - 1) / 2.0) * 0.12) * float(go[1]), dg, dmg, true,
				float(st["knockback"]) / 3.0, go[0])


## Danno ×1,2 con la Pozione di vigore attiva, e il danno in più degli accessori.
func _boon() -> float:
	return (Boons.VIGORE if m.boons.active.has("vigore") else 1.0) * dmg_mult * (Boons.SAZIO if m.boons.active.has("sazio") else 1.0) \
		* (m.arts.mult_now() if m.get("arts") != null else 1.0) \
		* (m.styles.dmg_now() if m.get("styles") != null else 1.0) \
		* style_mult                                                    # voce 389: elmi e set degli stili


func _strike(c: Creature, dmg: int, from_x: float, force: float, elem := "") -> void:
	m.sfx.play("colpito", c.position)
	# voce 334: il colpo fa un lampo breve (del colore dell'elemento); voce 335: lo schizzo
	var gl := Projectiles.glow_of(elem)
	m.light.pulse(Vector2i(floori(c.position.x / 16.0), floori(c.position.y / 16.0)),
		gl * 0.7 if gl != Color.BLACK else Color(0.9, 0.75, 0.55), 0.1)
	ImpactFx.hit(m.fx, c.position, elem)
	if hit_mult.is_valid():
		dmg = maxi(roundi(dmg * float(hit_mult.call())), 1)
	dmg = maxi(roundi(dmg * fauna._zm(c.position, "guardia")), 1)   # voce 87: lo Stendardo di guardia
	if m.rooms:
		dmg = maxi(roundi(dmg * m.rooms.trophy_vs(c)), 1)              # voce 142: la sala dei trofei (voce 401: anche i boss)
	if m.study:
		dmg = maxi(roundi(dmg * m.study.mult(c.base)), 1)              # voce 138: le specie studiate
	if m.get("banners") != null:
		dmg = maxi(roundi(dmg * m.banners.mult(c.family)), 1)          # voce 381: lo stendardo della famiglia
	if elem.contains("+"):
		# una lega con due elementi (voce 52): uno per colpo, alternati
		_alt += 1
		elem = elem.get_slice("+", _alt % 2)
	if elem != "":
		dmg = Elements.hit(self, c, elem, dmg)     # voce 51: debolezze, stati e reazioni
		if not is_instance_valid(c) or not fauna.list.has(c):
			return
	var held: Dictionary = m.hud.current()
	if Gear.effect(held, "poison") > 0.0 or ItemsData.get_item(String(held["id"])).get("poison", false):
		c.poison_t = 4.0
	# creatura Spinosa: colpirla da vicino ferisce anche il Germogliato
	if c.ancient and c.ancient.has("spinosa") and player.position.distance_to(c.position) < 48.0:
		_self_hurt(maxi(int(dmg * c.ancient.value("thorns")), 1))
	struck.emit(c, dmg)
	if not is_instance_valid(c) or not fauna.list.has(c):
		return
	if c.take_hit(dmg, from_x, maxf(force, 0.3)):
		var burst := Gear.effect(held, "burst")
		fauna.kill(c)
		if burst > 0.0:
			# tratto Scoppio: la creatura abbattuta ferisce quelle vicine
			Fx.puff(m.fx, c.position, Color(2.0, 1.2, 0.6))
			for o in fauna.list.duplicate():
				if o.position.distance_to(c.position) < 48.0 and o.take_hit(int(dmg * burst), c.position.x, 0.5):
					fauna.kill(o)


## Ferita piccola che non dà invulnerabilità (spine, scoppi): numero rosso e basta.
func _self_hurt(dmg: int) -> void:
	if god or m.life.dead:
		return
	var lost := vitals.hurt(dmg)
	Fx.float_text(m.fx, player.position + Vector2(0, -20), "-%d" % lost, Color("#ff9a7a"))


## Una creatura Esplosiva muore: scoppia, e se il Germogliato è vicino si ferisce.
func on_killed(c: Creature) -> void:
	if c.ancient and c.ancient.has("esplosiva"):
		Fx.puff(m.fx, c.position, Color(2.4, 1.2, 0.5))
		m.sfx.play("rompi", c.position)
		if player.position.distance_to(c.position) < 3.5 * 16.0:
			hurt_player(int(c.ancient.value("explode")), c.position.x, "uno scoppio")


## Le creature che toccano il Germogliato lo feriscono.
func _contact() -> void:
	if invuln > 0.0 or m.life.dead:
		return
	var pr := Rect2(player.position - Player.HALF, Player.HALF * 2.0).grow(-1.0)
	for c in fauna.list:
		if c.damage > 0 and pr.intersects(c.rect().grow(-1.0)):
			var gk: float = m.banners.guard(c.family) if m.get("banners") != null else 1.0   # voce 381
			hurt_player(maxi(roundi(c.damage * gk), 1), c.position.x, String(c.data.get("name", "una creatura")))
			if c.ancient and c.ancient.has("velenosa"):
				vitals.poison_t = maxf(vitals.poison_t, c.ancient.value("poison"))
				m.hud.toast("Avvelenato!")
			# tratto Spine dell'equipaggiamento: chi tocca il Germogliato si ferisce
			if thorns + boon_thorns > 0 and c.take_hit(thorns + boon_thorns, player.position.x, 0.4):
				fauna.kill(c)
			return


## Ferita del Germogliato da una creatura o da un colpo: meno Vita, spinta indietro, lampeggio, numero rosso.
func hurt_player(dmg: int, from_x: float, why := "una creatura") -> void:
	if invuln > 0.0 or m.life.dead or god:
		return
	invuln = INVULN
	m.sfx.play("ferita")
	var lost := vitals.hurt(dmg, why)
	var dir := signf(player.position.x - from_x)
	if dir == 0.0:
		dir = -float(player.facing)
	player.vel = Vector2(dir * 170.0, -170.0)
	player.on_floor = false
	player.facing = int(-dir)                   # guarda chi l'ha colpito: la posa della ferita scatta all'indietro
	player.hurt_t = HeroSprites.HURT_TIME
	Fx.float_text(m.fx, player.position + Vector2(0, -20), "-%d" % lost, Color("#ff7a5a"))
	m.life.flash(Color(1.0, 0.25, 0.2, 0.18), 0.25)
