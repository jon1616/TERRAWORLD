class_name TestsHome
extends RefCounted
## Prove della Roadmap 8 nel Giardino vero (`-- --prove --prova-giardino`: una partita nuova, come dal menu, con il
## gene «brina» per il primo Seme). Voce 62: l'isola nel Vuoto con l'Albero-Madre e l'Aiuola, niente creature né
## firma, il primo Seme dall'Albero, il portale verso il primo mondo (vigore 1), il Vuoto che respinge chi cade;
## foto 101_giardino.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	await garden()
	await stages()
	await powers()
	await villagers()
	await board()


func garden() -> void:
	var g: Giardino = m.giardino
	var grass := 0
	for x in world.w:
		if TileDefs.is_grass(world.tile(x, world.surface[x])):
			grass += 1
	print("Giardino: %d×%d, Giardino attivo %s, Albero-Madre %s, Aiuole %d, partenza %s sull'isola %s, colonne d'erba %d, alberi %d, creature %d, firma %s, casa %s" % [
		world.w, world.h, "sì" if g.active else "NO", world.stations.get(g.tree_o, "NESSUNO"), m.aiuole.count(), world.spawn,
		"sì" if world.solid(world.spawn.x, world.spawn.y + 1) else "NO", grass, _trees(), m.fauna.list.size(),
		m.world_meta.get("firma", {}), "sì" if m.aiuole.is_home() else "NO"])
	m.snap_to(world.spawn)
	m.boons.add("bagliore", 5.0)
	await kit.seconds(0.8)
	await kit.save("101_giardino")
	# il primo Seme
	var b := kit.bisaccia()
	var s0 := b.count("seme_mondo") + b.count("seme_mondo_brina")
	g.touch_tree(g.tree_o)
	var seed_slot := -1
	for i in b.slots.size():
		if String(ItemsData.get_item(b.id_at(i)).get("kind", "")) == "seme_mondo":
			seed_slot = i
	var dati: Dictionary = b.data_at(seed_slot) if seed_slot >= 0 else {}
	print("primo Seme: %s, geni %s, vigore %d" % [b.id_at(seed_slot) if seed_slot >= 0 else "NESSUNO", dati.get("geni", []),
		int(dati.get("vigore", 0))])
	m.guardian.lore.visible = false
	# nell'Aiuola: il portale verso il primo mondo
	var ai := Vector2i(-1, -1)
	for o in world.stations:
		if world.stations[o] == "aiuola":
			ai = o
	var planted := false
	var dest := []
	if ai.x >= 0 and seed_slot >= 0:
		m.snap_to(ai + Vector2i(-2, 3))
		kit.hold(b.id_at(seed_slot))
		planted = m.portal.plant(ai + Vector2i(1, 2), m.hud.current()["id"])
		await kit.frames(2)
		if world.stations.get(ai, "") == "portale":
			dest = m.portal.destination(ai)
	print("nell'Aiuola: piantato %s, portale %s verso «%s» (vigore %s)" % ["sì" if planted else "NO",
		"sì" if world.stations.get(ai, "") == "portale" else "NO", dest[1] if dest.size() > 1 else "-", dest[3] if dest.size() > 3 else "-"])
	# il Vuoto
	m.snap_to(Vector2i(world.spawn.x, mini(world.h - 3, int(m.world_meta["isola_fondo"]) + Giardino.FALL + 4)))
	await kit.seconds(0.5)
	var back: bool = m.player.position.distance_to(m.cell_to_feet(world.spawn)) < 3 * S
	print("caduta nel Vuoto: respinto all'Albero %s" % ("sì" if back else "NO"))
	if not g.active or not world.stations.get(g.tree_o, "").begins_with("albero_madre") or seed_slot < 0 or not planted \
			or int(dati.get("vigore", 0)) != 1 or not "brina" in dati.get("geni", []) or not back or m.fauna.list.size() > 0:
		print("ATTENZIONE: il Giardino non funziona come dovrebbe")


func _trees() -> int:
	var n := 0
	for k in world.trees:
		n += (world.trees[k] as Array).size()
	return n


