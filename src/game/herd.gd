class_name Herd
extends Node2D
## La mandria (voce 59, dati in `HerdData`): le creature addomesticate del Germogliato. Stanno nel personaggio
## (`Character.mandria`, una scheda per creatura) e lo seguono da un mondo all'altro. Come entrano nella mandria:
## `Taming`; recinti e Incubatrice: `Pens`; testi: `HerdInfo`; pannello: `HerdPanel` (tasto G).
## Una scheda ha uno stato: «segue» (fino a `FOLLOW_MAX`: combatte con te, ti aiuta con il suo dono, ha fame e va
## nutrita con clic destro), «recinto» (vive in un Recinto di questo mondo e produce), «riposo» (riposa nel Giardino e
## guarisce). Stremata in battaglia, torna a riposare. Cresce di livello combattendo, mangiando e producendo.
## Tasto R: in sella alla prima che si cavalca (i suoi bonus passano da `GearEffects`, come gli accessori).
## Le creature in scena sono `Creature` con un `BhMandria` al posto dei comportamenti selvatici (`beasts`).

const S := 16
const HEARTS := Color(1.8, 0.8, 1.1)

var m: Node2D
var beasts := {}                       # uid -> Creature in scena
var riding := -1                       # uid della creatura cavalcata (-1 = a piedi)
var _t := 1.0
var _light_t := 0.0
var _rng := RandomNumberGenerator.new()
var xp_mult := 1.0                     # Roadmap 20: il grado della mandria (`GearEffects`, chiave «herd»)
signal changed                         # la mandria è cambiata (il pannello si ridisegna)


func setup(main: Node2D) -> void:
	m = main
	z_index = 3
	_rng.randomize()


func records() -> Array:
	return m.character.mandria


func rec_of(uid: int) -> Dictionary:
	for r in records():
		if int(r["uid"]) == uid:
			return r
	return {}


static func family_of(rec: Dictionary) -> String:
	return FamiliesData.family_of(CreaturesData.base_of(String(rec["specie"])))


static func tame_data(rec: Dictionary) -> Dictionary:
	return HerdData.tame_of(family_of(rec))


func followers() -> Array:
	return records().filter(func(r: Dictionary) -> bool: return r["stato"] == "segue")


## Una scheda nuova (`how`: nutrita, laccio, uovo, allevata). `forza`: quanto era forte la creatura presa (strati
## profondi, mondi di vigore alto); `doti` sono i geni dell'allevamento (voce 60).
func new_record(specie: String, how: String, forza := 1.0, doti := {}) -> Dictionary:
	if doti.is_empty():
		doti = Breeding.wild(_rng)             # voce 60: presa in natura, doti vicine a quelle della specie
	var uid := int(m.character.stats.get("mandria_uid", 0)) + 1
	m.character.stats["mandria_uid"] = uid
	var mood := {"nutrita": 0.8, "laccio": 0.35, "uovo": 1.0, "allevata": 1.0}
	return {"uid": uid, "specie": specie, "nome": new_name(_rng), "lvl": 1, "xp": 0, "fame": 0.2,
		"felice": float(mood.get(how, 0.7)), "stato": "riposo", "mondo": "", "recinto": "", "prod": 0.0, "vita": 1.0,
		"t": Time.get_unix_time_from_system(), "forza": clampf(forza, 1.0, 4.0), "nato": how, "doti": doti}


static func new_name(rng: RandomNumberGenerator) -> String:
	var a: Array = HerdData.NAME_A
	var b: Array = HerdData.NAME_B
	return String(a[rng.randi_range(0, a.size() - 1)]) + String(b[rng.randi_range(0, b.size() - 1)])


## Una scheda entra nella mandria: segue se c'è posto, altrimenti riposa.
func add_record(rec: Dictionary) -> void:
	rec["stato"] = "segue" if followers().size() < HerdData.FOLLOW_MAX and float(rec["vita"]) >= 0.3 else "riposo"
	rec["mondo"] = ""
	rec["recinto"] = ""
	records().append(rec)
	changed_now()


func changed_now() -> void:
	changed.emit()
	m.gear.refresh()


## La creatura sotto il punto (`wild`: tra quelle selvatiche, altrimenti nella mandria).
func creature_at(pos: Vector2, wild := true) -> Creature:
	var pool: Array = m.fauna.list if wild else beasts.values()
	for c in pool:
		if is_instance_valid(c) and c.rect().grow(6.0).has_point(pos):
			return c
	return null


# ---- stati ---------------------------------------------------------------------------------------------------------

