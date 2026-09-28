class_name TestsAlive
extends RefCounted
## Roadmap 15 «Il mondo abitato» (creature e costruzioni). Voce 127: gli attacchi si annunciano (il «!» di `TeleMark`) e
## la schivata c'è solo con un oggetto che la sblocca. Voce 128: i costrutti (forma × materiale). Voce 129: il cervello (`Mind`).
## Voce 130: le astuzie (`WilesData`, `Wiles`). Voce 131: le tattiche di gruppo (`Tactics`).
## Voce 140: gli strumenti del costruttore (`BuilderTools`). Voci 132-134: le specie nuove nascono e vivono. Gruppo «vivo».

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var b: Bisaccia = m.character.bisaccia
	var slots0 := b.slots.duplicate(true)
	var equip0 := b.equip.duplicate(true)
	await telegraphs()
	await dash()
	await builds()
	await builder()
	await brain()
	await wiles()
	await tactics()
	await species("superficie", "198_bestiario_superficie")
	for i in slots0.size():
		b.slots[i] = slots0[i]
	b.equip = equip0
	b.changed.emit()


## Una creatura che carica, messa sulla linea del Germogliato: prima di partire accende il «!».
func telegraphs() -> void:
	var w: World = m.world
	var cid := ""
	for id in CreaturesData.CREATURES:
		var c: Dictionary = CreaturesData.CREATURES[id]
		if "carica" in (c.get("behaviors", []) as Array) and not c.get("fly", false) and not c.get("boss", false) \
				and 0 in (c.get("strata", []) as Array):
			cid = String(id)
			break
	var spot := kit.flat_spot(w.spawn + Vector2i(40, 0), 6)
	if cid == "" or spot.x < 0:
		print("ATTENZIONE: nessuna creatura che carica, o nessun posto piano, per la prova dei segnali")
		return
	kit.flatten(spot, 8)
	m.snap_to(spot)
	m.vitals.refill()
	await kit.frames(3)
	var cr: Creature = m.fauna.add(cid, m.player.position + Vector2(90, 0))
	var seen := 0.0
	var shot := false
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 5000 and is_instance_valid(cr):
		await kit.frames(1)
		seen = maxf(seen, cr.tele)
		if cr.tele > 0.15 and not shot:
			shot = true
			await kit.save("190_telegrafo")
	var has_mark := is_instance_valid(cr) and cr.get_children().any(func(n: Node) -> bool: return n is TeleMark)
	if is_instance_valid(cr):
		m.fauna.clear()
	m.vitals.refill()
	print("segnale degli attacchi: %s, prima della carica il «!» acceso %s (%.2f s), il segno c'è %s" % [cid,
		"sì" if seen > 0.1 else "NO", seen, "sì" if has_mark else "NO"])
	if seen <= 0.1 or not has_mark:
		print("ATTENZIONE: gli attacchi non si annunciano")


## La schivata: senza oggetto no; con il Cavigliere di vento sì (scatto, invulnerabilità, ricarica).
func dash() -> void:
	var b: Bisaccia = m.character.bisaccia
	var p: Player = m.player
	var no_item: bool = not m.dodge.dash()
	b.equip["accessorio_1"] = "cavigliere_vento"
	m.gear.refresh()
	await kit.seconds(0.2)
	var x0 := p.position.x
	m.combat.invuln = 0.0
	var ok: bool = m.dodge.dash()
	var inv: float = m.combat.invuln
	var again: bool = m.dodge.dash()
	await kit.seconds(0.35)
	var moved := absf(p.position.x - x0)
	print("schivata: senza oggetto no %s; con il Cavigliere sì %s, %.0f px, invulnerabile %.2f s, subito di nuovo no %s" % [
		"sì" if no_item else "NO", "sì" if ok else "NO", moved, inv, "sì" if not again else "NO"])
	if not no_item or not ok or moved < 24.0 or inv < 0.25 or again:
		print("ATTENZIONE: la schivata non va come dovrebbe")


## Voce 128: un muretto di costrutti (tutte le forme, tre materiali) con le pareti costruite dietro; uno si scava e
## lascia il suo oggetto; il mondo salvato e ricaricato li tiene.
func builds() -> void:
	var w: World = m.world
	var spot := kit.flat_spot(w.spawn + Vector2i(-40, 0), 12)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto piano per la prova dei costrutti")
		return
	kit.flatten(spot, 14)
	var nf := BuildData.FORMS.size()
	var placed := 0
	var mats := [0, 1, 2, 6, 12, 13, 14, 17]              # un campione: ardesia, lanterna, ambra, brace, Linfa, stellare, vetro, catacomba
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


