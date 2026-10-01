class_name BondBag
extends Node
## La Sacca dei legami (Roadmap 32, voce 311; richiesta dell'utente: «uno solo in campo, ma posso portarne cinque
## assieme in un'apposita sacca; quando una creatura va KO torna nell'inventario e guarisce solo quando torno al
## Giardino, e può essere sostituita da una delle altre quattro»).
## Le creature della sacca sono le schede della mandria con stato «segue» (al più `HerdData.FOLLOW_MAX`, cinque); quella in campo ha
## "campo" = true ed è l'unica in scena (`Herd._process`). Una scheda KO ha "ko" = true: resta nella sacca, non si
## evoca, e guarisce solo nel Giardino (qui, `_heal_home`). Tasti: «compagno» (evoca o richiama), «cambia_compagno»
## (manda in campo la prossima pronta). La barra nell'HUD è `BondBar`.

var m: Node2D
var _t := 0.0
var _home_healed := false              # già guariti in questa visita al Giardino (l'avviso una volta sola)
var _cool := 0.0                       # un attimo tra un cambio e l'altro
signal changed                         # la sacca è cambiata (la barra si ridisegna)


func setup(main: Node2D) -> void:
	m = main
	process_mode = Node.PROCESS_MODE_PAUSABLE


func herd() -> Herd:
	return m.herd


## Le schede nella sacca, nell'ordine in cui sono state messe.
func bag() -> Array:
	return herd().followers()


## La scheda in campo ({} se nessuna).
func field() -> Dictionary:
	for r in bag():
		if bool(r.get("campo", false)):
			return r
	return {}


static func ready_to_fight(r: Dictionary) -> bool:
	return not bool(r.get("ko", false))


## Manda in campo una scheda della sacca. "" se è andata, altrimenti il perché.
func summon(r: Dictionary) -> String:
	if String(r.get("stato", "")) != "segue":
		return "%s non è nella Sacca dei legami" % r["nome"]
	if not ready_to_fight(r):
		return "%s è KO: guarisce solo nel Giardino" % r["nome"]
	var cur := field()
	if cur == r:
		return ""
	if not cur.is_empty():
		_put_away(cur)
	r["campo"] = true
	m.sfx.play("dono")
	_emit()
	return ""


## Richiama nella sacca quella in campo (la sua Vita resta com'è).
func recall() -> void:
	var cur := field()
	if cur.is_empty():
		return
	_put_away(cur)
	m.hud.toast("%s torna nella Sacca dei legami" % cur["nome"])
	_emit()


func _put_away(r: Dictionary) -> void:
	var uid := int(r["uid"])
	if uid == herd().riding:
		herd().ride(false)
	var c: Creature = herd().beasts.get(uid)
	if c != null and is_instance_valid(c):
		r["vita"] = float(c.hp) / float(c.hp_max)
		Fx.puff(m.fx, c.position, Color(0.8, 1.6, 1.4))
	r["campo"] = false
	herd().despawn(uid)


## La prossima scheda pronta dopo quella in campo (o la prima pronta), {} se nessuna.
func next_ready() -> Dictionary:
	var list := bag()
	if list.is_empty():
		return {}
	var start := list.find(field())
	for k in range(1, list.size() + 1):
		var r: Dictionary = list[(start + k) % list.size()] if start >= 0 else list[k - 1]
		if ready_to_fight(r) and not bool(r.get("campo", false)):
			return r
	return {}


## Una del campo è andata KO (da `Herd.faint`): torna nella sacca, e l'avviso dice chi può prenderne il posto.
func knocked_out(r: Dictionary) -> void:
	r["ko"] = true
	r["campo"] = false
	r["vita"] = 0.0
	var nx := next_ready()
	if nx.is_empty():
		m.hud.toast("%s è KO e torna nella sacca. Nessun altro compagno è pronto: guariscono nel Giardino" % r["nome"])
	else:
		m.hud.toast("%s è KO e torna nella sacca. %s: manda in campo %s" % [r["nome"], Keys.label("cambia_compagno"),
			nx["nome"]])
	_emit()


func _unhandled_input(e: InputEvent) -> void:
	if m == null or not m.built or m.hud.is_open() or m.life.dead:
		return
	if Keys.pressed(e, "compagno"):
		get_viewport().set_input_as_handled()
		if _cool > 0.0:
			return
		_cool = 0.4
		if not field().is_empty():
			recall()
			return
		var r := next_ready()
		if r.is_empty():
			m.hud.toast(_why_none())
			return
		summon(r)
		m.hud.toast("In campo: %s" % r["nome"])
	elif Keys.pressed(e, "cambia_compagno"):
		get_viewport().set_input_as_handled()
		if _cool > 0.0:
			return
		_cool = 0.4
		var r := next_ready()
		if r.is_empty():
			m.hud.toast(_why_none() if field().is_empty() else "Nessun altro compagno pronto nella sacca")
			return
		summon(r)
		m.hud.toast("In campo: %s" % r["nome"])


func _why_none() -> String:
	if bag().is_empty():
		return "La Sacca dei legami è vuota: lega una creatura (Laccio, cibo, uova) o mettine una dalla mandria (G)"
	return "Tutti i compagni della sacca sono KO: guariscono nel Giardino"


func _process(dt: float) -> void:
	_cool -= dt
	if m == null or not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = 1.0
	_tidy()
	_heal_home()


## Al più una in campo, nessuna KO in campo, nessuna fuori dalla sacca segnata «in campo».
func _tidy() -> void:
	var seen := false
	for r in herd().records():
		if not bool(r.get("campo", false)):
			continue
		if String(r["stato"]) != "segue" or bool(r.get("ko", false)) or seen:
			r["campo"] = false
			herd().despawn(int(r["uid"]))
			_emit()
		else:
			seen = true


## Nel Giardino guariscono tutti (quelli della sacca, anche KO).
func _heal_home() -> void:
	if m.giardino == null or not m.giardino.active:
		_home_healed = false
		return
	var healed := 0
	for r in bag():
		if bool(r.get("ko", false)) or float(r.get("vita", 1.0)) < 1.0:
			r["ko"] = false
			r["vita"] = 1.0
			var c: Creature = herd().beasts.get(int(r["uid"]))
			if c != null and is_instance_valid(c):
				c.hp = c.hp_max
				c._bar.set_value(1.0)
			healed += 1
	if healed > 0:
		_emit()
		if not _home_healed:
			m.hud.toast("Nel Giardino i compagni della sacca guariscono")
	_home_healed = true


func _emit() -> void:
	changed.emit()
	herd().changed_now()
