class_name TestsLiquids
extends RefCounted
## Prove di Linfa e brace liquide (voce 74): l'acqua sulla brace fa la pietra di brace, la Linfa sulla brace il
## cristallo, l'acqua annacqua la Linfa; la brace brucia il Germogliato e le creature, la Linfa cura; la Linfa fa
## crescere più in fretta le colture vicine; i geni dei fiumi di brace e dei laghi di Linfa li fanno di liquido vero.
## Foto 138_liquidi.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _count(o: Vector2i, w: int, h: int, what: Callable) -> int:
	var n := 0
	for y in range(o.y, o.y + h):
		for x in range(o.x, o.x + w):
			if what.call(x, y):
				n += 1
	return n


func run() -> void:
	var lq: Liquids = m.liquids
	var tw := TestsWater.new(kit)
	m.snap_to(world.spawn)
	var base := Vector2i(world.spawn.x - 40, world.surface[world.spawn.x - 40] + 30)
	var r0 := lq.reactions
	# acqua sulla brace
	var o1 := base
	tw._box(o1, 8, 6)
	for x in range(o1.x, o1.x + 8):
		world.set_liq(x, o1.y + 5, 8, LiquidsData.BRACE)
	for x in range(o1.x + 2, o1.x + 5):
		lq.pour(Vector2i(x, o1.y), 8, LiquidsData.ACQUA)
	# Linfa sulla brace
	var o2 := base + Vector2i(10, 0)
	tw._box(o2, 8, 6)
	for x in range(o2.x, o2.x + 8):
		world.set_liq(x, o2.y + 5, 8, LiquidsData.BRACE)
	for x in range(o2.x + 2, o2.x + 5):
		lq.pour(Vector2i(x, o2.y), 8, LiquidsData.LINFA)
	# acqua accanto alla Linfa
	var o3 := base + Vector2i(20, 0)
	tw._box(o3, 8, 4)
	for x in range(o3.x, o3.x + 4):
		world.set_liq(x, o3.y + 3, 8, LiquidsData.LINFA)
		lq.wake(x, o3.y + 3)
	for x in range(o3.x + 4, o3.x + 8):
		lq.pour(Vector2i(x, o3.y + 3), 8, LiquidsData.ACQUA)
	var linfa0 := _count(o3, 8, 4, func(x: int, y: int) -> bool: return world.liq(x, y) > 0 and world.liq_type(x, y) == LiquidsData.LINFA)
	for k in 240:
		lq.step()
	var stone := _count(o1, 8, 6, func(x: int, y: int) -> bool: return world.tile(x, y) == TileDefs.PIETRA_BRACE)
	var crys := _count(o2, 8, 6, func(x: int, y: int) -> bool: return world.tile(x, y) == TileDefs.CRYSTAL)
	var linfa1 := _count(o3, 8, 4, func(x: int, y: int) -> bool: return world.liq(x, y) > 0 and world.liq_type(x, y) == LiquidsData.LINFA)
	# la brace brucia, la Linfa cura
	var o4 := base + Vector2i(32, 0)
	tw._box(o4, 6, 5)
	for y in range(o4.y + 1, o4.y + 5):
		for x in range(o4.x, o4.x + 3):
			world.set_liq(x, y, 8, LiquidsData.BRACE)
		for x in range(o4.x + 3, o4.x + 6):
			world.set_liq(x, y, 8, LiquidsData.LINFA)
	m.view.refresh_rect(Rect2i(o4, Vector2i(6, 5)))
	m.vitals.refill()
	var hp0: int = m.vitals.hp
	m.snap_to(o4 + Vector2i(1, 3))
	await kit.seconds(1.2)
	var burnt: bool = m.vitals.hp < hp0
	var hp1: int = m.vitals.hp
	m.snap_to(o4 + Vector2i(4, 3))
	await kit.seconds(1.6)
	var healed: bool = m.vitals.hp > hp1
	var cr: Creature = m.fauna.add("grumo_muschio", Vector2(o4 + Vector2i(1, 3)) * 16.0)
	var chp := cr.hp
	m.boons.add("bagliore", 10.0)
	await kit.seconds(1.2)
	await kit.save("138_liquidi")
	var creature_burnt: bool = not is_instance_valid(cr) or cr.hp < chp
	if is_instance_valid(cr):
		m.fauna.kill_quietly(cr)
	m.vitals.refill()
	m.snap_to(world.spawn)
	# le colture vicino alla Linfa
	var near := o4 + Vector2i(4, 0)
	var far := world.spawn + Vector2i(0, -2)
	world.crops[near] = ["rugiada", 100.0, false]
	world.crops[far] = ["rugiada", 100.0, false]
	m.garden.grow(10.0)
	var g_near := float(world.crops[near][1])
	var g_far := float(world.crops[far][1])
	world.crops.erase(near)
	world.crops.erase(far)
	# i geni: fiumi e laghi veri
	var ws: Array[World] = await kit.gen_many([[5151, 1600, 900, {"geni": ["lanterna", "fiumi_brace"], "vigore": 3}], [5151, 1600, 900, {"geni": ["lanterna", "laghi_linfa"], "vigore": 3}]])      # insieme, in parallelo
	var w1 := ws[0]
	var w2 := ws[1]
	var brace := 0
	var linfa := 0
	for i in range(0, w1.liquid.size(), 3):
		if w1.liquid[i] & 15 > 0 and (w1.liquid[i] >> 4) == LiquidsData.BRACE:
			brace += 3
	for i in range(0, w2.liquid.size(), 3):
		if w2.liquid[i] & 15 > 0 and (w2.liquid[i] >> 4) == LiquidsData.LINFA:
			linfa += 3
	print("liquidi: reazioni %d; pietra di brace %d, cristallo %d, Linfa annacquata %d → %d; brace brucia %s, Linfa cura %s, creatura bruciata %s; coltura vicino alla Linfa %.0f s, lontano %.0f s; fiumi di brace ~%d celle, laghi di Linfa ~%d" % [
		lq.reactions - r0, stone, crys, linfa0, linfa1, "sì" if burnt else "NO", "sì" if healed else "NO",
		"sì" if creature_burnt else "NO", g_near, g_far, brace, linfa])
	if stone == 0 or crys == 0 or linfa1 >= linfa0 or not burnt or not healed or not creature_burnt or g_near >= g_far \
			or brace < 500 or linfa < 300:
		print("ATTENZIONE: Linfa e brace liquide non funzionano come dovrebbero")
