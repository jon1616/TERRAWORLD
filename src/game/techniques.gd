class_name Techniques
extends Node
## Le tecniche delle armi (Roadmap 25, voce 248; dati in `ArtsData.TECHS`): il tasto «tecnica» esegue la mossa della
## forma d'arma in mano, se la sua maestria (`WeaponArts`) l'ha aperta. Costa Linfa e ha un'attesa (`cd` per forma).
## Il danno è quello dell'arma (con qualità, tratti, tempra e i moltiplicatori di `Combat._boon`) × il `mult` del grado.

const S := 16.0

var m: Node2D
var _cd := {}                          # forma -> secondi che mancano


func setup(main: Node2D) -> void:
	m = main


func _process(dt: float) -> void:
	for k in _cd.keys():
		_cd[k] = float(_cd[k]) - dt
		if float(_cd[k]) <= 0.0:
			_cd.erase(k)


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo and Keys.pressed(e, "tecnica") and not m.hud.panel.visible:
		use()
		get_viewport().set_input_as_handled()


## Quanto manca prima di poter usare di nuovo la tecnica della forma (0 = pronta).
func wait_of(form: String) -> float:
	return maxf(float(_cd.get(form, 0.0)), 0.0)


## Esegue la tecnica dell'arma in mano. Restituisce "" se è partita, altrimenti il perché (anche come avviso).
func use(target := Vector2.INF) -> String:
	var form: String = m.arts.held_form()
	var why := ""
	var g := ArtsData.tech_grade(m.arts.rank(form)) if form != "" else 0
	if form == "":
		why = "Le tecniche si usano con un'arma in mano"
	elif g == 0:
		why = "La tecnica %s si apre al rango %d della sua maestria" % [ArtsData.FORMS[form], int(ArtsData.TECH_RANKS[0])]
	elif wait_of(form) > 0.0:
		why = "%s: ancora %d secondi" % [ArtsData.TECHS[form]["name"], ceili(wait_of(form))]
	elif m.vitals.linfa < int(ArtsData.TECHS[form]["linfa"]):
		why = "Serve Linfa per %s" % ArtsData.TECHS[form]["name"]
	if why != "":
		m.hud.toast(why)
		return why
	var t: Dictionary = ArtsData.TECHS[form]
	m.vitals.linfa -= int(t["linfa"])
	m.vitals.changed.emit()
	_cd[form] = float(t["cd"])
	var slot: Dictionary = m.hud.current()
	var st := Gear.stats({"id": slot["id"], "tratto": slot.get("tratto", ""), "dati": m.character.bisaccia.slots[m.hud.sel].get("dati", {})})
	var dmg := maxi(1, roundi(float(st["damage"]) * float(t["mult"][g - 1]) * m.combat._boon()))
	var elem := String(st["elem"])
	var aim: Vector2 = target if target != Vector2.INF else m.fx.get_global_mouse_position()
	call("_" + String(t["kind"]), t, dmg, elem, aim)
	m.objectives.bump("tecniche")
	m.sfx.play("colpo")
	return ""


func _p() -> Player:
	return m.player


func _hit_all(list: Array, dmg: int, force: float, elem: String, stun := 0.0) -> int:
	var n := 0
	for c in list:
		if not is_instance_valid(c) or not m.fauna.list.has(c) or c.tame != null:
			continue
		if stun > 0.0:
			c.stun = maxf(c.stun, stun)
		m.combat._strike(c, dmg, _p().position.x, force, elem)
		n += 1
	return n


func _near(center: Vector2, r_tiles: float) -> Array:
	return m.fauna.list.filter(func(c: Creature) -> bool: return c.position.distance_to(center) <= r_tiles * S)


## Colpisce tutto attorno (fendente, mietitura).
func _giro(t: Dictionary, dmg: int, elem: String, _aim: Vector2) -> void:
	Fx.puff(m.fx, _p().position, Color(1.6, 1.5, 1.2))
	_hit_all(_near(_p().position, float(t["r"])), dmg, 2.0, elem)


