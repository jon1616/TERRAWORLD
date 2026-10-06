class_name TestsStyles
extends RefCounted
## Gli stili del Giardiniere (Roadmap 40, voci 367, 368 e 372). Gruppo «stili».
## I dati (ogni forma d'arma ha uno stile, le forme nuove esistono in ogni materiale puro e crescono con il grado), e le
## risorse in partita: lo Slancio delle manopole, la Mira ferma dei dischi, l'Ispirazione della buccina e il suo canto,
## la Rugiada del virgulto, il seme-torre che tira da solo, la fionda con i sassi, lo scettro con l'alleato forte.

var kit: TestKit
var m: Node2D
var res := {}


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	data()
	var keep: Array = m.character.bisaccia.slots.duplicate(true)
	m.snap_to(m.world.spawn)
	await kit.frames(3)
	m.fauna.clear(true)
	await slancio()
	await lancio()
	await canto()
	cura()
	await radice()
	await distanza()
	evocazione()
	await firma()
	m.styles.auto_fire = false
	m.styles.auto_aim = Vector2.INF
	m.combat.auto_fire = false
	m.combat.auto_aim = Vector2.INF
	m.player.force_swing = false
	m.fauna.clear(true)
	m.styles.turrets.clear()
	var w := 0.0
	while m.shots.count() > 0 and w < 4.0:          # i colpi ancora in volo (le prove dopo li contano)
		await kit.seconds(0.2)
		w += 0.2
	for i in keep.size():
		m.character.bisaccia.slots[i] = keep[i]
	m.character.bisaccia.changed.emit()
	print("stili: %s" % str(res))
	if not res.values().all(func(x: Variant) -> bool: return x == true):
		print("ATTENZIONE: gli stili del Giardiniere non vanno come dovrebbero")


func data() -> void:
	var no_style := []
	for f in FormsData.FORMS:
		var it := ItemsData.get_item(FormsData.item_id(String(f), "radicite"))
		var k := String(it.get("kind", ""))
		if k in ["elmo", "corazza", "gambali", "guanti", "stivali", "mantello", "piccone", "ascia", "canna"]:
			continue
		if StylesData.of_item(it) == "":
			no_style.append(f)
	var grow := true
	for f in FormsData.PURE:
		var a := ItemsData.get_item(FormsData.item_id(String(f), "radicite"))
		var b := ItemsData.get_item(FormsData.item_id(String(f), "primambra"))
		if a.is_empty() or b.is_empty() or ItemsData.has(FormsData.item_id(String(f), "lega_radicite_ambra")):
			grow = false
		elif String(f) != "scettro" and int(b["damage"]) < int(a["damage"]) * 10:
			grow = false
	var ammo_ok := true
	for f in FormsData.AMMO_OF:
		var want := String(FormsData.AMMO_OF[f])
		if not Combat.AMMO.any(func(x: String) -> bool: return String(ItemsData.get_item(x).get("ammo", "dardo")) == want):
			ammo_ok = false
	res["dati"] = no_style.is_empty() and grow and ammo_ok and Combat.AMMO.size() >= 30
	print("stili, i dati: forme senza stile %s; crescono con il grado %s; munizioni %d (sassi e spore %s); verga di radicite %d, di primambra %d" % [
		str(no_style), grow, Combat.AMMO.size(), ammo_ok, int(ItemsData.get_item("verga_radicite")["damage"]),
		int(ItemsData.get_item("verga_primambra")["damage"])])


func _hold(id: String) -> void:
	var si := kit.hold(id)
	m.hud.select(si)


func _foe(dx: float) -> Creature:
	var cr: Creature = m.fauna.add("grumo_muschio", m.player.position + Vector2(dx, -6))
	cr.set_process(false)
	cr.hp = 99999
	cr.hp_max = 99999
	return cr


## Mischia: le manopole caricano lo Slancio colpo dopo colpo; pieno, il giro dopo vale doppio e lo Slancio torna a zero.
func slancio() -> void:
	_hold("manopole_radicite")
	await kit.frames(2)
	var cr := _foe(14.0 * float(m.player.facing))
	m.styles.slancio = 0
	var peak := 0
	var reset := false
	m.player.force_swing = true
	var t := 0.0
	while t < 4.0:
		await kit.frames(1)
		t += m.get_process_delta_time()
		peak = maxi(peak, m.styles.slancio)
		if peak >= StylesData.SLANCIO_MAX and m.styles.slancio < StylesData.SLANCIO_MAX:
			reset = true
			break
	m.player.force_swing = false
	res["slancio"] = peak >= StylesData.SLANCIO_MAX and reset and cr.hp < 99999
	m.fauna.clear(true)


## Lancio: fermo un attimo, la Mira ferma è pronta; il lancio dopo la consuma e i dischi partono.
func lancio() -> void:
	_hold("dischi_radicite")
	m.player.vel = Vector2.ZERO
	m.styles.mira_ready = false
	await kit.seconds(StylesData.MIRA_T + 0.4)
	var ready: bool = m.styles.mira_ready
	var f0: int = m.styles.fired
	m.styles.auto_aim = m.player.position + Vector2(200, -6)
	m.styles.auto_fire = true
	await kit.seconds(0.3)
	m.styles.auto_fire = false
	res["lancio"] = ready and not m.styles.mira_ready and m.styles.fired > f0


