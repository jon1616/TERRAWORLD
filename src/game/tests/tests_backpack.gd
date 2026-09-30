class_name TestsBackpack
extends RefCounted
## Roadmap 30 «Lo zaino»: Bisacce a gradi, tasche, «non raccogliere», Dispensa, basto (gruppo `zaino`). Ogni prova
## rimette la Bisaccia com'era (caselle, contenuto, equipaggiamento) e i conteggi del personaggio.

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await bags()
	await pouches()
	await pick_rules()
	await larder()
	await pack_beast()


## Lo stato della Bisaccia da rimettere dopo la prova: caselle, contenuto ed equipaggiamento.
func _save_bag() -> Dictionary:
	var b: Bisaccia = m.character.bisaccia
	return {"slots": b.slots.duplicate(true), "equip": b.equip.duplicate(true), "traits": b.equip_traits.duplicate(true),
		"data": b.equip_data.duplicate(true), "stats": m.character.stats.duplicate(true)}


func _restore_bag(s: Dictionary) -> void:
	var b: Bisaccia = m.character.bisaccia
	b.slots.clear()
	for e in s["slots"]:
		b.slots.append((e as Dictionary).duplicate(true))
	b.equip = (s["equip"] as Dictionary).duplicate(true)
	b.equip_traits = (s["traits"] as Dictionary).duplicate(true)
	b.equip_data = (s["data"] as Dictionary).duplicate(true)
	var st: Dictionary = m.character.stats
	for k in st.keys():
		if not (s["stats"] as Dictionary).has(k):
			st.erase(k)
	for k in s["stats"]:
		st[k] = s["stats"][k]
	b.changed.emit()


## Voce 295: una Bisaccia più grande allarga lo zaino (il contenuto resta), una più piccola non si consuma; il pannello si
## sfoglia a pagine; il salvataggio tiene le caselle.
func bags() -> void:
	var saved := _save_bag()
	var b: Bisaccia = m.character.bisaccia
	var n0 := b.slots.size()
	var first := b.slots[0].duplicate(true)
	b.slots[b.slots.size() - 1] = {}
	b.add("bisaccia_ambra", 1)
	var grown: bool = m.backpack.use_bag("bisaccia_ambra")
	var n1 := b.slots.size()
	b.add("bisaccia_seta", 1)
	var smaller: bool = m.backpack.use_bag("bisaccia_seta")
	var kept := b.count("bisaccia_seta") == 1 and b.slots[0] == first
	b.remove("bisaccia_seta", 1)
	b.slots[n1 - 1] = {"id": "legno", "n": 7}               # una casella in fondo, sull'ultima pagina
	var d: Dictionary = m.character.to_dict()
	var back := Character.from_dict("prova_zaino", JSON.parse_string(JSON.stringify(d)))
	var saved_ok: bool = back != null and back.bisaccia.slots.size() == n1 and back.bisaccia.id_at(n1 - 1) == "legno"
	var bp: BisacciaPanel = m.hud.panel
	bp.toggle()
	await kit.frames(3)
	var pages := bp._views.size()
	bp.view = pages - 1
	bp._refresh()
	await kit.frames(3)
	var last_seen := false
	for s in bp._slots:
		if s.visible and s.index == n1 - 1:
			last_seen = true
	await kit.save("300_zaino_pagine")
	bp.view = 0
	bp.toggle()
	var ok: bool = grown and n1 == 84 and not smaller and kept and saved_ok and pages == 3 and last_seen
	print("Bisacce a gradi: %d → %d caselle %s, una più piccola non si usa %s, contenuto al suo posto %s, salvataggio %s, pagine %d, ultima casella in vista %s" % [
		n0, n1, grown, not smaller, kept, saved_ok, pages, last_seen])
	if not ok:
		print("ATTENZIONE: le Bisacce a gradi non vanno")
	_restore_bag(saved)


