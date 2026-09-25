class_name TestsBestiary
extends RefCounted
## Prove del bestiario della voce 22: ogni comportamento nuovo fa ciò che deve (agguato, scava, teletrasporto, guscio,
## mimo, bombarda, sciame, ragnatela), gli accessori nuovi cambiano ciò che devono, lo Specchio del guizzo riporta
## alla partenza; foto di gruppo di tutte le creature nuove (45_bestiario) e dell'agguato in grotta (46_agguato).

const S := 16
const NEW := ["corvo_corteccia", "spinoriccio", "lucciola_vorace", "tessiradice", "talpone", "saltafungo",
	"ala_ardesia", "chiocciola_cristallo", "geomimo", "serpe_linfa", "campanula_errante", "guizzalinfa", "mietivuoto",
	"tessivuoto", "sciame_schegge"]

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _feet(x: int, id: String) -> Vector2:
	return Vector2(x * S + 8, world.surface[x] * S - float(CreaturesData.CREATURES[id]["half"][1]) - 0.1)


## Un pavimento di grotta con il soffitto a 4-7 tessere sopra, vicino alla partenza (per l'agguato).
func _cave_spot() -> Vector2i:
	var best := Vector2i(-1, -1)
	var bd := 1e18
	for y in range(world.surface[world.spawn.x] + 30, world.h - 20, 3):
		for x in range(maxi(world.spawn.x - 300, 5), mini(world.spawn.x + 300, world.w - 5), 3):
			if world.solid(x, y) or not world.solid(x, y + 1) or world.solid(x, y - 1) or world.solid(x + 1, y):
				continue
			var up := 0
			while up < 9 and not world.solid(x, y - up - 1):
				up += 1
			if up < 4 or up > 7:
				continue
			var d := Vector2(Vector2i(x, y) - world.spawn).length_squared()
			if d < bd:
				bd = d
				best = Vector2i(x, y)
	return best


