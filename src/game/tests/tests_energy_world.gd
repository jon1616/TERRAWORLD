class_name TestsEnergyWorld
extends RefCounted
## Roadmap 19, voci 207-208: la rete e il mondo attorno (geni, Tempesta di Linfa, Succhiavena, Aiuole alimentate,
## Tessitrice, Bacheca). Gruppo `energia`, chiamate da `TestsEnergy.run`.

var t: TestsEnergy
var logic: TestsEnergyLogic
var kit: TestKit
var m: Node


func _init(tk: TestKit, owner: TestsEnergy, lg: TestsEnergyLogic) -> void:
	kit = tk
	t = owner
	logic = lg
	m = tk.m


## Voce 207: i geni della rete, la Tempesta di Linfa con e senza Valvola, il Succhiavena che beve solo le vene di radice.
func world_and_storm() -> void:
	var e: Energy = m.energy
	var w: World = m.world
	var p: Vector2i = await t.clean_spot(-360, 40)
	var y := p.y
	var genes0: Array = m.world_traits.genes.duplicate()
	# una Foglia-lanterna su una vena d'ambra con una Lampada
	var leaf := t.place("foglia_lanterna", Vector2i(p.x, y))
	var lamp := t.place("lampada_baccello", Vector2i(p.x + 6, y))
	t.lay_row(p.x, p.x + 6, y, 3)
	await t.ticks(3)
	var base: float = (e.machines[leaf] as Machine).made
	m.world_traits.genes = genes0 + ["sole_linfa", "terra_conduce"]
	e.rebuild()
	await t.ticks(3)
	var sunny: float = (e.machines[leaf] as Machine).made
	var cond := is_equal_approx(EnergyGraph.cap_mult, 1.5)
	m.world_traits.genes = genes0
	e.rebuild()
	await t.ticks(2)
	var genes_ok := base > 0.0 and is_equal_approx(sunny, base * 1.5) and cond and is_equal_approx(EnergyGraph.cap_mult, 1.0)
	# la Tempesta: sorgenti al 150%; senza valvola le vene di radice si spezzano, con la valvola no
	var ev_paused: bool = m.events.paused
	m.events.paused = true
	m.events.start("tempesta_linfa")
	t.lay_row(p.x + 7, p.x + 12, y, 1)                    # un tratto di radice (sulla stessa rete: ambra e radice si toccano)
	await t.ticks(3)
	var stormy: float = (e.machines[leaf] as Machine).made
	var b0 := EnergyStorm.bursts
	EnergyStorm.tick(e, EnergyStorm.BURST_EVERY)         # probabilità piena: una vena si spezza per rete che scorre
	var broke := EnergyStorm.bursts == b0 + 1
	await t.ticks(2)
	var valve := t.place("valvola_sfogo", Vector2i(p.x + 3, y))
	await t.ticks(3)
	var b1 := EnergyStorm.bursts
	EnergyStorm.tick(e, EnergyStorm.BURST_EVERY)
	var saved := EnergyStorm.bursts == b1
	await kit.save("241_tempesta")
	m.events.stop()
	m.events.paused = ev_paused
	var storm_ok := is_equal_approx(stormy, minf(base * 1.5, (e.machines[leaf] as Machine).cap)) and broke and saved
	# il Succhiavena: una riga di radice, una di legnoferro, una cella di radice isolata
	var sx := p.x + 18
	for x in range(sx, sx + 12):
		if VeinsData.tier(w.vein_at(x, y)) == 0:
			t.lay(Vector2i(x, y), 1 if x < sx + 6 else 2)
	w.set_vein(sx + 2, y, w.vein_at(sx + 2, y) | VeinsData.INSULATED)
	e._on_vein(Vector2i(sx + 2, y))
	m.snap_to(Vector2i(p.x - 25, y))
	var s0: int = m.wiles.sucked
	var leech: Creature = m.fauna.add("succhiavena", Vector2(sx + 3, y) * 16.0 + Vector2(8, 8))
	await kit.seconds(9.0)
	var radice_left := 0
	for x in range(sx, sx + 6):
		if VeinsData.tier(w.vein_at(x, y)) == 1:
			radice_left += 1
	var hard_left := 0
	for x in range(sx + 6, sx + 12):
		if VeinsData.tier(w.vein_at(x, y)) == 2:
			hard_left += 1
	var ins_ok := VeinsData.tier(w.vein_at(sx + 2, y)) == 1
	var leech_ok: bool = is_instance_valid(leech) and m.wiles.sucked > s0 and radice_left < 5 and hard_left == 6 and ins_ok
	await kit.save("242_succhiavena")
	m.fauna.clear()
	print("geni della rete: sole %.1f → %.1f pulsi, vene ×%s %s; tempesta: %.1f pulsi, vena spezzata %s, con la valvola salva %s; succhiavena: bevute %d, radice rimasta %d/5, legnoferro %d/6, isolata intatta %s" % [
		base, sunny, str(cond), genes_ok, stormy, broke, saved, m.wiles.sucked - s0, radice_left, hard_left, ins_ok])
	if not (genes_ok and storm_ok and leech_ok):
		print("ATTENZIONE: geni, Tempesta di Linfa o Succhiavena non fanno ciò che devono")
	for o in [leaf, lamp, valve]:
		t.unplace(o)
	logic._clear(p, 40)



