class_name TestsAliveBuild
extends RefCounted
## Roadmap 15 «Il mondo abitato», le prove delle costruzioni (le chiama `TestsAlive`, gruppo «vivo»): i costrutti
## (voce 128), gli strumenti del costruttore (140), gli arredi (141), le stanze (142), le case (143), il riparo (144),
## i progetti dei Seminatori (145), gli ospiti (146), la mandria che abita (148).

var kit: TestKit
var m: Node2D
var wid := ""                                    # una creatura semplice (la sceglie `TestsAlive.wiles`)
var _hall := Vector2i(-1, -1)                    # la sala dei trofei della prova dei progetti (per gli ospiti)
var _bed := Vector2i(-1, -1)                     # il letto della stanza della prova delle stanze (per le case)


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


## Voce 128: un muretto di costrutti (tutte le forme, tre materiali) con le pareti costruite dietro; uno si scava e
## lascia il suo oggetto; il mondo salvato e ricaricato li tiene.
func builds() -> void:
	var w: World = m.world
	var spot := kit.flat_spot(w.spawn + Vector2i(-40, 0), 12)
	if spot.x < 0:
		spot = m.player_cell()                  # (lo spiana `flatten` qui sotto)
	kit.flatten(spot, 14)
	var nf := BuildData.FORMS.size()
	var placed := 0
	var mats := [0, 1, 2, 6, 12, 21, 23, 25]              # un campione: ardesia, lanterna, ambra, brace, Linfa, osso, cera, squame
	for r in mats.size():
		var mi: int = mats[r]
		for fi in nf:
			var c := Vector2i(spot.x - 4 + fi, spot.y - 2 - r * 2)
			for dy in 2:
				var q := c + Vector2i(0, -dy) if dy == 1 else c
				w.set_build(q.x, q.y, mi * nf + fi + 1)
				if fi < 3 and w.inside(q.x - 5, q.y) and not w.solid(q.x - 5, q.y):
					w.walls[q.y * w.w + q.x - 5] = BuildData.WALL_BASE + mi   # le pareti costruite, a sinistra
				placed += 1
	for x in range(spot.x - 6, spot.x + 8):
		for y in range(spot.y - 18, spot.y + 1):
			m.view.refresh_around(Vector2i(x, y))
	w.stations[Vector2i(spot.x + 8, spot.y - 1)] = "scalpellino"   # voce 139: il Banco dello scalpellino accanto
	m.view.add_station(Vector2i(spot.x + 8, spot.y - 1))
	m.snap_to(Vector2i(spot.x + 6, spot.y))
	m.light.dirty = true
	await kit.seconds(0.4)
	await kit.save("191_costrutti")
	m.view.remove_station(Vector2i(spot.x + 8, spot.y - 1))
	w.stations.erase(Vector2i(spot.x + 8, spot.y - 1))
	# si scava: lascia il suo oggetto
	var c0 := Vector2i(spot.x - 4, spot.y - 2)
	var k0 := w.build_at(c0.x, c0.y)
	var want := BuildData.item_of(k0)
	var n0: int = m.drops._items.size()
	m.actions.break_tile(c0)
	var dropped := false
	for d in m.drops._items.slice(n0):
		dropped = dropped or String(d["id"]) == want
	var gone := w.build_at(c0.x, c0.y) == 0 and w.tile(c0.x, c0.y) == TileDefs.AIR
	# salvato e ricaricato
	var saved := WorldSave.save(w, "prova_costrutti", {"nome": "costrutti"})
	var back := WorldSave.load_world("prova_costrutti")
	var same: bool = saved == OK and back != null and back.build == w.build
	WorldSave.delete("prova_costrutti")
	var vt := TileDefs.COSTRUTTO_T in [w.tile(spot.x + 4, spot.y - 2)]
	print("costrutti: %d piazzati (%d tipi), scavato lascia «%s» %s, tolto %s, salvati e ricaricati %s, vetrata trasparente %s" % [
		placed, BuildData.kinds().size(), want, "sì" if dropped else "NO", "sì" if gone else "NO", "sì" if same else "NO",
		"sì" if vt else "NO"])
	if not dropped or not gone or not same or not vt:
		print("ATTENZIONE: i costrutti non vanno come dovrebbero")


