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
	await furniture()
	await rooms()
	await homes()
	await shelter()
	await brain()
	await wiles()
	await tactics()
	await species("superficie", "198_bestiario_superficie")
	await species("sottosuolo", "199_bestiario_sottosuolo")
	await species("tempo", "200_bestiario_tempo")
	conditions()
	await species("signori", "203_signori")
	await lords()
	await species("guardiani", "205_grandi_guardiani")
	await great()
	await tides()
	await study()
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
var _bed := Vector2i(-1, -1)                     # il letto della stanza della prova delle stanze (per le case)


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


## Voce 134: le specie a condizione nascono solo quando la condizione c'è (notte, stagione, tempo, eclissi).
func conditions() -> void:
	var s0 := CreaturesData.now_season
	var w0 := CreaturesData.now_weather
	var e0 := CreaturesData.now_eclipse
	var ids := func(night: bool) -> Array:
		return CreaturesData.of_stratum(0, night, "foresta").map(func(e: Array) -> String: return String(e[0]))
	CreaturesData.now_season = "germoglio"
	CreaturesData.now_weather = "sereno"
	CreaturesData.now_eclipse = false
	var calm: Array = ids.call(false)
	var no_other := not "cinghiale_raccolto" in calm and not "rana_tuono" in calm and not "eclissimo" in calm and not "lupo_lunare" in calm
	var has_season := "bruco_germoglio" in calm
	CreaturesData.now_season = "raccolto"
	CreaturesData.now_weather = "temporale"
	CreaturesData.now_eclipse = true
	var storm: Array = ids.call(true)
	var all_in := "cinghiale_raccolto" in storm and "rana_tuono" in storm and "eclissimo" in storm and "lupo_lunare" in storm 		and not "bruco_germoglio" in storm
	CreaturesData.now_season = s0
	CreaturesData.now_weather = w0
	CreaturesData.now_eclipse = e0
	print("specie a condizione: col sereno di giorno in Germoglio solo quelle giuste %s (bruco sì %s); di notte col temporale in Raccolto e l'eclissi le altre %s" % [
		"sì" if no_other else "NO", "sì" if has_season else "NO", "sì" if all_in else "NO"])
	if not no_other or not has_season or not all_in:
		print("ATTENZIONE: le specie a condizione non nascono come dovrebbero")


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


## Voce 135: nella foresta l'esca del Cervo-lanterna lo chiama; a metà Vita entra in furia; sconfitto lascia il suo
## materiale e il trofeo; l'esca di un altro luogo qui non fa nulla.
func lords() -> void:
	var w: World = m.world
	m.snap_to(w.spawn)
	await kit.frames(3)
	var key: String = m.lords.here()
	var b: Bisaccia = m.character.bisaccia
	var wrong := "esca_signore_brace" if key != "brace" else "esca_signore_foresta"
	b.add(wrong, 1)
	var no: bool = not m.lords.summon(wrong)
	var bait := "esca_signore_" + key
	b.add(bait, 1)
	m.combat.god = true
	var ok: bool = key != "" and m.lords.summon(bait)
	var lord: Creature = m.lords.active
	var n0: int = lord.behaviors.size() if lord else 0
	if lord:
		lord.hp = lord.hp_max / 3
		await kit.seconds(0.3)
	var fury: bool = lord != null and is_instance_valid(lord) and lord.behaviors.size() > n0
	await kit.save("204_signore")
	var d0: int = m.drops._items.size()
	if lord and is_instance_valid(lord):
		m.fauna.kill(lord)
	var rec: int = int((m.world_meta.get("signori", {}) as Dictionary).get(key, 0))
	var dropped: bool = m.drops._items.size() > d0
	m.fauna.clear()
	m.combat.god = false
	b.remove(wrong, b.count(wrong))
	print("Signori: qui «%s», l'esca sbagliata non fa nulla %s, quella giusta lo chiama %s, furia a metà Vita %s, sconfitto (%d) e bottino %s" % [
		key, "sì" if no else "NO", "sì" if ok else "NO", "sì" if fury else "NO", rec, "sì" if dropped else "NO"])
	if key == "" or not no or not ok or not fury or rec < 1 or not dropped:
		print("ATTENZIONE: i Signori dei luoghi non vanno come dovrebbero")