## Canto: le note che colpiscono danno Ispirazione; piena, parte il Canto di guerra (+25% danno).
func canto() -> void:
	_hold("buccina_radicite")
	var cr := _foe(70.0)
	m.styles.ispirazione = 0
	m.styles.song = ""
	m.styles.auto_aim = cr.position
	m.styles.auto_fire = true
	await kit.seconds(2.0)
	m.styles.auto_fire = false
	var got: int = m.styles.ispirazione
	m.styles.ispirazione = StylesData.ISPIRAZIONE_MAX - 1
	m.styles.note_hit("canto", cr, 5)
	var song := String(m.styles.song)
	var mult: float = m.styles.dmg_now()
	m.styles.song_t = 0.01
	await kit.frames(3)
	res["canto"] = got >= 1 and song == "buccina" and is_equal_approx(mult, 1.25) and m.styles.song == ""
	m.fauna.clear(true)


## Cura: ferire con il virgulto cura; la sesta volta l'onda di Rugiada.
func cura() -> void:
	_hold("virgulto_radicite")
	var hp0: int = m.vitals.hp
	m.vitals.hp = maxi(m.vitals.hp_max / 2, 1)
	var low: int = m.vitals.hp
	m.styles.rugiada = 0
	for k in StylesData.RUGIADA_EVERY:
		m.styles.note_hit("cura", null, 10)
	res["cura"] = m.vitals.hp > low + StylesData.RUGIADA_EVERY and m.styles.rugiada == 0
	m.vitals.hp = maxi(hp0, 1)
	m.vitals.changed.emit()


## Radice: un seme-torre piantato vicino tira da solo alla creatura vicina.
func radice() -> void:
	_hold("semetorre_radicite")
	var cr := _foe(90.0)
	var ok: bool = m.styles.turrets.plant(m.player.position + Vector2(30, -4), 20, {"style": "radice"}, 1, "semetorre_radicite")
	await kit.seconds(1.6)
	res["radice"] = ok and m.styles.turrets.count() == 1 and cr.hp < 99999
	m.styles.turrets.clear()
	m.fauna.clear(true)


## Distanza: la fionda tira sassi (e non dardi).
func distanza() -> void:
	_hold("fionda_radicite")
	m.character.bisaccia.add("sasso", 20)
	var d0: int = m.character.bisaccia.count("dardo")
	var s0: int = m.character.bisaccia.count("sasso")
	m.combat.auto_aim = m.player.position + Vector2(200, -10)
	m.combat.auto_fire = true
	await kit.seconds(0.8)
	m.combat.auto_fire = false
	m.combat.auto_aim = Vector2.INF
	res["distanza"] = m.character.bisaccia.count("sasso") < s0 and m.character.bisaccia.count("dardo") == d0


## Evocazione: lo scettro di primambra richiama un alleato molto più forte di quello di radicite.
func evocazione() -> void:
	var lin: int = m.vitals.linfa
	m.vitals.linfa = m.vitals.linfa_max
	var ok: bool = m.companions.summon("scettro_primambra")
	var pw: float = m.companions.allies[-1].power if ok and not m.companions.allies.is_empty() else 0.0
	m.companions.dismiss_allies()
	m.vitals.linfa = lin
	res["evocazione"] = ok and pw > 5.0


## Voci 370 e 371: dieci armi firma per fase, tutte diverse, più forti delle armi fabbricate della loro fase; una cade
## davvero; tenuta in mano porta i suoi effetti; le linee d'arma arrivano all'arma suprema di ogni stile.
func firma() -> void:
	var per_phase := {}
	var sigs := {}
	var bad := []
	for id in ItemsData.all():
		var it := ItemsData.get_item(String(id))
		if not it.has("firma") or it.has("linea"):
			continue
		per_phase[int(it["fase"])] = int(per_phase.get(int(it["fase"]), 0)) + 1
		var sig := "%s|%s|%s" % [it["form"], str(it.get("mods", {})), str((it["effects"] as Array).map(func(e: String) -> Dictionary:
			var d := EffectsData.info(e).duplicate()
			d.erase("name")
			d.erase("desc")
			return d))]
		if sigs.has(sig):
			bad.append("gemella: %s e %s" % [id, sigs[sig]])
		sigs[sig] = id
		for e in it["effects"]:
			if EffectsData.info(String(e)).is_empty():
				bad.append("%s: effetto %s" % [id, e])
	var tens := per_phase.size() == 23 and per_phase.values().all(func(n: int) -> bool: return n == 10)
	# più forte della spada fabbricata della sua fase (la fase 13 = corallite)
	var f13 := ""
	for id in ItemsData.all():
		var it := ItemsData.get_item(String(id))
		if it.has("firma") and int(it.get("fase", 0)) == 13 and String(it["form"]) == "spada" and not it.has("linea"):
			f13 = String(id)
	var stronger := f13 == "" or int(ItemsData.get_item(f13)["damage"]) > int(ItemsData.get_item("spada_corallite")["damage"])
	# una cade, e in mano porta i suoi effetti
	var got: String = m.firma.drop(5, m.player.position + Vector2(0, -20))
	await kit.seconds(0.6)
	var held := false
	if got != "":
		_hold(got)
		await kit.frames(2)
		m.effects.refresh()
		held = m.effects.has(String((ItemsData.get_item(got)["effects"] as Array)[0]))
	# le linee
	var lines := 0
	for st in StylesData.ORDER:
		if ItemsData.has("linea_%s_6" % st) and not RecipesData.making("linea_%s_6" % st).is_empty():
			lines += 1
	var sup := int(ItemsData.get_item("linea_mischia_6").get("damage", 0))
	res["firma"] = tens and bad.is_empty() and stronger and got != "" and held and lines == 8 and sup > int(ItemsData.get_item("spada_primambra")["damage"])
	print("stili, le armi firma: per fase %s; gemelle e difetti %s; più forte della spada di corallite %s; caduta «%s», effetti in mano %s; linee complete %d, la Radice del mondo %d (spada di primambra %d)" % [
		str(per_phase.values()), str(bad.slice(0, 4)), stronger, got, held, lines, sup, int(ItemsData.get_item("spada_primambra")["damage"])])

