class_name TestsGenes
extends RefCounted
## Prove del piano «Il Giardiniere dei mondi» (voci 43-48). Voce 43: i geni del generatore cambiano davvero il mondo
## (tre mondi piccoli dallo stesso seme: semplice, «cavo» e «compatto» con altri geni a confronto), un Seme trovato ha
## sempre un gene di forma, grotte o sottosuolo; una fungaia e un fiume di brace copiati nel mondo di prova e
## fotografati (80_fungaia, 81_fiume_brace).
## Voce 44: le dodici firme costruite in mondi piccoli (ognuna con il suo scrigno, la Linfa antica e il ricordo),
## due fotografate (82_firma_albero, 83_firma_bolla); la firma del mondo di prova si trova avvicinandosi; i nomi dei
## mondi nuovi.

const S := 16
const W := 1400                        # mondi piccoli: la prova resta svelta

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	await generator()
	await signatures()
	await aiuole()
	await genes_found()
	await grafting()
	await rare_genes()


func _census(w: World) -> Dictionary:
	var under := 0
	var air := 0
	for y in w.h:
		for x in range(0, w.w, 2):
			if y > w.surface[x] + 8:
				under += 1
				if w.tiles[y * w.w + x] == TileDefs.AIR:
					air += 1
	var rough := 0
	for x in range(1, w.w):
		rough += absi(w.surface[x] - w.surface[x - 1])
	var trees := 0
	for k in w.trees:
		trees += (w.trees[k] as Array).size()
	var ore := 0
	for t in w.tiles:
		if t == TileDefs.RADICITE:
			ore += 1
	return {"grotte": roundi(100.0 * air / maxi(under, 1)), "salti": rough, "alberi": trees, "radicite": ore,
		"sottosuolo": w.gen_notes.get("sottosuolo", {}), "avvizzimento": (w.gen_notes.get("avvizzimento", []) as Array).size()}


func generator() -> void:
	var sd := 5150
	var ws: Array[World] = await kit.gen_many([[sd, W, WorldGen.HEIGHT, {"vigore": 3}],
		[sd, W, WorldGen.HEIGHT, {"vigore": 3, "geni": ["sporangio", "montagne", "cavo", "fungaie", "radicite_diffusa", "rigoglioso", "sano"]}],
		[sd, W, WorldGen.HEIGHT, {"vigore": 3, "geni": ["cenere", "pianure", "compatto", "fiumi_brace", "spoglio", "avvizzito"]}]])
	var plain := ws[0]
	var a := ws[1]
	var b := ws[2]
	var cp := _census(plain)
	var ca := _census(a)
	var cb := _census(b)
	print("geni del generatore: semplice %s · A (montagne, cavo, fungaie, radicite diffusa, rigoglioso, sano) %s · B (pianure, compatto, fiumi di brace, spoglio, avvizzito) %s" % [cp, ca, cb])
	var ok: bool = int(ca["grotte"]) > int(cp["grotte"]) and int(cb["grotte"]) < int(cp["grotte"]) \
		and int(ca["salti"]) > int(cb["salti"]) and int(ca["alberi"]) > int(cb["alberi"]) \
		and int(ca["radicite"]) > int(cp["radicite"]) and int(ca["sottosuolo"].get("fungaie", 0)) > 0 \
		and int(cb["sottosuolo"].get("fiumi_brace", 0)) > 0 and int(ca["avvizzimento"]) == 0 \
		and int(cb["avvizzimento"]) > int(cp["avvizzimento"])
	print("i geni cambiano il mondo come dicono: %s" % ("sì" if ok else "NO"))
	if not ok:
		print("ATTENZIONE: un gene del generatore non ha l'effetto promesso")
	# un Seme trovato ha sempre un gene che cambia la forma del mondo
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var shaped := 0
	for k in 40:
		var gs := Genome.genes(Genome.roll(rng, 1 + k % 8))
		if gs.any(func(g: String) -> bool: return GenesData.cat_of(g) in Genome.SHAPE_CATS):
			shaped += 1
	print("Semi trovati con un gene di forma, grotte o sottosuolo: %d su 40" % shaped)
	# le foto: una fungaia e un fiume di brace copiati lontano dalla partenza del mondo di prova
	await _photo(a, "fungaie", "80_fungaia", Vector2i(420, 0))
	await _photo(b, "fiumi_brace", "81_fiume_brace", Vector2i(-420, 0))


