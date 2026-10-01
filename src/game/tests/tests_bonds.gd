class_name TestsBonds
extends RefCounted
## Prove dei compagni di battaglia (Roadmap 32, gruppo `legami`): ogni specie combatte con il suo stile (chi spara
## spara colpi amici, chi carica carica, chi scava sbuca, chi nuota vola in una bolla), le creature selvatiche
## prendono di mira il compagno e lo feriscono, il compagno non resta mai indietro. Rimettono la mandria com'era.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var spot := kit.flat_spot(world.spawn + Vector2i(80, 0), 10)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto per le prove dei compagni")
		return
	kit.flatten(spot, 22)
	m.fauna.clear()
	m.snap_to(spot)
	kit.make_room()
	await kit.frames(3)
	var h: Herd = m.herd
	var old: Array = m.character.mandria.duplicate(true)
	m.character.mandria.clear()
	await styles(spot, h)
	await aggro(spot, h)
	await follow(spot, h)
	for uid in h.beasts.keys():
		h.despawn(int(uid))
	m.character.mandria.clear()
	m.character.mandria.append_array(old)
	m.fauna.clear()
	m.snap_to(spot)


## Una scheda che segue, di livello `lvl`, sola in campo.
func _companion(h: Herd, sp: String, lvl: int) -> Dictionary:
	for uid in h.beasts.keys():
		h.despawn(int(uid))
	m.character.mandria.clear()
	var rec := h.new_record(sp, "allevata")
	rec["lvl"] = lvl
	h.add_record(rec)
	rec["stato"] = "segue"
	return rec


## Voce 310: cinque specie, cinque stili, ognuna contro un nemico vero.
func styles(spot: Vector2i, h: Herd) -> void:
	var out := []
	var bad := []
	for sp in ["volpe_ambra", "sputaspore", "talpone", "anguilla_linfa", "grumo_muschio"]:
		m.fauna.clear()
		m.snap_to(spot)
		var rec := _companion(h, sp, 12)
		await kit.seconds(0.6)
		var c: Creature = h.beasts.get(int(rec["uid"]))
		if c == null:
			bad.append(sp + ": non in scena")
			continue
		var shots0 := _ally_shots()
		var fired := false
		var foe: Creature = m.fauna.add("lupo_lunare", m.player.position + Vector2(5 * S, -8))
		foe.hp_max = 90
		foe.hp = 90
		var hp0: int = m.vitals.hp
		var t0 := Time.get_ticks_msec()
		var hurt := false
		while Time.get_ticks_msec() - t0 < 12000 and is_instance_valid(foe) and m.fauna.list.has(foe):
			m.vitals.hp = hp0                      # il Germogliato guarda e basta
			m.combat.invuln = 1.0
			if foe.hp < foe.hp_max:
				hurt = true
			if _ally_shots() > shots0:
				fired = true
			await kit.frames(1)
		var won: bool = not (is_instance_valid(foe) and m.fauna.list.has(foe))
		var secs := (Time.get_ticks_msec() - t0) / 1000.0
		out.append("%s %s (%s%s, %.1f s)" % [sp, BondsData.style_of(sp), "vince" if won else ("ferisce" if hurt else "NIENTE"),
			", spara" if fired else "", secs])
		if not won and not hurt:
			bad.append(sp)
		if sp == "sputaspore" and not fired:
			bad.append("lo sputaspore non spara")
		if sp == "anguilla_linfa" and not c.fly:
			bad.append("l'anguilla non vola fuori dall'acqua")
	m.combat.invuln = 0.0
	print("stili dei compagni: %s" % ", ".join(out))
	if not bad.is_empty():
		print("ATTENZIONE: compagni che non combattono con il loro stile: %s" % [bad])


func _ally_shots() -> int:
	var n := 0
	for s in m.shots._shots:
		if int(s.get("ally", -1)) >= 0:
			n += 1
	return n + int(m.shots.get_meta("ally_fired", 0))


## Voce 310: una creatura colpita dal compagno lo insegue, e il suo contatto lo ferisce.
func aggro(spot: Vector2i, h: Herd) -> void:
	m.fauna.clear()
	m.snap_to(spot)
	var rec := _companion(h, "volpe_ambra", 3)
	await kit.seconds(0.6)
	var c: Creature = h.beasts.get(int(rec["uid"]))
	var foe: Creature = m.fauna.add("lupo_lunare", c.position + Vector2(4 * S, -8))
	foe.hp_max = 400
	foe.hp = 400
	var targeted := false
	var t0 := Time.get_ticks_msec()
	var hp0: int = m.vitals.hp
	while Time.get_ticks_msec() - t0 < 4000 and is_instance_valid(c) and String(rec["stato"]) == "segue":
		m.vitals.hp = hp0
		m.combat.invuln = 1.0
		if is_instance_valid(foe) and foe.target == c:
			targeted = true
		await kit.frames(1)
	var hurt := float(rec["vita"]) < 0.99 or String(rec["stato"]) != "segue"
	m.combat.invuln = 0.0
	print("il nemico prende di mira il compagno: %s; il compagno è ferito: %s (Vita %.0f%%, %s)" % [
		"sì" if targeted else "NO", "sì" if hurt else "NO", float(rec["vita"]) * 100.0, rec["stato"]])
	if not targeted or not hurt:
		print("ATTENZIONE: le creature selvatiche ignorano il compagno")
	m.fauna.clear()


## Voce 310: il compagno non resta indietro (un salto lontano del Germogliato, un muro che lo chiude).
func follow(spot: Vector2i, h: Herd) -> void:
	m.fauna.clear()
	m.snap_to(spot)
	var rec := _companion(h, "pecora_muschio", 5)
	await kit.seconds(0.8)
	var c: Creature = h.beasts.get(int(rec["uid"]))
	m.snap_to(kit.floor_near(spot + Vector2i(40, 0), 8))
	await kit.seconds(1.0)
	var far1: float = c.position.distance_to(m.player.position) / S
	# chiuso dietro un muro alto: dopo un po' ricompare accanto
	m.snap_to(spot)
	await kit.seconds(0.8)
	var cx := floori(c.position.x / S)
	var cy := floori(c.position.y / S)
	var px := floori(m.player.position.x / S)
	var wall_x := cx + (1 if px > cx else -1)
	var placed := []
	for y in range(cy - 12, cy + 2):
		if not world.solid(wall_x, y):
			world.set_tile(wall_x, y, TileDefs.STONE)
			placed.append(Vector2i(wall_x, y))
	m.snap_to(kit.floor_near(Vector2i(px + (8 if px > cx else -8), cy), 6))
	await kit.seconds(2.6)
	var far2: float = c.position.distance_to(m.player.position) / S
	for p in placed:
		world.set_tile(p.x, p.y, TileDefs.AIR)
	m.view.refresh_rect(Rect2i(wall_x - 1, cy - 13, 3, 16))
	print("il compagno non resta indietro: dopo un salto di 40 tessere a %.1f tessere, chiuso dietro un muro a %.1f" % [far1, far2])
	if far1 > 4.0 or far2 > 6.0:
		print("ATTENZIONE: il compagno resta indietro")