## Cambia lo stato di una scheda (dal pannello). "" se è andata, altrimenti il perché.
func set_state(rec: Dictionary, stato: String) -> String:
	match stato:
		"segue":
			if followers().size() >= HerdData.FOLLOW_MAX:
				return "Ti seguono già in %d" % HerdData.FOLLOW_MAX
			if float(rec["vita"]) < 0.3:
				return "%s è ancora stremata: lasciala riposare" % rec["nome"]
		"guardia":
			# voce 148: di guardia alla sua cuccia (in questo mondo): difende la casa, anche durante le maree
			var cu := free_kennel(m.player.position)
			if cu.x < 0:
				return "Serve una Cuccia libera qui vicino (al Ceppo)"
			if float(rec["vita"]) < 0.3:
				return "%s è ancora stremata: lasciala riposare" % rec["nome"]
			rec["cuccia"] = "%d,%d" % [cu.x, cu.y]
			rec["mondo"] = m.world_id
		"recinto":
			var k: String = m.pens.free_pen(m.player.position)
			if k == "":
				return "Nessun recinto con posto in questo mondo (Recinto di radici, al Ceppo)"
			rec["recinto"] = k
			rec["mondo"] = m.world_id
			rec["t"] = Time.get_unix_time_from_system()
	if int(rec["uid"]) == riding:
		ride(false)
	rec["stato"] = stato
	if stato != "recinto":
		rec["recinto"] = ""
	if stato != "guardia":
		rec.erase("cuccia")
	if stato != "recinto" and stato != "guardia":
		rec["mondo"] = ""
	despawn(int(rec["uid"]))
	changed_now()
	return ""


## Voce 148: la cuccia di una scheda di guardia (se c'è ancora), o (-1, -1).
func kennel_of(rec: Dictionary) -> Vector2i:
	var parts := String(rec.get("cuccia", "")).split(",")
	if parts.size() != 2:
		return Vector2i(-1, -1)
	var o := Vector2i(int(parts[0]), int(parts[1]))
	return o if String(m.world.stations.get(o, "")) == "cuccia" else Vector2i(-1, -1)


## Una cuccia libera entro 40 tessere da un punto.
func free_kennel(near: Vector2) -> Vector2i:
	var taken := []
	for r in records():
		if String(r["stato"]) == "guardia":
			taken.append(kennel_of(r))
	for o in m.world.stations:
		if String(m.world.stations[o]) == "cuccia" and not o in taken and (Vector2(o) * S).distance_to(near) < 40.0 * S:
			return o
	return Vector2i(-1, -1)


## Liberare: la creatura torna selvatica, per sempre.
func free_record(rec: Dictionary) -> void:
	var uid := int(rec["uid"])
	if uid == riding:
		ride(false)
	var pos: Vector2 = beasts[uid].position if beasts.has(uid) else m.player.position
	despawn(uid)
	unpair(rec)
	records().erase(rec)
	var c: Creature = m.fauna.add(String(rec["specie"]), pos)
	c.docile = true
	c.damage = 0
	Fx.puff(m.fx, pos, Color(1.0, 1.4, 1.2))
	m.hud.toast("%s torna libera" % rec["nome"])
	changed_now()


## Voce 60: due creature della stessa famiglia in coppia (fanno uova nello stesso recinto). "" se è andata.
func pair(a: Dictionary, b: Dictionary) -> String:
	var why := Breeding.can_pair(a, b)
	if why != "":
		return why
	unpair(a)
	unpair(b)
	a["coppia"] = int(b["uid"])
	b["coppia"] = int(a["uid"])
	m.objectives.bump("coppie")
	changed_now()
	return ""


func unpair(a: Dictionary) -> void:
	var other := rec_of(int(a.get("coppia", -1)))
	if not other.is_empty():
		other.erase("coppia")
	a.erase("coppia")
	a.erase("amore")


## Stremata: si ritira a riposare nel Giardino e guarisce piano.
func faint(rec: Dictionary) -> void:
	rec["vita"] = 0.0
	var uid := int(rec["uid"])
	if uid == riding:
		ride(false)
	if beasts.has(uid):
		Fx.puff(m.fx, (beasts[uid] as Creature).position, Color(1.2, 1.2, 1.2))
	rec["stato"] = "riposo"
	despawn(uid)
	m.hud.toast("%s è stremata e torna a riposare nel Giardino (G)" % rec["nome"])
	changed_now()


# ---- valori e crescita ---------------------------------------------------------------------------------------------

## Vita e danno di una creatura della mandria (livello, forza di quando è stata presa, doti dell'allevamento).
static func stats_of(rec: Dictionary) -> Dictionary:
	var d := CreaturesData.get_data(String(rec["specie"]))
	var lvl := int(rec["lvl"])
	var f := float(rec.get("forza", 1.0))
	var g: Dictionary = rec.get("doti", {})
	var hp := roundi(int(d["hp"]) * f * (1.0 + 0.1 * (lvl - 1)) * Breeding.mult(g, "vita"))
	var dmg := roundi(maxi(int(d["damage"]), 3) * f * (1.0 + HerdData.LVL_DAMAGE * (lvl - 1)) * Breeding.mult(g, "danno"))
	return {"hp": maxi(hp, 1), "damage": dmg}


