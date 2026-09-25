class_name TestsGifts
extends RefCounted
## Prove della voce 21: quanti doni nel mondo, assorbire un Cuore di bocciolo e una Stilla perenne (e il tetto), la
## Pozione di Linfa, i bastoni (Linfa spesa, scheggia che attraversa tre creature, sfera che insegue); foto
## 43_bastoni e 44_bocciolo.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _feet(x: int, id: String) -> Vector2:
	return Vector2(x * S + 8, world.surface[x] * S - float(CreaturesData.CREATURES[id]["half"][1]) - 0.1)


func _nearest(kind: int) -> Vector2i:
	var best := Vector2i(-1, -1)
	var bd := 1e18
	for i in world.decor.size():
		if world.decor[i] == kind:
			var c := Vector2i(i % world.w, i / world.w)
			var d := Vector2(c - world.spawn).length_squared()
			if d < bd:
				bd = d
				best = c
	return best


func run() -> void:
	var nb := 0
	var ns := 0
	for d in world.decor:
		if d == TileDefs.DECOR_BOCCIOLO:
			nb += 1
		elif d == TileDefs.DECOR_STILLA:
			ns += 1
	print("doni nel mondo: %d Boccioli del cuore, %d Stille perenni" % [nb, ns])
	var v: Vitals = m.vitals
	var ch: Character = m.character
	var b: Bisaccia = ch.bisaccia
	# assorbire i doni
	var hp0 := v.hp_max
	var lm0 := v.linfa_max
	kit.hold("cuore_bocciolo")
	var ok1: bool = m.interact._use("dono", "cuore_bocciolo", m.player_cell())
	kit.hold("stilla_perenne")
	var ok2: bool = m.interact._use("dono", "stilla_perenne", m.player_cell())
	print("doni: Cuore di bocciolo %s (Vita massima %d → %d), Stilla perenne %s (Linfa massima %d → %d)" % [
		"sì" if ok1 else "NO", hp0, v.hp_max, "sì" if ok2 else "NO", lm0, v.linfa_max])
	var real := int(ch.stats.get("doni_cuore_bocciolo", 0))
	ch.stats["doni_cuore_bocciolo"] = 15
	b.add("cuore_bocciolo", 1)
	kit.hold("cuore_bocciolo")
	var ok3: bool = m.interact._use("dono", "cuore_bocciolo", m.player_cell())
	print("tetto dei Cuori di bocciolo: il sedicesimo %s" % ("rifiutato" if not ok3 else "ACCETTATO (errore)"))
	ch.stats["doni_cuore_bocciolo"] = real
	# la Pozione di Linfa
	v.linfa = 2
	kit.hold("pozione_linfa")
	m.actions.drink("pozione_linfa")
	print("Pozione di Linfa: Linfa da 2 a %d" % v.linfa)
	# bastone di cristallo: una scheggia attraversa tre creature in fila
	var spot := kit.flat_spot(world.spawn, 6)
	if spot.x < 0:
		print("ATTENZIONE: nessun terreno piano per la prova dei bastoni")
		return
	m.snap_to(spot)
	m.fauna.clear()
	await kit.frames(4)
	var row: Array[Creature] = []
	for k in 3:
		# alla stessa altezza del colpo, ferme a mezz'aria: la scheggia deve attraversarle tutte e tre
		var cr: Creature = m.fauna.add("strisciaradice", m.player.position + Vector2(48 + k * 32, -6))
		cr.set_process(false)
		cr.hp_max = 500
		cr.hp = 500
		row.append(cr)
	v.refill()
	kit.hold("bastone_cristallo")
	m.spells.auto_aim = row[2].position
	m.spells.auto_fire = true
	await kit.frames(3)
	m.spells.auto_fire = false
	var l0 := v.linfa
	await kit.seconds(0.6)
	var hit := 0
	for cr in row:
		if cr.hp < 500:
			hit += 1
	print("bastone di cristallo: colpite %d creature su 3 con una scheggia, Linfa %d → %d (tirati %d)" % [hit, v.linfa_max,
		l0, m.spells.casts])
	m.fauna.clear()
	# bastone del Vuoto: la sfera insegue una creatura alle spalle del punto di mira
	var tgt: Creature = m.fauna.add("falena_brace", m.player.position + Vector2(-90, -50))
	tgt.set_process(false)
	tgt.hp_max = 500
	tgt.hp = 500
	v.refill()
	kit.hold("bastone_vuoto")
	m.spells.auto_aim = m.player.position + Vector2(200, 0)
	m.spells.auto_fire = true
	await kit.frames(3)
	m.spells.auto_fire = false
	await kit.seconds(2.0)
	print("bastone del Vuoto: la sfera tirata a destra ha raggiunto la falena a sinistra %s (Vita %d)" % [
		"sì" if tgt.hp < 500 else "NO", tgt.hp])
	m.fauna.clear()
	# foto: un ventaglio di spore e faville di brace in volo verso tre grumi
	for k in 3:
		var g: Creature = m.fauna.add("grumo_muschio", _feet(spot.x + 6 + k * 2, "grumo_muschio"))
		g.set_process(false)
		g.hp_max = 500
		g.hp = 500
	v.refill()
	kit.hold("bastone_spore")
	m.spells.auto_aim = m.player.position + Vector2(140, -30)
	m.spells.auto_fire = true
	await kit.seconds(0.9)
	m.spells.auto_fire = false
	await kit.save("43_bastoni")
	m.spells.auto_aim = Vector2.INF
	m.fauna.clear()
	await kit.seconds(1.0)
	# un Bocciolo del cuore nel buio di una grotta
	var bc := _nearest(TileDefs.DECOR_BOCCIOLO)
	if bc.x >= 0:
		var near := kit.floor_near(bc, 4)
		m.snap_to(near if near.x >= 0 else bc)
		await kit.seconds(2.0)
		await kit.save("44_bocciolo")
	else:
		print("ATTENZIONE: nessun Bocciolo del cuore nel mondo")
	v.refill()