## Voce 140: posare in linea e ad area, scolpire, tingere, copiare e rifare un progetto (e i colori si salvano).
func builder() -> void:
	var w: World = m.world
	var spot := kit.flat_spot(w.spawn + Vector2i(-70, 0), 12)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto piano per la prova degli strumenti del costruttore")
		return
	kit.flatten(spot, 24)
	m.snap_to(spot)
	await kit.frames(3)
	var bt: BuilderTools = m.builder
	var b: Bisaccia = m.character.bisaccia
	var id := "costr_mattoni_ardesia"
	b.add(id, 60)
	m.hud.sel = kit.hold(id)
	# una linea di 5 sul pavimento, verso destra
	var a := spot + Vector2i(1, 0)
	var line := bt.fill(bt._cells(a, a + Vector2i(4, 0), false), id)
	# un'area 3 × 2 sopra la linea
	var area := bt.fill(bt._cells(spot + Vector2i(2, -1), spot + Vector2i(4, -2), true), id)
	# scolpire: la forma dopo
	var k0 := w.build_at(a.x, a.y)
	var sc := bt.sculpt(a) and w.build_at(a.x, a.y) == k0 + 1
	# tingere
	b.add("tintura_rossa", 5)
	m.hud.sel = kit.hold("tintura_rossa")
	var dy := bt.dye(spot + Vector2i(3, -1), "tintura_rossa", false) and w.block_tint(spot.x + 3, spot.y - 1) == 1
	b.add("tintura_blu", 5)
	m.hud.sel = kit.hold("tintura_blu")
	bt.dye(spot + Vector2i(4, -2), "tintura_blu", false)
	await kit.seconds(0.3)
	await kit.save("196_costruttore")
	# il progetto: copia l'area e la rifà più in là
	b.add("tavola_progetto", 1)
	m.hud.sel = kit.hold("tavola_progetto")
	var copied := bt.copy(Rect2i(spot + Vector2i(1, -2), Vector2i(5, 3)))
	var need := BuilderTools.needs(bt._plan())
	for nid in need:
		b.add(String(nid), int(need[nid]))
	var dest := spot + Vector2i(-8, -3)
	var built_ok := bt.build_plan(dest)
	var same := 0
	for e in bt._plan()["cells"]:
		if int(e[2]) > 0 and w.build_at(dest.x + int(e[0]), dest.y + int(e[1])) == int(e[2]):
			same += 1
	var saved := WorldSave.save(w, "prova_tinte", {"nome": "tinte"})
	var back := WorldSave.load_world("prova_tinte")
	var kept: bool = saved == OK and back != null and back.tint == w.tint
	WorldSave.delete("prova_tinte")
	await kit.seconds(0.2)
	await kit.save("197_progetto")
	print("costruttore: in linea %d su 5, ad area %d su 6, scolpito %s, tinto %s, progetto copiato %d celle e rifatto %s (%d blocchi uguali), colori salvati %s" % [
		line, area, "sì" if sc else "NO", "sì" if dy else "NO", copied, "sì" if built_ok else "NO", same, "sì" if kept else "NO"])
	if line < 5 or area < 6 or not sc or not dy or copied < 8 or not built_ok or same < 8 or not kept:
		print("ATTENZIONE: gli strumenti del costruttore non vanno come dovrebbero")


