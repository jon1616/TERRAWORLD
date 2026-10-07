class_name TestsLands
extends RefCounted
## La terra dei mondi (Roadmap 52, voci 412-416). Gruppo «terre».
## Ogni bioma ha la sua terra e la sua roccia (e il mondo di prova le ha davvero, senza sabbie sospese nel vuoto); la
## sabbia frana, il ghiaccio scivola, il fango appiccica, la neve attutisce le cadute, la cenere calda scalda nel freddo,
## la terra grassa e il concime fanno crescere l'orto, la pietra nera regge le esplosioni, la pietra fossile ha i fossili.
## Foto 260_terre_<bioma>: la sezione della terra di alcuni biomi, senza il buio.

var kit: TestKit
var m: Node2D
var res := {}


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	data()
	world_check()
	await falls()
	await floors()
	soft_and_warm()
	garden_and_fossils()
	blast()
	await photos()
	print("terre: %s" % str(res))
	if not res.values().all(func(x: Variant) -> bool: return x == true):
		print("ATTENZIONE: la terra dei mondi non va come dovrebbe")


static func tile_of(id: String) -> int:
	return int(ItemsData.get_item(id).get("place", 0))


## Ogni bioma di superficie (tranne la foresta, che tiene l'humus) ha la sua terra; ogni terra che frana ha la roccia
## che la regge; ogni tessera nuova lascia un oggetto che esiste.
func data() -> void:
	var soils: Dictionary = BiomesData.pack("soils")
	var missing := []
	for b in BiomesData.BIOMES:
		if String(b["id"]) != "foresta" and not soils.has(String(b["id"])):
			missing.append(String(b["id"]))
	var kinds := {}
	var bad := []
	for t in TileDefs.KIND:
		var k := TileDefs.kind_of(int(t))
		kinds[k] = int(kinds.get(k, 0)) + 1
		var drop := String(TileDefs.DROP.get(int(t), ""))
		if drop != "" and not ItemsData.has(drop):
			bad.append(drop)
	res["dati"] = missing.is_empty() and bad.is_empty() and int(kinds.get("suolo", 0)) >= 15 and int(kinds.get("roccia", 0)) >= 14
	print("terre, i dati: tipi %s; biomi senza terra %s; oggetti che mancano %s" % [str(kinds), str(missing), str(bad)])


## Nel mondo di prova: ogni bioma presente ha la sua terra nelle sue colonne, e nessuna sabbia resta sospesa sul vuoto
## vicino alla superficie (poche: le stanze e le tane scavate dopo dal generatore, e le prove di prima).
func world_check() -> void:
	var w: World = m.world
	var soils: Dictionary = BiomesData.pack("soils")
	var found := {}
	var floating := 0
	for x in range(0, w.w, 3):
		var bid := String(BiomesData.BIOMES[w.biomes[x]]["id"])
		var want := int((soils.get(bid, {}) as Dictionary).get("suolo", 0))
		for y in range(maxi(w.surface[x], 0), mini(w.surface[x] + 40, w.h - 1)):
			var t := w.tile(x, y)
			if want > 0 and t == want:
				found[bid] = true
			if TileDefs.FALLS[t] == 1 and w.tile(x, y + 1) == TileDefs.AIR:
				floating += 1
	var lacking := []
	for x in range(0, w.w, 50):
		var bid := String(BiomesData.BIOMES[w.biomes[x]]["id"])
		if soils.has(bid) and soils[bid].has("suolo") and not found.has(bid) and not bid in lacking:
			lacking.append(bid)
	res["mondo"] = lacking.is_empty() and floating <= 40
	print("terre, nel mondo di prova: biomi con la loro terra %d %s, senza %s; sabbie sospese %d" % [found.size(), str(found.keys()),
		str(lacking), floating])


