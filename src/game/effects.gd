class_name Effects
extends Node
## Gli effetti speciali (voce 85, dati in `EffectsData`): raccoglie gli effetti di ciò che si indossa e dell'arma in mano
## (campo "effects" degli oggetti) e li applica ai momenti giusti: colpi (`Combat.struck`, e `Combat.hit_mult` per le
## condizioni), creature sconfitte (`Fauna.killed`), ferite (`Vitals.wounded`), la Vita che finirebbe
## (`Vitals.death_guard`), e di continuo (condizioni, aure, effetti a tempo).

var m: Node2D
var active: Array = []                 # gli effetti attivi adesso (id), anche ripetuti se due oggetti li danno
var _hits := 0
var _t := 0.0
var _still := 0.0
var _cool := {}                        # id -> secondi prima di poter tornare
var _timed := {}                       # "corsa"/"ombra" -> [moltiplicatore, secondi che restano]
var saved := 0                         # per le prove: quante volte «Seconda radice» ha salvato


func setup(main: Node2D) -> void:
	m = main
	m.character.bisaccia.changed.connect(refresh)
	m.hud.selected.connect(func(_it: Dictionary) -> void: refresh())
	m.combat.struck.connect(_on_struck)
	m.combat.hit_mult = hit_mult
	m.fauna.killed.connect(_on_killed)
	m.vitals.wounded.connect(_on_wounded)
	m.vitals.death_guard = _guard
	refresh()


## Gli effetti degli oggetti indossati e di quello in mano.
func refresh() -> void:
	active.clear()
	var b: Bisaccia = m.character.bisaccia
	for slot in b.equip:
		active.append_array(ItemsData.get_item(String(b.equip[slot])).get("effects", []))
	var held := String(m.hud.current().get("id", ""))
	var it := ItemsData.get_item(held)
	if it.has("effects") and not String(it.get("kind", "")) in ["accessorio", "elmo", "corazza", "gambali", "guanti",
			"stivali", "mantello", "amuleto", "anello"]:
		active.append_array(it["effects"])


func has(id: String) -> bool:
	return id in active


func _cond(c: String) -> bool:
	match c:
		"vita_bassa":
			return m.vitals.hp <= m.vitals.hp_max / 3
		"notte":
			return m.day.is_night()
		"acqua":
			return m.player.in_liquid
		"fermo":
			return _still >= 1.5
		"sottoterra":
			return m.depth_watch.stratum >= 1
		"superficie":
			return m.depth_watch.stratum == 0
	return false


## Il moltiplicatore del danno dalle condizioni (lo chiede `Combat` a ogni colpo).
func hit_mult() -> float:
	var k := 1.0
	for id in active:
		var e := EffectsData.info(String(id))
		if String(e.get("when", "")) == "se" and String(e["do"]) == "danno" and _cond(String(e["cond"])):
			k *= float(e["mult"])
	return k


func _on_struck(c: Creature, dmg: int) -> void:
	_hits += 1
	for id in active:
		var e := EffectsData.info(String(id))
		var when := String(e.get("when", ""))
		if when == "colpo" and randf() < float(e.get("chance", 1.0)):
			_do(e, c, dmg)
		elif when == "ogni" and _hits % int(e["n"]) == 0:
			_do(e, c, dmg)


func _on_killed(c: Creature) -> void:
	if not m.player.position.distance_to(c.position) < 20 * 16.0:
		return                                    # solo le creature sconfitte vicino al Germogliato
	for id in active:
		var e := EffectsData.info(String(id))
		if String(e.get("when", "")) == "uccisione":
			_do(e, c, 0)


func _on_wounded(amount: int) -> void:
	for id in active:
		var e := EffectsData.info(String(id))
		if String(e.get("when", "")) != "ferita" or float(_cool.get(id, 0.0)) > 0.0:
			continue
		if e.has("sotto") and m.vitals.hp > m.vitals.hp_max * float(e["sotto"]):
			continue
		if randf() < float(e.get("chance", 1.0)):
			_do(e, null, amount)
			if e.has("cool"):
				_cool[id] = float(e["cool"])


