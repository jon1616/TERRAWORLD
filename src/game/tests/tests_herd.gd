class_name TestsHerd
extends RefCounted
## Prove della mandria (voce 59, Roadmap 7): una pecora docile addomesticata con il cibo (il cibo sbagliato non va,
## una volpe sazia non si fida), una volpe presa con il Laccio, la mandria che segue il Germogliato e combatte, in
## sella a un cornoradice (foto 95_mandria), il recinto che nutre e produce anche «mentre sei via» (foto 96_recinto),
## l'Incubatrice che schiude un uovo in un vasetto, il vasetto, la creatura stremata, il salvataggio delle schede.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var spot := kit.flat_spot(world.spawn + Vector2i(60, 0), 8)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto per le prove della mandria")
		return
	kit.flatten(spot, 16)
	m.fauna.clear()
	m.snap_to(spot)
	kit.make_room()
	await kit.frames(3)
	var h: Herd = m.herd
	var old: Array = m.character.mandria.duplicate()
	m.character.mandria.clear()
	await taming(spot, h)
	await follow_and_fight(spot, h)
	await riding(spot, h)
	await pens(spot, h)
	await jars_and_saves(h)
	await breeding(spot, h)
	await bestiary()
	# si rimette la mandria com'era
	h.ride(false)
	for uid in h.beasts.keys():
		h.despawn(int(uid))
	m.character.mandria.clear()
	m.character.mandria.append_array(old)
	m.fauna.clear()


func _feet(c: Vector2i, id: String) -> Vector2:
	return Vector2(c.x * S + 8, (c.y + 1) * S - float(CreaturesData.get_data(id)["half"][1]) - 0.1)


func taming(spot: Vector2i, h: Herd) -> void:
	var tm: Taming = m.taming
	var b := kit.bisaccia()
	b.add("tubero_linfa", 20)
	b.add("boccone", 5)
	# il cibo sbagliato e una volpe sazia
	var sheep: Creature = m.fauna.add("pecora_muschio~~~docile", _feet(spot + Vector2i(2, 0), "pecora_muschio"))
	var wrong := tm.feed(sheep, "boccone")
	var fox: Creature = m.fauna.add("volpe_ambra", _feet(spot + Vector2i(-3, 0), "volpe_ambra"))
	fox.set_process(false)
	fox.hunger = 0.0
	var sated := Taming.refuses(fox)
	fox.hunger = 0.9
	var hungry := Taming.refuses(fox)
	# la pecora: pasti fino all'addomesticamento
	var meals := 0
	var n0 := h.records().size()
	while is_instance_valid(sheep) and m.fauna.list.has(sheep) and meals < 10:
		tm.feed(sheep, "tubero_linfa")
		meals += 1
		await kit.frames(1)
	print("addomesticare col cibo: il cibo sbagliato %s; volpe sazia «%s», affamata %s; pecora docile tua dopo %d pasti (%d → %d schede, dieta nell'Erbario %s)" % [
		"rifiutato" if not wrong else "ACCETTATO", sated, "accetta" if hungry == "" else "NO", meals, n0, h.records().size(),
		"sì" if m.character.erbario.get("diete", {}).has("pecore") else "NO"])
	# la volpe con il Laccio: prima troppo in forze, poi stremata
	b.add("laccio", 12)
	var too_strong := tm.lasso("laccio", fox.position)
	fox.hp = maxi(1, fox.hp_max / 10)
	var tries := 0
	while is_instance_valid(fox) and m.fauna.list.has(fox) and tries < 12:
		tm.lasso("laccio", fox.position)
		fox.stun = 0.0
		tries += 1
		await kit.frames(1)
	print("laccio: in forze %s; stremata presa al %d° lancio (riuscita %.0f%% a un decimo di Vita)" % ["no" if not too_strong else "SÌ (sbagliato)",
		tries, 100.0 * HerdData.capture_chance("volpi", 0.1) * 0.95])
	if wrong or sated == "" or hungry != "" or h.records().size() < n0 + 2:
		print("ATTENZIONE: addomesticare non funziona come dovrebbe")
	m.fauna.clear()


