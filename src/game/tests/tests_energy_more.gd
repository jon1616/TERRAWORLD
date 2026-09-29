class_name TestsEnergyMore
extends RefCounted
## Roadmap 19: le prove della rete dalla voce 196 in poi (sorgenti speciali, riserve, macchine, logica). Usa gli aiuti
## di `TestsEnergy` (`place`, `lay`, `ticks`, `clean_spot`).

var kit: TestKit
var m: Node
var t: TestsEnergy


func _init(tk: TestKit, base: TestsEnergy) -> void:
	kit = tk
	m = tk.m
	t = base


## Voce 196: la ruota della mandria, il parafulmine, la Radice-madre, la Radice del Giardino.
func special() -> void:
	var e: Energy = m.energy
	var w: World = m.world
	var p: Vector2i = await t.clean_spot(130, 36)
	var y := p.y
	# la ruota della mandria: una creatura della mandria di livello 3 che corre dentro = 25 pulsi; affamata niente
	var wheel := t.place("ruota_mandria", Vector2i(p.x, y))
	await t.ticks(2)
	var rm: Machine = e.machines[wheel]
	var cr: Creature = m.fauna.add("pecora_muschio", Vector2(wheel) * 16.0 + Vector2(24, 16))
	cr.set_process(false)
	cr.tame = BhMandria.new()
	cr.tame.rec = {"lvl": 3, "fame": 0.1}
	cr.vel = Vector2(60, 0)
	var running := rm.bh.produce(rm, e)
	cr.tame.rec["fame"] = 0.95
	var hungry := rm.bh.produce(rm, e)
	m.fauna.clear()
	print("ruota della mandria: una creatura di livello 3 dà %.0f pulsi, affamata %.0f" % [running, hungry])
	# il parafulmine: un fulmine nel temporale riempie l'Otre della sua rete
	var rod := t.place("parafulmine", Vector2i(p.x + 6, y))
	var otre := t.place("otre_linfa", Vector2i(p.x + 7, y))
	t.lay_row(p.x + 6, p.x + 7, y, 1)
	await t.ticks(2)
	var target: int = e.bolt_target(m.player_cell().x)
	var g0 := float((e.machines[otre] as Machine).st.get("g", 0.0))
	var hit: Vector2i = m.weather.strike()
	await t.ticks(1)
	var g1 := float((e.machines[otre] as Machine).st.get("g", 0.0))
	print("parafulmine: attira il fulmine sulla sua colonna %s, l'Otre da %.0f a %.0f gocce" % [target == rod.x and hit.x == rod.x, g0, g1])
	# la Radice-madre accanto al Cuore del mondo: curato 250, sconfitto 120, dorme 0
	var heart := Vector2i(p.x + 12, y - 2)
	w.stations[heart] = "cuore_vivo"
	var root := t.place("radice_madre", Vector2i(p.x + 16, y))
	await t.ticks(2)
	var mm: Machine = e.machines[root]
	var g_state = m.world_meta.get("guardiano", "dorme")
	m.world_meta["guardiano"] = "curato"
	var cured := mm.bh.produce(mm, e)
	m.world_meta["guardiano"] = "sconfitto"
	var beaten := mm.bh.produce(mm, e)
	m.world_meta["guardiano"] = "dorme"
	var asleep := mm.bh.produce(mm, e)
	m.world_meta["guardiano"] = g_state
	w.stations.erase(heart)
	print("Radice-madre: Cuore guarito %.0f, ferito %.0f, che dorme %.0f" % [cured, beaten, asleep])
	# la Radice del Giardino: fuori dal Giardino niente, nel Giardino vicino all'Albero 50 a stadio
	var groot := t.place("radice_giardino", Vector2i(p.x + 22, y))
	await t.ticks(2)
	var gm: Machine = e.machines[groot]
	var outside := gm.bh.produce(gm, e)
	var was_garden = m.world_meta.get("giardino", false)
	m.world_meta["giardino"] = true
	var tree_o := Vector2i(p.x + 28, y - 3)
	w.stations[tree_o] = "albero_madre_1"
	var inside := gm.bh.produce(gm, e)
	w.stations.erase(tree_o)
	m.world_meta["giardino"] = was_garden
	print("Radice del Giardino: fuori dal Giardino %.0f, vicino all'Albero %.0f (stadio %d)" % [outside, inside, m.albero.stage()])
	var ok := running >= 24.0 and hungry == 0.0 and target == rod.x and g1 >= g0 + 2900.0 and cured == 250.0 \
		and beaten == 120.0 and asleep == 0.0 and outside == 0.0 and inside >= 50.0
	if not ok:
		print("ATTENZIONE: le sorgenti speciali non danno ciò che devono")
	for o in [wheel, rod, otre, root, groot]:
		t.unplace(o)


