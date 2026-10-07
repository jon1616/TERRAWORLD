class_name TestsSpine
extends RefCounted
## La spina della partita (Roadmap 39, voci 362-366). Gruppo «spina».
## Le curve dei numeri (armi e creature crescono insieme), i dodici metalli con tutto ciò che serve, il Risveglio del
## Cuore (metalli nelle rocce, antiche più frequenti, un'Aiuola in più), la Linfa del Cuore, il Diario della spina, i
## Guardiani generati di pericolosità simile.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	curves()
	metals()
	awakening()
	heart_gift()
	guardians()


## Voce 365: le curve. Il filo di ogni metallo sta sulla curva della spina (entro il 12%), la Vita delle creature
## cresce di ×1,3456 per vigore fino al tetto e poco dopo, il danno meno della Vita.
func curves() -> void:
	var off := []
	for mat in MaterialsData.MATERIALS.keys() + SpineData.METALS.keys():
		var md := MaterialsData.get_mat(String(mat))
		if String(mat) in ["pallidite", "tizzonite", "nimbite"] or md.has("dopo"):
			continue                                     # i metalli laterali hanno altri pregi; quelli del dopo la loro curva
		var want := SpineData.filo_of_tier(int(md["tier"]))
		if absf(float(md["filo"]) - want) > want * 0.12:
			off.append("%s %s/%d" % [mat, md["filo"], roundi(want)])
	var hp_ok := is_equal_approx(SpineData.creature_hp(1), 1.0) and SpineData.creature_hp(11) > 14.0 \
		and SpineData.creature_hp(15) < SpineData.creature_hp(11) * 1.25
	var dmg_ok := SpineData.creature_dmg(8) < SpineData.creature_hp(8) and SpineData.creature_dmg(8) > 2.5
	var sw := [float(ItemsData.get_item("spada_radicite")["damage"]), float(ItemsData.get_item("spada_primambra")["damage"])]
	print("spina, le curve: Vita delle creature v2 ×%.2f, v6 ×%.1f, v11 ×%.1f, v15 ×%.1f; danno v11 ×%.1f; spada di radicite %d, di primambra %d (×%.0f); metalli fuori curva %s" % [
		SpineData.creature_hp(2), SpineData.creature_hp(6), SpineData.creature_hp(11), SpineData.creature_hp(15),
		SpineData.creature_dmg(11), sw[0], sw[1], sw[1] / sw[0], str(off)])
	if not off.is_empty() or not hp_ok or not dmg_ok or sw[1] / sw[0] < 18.0:
		print("ATTENZIONE: le curve della spina non tornano")


## Voce 363: ogni metallo del Risveglio ha grezzo, lingotto con la sua ricetta, gesto, carattere, set, armi e armature,
## e una fase che viene dopo quella del metallo prima.
func metals() -> void:
	var bad := []
	var last := PhasesData.of("spada_stellare")
	for g in SpineData.METALS:
		var raw := String(SpineData.METALS[g]["raw"]["id"])
		if not ItemsData.has(raw) or RecipesData.making("lingotto_" + g).is_empty():
			bad.append(g + ": grezzo o lingotto")
		if GesturesData.of_mat(String(g)).is_empty() or MaterialsData.trait_of(String(g)).is_empty():
			bad.append(g + ": gesto o carattere")
		if not SetsData.all().has(g) or not ItemsData.has("corazza_" + g) or not ItemsData.has("arco_" + g):
			bad.append(g + ": set o famiglia")
		var f := PhasesData.of("spada_" + g)
		if SpineData.METALS[g].has("dopo"):
			continue                                     # Roadmap 51: oltre la fase 23 c'è il dopo (stessa fase, più forza)
		if f <= last:
			bad.append("%s: fase %d" % [g, f])
		last = f
	print("spina, i metalli del Risveglio: %d, fasi della spada %s; problemi %s" % [SpineData.METALS.size(),
		str(SpineData.METALS.keys().map(func(x: String) -> int: return PhasesData.of("spada_" + x))), str(bad)])
	if not bad.is_empty():
		print("ATTENZIONE: i metalli del Risveglio non sono completi")


