class_name TestsEcology
extends RefCounted
## Prove della Roadmap 7 «L'ecologia». Voce 55: le varianti di una famiglia (taglia, elemento, indole) cambiano
## valori, debolezze e disegno (foto 91_varianti); le docili non feriscono finché non le colpisci; le timide scappano;
## quante varianti nascono a caso.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	await variants()


func _feet(c: Vector2i, id: String) -> Vector2:
	return Vector2(c.x * S + 8, (c.y + 1) * S - float(CreaturesData.get_data(id)["half"][1]) - 0.1)


func variants() -> void:
	var spot := kit.flat_spot(world.spawn + Vector2i(40, 0), 12)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto per le varianti")
		return
	kit.flatten(spot, 12)
	m.fauna.clear()
	m.snap_to(spot)
	await kit.frames(3)
	var ids := ["grumo_muschio", "grumo_muschio~grande~~", "grumo_muschio~piccolo~~", "grumo_muschio~~gelo~",
		"grumo_muschio~~brace~feroce", "grumo_muschio~grande~luce~", "grumo_muschio~~vuoto~docile", "grumo_muschio~~spora~timida"]
	var made: Array[Creature] = []
	for k in ids.size():
		var c: Creature = m.fauna.add(ids[k], _feet(spot + Vector2i(-10 + k * 3, 0), ids[k]))
		c.set_process(false)
		made.append(c)
	m.boons.add("bagliore", 4.0)
	await kit.seconds(0.6)
	await kit.save("91_varianti")
	var big := CreaturesData.get_data("grumo_muschio~grande~~")
	var norm := CreaturesData.get_data("grumo_muschio")
	var cold := CreaturesData.get_data("grumo_muschio~~gelo~")
	print("varianti del grumo di muschio: «%s» Vita %d contro %d; «%s» debole a %s, resiste a %s; nomi: %s" % [big["name"],
		int(big["hp"]), int(norm["hp"]), cold["name"], cold["weak"], cold["resist"],
		", ".join(ids.map(func(i: String) -> String: return String(CreaturesData.get_data(i)["name"])))])
	m.fauna.clear()
	# una docile non ferisce finché non la colpisci
	m.vitals.refill()
	var hp0: int = m.vitals.hp
	var d: Creature = m.fauna.add("grumo_muschio~~~docile", m.player.position + Vector2(4, 0))
	await kit.seconds(0.6)
	var calm_hurt: int = hp0 - m.vitals.hp
	m.combat._strike(d, 1, m.player.position.x - 20, 0.1)
	m.combat.invuln = 0.0
	m.vitals.refill()
	d.position = m.player.position + Vector2(4, 0)
	await kit.seconds(0.6)
	var angry_hurt: int = m.vitals.hp_max - m.vitals.hp
	print("docile: ferite senza provocarla %d, dopo un colpo %d (provocata %s)" % [calm_hurt, angry_hurt, "sì" if d.provoked else "NO"])
	m.fauna.clear()
	# una timida scappa
	var t: Creature = m.fauna.add("strisciaradice~~~timida", _feet(spot + Vector2i(3, 0), "strisciaradice"))
	var x0 := t.position.x
	await kit.seconds(1.5)
	print("timida: si allontana di %.0f px" % (t.position.x - x0))
	m.fauna.clear()
	# quante varianti nascono a caso
	var rng := RandomNumberGenerator.new()
	rng.seed = 55
	var n := {"normali": 0, "taglia": 0, "elemento": 0, "indole": 0}
	for k in 1000:
		var v := FamiliesData.roll_variant("grumo_muschio", rng, "gelo", 1.0)
		var pr := FamiliesData.parts(v)
		if v == "grumo_muschio":
			n["normali"] += 1
		if pr[1] != "":
			n["taglia"] += 1
		if pr[2] != "":
			n["elemento"] += 1
		if pr[3] != "":
			n["indole"] += 1
	print("1000 grumi a caso: %s" % [n])
	if calm_hurt > 0 or angry_hurt <= 0 or int(big["hp"]) <= int(norm["hp"]):
		print("ATTENZIONE: le varianti non si comportano come dovrebbero")