## Voce 63: gli stadi dell'Albero-Madre. Il primo stadio con le offerte vere (legno e humus dalla Bisaccia, il primo
## viaggio), il pannello (foto 102_albero), poi tutti gli altri stadi fino al risveglio (foto 103_albero_sveglio):
## Aiuole, disegno dell'Albero, poteri, abitanti e categorie d'innesto crescono con gli stadi.
func stages() -> void:
	var am: AlberoMadre = m.albero
	var b := kit.bisaccia()
	kit.make_room()
	var ai0: int = m.aiuole.max_aiuole()
	var line0 := String(am._label.text)
	am.open()
	await kit.frames(4)
	await kit.save("102_albero")
	am.panel.visible = false
	var ready0 := am.ready_to_wake()
	b.add("legno", 20)
	var given1 := am.offer()
	b.add("legno", 15)
	b.add("humus", 30)
	var given2 := am.offer()
	var ready1 := am.ready_to_wake()
	m.character.stats["viaggi"] = 1
	var woke := am.awaken()
	await kit.frames(3)
	var ph1: String = world.stations.get(m.giardino.tree_o, "")
	print("Albero-Madre: all'inizio pronto %s; offerti %d poi %d (pronto senza il viaggio: %s); dopo il viaggio si sveglia %s → stadio %d, Aiuole %d → %d, disegno %s; la riga dice «%s»" % [
		"sì (sbagliato)" if ready0 else "no", given1, given2, "sì (sbagliato)" if ready1 else "no", "sì" if woke else "NO",
		am.stage(), ai0, m.aiuole.max_aiuole(), ph1, line0])
	m.guardian.lore.visible = false
	# gli altri stadi: si danno le offerte e i traguardi richiesti
	var grafts0: Array = am.graftable()
	while not am.done():
		var st: Dictionary = am.current()
		for o in st["offers"]:
			if o.has("item"):
				b.add(String(o["item"]), int(o["n"]))
			else:
				m.character.stats[String(o["stat"])] = maxi(int(m.character.stats.get(String(o["stat"]), 0)), int(o["n"]))
		am.offer()
		if not am.awaken():
			print("ATTENZIONE: lo stadio «%s» non si sveglia" % st["name"])
			break
		m.guardian.lore.visible = false
		kit.make_room()
	await kit.frames(3)
	m.snap_to(m.giardino.tree_o + Vector2i(-4, 12))
	m.boons.add("bagliore", 4.0)
	await kit.seconds(0.8)
	await kit.save("103_albero_sveglio")
	print("risveglio: stadio %d, disegno %s, Aiuole %d, poteri %s, abitanti %s, categorie d'innesto %d → %d" % [am.stage(),
		world.stations.get(m.giardino.tree_o, ""), m.aiuole.max_aiuole(), MotherTreeData.gifts(am.stage(), "power"),
		MotherTreeData.gifts(am.stage(), "npc"), grafts0.size(), am.graftable().size()])
	if ready0 or not woke or am.stage() != MotherTreeData.STAGES.size() or ph1 != "albero_madre_1" \
			or m.aiuole.max_aiuole() != 1 + MotherTreeData.aiuole(am.stage()) or am.graftable().size() != GenesData.CATEGORIES.size():
		print("ATTENZIONE: gli stadi dell'Albero-Madre non funzionano come dovrebbero")


## Voce 64: i poteri (dopo il risveglio li ha tutti e sei). Un Sigillo di radice costruito sull'isola si apre solo con
## il Canto delle radici; la Vista mostra le vene; la passerella di radici; il salto in più; foto 104_sigillo.
func powers() -> void:
	var pw: Powers = m.powers
	var owned := pw.owned.duplicate()
	# un luogo sigillato di prova sul bordo dell'isola
	var x := world.spawn.x - 40
	var y := world.surface[x] + 4
	var ps := PassSigilli.new()
	ps._vault(world, x, y, TileDefs.SIG_RADICE, "radice", 1, RandomNumberGenerator.new())
	for dx in range(-1, PassSigilli.W + 2, 3):
		m.view.refresh_around(Vector2i(x + dx, y))
	m.snap_to(Vector2i(x - 3, world.surface[x - 3] - 1))
	var seal := Vector2i(x - 1, y + 1)
	pw.extra = []
	var had := pw.has("canto")
	pw.owned.erase("canto")
	var closed := pw.open_seal(seal) and world.tile(seal.x, seal.y) == TileDefs.SIG_RADICE
	pw.owned.append("canto")
	var opened := pw.open_seal(seal) and world.tile(seal.x, seal.y) == TileDefs.AIR
	var left := 0
	for yy in range(y - 1, y + PassSigilli.H + 1):
		for xx in range(x - 1, x + PassSigilli.W + 1):
			if world.tile(xx, yy) == TileDefs.SIG_RADICE:
				left += 1
	var chest_o := Vector2i(x + PassSigilli.W / 2 - 1, y + PassSigilli.H - int(StationsData.STATIONS["scrigno"]["size"][1]))
	var frag := world.chest_at(chest_o).count("frammento_albero") if world.stations.get(chest_o, "") == "scrigno" else 0
	m.snap_to(Vector2i(x + 2, y + PassSigilli.H - 1))
	m.boons.add("bagliore", 4.0)
	await kit.seconds(0.6)
	await kit.save("104_sigillo")
	var v: Dictionary = pw.vista()
	var bridge := pw.bridge(m.player.position + Vector2(10 * S, -3 * S))
	print("poteri: %s; Sigillo di radice senza Canto chiuso %s, con il Canto aperto %s (resta %d), Frammento nello scrigno %d; Vista %s; passerella %d tessere; salti in aria %d" % [
		owned, "sì" if closed else "NO", "sì" if opened else "NO", left, frag, v, bridge, m.player.air_jumps])
	if owned.size() != 6 or not had or not closed or not opened or left > 0 or frag < 1 or bridge < 5 or m.player.air_jumps < 1:
		print("ATTENZIONE: i poteri non funzionano come dovrebbero")