## Voce 197: le riserve grandi e il lavoro mentre sei via (un'ora finta = mezz'ora di lavoro; dieci ore = un'ora).
func reserves() -> void:
	var e: Energy = m.energy
	var p: Vector2i = await t.clean_spot(180, 12)
	var y := p.y
	var leaf := t.place("foglia_lanterna", Vector2i(p.x, y))
	var tank := t.place("baccello_serbatoio", Vector2i(p.x + 3, y))
	t.lay_row(p.x, p.x + 4, y, 2)
	m.day.time = 0.5
	m.day.apply(true)
	await t.ticks(6)
	var tm: Machine = e.machines[tank]
	var g0 := float(tm.st.get("g", 0.0))
	var charging := g0 > 0.0
	# un'ora via: mezz'ora di lavoro, la foglia (12 pulsi) riempie il serbatoio di 21600 gocce (tetto 20000)
	tm.st["g"] = 0.0
	e.meta()["visto"] = Time.get_unix_time_from_system() - 3600.0
	var w0 := e.away_worked
	var note := EnergyAway.run(e)
	var worked := e.away_worked - w0
	var g1 := float(tm.st.get("g", 0.0))
	# dieci ore via: al più un'ora di lavoro
	e.meta()["visto"] = Time.get_unix_time_from_system() - 36000.0
	var w1 := e.away_worked
	EnergyAway.run(e)
	var capped := e.away_worked - w1
	print("riserve: il serbatoio si carica al sole %s; via un'ora: %d s di lavoro, serbatoio %.0f gocce («%s»); via dieci ore: %d s" % [
		charging, roundi(worked), g1, note, roundi(capped)])
	if not (charging and absf(worked - 1800.0) < 31.0 and g1 >= 19999.0 and absf(capped - 3600.0) < 31.0 and note.contains("minuti")):
		print("ATTENZIONE: le riserve o il lavoro mentre si è via non vanno come dovrebbero")
	t.unplace(leaf)
	t.unplace(tank)


## Una macchina con un Otre pieno accanto e una vena di legnoferro sotto entrambi (per le macchine che chiedono poco).
func powered(id: String, c: Vector2i, reserve := "otre_linfa") -> Vector2i:
	var o := t.place(id, c)
	var sz: Array = StationsData.STATIONS[id]["size"]
	var ot := t.place(reserve, Vector2i(c.x + int(sz[0]), c.y))
	var rs: Array = StationsData.STATIONS[reserve]["size"]
	t.lay_row(c.x, c.x + int(sz[0]) + int(rs[0]) - 1, c.y, 2)
	await t.ticks(2)
	(m.energy.machines[ot] as Machine).st["g"] = float(MachinesData.get_machine(reserve)["cap"])
	await t.ticks(2)
	return o