## Voce 364: prima del Risveglio niente metalli nuovi; dopo, quelli del vigore del mondo (l'ultimo per sempre), che
## cadono scavando la roccia dello strato giusto; le antiche più frequenti; un'Aiuola in più.
func awakening() -> void:
	var ch: Character = m.character
	var had := int(ch.stats.get("risveglio_cuore", 0))
	var v0: Variant = m.world_meta.get("vigore", null)
	var aiu0: int = m.aiuole.max_aiuole()
	var before := GeneMaterials.spine_for(6, false)
	var at6 := GeneMaterials.spine_for(6, true)
	var at12 := GeneMaterials.spine_for(12, true)
	var at30 := GeneMaterials.spine_for(30, true)
	ch.stats["risveglio_cuore"] = 1
	m.world_meta["vigore"] = 6
	m.cuore_desto.apply()
	var spine: Array = m.gene_mats.spine.duplicate()
	var rare: float = m.fauna.awake_rare
	var aiu1: int = m.aiuole.max_aiuole()
	# scavare: la corallite cade dall'ardesia delle Caverne, mai dalla Superficie
	var px: int = m.player_cell().x
	var deep := Vector2i(px, int(m.world.surface[px]) + StrataData.top(2) + 30)
	var top := Vector2i(px, int(m.world.surface[px]) + 2)
	var f0: int = m.gene_mats.found
	for k in 400:
		m.gene_mats.on_dig(TileDefs.STONE, top)
	var f_top: int = m.gene_mats.found - f0
	for k in 400:
		m.gene_mats.on_dig(TileDefs.STONE, deep)
	var f_deep: int = m.gene_mats.found - f0 - f_top
	_clear_drops()
	# il Diario della spina
	var rows: Array = m.cuore_desto.rows("")
	var det: String = m.cuore_desto.detail()
	# com'era
	if had == 0:
		ch.stats.erase("risveglio_cuore")
	else:
		ch.stats["risveglio_cuore"] = had
	if v0 == null:
		m.world_meta.erase("vigore")
	else:
		m.world_meta["vigore"] = v0
	m.cuore_desto.apply()
	var ok := before.is_empty() and at6 == ["corallite"] and at12.has("primambra") and at12.size() >= 3 and at30 == ["memorite"] \
		and spine == ["corallite"] and rare > 1.0 and aiu1 == aiu0 + 1 and f_top == 0 and f_deep > 5 and f_deep < 50 \
		and not rows.is_empty() and det.contains("corallite") and det.contains("fase")
	print("spina, il Risveglio: prima %s, vigore 6 %s, 12 %s, 30 %s; antiche ×%.2f; Aiuole %d → %d; corallite scavando 400 volte: in superficie %d, nelle Caverne %d; Diario «%s»" % [
		str(before), str(at6), str(at12), str(at30), rare, aiu0, aiu1, f_top, f_deep, String(rows[0][1]) if not rows.is_empty() else "?"])
	if not ok:
		print("ATTENZIONE: il Risveglio del Cuore non va")


func _clear_drops() -> void:
	var ids := {}
	for g in SpineData.METALS:
		ids[String(SpineData.METALS[g]["raw"]["id"])] = true
	for d in m.drops._items.duplicate():
		if ids.has(String(d["id"])):
			(d["node"] as Node).queue_free()
			m.drops._items.erase(d)


## Voce 364: la Linfa del Cuore alza la Vita massima per sempre.
func heart_gift() -> void:
	var ch: Character = m.character
	var hp0: int = m.vitals.hp_max
	var extra0 := ch.vita_extra
	var n0 := int(ch.stats.get("doni_linfa_cuore", 0))
	ch.bisaccia.add("linfa_cuore", 1)
	var ok := Gifts.absorb(m, "linfa_cuore")
	var gained: int = m.vitals.hp_max - hp0
	ch.vita_extra = extra0
	m.vitals.hp_max = hp0
	m.vitals.refill()
	if n0 == 0:
		ch.stats.erase("doni_linfa_cuore")
	else:
		ch.stats["doni_linfa_cuore"] = n0
	print("spina, la Linfa del Cuore: assorbita %s, Vita massima +%d" % [ok, gained])
	if not ok or gained != 15:
		print("ATTENZIONE: la Linfa del Cuore non dà Vita")


## Voce 365: i Guardiani generati hanno una pericolosità simile (prima il più pericoloso toglieva venti volte più Vita del
## più mite).
func guardians() -> void:
	var a := []
	for k in 120:
		var d := GuardianGen.make("gg~%d" % (5000 + k * 7919))
		a.append(GuardianGen.threat(d["attacks"], d["p"], float(d["damage"])))
	a.sort()
	var spread := float(a[-2]) / maxf(float(a[1]), 0.01)
	print("spina, i Guardiani generati: pericolosità da %.1f a %.1f (mediana %.1f, rapporto %.2f)" % [a[0], a[-1], a[a.size() / 2], spread])
	if spread > 1.6:
		print("ATTENZIONE: i Guardiani generati sono troppo diversi tra loro")
