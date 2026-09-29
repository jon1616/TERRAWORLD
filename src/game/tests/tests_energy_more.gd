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
func powered(id: String, c: Vector2i) -> Vector2i:
	var o := t.place(id, c)
	var sz: Array = StationsData.STATIONS[id]["size"]
	var ot := t.place("otre_linfa", Vector2i(c.x + int(sz[0]), c.y))
	t.lay_row(c.x, c.x + int(sz[0]), c.y, 2)
	await t.ticks(2)
	(m.energy.machines[ot] as Machine).st["g"] = 3000.0
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
