class_name TestsWater
extends RefCounted
## Prove dell'acqua (voce 73): l'acqua versata cade e si posa sul fondo senza perdersi; scavando la parete di una conca
## l'acqua esce; nell'acqua il Germogliato nuota (caduta lenta, sale tenendo il salto) e il respiro cala; il secchio
## raccoglie e versa; i mondi hanno conche, il gene Sommerso un mare; quanto costa un passo con tanta acqua in moto.
## Foto 137_acqua.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


## Una stanza d'aria chiusa (pareti di ardesia) con l'angolo in alto a sinistra in o.
func _box(o: Vector2i, w: int, h: int) -> void:
	for y in range(o.y - 1, o.y + h + 1):
		for x in range(o.x - 1, o.x + w + 1):
			var edge := y == o.y - 1 or y == o.y + h or x == o.x - 1 or x == o.x + w
			world.set_tile(x, y, TileDefs.STONE if edge else TileDefs.AIR)
			world.set_liq(x, y, 0, 0)
	m.view.refresh_rect(Rect2i(o - Vector2i(2, 2), Vector2i(w + 4, h + 4)))


func _volume(o: Vector2i, w: int, h: int) -> int:
	var n := 0
	for y in range(o.y, o.y + h):
		for x in range(o.x, o.x + w):
			n += world.liq(x, y)
	return n


func run() -> void:
	var lq: Liquids = m.liquids
	m.snap_to(world.spawn)                     # i liquidi scorrono solo vicino al Germogliato (`LiquidsData.WINDOW`)
	var base := Vector2i(world.spawn.x + 20, world.surface[world.spawn.x + 20] + 30)
	# 1. versata in alto, si posa sul fondo
	var o := base
	_box(o, 10, 8)
	for x in range(o.x + 3, o.x + 6):
		lq.pour(Vector2i(x, o.y), 8, LiquidsData.ACQUA)
	var v0 := _volume(o, 10, 8)
	for k in 200:
		lq.step()
	var v1 := _volume(o, 10, 8)
	var bottom := 0
	for x in range(o.x, o.x + 10):
		bottom += world.liq(x, o.y + 7)
	var top_empty := world.liq(o.x + 4, o.y) == 0
	# 2. la parete si apre: l'acqua esce nella stanza accanto
	var o2 := Vector2i(o.x + 11, o.y)
	_box(o2, 8, 8)
	world.set_tile(o.x + 10, o.y + 7, TileDefs.STONE)
	lq.wake(o.x + 9, o.y + 7)
	world.set_tile(o.x + 10, o.y + 7, TileDefs.AIR)        # come uno scavo: `on_change` risveglia l'acqua
	for k in 300:
		lq.step()
	var out := _volume(o2, 8, 8)
	# 3. nuotare e trattenere il respiro
	var o3 := Vector2i(o.x, o.y + 12)
	_box(o3, 12, 10)
	for y in range(o3.y + 1, o3.y + 10):
		for x in range(o3.x, o3.x + 12):
			world.set_liq(x, y, 8, LiquidsData.ACQUA)
	m.view.refresh_rect(Rect2i(o3, Vector2i(12, 10)))
	var p: Player = m.player
	m.snap_to(o3 + Vector2i(6, 6))
	lq.breath = LiquidsData.BREATH
	await kit.seconds(1.2)
	var swim: bool = p.in_liquid
	var slow_fall: bool = p.vel.y <= LiquidsData.SWIM_FALL + 1.0
	var breath_down: bool = lq.breath < LiquidsData.BREATH
	m.fauna.add("pesce_lume", Vector2(o3 + Vector2i(3, 5)) * 16.0)
	m.boons.add("bagliore", 10.0)
	await kit.seconds(0.4)
	await kit.save("137_acqua")
	p.auto_jump = true
	var y0: float = p.position.y
	await kit.seconds(0.5)
	var went_up: bool = p.position.y < y0 - 8.0
	p.auto_jump = false
	# 4. il secchio
	var b := kit.bisaccia()
	b.add("secchio", 1)
	var hx := o3 + Vector2i(2, 8)
	m.snap_to(o3 + Vector2i(3, 6))
	var got: bool = lq.scoop(hx)
	var full: bool = b.count("secchio_acqua") == 1
	var dry := Vector2i(o.x + 5, o.y + 2)
	m.snap_to(Vector2i(o.x + 3, o.y + 5))
	var poured: bool = lq.empty_bucket(dry, "secchio_acqua")
	m.snap_to(world.spawn)
	# 5. i mondi: conche ovunque, il mare con Sommerso
	var w1 := World.new()
	WorldGen.generate(w1, 3131, 1600, 900, {"geni": ["lanterna", "sorgenti"], "vigore": 2})
	var w2 := World.new()
	WorldGen.generate(w2, 3131, 1600, 900, {"geni": ["lanterna", "sommerso"], "vigore": 2})
	var sea := 0                               # quante colonne hanno il mare sopra la superficie (in percentuale)
	for x in w2.w:
		if w2.liq(x, w2.surface[x] - 1) > 0:
			sea += 1
	sea = roundi(100.0 * sea / w2.w)
	# 6. quanto costa: una cascata grande
	var o4 := Vector2i(o.x - 60, o.y)
	_box(o4, 40, 20)
	for y in range(o4.y, o4.y + 10):
		for x in range(o4.x, o4.x + 40):
			world.set_liq(x, y, 8, LiquidsData.ACQUA)
			lq.wake(x, y)
	var t0 := Time.get_ticks_usec()
	for k in 30:
		lq.step()
	var per := (Time.get_ticks_usec() - t0) / 1000.0 / 30.0
	print("acqua: versata %d → %d (fondo %d, cima vuota %s); aperta la parete ne escono %d; nuota %s, caduta lenta %s, sale %s, respiro cala %s; secchio %s/%s/%s; conche con Sorgenti %d, mare con Sommerso sul %d%% delle colonne; un passo con 400 celle in moto %.2f ms" % [
		v0, v1, bottom, "sì" if top_empty else "NO", out, "sì" if swim else "NO", "sì" if slow_fall else "NO",
		"sì" if went_up else "NO", "sì" if breath_down else "NO", got, full, poured, int(w1.gen_notes.get("laghi", 0)), sea, per])
	if v1 != v0 or not top_empty or out <= 0 or not swim or not went_up or not breath_down or not (got and full and poured) \
			or int(w1.gen_notes.get("laghi", 0)) < 10 or sea < 70 or per > 6.0:
		print("ATTENZIONE: l'acqua non funziona come dovrebbe")