## Voce 65: gli abitanti dell'Albero-Madre. La Vecchia Radice arriva accanto all'Albero senza letto; con un Focolare e
## i letti arrivano gli altri; affetto con un dono che piace, sconto, una richiesta consegnata con la ricompensa;
## foto 105_abitanti con il commercio del Mercante di Semi.
func villagers() -> void:
	var vl: Villagers = m.villagers
	var first := vl.check()
	# un Focolare e sei letti sull'isola, a sinistra della partenza
	var base := world.spawn + Vector2i(-26, 0)
	kit.flatten(base, 16)
	world.stations[base + Vector2i(0, -int(StationsData.STATIONS["focolare"]["size"][1]) + 1)] = "focolare"
	for k in 6:
		var o := base + Vector2i(-14 + k * 4 + (5 if k >= 3 else 0), -int(StationsData.STATIONS["letto"]["size"][1]) + 1)
		world.stations[o] = "letto"
	for o in world.stations:
		m.view.add_station(o)
	var came := [first]
	for k in 8:
		var n := vl.check()
		if n == "":
			break
		came.append(n)
	var ch: Character = m.character
	var tp: TradePanel = vl.panel
	var b := kit.bisaccia()
	kit.make_room()
	b.add("lumino", 2000)
	tp.open("mercante_semi")
	var p0 := tp._price("seme_mondo_brina", 1)
	# un dono che piace, tre volte
	for k in 3:
		b.add("fungo_luminoso", 3)
		var i := kit.slot_of("fungo_luminoso") if kit.slot_of("fungo_luminoso") >= 0 else Bisaccia.HOTBAR
		m.hud.panel.held = b.slots[i]
		b.slots[i] = {}
		tp.gift_held()
	var p1 := tp._price("seme_mondo_brina", 1)
	var lv := NpcBonds.level(ch, "mercante_semi")
	b.add("fungo_luminoso", 10)
	var q0: String = NpcBonds.quest(ch, "mercante_semi").get("text", "")
	var mos0 := b.count("seme_mondo_mosaico")
	var ok := tp.deliver()
	var bought := tp.buy(0)
	await kit.frames(4)
	await kit.save("105_abitanti")
	tp.close()
	m.hud.panel.toggle()
	print("abitanti: arrivati %s; Mercante di Semi: affetto %d (livello %d), prezzo %d → %d; richiesta «%s» consegnata %s (Seme mosaico %d → %d); comprato %s" % [
		came, NpcBonds.affetto(ch, "mercante_semi"), lv, p0, p1, q0, "sì" if ok else "NO", mos0, b.count("seme_mondo_mosaico"),
		"sì" if bought else "NO"])
	if first != "vecchia_radice" or not "mercante_semi" in came or not "cartografo" in came or p1 >= p0 or not ok:
		print("ATTENZIONE: gli abitanti dell'Albero-Madre non funzionano come dovrebbero")


## Voce 67: la Bacheca dei Giardinieri: sempre quattro richieste sensate; una fornitura consegnata con il premio, una
## cambiata; tanti giri a vuoto per vedere che le richieste restano fattibili; foto 108_bacheca.
func board() -> void:
	var bd: Board = m.board
	var has_station := false
	for o in world.stations:
		if world.stations[o] == "bacheca":
			has_station = true
	bd.open()
	await kit.frames(4)
	await kit.save("108_bacheca")
	var types := []
	for r in bd.open_list():
		types.append(r["tipo"])
	# una fornitura: si portano gli oggetti e si consegna
	var b := kit.bisaccia()
	kit.make_room()
	var i := -1
	for k in bd.open_list().size():
		if String(bd.open_list()[k]["tipo"]) in ["fornitura", "gene", "prodotto"]:
			i = k
	var delivered := false
	var lum0 := b.count("lumino")
	if i >= 0:
		var r: Dictionary = bd.open_list()[i]
		b.add(String(r["cosa"]), int(r["n"]))
		delivered = bd.deliver(i)
	bd.swap(0)
	# tante richieste nuove: sono sempre di tipi che il personaggio può fare
	var kinds := {}
	for k in 60:
		var r := bd.make()
		kinds[r["tipo"]] = int(kinds.get(r["tipo"], 0)) + 1
	bd.panel.visible = false
	print("Bacheca: nel Giardino %s; aperte %d (%s); consegnata una %s (Lumini %d → %d), dopo ancora %d aperte; 60 richieste nuove: %s" % [
		"sì" if has_station else "NO", bd.open_list().size(), types, "sì" if delivered else "NO (nessuna fornitura)", lum0,
		b.count("lumino"), bd.open_list().size(), kinds])
	if not has_station or bd.open_list().size() < Board.OPEN or (i >= 0 and not delivered) or kinds.size() < 4:
		print("ATTENZIONE: la Bacheca non funziona come dovrebbe")
