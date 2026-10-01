class_name BondFight
extends RefCounted
## Il combattimento dei compagni (Roadmap 32, voce 310; dati in `BondsData`). Un compagno è una `Creature` della
## mandria (`Herd.beasts`) che usa i comportamenti della sua specie contro le creature nemiche (`BhMandria._fight`):
## qui ciò che quei comportamenti chiedono diventa colpi veri dalla parte del Germogliato.
##   - il contatto ferisce il nemico (una volta ogni `HIT_EVERY` secondi per nemico), con l'elemento della variante;
##   - gli spari diventano colpi amici (`Projectiles.fire` con "ally" = uid della scheda: li smista `Combat.on_shot`);
##   - lo scoppio ferisce le creature attorno (il compagno non muore, lo rifà dopo un po'), il fulmine cade sui nemici;
##   - le creature selvatiche lo vedono: chi è stata colpita da lui, o gli è molto più vicina che al Germogliato, lo
##     prende di mira (`retarget`), e i loro colpi e il loro contatto lo feriscono (`hurt`, `shot_hits_ally`).

var herd: Node2D                       # il modulo `Herd`
var m: Node2D
var _cd := {}                          # "uid:id del nemico" -> millisecondi in cui può colpirlo di nuovo
var _clean := 0


func _init(h: Node2D) -> void:
	herd = h
	m = h.m


## Le creature in scena che combattono (che seguono o fanno la guardia).
func fighters() -> Array:
	var out := []
	for uid in herd.beasts:
		var c: Creature = herd.beasts[uid]
		if is_instance_valid(c) and c.tame != null and (c.tame.mode == "segue" or c.tame.mode == "guardia"):
			out.append(c)
	return out


## Il contatto: il compagno ferisce il nemico che sta combattendo e ogni creatura ostile che tocca.
func contact(c: Creature, rec: Dictionary) -> void:
	var now := Time.get_ticks_msec()
	var foe = c.tame.foe                   # (può essere già liberata: senza tipo)
	for o in m.fauna.list.duplicate():
		if o.calm or o.buried or (o != foe and o.damage <= 0):
			continue
		if not c.rect().grow(3.0).intersects(o.rect()):
			continue
		var k := "%d:%d" % [int(rec["uid"]), o.get_instance_id()]
		if int(_cd.get(k, 0)) > now:
			continue
		_cd[k] = now + int(BondsData.HIT_EVERY * 1000.0)
		strike(c, rec, o, herd.damage_now(rec), c.position.x, "")
	_clean += 1
	if _clean > 600:
		_clean = 0
		for k in _cd.keys():
			if int(_cd[k]) < now:
				_cd.erase(k)


## Un colpo del compagno a una creatura: l'elemento della sua variante, la creatura lo prende di mira, l'esperienza.
func strike(c: Creature, rec: Dictionary, o: Creature, dmg: int, from_x: float, elem: String) -> void:
	if elem == "" and c != null:
		elem = String(FamiliesData.parts(c.id)[2])
	if elem != "":
		dmg = Elements.hit(m.combat, o, elem, dmg)
		if not is_instance_valid(o) or not m.fauna.list.has(o):
			return
	o.set_meta("bond_aggro", Time.get_ticks_msec())
	m.sfx.play("colpito", o.position)
	if o.take_hit(maxi(dmg, 1), from_x, 0.6):
		if not rec.is_empty():
			herd.credit(rec, o)
		m.fauna.kill(o)


## Ciò che i comportamenti del compagno hanno chiesto in questo passo: spari, scoppi, fulmini. Il resto (rinforzi,
## ragnatele, furti) un compagno non lo fa.
func collect(c: Creature, rec: Dictionary) -> void:
	var dmg: int = herd.damage_now(rec)
	var base := maxf(float(CreaturesData.get_data(c.id).get("damage", 1)), 1.0)
	var elem := String(FamiliesData.parts(c.id)[2])
	for f in c.fire:
		var k := clampf(float(f.get("damage", base)) / base, BondsData.SHOT_MIN, BondsData.SHOT_MAX)
		m.shots.fire(f["from"], f["vel"], float(f["grav"]), maxi(roundi(dmg * k), 1), true, 0.7,
			{"look": f.get("look", "spora"), "ally": int(rec["uid"]), "elem": elem})
		m.sfx.play("spora", f["from"])
	c.fire.clear()
	c.summons.clear()
	for a in c.acts:
		match String(a.get("kind", "")):
			"scoppia":
				_blast(c, rec, float(a.get("r", 2.5)), roundi(dmg * BondsData.BLAST_MULT))
			"folgore":
				m.strikes.bolt(float(a["x"]), float(a.get("delay", 0.6)), dmg, int(rec["uid"]))
			"cura":
				# voce 314: l'Istinto della cura: un quinto della sua Vita, e un poco al Germogliato
				c.hp = mini(c.hp + maxi(1, c.hp_max / 5), c.hp_max)
				c._bar.set_value(float(c.hp) / float(c.hp_max))
				m.vitals.heal(maxi(4, m.vitals.hp_max / 12))
				Fx.puff(m.fx, c.position, Color(0.8, 1.8, 1.2))
				Fx.puff(m.fx, m.player.position, Color(0.8, 1.8, 1.2))
	c.acts.clear()