## Voce 141: una stanza di arredi in serie (tutte le forme di un materiale, più qualche altro materiale): si
## piazzano, il letto è un letto vero, l'armadio tiene gli oggetti; foto.
func furniture() -> void:
	var w: World = m.world
	var spot := kit.flat_spot(w.spawn + Vector2i(-110, 0), 20)
	if spot.x < 0:
		spot = m.player_cell()
	kit.flatten(spot, 30)
	var x := spot.x - 14
	var placed := 0
	for mat in ["ambra", "lanterna"]:
		for f in FurnitureData.FORMS:
			var sid := FurnitureData.id_of(String(f["id"]), mat)
			var sz: Array = f["size"]
			var o := Vector2i(x, spot.y - int(sz[1]) + 1)
			if String(f["id"]) == "lanterna":
				o.y -= 3
			elif String(f["id"]) in ["finestra", "quadro"]:
				o.y -= 2
			w.stations[o] = sid
			m.view.add_station(o)
			placed += 1
			x += int(sz[0]) + (0 if mat == "ambra" else 0)
		x = spot.x - 14
		spot.y -= 5
		for dx in range(-16, 30):
			w.set_tile(spot.x + dx, spot.y + 1, TileDefs.STONE)
			m.view.refresh_around(Vector2i(spot.x + dx, spot.y + 1))
	spot.y += 10
	m.snap_to(spot + Vector2i(2, 0))
	m.light.dirty = true
	await kit.seconds(0.4)
	await kit.save("201_arredi")
	# il letto della serie è un letto; l'armadio tiene 24 oggetti
	var bed_o := Vector2i(-1, -1)
	var wardrobe := Vector2i(-1, -1)
	for o in w.stations:
		if String(w.stations[o]) == FurnitureData.id_of("letto", "ambra"):
			bed_o = o
		if String(w.stations[o]) == FurnitureData.id_of("armadio", "ambra"):
			wardrobe = o
	var bed_ok: bool = bed_o.x >= 0 and m.masonry.use_bed(bed_o) and m.masonry.respawn_point() != w.spawn
	var slots: int = w.chest_at(wardrobe).slots.size() if wardrobe.x >= 0 else 0
	m.world_meta.erase("letti")
	print("arredi: %d piazzati (%d forme × 2 materiali), il letto è un letto %s, l'armadio tiene %d oggetti" % [placed,
		FurnitureData.FORMS.size(), "sì" if bed_ok else "NO", slots])
	if not bed_ok or slots != 24:
		print("ATTENZIONE: gli arredi in serie non vanno come dovrebbero")


## Voce 142: una stanza chiusa (blocchi, pareti, porta) si riconosce; col letto è una casa, con due banchi un
## laboratorio, con tre trofei in un armadio una sala dei trofei (più danno contro quelle famiglie); il comfort cresce
## con gli arredi.
func rooms() -> void:
	var w: World = m.world
	var spot := kit.flat_spot(w.spawn + Vector2i(130, 0), 16)
	if spot.x < 0:
		spot = m.player_cell() + Vector2i(30, 0)
	kit.flatten(spot, 20)
	var x0 := spot.x - 5
	var y1 := spot.y                                   # la riga del pavimento libero più bassa
	var y0 := y1 - 3
	var k_wall := 1 + 0 * BuildData.FORMS.size() + 1  # mattoni d'ardesia
	for y in range(y0 - 1, y1 + 2):
		for x in range(x0 - 1, x0 + 11):
			var inside := x >= x0 and x < x0 + 10 and y >= y0 and y <= y1
			if inside:
				w.set_tile(x, y, TileDefs.AIR)
				w.walls[y * w.w + x] = BuildData.WALL_BASE
			else:
				w.set_build(x, y, k_wall)
	# la porta a destra
	var door := Vector2i(x0 + 10, y1 - m.masonry.door_h() + 1)
	for dy in m.masonry.door_h():
		w.set_tile(door.x, door.y + dy, TileDefs.PORTA)
	w.stations[door] = "porta"
	for y in range(y0 - 2, y1 + 3):
		for x in range(x0 - 2, x0 + 13):
			m.view.refresh_around(Vector2i(x, y))
	m.view.add_station(door)
	m.snap_to(Vector2i(x0 + 4, y1))
	await kit.frames(3)
	var empty: Dictionary = m.rooms.refresh()
	var put := func(sid: String, o: Vector2i) -> void:
		w.stations[o] = sid
		m.view.add_station(o)
	put.call(FurnitureData.id_of("letto", "ambra"), Vector2i(x0, y1))
	_bed = Vector2i(x0, y1)
	put.call(FurnitureData.id_of("lampada", "ambra"), Vector2i(x0 + 3, y1 - 1))
	put.call(FurnitureData.id_of("quadro", "ambra"), Vector2i(x0 + 4, y0))
	put.call(FurnitureData.id_of("vaso", "ambra"), Vector2i(x0 + 8, y1))
	put.call(FurnitureData.id_of("tappeto", "ambra"), Vector2i(x0 + 5, y1))
	var home: Dictionary = m.rooms.refresh()
	var regen: float = m.vitals.room_regen
	await kit.seconds(0.3)
	await kit.save("202_stanza")
	# una sala dei trofei: un armadio con tre trofei
	var ward := Vector2i(x0 + 6, y0)
	put.call(FurnitureData.id_of("armadio", "ambra"), ward)
	var trophies := ["coda_brace", "ala_pietra", "cuore_golem"]
	var chest: Bisaccia = w.chest_at(ward)
	for t in trophies:
		chest.add(t, 1)
	var hall: Dictionary = m.rooms.refresh()
	var mult: float = m.rooms.trophy_mult(FamiliesData.family_of("salamandra_brace"))
	# e ancora: uscendo la stanza resta ricordata (i bonus del mondo), rientrando si riconosce di nuovo
	m.snap_to(door + Vector2i(3, m.masonry.door_h() - 1))
	await kit.frames(2)
	m.rooms.refresh()
	var kept: bool = m.rooms.list().any(func(e: Dictionary) -> bool: return String(e["type"]) == "trofei")
	print("stanze: senza arredi «%s» %s; col letto «%s» comfort %d (Vita ×%.2f); con tre trofei «%s» (danno contro le salamandre ×%.2f); ricordata uscendo %s" % [
		empty.get("type", "—"), "sì" if not empty.is_empty() else "NO", home.get("type", "—"), int(home.get("comfort", 0)), regen,
		hall.get("type", "—"), mult, "sì" if kept else "NO"])
	if empty.is_empty() or String(home.get("type", "")) != "casa" or String(hall.get("type", "")) != "trofei" or mult <= 1.0 or not kept:
		print("ATTENZIONE: le stanze non si riconoscono come dovrebbero")
	m.world_meta["stanze"] = []
	m.rooms.refresh()