## Voce 129: al buio una creatura vede meno lontano; un rumore la fa venire a guardare; ferita grave, una paurosa fugge.
func brain() -> void:
	var w: World = m.world
	var cid := ""
	for id in CreaturesData.CREATURES:
		var d: Dictionary = CreaturesData.CREATURES[id]
		if "cammina" in (d.get("behaviors", []) as Array) and not d.get("fly", false) and not d.get("boss", false) 				and not d.get("docile", false) and 0 in (d.get("strata", []) as Array) and int(d.get("damage", 0)) > 0:
			cid = String(id)
			break
	var spot := kit.flat_spot(w.spawn + Vector2i(60, 0), 16)
	if cid == "" or spot.x < 0:
		print("ATTENZIONE: nessuna creatura che cammina, o nessun posto piano, per la prova del cervello")
		return
	kit.flatten(spot, 36)
	m.snap_to(spot)
	m.vitals.refill()
	m.senses.paused = true
	await kit.frames(3)
	var cr: Creature = m.fauna.add(cid, m.player.position + Vector2(15 * 16, -8))
	var sight := float(cr.p.get("sight", 20))
	Mind.lit = 1.0
	var day := Behavior.sees(cr, 16.0)
	cr.mind = Mind.new()
	cr.mind.setup(cr)
	Mind.lit = 0.0
	var night := Behavior.sees(cr, 16.0)
	# un rumore vicino alla creatura: va a vedere
	cr.mind.dark = false
	var x0 := cr.position.x
	var spot_n := cr.position + Vector2(-6 * 16, 0)
	Mind.noise(spot_n, 9.0)
	await kit.seconds(1.2)
	var alert := cr.mind.state == Mind.ALERT
	var went := x0 - cr.position.x
	await kit.save("192_allerta")
	# la fuga
	cr.mind.brave = false
	cr.hp = maxi(1, cr.hp_max / 10)
	Mind.lit = 1.0
	await kit.seconds(0.3)
	var fx0 := absf(cr.position.x - m.player.position.x)
	await kit.seconds(1.0)
	var flee := cr.mind.state == Mind.FLEE and absf(cr.position.x - m.player.position.x) > fx0
	m.fauna.clear()
	m.senses.paused = false
	Mind.reset()
	print("cervello (%s, vista %.0f): a 15 tessere di giorno la vede %s, al buio no %s; un rumore: all'erta %s, %.0f px verso il rumore; ferita grave fugge %s" % [
		cid, sight, "sì" if day else "NO", "sì" if not night else "NO", "sì" if alert else "NO", went, "sì" if flee else "NO"])
	if not day or night or not alert or went < 16.0 or not flee:
		print("ATTENZIONE: il cervello delle creature non va come dovrebbe")


var _wid := ""


## Una creatura di prova con un'astuzia in più (dati copiati, per non toccare la tabella).
func _mk(beh: String, at: Vector2, params := {}) -> Creature:
	var cr: Creature = m.fauna.add(_wid, at)
	cr.data = cr.data.duplicate(true)
	(cr.data["behaviors"] as Array).append(beh)
	cr.p = cr.p.duplicate(true)
	cr.p.merge(params, true)
	cr.behaviors.append(Behavior.make(beh))
	cr.mind.brave = true
	return cr