## Lo scoppio di un compagno: ferisce le creature attorno, non lui né il Germogliato; poi tace per un po'.
func _blast(c: Creature, rec: Dictionary, r: float, dmg: int) -> void:
	Fx.puff(m.fx, c.position, Color(2.2, 1.3, 0.6))
	m.sfx.play("scoppio", c.position)
	for o in m.fauna.list.duplicate():
		if not o.calm and o.position.distance_to(c.position) < r * 16.0:
			strike(c, rec, o, dmg, c.position.x, "")
	c.busy = false
	c.shake = 0.0
	c.crouch = 0.0
	for b in c.tame.style:
		if b is BhScoppia:
			c.tame.pause[b] = BondsData.PAUSE


## Un colpo amico di un compagno (da `Combat.on_shot`): colpisce la prima creatura che tocca.
func shot(s: Dictionary, pos: Vector2) -> bool:
	var uid := int(s["ally"])
	var rec: Dictionary = herd.rec_of(uid)
	var c: Creature = herd.beasts.get(uid)
	var hits: Dictionary = s["hits"]
	for o in m.fauna.list.duplicate():
		if not hits.has(o) and not o.calm and o.rect().grow(2.0).has_point(pos):
			hits[o] = true
			strike(c if is_instance_valid(c) else null, rec, o, int(s["damage"]), pos.x - signf(s["vel"].x) * 10.0,
				String(s.get("elem", "")))
			return true
	return false


## Un colpo di una creatura selvatica tocca un compagno? Lo ferisce (e il colpo finisce lì).
func shot_hits_ally(s: Dictionary, pos: Vector2) -> bool:
	for c in fighters():
		if c.rect().grow(1.0).has_point(pos):
			hurt(c, c.tame.rec, int(s["damage"]), pos.x)
			return true
	return false


## Il compagno è ferito: se la Vita finisce si ritira (`Herd.faint`).
func hurt(c: Creature, rec: Dictionary, dmg: int, from_x: float) -> void:
	if c.take_hit(dmg, from_x, 0.6):
		herd.faint(rec)
	else:
		rec["vita"] = float(c.hp) / float(c.hp_max)


## Chi prende di mira chi: una creatura colpita da poco da un compagno, o molto più vicina a lui che al Germogliato,
## insegue il compagno. I Guardiani e i boss restano sul Germogliato.
func retarget() -> void:
	var allies := fighters()
	var p: Node2D = m.player
	var now := Time.get_ticks_msec()
	for o in m.fauna.list:
		if o.boss or o.calm:
			continue
		var best: Node2D = p
		var bd: float = o.position.distance_to(p.position)
		var aggro: bool = o.has_meta("bond_aggro") and now - int(o.get_meta("bond_aggro")) < int(BondsData.AGGRO_TIME * 1000.0)
		for a in allies:
			var da: float = o.position.distance_to(a.position)
			if (aggro and da < BondsData.LEASH * 16.0) or da < bd * BondsData.AGGRO_NEAR:
				best = a
				bd = da
		if o.target != best:
			o.target = best


## Nessuna creatura deve restare puntata su un compagno che se ne va (`Herd.despawn`).
func release(c: Creature) -> void:
	for o in m.fauna.list:
		if o.target == c:
			o.target = m.player


## Ricompare accanto al Germogliato (rimasto indietro o bloccato), su un posto libero, con uno sbuffo.
func beside(c: Creature) -> void:
	var p: Player = m.player
	Fx.puff(m.fx, c.position, Color(0.8, 1.6, 1.4))
	var spot := p.position + Vector2(-20.0 * p.facing, 0.0)
	for dx in [-20.0, 20.0, -36.0, 36.0, 0.0]:
		var at: Vector2 = p.position + Vector2(dx * p.facing, Player.HALF.y - c.half.y - 1.0)
		if _free(at, c.half):
			spot = at
			break
	c.position = spot
	c.vel = Vector2.ZERO
	c.busy = false
	Fx.puff(m.fx, c.position, Color(0.8, 1.6, 1.4))


func _free(at: Vector2, half: Vector2) -> bool:
	var w: World = m.world
	for x in range(floori((at.x - half.x) / 16.0), floori((at.x + half.x) / 16.0) + 1):
		for y in range(floori((at.y - half.y) / 16.0), floori((at.y + half.y) / 16.0) + 1):
			if w.solid(x, y):
				return false
	return true
