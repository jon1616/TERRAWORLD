class_name TestsNero
extends RefCounted
## Prove del Seme Nero (voce 72): il Seme Nero piantato in un'Aiuola porta al mondo «Dove cadde il Seme Nero»; quel
## mondo nasce con la roccia malata attorno al Cuore; il suo Guardiano è l'Avvizzitore (malato e guarito, foto
## 135-136); la scelta vale per tutti i mondi: curato l'Avvizzimento si ritira, spezzato non si allarga più.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var ch: Character = m.character
	var had_nero := String(ch.seme_nero)
	# il mondo dove cadde
	var w1 := World.new()
	WorldGen.generate(w1, 9090, 1600, 900, {"geni": ["cenere", "abissale", "cuore_nero"], "vigore": 4, "nero": true})
	var cu: Vector2i = w1.gen_notes.get("cuore", Vector2i(-1, -1))
	var sick := 0
	for y in range(cu.y - 40, cu.y + 20):
		for x in range(cu.x - 60, cu.x + 60):
			if w1.inside(x, y) and w1.tile(x, y) == TileDefs.AVV_PIETRA:
				sick += 1
	# il Seme Nero nell'Aiuola
	var spot := kit.flat_spot(world.spawn + Vector2i(60, 0), 8)
	if spot.x < 0:
		spot = kit.floor_near(world.spawn + Vector2i(60, 0), 40)
	kit.flatten(spot, 6)
	m.snap_to(spot + Vector2i(-3, 0))
	kit.aiuola(spot)
	var g := {"geni": Genome.sort(["cenere", "abissale", "cuore_nero"]), "vigore": 4, "nero": true}
	kit.bisaccia().add_stack({"id": "seme_nero", "n": 1, "dati": g})
	kit.hold("seme_nero")
	var planted: bool = m.portal.plant(spot, "seme_nero")
	m.guardian.lore.visible = false
	var o := spot - Vector2i(1, 3)
	var e: Dictionary = m.world_meta.get("portali", {}).get("%d,%d" % [o.x, o.y], {})
	var dest_name := String(m.portal.destination(o)[1]) if not e.is_empty() else ""
	# il Guardiano di quel mondo, e il suo aspetto
	var had_meta: Variant = m.world_meta.get("nero", null)
	m.world_meta["nero"] = true
	var gi: Dictionary = m.guardian.info()
	var cr: Creature = m.fauna.add("avvizzitore", m.player.position + Vector2(90, -60))
	cr.stun = 30.0
	m.boons.add("bagliore", 20.0)
	await kit.seconds(0.6)
	await kit.save("135_avvizzitore")
	cr.make_calm()
	await kit.seconds(0.6)
	await kit.save("136_avvizzitore_guarito")
	m.fauna.kill_quietly(cr)
	# la scelta, per tutti i mondi
	ch.seme_nero = ""
	m.guardian.nero_choice("curato")
	var cured := String(ch.seme_nero)
	var b: Blight = m.blight
	var n0: int = b.cells.size()
	b.tick()
	var n1: int = b.cells.size()
	ch.seme_nero = "spezzato"
	var state0 := String(m.world_meta.get("guardiano", "dorme"))
	m.world_meta["guardiano"] = "dorme"
	var n2: int = b.cells.size()
	b.tick()
	var n3: int = b.cells.size()
	m.world_meta["guardiano"] = state0
	ch.seme_nero = had_nero
	if had_meta == null:
		m.world_meta.erase("nero")
	else:
		m.world_meta["nero"] = had_meta
	print("Seme Nero: mondo con la roccia malata attorno al Cuore %d tessere; piantato %s, porta a «%s» (nero %s); Guardiano %s; curato → «%s», Avvizzimento %d → %d; spezzato: %d → %d" % [
		sick, "sì" if planted else "NO", dest_name, e.get("nero", false), gi.get("creature", ""), cured, n0, n1, n2, n3])
	if sick < 100 or not planted or dest_name != NeroData.WORLD_NAME or String(gi.get("creature", "")) != "avvizzitore" \
			or cured != "curato" or (n0 > 0 and n1 >= n0) or n3 > n2:
		print("ATTENZIONE: il Seme Nero non funziona come dovrebbe")
