class_name TestsArmor
extends RefCounted
## Le armature e i set (Roadmap 44, voci 389-391). Gruppo «armature».
## I dati: un elmo per stile in ogni materiale puro, un set per stile, un'abilità per ogni set di materiale; in gioco:
## l'elmo dello stile alza il danno dell'arma del suo stile (e solo di quella), il set intero accende la sua abilità
## (il fulmine del nembo al salto, l'ambra che stordisce chi ti ferisce), l'essenza della forgia si innesta su un pezzo.

var kit: TestKit
var m: Node2D
var res := {}


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	data()
	await style_helm()
	await set_ability()
	forge()
	print("armature: %s" % str(res))
	if not res.values().all(func(x: Variant) -> bool: return x == true):
		print("ATTENZIONE: le armature e i set non vanno come dovrebbero")


func data() -> void:
	var helms := 0
	for id in ItemsData.all():
		var it := ItemsData.get_item(String(id))
		if ArmorData.HELMS.has(String(it.get("form", ""))):
			helms += 1
	var style_sets := 0
	var no_fx := []
	for s in SetsData.all():
		var sd: Dictionary = SetsData.all()[s]
		if String(s).begins_with("stile_"):
			style_sets += 1
		if MaterialsData.all().has(s) and not sd.has("effects"):
			no_fx.append(s)
		for fx in sd.get("effects", []):
			if EffectsData.info(String(fx)).is_empty():
				no_fx.append("%s:%s" % [s, fx])
	var pure := 0
	for mat in MaterialsData.all():
		if not (MaterialsData.all()[mat] as Dictionary).has("alloy"):
			pure += 1
	res["dati"] = helms == pure * 8 and style_sets == pure * 8 and no_fx.is_empty() \
		and not RecipesData.making("celata_radicite").is_empty()
	print("armature, i dati: elmi degli stili %d, set degli stili %d (materiali puri %d), set senza abilità %s" % [
		helms, style_sets, pure, str(no_fx)])


## La Celata alza il danno della spada, non quello dell'arco.
func style_helm() -> void:
	kit.make_room()                              # (nel giro intero la Bisaccia è piena)
	var b: Bisaccia = m.character.bisaccia
	var eq0 := b.equip.duplicate()
	b.equip.erase("elmo")
	b.equip["elmo"] = "celata_ambra"
	var sel0: int = m.hud.sel
	var sw := kit.hold("spada_ambra")
	m.gear.refresh()
	var k_sword: float = m.combat.style_mult
	kit.hold("arco_ambra")
	m.gear.refresh()
	var k_bow: float = m.combat.style_mult
	b.equip = eq0
	m.hud.sel = sel0
	m.gear.refresh()
	await kit.frames(1)
	var want := ArmorData.helm_bonus(int(MaterialsData.get_mat("ambra")["tier"]))
	res["elmo"] = sw >= 0 and is_equal_approx(k_sword, want) and is_equal_approx(k_bow, 1.0)
	print("armature, la Celata d'ambra: spada ×%.3f (voluto %.3f), arco ×%.3f" % [k_sword, want, k_bow])


## Il set di nimbite chiama un fulmine al salto; quello d'ambra stordisce chi ti ferisce.
func set_ability() -> void:
	var b: Bisaccia = m.character.bisaccia
	var eq0 := b.equip.duplicate()
	for p in SetsData.all()["nimbite"]["pieces"]:
		b.equip[String(ItemsData.get_item(String(p))["kind"])] = String(p)
	m.gear.refresh()
	m.effects.refresh()
	var on: bool = m.effects.has("set_nimbite")
	var at: Vector2 = m.player.position + Vector2(48, 0)
	var c: Creature = m.fauna.add("lepre_linfa", at)
	var hp0: int = c.hp if c != null else 0
	var f0: int = m.effects.bolts
	m.abilities._cool.clear()
	m.abilities.trigger("salto")
	await kit.frames(2)
	var bolt: bool = m.effects.bolts == f0 + 1 and (c == null or not is_instance_valid(c) or c.hp < hp0)
	# l'ambra: chi ferisce resta stordito
	for p in SetsData.all()["ambra"]["pieces"]:
		b.equip[String(ItemsData.get_item(String(p))["kind"])] = String(p)
	m.gear.refresh()
	m.effects.refresh()
	var c2: Creature = m.fauna.add("lepre_linfa", m.player.position + Vector2(20, 0))
	m.effects._cool.clear()
	m.effects._on_wounded(5)
	var stun: bool = c2 != null and is_instance_valid(c2) and c2.stun > 1.0
	for o in [c, c2]:
		if o != null and is_instance_valid(o):
			m.fauna.kill(o)
	b.equip = eq0
	m.gear.refresh()
	m.effects.refresh()
	res["abilita_set"] = on and bolt and stun
	print("armature, le abilità dei set: nimbite attivo %s, fulmine al salto %s; ambra stordisce %s" % [on, bolt, stun])


## Un'essenza della forgia si innesta su un pezzo d'armatura e ne cambia il danno.
func forge() -> void:
	var ok := TraitsData.can_graft("essenza_cresta", "corazza_ambra") and not TraitsData.can_graft("essenza_cresta", "spada_ambra")
	var slot := {"id": "corazza_ambra", "n": 1, "dati": {"innesti": ["cresta"]}}
	var k := Gear.effect(slot, "damage")
	res["forgia"] = ok and is_equal_approx(k, 1.06)
	print("armature, la forgia: innesto %s, danno del pezzo ×%.2f" % [ok, k])
