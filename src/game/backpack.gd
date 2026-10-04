class_name Backpack
extends Node
## Lo zaino (Roadmap 30; dati in `BackpackData`). Voce 295: le Bisacce a gradi. Usarne una allarga la Bisaccia del
## Germogliato a tante caselle quante ne ha (per sempre, il contenuto resta); una più piccola della Bisaccia di adesso non
## si consuma. Il conteggio «bisaccia_caselle» dice fin dove si è arrivati.
## Voce 297: «Non raccogliere» e «Dritto nel Cestino», un segno per oggetto (`Character.guida["scarta"]`) che `Drops`
## legge; lo si cambia con il pulsante di Esamina.
## Voce 298: la Dispensa del Giardiniere (`Character.dispensa`): la stazione, il Seme (manda il superfluo), il Cuore (la
## apre ovunque); il grado in `stats["dispensa_grado"]`.
## Voce 299: il basto della mandria. Ogni secondo le creature che ti seguono con un basto (`rec["basto"]` = {id, c})
## diventano `Bisaccia.carriers`; il contenuto resta nella loro scheda anche quando riposano.

const RULES := ["", "lascia", "cestino"]
const RULE_TEXT := {"": "Raccogli", "lascia": "Non raccogliere", "cestino": "Dritto nel Cestino"}

var m: Node2D
var _bags := {}                        # uid della creatura -> Bisaccia del suo basto
var _t := 0.0


func setup(main: Node2D) -> void:
	m = main
	_sync_rules()
	var bp: BisacciaPanel = m.hud.panel
	bp.pick_rule = rule
	bp.pick_rule_next = next_rule


## Voce 297: che cosa si fa di un oggetto a terra: "" (raccoglierlo), "lascia", "cestino".
func rule(id: String) -> String:
	return String(_rules().get(id, ""))


func set_rule(id: String, r: String) -> void:
	if r == "":
		_rules().erase(id)
	else:
		_rules()[id] = r
	_sync_rules()


## Il segno dopo (Raccogli → Non raccogliere → Dritto nel Cestino → Raccogli); restituisce il nuovo.
func next_rule(id: String) -> String:
	var r := String(RULES[(RULES.find(rule(id)) + 1) % RULES.size()])
	set_rule(id, r)
	var name := String(ItemsData.get_item(id).get("name", id))
	m.hud.toast({"": "%s: lo raccogli di nuovo", "lascia": "%s: resta a terra, non lo raccogli più",
		"cestino": "%s: raccolto finisce subito nel Cestino"}[r] % name)
	return r


func _rules() -> Dictionary:
	if not m.character.guida.has("scarta"):
		m.character.guida["scarta"] = {}
	return m.character.guida["scarta"]


func _sync_rules() -> void:
	m.drops.rules = _rules()                    # (il dizionario si riassegna: un salvataggio può averlo sostituito)


## La Dispensa del personaggio (nasce alla prima apertura, grande quanto il suo grado).
func dispensa() -> Bisaccia:
	var n := int(BackpackData.DISPENSA_SLOTS[clampi(int(m.character.stats.get("dispensa_grado", 1)) - 1, 0,
		BackpackData.DISPENSA_SLOTS.size() - 1)])
	if m.character.dispensa == null:
		m.character.dispensa = Bisaccia.new(n)
	else:
		m.character.dispensa.grow(n)
	return m.character.dispensa


func open_dispensa(o: Vector2i, own := false) -> bool:
	var ip: ChestPanel = m.interact.chest_panel
	ip.open(o, dispensa(), "La tua Dispensa", own)
	m.sfx.play("apri", Vector2(o) * 16.0)
	return true


## Il Seme (manda il superfluo) e il Cuore (apre la Dispensa dove sei): il primo uso alza il grado.
func use_dispensa(id: String) -> bool:
	var g := int(ItemsData.get_item(id).get("grado", 2))
	if int(m.character.stats.get("dispensa_grado", 1)) < g:
		m.character.stats["dispensa_grado"] = g
		dispensa()
		m.hud.toast("La Dispensa cresce: ora ha %d caselle" % dispensa().slots.size())
	if g >= 3:
		return open_dispensa(m.player_cell(), true)
	var moved := send_surplus()
	m.hud.toast("Nella Dispensa: %d pile (ciò che contiene già e i materiali)" % moved if moved > 0
		else "Niente da mandare nella Dispensa (o è piena)")
	m.sfx.play("dono")
	return true