## Voce 208: una stazione su una rete viva è «alimentata»; l'Aiuola alimentata fa lavorare a piena velocità il suo
## mondo mentre si è via; le macchine contano per gli obiettivi; la Tessitrice arriva; la Bacheca chiede la rete.
func garden_links() -> void:
	var e: Energy = m.energy
	var p: Vector2i = await t.clean_spot(-420, 20)
	var y := p.y
	var src := t.place("foglia_lanterna", Vector2i(p.x, y))
	var src2 := t.place("foglia_lanterna", Vector2i(p.x + 2, y))
	var box := t.place("cesta", Vector2i(p.x + 5, y))
	t.lay_row(p.x, p.x + 8, y, 3)
	await t.ticks(3)
	var on := EnergyGarden.powered(e, box)                   # due foglie a mezzogiorno: 24 pulsi
	t.unplace(src2)
	await t.ticks(3)
	var weak := not EnergyGarden.powered(e, box)            # una sola: 12, sotto la soglia
	var stats: Dictionary = m.character.stats
	var key := "rete_viva_" + String(m.world_id)
	var had: Variant = stats.get(key, null)
	stats[key] = 1
	var full := is_equal_approx(EnergyGarden.away_speed(e), 1.0)
	stats[key] = 0
	var half := is_equal_approx(EnergyGarden.away_speed(e), EnergyAway.SPEED)
	if had == null:
		stats.erase(key)
	else:
		stats[key] = had
	var counted := int(stats.get("macchine", 0)) >= 4
	var weaver := counted and NpcData.NPCS.has("tessitrice")
	var asked := false
	for i in 60:
		var r: Dictionary = m.board.make()
		if String(r["tipo"]) in ["rete", "centrale"]:
			asked = true
			break
	print("giardino e rete: stazione alimentata %s, sotto soglia %s, lavoro da lontano pieno %s / a metà %s, macchine contate %d, Tessitrice pronta %s, la Bacheca chiede la rete %s" % [
		on, weak, full, half, int(stats.get("macchine", 0)), weaver, asked])
	if not (on and weak and full and half and counted and weaver and asked):
		print("ATTENZIONE: le Aiuole alimentate, il conto delle macchine o la Bacheca non fanno ciò che devono")
	if m.world.chests.has(box):
		m.world.chests.erase(box)
	t.unplace(box)
	t.unplace(src)
	logic._clear(p, 20)


## Voce 209: il corredo del secondo stadio dell'Albero e il filo del primo circuito, passo passo fino alla Lampada accesa
## dalla Leva; i consigli della rete hanno tutti la loro condizione.
func first_circuit() -> void:
	var e: Energy = m.energy
	var stats: Dictionary = m.character.stats
	var had := int(stats.get("primo_circuito", 0))
	stats.erase("primo_circuito")
	var kit_ok: bool = (MotherTreeData.STAGES[1]["gives"] as Dictionary).get("items", {}).has("pinza_vene")
	var p: Vector2i = await t.clean_spot(-460, 16)
	var y := p.y
	var seen := []
	for o in e.machines.keys():                             # il circuito si cerca fra tutte le macchine del mondo
		t.unplace(o)
	await t.ticks(2)
	seen.append(String(FiloRete.from(m).get("text", "")))
	var drum := t.place("tamburo_radice", Vector2i(p.x, y))
	await t.ticks(2)
	seen.append(String(FiloRete.from(m).get("text", "")))
	t.lay_row(p.x, p.x + 8, y, 2)
	await t.ticks(2)
	seen.append(String(FiloRete.from(m).get("text", "")))
	var otre := t.place("otre_linfa", Vector2i(p.x + 3, y))
	await t.ticks(2)
	seen.append(String(FiloRete.from(m).get("text", "")))
	var lamp := t.place("lampada_baccello", Vector2i(p.x + 6, y))
	await t.ticks(2)
	seen.append(String(FiloRete.from(m).get("text", "")))
	var lever := t.place("leva_radice", Vector2i(p.x + 8, y))
	t.lay_row(p.x + 6, p.x + 8, y, 1 << VeinsData.WIRE_SHIFT)
	await t.ticks(2)
	(e.machines[otre] as Machine).st["g"] = 60.0
	logic._lever(lever, true)
	await t.settle(0.5)
	await t.ticks(2)
	var after := FiloRete.from(m)
	var steps_ok := seen.size() == 5
	for i in 5:
		steps_ok = steps_ok and seen[i] == String(FiloRete.STEPS[i][1])
	var done := after.is_empty() and int(stats.get("primo_circuito", 0)) == 1
	var tips := true
	for row in ConsigliData.LIST.slice(ConsigliData.LIST.size() - 5):
		tips = tips and m.consigli.has_method("_c_" + String(row["id"]))
	print("primo circuito: corredo dell'Albero %s, i cinque passi del filo %s, finito %s, consigli della rete %s" % [kit_ok, steps_ok, done, tips])
	if not steps_ok:
		print("  passi visti: %s" % str(seen))
	if not (kit_ok and steps_ok and done and tips):
		print("ATTENZIONE: il primo circuito guidato non fa ciò che deve")
	stats["primo_circuito"] = had
	for o in [drum, otre, lamp, lever]:
		t.unplace(o)
	logic._clear(p, 16)