## Voce 296: una tasca alla cintura prende da sola il suo tipo; ciò che contiene si conta per creare, si toglie, resta nella
## tasca quando la si leva e torna quando la si rimette; il salvataggio la tiene.
func pouches() -> void:
	var saved := _save_bag()
	var b: Bisaccia = m.character.bisaccia
	b.equip.erase("tasca_1")
	b.equip.erase("tasca_2")
	var back0 := b.wear("tasca_1", {"id": "tasca_minatore_1", "n": 1})
	var main0 := 0
	for s in b.slots:
		if String(s.get("id", "")) == "ardesia":
			main0 += int(s["n"])
	var pb := b.pouch("tasca_1")
	var rest := b.add("ardesia", 30)
	var in_pouch := pb.count("ardesia") if pb != null else -1
	var main1 := 0
	for s in b.slots:
		if String(s.get("id", "")) == "ardesia":
			main1 += int(s["n"])
	var counted := b.count("ardesia") == main0 + 30 and int(Crafting.counts(b).get("ardesia", 0)) >= main0 + 30
	b.add("dardo", 5)
	var sword_refused := pb != null and not BackpackData.accepts("minatore", "spada_radice") and pb.count("dardo") == 0
	b.remove("ardesia", main0 + 5)
	var took := pb != null and pb.count("ardesia") == 25
	var d: Dictionary = m.character.to_dict()
	var ch := Character.from_dict("prova_tasche", JSON.parse_string(JSON.stringify(d)))
	var saved_ok: bool = ch != null and ch.bisaccia.pouch("tasca_1") != null and ch.bisaccia.pouch("tasca_1").count("ardesia") == 25
	var bp: BisacciaPanel = m.hud.panel
	bp.toggle()
	await kit.frames(2)
	bp.view = bp._views.size() - 1
	bp._refresh()
	await kit.frames(3)
	var tab_ok: bool = bp.bag() == pb
	await kit.save("301_zaino_tasca")
	bp.view = 0
	bp.toggle()
	var off := b.wear("tasca_1", {})
	var off_full := (off.get("dati", {}) as Dictionary).has("c") and b.count("ardesia") == 0
	b.wear("tasca_1", off)
	var again := b.count("ardesia") == 25
	var ok: bool = back0.is_empty() and rest == 0 and in_pouch == 30 and main1 == main0 and counted and sword_refused and took 		and saved_ok and tab_ok and off_full and again
	print("tasche: 30 ardesie nella Sacca del minatore %s (fuori %d → %d), contate per creare %s, dardi rifiutati %s, tolte %s, salvataggio %s, scheda %s, tolta piena %s, rimessa %s" % [
		in_pouch == 30, main0, main1, counted, sword_refused, took, saved_ok, tab_ok, off_full, again])
	if not ok:
		print("ATTENZIONE: le tasche non vanno")
	_restore_bag(saved)


## Voce 297: un oggetto segnato «Non raccogliere» resta a terra; «Dritto nel Cestino» sparisce senza entrare nella Bisaccia.
func pick_rules() -> void:
	var saved := _save_bag()
	var b: Bisaccia = m.character.bisaccia
	var bk: Backpack = m.backpack
	var id := "humus"
	var r0 := bk.rule(id)
	var n0 := b.count(id)
	var d0: int = m.drops.count()
	bk.set_rule(id, "lascia")
	m.drops.spawn(id, 3, m.player.position + Vector2(0, -8))
	await kit.seconds(1.5)
	var left_there: bool = m.drops.count() == d0 + 1 and b.count(id) == n0
	bk.set_rule(id, "cestino")
	await kit.seconds(1.5)
	var trashed: bool = m.drops.count() == d0 and b.count(id) == n0
	bk.set_rule(id, "")
	m.drops.spawn(id, 2, m.player.position + Vector2(0, -8))
	await kit.seconds(1.5)
	var picked := b.count(id) == n0 + 2
	var bp: BisacciaPanel = m.hud.panel
	var text := String(Backpack.RULE_TEXT[bk.next_rule(id)])
	var cycled := bk.rule(id) == "lascia" and text == "Non raccogliere"
	bk.set_rule(id, r0)
	var ok: bool = left_there and trashed and picked and cycled and bp.pick_rule.is_valid()
	print("non raccogliere: resta a terra %s, nel Cestino %s, di nuovo raccolto %s, il pulsante cambia %s" % [left_there, trashed,
		picked, cycled])
	if not ok:
		print("ATTENZIONE: «Non raccogliere» non va")
	_restore_bag(saved)


