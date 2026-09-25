class_name TestsAncient
extends RefCounted
## Prove delle creature antiche (voce 20b): probabilità per zona, statistiche e tratti, veleno e spine sul Germogliato,
## Essenze nel bottino, innesto al Maglio, e una foto di gruppo (41_antiche).

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


func _essences() -> int:
	var n := 0
	for d in m.drops._items:
		if String(d["id"]).begins_with("essenza_"):
			n += int(d["n"])
	return n


func run() -> void:
	var fauna: Fauna = m.fauna
	var v: Vitals = m.vitals
	# probabilità per zona, contate su molti tiri
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var line := "creature rare su 10000 nascite:"
	for d in [1.0, 2.5, 4.5, 5.5]:
		var a := 0
		var b := 0
		for k in 10000:
			var r := AncientData.roll_rarity(d, rng)
			if r == "antica":
				a += 1
			elif r == "ancestrale":
				b += 1
		line += " pericolo %.1f → antiche %.1f%%, ancestrali %.2f%% ·" % [d, a / 100.0, b / 100.0]
	print(line)
	var spot := kit.flat_spot(world.spawn, 6)
	m.snap_to(spot)
	fauna.clear()
	await kit.frames(5)
	# statistiche: una strisciaradice antica Corazzata
	var c := fauna.add("strisciaradice", _feet(spot.x + 3, "strisciaradice"))
	var hp0 := c.hp_max
	var def0 := c.defense
	fauna.make_ancient(c, "antica", ["corazzata"])
	print("strisciaradice antica Corazzata: Vita %d → %d, difesa %d → %d, barra sempre in vista %s" % [hp0, c.hp_max,
		def0, c.defense, "sì" if c._bar.visible else "NO"])
	fauna.clear()
	# veleno: un grumo antico Velenoso addosso
	v.refill()
	m.combat.invuln = 0.0
	var g := fauna.add("grumo_muschio", m.player.position + Vector2(4, 0))
	fauna.make_ancient(g, "antica", ["velenosa"])
	await kit.frames(4)
	fauna.clear()
	var after_hit := v.hp
	await kit.seconds(2.0)
	print("veleno: avvelenato %s, Vita dopo il colpo %d, dopo 2 s %d" % ["sì" if v.poison_t > 0.0 or v.hp < after_hit else "NO",
		after_hit, v.hp])
	v.poison_t = 0.0
	v.refill()
	# spine: colpire da vicino una creatura Spinosa ferisce anche il Germogliato
	var sp := fauna.add("strisciaradice", m.player.position + Vector2(20, 0))
	sp.set_process(false)
	fauna.make_ancient(sp, "antica", ["spinosa"])
	var hp_before := v.hp
	m.combat._strike(sp, 10, m.player.position.x, 0.5)
	print("spine: Vita del Germogliato da %d a %d colpendo una Spinosa" % [hp_before, v.hp])
	# essenze: un'ancestrale abbattuta lascia un'Essenza per ogni tratto
	var e0 := _essences()
	var anc := fauna.add("scarabeo_ardesia", _feet(spot.x + 6, "scarabeo_ardesia"))
	fauna.make_ancient(anc, "ancestrale", ["furiosa", "gigante", "luminosa"])
	fauna.kill(anc)
	await kit.frames(3)
	print("ancestrale abbattuta: Essenze a terra +%d (attese 3)" % (_essences() - e0))
	fauna.clear()
	v.refill()
	# innesto al Maglio: l'Essenza di furia sulla spada in mano
	var b: Bisaccia = m.character.bisaccia
	b.add("essenza_furia", 1)
	var slot := kit.hold("spada_radice")
	var tr := Crafting.graft(b, slot, "essenza_furia")
	print("innesto: Spada di radice ora [%s], danno ×%.2f, essenze rimaste %d" % [tr, TraitsData.effect(tr, "damage"),
		b.count("essenza_furia")])
	# foto di gruppo: una creatura antica o ancestrale per tipo, ferme, con aura e nomi
	var dx := -12
	var looks := [["grumo_muschio", "antica", ["furiosa"]], ["falena_brace", "antica", ["luminosa"]],
		["strisciaradice", "ancestrale", ["gigante", "velenosa"]], ["scarabeo_ardesia", "antica", ["corazzata"]],
		["sputaspore", "ancestrale", ["evocatrice", "spinosa", "esplosiva"]]]
	for L in looks:
		var x: int = spot.x + dx
		var pos := _feet(x, String(L[0]))
		if CreaturesData.CREATURES[L[0]].get("fly", false):
			pos.y -= 30
		var cr := fauna.add(String(L[0]), pos)
		cr.set_process(false)
		fauna.make_ancient(cr, String(L[1]), L[2])
		cr._animate(0.1)
		cr.ancient.tick(cr, 0.1)
		dx += 6
	await kit.seconds(3.0)
	await kit.save("41_antiche")
	fauna.clear()
	fauna.light.set_extra("antiche", [])