## Copia il primo luogo di quel tipo dal mondo generato al mondo di prova (stessa profondità sotto la superficie,
## spostato di `shift` colonne dalla partenza), ci porta il Germogliato con la luce e fotografa.
func _photo(src: World, what: String, photo: String, shift: Vector2i) -> void:
	var list: Array = src.gen_notes.get("sottosuolo_pos", {}).get(what, [])
	if list.is_empty():
		print("ATTENZIONE: nessun luogo «%s» da fotografare" % what)
		return
	var p: Vector2i = list[0]
	var dep: int = p.y - src.surface[p.x]
	var to := Vector2i(world.spawn.x + shift.x, 0)
	to.y = world.surface[to.x] + dep
	var half := Vector2i(44, 20)
	for dy in range(-half.y, half.y + 1):
		for dx in range(-half.x, half.x + 1):
			var s := p + Vector2i(dx, dy)
			var d := to + Vector2i(dx, dy)
			if not src.inside(s.x, s.y) or not world.inside(d.x, d.y):
				continue
			var si := s.y * src.w + s.x
			var di := d.y * world.w + d.x
			world.tiles[di] = src.tiles[si]
			world.walls[di] = src.walls[si]
			world.decor[di] = src.decor[si]
	for dy in range(-half.y, half.y + 1, 8):
		for dx in range(-half.x, half.x + 1, 8):
			m.view.refresh_around(to + Vector2i(dx, dy))
	# il Germogliato in un punto d'aria vicino al centro, con la Lanterna per vedere
	var stand := to
	for r in 20:
		if not world.solid(to.x, to.y + r) and world.solid(to.x, to.y + r + 1):
			stand = Vector2i(to.x, to.y + r)
			break
	m.snap_to(stand)
	m.boons.add("bagliore", 6.0)             # nel buio vero la foto non mostrerebbe nulla
	m.boons.add("vista", 6.0)
	m.light.dirty = true
	await kit.seconds(1.2)
	await kit.save(photo)
	m.boons.active.erase("bagliore")
	m.boons.active.erase("vista")


func signatures() -> void:
	var ok := 0
	var fails := []
	var keep := {}
	var jobs := []
	for id in SignaturesData.SIGNATURES:
		jobs.append([777, 900, WorldGen.HEIGHT, {"vigore": 3, "firma": id}])
	var made: Array[World] = await kit.gen_many(jobs)       # le dodici firme insieme, in parallelo
	var wi := 0
	for id in SignaturesData.SIGNATURES:
		var w := made[wi]
		wi += 1
		var f: Dictionary = w.gen_notes.get("firma", {})
		var good := false
		if not f.is_empty() and f["id"] == id:
			var chest: Bisaccia = w.chests.get(f["scrigno"])
			good = chest != null and chest.count(String(SignaturesData.SIGNATURES[id]["ricordo"])) == 1 				and chest.count("linfa_antica") == 3
		if good:
			ok += 1
			if id in ["albero_colossale", "bolla_vuoto"]:
				keep[id] = w
		else:
			fails.append(id)
	print("firme costruite con scrigno, ricordo e Linfa antica: %d su %d%s" % [ok, SignaturesData.SIGNATURES.size(),
		"" if fails.is_empty() else " (mancano %s)" % [fails]])
	if not fails.is_empty():
		print("ATTENZIONE: alcune firme non si costruiscono")
	if keep.has("albero_colossale"):
		await _photo_at(keep["albero_colossale"], "82_firma_albero", Vector2i(-700, 0), Vector2i(0, -30))
	if keep.has("bolla_vuoto"):
		await _photo_at(keep["bolla_vuoto"], "83_firma_bolla", Vector2i(700, 0), Vector2i(0, 0))
	# la firma del mondo di prova: si trova avvicinandosi
	var sig: Signature = m.signature
	var had := sig.found()
	var ctr := sig.center()
	if ctr.x >= 0 and not had:
		var before := int(m.character.stats.get("firme", 0))
		m.snap_to(kit.floor_near(ctr, 30))
		sig._t = 0.0
		await kit.seconds(1.0)
		print("firma del mondo di prova «%s» trovata avvicinandosi: %s, conteggio firme %d → %d, riga della scheda «%s»" % [
			sig.info()["id"], "sì" if sig.found() else "NO", before, int(m.character.stats.get("firme", 0)), sig.sheet_line()])
		m.depth_watch.banner.visible = false
	else:
		print("ATTENZIONE: il mondo di prova non ha una firma da trovare")
	# i nomi dei mondi nuovi: dai geni e dal seme
	var names := []
	for k in 4:
		var rng := RandomNumberGenerator.new()
		rng.seed = 300 + k
		names.append(NamesData.world_name(Genome.genes(Genome.roll(rng, 4)), 1000 + k))
	print("nomi di mondi nuovi: %s; stesso Seme, stesso nome: %s" % [", ".join(names),
		"sì" if NamesData.world_name(["sporangio", "cavo"], 5) == NamesData.world_name(["sporangio", "cavo"], 5) else "NO"])


