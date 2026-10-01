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


var panel: BondsPanel                  # voce 316: il pannello dei compagni (tasto «compagni»)


func setup(main: Node2D) -> void:
	m = main
	process_mode = Node.PROCESS_MODE_PAUSABLE
	panel = BondsPanel.new()
	m.hud.add_child(panel)
	panel.setup(m, self)
	m.hud.overlays.append(panel)


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
		r.erase("resistito")                            # voce 315: l'ultima resistenza torna
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


# ---- voce 314: gli oggetti dei compagni ----------------------------------------------------------------------------

## Dare un oggetto al compagno in campo (clic sopra di lui con l'oggetto in mano). False se non c'entra (un'essenza
## cliccata altrove resta per gli innesti).
func use_item(id: String, at: Vector2) -> bool:
	var rec := field()
	var c: Creature = herd().beasts.get(int(rec.get("uid", -1))) if not rec.is_empty() else null
	var on_it: bool = c != null and is_instance_valid(c) and c.rect().grow(8.0).has_point(at)
	var essence := BondsData.essence_trait(id)
	if not on_it:
		if essence != "":
			return false
		m.hud.toast("Clic sul compagno in campo con l'oggetto in mano" if c != null else "Serve un compagno in campo (%s)" % Keys.label("compagno"))
		return true
	var why := give(rec, id)
	if why != "":
		m.hud.toast(why)
		return true
	m.character.bisaccia.remove(id, 1)
	Fx.puff(m.fx, c.position + Vector2(0, -c.half.y), Herd.HEARTS)
	m.sfx.play("dono", c.position)
	_emit()
	return true


## Voce 315: l'atteggiamento in battaglia (dal pannello).
func set_stance(rec: Dictionary, s: String) -> void:
	if not BondsData.STANCES.has(s):
		return
	rec["indole"] = s
	var c: Creature = herd().beasts.get(int(rec["uid"]))
	if c != null and is_instance_valid(c) and s == "fermo":
		c.tame.foe = null
	m.hud.toast("%s: %s (%s)" % [rec["nome"], String(BondsData.STANCES[s][0]).to_lower(), BondsData.STANCES[s][1]])
	_emit()


## L'effetto di un oggetto su una scheda. "" se è andato (l'oggetto va tolto), altrimenti il perché. Lo usano anche le
## prove e il pannello (voce 316).
func give(rec: Dictionary, id: String) -> String:
	var name := String(rec["nome"])
	var sp := String(rec["specie"])
	if BondsData.FRUITS.has(id):
		var k := String(BondsData.FRUITS[id][0])
		if not rec.has("frutti"):
			rec["frutti"] = {}
		var n := int(rec["frutti"].get(k, 0))
		if n >= BondsData.FRUIT_MAX:
			return "%s ne ha già mangiate %d: di più non le fanno nulla" % [name, BondsData.FRUIT_MAX]
		rec["frutti"][k] = n + 1
		herd().refresh(rec)
		m.hud.toast("%s: %s (%d/%d)" % [name, BondsData.FRUITS[id][2], n + 1, BondsData.FRUIT_MAX])
		return ""
	if id == BondsData.XP_SEED:
		if int(rec["lvl"]) >= HerdData.LVL_MAX:
			return "%s è già al livello più alto" % name
		herd().gain_xp(rec, BondsData.xp_for(int(rec["lvl"])) / 2)
		return ""
	if id.begins_with("istinto_"):
		var b := id.trim_prefix("istinto_")
		var known: Array = rec.get("istinti", [])
		var no := BondsData.can_learn(sp, b, known)
		if no != "":
			return "%s: %s" % [name, no.to_lower()]
		var slots := BondsData.slots_at(int(rec["lvl"]))
		if known.size() >= slots:
			var nx := -1
			for l in BondsData.SLOT_LVLS:
				if int(rec["lvl"]) < int(l) and nx < 0:
					nx = int(l)
			return "%s non ha posti liberi per le mosse%s" % [name,
				(": il prossimo si apre al livello %d" % nx) if nx > 0 else " (ne ha già %d: dimenticane una nel pannello)" % slots]
		known.append(b)
		rec["istinti"] = known
		herd().refresh(rec, true)
		m.hud.toast("%s impara: %s" % [name, String(BondsData.ISTINTI[b][1])])
		m.objectives.bump("istinti_imparati")
		return ""
	if id.begins_with("pietra_elem_"):
		var e := id.trim_prefix("pietra_elem_")
		var pt := FamiliesData.parts(sp)
		if String(pt[2]) == e:
			return "%s è già %s" % [name, BondsData.ELEM_STONES[e]]
		rec["specie"] = FamiliesData.variant_id(String(pt[0]), String(pt[1]), e, String(pt[3]))
		herd().refresh(rec, true)
		m.hud.toast("%s diventa %s" % [name, BondsData.ELEM_STONES[e]])
		return ""
	if BondsData.CIONDOLI.has(id):
		var old := String(rec.get("ciondolo", ""))
		if old == id:
			return "%s porta già questo ciondolo" % name
		rec["ciondolo"] = id
		if old != "":
			m.character.bisaccia.add(old, 1)
		herd().refresh(rec)
		m.hud.toast("%s porta il %s: %s" % [name, String(BondsData.CIONDOLI[id][0]).to_lower(), BondsData.CIONDOLI[id][2]])
		return ""
	var tr := BondsData.essence_trait(id)
	if tr != "":
		var an: Dictionary = rec.get("antico", {"r": "", "t": []})
		if tr in (an.get("t", []) as Array):
			return "%s ha già il tratto %s" % [name, String(AncientData.TRAITS[tr]["name"]).to_lower()]
		if int(rec.get("essenze", 0)) >= BondsData.ESSENCE_MAX:
			return "%s ha già preso %d essenze: di più non ne regge" % [name, BondsData.ESSENCE_MAX]
		var ts: Array = an.get("t", [])
		ts.append(tr)
		an["t"] = ts
		rec["antico"] = an
		rec["essenze"] = int(rec.get("essenze", 0)) + 1
		herd().refresh(rec, true)
		m.hud.toast("%s prende il tratto %s: %s" % [name, String(AncientData.TRAITS[tr]["name"]).to_lower(),
			String(AncientData.TRAITS[tr]["desc"])])
		return ""
	return "Non è un oggetto per i compagni"