## Voce 136: la Signora delle correnti si chiama all'aperto (il Leviatano senza lago no); le mosse: la raffica spinge
## e fa nascere correnti e nuvole, i pilastri si alzano solo nell'aria e crollano, la marea versa acqua; alla fine non
## resta nulla di temporaneo.
func great() -> void:
	var w: World = m.world
	var gg: GreatGuardians = m.great
	m.snap_to(w.spawn)
	await kit.frames(3)
	m.combat.god = true
	var b: Bisaccia = m.character.bisaccia
	b.add("richiamo_leviatano", 1)
	var no_lake: bool = not gg.summon("richiamo_leviatano")
	b.add("richiamo_correnti", 1)
	var sky: bool = gg.summon("richiamo_correnti")
	var boss: Creature = gg.active
	var P: Vector2 = m.player.position
	var v0: float = m.player.vel.x
	var cur0: int = m.gravity.currents.size()
	if boss:
		gg.act(boss, {"kind": "correnti", "at": P, "from": P - Vector2(80, 0)})
	var pushed: bool = m.player.vel.x - v0 > 100.0
	var winds: bool = m.gravity.currents.size() > cur0 and not gg.clouds.is_empty()
	await kit.seconds(0.3)
	await kit.save("206_correnti")
	if boss:
		gg.act(boss, {"kind": "pilastri", "at": P + Vector2(0, 0), "n": 3})
	var raised: int = gg.pillars.size()
	var solid_ok := true
	for e in gg.pillars:
		solid_ok = solid_ok and w.tile((e[0] as Vector2i).x, (e[0] as Vector2i).y) == TileDefs.RADICE
	var t0: int = gg.tides
	if boss:
		gg.act(boss, {"kind": "marea", "at": P + Vector2(0, 16), "to": P + Vector2(64, 0), "n": 4})
	var tide: bool = gg.tides > t0
	gg.clear_temp()
	var cleared: bool = gg.pillars.is_empty() and gg.clouds.is_empty() and m.gravity.currents.size() == cur0
	if boss and is_instance_valid(boss):
		m.fauna.kill(boss)
	var rec: int = int((m.world_meta.get("grandi_guardiani", {}) as Dictionary).get("correnti", 0))
	m.fauna.clear()
	m.combat.god = false
	print("grandi Guardiani: il Leviatano senza lago no %s; la Signora delle correnti all'aperto sì %s; raffica %s, correnti e nuvole %s; %d pilastri di radice %s; marea %s; poi tutto sparito %s; sconfitta (%d)" % [
		"sì" if no_lake else "NO", "sì" if sky else "NO", "sì" if pushed else "NO", "sì" if winds else "NO", raised,
		"sì" if solid_ok else "NO", "sì" if tide else "NO", "sì" if cleared else "NO", rec])
	if not no_lake or not sky or not pushed or not winds or raised < 3 or not tide or not cleared or rec < 1:
		print("ATTENZIONE: i grandi Guardiani non vanno come dovrebbero")


