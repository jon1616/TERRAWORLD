class_name TestsBonds
extends RefCounted
## Prove dei compagni di battaglia (Roadmap 32, gruppo `legami`): ogni specie combatte con il suo stile (chi spara
## spara colpi amici, chi carica carica, chi scava sbuca, chi nuota vola in una bolla), le creature selvatiche
## prendono di mira il compagno e lo feriscono, il compagno non resta mai indietro. Rimettono la mandria com'era.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var spot := kit.flat_spot(world.spawn + Vector2i(80, 0), 10)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto per le prove dei compagni")
		return
	kit.flatten(spot, 22)
	m.fauna.clear()
	m.snap_to(spot)
	kit.make_room()
	await kit.frames(3)
	var h: Herd = m.herd
	var old: Array = m.character.mandria.duplicate(true)
	m.character.mandria.clear()
	await styles(spot, h)
	await aggro(spot, h)
	await follow(spot, h)
	await sack(spot, h)
	await binding(spot, h)
	await growth(spot, h)
	await gifts(spot, h)
	for uid in h.beasts.keys():
		h.despawn(int(uid))
	m.character.mandria.clear()
	m.character.mandria.append_array(old)
	m.fauna.clear()
	m.snap_to(spot)


## Una scheda che segue, di livello `lvl`, sola in campo.
func _companion(h: Herd, sp: String, lvl: int) -> Dictionary:
	for uid in h.beasts.keys():
		h.despawn(int(uid))
	m.character.mandria.clear()
	var rec := h.new_record(sp, "allevata")
	rec["lvl"] = lvl
	h.add_record(rec)
	rec["stato"] = "segue"
	rec["campo"] = true
	return rec


## Voce 310: cinque specie, cinque stili, ognuna contro un nemico vero.
func styles(spot: Vector2i, h: Herd) -> void:
	var out := []
	var bad := []
	for sp in ["volpe_ambra", "sputaspore", "talpone", "anguilla_linfa", "grumo_muschio"]:
		m.fauna.clear()
		m.snap_to(spot)
		var rec := _companion(h, sp, 12)
		await kit.seconds(0.6)
		var c: Creature = h.beasts.get(int(rec["uid"]))
		if c == null:
			bad.append(sp + ": non in scena")
			continue
		var shots0 := _ally_shots()
		var fired := false
		var foe: Creature = m.fauna.add("lupo_lunare", m.player.position + Vector2(5 * S, -8))
		foe.hp_max = 90
		foe.hp = 90
		var hp0: int = m.vitals.hp
		var t0 := Time.get_ticks_msec()
		var hurt := false
		while Time.get_ticks_msec() - t0 < 12000 and is_instance_valid(foe) and m.fauna.list.has(foe):
			m.vitals.hp = hp0                      # il Germogliato guarda e basta
			m.combat.invuln = 1.0
			if foe.hp < foe.hp_max:
				hurt = true
			if _ally_shots() > shots0:
				fired = true
			await kit.frames(1)
		var won: bool = not (is_instance_valid(foe) and m.fauna.list.has(foe))
		var secs := (Time.get_ticks_msec() - t0) / 1000.0
		out.append("%s %s (%s%s, %.1f s)" % [sp, BondsData.style_of(sp), "vince" if won else ("ferisce" if hurt else "NIENTE"),
			", spara" if fired else "", secs])
		if not won and not hurt:
			bad.append(sp)
		if sp == "sputaspore" and not fired:
			bad.append("lo sputaspore non spara")
		if sp == "anguilla_linfa" and not c.fly:
			bad.append("l'anguilla non vola fuori dall'acqua")
	m.combat.invuln = 0.0
	print("stili dei compagni: %s" % ", ".join(out))
	if not bad.is_empty():
		print("ATTENZIONE: compagni che non combattono con il loro stile: %s" % [bad])


func _ally_shots() -> int:
	var n := 0
	for s in m.shots._shots:
		if int(s.get("ally", -1)) >= 0:
			n += 1
	return n + int(m.shots.get_meta("ally_fired", 0))