## Una sabbia posata nell'aria cade fino a terra.
func falls() -> void:
	var w: World = m.world
	var sand := tile_of("sabbia_ambra")
	var pc: Vector2i = m.player_cell()
	var q := Vector2i(-1, -1)
	for dx in range(6, 40):
		var x := pc.x + dx
		var s := w.surface[x]
		var clear := true
		for y in range(s - 8, s):
			if w.solid(x, y) or w.tree_at(Vector2i(x, y)).x >= 0 or not w.station_at(Vector2i(x, y)).is_empty() or w.liq(x, y) > 0:
				clear = false
				break
		if clear and w.solid(x, s):
			q = Vector2i(x, s - 7)
			break
	if q.x < 0:
		print("ATTENZIONE: nessun posto per la prova della sabbia")
		res["frana"] = false
		return
	w.set_tile(q.x, q.y, sand)
	m.view.refresh_around(q)
	m.living._on_placed(q, "sabbia_ambra")
	await kit.seconds(1.0)
	var landed := Vector2i(q.x, w.surface[q.x] - 1)
	var ok := w.tile(q.x, q.y) == TileDefs.AIR and w.tile(landed.x, landed.y) == sand
	if w.tile(landed.x, landed.y) == sand:
		w.set_tile(landed.x, landed.y, TileDefs.AIR)
		m.view.refresh_around(landed)
	res["frana"] = ok
	print("terre, la sabbia posata a %s nell'aria: è caduta fino a terra %s" % [str(q), ok])


## Sul ghiaccio ci si ferma tardi; sul fango si corre a fatica. Il Germogliato corre e lascia i tasti su tre pavimenti.
func floors() -> void:
	var w: World = m.world
	var spot := kit.flat_spot(m.player_cell(), 30)
	if spot.x < 0:
		spot = m.player_cell()
	kit.flatten(spot, 14)
	var y := spot.y + 1
	var x0 := spot.x - 13
	var slides := {}
	var speeds := {}
	var had_control: bool = m.player.control
	m.player.control = false
	for id in ["ardesia", "ghiaccio_antico", "fango_spore"]:
		var t := TileDefs.STONE if id == "ardesia" else tile_of(id)
		for x in range(x0, x0 + 27):
			w.set_tile(x, y, t)
		m.view.refresh_rect(Rect2i(x0 - 1, y - 1, 29, 3))
		m.snap_to(Vector2i(x0 + 1, spot.y))
		await kit.seconds(0.3)
		m.player.auto_dir = 1.0
		var xa: float = m.player.position.x
		await kit.seconds(0.6)
		speeds[id] = (m.player.position.x - xa) / 0.6
		m.player.auto_dir = 0.0
		var xr: float = m.player.position.x
		await kit.seconds(1.2)
		slides[id] = m.player.position.x - xr
	m.player.control = had_control
	for x in range(x0, x0 + 27):
		w.set_tile(x, y, TileDefs.STONE)
	m.view.refresh_rect(Rect2i(x0 - 1, y - 1, 29, 3))
	res["pavimenti"] = float(slides["ghiaccio_antico"]) > float(slides["ardesia"]) * 3.0 + 8.0 \
		and float(speeds["fango_spore"]) < float(speeds["ardesia"]) * 0.8
	print("terre, i pavimenti: dopo aver lasciato i tasti si scivola %s px; velocità %s px/s" % [str(slides), str(speeds)])


## La neve attutisce le cadute; la cenere calda scalda nel freddo.
func soft_and_warm() -> void:
	var w: World = m.world
	var pc: Vector2i = m.player_cell()
	var feet := Vector2i(pc.x, floori((m.player.position.y + Player.HALF.y + 2.0) / 16.0))
	var old := w.tile(feet.x, feet.y)
	var lost := {}
	for id in ["ardesia", "neve"]:
		w.set_tile(feet.x, feet.y, TileDefs.STONE if id == "ardesia" else tile_of(id))
		m.vitals.refill()
		var h0: int = m.vitals.hp
		m.life._on_landed(22.0)
		lost[id] = h0 - int(m.vitals.hp)
	m.vitals.refill()
	w.set_tile(feet.x, feet.y, old)
	var cold0: bool = m.harsh.near_warm(pc)
	var side := pc + Vector2i(2, 1)
	var old2 := w.tile(side.x, side.y)
	w.set_tile(side.x, side.y, tile_of("cenere_calda"))
	var cold1: bool = m.harsh.near_warm(pc)
	w.set_tile(side.x, side.y, old2)
	res["neve_cenere"] = int(lost["neve"]) < int(lost["ardesia"]) and int(lost["ardesia"]) > 0 and not cold0 and cold1
	print("terre, una caduta di 22 tessere toglie %s Vita; vicino alla cenere calda: %s (prima %s)" % [str(lost), cold1, cold0])