func follow_and_fight(spot: Vector2i, h: Herd) -> void:
	await kit.seconds(0.5)
	m.snap_to(kit.floor_near(spot + Vector2i(9, 0), 6))
	await kit.seconds(3.0)
	var far := 0.0
	for uid in h.beasts:
		far = maxf(far, (h.beasts[uid] as Creature).position.distance_to(m.player.position) / S)
	print("la mandria segue: %d creature in scena, la più lontana a %.1f tessere dal Germogliato" % [h.beasts.size(), far])
	# un grumo ostile: la volpe lo attacca
	var fox_rec := {}
	for r in h.records():
		if Herd.family_of(r) == "volpi":
			fox_rec = r
	m.bonds.summon(fox_rec)                    # Roadmap 32: in campo ce n'è una sola
	await kit.seconds(0.6)
	var xp0 := int(fox_rec.get("xp", 0)) + int(fox_rec.get("lvl", 1)) * 1000
	var foe: Creature = m.fauna.add("grumo_muschio", m.player.position + Vector2(40, -8))
	var hp0: int = m.vitals.hp
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 10000 and is_instance_valid(foe) and m.fauna.list.has(foe):
		m.vitals.hp = hp0                      # il Germogliato non deve appassire mentre guarda
		await kit.frames(1)
	var won: bool = not (is_instance_valid(foe) and m.fauna.list.has(foe))
	var xp1 := int(fox_rec.get("xp", 0)) + int(fox_rec.get("lvl", 1)) * 1000
	print("la volpe della mandria abbatte un grumo: %s (in %.1f s), esperienza %s" % ["sì" if won else "NO",
		(Time.get_ticks_msec() - t0) / 1000.0, "guadagnata" if xp1 > xp0 else "NO"])
	if far > 6.0 or not won:
		print("ATTENZIONE: la mandria non segue o non combatte")
	m.fauna.clear()


func riding(spot: Vector2i, h: Herd) -> void:
	# la pecora va a riposare, arriva un cornoradice
	for r in h.records():
		if Herd.family_of(r) == "pecore":
			h.set_state(r, "riposo")
	var horn := h.new_record("cornoradice", "nutrita")
	h.add_record(horn)
	m.bonds.summon(horn)                       # Roadmap 32: si cavalca quella in campo
	await kit.frames(3)
	var run0: float = m.player.run_mult
	var ok := h.ride(true)
	await kit.frames(2)
	var run1: float = m.player.run_mult
	m.boons.add("bagliore", 6.0)
	await kit.seconds(0.6)
	await kit.save("95_mandria")
	h.ride(false)
	await kit.frames(2)
	print("in sella al cornoradice: %s, corsa ×%.2f → ×%.2f → ×%.2f scesi; doni di chi segue: %s" % ["sì" if ok else "NO", run0, run1,
		m.player.run_mult, h.bonuses()])
	if not ok or run1 < run0 * 1.4 or absf(m.player.run_mult - run0) > 0.01:
		print("ATTENZIONE: cavalcare non funziona come dovrebbe")


func pens(spot: Vector2i, h: Herd) -> void:
	var ps: Pens = m.pens
	var c := spot + Vector2i(-8, 0)
	kit.flatten(c, 14)
	var o := c - Vector2i(1, 1)
	world.stations[o] = "recinto"
	m.view.add_station(o)
	var inc := c + Vector2i(-6, -1)
	world.stations[inc] = "incubatrice"
	m.view.add_station(inc)
	ps._scan()
	var sheep := {}
	for r in h.records():
		if Herd.family_of(r) == "pecore":
			sheep = r
	var why := h.set_state(sheep, "recinto")
	var chest: Bisaccia = world.chest_at(o)
	chest.add("tubero_linfa", 5)
	sheep["fame"] = 0.9
	ps.tick(sheep, 1.0)
	var ate: bool = chest.count("tubero_linfa") == 4
	sheep["prod"] = 10000.0
	ps.tick(sheep, 1.0)
	var wool := chest.count("lana_muschio")
	# due ore di assenza, con la mangiatoia piena
	chest.add("tubero_linfa", 20)
	sheep["t"] = Time.get_unix_time_from_system() - 3600.0
	sheep["prod"] = 0.0
	ps.catch_up()
	var wool2 := chest.count("lana_muschio")
	m.snap_to(kit.floor_near(c + Vector2i(3, 0), 6))
	m.boons.add("bagliore", 6.0)
	await kit.seconds(1.2)
	await kit.save("96_recinto")
	var shown := h.beasts.has(int(sheep["uid"])) and (h.beasts[int(sheep["uid"])] as Creature).tame.mode == "recinto"
	print("recinto: %s; la pecora ci vive %s, mangia dalla mangiatoia %s, produce %d lana; dopo un'ora «via» %d lana (tubero rimasto %d, livello %d)" % [
		why if why != "" else "posto trovato", "sì" if shown else "NO", "sì" if ate else "NO", wool, wool2 - wool,
		chest.count("tubero_linfa"), int(sheep["lvl"])], " xp ", int(sheep["xp"]))
	# l'Incubatrice: un uovo posato «tre minuti fa»
	var ichest: Bisaccia = world.chest_at(inc)
	ichest.slots[0] = {"id": "uovo", "n": 1, "dati": {"fam": "lepri", "specie": "lepre_linfa~grande~~",
		"cova": Time.get_unix_time_from_system() - HerdData.HATCH - 10.0}}
	ps.incubate(inc)
	var hatched := ichest.id_at(0) == "creatura"
	print("Incubatrice: l'uovo si schiude %s → %s" % ["sì" if hatched else "NO", Gear.full_name(ichest.slots[0])])
	if why != "" or not ate or wool <= 0 or wool2 - wool < 3 or not hatched or not shown:
		print("ATTENZIONE: recinto o Incubatrice non funzionano come dovrebbero")
	# il vasetto schiuso va in mano e si apre
	kit.bisaccia().add_stack(ichest.slots[0])
	ichest.slots[0] = {}
	kit.hold("creatura")
	var n0 := h.records().size()
	var out: bool = m.taming.release()
	print("il vasetto dell'uovo si apre: %s (%d → %d schede)" % ["sì" if out else "NO", n0, h.records().size()])
	world.stations.erase(o)
	world.stations.erase(inc)
	m.view.remove_station(o)
	m.view.remove_station(inc)
	world.chests.erase(o)
	world.chests.erase(inc)
	ps._scan()
	print("recinto tolto: la pecora %s" % HerdInfo.STATES.get(String(sheep["stato"]), sheep["stato"]))