## Voce 198: l'ascensore porta su, il nastro sposta, la catapulta lancia, la porta-seme porta dall'altra parte.
func moving() -> void:
	var e: Energy = m.energy
	var p: Vector2i = await t.clean_spot(210, 40)
	var y := p.y
	var ctl: bool = m.player.control
	m.player.control = false
	# l'ascensore: tenendo il salto nella colonna si sale
	var lift := await powered("ascensore_bolla", Vector2i(p.x, y))
	m.snap_to(Vector2i(p.x, y - 1))
	await kit.frames(3)
	var y0: float = m.player.position.y
	m.player.auto_jump = true
	await kit.seconds(1.5)
	m.player.auto_jump = false
	var rose: float = (y0 - m.player.position.y) / 16.0
	var col_ok: bool = m.gravity.columns.has("%d,%d" % [lift.x, lift.y])
	await kit.seconds(1.5)
	print("ascensore a bolla: colonna accesa %s, in 1,5 s si sale di %.1f tessere" % [col_ok, rose])
	# il nastro vivo: un oggetto posato sopra si sposta
	var belt := await powered("nastro_vivo", Vector2i(p.x + 6, y))     # quattro in fila (l'Otre a destra del primo)
	for k in range(1, 4):
		t.place("nastro_vivo", Vector2i(p.x + 6 - k, y))
	t.lay_row(p.x + 3, p.x + 6, y, 2)
	await t.ticks(3)
	belt = Vector2i(p.x + 3, y)
	m.snap_to(Vector2i(p.x + 30, y))                    # lontano: gli oggetti vicini volano nella Bisaccia
	await kit.frames(2)
	m.drops.spawn("legno", 1, Vector2(belt) * 16.0 + Vector2(8, 0))
	var item: Dictionary = m.drops._items[-1]
	await kit.seconds(0.2)
	var d0: Vector2 = (item["node"] as Node2D).position
	await kit.seconds(0.8)
	var moved: float = (item["node"] as Node2D).position.x - d0.x if is_instance_valid(item["node"]) else 0.0
	print("nastro vivo: l'oggetto si sposta di %.0f px in 0,8 s" % moved)
	# la catapulta: il Germogliato sopra viene lanciato in su
	var cat := await powered("catapulta_spore", Vector2i(p.x + 16, y))
	m.snap_to(Vector2i(p.x + 16, y))
	await kit.frames(3)
	e.touch(cat)
	var vy: float = m.player.vel.y
	await kit.seconds(1.5)
	print("catapulta di spore: velocità in su %.0f px/s" % -vy)
	# la porta-seme: da una all'altra
	var g1 := await powered("porta_seme", Vector2i(p.x + 22, y))
	var g2 := t.place("porta_seme", Vector2i(p.x + 34, y))
	await t.ticks(2)
	m.snap_to(Vector2i(p.x + 23, y))
	await kit.frames(3)
	e.touch(g1)
	await kit.frames(3)
	var arrived: bool = absi(m.player_cell().x - (g2.x + 1)) <= 1
	print("porta-seme: arrivato all'altra porta %s" % arrived)
	m.player.control = ctl
	if not (col_ok and rose > 8.0 and absf(moved) > 60.0 and -vy > 400.0 and arrived):
		print("ATTENZIONE: le macchine del movimento non vanno come dovrebbero")
	for o in e.machines.keys():
		if o.x >= p.x - 2 and o.x <= p.x + 40:
			t.unplace(o)