## Copia la firma di un mondo generato nel mondo di prova e la fotografa (`look`: dove guardare, dal centro).
func _photo_at(src: World, photo: String, shift: Vector2i, look: Vector2i) -> void:
	var f: Dictionary = src.gen_notes["firma"]
	var p := Vector2i(int(f["x"]), int(f["y"]))
	var dep: int = p.y - src.surface[p.x]
	var to := Vector2i(world.spawn.x + shift.x, 0)
	to.y = world.surface[to.x] + dep
	var half := Vector2i(46, 40)
	for dy in range(-half.y, half.y + 1):
		for dx in range(-half.x, half.x + 1):
			var s := p + Vector2i(dx, dy)
			var d := to + Vector2i(dx, dy)
			if not src.inside(s.x, s.y) or not world.inside(d.x, d.y):
				continue
			var si := s.y * src.w + s.x
			var di := d.y * world.w + d.x
			world.tiles[di] = src.tiles[si]
			world.walls[di] = src.walls[si]
			world.decor[di] = src.decor[si]
	for dy in range(-half.y, half.y + 1, 8):
		for dx in range(-half.x, half.x + 1, 8):
			m.view.refresh_around(to + Vector2i(dx, dy))
	m.snap_to(kit.floor_near(to + look, 20))
	m.boons.add("bagliore", 6.0)
	m.boons.add("vista", 6.0)
	m.light.dirty = true
	await kit.seconds(1.2)
	await kit.save(photo)
	m.boons.active.erase("bagliore")
	m.boons.active.erase("vista")


