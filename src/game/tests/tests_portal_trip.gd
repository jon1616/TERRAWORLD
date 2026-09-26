class_name TestsPortalTrip
extends RefCounted
## Il viaggio vero attraverso il portale (voce 12), con il cambio di scena: `-- --prove --prova-portale`.
## Tappa 0 (mondo di prova): si pianta un Seme di mondo e si attraversa il portale.
## Tappa 1 (mondo nuovo): vigore 2, portale di ritorno accanto alla partenza, creature più forti; si torna indietro.
## Tappa 2 (di nuovo nel mondo di prova): il portale ricorda il mondo nuovo. Fine.
## La tappa sta in `Session.test_hops`, perché ogni cambio di scena ricomincia le prove da capo.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var hop := Session.test_hops
	Session.test_hops += 1
	match hop:
		0:
			var spot := kit.flat_spot(kit.world.spawn, 4)
			m.snap_to(spot + Vector2i(-3, 0))
			await kit.frames(5)
			m.character.bisaccia.add("seme_mondo", 1)
			kit.hold("seme_mondo")
			kit.aiuola(spot)
			var ok: bool = m.portal.plant(spot, "seme_mondo")
			m.guardian.lore.visible = false
			print("viaggio, tappa 0: portale piantato %s, si parte" % ("sì" if ok else "NO"))
			await kit.seconds(0.5)
			m.portal.travel(spot - Vector2i(1, 3))
		1:
			var back := Vector2i(-1, -1)
			for o in kit.world.stations:
				if kit.world.stations[o] == "portale":
					back = o
			print("viaggio, tappa 1: mondo «%s», vigore %d, creature ×%.2f, portale di ritorno %s" % [
				m.world_meta.get("nome", "?"), m.portal.vigor(), m.fauna.vigor_mult, "sì" if back.x >= 0 else "NO"])
			if back.x >= 0:
				m.snap_to(back + Vector2i(-2, 3))
			await kit.seconds(1.5)
			await kit.save("30_mondo_oltre_il_portale")
			if back.x >= 0:
				m.portal.travel(back)
			else:
				kit.node.get_tree().quit()
		_:
			var dest := ""
			for k in (m.world_meta.get("portali", {}) as Dictionary):
				dest = String(m.world_meta["portali"][k].get("mondo", ""))
			print("viaggio, tappa 2: di nuovo in «%s», il portale porta a «%s»" % [m.world_meta.get("nome", "?"), dest])
			kit.node.get_tree().quit()