## Voce 199: luce, liquidi, giardino e mandria.
func garden_light_liquids() -> void:
	var e: Energy = m.energy
	var w: World = m.world
	var p: Vector2i = await t.clean_spot(260, 60)
	var y := p.y
	# il faro e la cupola: zone di quiete; la serra: zona di crescita
	var faro := await powered("faro_linfa", Vector2i(p.x, y))
	var cup := await powered("cupola_quiete", Vector2i(p.x + 4, y), "baccello_serbatoio")
	var serra := await powered("serra_linfa", Vector2i(p.x + 10, y))
	await t.ticks(2)
	var fpos := (Vector2(faro) + Vector2(0.5, 1.0)) * 16.0
	var quiet_near: float = m.zones.add_at(fpos + Vector2(10 * 16, 0), "quiete")
	var quiet_far: float = m.zones.add_at(fpos + Vector2(0, 45 * 16), "quiete")
	var grow: float = m.zones.mult_at((Vector2(serra) + Vector2(1, 1)) * 16.0, "crescita")
	var faro_lit: bool = (e.machines[faro] as Machine).lit
	print("faro acceso %s, quiete vicino %.1f e lontano %.1f, serra: crescita ×%.2f" % [faro_lit, quiet_near, quiet_far, grow])
	# la pompa: l'acqua della buca sotto va allo sbocco
	var px := p.x + 16
	for yy in range(y + 1, y + 4):                         # una buca murata: l'acqua non scappa di lato né sotto
		w.set_tile(px - 1, yy, TileDefs.STONE)
		w.set_tile(px + 1, yy, TileDefs.STONE)
	w.set_tile(px, y + 3, TileDefs.STONE)
	for yy in range(y + 1, y + 3):
		w.set_tile(px, yy, TileDefs.AIR)
		w.set_liq(px, yy, 8, LiquidsData.ACQUA)
	var pump := await powered("pompa_radice", Vector2i(px, y))
	var spout := t.place("sbocco_radice", Vector2i(px + 4, y - 3))
	t.lay_row(px + 2, px + 4, y, 2)
	for yy in range(y - 3, y):
		t.lay(Vector2i(px + 4, yy), 2)
	await t.ticks(10)
	var pumped := int((e.machines[pump] as Machine).st.get("mosso", 0))    # poi l'acqua scorre via dallo sbocco
	print("pompa: %d livelli d'acqua portati allo sbocco (sotto la pompa ne restano %d)" % [pumped, w.liq(px, y + 1) + w.liq(px, y + 2)])
	# la chiusa: il clic destro la apre
	var gate := await powered("chiusa_radice", Vector2i(p.x + 24, y))
	await t.settle(0.3)
	var closed0: bool = w.tile(gate.x, gate.y) == TileDefs.PORTA
	e.touch(gate)
	await t.settle(0.4)
	var opened: bool = w.tile(gate.x, gate.y) == TileDefs.AIR
	print("chiusa: chiusa all'inizio %s, il clic destro la apre %s" % [closed0, opened])
	# l'irrigatore annaffia, la mietitrice raccoglie
	var crop := String(CropsData.CROPS.keys()[0])
	var c1 := Vector2i(p.x + 32, y)
	var c2 := Vector2i(p.x + 34, y)
	w.crops[c1] = [crop, 200.0, false]
	w.crops[c2] = [crop, 0.0, true]
	w.set_decor(c2.x, c2.y, int(CropsData.CROPS[crop]["decor"]))
	for xx in range(p.x + 29, p.x + 31):                       # una piccola buca d'acqua
		w.set_tile(xx, y + 1, TileDefs.AIR)
		w.set_liq(xx, y + 1, 8, LiquidsData.ACQUA)
		w.set_tile(xx, y + 2, TileDefs.STONE)
	var irr := await powered("irrigatore", Vector2i(p.x + 28, y))
	var har := await powered("falciatrice_radice", Vector2i(p.x + 36, y))
	await t.settle(4.5)
	var watered := bool(w.crops[c1][2])
	var box: Bisaccia = w.chest_at(har)
	var harvested := not box.is_empty() and float(w.crops[c2][1]) > 0.0
	print("irrigatore: la coltura è annaffiata %s; mietitrice: raccolto nella cassetta %s e ripiantato" % [watered, harvested])
	# la mungitrice: la lana del recinto va nella sua cassetta
	var pen := Vector2i(p.x + 42, y - 1)
	w.stations[pen] = "recinto"
	w.chest_at(pen).add("lana_muschio", 3)
	var milk := await powered("mungitrice", Vector2i(p.x + 46, y))
	await t.settle(2.5)
	var milked: int = w.chest_at(milk).count("lana_muschio")
	w.chests.erase(pen)
	w.stations.erase(pen)
	# la culla: le uova dell'Incubatrice vicina covano più in fretta
	var inc := Vector2i(p.x + 50, y)
	w.stations[inc] = "incubatrice"
	w.chest_at(inc).add_stack({"id": "uovo", "n": 1, "dati": {"specie": "pecora_muschio"}})
	var cradle := await powered("culla_calda", Vector2i(p.x + 53, y))
	await t.ticks(2)
	var fast := float((w.chest_at(inc).slots[0].get("dati", {}) as Dictionary).get("cova_mult", 1.0))
	w.chests.erase(inc)
	w.stations.erase(inc)
	print("mungitrice: lana portata via %d; culla calda: le uova covano ×%.1f" % [milked, fast])
	await kit.save("235_macchine_199")
	var ok := faro_lit and quiet_near > 0.0 and quiet_far == 0.0 and grow > 1.5 and pumped >= 16 and closed0 and opened \
		and watered and harvested and milked == 3 and fast < 0.7
	if not ok:
		print("ATTENZIONE: le macchine di luce, liquidi e giardino non fanno ciò che devono")
	for o in m.energy.machines.keys():
		if o.x >= p.x - 2 and o.x <= p.x + 62:
			if w.chests.has(o):
				w.chests.erase(o)
			t.unplace(o)


