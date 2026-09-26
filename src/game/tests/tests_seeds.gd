class_name TestsSeeds
extends RefCounted
## Prove delle voci 39 e 42: quanti geni secondo il vigore; due mondi dallo stesso seme, uno semplice e uno di sporangio
## con Rovine fitte, Gemme ricche e Vene ricche (paludi, scrigni, gemme, minerali a confronto); il Seme di resina
## nella Bisaccia ha il suo genoma, piantato dà un portale con gli stessi geni, che il primo tocco racconta; gli
## effetti dei geni mentre si gioca.

const S := 16
const GEMS := [23, 24, 25, 26]

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _census(w: World) -> Dictionary:
	var palude := 0
	for x in w.w:
		if int(w.biomes[x]) == BiomesData.index_of("palude"):
			palude += 1
	var gems := 0
	for d in w.decor:
		if d in GEMS:
			gems += 1
	var ores := 0
	for t in w.tiles:
		if t in [TileDefs.RADICITE, TileDefs.LEGNOFERRO, TileDefs.AMBRA, TileDefs.PALLIDITE, TileDefs.TIZZONITE]:
			ores += 1
	return {"paludi": roundi(100.0 * palude / w.w), "scrigni": w.stations.values().count("scrigno"), "gemme": gems,
		"minerali": ores}


func run() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var counts := []
	for v in [2, 3, 5, 9]:
		counts.append(Genome.genes(Genome.roll(rng, v)).size() - 1)
	print("geni oltre la superficie per vigore 2, 3, 5, 9: %s" % [counts])
	# due mondi dallo stesso seme
	var plain := World.new()
	WorldGen.generate(plain, 4242, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 2})
	var rich := World.new()
	WorldGen.generate(rich, 4242, WorldGen.WIDTH, WorldGen.HEIGHT,
		{"vigore": 2, "geni": ["sporangio", "rovine_fitte", "gemme_ricche", "vene_ricche"]})
	var a := _census(plain)
	var b := _census(rich)
	print("mondo semplice %s · mondo di sporangio ricco %s; partenza nella palude %s" % [a, b,
		"sì" if int(rich.biomes[rich.spawn.x]) == BiomesData.index_of("palude") else "NO"])
	if int(b["paludi"]) <= int(a["paludi"]) or int(b["scrigni"]) <= int(a["scrigni"]) or int(b["gemme"]) <= int(a["gemme"]) \
			or int(b["minerali"]) <= int(a["minerali"]):
		print("ATTENZIONE: i tratti del Seme non hanno cambiato il mondo come dovevano")
	await kit.frames(2)
	# il Seme di resina piantato
	kit.make_room()
	var spot := kit.flat_spot(world.spawn + Vector2i(90, 0), 8)
	if spot.x < 0:
		print("ATTENZIONE: nessun terreno per il portale")
		return
	kit.flatten(spot, 8)
	m.snap_to(spot + Vector2i(-3, 0))
	kit.aiuola(spot)
	var hs: int = kit.hold("seme_mondo_resina")
	var g: Dictionary = m.character.bisaccia.data_at(hs).duplicate(true)
	var planted: bool = m.portal.plant(spot, "seme_mondo_resina")
	var o := spot - Vector2i(1, 3)
	var e: Dictionary = m.world_meta.get("portali", {}).get("%d,%d" % [o.x, o.y], {})
	await kit.frames(2)
	m.guardian.lore.visible = false          # la pagina del portale
	m.portal.touch(o)
	print("Seme di resina con il suo genoma %s (vigore %d), piantato %s: geni del portale %s, uguali %s; primo tocco: «%s»" % [
		Genome.genes(g), Genome.vigor(g), "sì" if planted else "NO", e.get("geni", []),
		"sì" if e.get("geni", []) == Genome.genes(g) and Genome.surface_of(e.get("geni", [])) == "resina" else "NO",
		m.portal.describe(o)])
	# la scheda del mondo con il mouse sopra il portale
	Tips.show_at(StationTip.portal(m, o), Vector2(560, 120))
	await kit.frames(4)
	await kit.save("109_scheda_portale")
	var tip_text: String = PortalInfo.text(m.portal, o)
	Tips.unpin()
	print("scheda del portale: vigore %s, Guardiano %s, stagione %s, mai visitato %s, genoma %s" % [
		"sì" if tip_text.contains("Vigore") else "NO", "sì" if tip_text.contains("Guardiano del Cuore") else "NO",
		"sì" if tip_text.contains("Stagione") else "NO", "sì" if tip_text.contains("mai visitato") else "NO",
		"sì" if tip_text.contains("Genoma") else "NO"])
	if not (tip_text.contains("Vigore") and tip_text.contains("Genoma")):
		print("ATTENZIONE: la scheda del portale è incompleta")
	# la scheda del Seme in Esamina: il genoma, con i geni mai visti come «?»
	var sheet := ItemInfo.bbcode("seme_mondo_resina", "", g)
	print("scheda del Seme: genoma %s, vigore %s" % ["sì" if sheet.contains("Genoma") else "NO",
		"sì" if sheet.contains("vigore %d" % Genome.vigor(g)) else "NO"])
	# gli effetti dei tratti mentre si gioca
	var wt: WorldTraits = m.world_traits
	m.day.time = 0.26
	var dawn0: float = m.day.daylight()
	wt.genes = ["sporangio", "brulicante", "notti_lunghe", "fertile", "stellato", "avvizzito"]
	wt.apply()
	var dawn1: float = m.day.daylight()
	print("tratti in gioco: pericolo %+.1f, Lumini ×%.1f, colture ×%.1f, eventi ×%.1f, Avvizzimento ×%.1f; luce all'alba %.2f → %.2f; scheda: %s" % [
		m.fauna.world_danger, m.fauna.world_lumini, m.garden.grow_mult, m.events.chance_mult, m.blight.spread_mult,
		dawn0, dawn1, "sì" if CharacterSheet.bbcode(m).contains("Questo mondo") else "NO"])
	wt.genes = []
	wt.apply()
	m.day.time = 0.5
	m.day.apply(true)
	await kit.frames(2)