## Uno scatto in avanti: colpisce chi sta sulla strada (affondo, carica).
func _affondo(t: Dictionary, dmg: int, elem: String, aim: Vector2) -> void:
	var p := _p()
	var dir := 1.0 if aim.x >= p.position.x else -1.0
	p.facing = int(dir)
	var length: float = float(t.get("dash", 4.0)) * S
	p.dash_dir = dir
	p.dash_t = length / DashData.SPEED
	var a := p.position.x
	var b := a + dir * (length + float(t["r"]) * S)
	var lane: Array = m.fauna.list.filter(func(c: Creature) -> bool:
		return c.position.x >= minf(a, b) and c.position.x <= maxf(a, b) and absf(c.position.y - p.position.y) < 2.2 * S)
	_hit_all(lane, dmg, 2.5, elem)


## Un colpo davanti, forte e che spinge lontano.
func _pesante(t: Dictionary, dmg: int, elem: String, aim: Vector2) -> void:
	var p := _p()
	var dir := 1.0 if aim.x >= p.position.x else -1.0
	var front := p.position + Vector2(dir * float(t["r"]) * S * 0.5, 0)
	Fx.puff(m.fx, front, Color(1.8, 1.3, 0.8))
	_hit_all(_near(front, float(t["r"]) * 0.6), dmg, 5.0, elem, 0.4)


## Un'onda a terra che stordisce tutto attorno.
func _terremoto(t: Dictionary, dmg: int, elem: String, _aim: Vector2) -> void:
	var p := _p()
	for k in 5:
		Fx.puff(m.fx, p.position + Vector2((k - 2) * float(t["r"]) * S / 3.0, 6), Color(1.3, 1.1, 0.8))
	var near: Array = _near(p.position, float(t["r"])).filter(func(c: Creature) -> bool: return not c.fly)
	_hit_all(near, dmg, 1.5, elem, float(t.get("stun", 1.0)))


## Afferra la creatura più vicina davanti e la tira a sé.
func _laccio(t: Dictionary, dmg: int, elem: String, aim: Vector2) -> void:
	var p := _p()
	var dir := 1.0 if aim.x >= p.position.x else -1.0
	var best: Creature = null
	var bd := float(t["r"]) * S
	for c in m.fauna.list:
		var dx: float = (c.position.x - p.position.x) * dir
		var d: float = c.position.distance_to(p.position)
		if dx > 0.0 and d < bd and c.tame == null and absf(c.position.y - p.position.y) < 4.0 * S:
			bd = d
			best = c
	if best == null:
		return
	best.position = p.position + Vector2(dir * 1.5 * S, -2.0)
	_hit_all([best], dmg, 0.3, elem, float(t.get("stun", 0.6)))


## Una pioggia di dardi a ventaglio (senza consumare dardi: è la tecnica).
func _raffica(t: Dictionary, dmg: int, elem: String, aim: Vector2) -> void:
	var from := _p().position + Vector2(0, -6)
	var v := (aim - from).normalized() * Combat.DART_SPEED
	var n := int(t.get("n", 5))
	for k in n:
		m.shots.fire(from + v.normalized() * 8.0, v.rotated((k - (n - 1) / 2.0) * 0.14), Combat.DART_GRAV * Creature.grav, dmg, true,
				1.0, {"elem": elem})


## Un dardo che attraversa tutte le creature in linea.
func _trafiggi(_t: Dictionary, dmg: int, elem: String, aim: Vector2) -> void:
	var from := _p().position + Vector2(0, -6)
	var v := (aim - from).normalized() * Combat.DART_SPEED * 1.4
	m.shots.fire(from + v.normalized() * 8.0, v, Combat.DART_GRAV * Creature.grav * 0.3, dmg, true, 1.5, {"pierce": 99, "elem": elem})


## Una saetta grande che esplode dove arriva (entro 18 tessere).
func _saetta(t: Dictionary, dmg: int, elem: String, aim: Vector2) -> void:
	var p := _p()
	var d := aim - p.position
	if d.length() > 18.0 * S:
		aim = p.position + d.normalized() * 18.0 * S
	Fx.puff(m.fx, aim, Color(0.8, 1.8, 1.9))
	_hit_all(_near(aim, float(t["r"])), dmg, 2.0, elem if elem != "" else "linfa")