## Voce 210: la centralina del Giardiniere nasce in un colpo con le vene e i fili, e funziona (con il sole la Lampada
## si accende quando si alza la Leva); i capitoli della rete ci sono.
func blueprint() -> void:
	var e: Energy = m.energy
	var b: Bisaccia = m.character.bisaccia
	var p: Vector2i = await t.clean_spot(-500, 16)
	var id := "centralina"
	var sz := ProjectsData.size_of(id)
	var o := Vector2i(p.x + 1, p.y - sz.y + 1)
	for yy in range(o.y - MbSole.ROOF - 1, o.y):                # il cielo libero sopra le foglie
		for xx in range(o.x - 1, o.x + sz.x + 1):
			m.world.set_tile(xx, yy, TileDefs.AIR)
	var need := ProjectsData.needs(id)
	for k in need:
		b.add(String(k), int(need[k]))
	var built: bool = m.builder.build_blueprint(id, o)
	await t.ticks(3)
	var leaves := 0
	var lamps: Array[Machine] = []
	var lever: Machine = null
	for mc: Machine in e.machines.values():
		if Rect2i(o, sz).has_point(mc.o):
			match mc.id:
				"foglia_lanterna":
					leaves += 1 if mc.net >= 0 else 0
				"lampada_baccello":
					lamps.append(mc)
				"leva_radice":
					lever = mc
	var got := []
	for q in m.world.stations:
		if Rect2i(o, sz).has_point(q):
			got.append("%s@%d,%d" % [m.world.stations[q], q.x - o.x, q.y - o.y])
	if lamps.size() != 2 or leaves != 2:
		print("  centralina: stazioni %s, foglie in rete %d, lampade %d, reti %s" % [str(got), leaves, lamps.size(), str(lamps.map(func(q: Machine) -> int: return q.net))])
	var one_net := lamps.size() == 2 and leaves == 2 and lamps[0].net >= 0 and lamps[0].net == lamps[1].net
	if lever != null:
		logic._lever(lever.o, true)
	await t.settle(0.5)
	await t.ticks(4)
	var lit := lamps.size() == 2 and lamps[0].lit and lamps[1].lit
	if not lit and lamps.size() == 2:
		var nt: Dictionary = e.nets[lamps[0].net]
		print("  centralina: lampade on %s/%s, potenza %.2f/%.2f, fili %s, leva %s, rete dà %.1f chiede %.1f" % [lamps[0].on(), lamps[1].on(),
			lamps[0].power, lamps[1].power, str(lamps[0].wired), str(lever.st if lever != null else {}), float(nt["prod"]), float(nt["want"])])
	m.snap_to(Vector2i(o.x + sz.x / 2, p.y))
	await kit.save("243_centralina")
	var chapters := 0
	for c in EncyEnergyData.CHAPTERS:
		if not EncyPages.chapter(String(c["id"])).is_empty():
			chapters += 1
	var cat_ok := EncyEnergy.inline("cat_rete_sorgenti").count("\n") >= 5 and EncyEnergy.inline("cat_rete_vene").count("\n") == 3
	print("centralina: costruita %s, due foglie e due lampade sulla stessa rete %s, la Leva le accende %s; capitoli della rete %d/%d, cataloghi %s" % [
		built, one_net, lit, chapters, EncyEnergyData.CHAPTERS.size(), cat_ok])
	if not (built and one_net and lit and chapters == EncyEnergyData.CHAPTERS.size() and cat_ok):
		print("ATTENZIONE: il progetto della centralina o i capitoli della rete non fanno ciò che devono")
	for mc: Machine in e.machines.values():
		if Rect2i(o, sz).has_point(mc.o):
			t.unplace(mc.o)