## Voce 45: le Aiuole (solo nel Giardino, al più tre), il Seme piantato nell'Aiuola diventa un portale, a terra no;
## il Semenzaio elenca la rete (foto 84_semenzaio); chiudere un mondo ridà il Seme dormiente con lo stesso genoma.
func aiuole() -> void:
	var ai: Aiuole = m.aiuole
	kit.make_room()
	var spot := kit.flat_spot(world.spawn + Vector2i(-60, 0), 8)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto per l'Aiuola")
		return
	m.snap_to(spot + Vector2i(-3, 0))
	await kit.frames(3)
	# a terra non si pianta più
	kit.flatten(spot, 6)
	var hs: int = kit.hold("seme_mondo_brina")
	var g: Dictionary = m.character.bisaccia.data_at(hs).duplicate(true)
	var on_ground: bool = m.portal.plant(spot, "seme_mondo_brina")
	# le regole delle Aiuole
	ai.bonus = -99
	var full: String = ai._can_place("aiuola")
	ai.bonus = 0
	var ok_home: String = ai._can_place("aiuola")
	kit.aiuola(spot)
	var planted: bool = m.portal.plant(spot, "seme_mondo_brina")
	var o := spot - Vector2i(1, 3)
	var e: Dictionary = m.world_meta.get("portali", {}).get("%d,%d" % [o.x, o.y], {})
	m.guardian.lore.visible = false
	print("Aiuole: nel Giardino %s, piene «%s», a terra %s, nell'Aiuola %s (portale d'Aiuola %s, geni %s), Aiuole contate %d" % [
		"sì" if ai.is_home() and ok_home == "" else "NO", full, "rifiutato" if not on_ground else "PIANTATO (NO)",
		"sì" if planted else "NO", "sì" if e.get("aiuola", false) else "NO", e.get("geni", []), ai.count()])
	# il Semenzaio
	var sp: SemenzaioPanel = null
	for c in m.hud.overlays:
		if c is SemenzaioPanel:
			sp = c
	sp.toggle()
	await kit.frames(6)
	await kit.save("84_semenzaio")
	print("Semenzaio: mondi nella rete %d, titolo «%s»" % [ai.network().size(), sp._title.text])
	sp.toggle()
	# chiudere il mondo dell'Aiuola: torna Aiuola, il Seme dormiente torna con lo stesso genoma
	var before: int = m.character.bisaccia.count(Genome.item_of(g))
	var closed: bool = ai.close(o)
	var back := false
	for i in m.character.bisaccia.slots.size():
		var d: Dictionary = m.character.bisaccia.data_at(i)
		if Genome.genes(d) == Genome.genes(g) and m.character.bisaccia.id_at(i) == Genome.item_of(g):
			back = true
	print("mondo chiuso %s: di nuovo Aiuola %s, Seme dormiente con lo stesso genoma %s (Semi %d → %d)" % [
		"sì" if closed else "NO", "sì" if world.stations.get(o, "") == "aiuola" else "NO", "sì" if back else "NO", before,
		m.character.bisaccia.count(Genome.item_of(g))])
	m.hud.toast("")