func run() -> void:
	var fauna: Fauna = m.fauna
	var spot := kit.flat_spot(world.spawn, 6)
	if spot.x < 0:
		print("ATTENZIONE: nessun terreno piano per le prove del bestiario")
		return
	m.snap_to(spot)
	fauna.clear()
	m.combat.god = true
	await kit.frames(4)
	# guscio: colpita si chiude, e il secondo colpo fa un quarto del danno
	var ch := fauna.add("chiocciola_cristallo", _feet(spot.x + 4, "chiocciola_cristallo"))
	ch.hp_max = 500
	ch.hp = 500
	ch.take_hit(40, m.player.position.x, 0.1)
	var after1 := ch.hp
	await kit.frames(2)
	ch.take_hit(40, m.player.position.x, 0.1)
	print("guscio: chiusa %s, primo colpo -%d, secondo colpo nel guscio -%d" % ["sì" if ch.shell > 0.0 else "NO",
		500 - after1, after1 - ch.hp])
	fauna.clear()
	# mimo: travestito finché non ti avvicini
	var gm := fauna.add("geomimo", _feet(spot.x + 8, "geomimo"))
	await kit.frames(3)
	var was_still := gm.anchored
	gm.position = _feet(spot.x + 2, "geomimo")
	await kit.frames(3)
	print("mimo: fermo da lontano %s, sveglio da vicino %s" % ["sì" if was_still else "NO", "sì" if not gm.anchored else "NO"])
	fauna.clear()
	# teletrasporto: da 12 tessere ricompare accanto
	var gz := fauna.add("guizzalinfa", _feet(spot.x + 12, "guizzalinfa"))
	var d0 := gz.position.distance_to(m.player.position) / S
	await kit.seconds(4.0)
	print("teletrasporto: Guizzalinfa da %.0f a %.0f tessere dal Germogliato" % [d0, gz.position.distance_to(m.player.position) / S])
	fauna.clear()
	# scava: il talpone attraversa la terra e si avvicina
	var tp := fauna.add("talpone", _feet(spot.x + 14, "talpone"))
	var t0 := tp.position.distance_to(m.player.position) / S
	var buried := false
	for k in 60:
		await kit.frames(2)
		buried = buried or tp.buried
	print("scava: Talpone sotto terra %s, da %.0f a %.0f tessere" % ["sì" if buried else "NO", t0,
		tp.position.distance_to(m.player.position) / S])
	fauna.clear()
	# bombarda: una campanula sopra la testa lascia cadere polline
	var shots0: int = m.shots.count()
	var cp := fauna.add("campanula_errante", m.player.position + Vector2(10, -70))
	var fired := 0
	for k in 90:
		await kit.frames(2)
		fired = maxi(fired, m.shots.count() - shots0)
	print("bombarda: colpi in volo dalla Campanula %d" % fired)
	cp.queue_free()
	fauna.clear()
	# sciame: le lucciole nascono in gruppo e non contano nel tetto
	var first := fauna.add("lucciola_vorace", m.player.position + Vector2(60, -40))
	fauna._group(first, "lucciola_vorace", 1.0)
	var extra := fauna.list.filter(func(c: Creature) -> bool: return c.extra).size()
	print("sciame: %d lucciole, %d in più che non contano nel tetto (vive che contano: %d)" % [fauna.list.size(), extra,
		fauna._alive()])
	fauna.clear()
	# ragnatela: invischia (corsa a metà)
	m.combat.god = false
	m.combat.invuln = 0.0
	m.combat.on_shot({"node": m.player, "vel": Vector2(10, 0), "damage": 1, "player": false, "slow": 2.5})
	print("ragnatela: invischiato per %.1f s" % m.player.slow_t)
	m.player.slow_t = 0.0
	m.vitals.refill()
	m.combat.god = true
	# accessori nuovi
	var b: Bisaccia = m.character.bisaccia
	var old1 := String(b.equip.get("accessorio_1", ""))
	var old2 := String(b.equip.get("accessorio_2", ""))
	for pair in [["guanti_talpone", "velo_ombra"], ["anello_geode", "collana_aculei"]]:
		b.wear("accessorio_1", {})
		b.wear("accessorio_2", {})
		b.wear("accessorio_1", {"id": pair[0], "n": 1})
		b.wear("accessorio_2", {"id": pair[1], "n": 1})
		await kit.frames(1)
		print("accessori %s + %s: scavo ×%.2f, visti da ×%.2f, fortuna %.1f, spine %d" % [pair[0], pair[1],
			m.actions.dig_mult, Behavior.stealth, fauna.luck, m.combat.thorns])
	b.wear("accessorio_1", {})
	b.wear("accessorio_2", {})
	if old1 != "":
		b.wear("accessorio_1", {"id": old1, "n": 1})
	if old2 != "":
		b.wear("accessorio_2", {"id": old2, "n": 1})
	# Specchio del guizzo: da lontano si torna alla partenza
	m.snap_to(spot + Vector2i(40, 0))
	kit.hold("specchio_guizzo")
	m.interact._use("specchio", "specchio_guizzo", m.player_cell())
	print("specchio: dopo l'uso a %.0f tessere dalla partenza" % (m.player.position.distance_to(m.cell_to_feet(world.spawn)) / S))
	# foto di gruppo: tutte le creature nuove in fila, ferme
	m.snap_to(spot)
	await kit.frames(3)
	var x := spot.x - 13
	for id in NEW:
		var cd: Dictionary = CreaturesData.CREATURES[id]
		var pos := _feet(x, id)
		if cd.get("fly", false):
			pos.y -= 26
		var cr := fauna.add(id, pos)
		cr.set_process(false)
		cr._animate(0.1)
		x += 2
	await kit.seconds(2.5)
	await kit.save("45_bestiario")
	fauna.clear()
	# agguato: un Tessiradice sale al soffitto di una grotta e cade quando gli passi sotto
	var cs := _cave_spot()
	if cs.x < 0:
		print("ATTENZIONE: nessuna grotta adatta alla prova dell'agguato")
	else:
		m.snap_to(cs + Vector2i(-8, 0))
		var ts := fauna.add("tessiradice", Vector2(cs.x * S + 8, (cs.y + 1) * S - 5.1))
		await kit.frames(3)
		var hung := ts.anchored
		var y_hung := ts.position.y
		m.boons.add("bagliore", 20.0)              # nel buio vero la foto non mostrerebbe nulla
		await kit.seconds(1.5)
		await kit.save("46_agguato")
		m.snap_to(cs)
		await kit.seconds(1.2)
		print("agguato: appeso %s (salito di %.0f tessere), caduto quando sei passato sotto %s" % ["sì" if hung else "NO",
			(cs.y * S - y_hung) / S, "sì" if not ts.anchored else "NO"])
	fauna.clear()
	m.combat.god = false
	m.vitals.refill()
