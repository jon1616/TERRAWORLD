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
	await moving()


## Due conche vuote affiancate su terreno piano vicino a c: [sinistra, destra] (i centri della prima riga), e ciò che
## c'era prima (per rimetterlo). Ogni conca è larga 11 e profonda 4, con il bordo di pietra.
func _basins(c: Vector2i, saved: Array) -> Array:
	var w: World = m.world
	var out := []
	for k in 2:
		var cx := c.x - 8 + k * 16
		for xx in range(cx - 6, cx + 7):
			for yy in range(c.y + 1, c.y + 7):
				saved.append([xx, yy, w.tile(xx, yy)])
				var edge := absi(xx - cx) == 6 or yy == c.y + 6
				w.set_tile(xx, yy, TileDefs.STONE if edge else TileDefs.AIR)
				w.set_liq(xx, yy, 0, 0)
		out.append(Vector2i(cx, c.y + 1))
	m.view.refresh_around(c)
	return out


func _restore(saved: Array) -> void:
	var w: World = m.world
	for s in saved:
		w.set_tile(int(s[0]), int(s[1]), int(s[2]))
		w.set_liq(int(s[0]), int(s[1]), 0, 0)


## Voce 119: l'otre raccoglie da un bacino e versa nell'altro senza perdere liquido; una fonte riempie una conca vuota
## finché non diventa pescabile.
func moving() -> void:
	var w: World = m.world
	var b: Bisaccia = m.character.bisaccia
	var spot := kit.flat_spot(w.spawn + Vector2i(-60, 0), 8)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto piano per le prove dei liquidi")
		return
	kit.flatten(spot, 16)
	var saved := []
	var bs := _basins(spot, saved)
	m.snap_to(spot + Vector2i(0, -1))
	for yy in range(bs[0].y, bs[0].y + 5):
		for xx in range(bs[0].x - 5, bs[0].x + 6):
			w.set_liq(xx, yy, 8, LiquidsData.ACQUA)
	var before := WaterBody.at(w, bs[0])
	# l'otre in mano
	kit.make_room()
	b.add("otre_legnoferro", 1)
	kit.hold("otre_legnoferro")
	var took: bool = m.liquid_tools.use_container(bs[0] + Vector2i(4, 1), "otre_legnoferro")
	var d: Dictionary = b.data_at(m.hud.sel)
	var after := WaterBody.at(w, bs[0] + Vector2i(0, 4))
	var poured: bool = m.liquid_tools.use_container(bs[1] + Vector2i(-5, 1), "otre_legnoferro")
	for k in 60:
		m.liquids.step()
	var there := WaterBody.at(w, bs[1] + Vector2i(0, 4))
	var kept := not there.is_empty() and absf(float(there["volume"]) + float(after["volume"]) - float(before["volume"])) < 0.2
	print("otre: raccolto %s (%s), versato %s; nel bacino di prima %.1f → %.1f celle, nell'altro %.1f: niente perso %s" % [
		"sì" if took else "NO", LiquidTools.content_text("otre_legnoferro", d), "sì" if poured else "NO",
		float(before["volume"]), float(after.get("volume", 0.0)), float(there.get("volume", 0.0)), "sì" if kept else "NO"])
	# la fonte: nella conca di destra, svuotata, versa finché non è pescabile
	for yy in range(bs[1].y, bs[1].y + 5):
		for xx in range(bs[1].x - 5, bs[1].x + 6):
			w.set_liq(xx, yy, 0, 0)
	var fo := Vector2i(bs[1].x - 8, spot.y - 1)            # accanto alla conca, sul terreno spianato
	w.stations[fo] = "fonte_acqua"
	m.view.add_station(fo)
	var mouth: Vector2i = m.liquid_tools.mouth(fo, "fonte_acqua")
	var t0 := Time.get_ticks_msec()
	var filled := {}
	for k in 3000:
		m.liquid_tools.tick()
		m.liquids.step()
		filled = WaterBody.at(w, bs[1] + Vector2i(0, 4))
		if not filled.is_empty() and filled["ok"]:
			break
	await kit.frames(4)
	await kit.save("181_fonte")
	var full_ok := not filled.is_empty() and bool(filled["ok"])
	print("fonte di muschio: bocca %s, la conca vuota diventa pescabile %s (%s, %d ms)" % [mouth, "sì" if full_ok else "NO",
		WaterBody.describe(filled), Time.get_ticks_msec() - t0])
	w.stations.erase(fo)
	m.view.remove_station(fo)
	_restore(saved)
	m.view.refresh_around(spot)
	if not took or not poured or not kept or not full_ok:
		print("ATTENZIONE: i liquidi non si spostano come dovrebbero")


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