func jars_and_saves(h: Herd) -> void:
	var b := kit.bisaccia()
	b.add("vasetto", 2)
	var rec: Dictionary = h.followers()[0]
	var n0 := h.records().size()
	var c0 := b.count("creatura")
	var ok: bool = m.taming.jar_record(rec)
	print("vasetto: %s dentro (%d → %d schede, vasetti pieni %d → %d)" % [rec["nome"] if ok else "NESSUNA", n0, h.records().size(), c0, b.count("creatura")])
	# stremata
	var f: Dictionary = h.followers()[0]
	h.faint(f)
	var st := String(f["stato"])
	var back: String = m.bonds.summon(f)          # Roadmap 32: KO resta nella sacca e non si evoca
	# salvataggio
	var d: Dictionary = m.character.to_dict()
	var copy := Character.from_dict("prova", JSON.parse_string(JSON.stringify(d)))
	var same: bool = copy.mandria.size() == h.records().size() and copy.mandria[0]["uid"] is int
	print("stremata: %s, richiamarla subito: «%s»; salvate e riprese %d schede %s; la scheda: %s" % [HerdInfo.STATES.get(st, st), back,
		copy.mandria.size(), "identiche" if same else "DIVERSE", HerdInfo.short(h.records()[0])])
	if not ok or st != "segue" or not bool(f.get("ko", false)) or back == "" or not same:
		print("ATTENZIONE: vasetti o salvataggio della mandria non funzionano")