## Voce 130: ogni astuzia fa ciò che promette (il tuffatore ha bisogno di uno specchio: lo prova il gruppo «pesca» più avanti).
func wiles() -> void:
	var w: World = m.world
	for id in CreaturesData.CREATURES:
		var d: Dictionary = CreaturesData.CREATURES[id]
		if "cammina" in (d.get("behaviors", []) as Array) and not d.get("fly", false) and not d.get("boss", false) 				and not d.get("docile", false) and 0 in (d.get("strata", []) as Array):
			_wid = String(id)
			break
	var spot := kit.flat_spot(w.spawn + Vector2i(60, 0), 16)
	if spot.x < 0:
		spot = m.player_cell()                  # il posto della prova del cervello, già spianato
	if _wid == "":
		print("ATTENZIONE: nessuna creatura semplice o nessun posto piano per la prova delle astuzie")
		return
	kit.flatten(spot, 30)
	m.snap_to(spot)
	m.vitals.refill()
	m.combat.god = true
	var b: Bisaccia = m.character.bisaccia
	b.add("legno", 20)
	var res := {}
	var P: Vector2 = m.player.position
	# ladro
	var cr := _mk("ladro", P + Vector2(10, 0))
	await kit.seconds(0.8)
	var had := cr.has_meta("rubato")
	var n0: int = m.drops._items.size()
	m.fauna.kill(cr)
	res["ladro"] = had and m.drops._items.size() > n0
	m.fauna.clear()
	# si divide
	cr = _mk("divide", P + Vector2(60, 0))
	cr.last_dmg = 1
	var c0: int = m.fauna.list.size()
	m.fauna.kill(cr)
	res["divide"] = m.fauna.list.size() == c0 + 1
	m.fauna.clear()
	# scudo: davanti un quinto
	cr = _mk("scudo", P + Vector2(60, 0))
	await kit.seconds(0.1)
	cr.hp = cr.hp_max
	cr.defense = 0
	var fc := float((cr.behaviors[-1] as BhScudo).face)
	cr.take_hit(20, cr.position.x + fc * 20.0, 0.0)
	var front := cr.hp_max - cr.hp
	cr.hp = cr.hp_max
	cr.take_hit(20, cr.position.x - fc * 20.0, 0.0)
	var back := cr.hp_max - cr.hp
	res["scudo"] = front < back
	m.fauna.clear()
	# guaritore
	var hurt: Creature = m.fauna.add(_wid, P + Vector2(80, 0))
	hurt.hp = maxi(1, hurt.hp_max / 3)
	var h0 := hurt.hp
	cr = _mk("guaritore", P + Vector2(100, 0))
	await kit.seconds(4.0)
	res["guaritore"] = is_instance_valid(hurt) and hurt.hp > h0
	m.fauna.clear()
	# richiamo
	cr = _mk("richiamo", P + Vector2(90, 0), {"call_time": 0.5})
	await kit.seconds(1.2)
	res["richiamo"] = m.fauna.list.size() >= 3
	m.fauna.clear()
	# parassita
	m.vitals.refill()
	var l0: int = m.vitals.linfa
	cr = _mk("parassita", P + Vector2(4, 0))
	await kit.seconds(2.3)
	res["parassita"] = m.vitals.linfa < l0
	m.fauna.clear()
	# tessitore
	cr = _mk("tessitore", P + Vector2(100, 0))
	(cr.behaviors[-1] as BhTessitore).t = 0.0
	await kit.seconds(1.0)
	res["tessitore"] = not m.wiles.webs.is_empty() and m.player.slow_t > 0.0
	await kit.save("193_ragnatela")
	m.wiles.webs.clear()
	m.wiles.queue_redraw()
	m.player.slow_t = 0.0
	m.fauna.clear()
	# scoppiante
	var bl0: int = m.throwing.blasts
	cr = _mk("scoppia", P + Vector2(20, 0), {"fuse": 0.5})
	await kit.seconds(1.2)
	res["scoppia"] = m.throwing.blasts > bl0 and not m.fauna.list.has(cr)
	m.fauna.clear()
	# mimetico: fermo finché non ti avvicini
	cr = _mk("mimetico", P + Vector2(6 * 16, 0))
	await kit.seconds(0.5)
	var still := cr.anchored
	await kit.save("194_mimetico")
	cr.position = P + Vector2(24, 0)
	await kit.seconds(0.3)
	res["mimetico"] = still and not cr.anchored
	m.fauna.clear()
	# pastore
	var sheep: Creature = m.fauna.add(_wid, P + Vector2(120, 0))
	cr = _mk("pastore", P + Vector2(160, 0))
	await kit.seconds(0.7)
	var led := sheep.mind.lead == cr
	m.fauna.kill(cr)
	res["pastore"] = led and sheep.mind.state == Mind.FLEE
	m.fauna.clear()
	# sbuca: sotto terra, poi fuori
	cr = _mk("sbuca", P + Vector2(40, 48), {"sight": 20})
	cr.behaviors = [cr.behaviors[-1]] as Array[Behavior]
	var out := false
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 5000 and is_instance_valid(cr):
		await kit.frames(1)
		if (cr.behaviors[0] as BhSbuca).phase == 2 and not cr.buried:
			out = true
			break
	res["sbuca"] = out
	m.fauna.clear()
	# rosicchia: fuori dall'assedio non tocca nulla, nell'assedio rode la porta finché cade
	var q: Vector2i = m.player_cell() + Vector2i(4, 1 - m.masonry.door_h())
	for dy in m.masonry.door_h():
		w.set_tile(q.x, q.y + dy, TileDefs.PORTA)
	w.stations[q] = "porta"
	m.view.add_station(q)
	cr = _mk("rosicchia", Vector2(q.x + 1, q.y + m.masonry.door_h() - 1) * 16.0 + Vector2(8, 8), {"gnaw_every": 0.15})
	cr.mind.dark = true
	await kit.seconds(1.2)
	var kept: bool = w.stations.get(q, "") == "porta"
	Wiles.siege = true
	await kit.seconds(2.0)
	Wiles.siege = false
	res["rosicchia"] = kept and not w.stations.has(q) and w.tile(q.x, q.y) == TileDefs.AIR
	if w.stations.has(q):
		w.stations.erase(q)
		m.view.remove_station(q)
		for dy in m.masonry.door_h():
			w.set_tile(q.x, q.y + dy, TileDefs.AIR)
	m.fauna.clear()
	# fotofobo: a mezzogiorno in superficie fugge
	cr = _mk("fotofobo", P + Vector2(60, 0))
	await kit.seconds(0.6)
	res["fotofobo"] = cr.mind.state == Mind.FLEE
	m.fauna.clear()
	m.combat.god = false
	b.remove("legno", mini(20, b.count("legno")))
	var bad := []
	for k in res:
		if not res[k]:
			bad.append(k)
	print("astuzie: %d su %d come promesso%s (furti %d, divisioni %d)" % [res.size() - bad.size(), res.size(),
		"" if bad.is_empty() else "; NON vanno: " + ", ".join(bad), m.wiles.stolen, m.wiles.splits])
	if not bad.is_empty():
		print("ATTENZIONE: alcune astuzie non vanno")


