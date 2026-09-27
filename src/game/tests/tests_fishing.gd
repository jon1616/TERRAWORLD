class_name TestsFishing
extends RefCounted
## La pesca (Roadmap 14 «Le acque vive»). Voce 118: gli stagni di superficie nel mondo di prova, lo specchio riconosciuto
## al momento (`WaterBody`), un laghetto fatto a mano che vale come uno naturale, una pozzanghera troppo piccola.
## Gruppo «pesca».

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await bodies()


func bodies() -> void:
	var w: World = m.world
	# 1. uno stagno naturale in superficie
	var pond := {}
	var ponds := 0
	var x := 0
	while x < w.w:
		var y := w.surface[x]
		if w.liq(x, y) > 0:
			var b := WaterBody.at(w, Vector2i(x, y))
			if int(b["stratum"]) == 0:
				ponds += 1
				if pond.is_empty() or absi(x - w.spawn.x) < absi(int(pond["x0"]) - w.spawn.x):
					pond = b
				x = int(b["x1"]) + 1
				continue
		x += 1
	print("stagni di superficie nel mondo di prova: %d; il più vicino: %s" % [ponds, WaterBody.describe(pond)])
	if not pond.is_empty():
		var c: Vector2i = pond["center"]
		m.snap_to(Vector2i(int(pond["x0"]) - 6, w.surface[int(pond["x0"]) - 6] - 1))
		await kit.frames(6)
		await kit.save("180_stagno")
	# 2. un laghetto fatto a mano: una conca scavata e riempita
	var spot := kit.flat_spot(w.spawn + Vector2i(70, 0), 17)
	var made := {}
	var saved := []
	if spot.x < 0:
		print("ATTENZIONE: nessun posto piano per il laghetto fatto a mano")
	else:
		for xx in range(spot.x - 8, spot.x + 9):
			for yy in range(spot.y + 1, spot.y + 6):
				saved.append([xx, yy, w.tile(xx, yy)])
				var edge := absi(xx - spot.x) == 8 or yy == spot.y + 5
				w.set_tile(xx, yy, TileDefs.STONE if edge else TileDefs.AIR)
				w.set_liq(xx, yy, 0 if edge else 8, LiquidsData.ACQUA)
		made = WaterBody.at(w, spot + Vector2i(0, 2))
		print("laghetto fatto a mano: %s" % WaterBody.describe(made))
	# 3. una pozzanghera: troppo piccola
	var q := Vector2i(w.spawn.x + 300, 20)
	w.set_liq(q.x, q.y, 8, LiquidsData.ACQUA)
	w.set_liq(q.x + 1, q.y, 8, LiquidsData.ACQUA)
	var puddle := WaterBody.at(w, q)
	w.set_liq(q.x, q.y, 0, 0)
	w.set_liq(q.x + 1, q.y, 0, 0)
	print("pozzanghera di due celle: %s" % WaterBody.describe(puddle))
	# rimette il terreno del laghetto com'era
	for s in saved:
		w.set_tile(int(s[0]), int(s[1]), int(s[2]))
		w.set_liq(int(s[0]), int(s[1]), 0, 0)
	if spot.x >= 0:
		m.view.refresh_around(spot)
	if ponds == 0 or pond.is_empty() or not pond["ok"] or made.is_empty() or not made["ok"] or int(made["stratum"]) != 0 \
			or puddle.is_empty() or puddle["ok"]:
		print("ATTENZIONE: gli specchi d'acqua non si riconoscono come dovrebbero")