## Voce 143: il Forgiatore prende il letto della stanza di prova; con un camino di legnoferro (che ama) è più felice e
## i prezzi scendono; senza letto è scontento e i prezzi salgono; felice, lascia un regalo al giorno.
func homes() -> void:
	var w: World = m.world
	if _bed.x < 0:
		print("ATTENZIONE: nessuna stanza per la prova delle case")
		return
	var vil: Villagers = m.villagers
	vil.paused = true
	var n: Npc = vil._spawn("forgiatore", _bed)
	var saved: Dictionary = m.world_meta.get("abitanti", {})
	saved["forgiatore"] = [_bed.x, _bed.y]
	m.world_meta["abitanti"] = saved
	m.world_meta["case"] = {"forgiatore": [_bed.x, _bed.y]}          # il letto della stanza (ce ne sono altri, fuori)
	var h0: int = int(m.homes.update(0.0).get("forgiatore", 0))
	var cam := _bed + Vector2i(3, -1)
	w.stations[cam] = FurnitureData.id_of("camino", "legnoferro")
	m.view.add_station(cam)
	var h1: int = int(m.homes.update(0.0).get("forgiatore", 0))
	var p1: int = NpcBonds.price(m.character, "forgiatore", 100)
	var g0: int = m.homes.gifts
	m.homes.update(HomesData.GIFT_EVERY + 1.0)
	var gift: bool = m.homes.gifts > g0 or h1 < HomesData.HAPPY
	var line: String = m.homes.line("forgiatore")
	# un letto fuori da una stanza
	var bed_id := String(w.stations[_bed])
	w.stations.erase(_bed)
	m.world_meta.erase("case")
	var h2: int = int(m.homes.update(0.0).get("forgiatore", 0))
	var p2: int = NpcBonds.price(m.character, "forgiatore", 100)
	w.stations[_bed] = bed_id
	# via l'abitante di prova
	vil.list.erase(n)
	n.queue_free()
	saved.erase("forgiatore")
	m.world_meta.erase("case")
	m.world_meta.erase("felicita")
	NpcBonds.mood_mult.clear()
	vil.paused = false
	print("case: il Forgiatore nella stanza %d, col camino di legnoferro %d (prezzo 100 → %d, regalo %s), in un letto fuori da una stanza %d (prezzo %d); «%s»" % [
		h0, h1, p1, "sì" if gift else "NO", h2, p2, line])
	if h1 <= h0 or h2 >= h0 or p2 <= p1 or not gift or line == "":
		print("ATTENZIONE: le case degli abitanti non vanno come dovrebbero")