## Voce 60: una coppia nel recinto fa un uovo con le doti del figlio; che cosa può nascere (anteprima); i manti rari
## più frequenti nelle stirpi lunghe; allevare scegliendo i migliori fa crescere la resa; foto 97_manti con tutti i
## manti su una pecora.
func breeding(spot: Vector2i, h: Herd) -> void:
	var ps: Pens = m.pens
	var c := spot + Vector2i(-8, 0)
	kit.flatten(c, 14)
	var o := c - Vector2i(1, 1)
	world.stations[o] = "recinto"
	m.view.add_station(o)
	ps._scan()
	var a := h.new_record("pecora_muschio", "nutrita")
	var b := h.new_record("pecora_muschio~grande~~", "nutrita")
	a["lvl"] = 1
	b["lvl"] = 4
	h.add_record(a)
	h.add_record(b)
	var too_young := h.pair(a, b)
	a["lvl"] = 4
	var paired := h.pair(a, b)
	h.set_state(a, "recinto")
	h.set_state(b, "recinto")
	for r in [a, b]:
		r["fame"] = 0.0
		r["felice"] = 1.0
	a["amore"] = BreedData.BREED_TIME - 1.0
	ps.breed(Pens.key(o), 2.0)
	var chest: Bisaccia = world.chest_at(o)
	var egg := {}
	for i in chest.slots.size():
		if chest.id_at(i) == "uovo":
			egg = chest.slots[i]
	print("coppia: troppo giovane «%s», poi %s; uovo nella mangiatoia %s: %s, doti %s" % [too_young, "fatta" if paired == "" else paired,
		"sì" if not egg.is_empty() else "NO", Gear.full_name(egg) if not egg.is_empty() else "-", egg.get("dati", {}).get("doti", {})])
	print(Breeding.preview(a, b).replace("[color=#ffd08a]", "").replace("[color=#9fc8c0]", "").replace("[color=#cfeee4]", "")
		.replace("[color=#ffd24a]", "").replace("[color=#6a8a84]", "").replace("[/color]", "").strip_edges().replace("\n", " | "))
	# i manti rari: coppie comuni di generazione 0 e di generazione 6
	var rng := RandomNumberGenerator.new()
	rng.seed = 60
	var rare := [0, 0]
	for k in 2:
		var ga := {"gen": 6 * k, "manto": "", "vita": 1.0, "danno": 1.0, "resa": 1.0}
		var pa := {"uid": 1, "specie": "pecora_muschio", "doti": ga}
		var pb := {"uid": 2, "specie": "pecora_muschio", "doti": ga.duplicate()}
		for i in 2000:
			if BreedData.is_rare(String(Breeding.child(pa, pb, rng)["doti"]["manto"])):
				rare[k] += 1
	# allevare per la resa: dieci generazioni, ogni volta i due figli migliori di dieci
	var p1 := {"uid": 1, "specie": "pecora_muschio", "doti": {"gen": 0, "manto": "", "vita": 1.0, "danno": 1.0, "resa": 1.0}}
	var p2 := {"uid": 2, "specie": "pecora_muschio", "doti": {"gen": 0, "manto": "", "vita": 1.0, "danno": 1.0, "resa": 1.0}}
	for g in 10:
		var kids := []
		for i in 10:
			kids.append(Breeding.child(p1, p2, rng))
		kids.sort_custom(func(x: Dictionary, y: Dictionary) -> bool: return float(x["doti"]["resa"]) > float(y["doti"]["resa"]))
		p1 = {"uid": 1, "specie": kids[0]["specie"], "doti": kids[0]["doti"]}
		p2 = {"uid": 2, "specie": kids[1]["specie"], "doti": kids[1]["doti"]}
	print("manti rari: %.1f%% dei figli alla prima generazione, %.1f%% alla settima; resa dopo dieci generazioni scelte ×%.2f" % [
		rare[0] / 20.0, rare[1] / 20.0, float(p1["doti"]["resa"])])
	# foto: una pecora per manto, e una gigante
	h.set_state(a, "riposo")
	h.set_state(b, "riposo")
	m.snap_to(kit.floor_near(c + Vector2i(2, 0), 6))
	var shown: Array[Creature] = []
	var coats: Array = BreedData.COATS.keys()
	for k in coats.size() + 1:
		var more := {"manto": coats[k]} if k < coats.size() else {"gigante": true}
		var cr := Creature.new()
		cr.setup("pecora_muschio", world, m.player, 7, more)
		cr.position = Vector2((c.x - 9 + k * 2) * S + 8, (c.y + 1) * S - cr.half.y - 0.1)
		m.fx.add_child(cr)
		cr.set_process(false)
		shown.append(cr)
	m.boons.add("bagliore", 6.0)
	await kit.seconds(0.6)
	await kit.save("97_manti")
	for cr in shown:
		cr.queue_free()
	world.stations.erase(o)
	m.view.remove_station(o)
	world.chests.erase(o)
	ps._scan()
	if too_young == "" or paired != "" or egg.is_empty() or rare[1] <= rare[0] or float(p1["doti"]["resa"]) < 1.3:
		print("ATTENZIONE: l'allevamento non funziona come dovrebbe")


## Voce 61: l'Erbario vivo — la scheda Famiglie con quello che si è scoperto giocando (foto 98_erbario_famiglie).
func bestiary() -> void:
	var ep: ErbarioPanel = null
	for o in m.hud.overlays:
		if o is ErbarioPanel:
			ep = o
	var fams := 0
	for f in FamiliesData.FAMILIES:
		if m.erbario.known("famiglie", f):
			fams += 1
	var txt := BestiaryInfo.family(m.character, "pecore")
	var plain := RegEx.create_from_string("\\[[^\\]]*\\]").sub(txt, "", true).strip_edges().replace("\n", " | ")
	print("Erbario vivo: famiglie conosciute %d su %d (%.0f%%); pecore: %s" % [fams, FamiliesData.FAMILIES.size(),
		m.erbario.percent("famiglie"), plain])
	var lynx := RegEx.create_from_string("\\[[^\\]]*\\]").sub(BestiaryInfo.family(m.character, "linci"), "", true)
	print("  linci (mai addomesticate): %s" % lynx.strip_edges().replace("\n", " | "))
	if ep != null:
		ep.section = "famiglie"
		ep.selected = "pecore"
		ep.toggle()
		await kit.frames(4)
		await kit.save("98_erbario_famiglie")
		ep.toggle()
	if fams == 0 or not txt.contains("Mangia:") or not txt.contains("Nel recinto"):
		print("ATTENZIONE: l'Erbario non racconta le famiglie come dovrebbe")
