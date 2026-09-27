class_name TestsGuardianGen
extends RefCounted
## Prove dei Guardiani generati (voce 80): trenta semi danno Guardiani diversi (nomi, corpi, attacchi), sempre uguali
## dallo stesso seme, con attacchi adatti al corpo; i mondi di vigore 4+ li usano; uno nasce, combatte, a metà Vita
## cambia elemento; i suoi materiali esistono. Foto 147_guardiano_generato.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var names := {}
	var bodies := {}
	var combos := {}
	var bad := []
	for sd in range(1, 31):
		var id := GuardianGen.id_for(sd * 104729)
		var d := CreaturesData.get_data(id)
		names[d["name"]] = true
		bodies[d["body"]] = true
		combos[str(d["attacks"])] = true
		for a in d["attacks"]:
			var ad: Dictionary = GuardianGenData.ATTACKS[a]
			if ad.has("fly") and bool(ad["fly"]) != bool(d["fly"]):
				bad.append("%s: %s" % [d["name"], a])
		for b in d["behaviors"]:
			if Behavior.make(String(b)) == null:
				bad.append("comportamento %s" % b)
	var same := GuardianGen.make(GuardianGen.id_for(42)) == GuardianGen.make(GuardianGen.id_for(42))
	# quale Guardiano per quale vigore
	var v0: int = m.world_meta.get("vigore", 1)
	m.world_meta["vigore"] = 2
	var g2 := String(m.guardian.info()["creature"])
	m.world_meta["vigore"] = 6
	var g6: Dictionary = m.guardian.info()
	m.world_meta["vigore"] = v0
	var items_ok := ItemsData.get_item(String(g6["defeat"].keys()[0])).has("name") and ItemsData.get_item("linfa_gg").has("name")
	# uno nasce e combatte
	m.snap_to(world.spawn)
	await kit.seconds(0.2)
	m.vitals.refill()
	var gid := String(g6["creature"])
	var cr: Creature = m.fauna.add(gid, m.player.position + Vector2(150, -90))
	cr.target = m.player
	var gd: Guardian = m.guardian
	var old_boss: Creature = gd.boss
	gd.boss = cr
	await kit.seconds(1.5)
	await kit.save("147_guardiano_generato")
	var elem0 := String(cr.data["elem"])
	cr.hp = int(cr.hp_max * 0.4)
	await kit.seconds(0.6)
	var elem1 := String(cr.data["elem"])
	var phased := elem1 == String(CreaturesData.get_data(gid)["phase_elem"]) and elem1 != elem0 or gd._phased
	gd.boss = old_boss
	gd._phased = false
	if is_instance_valid(cr):
		m.fauna.kill_quietly(cr)
	m.vitals.refill()
	print("guardiani generati: %d nomi diversi su 30, %d corpi, %d combinazioni di attacchi; stesso seme uguale %s; vigore 2 → %s, vigore 6 → %s (%s); materiali %s; in battaglia: elemento %s → %s, fase %s; problemi %s" % [
		names.size(), bodies.size(), combos.size(), "sì" if same else "NO", g2, g6["creature"],
		GuardianGen.describe(gid), "sì" if items_ok else "NO", elem0, elem1, "sì" if phased else "NO", bad])
	if names.size() < 25 or bodies.size() < 8 or combos.size() < 8 or not same or g2 != "regina_spore" \
			or not GuardianGen.is_gen(String(g6["creature"])) or not items_ok or not phased or not bad.is_empty():
		print("ATTENZIONE: i Guardiani generati non funzionano come dovrebbero")
