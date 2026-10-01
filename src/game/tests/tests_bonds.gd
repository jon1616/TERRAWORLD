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