## Voce 298: la Dispensa è del personaggio: la stazione la apre, il Seme ci manda il superfluo (e la porta a 120), il
## Cuore la apre ovunque (e la porta a 200); il salvataggio la tiene.
func larder() -> void:
	var saved := _save_bag()
	var d0: Bisaccia = m.character.dispensa
	var bk: Backpack = m.backpack
	m.character.dispensa = null
	m.character.stats.erase("dispensa_grado")
	var b: Bisaccia = m.character.bisaccia
	var dsp := bk.dispensa()
	var n1 := dsp.slots.size()
	bk.open_dispensa(m.player_cell())
	await kit.frames(3)
	var ip: ChestPanel = m.interact.chest_panel
	var opened: bool = ip.visible and ip.chest == dsp
	ip.close()
	if m.hud.panel.visible:
		m.hud.panel.toggle()
	b.slots[b.slots.size() - 1] = {"id": "ardesia", "n": 40}
	b.slots[b.slots.size() - 2] = {"id": "spada_radice", "n": 1}
	bk.use_dispensa("seme_dispensa")
	var sent := dsp.count("ardesia") == 40 and b.id_at(b.slots.size() - 2) == "spada_radice"
	var n2 := bk.dispensa().slots.size()
	bk.use_dispensa("cuore_dispensa")
	await kit.frames(3)
	var far_open: bool = ip.visible and ip.personal and ip.chest == dsp
	await kit.save("302_zaino_dispensa")
	ip.close()
	if m.hud.panel.visible:
		m.hud.panel.toggle()
	var n3 := bk.dispensa().slots.size()
	var dd: Dictionary = m.character.to_dict()
	var ch := Character.from_dict("prova_dispensa", JSON.parse_string(JSON.stringify(dd)))
	var saved_ok: bool = ch != null and ch.dispensa != null and ch.dispensa.count("ardesia") == 40 and ch.dispensa.slots.size() == 200
	var ok: bool = n1 == 60 and opened and sent and n2 == 120 and far_open and n3 == 200 and saved_ok
	print("Dispensa: %d → %d → %d caselle, aperta dalla stazione %s, il Seme manda l'ardesia (non la spada) %s, il Cuore la apre ovunque %s, salvataggio %s" % [
		n1, n2, n3, opened, sent, far_open, saved_ok])
	if not ok:
		print("ATTENZIONE: la Dispensa non va")
	m.character.dispensa = d0
	_restore_bag(saved)


## Voce 299: il basto va a una creatura che ti segue; con la Bisaccia piena ciò che non entra va sul basto, si conta e
## resta nella scheda della creatura; un basto più grande prende il posto di quello piccolo (il contenuto passa).
func pack_beast() -> void:
	var saved := _save_bag()
	var herd0: Array = (m.character.mandria as Array).duplicate(true)
	var bk: Backpack = m.backpack
	var b: Bisaccia = m.character.bisaccia
	var rec: Dictionary = m.herd.new_record("pecora_muschio", "nutrita")
	rec["stato"] = "segue"
	rec["vita"] = 1.0
	(m.character.mandria as Array).append(rec)
	for r in m.character.mandria:
		if r != rec and String(r["stato"]) == "segue":
			r["stato"] = "riposo"
	b.add("basto_radice", 1)
	var put: bool = bk.use_basto("basto_radice")
	bk.update_carriers()
	var slots_n := BackpackData.basto_slots("basto_radice", int(rec["lvl"]))
	for i in b.slots.size():
		if b.slots[i].is_empty():
			b.slots[i] = {"id": "spada_radice", "n": 1}
	var h0 := b.count("humus")
	for i in b.slots.size():
		if b.id_at(i) == "humus":
			b.slots[i] = {"id": "spada_radice", "n": 1}
	var left := b.add("humus", 30)
	var on_beast := b.carriers.size() == 1 and (b.carriers[0]["bag"] as Bisaccia).count("humus") == 30
	var counted := b.count("humus") == 30 and left == 0
	var in_rec := ((rec["basto"] as Dictionary).get("c", []) as Array).size() > 0
	var views := b.extra_views().any(func(v: Dictionary) -> bool: return String(v.get("icon", "")) == "basto_radice")
	b.slots[b.slots.size() - 1] = {"id": "basto_ambra", "n": 1}
	var upgraded: bool = bk.use_basto("basto_ambra")
	bk.update_carriers()
	var kept := b.carriers.size() == 1 and (b.carriers[0]["bag"] as Bisaccia).count("humus") == 30 		and (b.carriers[0]["bag"] as Bisaccia).slots.size() == BackpackData.basto_slots("basto_ambra", int(rec["lvl"]))
	rec["stato"] = "riposo"
	bk.update_carriers()
	var gone := b.carriers.is_empty() and b.count("humus") == 0
	var ok: bool = put and slots_n >= 8 and on_beast and counted and in_rec and views and upgraded and kept and gone and h0 >= 0
	print("basto: messo %s (%d caselle), la Bisaccia piena lo usa %s, contato %s, resta nella scheda %s, scheda nel pannello %s, basto più grande %s (contenuto passato %s), a riposo non segue più %s" % [
		put, slots_n, on_beast, counted, in_rec, views, upgraded, kept, gone])
	if not ok:
		print("ATTENZIONE: il basto non va")
	m.character.mandria = herd0
	bk.update_carriers()
	_restore_bag(saved)