## Voce 144: nella stanza di prova il freddo sale meno (e con un camino niente), le creature non nascono sulle pareti
## posate, una porta incorniciata di mura dure regge il doppio dei morsi.
func shelter() -> void:
	var w: World = m.world
	if _bed.x < 0:
		return
	m.snap_to(_bed + Vector2i(2, 0))
	await kit.frames(2)
	var r: Dictionary = m.rooms.refresh()
	var cold: float = m.rooms.shelter("freddo")
	var heat: float = m.rooms.shelter("calore")
	var cam := _bed + Vector2i(3, -1)
	var had_cam := w.stations.has(cam)
	if not had_cam:
		w.stations[cam] = FurnitureData.id_of("camino", "ardesia")
	m.rooms.refresh()
	var cold_fire: float = m.rooms.shelter("freddo")
	var no_spawn := Fauna.player_wall(w, _bed + Vector2i(1, 0)) and not Fauna.player_wall(w, w.spawn + Vector2i(0, -3))
	# la porta della stanza: cornice d'ardesia (tenera), poi d'ambra (dura)
	var door := Vector2i(-1, -1)
	for o in w.stations:
		if String(w.stations[o]) == "porta" and Vector2(o - _bed).length() < 14.0:
			door = o
	var soft: int = m.wiles.door_strength(door) if door.x >= 0 else 0
	var hard := 0
	if door.x >= 0:
		var amber := 2 * BuildData.FORMS.size() + 2          # mattoni d'ambra
		for dy in m.masonry.door_h():
			w.set_build(door.x - 1, door.y + dy, amber)
			w.set_build(door.x + 1, door.y + dy, amber)
		hard = m.wiles.door_strength(door)
	m.snap_to(w.spawn)
	await kit.frames(2)
	m.rooms.refresh()
	print("riparo: nella stanza (isolamento %.1f) il freddo sale ×%.2f, il calore ×%.2f, col camino il freddo ×%.2f; pareti posate senza nascite %s; porta: %d morsi, con le mura d'ambra %d" % [
		float(r.get("iso", 0.0)), cold, heat, cold_fire, "sì" if no_spawn else "NO", soft, hard])
	if cold >= 1.0 or cold_fire > 0.0 or not no_spawn or hard <= soft:
		print("ATTENZIONE: costruire contro il mondo non va come dovrebbe")


## Voce 145: la sala dei trofei dei Seminatori nasce in un colpo se hai i materiali; dentro è una stanza.
func blueprints() -> void:
	var w: World = m.world
	var spot := kit.flat_spot(w.spawn + Vector2i(-150, 0), 18)
	if spot.x < 0:
		spot = m.player_cell() + Vector2i(-40, 0)
	kit.flatten(spot, 24)
	var b: Bisaccia = m.character.bisaccia
	var id := "sala_trofei"
	var sz := ProjectsData.size_of(id)
	var o := Vector2i(spot.x - sz.x / 2, spot.y - sz.y + 1)
	m.snap_to(spot + Vector2i(-sz.x / 2 - 3, 0))
	await kit.frames(2)
	var none: bool = not m.builder.build_blueprint(id, o)
	var need := ProjectsData.needs(id)
	for k in need:
		b.add(String(k), int(need[k]))
	var ok: bool = m.builder.build_blueprint(id, o)
	var left := 0
	for k in need:
		left += b.count(String(k))
	m.snap_to(o + Vector2i(4, sz.y - 2))
	await kit.seconds(0.3)
	await kit.save("208_progetto_seminatori")
	var room: Dictionary = m.rooms.refresh()
	print("progetti dei Seminatori: senza materiali no %s; con i materiali costruito %s (ne restano %d nella Bisaccia); dentro una stanza «%s» comfort %d" % [
		"sì" if none else "NO", "sì" if ok else "NO", left, room.get("type", "—"), int(room.get("comfort", 0))])
	if not none or not ok or room.is_empty():
		print("ATTENZIONE: i progetti dei Seminatori non vanno come dovrebbero")
	_hall = o


