class_name TestsGuardians
extends RefCounted
## Prove dei Guardiani dei mondi oltre i portali (voce 19): con il vigore 2 si sveglia la Regina delle Spore, con il 3
## il Colosso d'Ardesia (foto 37 e 38); sconfitti lasciano il loro materiale, curati l'altro; i lingotti dei gradi 5 e
## 6 si fabbricano da entrambi.

var kit: TestKit
var m: Node2D
var g: Guardian


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m
	g = tk.m.guardian


func _reset(vigor: int) -> void:
	m.fauna.clear()
	m.world_meta["vigore"] = vigor
	m.world_meta["guardiano"] = "dorme"
	g.state = "dorme"
	g.boss = null
	m.world.stations[g.cuore] = "cuore_mondo"
	m.view.remove_station(g.cuore)
	m.view.add_station(g.cuore)


func run() -> void:
	if g.cuore.x < 0:
		return
	m.combat.god = true
	var names := {2: "37_regina_spore", 3: "38_colosso_ardesia"}
	for v in [2, 3]:
		_reset(v)
		m.snap_to(g.cuore + Vector2i(-10, 2))
		await kit.seconds(2.5)
		g.lore.visible = false
		var id: String = g.boss.id if g.boss != null else "(nessuno)"
		print("vigore %d: si sveglia %s (Vita %d)" % [v, id, g.boss.hp_max if g.boss != null else 0])
		await kit.save(names[v])
		if g.boss != null:
			var before: int = m.drops.count()
			m.combat._strike(g.boss, 999999, m.player.position.x, 1.0)
			await kit.seconds(0.5)
			g.lore.visible = false
			print("vigore %d sconfitto: stato %s, oggetti a terra %d → %d" % [v, m.world_meta["guardiano"], before, m.drops.count()])
	# i lingotti dei gradi nuovi, dalle due strade
	var b: Bisaccia = m.character.bisaccia
	b.add("vuotite", 12)
	b.add("scheggia_vuoto", 8)
	b.add("cristallo_linfa", 4)
	for extra in ["velo_spora", "polline_regina", "nucleo_colosso", "pietra_battente"]:
		b.add(extra, 1)
	var made := []
	for out in ["lingotto_vuoto", "lingotto_stellare"]:
		for r in RecipesData.making(out):
			if Crafting.craft(r, b):
				made.append(out)
	print("lingotti dei gradi 5 e 6: %s" % [made])
	_reset(1)
	m.world_meta["guardiano"] = "curato"
	g.state = "curato"
	m.combat.god = false
