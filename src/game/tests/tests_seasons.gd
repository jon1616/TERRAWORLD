class_name TestsSeasons
extends RefCounted
## Prove delle stagioni (voce 66): la stagione di ogni giorno del mondo di prova, il cambio con la scritta, i pesi delle
## famiglie che cambiano (i cervi del gelo), la creatura della stagione con il suo bottino (foto 107_stagione), la
## Provetta che cattura il gene della stagione, il gene che fissa la stagione.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var se: Seasons = m.seasons
	var names := []
	for d in range(1, 14):
		names.append(String(SeasonsData.SEASONS[SeasonsData.index(d, world.world_seed)]["id"]).substr(0, 4))
	var day0: int = m.day.day
	# al Germoglio, poi al Gelo: i pesi cambiano
	var w := {}
	for target in [0, 3]:
		var d := 1
		while SeasonsData.index(d, world.world_seed) != target:
			d += 1
		m.day.day = d
		await kit.seconds(1.3)
		w[target] = m.fauna.weight_of("cervo_brina") / maxf(m.fauna.weight_of("pecora_muschio"), 0.01)
	var gelo := se.current
	# la creatura della stagione (il Gelo: il Cervo del gelo), e il suo bottino
	var spot := kit.flat_spot(world.spawn + Vector2i(30, 0), 6)
	kit.flatten(spot, 8)
	m.snap_to(spot + Vector2i(-4, 0))
	m.fauna.clear()
	var cid: String = m.fauna.season_creature
	var cr: Creature = m.fauna.add(cid, Vector2(spot.x * S + 40, (spot.y + 1) * S - float(CreaturesData.get_data(cid)["half"][1]) - 0.1))
	cr.set_process(false)
	m.boons.add("bagliore", 4.0)
	await kit.seconds(0.8)
	await kit.save("107_stagione")
	m.fauna.kill(cr)
	await kit.frames(2)
	var loot := []
	for it in m.drops._items:
		loot.append(String(it["id"]))
	# la Provetta nell'aria della superficie
	var b := kit.bisaccia()
	kit.make_room()
	b.add("provetta", 12)
	var gene := String(SeasonsData.SEASONS[gelo]["gene"])
	var got := 0
	# una cella di cielo a portata (sopra un albero o una pianta la Provetta prenderebbe la flora)
	var sky: Vector2i = m.player_cell() + Vector2i(1, -2)
	for dx in range(-3, 4):
		for dy in range(-4, -1):
			var q: Vector2i = m.player_cell() + Vector2i(dx, dy)
			if m.sampling.category_at(q) in ["cielo", "tempo"] and m.actions.in_reach(q):
				sky = q
	for k in 12:
		kit.hold("provetta")
		m.sampling.use_vial("provetta", sky)
		got = b.count(GenesData.vial_of(gene))
		if got > 0:
			break
	var fixed := SeasonsData.index(7, world.world_seed, int(Genome.effects([gene], "run")["season"]))
	m.day.day = day0
	await kit.seconds(1.2)
	print("stagioni del mondo di prova, giorno per giorno: %s; cervi/pecore al Germoglio %.2f, al Gelo %.2f; creatura del %s: %s (bottino %s); Fiala di %s presa %s; con il gene la stagione resta %s; l'orologio dice «%s»" % [
		names, w[0], w[3], SeasonsData.SEASONS[gelo]["name"], CreaturesData.get_data(cid)["name"], loot, gene, "sì" if got > 0 else "NO",
		SeasonsData.SEASONS[fixed]["name"], m.day.clock_text()])
	if w[3] <= w[0] or cid == "" or not "cristallo_gelo" in loot or got == 0 or fixed != gelo:
		print("ATTENZIONE: le stagioni non funzionano come dovrebbero")