## Voce 46: la Provetta preleva il gene del mondo secondo ciò che tocca (e non si consuma dove il mondo non ne ha), la
## Fiala fa imparare il gene; le piante-seme del mondo di prova; una pianta-seme raccolta; il Seme selvatico figlio del
## mondo; le Fiale negli scrigni delle rovine; il Genario (foto 85_genario).
func genes_found() -> void:
	var wt: WorldTraits = m.world_traits
	var old: Array = wt.genes
	var sam: Sampling = m.sampling
	kit.make_room()
	var plants: int = world.stations.values().count("pianta_seme")
	var spot := kit.flat_spot(world.spawn + Vector2i(30, 0), 6)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto per la prova della Provetta")
		return
	kit.flatten(spot, 6)
	m.snap_to(spot)
	await kit.frames(3)
	# che cosa si tocca → quale categoria
	var sky := spot + Vector2i(1, -3)
	world.set_tile(spot.x + 2, spot.y + 1, TileDefs.GRASS)
	var cats := {"erba": sam.category_at(Vector2i(spot.x + 2, spot.y + 1)), "cielo": sam.category_at(sky)}
	var probe := Vector2i(spot.x + 3, spot.y + 1)
	for t in [[TileDefs.RADICITE, "vena"], [TileDefs.PIETRA_SEM, "pietra dei Seminatori"], [TileDefs.AVV_TERRA, "terra avvizzita"],
			[TileDefs.CRYSTAL, "cristallo"]]:
		world.set_tile(probe.x, probe.y, int(t[0]))
		cats[t[1]] = sam.category_at(probe)
	world.set_tile(probe.x, probe.y, TileDefs.STONE)
	print("la Provetta preleva: %s" % [cats])
	# un mondo senza geni: la Provetta non si consuma
	wt.genes = []
	var b: Bisaccia = m.character.bisaccia
	b.add("provetta", 3)
	kit.hold("provetta")
	var none: bool = sam.use_vial("provetta", sky)
	var left := b.count("provetta")
	# un mondo con i suoi geni
	wt.genes = ["sporangio", "stellato", "notti_lunghe", "cavo", "vene_ricche"]
	var before := int(m.character.stats.get("geni_imparati", 0))
	var got_sky: bool = sam.use_vial("provetta", sky)
	var got_grass: bool = sam.use_vial("provetta", Vector2i(spot.x + 2, spot.y + 1))
	await kit.frames(2)
	var learned := Genome.state("sporangio") == 2 and (Genome.state("stellato") == 2 or Genome.state("notti_lunghe") == 2)
	print("Provetta: in un mondo senza geni %s (Provette %d su 3), dal cielo %s, dall'erba %s (Fiala di Sporangio %d); geni imparati %s, conteggio %d → %d" % [
		"non si consuma" if not none else "CONSUMATA (NO)", left, "sì" if got_sky else "NO", "sì" if got_grass else "NO",
		b.count(GenesData.vial_of("sporangio")), "sì" if learned else "NO", before, int(m.character.stats.get("geni_imparati", 0))])
	# una pianta-seme raccolta: una Fiala o un Seme selvatico
	var o := spot + Vector2i(-2, -1)
	world.stations[o] = "pianta_seme"
	m.view.add_station(o)
	var drops0: int = m.drops.count()
	sam.harvest(o)
	var dropped: bool = m.drops.count() > drops0 or b.count(GenesData.vial_of("sporangio")) > 1
	var wild := sam.wild_seed()
	print("piante-seme nel mondo di prova %d; raccolta: %s (sparita %s); Seme selvatico: superficie %s, vigore %d, geni %s" % [plants,
		"qualcosa è caduto" if dropped else "NULLA (NO)", "sì" if not world.stations.has(o) else "NO",
		Genome.surface_of(Genome.genes(wild)), Genome.vigor(wild), Genome.genes(wild)])
	if plants < 12:
		print("ATTENZIONE: poche piante-seme nel mondo di prova")
	# le Fiale negli scrigni delle rovine
	var vials := 0
	for c in world.chests:
		for i in (world.chests[c] as Bisaccia).slots.size():
			if GenesData.gene_of_vial((world.chests[c] as Bisaccia).id_at(i)) != "":
				vials += 1
	print("Fiale negli scrigni del mondo: %d; Genario %d%% (%d geni imparati)" % [vials, roundi(Genario.percent()), Genario.learned()])
	# il Genario nel Semenzaio
	var sp: SemenzaioPanel = null
	for c in m.hud.overlays:
		if c is SemenzaioPanel:
			sp = c
	sp.tab = "genario"
	sp.selected = "sporangio"
	sp.toggle()
	await kit.frames(6)
	await kit.save("85_genario")
	sp.toggle()
	sp.tab = "mondi"
	sp.selected = ""
	wt.genes = old
	wt.apply()
	await kit.seconds(1.0)