## La Vita finirebbe: «Seconda radice» salva (una volta ogni tanto). True se ha salvato.
func _guard() -> bool:
	for id in active:
		var e := EffectsData.info(String(id))
		if String(e.get("when", "")) == "morte" and float(_cool.get(id, 0.0)) <= 0.0:
			_cool[id] = float(e.get("cool", 300.0))
			m.vitals.hp = maxi(roundi(m.vitals.hp_max * float(e["frac"])), 1)
			m.combat.invuln = maxf(m.combat.invuln, 2.0)
			Fx.float_text(m.fx, m.player.position + Vector2(0, -30), String(e["name"]) + "!", Color("#9fe070"))
			saved += 1
			return true
	return false


## Esegue un effetto. `c` = la creatura colpita (o sconfitta), `amount` = il danno del colpo (dato o ricevuto).
func _do(e: Dictionary, c: Creature, amount: int) -> void:
	match String(e["do"]):
		"brucia":
			if is_instance_valid(c):
				c.burn_t = maxf(c.burn_t, float(e["t"]))
				c.burn_dps = maxf(c.burn_dps, maxf(amount * 0.25, 1.0))
		"gela":
			if is_instance_valid(c):
				c.chill_t = maxf(c.chill_t, float(e["t"]))
		"stordisce":
			if is_instance_valid(c):
				c.stun = maxf(c.stun, float(e["t"]) / (3.0 if c.boss else 1.0))
		"schegge":
			if is_instance_valid(c):
				for k in int(e["n"]):
					var dir := Vector2.RIGHT.rotated(TAU * k / float(e["n"]) + randf() * 0.4)
					m.shots.fire(c.position + dir * 14.0, dir * 220.0, 60.0, maxi(roundi(amount * float(e["dmg"])), 1), true, 0.3)
		"catena":
			if is_instance_valid(c):
				var hit := 0
				for o in m.fauna.list.duplicate():
					if hit >= int(e["targets"]):
						break
					if o != c and is_instance_valid(o) and o.position.distance_to(c.position) < float(e["r"]) * 16.0:
						Fx.puff(m.fx, o.position, Color(1.6, 1.6, 2.4))
						hit += 1
						if o.take_hit(maxi(roundi(amount * float(e["dmg"])), 1), c.position.x, 0.4):
							m.fauna.kill(o)
		"cura":
			m.vitals.heal(maxi(roundi(amount * float(e["frac"])), 1))
		"lumini":
			if c != null:
				m.drops.spawn("lumino", int(e["n"]), c.position)
		"corsa", "ombra":
			_timed[String(e["do"])] = [float(e["mult"]), float(e["t"])]
		"riflesso":
			var best: Creature = null
			for o in m.fauna.list:
				if is_instance_valid(o) and o.position.distance_to(m.player.position) < 3 * 16.0:
					best = o
			if best != null and best.take_hit(maxi(roundi(amount * float(e["frac"])), 1), m.player.position.x, 0.5):
				m.fauna.kill(best)


func _process(dt: float) -> void:
	if not m.built:
		return
	for k in _cool.keys():
		_cool[k] = float(_cool[k]) - dt
	var p: Player = m.player
	_still = _still + dt if p.on_floor and absf(p.vel.x) < 4.0 else 0.0
	# gli effetti a tempo (corsa dopo una creatura sconfitta, ombra quando si è feriti)
	var run := 1.0
	var shadow := 1.0
	for k in _timed.keys():
		var v: Array = _timed[k]
		v[1] = float(v[1]) - dt
		if float(v[1]) <= 0.0:
			_timed.erase(k)
		elif k == "corsa":
			run *= float(v[0])
		else:
			shadow *= float(v[0])
	# le condizioni che durano
	var regen := 1.0
	var breath := 1.0
	for id in active:
		var e := EffectsData.info(String(id))
		if String(e.get("when", "")) != "se" or not _cond(String(e["cond"])):
			continue
		match String(e["do"]):
			"corsa":
				run *= float(e["mult"])
			"rigenera":
				regen *= float(e["mult"])
			"respiro":
				breath *= float(e["mult"])
	p.effect_run = run
	m.vitals.effect_regen = regen
	m.liquids.effect_breath = breath
	Behavior.effect_stealth = shadow
	# le aure, ogni mezzo secondo
	_t += dt
	if _t < 0.5:
		return
	_t = 0.0
	for id in active:
		var e := EffectsData.info(String(id))
		if String(e.get("when", "")) == "aura":
			for o in m.fauna.list:
				if is_instance_valid(o) and o.position.distance_to(p.position) < float(e["r"]) * 16.0:
					_do(e, o, 0)
