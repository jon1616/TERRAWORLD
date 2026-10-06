class_name TestsVastita
extends RefCounted
## Il piano «La vastità» (Roadmap 38 e seguenti, `VASTITA.md`). Gruppo «vastita».
## Voce 356: ogni materiale ha il suo gesto; una spada in mano porta l'effetto del suo metallo; i moduli dei colpi
## funzionano davvero: il rimbalzo sulla roccia, la divisione in schegge, il ritorno verso il Germogliato.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await gestures()


func gestures() -> void:
	var res := {}
	# 1. i dati: ogni materiale (anche le leghe) ha un gesto, e i suoi effetti esistono
	var missing := []
	for mat in MaterialsData.all():
		var g := GesturesData.of_mat(String(mat))
		if g.is_empty():
			missing.append(mat)
			continue
		for fx in g["fx"]:
			if EffectsData.info(String(fx)).is_empty():
				missing.append("%s:%s" % [mat, fx])
	res["dati"] = missing.is_empty()
	# 2. la spada di radicite in mano porta «Radice che trattiene»
	var keep: Array = m.character.bisaccia.slots.duplicate(true)
	var si := kit.hold("spada_radicite")
	m.hud.select(si)
	await kit.frames(2)
	m.effects.refresh()
	res["in_mano"] = m.effects.has("mat_radicite")
	# 3. i moduli: un posto aperto con la roccia vicina
	m.snap_to(m.world.spawn)
	await kit.frames(3)
	m.fauna.clear(true)
	var p: Vector2 = m.player.position + Vector2(0, -20)
	# rimbalzo: un colpo contro il terreno sotto i piedi rimbalza invece di sparire
	var n0: int = m.shots.count()
	m.shots.fire(p, Vector2(0, 300), 0.0, 1, true, 0.1, {"bounce": 2})
	m.shots.fire(p, Vector2(0, 300), 0.0, 1, true, 0.1, {})
	await kit.seconds(0.35)
	res["rimbalzo"] = m.shots.count() - n0 == 1
	# divisione: un colpo che prende una creatura lascia schegge
	var cr: Creature = m.fauna.add("grumo_muschio", m.player.position + Vector2(60, -6))
	cr.set_process(false)
	cr.hp = 9999
	var sh0: int = m.combat.shards_made
	m.shots.fire(m.player.position + Vector2(20, -6), Vector2(400, 0), 0.0, 5, true, 0.1, {"split": [3, 0.4]})
	await kit.seconds(0.4)
	res["divisione"] = m.combat.shards_made - sh0 == 3 and cr.hp < 9999
	m.fauna.clear(true)
	await kit.seconds(0.6)
	# ritorno: un colpo con il ritorno torna vicino al Germogliato e sparisce lì
	var before: int = m.shots.count()
	m.shots.fire(m.player.position + Vector2(10, -6), Vector2(300, 0), 0.0, 1, true, 0.1, {"ret": 0.3, "through": true})
	await kit.seconds(1.6)
	res["ritorno"] = m.shots.count() <= before
	for i in keep.size():
		m.character.bisaccia.slots[i] = keep[i]
	m.character.bisaccia.changed.emit()
	print("gesti: %s; materiali senza gesto %s" % [str(res), str(missing)])
	if not res.values().all(func(x: bool) -> bool: return x):
		print("ATTENZIONE: il motore dei gesti non va come dovrebbe")