## Voce 310: una creatura colpita dal compagno lo insegue, e il suo contatto lo ferisce.
func aggro(spot: Vector2i, h: Herd) -> void:
	m.fauna.clear()
	m.snap_to(spot)
	var rec := _companion(h, "volpe_ambra", 3)
	await kit.seconds(0.6)
	var c: Creature = h.beasts.get(int(rec["uid"]))
	var foe: Creature = m.fauna.add("lupo_lunare", c.position + Vector2(4 * S, -8))
	foe.hp_max = 400
	foe.hp = 400
	var targeted := false
	var t0 := Time.get_ticks_msec()
	var hp0: int = m.vitals.hp
	while Time.get_ticks_msec() - t0 < 4000 and is_instance_valid(c) and String(rec["stato"]) == "segue":
		m.vitals.hp = hp0
		m.combat.invuln = 1.0
		if is_instance_valid(foe) and foe.target == c:
			targeted = true
		await kit.frames(1)
	var hurt := float(rec["vita"]) < 0.99 or String(rec["stato"]) != "segue"
	m.combat.invuln = 0.0
	print("il nemico prende di mira il compagno: %s; il compagno è ferito: %s (Vita %.0f%%, %s)" % [
		"sì" if targeted else "NO", "sì" if hurt else "NO", float(rec["vita"]) * 100.0, rec["stato"]])
	if not targeted or not hurt:
		print("ATTENZIONE: le creature selvatiche ignorano il compagno")
	m.fauna.clear()


## Voce 310: il compagno non resta indietro (un salto lontano del Germogliato, un muro che lo chiude).
func follow(spot: Vector2i, h: Herd) -> void:
	m.fauna.clear()
	m.snap_to(spot)
	var rec := _companion(h, "pecora_muschio", 5)
	await kit.seconds(0.8)
	var c: Creature = h.beasts.get(int(rec["uid"]))
	m.snap_to(kit.floor_near(spot + Vector2i(40, 0), 8))
	await kit.seconds(1.0)
	var far1: float = c.position.distance_to(m.player.position) / S
	# chiuso dietro un muro alto: dopo un po' ricompare accanto
	m.snap_to(spot)
	await kit.seconds(0.8)
	var cx := floori(c.position.x / S)
	var cy := floori(c.position.y / S)
	var px := floori(m.player.position.x / S)
	var wall_x := cx + (1 if px > cx else -1)
	var placed := []
	for y in range(cy - 12, cy + 2):
		if not world.solid(wall_x, y):
			world.set_tile(wall_x, y, TileDefs.STONE)
			placed.append(Vector2i(wall_x, y))
	m.snap_to(kit.floor_near(Vector2i(px + (8 if px > cx else -8), cy), 6))
	await kit.seconds(2.6)
	var far2: float = c.position.distance_to(m.player.position) / S
	for p in placed:
		world.set_tile(p.x, p.y, TileDefs.AIR)
	m.view.refresh_rect(Rect2i(wall_x - 1, cy - 13, 3, 16))
	print("il compagno non resta indietro: dopo un salto di 40 tessere a %.1f tessere, chiuso dietro un muro a %.1f" % [far1, far2])
	if far1 > 4.0 or far2 > 6.0:
		print("ATTENZIONE: il compagno resta indietro")


## Voce 311: la Sacca dei legami. Cinque posti (la sesta va a riposare), una sola in campo, richiamare e cambiare;
## KO torna nella sacca e non si evoca, la prossima pronta prende il suo posto; nel Giardino guariscono tutte.
func sack(spot: Vector2i, h: Herd) -> void:
	m.fauna.clear()
	m.snap_to(spot)
	for uid in h.beasts.keys():
		h.despawn(int(uid))
	m.character.mandria.clear()
	var bb: BondBag = m.bonds
	var recs := []
	for sp in ["volpe_ambra", "lupo_lunare", "falena_brace", "talpone", "pecora_muschio", "grumo_muschio"]:
		var r := h.new_record(sp, "allevata")
		r["lvl"] = 6
		h.add_record(r)
		recs.append(r)
	await kit.seconds(0.6)
	var in_bag: int = bb.bag().size()
	var sixth := String(recs[5]["stato"])
	var first_field: bool = bb.field() == recs[0]
	var in_scene: int = h.beasts.size()
	bb.recall()
	await kit.seconds(0.3)
	var after_recall: int = h.beasts.size()
	var nx := bb.next_ready()
	bb.summon(nx)
	await kit.seconds(0.4)
	var switched: bool = bb.field() == nx and h.beasts.size() == 1
	await kit.save("320_sacca_legami")
	# KO: un colpo enorme
	var cur := bb.field()
	var c: Creature = h.beasts.get(int(cur["uid"]))
	h.fight.hurt(c, cur, 99999, c.position.x - 10.0)
	await kit.seconds(0.3)
	var ko: bool = bool(cur.get("ko", false)) and not bool(cur.get("campo", false)) and String(cur["stato"]) == "segue"
	var refused: String = bb.summon(cur)
	var other := bb.next_ready()
	bb.summon(other)
	await kit.seconds(0.4)
	var replaced: bool = not bb.field().is_empty() and bb.field() != cur and h.beasts.size() == 1
	# nel Giardino guariscono
	var was: bool = m.giardino.active
	m.giardino.active = true
	await kit.seconds(1.3)
	var healed: bool = not bool(cur.get("ko", false)) and float(cur["vita"]) >= 1.0
	m.giardino.active = was
	print("Sacca dei legami: %d nella sacca (la sesta: %s), in campo la prima %s, in scena %d; richiamata: in scena %d; cambio %s; KO %s («%s»), sostituita %s; nel Giardino guarisce %s" % [
		in_bag, sixth, "sì" if first_field else "NO", in_scene, after_recall, "sì" if switched else "NO", "sì" if ko else "NO",
		refused, "sì" if replaced else "NO", "sì" if healed else "NO"])
	if in_bag != 5 or sixth != "riposo" or not first_field or in_scene != 1 or after_recall != 0 or not switched or not ko 			or refused == "" or not replaced or not healed:
		print("ATTENZIONE: la Sacca dei legami non va")


