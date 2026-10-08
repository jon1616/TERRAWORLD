class_name TestsCombat
extends RefCounted
## Prove delle creature e del combattimento: ferita al contatto, spada, arco, spore, comparsa per strato e una foto
## di tutte le creature in fila.

const S := 16

var kit: TestKit
var world: World
var fauna: Fauna


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	fauna = tk.m.fauna


func _feet(c: Vector2i, id: String) -> Vector2:
	return Vector2(c.x * S + 8, (c.y + 1) * S - float(CreaturesData.CREATURES[id]["half"][1]) - 0.1)


## Aspetta finché `done` è vero (al massimo `secs` secondi); restituisce il tempo impiegato o -1.
func _until(done: Callable, secs: float) -> float:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(secs * 1000.0):
		if done.call():
			return (Time.get_ticks_msec() - t0) / 1000.0
		await kit.node.get_tree().process_frame
	return -1.0


func run() -> void:
	var m := kit.m
	var v: Vitals = m.vitals
	var spot := kit.flat_spot(world.spawn, 6)
	if spot.x < 0:
		spot = world.spawn
	m.snap_to(spot)
	fauna.clear()
	await kit.frames(10)
	# 1. contatto: un grumo addosso ferisce, poi qualche istante di invulnerabilità
	v.refill()
	fauna.add("grumo_muschio", m.player.position + Vector2(4, 0))
	await kit.frames(6)
	var lost := Vitals.HP_MAX - v.hp
	print("contatto con un grumo: persi %d di Vita, invulnerabile %s" % [lost, "sì" if m.combat.invuln > 0.0 else "NO"])
	fauna.clear()
	await kit.seconds(0.8)
	# 2. spada: una strisciaradice davanti, si colpisce finché muore; il bottino cade e si raccoglie
	v.refill()
	kit.hold("spada_radice")
	m.snap_to(spot)
	await kit.frames(4)
	var wood := kit.bisaccia().count("legno")
	var kills := fauna.kills
	var sr := fauna.add("strisciaradice", _feet(spot + Vector2i(1, 0), "strisciaradice"))
	sr.set_process(false)
	m.player.facing = 1
	m.player.force_swing = true
	var t := await _until(func() -> bool: return fauna.kills > kills, 6.0)
	m.player.force_swing = false
	await kit.seconds(1.0)
	print("spada contro strisciaradice: %s, bottino legno +%d" % [
		("abbattuta in %.1f s" % t) if t >= 0.0 else "NON abbattuta", kit.bisaccia().count("legno") - wood])
	# 3. arco: un grumo a 7 tessere, si tira finché muore
	kit.bisaccia().add("dardo", 30)
	kit.hold("arco_radice")
	var darts := kit.bisaccia().count("dardo")
	kills = fauna.kills
	var gx := spot.x + 7
	var gr := fauna.add("grumo_muschio", _feet(Vector2i(gx, world.surface[gx] - 1), "grumo_muschio"))
	gr.set_process(false)
	m.combat.auto_aim = gr.position
	m.combat.auto_fire = true
	await kit.frames(20)
	await kit.save("16_arco")
	t = await _until(func() -> bool: return fauna.kills > kills, 8.0)
	m.combat.auto_fire = false
	m.combat.auto_aim = Vector2.INF
	print("arco contro grumo a 7 tessere: %s, dardi usati %d" % [
		("abbattuto in %.1f s" % t) if t >= 0.0 else "NON abbattuto", darts - kit.bisaccia().count("dardo")])
	fauna.clear()
	await kit.seconds(0.8)
	# 4. spore: uno sputaspore a 8 tessere sputa verso il Germogliato
	v.refill()
	m.combat.invuln = 0.0
	fauna.add("sputaspore", _feet(spot + Vector2i(-8, 0), "sputaspore"))
	var hp0 := v.hp
	t = await _until(func() -> bool: return v.hp < hp0, 8.0)
	print("spora dello sputaspore: %s" % (("colpito dopo %.1f s (-%d)" % [t, hp0 - v.hp]) if t >= 0.0 else "NON colpito"))
	fauna.clear()
	# 5. comparsa: in superficie e in profondità, creature adatte allo strato
	var seen := {}
	for place in [spot, Vector2i(spot.x, world.surface[spot.x] + 250)]:
		m.snap_to(place)
		await kit.frames(3)
		for k in 300:
			var c := fauna.try_spawn()
			if c:
				var sname := StrataData.at(world, int(c.position.x / S), int(c.position.y / S))
				seen["%s (strato %d)" % [c.id, sname]] = true
			if fauna.list.size() >= 12:
				break
		fauna.clear()
	print("comparsa per strato: ", ", ".join(seen.keys()))
	# 6. tutte le creature in fila, ferme, per la foto
	m.snap_to(spot)
	await kit.frames(4)
	var dx := -8
	for id in CreaturesData.CREATURES:
		var cell := spot + Vector2i(dx, 0)
		cell.x = 4 + posmod(cell.x - 4, world.w - 8)        # tante creature: la fila ricomincia dall'altro lato del mondo
		var pos := _feet(Vector2i(cell.x, world.surface[cell.x] - 1), id)
		if CreaturesData.CREATURES[id].get("fly", false):
			pos.y -= 20
		var c := fauna.add(id, pos)
		c.set_process(false)
		c._animate(0.1)
		dx += 3
	# dopo tanti salti della visuale la foto arriva in ritardo: si aspetta di più
	await kit.seconds(2.0)
	await kit.save("15_creature")
	fauna.clear()
	v.refill()