## Voce 47: le probabilità dell'innesto sommano a 1 in ogni categoria, una Fiala fissa il suo gene, i figli nascono
## con le frequenze promesse (2000 innesti), il vigore è quello del genitore più forte; l'innesto al banco consuma
## genitori, Fiala e Linfa antica e dà il figlio (foto 86_innesto).
func grafting() -> void:
	var a := {"geni": ["sporangio", "cavo", "gemme_ricche", "stellato"], "vigore": 3}
	var b := {"geni": ["brina", "alveare", "fertile", "stellato"], "vigore": 5}
	var od := Genome.odds(a, b, ["fungaie"])
	var sums_ok := true
	for cat in od:
		var tot := 0.0
		for e in od[cat]:
			tot += float(e[1])
		sums_ok = sums_ok and absf(tot - 1.0) < 0.001
	var rng := RandomNumberGenerator.new()
	rng.seed = 4747
	var n := 2000
	var seen := {}
	var fixed_ok := true
	var vig_ok := true
	var mutated := 0
	for k in n:
		var ch := Genome.cross(a, b, ["fungaie"], rng)
		fixed_ok = fixed_ok and "fungaie" in Genome.genes(ch)
		vig_ok = vig_ok and Genome.vigor(ch) == 5
		if ch.has("mutato"):
			mutated += 1
			continue
		for g in Genome.genes(ch):
			seen[g] = int(seen.get(g, 0)) + 1
	var clean := n - mutated
	var want_sp := float(od["superficie"][0][1])
	var got_sp := float(seen.get("sporangio", 0)) / clean
	var want_cavo := float(od["grotte"][0][1])
	var got_cavo := float(seen.get("cavo", 0)) / clean
	var freq_ok := absf(got_sp - want_sp) < 0.04 and absf(got_cavo - want_cavo) < 0.04 and int(seen.get("stellato", 0)) == clean
	print("innesto: probabilità che sommano a 1 %s; Fiala che fissa il gene %s; vigore del più forte %s; Sporangio %.2f (atteso %.2f), Cavo %.2f (atteso %.2f), Stellato sempre %s; mutati %d su %d (%.1f%%, atteso %.0f%%)" % [
		"sì" if sums_ok else "NO", "sì" if fixed_ok else "NO", "sì" if vig_ok else "NO", got_sp, want_sp, got_cavo, want_cavo,
		"sì" if int(seen.get("stellato", 0)) == clean else "NO", mutated, n, 100.0 * mutated / n, Genome.MUTATION * 100.0])
	if not (sums_ok and fixed_ok and vig_ok and freq_ok):
		print("ATTENZIONE: l'innesto non rispetta le sue regole")
	# al banco
	var bag: Bisaccia = m.character.bisaccia
	kit.make_room()
	bag.add_stack({"id": "seme_mondo_sporangio", "n": 1, "dati": a.duplicate(true)})
	bag.add_stack({"id": "seme_mondo_brina", "n": 1, "dati": b.duplicate(true)})
	bag.add(GenesData.vial_of("fungaie"), 1)
	bag.add("linfa_antica", 2)
	var ip: InnestoPanel = m.innesto
	ip.open()
	for i in bag.slots.size():
		if String(ItemsData.get_item(bag.id_at(i)).get("kind", "")) == "seme_mondo" and Genome.genes(bag.data_at(i)) in [a["geni"], b["geni"]]:
			ip._toggle_parent(i)
	ip._toggle_vial(GenesData.vial_of("fungaie"))
	await kit.frames(4)
	await kit.save("86_innesto")
	var seeds0 := 0
	for i in bag.slots.size():
		if String(ItemsData.get_item(bag.id_at(i)).get("kind", "")) == "seme_mondo":
			seeds0 += 1
	var ok: bool = ip.graft()
	var seeds1 := 0
	for i in bag.slots.size():
		if String(ItemsData.get_item(bag.id_at(i)).get("kind", "")) == "seme_mondo":
			seeds1 += 1
	print("al banco: innesto %s, Semi %d → %d, Linfa antica rimasta %d, Fiala usata %s, figlio %s" % ["sì" if ok else "NO", seeds0, seeds1,
		bag.count("linfa_antica"), "sì" if bag.count(GenesData.vial_of("fungaie")) == 0 else "NO", Genome.genes(ip.last_child)])
	await kit.frames(4)
	await kit.save("87_innesto_nato")
	ip.visible = false


