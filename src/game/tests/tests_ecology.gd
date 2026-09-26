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
	# il Germogliato deve stare fermo quando nessuno lo comanda (nel giro lungo, a volte, se ne andava da solo)
	var q0: Vector2 = m.player.position
	await kit.seconds(1.0)
	if m.player.position.distance_to(q0) > 40.0:
		print("ATTENZIONE: il Germogliato si muove da solo: %s → %s, velocità %s, a terra %s, rampino %s, comandi %s %s, controllo %s" % [
			q0, m.player.position, m.player.vel, m.player.on_floor, m.player.hook, m.player.auto_dir, m.player.auto_jump, m.player.control])
	await variants()
	await new_families()
	await food_chain()


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


## Voce 57: una volpe affamata caccia una lepre (con il Germogliato lontano); una pecora affamata bruca l'erba vicina;
## il modello delle popolazioni: cacciando le pecore calano, lasciate stare tornano verso l'equilibrio, e nessun valore
## esce dai limiti (400 passi, circa mezz'ora di gioco).
func food_chain() -> void:
	var eco: Ecology = m.ecology
	var spot := kit.flat_spot(world.spawn + Vector2i(-80, 0), 6)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto per la catena alimentare")
		return
	# spianato fin dove guarda il Germogliato (nel giro lungo, arrivato con poca Vita, appassiva su un pericolo lì
	# accanto e rinasceva al letto, lontano: le creature della prova sparivano)
	kit.flatten(spot, 28)
	m.fauna.clear()
	m.vitals.hp = m.vitals.hp_max
	m.vitals.changed.emit()
	m.snap_to(spot + Vector2i(24, 0))                 # il Germogliato guarda da lontano
	await kit.frames(3)
	var h0 := eco.hunts
	# la fuga: una lepre accanto a una volpe che la caccia si allontana
	var fox: Creature = m.fauna.add("volpe_ambra", _feet(spot + Vector2i(-4, 0), "volpe_ambra"))
	var hare: Creature = m.fauna.add("lepre_linfa", _feet(spot + Vector2i(1, 0), "lepre_linfa"))
	fox.hunger = 1.0
	fox.set_process(false)
	fox.hunt = hare
	var d0 := hare.position.distance_to(fox.position)
	# nel giro lungo una volta la lepre è sparita durante la fuga: si annota chi l'ha tolta
	var why := {"cosa": ""}
	var on_kill := func(c: Creature) -> void:
		if c == hare or c == fox:
			why["cosa"] = "uccisa (%s, Vita %d)" % [c.id, c.hp]
	m.fauna.killed.connect(on_kill)
	var on_died := func() -> void: why["cosa"] = "il Germogliato è appassito (Vita %d)" % m.vitals.hp
	m.vitals.died.connect(on_died)
	var last := hare.position
	var t1 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t1 < 1000:
		await kit.frames(1)
		if not is_instance_valid(hare) or not is_instance_valid(fox):
			break
		last = hare.position
	m.fauna.killed.disconnect(on_kill)
	m.vitals.died.disconnect(on_died)
	if not is_instance_valid(hare) or not is_instance_valid(fox):
		print("ATTENZIONE: nella prova della caccia una creatura è sparita: %s; lepre vista l'ultima volta a %s (Germogliato a %s, fondo del mondo %d)" % [
			why["cosa"] if why["cosa"] != "" else "tolta senza morire (lontana, caduta o ripulita)", last, m.player.position, world.h * S])
		m.fauna.clear()
		return
	var fled := hare.position.distance_to(fox.position) - d0
	# la caccia: la stessa volpe, una lepre che non scappa (la caccia non deve dipendere dal terreno attorno)
	hare.set_process(false)
	hare.position = _feet(spot + Vector2i(3, 0), "lepre_linfa")
	fox.set_process(true)
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 10000 and eco.hunts == h0:
		await kit.frames(1)
	print("caccia: la lepre scappa di %.0f px in un secondo; la volpe la prende %s (in %.1f s)" % [fled, "sì" if eco.hunts > h0 else "NO",
		(Time.get_ticks_msec() - t0) / 1000.0])
	m.fauna.clear()
	# il pascolo: erba attorno, una pecora affamata
	for dx in range(-6, 7):
		world.set_decor(spot.x + dx, spot.y, TileDefs.DECOR_GRASS[0])
	m.view.refresh_around(spot)
	var g0 := eco.grazed
	var sheep: Creature = m.fauna.add("pecora_muschio", _feet(spot, "pecora_muschio"))
	sheep.hunger = 1.0
	t0 = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 12000 and eco.grazed == g0:
		await kit.frames(1)
	print("pascolo: la pecora bruca %s (in %.1f s)" % ["sì" if eco.grazed > g0 else "NO", (Time.get_ticks_msec() - t0) / 1000.0])
	if eco.grazed == g0:
		print("  (pecora %s, fame %.2f, erba sotto i piedi %s, dal Germogliato %.0f px)" % [sheep.position if is_instance_valid(sheep) else "sparita",
			sheep.hunger if is_instance_valid(sheep) else -1.0, world.decor_at(spot.x, spot.y),
			sheep.position.distance_to(m.player.position) if is_instance_valid(sheep) else -1.0])
	m.fauna.clear()
	# il modello delle popolazioni
	var p := {0: {"pecore": 1.0, "lepri": 1.0, "volpi": 1.0, "grumi": 1.0}}
	var lo := 9.0
	var hi := 0.0
	for k in 60:
		p[0]["pecore"] = maxf(float(p[0]["pecore"]) - 0.08, Ecology.MIN)      # si caccia forte
		Ecology.step(p)
	var hunted_low := float(p[0]["pecore"])
	var fox_mid := float(p[0]["volpi"])
	for k in 400:
		Ecology.step(p)
		for f in p[0]:
			lo = minf(lo, float(p[0][f]))
			hi = maxf(hi, float(p[0][f]))
	print("popolazioni: pecore cacciate %.2f (volpi %.2f), dopo 400 passi pecore %.2f, volpi %.2f; tra %.2f e %.2f" % [hunted_low,
		fox_mid, float(p[0]["pecore"]), float(p[0]["volpi"]), lo, hi])
	if eco.hunts == h0 or fled < 8.0 or eco.grazed == g0 or float(p[0]["pecore"]) < 0.8 or lo < Ecology.MIN or hi > Ecology.MAX:
		print("ATTENZIONE: la catena alimentare non funziona come dovrebbe")