## Voce 200: forno, frantoio, telaio, braccio, smistatore, nodo delle casse (tutti insieme, poi si guarda).
func factory() -> void:
	var e: Energy = m.energy
	var w: World = m.world
	var p: Vector2i = await t.clean_spot(330, 70)
	var y := p.y
	var forno := await powered("forno_linfa", Vector2i(p.x, y))
	w.chest_at(forno).add("minerale_radicite", 6)
	var mill := await powered("frantoio", Vector2i(p.x + 5, y), "baccello_serbatoio")
	w.chest_at(mill).add("minerale_legnoferro", 3)
	var loom := await powered("telaio_linfa", Vector2i(p.x + 11, y))
	var lm: Machine = e.machines[loom]
	var trec: Dictionary = {}
	for r in RecipesData.all():
		if String(r.get("station", "")) == "telaio" and not r.has("parole"):
			trec = r
			break
	lm.st["ricetta"] = String(trec["out"])
	for id in trec["in"]:
		w.chest_at(loom).add(String(id), int(trec["in"][id]))
	# il braccio: dalla cesta a sinistra a quella a destra
	var arm := t.place("braccio_radice", Vector2i(p.x + 18, y))          # cesta | braccio | cesta, l'Otre più in là
	var cl := t.place("cesta", Vector2i(p.x + 16, y))
	var cr := t.place("cesta", Vector2i(p.x + 19, y))
	var aot := t.place("otre_linfa", Vector2i(p.x + 22, y))
	t.lay_row(p.x + 18, p.x + 22, y, 2)
	await t.ticks(2)
	(e.machines[aot] as Machine).st["g"] = 3000.0
	w.chest_at(cl).add("legno", 5)
	# lo smistatore: gli oggetti a terra nella cesta della sua rete che li ha già
	var sorter := await powered("smistatore", Vector2i(p.x + 26, y))
	var target := t.place("cesta", Vector2i(p.x + 32, y))
	t.lay_row(p.x + 26, p.x + 33, y, 2)
	w.chest_at(target).add("ardesia", 1)
	await t.ticks(2)
	m.snap_to(Vector2i(p.x + 40, y))
	await kit.frames(2)
	m.drops.spawn("ardesia", 4, (Vector2(sorter) + Vector2(0.5, 0.5)) * 16.0)
	# il nodo delle casse: una cesta lontana sulla sua rete dà gli ingredienti
	var node := await powered("nodo_casse", Vector2i(p.x + 44, y))
	var far := t.place("cesta", Vector2i(p.x + 64, y))
	t.lay_row(p.x + 44, p.x + 65, y, 2)
	w.chest_at(far).add("gelatina", 7)
	await t.ticks(2)
	m.snap_to(Vector2i(p.x + 46, y))
	await kit.seconds(7.0)
	var ingots: int = w.chest_at(forno).count("lingotto_radicite")
	var dust: int = w.chest_at(mill).count("polvere_legnoferro")
	var woven: int = w.chest_at(loom).count(String(trec["out"]))
	var carried: int = w.chest_at(cr).count("legno")
	var sorted: int = w.chest_at(target).count("ardesia")
	var pooled := false
	for b in Crafting.pool:
		if b == w.chests[far]:
			pooled = true
	print("forno: %d lingotti; frantoio: %d polveri; telaio: %d «%s»; braccio: %d legni portati; smistatore: %d ardesie nella cesta; nodo delle casse: la cesta lontana dà gli ingredienti %s" % [
		ingots, dust, woven, trec["out"], carried, sorted, pooled])
	await kit.save("236_fabbrica")
	if not (ingots >= 1 and dust == 4 and woven >= 1 and carried >= 3 and sorted >= 5 and pooled):
		print("ATTENZIONE: le macchine che fabbricano e smistano non fanno ciò che devono")
	for o in m.energy.machines.keys() + [cl, cr, target, far]:
		if o.x >= p.x - 2 and o.x <= p.x + 70:
			if w.chests.has(o):
				w.chests.erase(o)
			t.unplace(o)