## Manda nella Dispensa, dalla Bisaccia (non la barra rapida) e dalle tasche, ciò che la Dispensa contiene già e i tipi
## che arrivano a mucchi. Restituisce quante pile sono partite (anche solo in parte).
func send_surplus() -> int:
	var dsp := dispensa()
	var have := {}
	for s in dsp.slots:
		if not s.is_empty():
			have[String(s["id"])] = true
	var moved := 0
	var b: Bisaccia = m.character.bisaccia
	for bag in b.all_bags():
		if bag == b.comps:
			continue                           # (3 ott 2026) gli scomparti restano addosso: munizioni, torce, Lumini
		for i in range(Bisaccia.HOTBAR if bag == b else 0, bag.slots.size()):
			var s: Dictionary = bag.slots[i]
			if s.is_empty() or s.has("dati") or s.has("tratto") or s.get("bloccato", false):
				continue
			var id := String(s["id"])
			if not have.has(id) and not String(ItemsData.get_item(id).get("kind", "")) in BackpackData.SURPLUS_KINDS:
				continue
			var n := int(s["n"])
			var left := dsp.add(id, n)
			if left < n:
				moved += 1
				if left <= 0:
					bag.slots[i] = {}
				else:
					bag.slots[i]["n"] = left
		bag.changed.emit()
	return moved


## Il basto va alla prima creatura che ti segue senza basto, o con uno più piccolo (il contenuto passa al nuovo).
func use_basto(id: String) -> bool:
	var bd := BackpackData.basto_of(id)
	var best: Dictionary = {}
	for r in m.herd.followers():
		var old := String((r.get("basto", {}) as Dictionary).get("id", ""))
		if old == "" or int(BackpackData.basto_of(old).get("slots", 0)) < int(bd["slots"]):
			best = r
			break
	if best.is_empty():
		m.hud.toast("Serve una creatura della mandria che ti segua senza un basto (o con uno più piccolo): tasto G")
		return false
	if not m.character.bisaccia.remove(id, 1):
		return false
	var old_c: Array = (best.get("basto", {}) as Dictionary).get("c", [])
	var old_id := String((best.get("basto", {}) as Dictionary).get("id", ""))
	best["basto"] = {"id": id, "c": old_c}
	if old_id != "":
		m.character.bisaccia.add(old_id, 1)       # il basto vecchio torna a te
	_bags.erase(int(best["uid"]))
	update_carriers()
	m.hud.toast("%s porta il %s: %d caselle in più finché ti segue" % [best["nome"], String(bd["name"]).to_lower(),
		BackpackData.basto_slots(id, int(best.get("lvl", 1)))])
	m.sfx.play("dono")
	return true


## Le creature che ti seguono con un basto diventano borse della Bisaccia.
func update_carriers() -> void:
	var b: Bisaccia = m.character.bisaccia
	var list := []
	var seen := {}
	for r in m.herd.followers():
		var bs: Dictionary = r.get("basto", {})
		if bs.is_empty():
			continue
		var uid := int(r["uid"])
		seen[uid] = true
		var n := BackpackData.basto_slots(String(bs["id"]), int(r.get("lvl", 1)))
		var cb: Bisaccia = _bags.get(uid)
		if cb == null:
			cb = Bisaccia.from_array(bs.get("c", []), n)
			var rec: Dictionary = r
			cb.changed.connect(func() -> void:
				(rec["basto"] as Dictionary)["c"] = cb.to_array()
				b.changed.emit())
			_bags[uid] = cb
		cb.grow(n)                                 # (una caselle in più quando la creatura sale di livello)
		list.append({"bag": cb, "icon": String(bs["id"]), "tip": "Il basto di %s · %d caselle" % [r["nome"], n]})
	for uid in _bags.keys():
		if not seen.has(uid):
			_bags.erase(uid)
	b.carriers = list


func _process(dt: float) -> void:
	_t -= dt
	if _t > 0.0 or m == null or m.get("herd") == null:
		return
	_t = 1.0
	update_carriers()


func use_bag(id: String) -> bool:
	var bd := BackpackData.bag_of(id)
	if bd.is_empty():
		return false
	var b: Bisaccia = m.character.bisaccia
	var n := int(bd["slots"])
	if n <= b.slots.size():
		m.hud.toast("La tua Bisaccia ha già %d caselle: questa ne ha %d" % [b.slots.size(), n])
		return false
	if not b.remove(id, 1):
		return false
	b.grow(n)
	m.character.stats["bisaccia_caselle"] = n
	m.hud.toast("%s: ora la Bisaccia ha %d caselle (le pagine in alto, accanto al titolo)" % [bd["name"], n])
	m.sfx.play("dono")
	return true
