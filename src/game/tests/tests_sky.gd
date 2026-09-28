class_name TestsSky
extends RefCounted
## Roadmap 16 «Le Chiome del cielo» (gruppo «cielo»): le zone nel mondo e la fascia di una cella (voce 154), le isole,
## le radici pendenti e le correnti (155): il Germogliato sale con una corrente dalla superficie a un'isola bassa;
## foto 212_cielo_basso e 213_cielo_alto.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	await zones()
	await climb()
	await high()


## Voce 154: le zone e le fasce.
func zones() -> void:
	var z: Array = world.sky
	var ok := not z.is_empty()
	var bad := []
	for e in z:
		var x := (int(e["x0"]) + int(e["x1"])) / 2
		var low := SkyData.zone_at(world, x, int(e["base"]) - 3)
		var hi := SkyData.zone_at(world, x, int(e["split"]) - 3)
		var ground := SkyData.zone_at(world, x, int(world.surface[x]) - 1)
		if low != String(e["low"]) or hi != String(e["high"]) or ground != "" \
				or SkyData.band_at(world, x, int(e["base"]) - 3) != "basso" or SkyData.band_at(world, x, int(e["split"]) - 3) != "alto":
			bad.append(e)
	var plats := 0
	var sky_tiles := 0
	for e in z:
		for x in range(int(e["x0"]), int(e["x1"]), 3):
			for y in range(SkyData.TOP, int(e["base"])):
				if world.plat(x, y):
					plats += 1
				if world.solid(x, y) and world.tile(x, y) >= 50 and world.tile(x, y) <= 56:
					sky_tiles += 1
	var sky_cur := 0
	for cu in m.gravity.currents:
		if (cu as Dictionary).get("cielo", false):
			sky_cur += 1
	print("cielo: %d zone (%s), fasce sbagliate %d; tessere del cielo (una colonna su 3) %d, passerelle delle radici %d, correnti del cielo %d; in world_meta %s" % [
		z.size(), ", ".join(z.map(func(e: Dictionary) -> String: return "%s/%s" % [e["low"], e["high"]])), bad.size(),
		sky_tiles, plats, sky_cur, m.world_meta.has("cielo")])
	if not ok or not bad.is_empty() or sky_tiles < 200 or sky_cur < z.size() or not m.world_meta.has("cielo"):
		print("ATTENZIONE: il cielo non è come dovrebbe")


## Voce 155: una corrente dalla superficie porta il Germogliato su un'isola bassa.
func climb() -> void:
	var best: Dictionary = {}
	var dist := INF
	for cu in m.gravity.currents:
		var d: Dictionary = cu
		if d.get("cielo", false) and SkyData.band_at(world, int(d["x"]), int(d["y0"]) + 2) == "basso" \
				and int(d["y1"]) >= int(world.surface[int(d["x"])]) - 2:
			var dd := absf(float(d["x"]) - world.spawn.x)
			if dd < dist:
				dist = dd
				best = d
	if best.is_empty():
		print("ATTENZIONE: nessuna corrente dalla superficie al cielo basso")
		return
	var x := int(best["x"])
	var top := int(best["y0"]) + 2
	# da che parte è l'isola
	var side := 0
	for dx in range(1, 24):
		if world.solid(x - dx, top):
			side = -1
			break
		if world.solid(x + dx, top):
			side = 1
			break
	m.vitals.hp = m.vitals.hp_max
	m.snap_to(Vector2i(x, int(best["y1"])))
	await kit.frames(2)
	var p: Player = m.player
	var min_y := p.position.y
	var t := 0.0
	while t < 8.0:
		await kit.frames(1)
		t += m.get_process_delta_time()
		min_y = minf(min_y, p.position.y)
		if p.position.y < (top - 1) * S:
			p.auto_dir = float(side)
		if p.on_floor and p.position.y < (top + 1) * S:
			break
	p.auto_dir = 0.0
	var c: Vector2i = m.player_cell()
	var zone := SkyData.zone_at(world, c.x, c.y)
	await kit.seconds(0.6)
	var ok := p.on_floor and zone != "" and c.y <= top
	print("salita con la corrente (x %d, da %d a %d): cima raggiunta %d, sull'isola %s (cella %s, zona «%s», scritta «%s»)" % [
		x, int(best["y1"]), int(best["y0"]), int(min_y / S), "sì" if ok else "NO", c, zone, m.chiome.here])
	if not ok:
		print("ATTENZIONE: la corrente non porta sull'isola")
	await kit.save("212_cielo_basso")


## Il cielo alto: una foto su un'isola alta.
func high() -> void:
	for e in world.sky:
		var x0 := int(e["x0"]) + 20
		var x1 := int(e["x1"]) - 20
		for x in range(x0, x1, 2):
			for y in range(SkyData.TOP + 2, int(e["split"])):
				if world.solid(x, y + 1) and not world.solid(x, y) and not world.solid(x, y - 1) and world.tile(x, y + 1) >= 50:
					m.snap_to(Vector2i(x, y))
					m.boons.add("bagliore", 5.0)
					await kit.seconds(0.8)
					print("cielo alto: %s nella zona «%s»" % [Vector2i(x, y), SkyData.zone_at(world, x, y)])
					await kit.save("213_cielo_alto")
					return
	print("ATTENZIONE: nessuna isola alta dove posarsi")