## Voce 201: la Trivella scava con il piccone della cassetta e si ferma davanti a ciò che è troppo duro.
func drill() -> void:
	var e: Energy = m.energy
	var w: World = m.world
	var p: Vector2i = await t.clean_spot(420, 10)
	var y := p.y
	var dr := await powered("trivella_radice", Vector2i(p.x, y), "baccello_serbatoio")
	var dm: Machine = e.machines[dr]
	await t.ticks(2)
	var no_pick := String(dm.get_meta("stop", ""))
	# sotto: tre righe di terra, poi una riga di vuotite (vuole il legnoferro)
	for x in range(p.x, p.x + 3):
		for yy in range(y + 1, y + 4):
			w.set_tile(x, yy, TileDefs.DIRT)
		w.set_tile(x, y + 4, TileDefs.VUOTITE)
	w.chest_at(dr).add("piccone_radicite", 1)
	await kit.seconds(6.0)
	var dug := int(dm.st.get("scavati", 0))
	var soil: int = w.chest_at(dr).count("humus")
	var stop := String(dm.get_meta("stop", ""))
	print("trivella: senza piccone «%s»; con il piccone di radicite scavati %d (humus %d), poi «%s»" % [no_pick, dug, soil, stop])
	if not (no_pick.contains("piccone") and dug >= 9 and soil >= 9 and stop.contains("troppo duro")):
		print("ATTENZIONE: la Trivella non scava come dovrebbe")
	for o in e.machines.keys():
		if o.x >= p.x - 2 and o.x <= p.x + 10:
			if w.chests.has(o):
				w.chests.erase(o)
			t.unplace(o)