## Voce 312: si lega ogni creatura non boss. La natura chiede il suo modo: l'avvizzita va prima curata con la Rugiada,
## il costrutto vuole il Sigillo, l'ancestrale il Laccio dei Seminatori; i lacci migliori prendono prima; la rara legata
## resta rara (aura, tratti).
func binding(spot: Vector2i, h: Herd) -> void:
	m.fauna.clear()
	m.snap_to(spot)
	for uid in h.beasts.keys():
		h.despawn(int(uid))
	m.character.mandria.clear()
	var tm: Taming = m.taming
	var all := 0
	var ok_all := 0
	var bosses := 0
	for id in CreaturesData.CREATURES:
		if not BondsData.bindable(String(id)):
			bosses += 1
			continue
		all += 1
		var t := HerdData.tame_of(FamiliesData.family_of(String(id)))
		if not t.is_empty() and t.has("produce") and t.has("diet") and not (BondsData.aid_of(FamiliesData.family_of(String(id)))[0] as Dictionary).is_empty():
			ok_all += 1
		elif ok_all + 12 > all:
			print("  senza dati di legame: %s (famiglia «%s»)" % [id, FamiliesData.family_of(String(id))])
	var b := kit.bisaccia()
	b.add("rugiada_linfa", 2)
	b.add("laccio", 5)
	b.add("sigillo_legame", 3)
	b.add("laccio_seminatori", 3)
	var at: Vector2 = m.player.position + Vector2(3 * S, -8)
	# l'avvizzita: rifiuta il laccio, la Rugiada la cura, poi si lega
	var av: Creature = m.fauna.add("avvizzito_errante", at)
	av.set_process(false)
	av.hp = maxi(1, av.hp_max / 10)
	var av_no := tm.nature_block(av, "laccio")
	var cured := tm.purify("rugiada_linfa", av.position)
	var av_yes := tm.nature_block(av, "laccio")
	# il costrutto: il laccio non lo tiene, il Sigillo sì
	var go: Creature = m.fauna.add("golem_muschio", at + Vector2(40, 0))
	go.set_process(false)
	go.hp = maxi(1, go.hp_max / 10)
	var go_no := tm.nature_block(go, "laccio")
	var go_yes := tm.nature_block(go, "sigillo_legame")
	var go_ch := Taming.lasso_chance(go, "sigillo_legame")
	# l'ancestrale: solo il Laccio dei Seminatori; legata resta rara
	var an: Creature = m.fauna.add("lupo_lunare", at + Vector2(-40, 0))
	an.set_process(false)
	m.fauna.make_ancient(an, "ancestrale")
	an.hp = maxi(1, an.hp_max / 10)
	var an_no := tm.nature_block(an, "laccio")
	var an_yes := tm.nature_block(an, "laccio_seminatori")
	var ch_seta := Taming.lasso_chance(an, "laccio")
	var ch_sem := Taming.lasso_chance(an, "laccio_seminatori")
	var rec := tm.tame(an, "laccio")
	m.bonds.summon(rec)
	await kit.seconds(0.6)
	var c: Creature = h.beasts.get(int(rec["uid"]))
	var rare: bool = c != null and c.ancient != null and c.ancient.rarity == "ancestrale" and not rec.get("antico", {}).is_empty()
	await kit.save("321_compagno_ancestrale")
	# un laccio migliore prende prima (stessa creatura a un terzo della Vita)
	var fx: Creature = m.fauna.add("volpe_ambra", at + Vector2(0, -40))
	fx.set_process(false)
	fx.hp = maxi(1, fx.hp_max / 3)
	var c1 := Taming.lasso_chance(fx, "laccio")
	var c2 := Taming.lasso_chance(fx, "laccio_intrecciato")
	var c3 := Taming.lasso_chance(fx, "laccio_seminatori")
	print("legare ogni creatura: %d specie su %d con cibo, dono e prodotto (%d boss escluse); avvizzita «%s» → curata %s → %s; costrutto «%s», col Sigillo %s (%.0f%%); ancestrale «%s», col Laccio dei Seminatori %s (seta %.0f%%, Seminatori %.0f%%), legata resta rara %s; volpe a un terzo: seta %.0f%%, intrecciato %.0f%%, Seminatori %.0f%%" % [
		ok_all, all, bosses, av_no, "sì" if cured else "NO", "si lega" if av_yes == "" else av_yes, go_no,
		"sì" if go_yes == "" else go_yes, go_ch * 100.0, an_no, "sì" if an_yes == "" else an_yes, ch_seta * 100.0,
		ch_sem * 100.0, "sì" if rare else "NO", c1 * 100.0, c2 * 100.0, c3 * 100.0])
	if ok_all != all or av_no == "" or not cured or av_yes != "" or go_no == "" or go_yes != "" or go_ch <= 0.0 			or an_no == "" or an_yes != "" or not rare or not (c1 < c2 and c2 < c3):
		print("ATTENZIONE: legare ogni creatura non va")
	m.fauna.clear()
	for it in ["rugiada_linfa", "laccio", "sigillo_legame", "laccio_seminatori"]:
		b.remove(it, b.count(it))