## Il danno di adesso: di più se è contenta, di meno se ha fame.
static func damage_now(rec: Dictionary) -> int:
	var dmg := float(stats_of(rec)["damage"]) * (0.75 + 0.5 * float(rec["felice"]))
	if float(rec["fame"]) >= 1.0:
		dmg *= 0.7
	return maxi(roundi(dmg), 1)


## Combatte? Tutte tranne gli erbivori gentili che non si cavalcano.
static func fights(rec: Dictionary) -> bool:
	var fd: Dictionary = FamiliesData.FAMILIES.get(family_of(rec), {})
	return String(fd.get("role", "")) != "erbivoro" or tame_data(rec).has("mount")


## Una creatura abbattuta da una della mandria: esperienza.
func credit(rec: Dictionary, foe: Creature) -> void:
	gain_xp(rec, maxi(2, foe.hp_max / 8))
	m.objectives.bump("mandria_prede")


func gain_xp(rec: Dictionary, n: int, quiet := false) -> void:
	rec["xp"] = int(rec["xp"]) + maxi(n, roundi(n * xp_mult))     # Roadmap 20: il grado della mandria
	while int(rec["lvl"]) < HerdData.LVL_MAX and int(rec["xp"]) >= HerdData.xp_for(int(rec["lvl"])):
		rec["xp"] = int(rec["xp"]) - HerdData.xp_for(int(rec["lvl"]))
		rec["lvl"] = int(rec["lvl"]) + 1
		if not quiet:
			m.hud.toast("%s sale al livello %d" % [rec["nome"], int(rec["lvl"])])
		if beasts.has(int(rec["uid"])):
			_apply_stats(beasts[int(rec["uid"])], rec)
	if int(rec["lvl"]) >= HerdData.LVL_MAX:
		rec["xp"] = mini(int(rec["xp"]), HerdData.xp_for(HerdData.LVL_MAX))


## I doni di chi ti segue e di chi cavalchi, per `GearEffects` (gruppi di effetti come quelli degli accessori).
func bonuses() -> Array:
	var out := []
	for r in followers():
		var aid: Dictionary = tame_data(r).get("aid", {}).duplicate()
		aid.erase("light")
		out.append(aid)
	var rr := rec_of(riding)
	if not rr.is_empty():
		var mt: Dictionary = tame_data(rr).get("mount", {}).duplicate()
		var lv := 1.0 + 0.02 * (int(rr["lvl"]) - 1)          # più è cresciuta, più corre
		for k in mt:
			if mt[k] is float:
				mt[k] = 1.0 + (float(mt[k]) - 1.0) * lv
		out.append(mt)
	return out


# ---- in sella ------------------------------------------------------------------------------------------------------

## In sella alla prima creatura che ti segue e si cavalca (`on`), o giù di sella.
func ride(on: bool) -> bool:
	if not on:
		if riding >= 0:
			var c: Creature = beasts.get(riding)
			riding = -1
			if c != null:
				c.tame.mode = "segue"
				c.position = m.player.position + Vector2(-16.0 * m.player.facing, 0)
			m.player.rig.position.y = 0.0
			changed_now()
		return true
	for r in followers():
		if tame_data(r).has("mount") and beasts.has(int(r["uid"])):
			riding = int(r["uid"])
			var c: Creature = beasts[riding]
			c.tame.mode = "cavalcata"
			m.player.rig.position.y = -roundf(c.half.y * 1.6)
			Fx.puff(m.fx, c.position, Color(1.2, 1.3, 1.0))
			m.objectives.bump("cavalcate")
			m.hud.toast("In sella a %s (R per scendere)" % r["nome"])
			changed_now()
			return true
	m.hud.toast("Nessuna creatura che ti segue si lascia cavalcare (cornoradici, cervi, linci, salamandre, talponi)")
	return false


func _unhandled_input(e: InputEvent) -> void:
	if Keys.pressed(e, "cavalca") and not m.hud.is_open():
		ride(riding < 0)
		get_viewport().set_input_as_handled()


# ---- in scena ------------------------------------------------------------------------------------------------------

