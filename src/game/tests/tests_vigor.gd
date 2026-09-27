class_name TestsVigor
extends RefCounted
## Prove del vigore senza tetto (voce 79): i gradi, le indoli nuove (le varianti di grado nascono solo nei mondi di
## grado alto, le corazzate hanno più Vita, le rigeneranti si rimarginano, le gemelle si dividono), le Schegge dei boss e
## la tempra al Maglio (livelli, tetto del grado, costo, danno e posti d'innesto in più, nome «+n»). Foto 146_gemelle.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var vg: Vigor = m.vigor
	var g0 := vg.grade
	var grades := [VigorData.grade(4), VigorData.grade(5), VigorData.grade(12), VigorData.grade(40)]
	# le indoli di grado: mai nel grado 0, spesso nel grado 4
	var rng := RandomNumberGenerator.new()
	rng.seed = 79
	var in0 := 0
	var in4 := 0
	var kinds := {}
	for k in 400:
		var a := String(FamiliesData.parts(FamiliesData.roll_variant("grumo_muschio", rng, "", 1.0, 0))[3])
		var b := String(FamiliesData.parts(FamiliesData.roll_variant("grumo_muschio", rng, "", 1.0, 4))[3])
		if VigorData.TEMPERS.has(a):
			in0 += 1
		if VigorData.TEMPERS.has(b):
			in4 += 1
			kinds[b] = true
	var base_hp := int(CreaturesData.get_data("grumo_muschio")["hp"])
	var armored := int(CreaturesData.get_data("grumo_muschio~~~corazzata")["hp"])
	# una rigenerante ferita si rimargina
	m.snap_to(world.spawn)
	await kit.seconds(0.2)
	var at: Vector2 = m.player.position + Vector2(40, -10)
	var rg: Creature = m.fauna.add("grumo_muschio~~~rigenerante", at)
	rg.calm = true
	rg.hp = maxi(rg.hp_max / 3, 1)
	var hp_a := rg.hp
	await kit.seconds(1.5)
	var hp_b := rg.hp
	# la gemella si divide
	var gm: Creature = m.fauna.add("grumo_muschio~~~gemella", at + Vector2(-120, 0))
	var n0: int = m.fauna.list.size()
	vg.grade = 3
	var kids: Array = vg.split(gm)
	await kit.seconds(0.4)
	await kit.save("146_gemelle")
	var twins: int = m.fauna.list.size() - n0
	# le Schegge di un boss
	var bag: Bisaccia = kit.bisaccia()
	var sh0 := bag.count("scheggia_vigore")
	rg.boss = true
	vg._on_killed(rg)
	rg.boss = false
	await kit.seconds(1.5)
	var shards := bag.count("scheggia_vigore") - sh0
	for c in [rg, gm] + kids:
		if is_instance_valid(c):
			m.fauna.list.erase(c)
			(c as Node).queue_free()
	# la tempra
	vg.grade = 2
	bag.add("scheggia_vigore", 60)
	var s := kit.hold("spada_radice")
	var before := Gear.stats(bag.slots[s])
	var slots0 := Gear.slots(bag.slots[s])
	var msgs := []
	for k in 5:
		msgs.append(vg.temper_hand())
	var after := Gear.stats(bag.slots[s])
	var lv := Vigor.level(bag.slots[s])
	var name := Gear.full_name(bag.slots[s])
	var slots1 := Gear.slots(bag.slots[s])
	vg.grade = 0
	var refused := vg.temper_hand()
	vg.grade = g0
	var dati: Dictionary = bag.slots[s].get("dati", {})
	dati.erase("tempra")
	bag.slots[s]["dati"] = dati
	bag.remove("scheggia_vigore", bag.count("scheggia_vigore"))
	print("vigore: gradi di 4, 5, 12, 40 = %s; indoli di grado su 400: grado 0 %d, grado 4 %d %s; corazzata %d Vita (specie %d); rigenerante %d → %d; gemelle nate %d; Schegge di un boss di grado 3: %d; tempra: livello %d, danno %.1f → %.1f, posti %d → %d, nome «%s», all'ultimo «%s», nel grado 0 «%s»" % [
		grades, in0, in4, kinds.keys(), armored, base_hp, hp_a, hp_b, twins, shards, lv, float(before["damage"]),
		float(after["damage"]), slots0, slots1, name, msgs[4], refused])
	if grades != [0, 1, 2, 8] or in0 > 0 or in4 < 60 or kinds.size() < 4 or armored < base_hp * 1.7 or hp_b <= hp_a \
			or twins != 2 or shards != VigorData.SHARD_BOSS * 3 or lv != 4 or float(after["damage"]) <= float(before["damage"]) \
			or slots1 != slots0 + 1 or not name.ends_with("+4") or not String(msgs[4]).contains("fino a +4") \
			or not refused.contains("vigore 5"):
		print("ATTENZIONE: il vigore senza tetto non funziona come dovrebbe")