## Voce 313: crescere. L'esperienza dipende da quanto era forte la creatura; quella sconfitta dal Germogliato ne dà
## metà; al livello 20 il compagno si vede più grande; Vita e danno seguono il livello e non la specie sola.
func growth(spot: Vector2i, h: Herd) -> void:
	m.fauna.clear()
	m.snap_to(spot)
	var rec := _companion(h, "grumo_muschio", 1)
	await kit.seconds(0.5)
	var weak := BondsData.xp_from(1.0, 10)
	var strong := BondsData.xp_from(20.0, 10)
	# una creatura sconfitta dal Germogliato: metà dell'esperienza al compagno in campo
	var xp0 := int(rec["xp"])
	var foe: Creature = m.fauna.add("lupo_lunare", m.player.position + Vector2(10 * S, -8))
	m.fauna.kill(foe)
	await kit.frames(2)
	var shared := int(rec["xp"]) > xp0
	# fino al 20: si vede più grande
	var st1 := Herd.stats_of(rec)
	var half1: float = (h.beasts[int(rec["uid"])] as Creature).half.y
	while int(rec["lvl"]) < 20:
		h.gain_xp(rec, BondsData.xp_for(int(rec["lvl"])), true)
	await kit.frames(3)
	var c: Creature = h.beasts.get(int(rec["uid"]))
	var st20 := Herd.stats_of(rec)
	var bigger: bool = c != null and c.half.y > half1 + 0.5
	await kit.save("322_compagno_cresciuto")
	# la forma: allo stesso livello un grumo e un lupo hanno forze vicine (la specie conta, ma poco)
	var g := BondsData.stats("grumo_muschio", 30, 1.0, 1.0, 1.0, {}, {})
	var l := BondsData.stats("lupo_lunare", 30, 1.0, 1.0, 1.0, {}, {})
	var pg := float(g["hp"]) / 5.0 + float(g["damage"])
	var pl := float(l["hp"]) / 5.0 + float(l["damage"])
	print("crescita: esperienza da una creatura debole %d, da una forte %d; dal Germogliato %s; livello 1 → 20: Vita %d → %d, danno %d → %d, più grande %s; al 30 grumo %.0f e lupo %.0f di forza" % [
		weak, strong, "sì" if shared else "NO", st1["hp"], st20["hp"], st1["damage"], st20["damage"], "sì" if bigger else "NO", pg, pl])
	if weak >= strong or not shared or int(st20["hp"]) <= int(st1["hp"]) * 2 or not bigger or absf(pg - pl) / pl > 0.35:
		print("ATTENZIONE: la crescita dei compagni non va")