## Voce 48: i geni rari cambiano il mondo (Mosaico, Isole sospese, Cuore cavo, Città sepolta in mondi piccoli; foto
## 88_isole_sospese), l'Aurora schiarisce la notte, le combinazioni segrete rendono la mutazione più probabile e danno il
## loro gene, la Provetta vicino alla firma preleva il gene della firma; nessun Seme trovato porta un gene «solo per
## mutazione».
func rare_genes() -> void:
	var res := {}
	var keep: World = null
	var sets := [["mosaico"], ["lanterna", "isole_sospese"], ["sporangio", "cuore_cavo"], ["resina", "citta_sepolta"]]
	var made: Array[World] = await kit.gen_many(sets.map(func(g: Array) -> Array: return [4848, W, WorldGen.HEIGHT, {"vigore": 6, "geni": g}]))
	for i in sets.size():
		var gs: Array = sets[i]
		var w := made[i]
		match String(gs[-1]):
			"mosaico":
				var changes := 0
				for x in range(1, w.w):
					if w.biomes[x] != w.biomes[x - 1]:
						changes += 1
				var kinds := {}
				for x in w.w:
					kinds[int(w.biomes[x])] = true
				res["mosaico"] = "%d cambi di bioma, %d biomi" % [changes, kinds.size()]
				res["_ok_mosaico"] = changes >= 8 and kinds.size() >= 4
			"isole_sospese":
				res["isole"] = (w.gen_notes.get("isole", []) as Array).size()
				res["_ok_isole"] = int(res["isole"]) >= 4
				keep = w
			"cuore_cavo":
				res["cuore cavo"] = int(w.gen_notes.get("sottosuolo", {}).get("cuore_cavo", 0))
				res["_ok_cavo"] = int(res["cuore cavo"]) == 1
			"citta_sepolta":
				var city: Vector2i = w.gen_notes.get("citta", Vector2i(-1, -1))
				var chests := 0
				if city.x >= 0:
					for o in w.chests:
						if o.x >= city.x - 2 and o.x < city.x + 64 and o.y >= city.y - 12 and o.y < city.y + 34:
							chests += 1
				res["città: scrigni"] = chests
				res["_ok_citta"] = chests >= 10
	var ok := true
	for k in res:
		if String(k).begins_with("_ok"):
			ok = ok and bool(res[k])
	print("geni rari nel generatore: %s — %s" % [res.keys().filter(func(k: String) -> bool: return not k.begins_with("_")).map(
		func(k: String) -> String: return "%s %s" % [k, res[k]]), "sì" if ok else "NO"])
	if not ok:
		print("ATTENZIONE: un gene raro non cambia il mondo come dovrebbe")
	if keep != null:
		var isl: Array = keep.gen_notes["isole"]
		var p: Vector2i = isl[0]
		keep.gen_notes["firma"] = {"x": p.x, "y": p.y + 4}
		await _photo_at(keep, "88_isole_sospese", Vector2i(-520, 0), Vector2i(0, -2))
	# l'Aurora: di notte la luce del cielo non scende sotto il suo valore
	var wt: WorldTraits = m.world_traits
	var old: Array = wt.genes
	m.day.time = 0.02
	m.day.apply(true)
	var dark: Color = m.light.sky
	wt.genes = ["lanterna", "aurora"]
	wt.apply()
	m.day.apply(true)
	var lit: Color = m.light.sky
	print("Aurora: cielo di notte %.2f → %.2f; è ancora notte per le creature %s" % [dark.v, lit.v, "sì" if m.day.is_night() else "NO"])
	wt.genes = old
	wt.apply()
	m.day.time = 0.5
	m.day.apply(true)
	# le combinazioni segrete
	var a := {"geni": ["sporangio", "vene_ricche"], "vigore": 4}
	var b := {"geni": ["resina", "stellato"], "vigore": 4}
	var mc := Genome.mutation_chance(a, b)
	var rng := RandomNumberGenerator.new()
	rng.seed = 48
	var hits := 0
	for k in 1000:
		if "vene_stellari" in Genome.genes(Genome.cross(a, b, [], rng)):
			hits += 1
	var plain := Genome.mutation_chance({"geni": ["sporangio", "cavo"]}, {"geni": ["resina", "fertile"]})
	print("combinazione Vene ricche + Stellato: mutazione %d%% verso «%s», nata %d volte su 1000; senza combinazione %d%%" % [
		roundi(float(mc[0]) * 100), mc[1], hits, roundi(float(plain[0]) * 100)])
	# nessun Seme trovato porta geni solo per mutazione o della firma
	var found_only := 0
	for k in 400:
		for g in Genome.genes(Genome.roll(rng, 1 + k % 12)):
			if GenesData.GENES[g].has("only"):
				found_only += 1
	# la Provetta vicino alla firma: il gene della firma
	var sig: Signature = m.signature
	var fid := String(sig.info().get("id", ""))
	var fg := String(SignaturesData.SIGNATURES.get(fid, {}).get("gene", ""))
	var cat: String = m.sampling.category_at(sig.center())
	print("geni «solo mutazione o firma» nei Semi trovati: %d su 400 Semi; vicino alla firma «%s» la Provetta preleva «%s» (gene della firma: %s)" % [
		found_only, fid, cat, fg])