## La creatura della scheda in scena (se non c'è già), nel modo dato ("" = nessuna).
func spawn(rec: Dictionary, mode: String) -> Creature:
	if mode == "":
		return null
	var uid := int(rec["uid"])
	if beasts.has(uid):
		return beasts[uid]
	var c := Creature.new()
	c.setup(String(rec["specie"]), m.world, m.player, uid, Breeding.mods(rec.get("doti", {})))
	c.behaviors.clear()
	c.docile = false
	var bh := BhMandria.new()
	bh.herd = self
	bh.rec = rec
	bh.mode = mode
	c.tame = bh
	_apply_stats(c, rec)
	c.position = m.player.position + Vector2(-20.0 * m.player.facing, -6.0)
	add_child(c)
	# un segno per riconoscerla: una fogliolina turchese sopra la testa (come i compagni)
	var leaf := Sprite2D.new()
	var li := Image.create_empty(3, 2, false, Image.FORMAT_RGBA8)
	li.fill(Color("#72d4b0"))
	leaf.texture = ImageTexture.create_from_image(li)
	leaf.position = Vector2(0, -c.half.y - 5)
	c.add_child(leaf)
	beasts[uid] = c
	return c


func _apply_stats(c: Creature, rec: Dictionary) -> void:
	var st := stats_of(rec)
	c.hp_max = int(st["hp"])
	c.hp = maxi(1, roundi(c.hp_max * clampf(float(rec["vita"]), 0.05, 1.0)))
	c.damage = 0                           # non ferisce il Germogliato: i suoi colpi li dà `BhMandria`
	c._bar.set_value(float(c.hp) / float(c.hp_max))


func despawn(uid: int) -> void:
	if beasts.has(uid):
		var c: Creature = beasts[uid]
		beasts.erase(uid)
		if is_instance_valid(c):
			c.queue_free()


func _process(dt: float) -> void:
	if not m.built:
		return
	# chi deve stare in scena, e in che modo
	var slot := 0
	for r in records():
		var uid := int(r["uid"])
		var mode := ""
		if r["stato"] == "segue" and not m.life.dead:
			mode = "cavalcata" if uid == riding else "segue"
		elif r["stato"] == "recinto" and m.pens.shows(r):
			mode = "recinto"
		elif r["stato"] == "guardia" and String(r.get("mondo", "")) == m.world_id and kennel_of(r).x >= 0:
			mode = "guardia"                               # voce 148
		if mode == "":
			despawn(uid)
			continue
		var fresh := not beasts.has(uid)
		var c := spawn(r, mode)
		if mode == "recinto" and (fresh or c.tame.mode != "recinto"):
			c.position = m.pens.spawn_pos(r)
		c.tame.mode = mode
		if mode == "recinto":
			c.tame.home = m.pens.range_of(r)
		elif mode == "guardia":
			var cu := kennel_of(r)
			if fresh:
				c.position = (Vector2(cu) + Vector2(1.0, 0.0)) * S
			c.tame.home = (Vector2(cu) + Vector2(1.0, 0.5)) * S
		elif mode == "segue":
			c.tame.slot = slot
			slot += 1
			r["vita"] = float(c.hp) / float(c.hp_max)
	for uid in beasts.keys():
		if rec_of(int(uid)).is_empty():
			despawn(int(uid))
	if riding >= 0 and (not beasts.has(riding) or m.life.dead):
		ride(false)
	_lights(dt)
	_t -= dt
	if _t > 0.0:
		return
	_t = 1.0
	# fame e umore di chi segue, riposo di chi è a casa (i recinti li fa `Pens`)
	for r in records():
		match String(r["stato"]):
			"segue":
				r["fame"] = minf(float(r["fame"]) + HerdData.HUNGER_RATE, 1.0)
				r["felice"] = move_toward(float(r["felice"]), 1.0 if float(r["fame"]) < 0.8 else 0.2, 1.0 / 600.0)
				var c: Creature = beasts.get(int(r["uid"]))
				if c != null and c.hp < c.hp_max:
					c.hp = mini(c.hp + maxi(1, c.hp_max / 60), c.hp_max)      # guarisce piano anche seguendoti
					c._bar.set_value(float(c.hp) / float(c.hp_max))
			"riposo", "guardia":
				r["vita"] = minf(float(r["vita"]) + 1.0 / HerdData.REST_HEAL, 1.0)
				r["fame"] = move_toward(float(r["fame"]), 0.3, 0.01)
				r["felice"] = move_toward(float(r["felice"]), 0.7, 1.0 / 600.0)


## Chi ha il dono della luce la fa attorno a sé.
func _lights(dt: float) -> void:
	_light_t -= dt
	if _light_t > 0.0:
		return
	_light_t = 0.15
	var ls := []
	for uid in beasts:
		var c: Creature = beasts[uid]
		var aid: Dictionary = tame_data(c.tame.rec).get("aid", {})
		if aid.has("light"):
			ls.append([Vector2i(floori(c.position.x / S), floori(c.position.y / S)), aid["light"]])
	m.light.set_extra("mandria", ls)