## Voce 202: la torretta tira, la siepe punge, la campana suona, lo scudo raddoppia le porte, la leva arma le trappole.
func defense() -> void:
	var e: Energy = m.energy
	var w: World = m.world
	var p: Vector2i = await t.clean_spot(460, 50)
	var y := p.y
	m.fauna.clear()
	# la torretta: un grumo a 8 tessere
	var tur := await powered("torretta_spine", Vector2i(p.x, y))
	w.chest_at(tur).add("dardo", 20)
	var gr: Creature = m.fauna.add("grumo_muschio", Vector2((p.x + 8) * 16 + 8, (y + 1) * 16 - 6))
	gr.set_process(false)
	var hp0 := gr.hp
	var k0: int = m.fauna.kills
	await kit.seconds(2.5)
	var shot := int((e.machines[tur] as Machine).st.get("tiri", 0))
	var hurt: bool = m.fauna.kills > k0 or (is_instance_valid(gr) and gr.hp < hp0)
	m.fauna.clear()
	# la siepe di spine: punge chi la attraversa
	var hedge := await powered("siepe_spine", Vector2i(p.x + 12, y))
	var gr2: Creature = m.fauna.add("scarabeo_ardesia", (Vector2(hedge) + Vector2(0.5, 0.5)) * 16.0)
	gr2.set_process(false)
	var hp2 := gr2.hp
	await kit.seconds(1.2)
	var pricked: bool = not is_instance_valid(gr2) or gr2.hp < hp2
	m.fauna.clear()
	print("torretta: %d tiri, il grumo è ferito %s; siepe di spine: punge %s" % [shot, hurt, pricked])
	# la campana: suona
	var bell := await powered("campana_allarme", Vector2i(p.x + 16, y))
	e.touch(bell)
	var rang := int((e.machines[bell] as Machine).st.get("suoni", 0)) == 1
	# lo scudo: una porta sulla sua rete regge il doppio
	var door := Vector2i(p.x + 22, y - 1)
	w.stations[door] = "porta"
	var base_hits: int = m.wiles.door_strength(door)
	var shield := await powered("scudo_corteccia", Vector2i(p.x + 23, y), "baccello_serbatoio")
	t.lay(Vector2i(p.x + 22, y), 2)
	await t.ticks(3)
	var shielded_hits: int = m.wiles.door_strength(door)
	w.stations.erase(door)
	print("campana: suona %s; scudo di corteccia: la porta regge %d morsi invece di %d" % [rang, shielded_hits, base_hits])
	# le trappole: una leva le arma e le disarma
	var trap := t.place(TrapsData.id_of(String(TrapsData.TYPES.keys()[0]), 0), Vector2i(p.x + 30, y))
	var lever := t.place("leva_radice", Vector2i(p.x + 34, y))
	t.lay_row(p.x + 30, p.x + 34, y, 1 << VeinsData.WIRE_SHIFT)
	await t.ticks(2)
	await kit.frames(2)
	var off_now: bool = not m.traps.armed(trap)
	e.touch(lever)
	await kit.frames(3)
	var on_now: bool = m.traps.armed(trap)
	print("trappola con un filo: disarmata a leva giù %s, armata a leva su %s" % [off_now, on_now])
	await kit.save("237_difese")
	if not (shot >= 1 and hurt and pricked and rang and shielded_hits == base_hits * 2 and off_now and on_now):
		print("ATTENZIONE: le difese non fanno ciò che devono")
	for o in e.machines.keys() + [trap]:
		if o.x >= p.x - 2 and o.x <= p.x + 50:
			if w.chests.has(o):
				w.chests.erase(o)
			t.unplace(o)
	m.world_meta["trappole_ferme"] = []


## Voce 203: il carillon suona la sua nota, la fontana e la teca sono belle, la teca illumina il trofeo.
func play_decor() -> void:
	var e: Energy = m.energy
	var w: World = m.world
	var p: Vector2i = await t.clean_spot(520, 16)
	var y := p.y
	var bell := await powered("carillon_radice", Vector2i(p.x, y))
	var bm: Machine = e.machines[bell]
	bm.st["nota"] = 4
	var played0: int = int(m.sfx.played.get("stella", 0))
	e.touch(bell)
	var played: bool = int(m.sfx.played.get("stella", 0)) == played0 + 1 and int(bm.st.get("suoni", 0)) == 1
	var fount := await powered("fontana_linfa", Vector2i(p.x + 4, y))
	var case_o := await powered("esposizione", Vector2i(p.x + 9, y))
	w.chest_at(case_o).add(String(TrophyItemsData.TROPHY_OF.values()[0]), 1)
	await t.ticks(3)
	var lit: bool = (e.machines[case_o] as Machine).lit
	var pretty: bool = int(StationsData.STATIONS["fontana_linfa"].get("bello", 0)) == 6 and int(StationsData.STATIONS["esposizione"].get("bello", 0)) == 3
	print("carillon: suona la nota %s; fontana e teca belle nelle stanze %s; la teca con un trofeo si illumina %s" % [played, pretty, lit])
	if not (played and pretty and lit):
		print("ATTENZIONE: carillon, fontana o teca non fanno ciò che devono")
	for o in e.machines.keys():
		if o.x >= p.x - 2 and o.x <= p.x + 16:
			if w.chests.has(o):
				w.chests.erase(o)
			t.unplace(o)