## Voce 314: gli oggetti dei compagni. Frutti (con il tetto), Seme del ricordo, istinti (i posti si aprono con il
## livello, la mossa nuova entra nello stile), pietre d'elemento, ciondoli (il vecchio torna nella Bisaccia), essenze;
## e da dove arrivano (creature rare, baccelli).
func gifts(spot: Vector2i, h: Herd) -> void:
	m.fauna.clear()
	m.snap_to(spot)
	var rec := _companion(h, "volpe_ambra", 5)
	await kit.seconds(0.5)
	var bb: BondBag = m.bonds
	var b := kit.bisaccia()
	var hp0 := int(Herd.stats_of(rec)["hp"])
	var ok_fruit := bb.give(rec, "frutto_cuore") == ""
	var hp1 := int(Herd.stats_of(rec)["hp"])
	for i in 12:
		bb.give(rec, "frutto_cuore")
	var capped := int(rec["frutti"]["vita"]) == BondsData.FRUIT_MAX
	var xp0 := int(rec["xp"]) + int(rec["lvl"]) * 10000
	bb.give(rec, BondsData.XP_SEED)
	var seeded := int(rec["xp"]) + int(rec["lvl"]) * 10000 > xp0
	var early := bb.give(rec, "istinto_spara")
	rec["lvl"] = 10
	var learned := bb.give(rec, "istinto_spara") == ""
	await kit.frames(3)
	var c: Creature = h.beasts.get(int(rec["uid"]))
	var has_shot := false
	for bh in c.tame.style:
		if bh is BhSpara:
			has_shot = true
	var full := bb.give(rec, "istinto_scatto")
	var stone := bb.give(rec, "pietra_elem_gelo") == "" and String(FamiliesData.parts(String(rec["specie"]))[2]) == "gelo"
	bb.give(rec, "ciondolo_zanna")
	var n0 := b.count("ciondolo_zanna")
	bb.give(rec, "ciondolo_lume")
	var back := b.count("ciondolo_zanna") == n0 + 1
	var dmg0 := int(Herd.stats_of(rec)["damage"])
	var ess := bb.give(rec, "essenza_furia") == ""
	var dmg1 := int(Herd.stats_of(rec)["damage"])
	await kit.frames(3)
	# il clic vero sul compagno con un frutto in mano
	c = h.beasts.get(int(rec["uid"]))
	b.add("frutto_zanna", 1)
	var f0 := int((rec["frutti"] as Dictionary).get("forza", 0))
	m.bonds.use_item("frutto_zanna", c.position)
	var clicked := int((rec["frutti"] as Dictionary).get("forza", 0)) == f0 + 1 and b.count("frutto_zanna") == 0
	# da dove arrivano
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var rare_n := 0
	var pod_n := 0
	for i in 400:
		rare_n += BondsData.creature_loot(["cammina", "carica"], "gelo", "antica", rng).size()
		pod_n += BondsData.pod_loot(94, 3, rng).size()
	b.remove("ciondolo_zanna", b.count("ciondolo_zanna"))
	print("oggetti dei compagni: frutto %s (Vita %d → %d), tetto %s, Seme del ricordo %s; istinto al livello 5 «%s», al 10 %s (spara %s), il secondo «%s»; pietra gelida %s; ciondolo scambiato %s; essenza furiosa %s (danno %d → %d); clic sul compagno %s; in 400 rare %d oggetti, in 400 urne %d" % [
		"sì" if ok_fruit else "NO", hp0, hp1, "sì" if capped else "NO", "sì" if seeded else "NO", early, "sì" if learned else "NO",
		"sì" if has_shot else "NO", full, "sì" if stone else "NO", "sì" if back else "NO", "sì" if ess else "NO", dmg0, dmg1,
		"sì" if clicked else "NO", rare_n, pod_n])
	if not ok_fruit or hp1 <= hp0 or not capped or not seeded or early == "" or not learned or not has_shot or full == "" 			or not stone or not back or not ess or dmg1 <= dmg0 or not clicked or rare_n < 200 or pod_n < 40:
		print("ATTENZIONE: gli oggetti dei compagni non vanno")