## La terra grassa fa crescere l'orto di più; il Concime toglie un terzo del tempo; la pietra fossile dà fossili veri.
func garden_and_fossils() -> void:
	var w: World = m.world
	var b: Bisaccia = m.character.bisaccia
	var c: Vector2i = m.player_cell() + Vector2i(2, 0)
	var had := w.crops.has(c)
	var old: Variant = w.crops.get(c)
	w.crops[c] = ["x", 90.0, false, 0]
	kit.make_room()
	b.add("concime", 1)
	var ok: bool = m.garden.fertilize(c, "concime")
	var left := float(w.crops[c][1])
	if had:
		w.crops[c] = old
	else:
		w.crops.erase(c)
	var fos: String = m.gene_mats.fossil()
	res["orto_fossili"] = ok and absf(left - 90.0 * (1.0 - Garden.FERTILIZE)) < 0.5 and b.count("concime") == 0 \
		and is_equal_approx(TileDefs.FERTILE[tile_of("terra_grassa")], 1.5) and ItemsData.has(fos) \
		and TileDefs.FOSSIL[tile_of("pietra_fossile")] > 0.0 and GroupsData.members("@terra").size() >= 15
	print("terre, l'orto: concime %s (restano %.1f s), terra grassa ×%.1f; un fossile dalla pietra: %s; terre nel gruppo %d" % [ok, left,
		TileDefs.FERTILE[tile_of("terra_grassa")], fos, GroupsData.members("@terra").size()])


## Un'esplosione rompe l'ardesia ma non la pietra nera.
func blast() -> void:
	var w: World = m.world
	var pc: Vector2i = m.player_cell() + Vector2i(14, -12)
	for y in range(pc.y - 2, pc.y + 3):
		for x in range(pc.x - 2, pc.x + 3):
			if w.tree_at(Vector2i(x, y)).x >= 0 or w.tree_at(Vector2i(x, y + 1)).x >= 0:
				pc += Vector2i(6, 0)
	var a := pc
	var n := pc + Vector2i(1, 0)
	var oa := w.tile(a.x, a.y)
	var on := w.tile(n.x, n.y)
	w.set_tile(a.x, a.y, TileDefs.STONE)
	w.set_tile(n.x, n.y, tile_of("pietra_nera"))
	m.throwing.explode(Vector2(a) * 16.0 + Vector2(16, 8), {"radius": 2.0, "power": 999, "damage": 0})
	var ok := w.tile(a.x, a.y) == TileDefs.AIR and w.tile(n.x, n.y) == tile_of("pietra_nera")
	w.set_tile(a.x, a.y, oa)
	w.set_tile(n.x, n.y, on)
	m.view.refresh_around(a)
	res["pietra_nera"] = ok
	print("terre, uno scoppio: l'ardesia salta, la pietra nera resta %s" % ok)


## La sezione della terra di alcuni biomi, senza il buio.
func photos() -> void:
	var w: World = m.world
	var back: Vector2 = m.player.position
	m.overlay.visible = false
	for bid in ["ambra", "brina", "palude", "brace", "ghiacciaio", "pietra"]:
		var bi := BiomesData.index_of(bid)
		var x := -1
		for xx in range(40, w.w - 40, 7):
			if w.biomes[xx] == bi and w.biomes[xx - 30] == bi and w.biomes[xx + 30] == bi:
				x = xx
				break
		if x < 0:
			continue
		m.snap_to(Vector2i(x, w.surface[x] - 1))
		await kit.seconds(0.6)
		await kit.save("260_terre_%s" % bid)
	m.overlay.visible = true
	m.snap_to(Vector2i(floori(back.x / 16.0), floori(back.y / 16.0)))