## Voce 137: lo Stormo arriva a ondate, poi il capo; sconfitto, il premio. L'assedio c'è solo con una base, accende
## i morsi alle porte e poi non torna nella stessa stagione.
func tides() -> void:
	var w: World = m.world
	var td: Tides = m.tides
	td.paused = true
	m.snap_to(w.spawn)
	await kit.frames(3)
	m.combat.god = true
	td.center = m.player_cell()
	td.start("stormo")
	var waves_seen := 0
	var t0 := Time.get_ticks_msec()
	while td.active != "" and Time.get_ticks_msec() - t0 < 20000:
		await kit.frames(3)
		waves_seen = maxi(waves_seen, td.wave)
		if td.boss and is_instance_valid(td.boss):
			if waves_seen >= 3 and td.wins == 0:
				await kit.save("207_marea")
			m.fauna.kill(td.boss)
		else:
			for c in td._wave_list.duplicate():
				if is_instance_valid(c):
					m.fauna.kill(c)
	var won_ok := td.wins >= 1
	m.fauna.clear()
	# l'assedio: senza base no; con Focolare e porta sì, e accende i morsi
	var no_base: bool = not td.siege_allowed() or td._base().x >= 0
	var fo: Vector2i = m.player_cell() + Vector2i(-6, -1)
	var dr: Vector2i = m.player_cell() + Vector2i(-10, 1 - m.masonry.door_h())
	var had_f: bool = w.stations.has(fo)
	w.stations[fo] = "focolare"
	w.stations[dr] = "porta_aperta"
	m.world_meta.erase("assedio")
	var can: bool = td.siege_allowed()
	td.center = td._base()
	td.start("assedio")
	var gnaw: bool = Wiles.siege
	td._end(false)
	var again: bool = td.siege_allowed()
	w.stations.erase(fo)
	w.stations.erase(dr)
	m.fauna.clear()
	m.combat.god = false
	td.paused = false
	print("maree: lo Stormo %d ondate, capo sconfitto e premio %s (%d nate); l'assedio con la base %s, porte rosicchiate %s, di nuovo nella stessa stagione no %s" % [
		waves_seen, "sì" if won_ok else "NO", td.spawned, "sì" if can else "NO", "sì" if gnaw else "NO", "sì" if not again else "NO"])
	if waves_seen < 3 or not won_ok or not can or not gnaw or again:
		print("ATTENZIONE: le maree del mondo non vanno come dovrebbero")


## Voce 138: una specie passa da sconosciuta a vista, sconfitta e studiata (con le sconfitte e la Provetta); la scheda
## svela le debolezze da sconfitta e le contromosse da studiata; studiata fa +6% di danno.
func study() -> void:
	var w: World = m.world
	var st: Study = m.study
	var base := "tessispore"
	var er: Dictionary = m.character.erbario
	er["creature"].erase(base)
	er["viste"].erase(base)
	er["studio"].erase(base)
	m.snap_to(w.spawn)
	await kit.frames(2)
	var g0 := st.grade(base)
	var cr: Creature = m.fauna.add(base, m.player.position + Vector2(40, -8))
	cr.mind.brave = true
	await kit.seconds(1.2)
	var g1 := st.grade(base)
	var tip1: String = WorldTip.creature(m, cr).plain()
	m.fauna.kill(cr)
	await kit.frames(2)
	var g2 := st.grade(base)
	er["creature"][base] = st.need(base) - 4
	var cr2: Creature = m.fauna.add(base, m.player.position + Vector2(24, -8))
	m.character.bisaccia.add("provetta", 1)
	var c2 := Vector2i(floori(cr2.position.x / 16.0), floori(cr2.position.y / 16.0))
	var sampled: bool = st.sample(c2, "provetta")
	var g3 := st.grade(base)
	var tip3: String = WorldTip.creature(m, cr2).plain()
	var mult: float = st.mult(base)
	m.fauna.clear()
	print("studio: %s da %d a %d (vista), %d (sconfitta), %d (studiata con la Provetta %s); prima la scheda nasconde %s, dopo mostra %s; danno ×%.2f" % [
		base, g0, g1, g2, g3, "sì" if sampled else "NO", "sì" if tip1.contains("studiala") else "NO",
		"sì" if tip3.contains("fuoco") or tip3.contains("Debole") else "NO", mult])
	if g0 != 0 or g1 != 1 or g2 != 2 or g3 != 3 or not sampled or mult <= 1.0 or not tip1.contains("studiala"):
		print("ATTENZIONE: lo studio delle creature non va come dovrebbe")