## Voce 146: la sala dei progetti, senza luci e lasciata sola, si riempie di ragnatele; con un letto è una casa e sul
## tetto un uccello fa il nido, che lascia piume.
func dwellers() -> void:
	var w: World = m.world
	if _hall.x < 0:
		print("ATTENZIONE: nessuna sala per la prova degli ospiti")
		return
	var sz := ProjectsData.size_of("sala_trofei")
	# via le lanterne, dentro un letto
	for o in w.stations.keys():
		if Rect2i(_hall, sz).has_point(o) and StationsData.role(String(w.stations[o])) == "lanterna":
			w.stations.erase(o)
			m.view.remove_station(o)
	var bed := _hall + Vector2i(6, sz.y - 2)
	w.stations[bed] = FurnitureData.id_of("letto", "lanterna")
	m.view.add_station(bed)
	m.snap_to(_hall + Vector2i(3, sz.y - 2))
	await kit.frames(2)
	var room: Dictionary = m.rooms.refresh()
	m.snap_to(_hall + Vector2i(-6, sz.y - 1))
	await kit.frames(2)
	m.rooms.refresh()
	var visits: Dictionary = m.world_meta.get("stanze_visite", {})
	var now: float = float(m.world_meta.get("tempo_gioco", 0.0))
	visits[String(room.get("key", ""))] = now - Dwellers.DARK_AFTER - 10.0
	var dw: Dwellers = m.dwellers
	var w0 := dw.webs_made
	dw.check(now)
	var webbed := dw.webs_made > w0
	# il nido: si prova finché lo mette (è una probabilità)
	var e: Dictionary = {}
	for r in m.rooms.list():
		if String(r["key"]) == String(room.get("key", "")):
			e = r
	var nest := false
	if not e.is_empty():
		dw._nest(e)
		nest = dw.nests_made > 0
	var nest_o := Vector2i(-1, -1)
	for o in w.stations:
		if String(w.stations[o]) == "nido_tetto":
			nest_o = o
	var d0: int = m.drops._items.size()
	if nest_o.x >= 0:
		dw.touch_nest(nest_o)
	var feathers: bool = m.drops._items.size() > d0
	await kit.seconds(0.2)
	await kit.save("209_ospiti")
	m.wiles.webs.clear()
	m.world_meta["stanze"] = []
	print("ospiti delle case: stanza «%s» buia e sola → ragnatele %s; casa con un nido sul tetto %s, piume %s" % [
		room.get("type", "—"), "sì" if webbed else "NO", "sì" if nest else "NO", "sì" if feathers else "NO"])
	if not webbed or not nest or not feathers:
		print("ATTENZIONE: gli ospiti delle case non vanno come dovrebbero")


## Voce 148: una creatura della mandria di guardia alla cuccia attacca chi si avvicina; l'alveare costruito fa il miele.
func herd_home() -> void:
	var w: World = m.world
	var spot := kit.flat_spot(w.spawn + Vector2i(170, 0), 12)
	if spot.x < 0:
		spot = m.player_cell() + Vector2i(20, 0)
	kit.flatten(spot, 16)
	m.snap_to(spot + Vector2i(-4, 0))
	await kit.frames(2)
	var cu := spot + Vector2i(2, 0)
	w.stations[cu] = "cuccia"
	m.view.add_station(cu)
	var rec: Dictionary = m.herd.new_record(String(FamiliesData.FAMILIES["linci"]["members"][0]), "nutrita", 2.0)
	m.herd.add_record(rec)
	var why: String = m.herd.set_state(rec, "guardia")
	await kit.seconds(0.5)
	var beast: Creature = m.herd.beasts.get(int(rec["uid"]))
	var guarding: bool = beast != null and beast.tame != null and beast.tame.mode == "guardia"
	m.combat.god = true
	var foe: Creature = m.fauna.add(wid if wid != "" else "scarabeo_ardesia", (Vector2(cu) + Vector2(6, 0)) * 16.0)
	var hp0 := foe.hp
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 5000 and is_instance_valid(foe) and foe.hp >= hp0:
		await kit.frames(3)
	var bit: bool = not is_instance_valid(foe) or foe.hp < hp0
	await kit.save("210_guardia")
	m.fauna.clear()
	m.combat.god = false
	# l'alveare
	var hv := spot + Vector2i(-2, -1)
	w.stations[hv] = "alveare_costruito"
	m.view.add_station(hv)
	m.dwellers.hive_honey(hv)
	var t: Dictionary = m.world_meta["alveari"]
	t["%d,%d" % [hv.x, hv.y]] = float(m.world_meta.get("tempo_gioco", 0.0)) - Dwellers.HIVE_EVERY * 3.0
	var honey: int = m.dwellers.hive_honey(hv)
	var d0: int = m.drops._items.size()
	m.dwellers.touch_hive(hv)
	var got: bool = m.drops._items.size() > d0
	m.herd.free_record(rec)
	print("la mandria abita: di guardia %s (%s), morde chi si avvicina alla cuccia %s; alveare: %d miele, raccolto %s" % [
		"sì" if guarding else "NO", why if why != "" else "ok", "sì" if bit else "NO", honey, "sì" if got else "NO"])
	if not guarding or not bit or honey < 3 or not got:
		print("ATTENZIONE: la mandria che abita non va come dovrebbe")
