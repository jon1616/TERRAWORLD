class_name TestsEcology
extends RefCounted
## Prove della Roadmap 7 «L'ecologia». Voce 55: le varianti di una famiglia (taglia, elemento, indole) cambiano
## valori, debolezze e disegno (foto 91_varianti); le docili non feriscono finché non le colpisci; le timide scappano;
## quante varianti nascono a caso. Voce 56: le famiglie nuove e la fauna di ogni mondo.

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
	await new_families()


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


## Voce 56: le dieci famiglie nuove (foto 92_famiglie), le tane dei Custodi dei biomi nel mondo di prova, due mondi con
## semi e geni di fauna diversi hanno faune diverse.
func new_families() -> void:
	var spot := kit.flat_spot(world.spawn + Vector2i(60, 0), 6)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto per le famiglie nuove")
		return
	kit.flatten(spot, 16)
	m.fauna.clear()
	m.snap_to(spot)
	await kit.frames(3)
	var ids := ["pecora_muschio", "cornoradice", "lepre_linfa", "bruco_lanterna", "ape_lume", "formica_resina",
		"pipistrello_corteccia", "libellula_brina", "volpe_ambra", "lince_ardesia"]
	for k in ids.size():
		var c: Creature = m.fauna.add(ids[k], _feet(spot + Vector2i(-15 + k * 3, 0), ids[k]) + (Vector2(0, -20) if CreaturesData.get_data(ids[k]).get("fly", false) else Vector2.ZERO))
		c.set_process(false)
	m.boons.add("bagliore", 4.0)
	await kit.seconds(0.6)
	await kit.save("92_famiglie")
	m.fauna.clear()
	var dens := []
	for o in world.stations:
		if String(world.stations[o]) in ["bozzolo_grande_cervo", "bozzolo_madre_salamandre"]:
			dens.append(world.stations[o])
	print("famiglie: %d (nuove 10); tane dei Custodi dei biomi nel mondo di prova: %s" % [FamiliesData.FAMILIES.size(), dens])
	# due mondi: famiglie favorite e assenti dal seme, ruoli dai geni
	var a := Fauna.family_weights(1111)
	var b := Fauna.family_weights(2222)
	var fa: Fauna = m.fauna
	var old_f := fa.family_mult
	var old_r := fa.role_mult
	var shares := []
	for genes in [["lanterna", "pascoli"], ["lanterna", "cacciatori"]]:
		fa.set_world(1111, genes, Genome.effects(genes, "run")["roles"])
		var tot := 0.0
		var herb := 0.0
		for e in CreaturesData.of_stratum(0, false, "foresta"):
			var wgt := float(e[1]) * fa.weight_of(String(e[0]))
			tot += wgt
			if String(FamiliesData.FAMILIES.get(FamiliesData.family_of(String(e[0])), {}).get("role", "")) == "erbivoro":
				herb += wgt
		shares.append(roundi(100.0 * herb / maxf(tot, 1.0)))
	fa.family_mult = old_f
	fa.role_mult = old_r
	print("mondo 1111: favorite/assenti %s · mondo 2222: %s · erbivori nella foresta con Pascoli %d%%, con Cacciatori %d%%" % [a, b,
		shares[0], shares[1]])
	if a == b or shares[0] <= shares[1] or dens.size() < 2:
		print("ATTENZIONE: la fauna non cambia con il mondo come dovrebbe")
