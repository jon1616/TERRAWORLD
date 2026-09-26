class_name TestsRarity
extends RefCounted
## Prove della voce 23: probabilità delle quattro rarità per zona, il capobranco con il suo branco, l'iridata che non
## attacca, fugge e svanisce, i trofei e la Polvere iridata nel bottino, gli accessori dei trofei (danno, colpi più
## rapidi), l'Arco iridato che tira tre dardi; foto 47_rarita.

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


func _count(id: String) -> int:
	var n := 0
	for d in m.drops._items:
		if String(d["id"]) == id:
			n += int(d["n"])
	return n


func run() -> void:
	var fauna: Fauna = m.fauna
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var line := "rarità su 20000 nascite:"
	for d in [1.0, 2.5, 5.5]:
		var n := {}
		for k in 20000:
			var r := AncientData.roll_rarity(d, rng)
			n[r] = int(n.get(r, 0)) + 1
		line += " pericolo %.1f → antiche %.1f%%, capibranco %.1f%%, iridate %.2f%%, ancestrali %.2f%% ·" % [d,
			n.get("antica", 0) / 200.0, n.get("capobranco", 0) / 200.0, n.get("iridata", 0) / 200.0,
			n.get("ancestrale", 0) / 200.0]
	print(line)
	var spot := kit.flat_spot(world.spawn, 6)
	if spot.x < 0:
		print("ATTENZIONE: nessun terreno piano per le prove delle rarità")
		return
	m.snap_to(spot)
	fauna.clear()
	m.combat.god = true
	await kit.frames(4)
	# capobranco: nasce con il suo branco
	var lead := fauna.add("grumo_muschio", _feet(spot.x + 8, "grumo_muschio"))
	fauna.make_ancient(lead, "capobranco")
	fauna.pack(lead, "grumo_muschio", 1.0)
	print("capobranco: %s con %d compagne (Vita %d)" % [lead.ancient._label.text, fauna.list.size() - 1, lead.hp_max])
	# trofeo: un capobranco abbattuto lascia sempre il trofeo della specie
	var t0 := _count("nucleo_muschio")
	fauna.kill(lead)
	await kit.frames(2)
	print("trofeo del capobranco: Nucleo di grumo di muschio +%d" % (_count("nucleo_muschio") - t0))
	fauna.clear()
	# iridata: non attacca, fugge dal Germogliato, lascia Polvere iridata; se non la prendi svanisce
	var ir := fauna.add("saltafungo", _feet(spot.x + 4, "saltafungo"))
	fauna.make_ancient(ir, "iridata")
	var x0 := ir.position.x
	await kit.seconds(2.5)
	print("iridata: danno %d, fuggita di %.0f tessere (si allontana %s)" % [ir.damage, absf(ir.position.x - x0) / S,
		"sì" if absf(ir.position.x - m.player.position.x) > absf(x0 - m.player.position.x) else "NO"])
	var p0 := _count("polvere_iridata")
	var tr0 := _count("cappello_saltafungo")
	fauna.kill(ir)
	await kit.frames(2)
	print("iridata abbattuta: Polvere iridata +%d, trofeo +%d" % [_count("polvere_iridata") - p0, _count("cappello_saltafungo") - tr0])
	var ir2 := fauna.add("grumo_resina", _feet(spot.x + 10, "grumo_resina"))
	fauna.make_ancient(ir2, "iridata")
	ir2.ancient.life = 0.2
	await kit.seconds(0.6)                  # in secondi: a 134 fotogrammi al secondo 20 fotogrammi non bastavano
	print("iridata non presa: svanita %s" % ("sì" if not is_instance_valid(ir2) or not fauna.list.has(ir2) else "NO"))
	# foto: un capobranco con il branco, un'iridata e un'antica
	fauna.clear()
	var ld := fauna.add("spinoriccio", _feet(spot.x + 6, "spinoriccio"))
	fauna.make_ancient(ld, "capobranco", ["furiosa"])
	fauna.pack(ld, "spinoriccio", 1.0)
	var iri := fauna.add("corvo_corteccia", m.player.position + Vector2(-60, -40))
	fauna.make_ancient(iri, "iridata")
	for c in fauna.list:
		c.set_process(false)
		c._animate(0.1)
		if c.ancient:
			c.ancient.tick(c, 0.8)
	await kit.seconds(2.0)
	await kit.save("47_rarita")
	fauna.clear()
	# accessori dei trofei: danno e colpi più rapidi
	var b: Bisaccia = m.character.bisaccia
	b.wear("accessorio_1", {})
	b.wear("accessorio_2", {})
	b.wear("accessorio_1", {"id": "schegge_orbitanti", "n": 1})
	b.wear("accessorio_2", {"id": "guanti_seta", "n": 1})
	await kit.frames(1)
	print("accessori dei trofei: danno ×%.2f, colpi ×%.2f" % [m.combat.dmg_mult, m.combat.spd_mult])
	b.wear("accessorio_1", {})
	b.wear("accessorio_2", {})
	# Arco iridato: tre dardi per tiro
	b.add("dardo", 20)
	kit.hold("arco_iridato")
	var s0: int = m.shots.count()
	m.combat.auto_aim = m.player.position + Vector2(200, -20)
	m.combat.auto_fire = true
	await kit.frames(2)
	m.combat.auto_fire = false
	print("Arco iridato: dardi in volo %d con un tiro" % (m.shots.count() - s0))
	m.combat.auto_aim = Vector2.INF
	m.combat.god = false
	await kit.seconds(1.0)