## Voce 131: un branco accerchia (qualcuno gira dall'altra parte), le prede si avvisano, la colonia difende il nido.
func tactics() -> void:
	if _wid == "":
		return
	m.snap_to(m.player_cell())
	m.combat.god = true
	var P: Vector2 = m.player.position
	# il branco: tre dalla destra, lo stesso gruppo
	var pack := []
	for i in 3:
		var c: Creature = m.fauna.add(_wid, P + Vector2(150.0 + i * 20.0, -4))
		c.set_meta("grp", 777)
		pack.append(c)
	var crossed := false
	var flanked := false
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 4000:
		await kit.frames(2)
		for c in pack:
			if is_instance_valid(c):
				flanked = flanked or c.mind.flank != 0.0
				crossed = crossed or c.position.x < m.player.position.x - 8.0
	await kit.save("195_branco")
	m.fauna.clear()
	# le prede si avvisano
	var a: Creature = m.fauna.add("lepre_linfa", P + Vector2(120, -4))
	var b2: Creature = m.fauna.add("lepre_linfa", P + Vector2(150, -4))
	await kit.seconds(0.4)
	a.take_hit(2, P.x, 0.0)
	await kit.seconds(0.5)
	var warned: bool = is_instance_valid(b2) and b2.mind.state == Mind.FLEE
	m.fauna.clear()
	# la colonia difende il nido
	var key := "%d,%d" % [m.player_cell().x, m.player_cell().y]
	m.ecology.nests[key] = {"fam": "formiche", "eggs": 0, "t": 0.0, "fed": 0}
	var ant: Creature = m.fauna.add("formica_resina", P + Vector2(18 * 16, -4))
	ant.docile = false
	await kit.seconds(1.4)
	var defend: bool = is_instance_valid(ant) and ant.mind.state in [Mind.ALERT, Mind.HUNT]
	m.ecology.nests.erase(key)
	m.fauna.clear()
	m.combat.god = false
	print("tattiche: il branco accerchia %s (qualcuno gira dall'altra parte %s); le prede si avvisano %s; la colonia difende il nido %s" % [
		"sì" if flanked else "NO", "sì" if crossed else "NO", "sì" if warned else "NO", "sì" if defend else "NO"])
	if not flanked or not crossed or not warned or not defend:
		print("ATTENZIONE: le tattiche di gruppo non vanno come dovrebbero")


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


## Voci 132-134: ogni specie di un pacchetto del bestiario nasce, vive qualche istante accanto al Germogliato (a gruppi
## di otto) senza errori, e la sua scheda si scrive; una foto del primo gruppo.
func species(pack: String, photo: String) -> void:
	var data: Dictionary = (load("res://src/data/bestiary/%s.gd" % pack) as GDScript).get("DATA")
	var ids: Array = (data["creatures"] as Dictionary).keys()
	m.snap_to(m.player_cell())
	m.combat.god = true
	var P: Vector2 = m.player.position
	var alive := 0
	var cards := 0
	for g in range(0, ids.size(), 8):
		for i in range(g, mini(g + 8, ids.size())):
			var id := String(ids[i])
			var cd: Dictionary = CreaturesData.get_data(id)
			var at := P + Vector2(-140.0 + (i - g) * 40.0, -40.0 if cd.get("fly", false) else -8.0)
			var cr: Creature = m.fauna.add(id, at)
			cr.mind.brave = true
			if not WorldTip.creature(m, cr).plain().is_empty():
				cards += 1
		await kit.seconds(1.2)
		if g == 0:
			await kit.save(photo)
		for cr in m.fauna.list:
			if is_instance_valid(cr) and cr.hp > 0:
				alive += 1
		m.fauna.clear()
	m.combat.god = false
	m.vitals.refill()
	print("bestiario «%s»: %d specie nate, %d vive dopo un attimo, %d schede scritte" % [pack, ids.size(), alive, cards])
	if cards < ids.size():
		print("ATTENZIONE: alcune specie del bestiario «%s» non hanno la scheda" % pack)
