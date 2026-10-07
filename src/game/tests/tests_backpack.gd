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
	await sections()
	await bags()
	await pouches()
	await pick_rules()
	await larder()
	await pack_beast()
	await compartments()
	await locks()


## Lo stato della Bisaccia da rimettere dopo la prova: caselle, contenuto ed equipaggiamento.
func _save_bag() -> Dictionary:
	var b: Bisaccia = m.character.bisaccia
	return {"slots": b.slots.duplicate(true), "equip": b.equip.duplicate(true), "traits": b.equip_traits.duplicate(true),
		"data": b.equip_data.duplicate(true), "stats": m.character.stats.duplicate(true),
		"sections": b.sections.duplicate(true), "size": b.section_size,
		"raccolta": b.raccolta.slots.duplicate(true) if b.raccolta != null else []}


func _restore_bag(s: Dictionary) -> void:
	var b: Bisaccia = m.character.bisaccia
	b.slots.clear()
	for e in s["slots"]:
		b.slots.append((e as Dictionary).duplicate(true))
	b.equip = (s["equip"] as Dictionary).duplicate(true)
	b.equip_traits = (s["traits"] as Dictionary).duplicate(true)
	b.equip_data = (s["data"] as Dictionary).duplicate(true)
	b.sections = (s["sections"] as Array).duplicate(true)       # Roadmap 53
	b.section_size = int(s["size"])
	if b.raccolta != null:
		b.raccolta.slots.clear()
		for e in s["raccolta"]:
			b.raccolta.slots.append((e as Dictionary).duplicate(true))
	var st: Dictionary = m.character.stats
	for k in st.keys():
		if not (s["stats"] as Dictionary).has(k):
			st.erase(k)
	for k in s["stats"]:
		st[k] = s["stats"][k]
	b.changed.emit()


## Roadmap 53: una Bisaccia più grande ingrandisce tutti gli scomparti (il contenuto resta), una più piccola non si
## consuma; lo scomparto più grande di una pagina si sfoglia; il salvataggio tiene le caselle.
func bags() -> void:
	var saved := _save_bag()
	var b: Bisaccia = m.character.bisaccia
	var n0 := b.section_size
	var first := b.slots[0].duplicate(true)
	b.add("bisaccia_ambra", 1)
	var grown: bool = m.backpack.use_bag("bisaccia_ambra")
	var n1 := b.section_size
	b.add("bisaccia_seta", 1)
	var smaller: bool = m.backpack.use_bag("bisaccia_seta")
	var kept := b.count("bisaccia_seta") == 1 and b.slots[0] == first
	b.remove("bisaccia_seta", 1)
	var r := b.section_range("materiali")
	b.slots[r.y - 1] = {"id": "legno", "n": 7}               # l'ultima casella dei Materiali, sulla terza pagina
	var d: Dictionary = m.character.to_dict()
	var back := Character.from_dict("prova_zaino", JSON.parse_string(JSON.stringify(d)))
	var saved_ok: bool = back != null and back.bisaccia.section_size == n1 and back.bisaccia.id_at(r.y - 1) == "legno" \
		and back.bisaccia.section_range("materiali") == r
	var bp: BisacciaPanel = m.hud.panel
	bp.toggle()
	await kit.frames(3)
	var tab := -1
	for k in bp._views.size():
		if String(bp._views[k].get("sec", "")) == "materiali":
			tab = k
	bp.view = tab
	bp.page = 2
	bp._refresh()
	await kit.frames(3)
	var last_seen := false
	for sv in bp._slots:
		if sv.visible and sv.index == r.y - 1:
			last_seen = true
	await kit.save("300_zaino_pagine")
	bp.view = 0
	bp.page = 0
	bp.toggle()
	var ok: bool = grown and n1 == 75 and not smaller and kept and saved_ok and last_seen and tab >= 0
	print("Bisacce a gradi: scomparti da %d → %d caselle %s, una più piccola non si usa %s, contenuto al suo posto %s, salvataggio %s, ultima casella in vista %s" % [
		n0, n1, grown, not smaller, kept, saved_ok, last_seen])
	if not ok:
		print("ATTENZIONE: le Bisacce a gradi non vanno")
	_restore_bag(saved)


## Roadmap 53: ciò che si raccoglie va nel suo scomparto; le tavolette, i fossili e le reliquie nella Raccolta (che non si
## riempie mai); uno scomparto pieno manda il resto nella barra rapida; si conta e si spende da ovunque; il salvataggio
## tiene tutto; una Bisaccia di prima (senza scomparti) si ridistribuisce da sola.
func sections() -> void:
	var saved := _save_bag()
	var b: Bisaccia = m.character.bisaccia
	for i in b.slots.size():
		if i >= Bisaccia.HOTBAR:
			b.slots[i] = {}
	var hot := b.slots.slice(0, Bisaccia.HOTBAR).duplicate(true)
	b.add("minerale_radicite", 12)
	b.add("legno", 20)
	b.add("tavoletta_seminatori", 3)
	var fossil := ArchaeologyData.fossil_id("grumo_primo", "cranio")
	b.add(fossil, 1)
	var rm := b.section_range("minerali")
	var rt := b.section_range("materiali")
	var routed := b.count("minerale_radicite") == 12 and _in(b, "minerale_radicite", rm) and _in(b, "legno", rt) \
		and b.raccolta.count("tavoletta_seminatori") == 3 and b.raccolta.count(fossil) == 1 and b.slots.slice(0, Bisaccia.HOTBAR) == hot
	# uno scomparto pieno: il resto nella barra rapida (se c'è posto)
	for i in range(rt.x, rt.y):
		b.slots[i] = {"id": "seta_radice", "n": ItemsData.stack_of("seta_radice")}
	var free_hot := -1
	for i in Bisaccia.HOTBAR:
		if b.slots[i].is_empty():
			free_hot = i
			break
	var left := b.add("gelatina", 3)
	var overflow := free_hot < 0 or (left == 0 and b.id_at(free_hot) == "gelatina")
	if free_hot >= 0:
		b.slots[free_hot] = {}
	for i in range(rt.x, rt.y):
		b.slots[i] = {}
	# la Raccolta cresce
	var r0 := b.raccolta.slots.size()
	for k in r0 + 3:
		b.add_stack({"id": "tavoletta_seminatori", "n": 1, "dati": {"k": k}})
	var grows := b.raccolta.slots.size() > r0
	var counted := b.count("tavoletta_seminatori") >= 3 and b.remove("tavoletta_seminatori", 1)
	# salvataggio e ricaricamento
	var back := Character.from_dict("prova_scomparti_tipo", JSON.parse_string(JSON.stringify(m.character.to_dict())))
	var saved_ok: bool = back != null and back.bisaccia.sections.size() == 9 and back.bisaccia.count("minerale_radicite") == 12 \
		and back.bisaccia.raccolta.count(fossil) == 1
	# una Bisaccia di prima: 84 caselle senza scomparti
	var old: Dictionary = m.character.to_dict()
	old.erase("sezioni")
	old.erase("raccolta")
	var flat := Bisaccia.new(84)
	flat.slots[3] = {"id": "piccone_radicite", "n": 1}
	flat.slots[50] = {"id": "minerale_radicite", "n": 9}
	flat.slots[83] = {"id": "tavoletta_seminatori", "n": 2}
	old["bisaccia"] = flat.to_array()
	var mig := Character.from_dict("prova_bisaccia_vecchia", JSON.parse_string(JSON.stringify(old)))
	var migrated: bool = mig != null and mig.bisaccia.section_size == 75 and mig.bisaccia.id_at(3) == "piccone_radicite" \
		and _in(mig.bisaccia, "minerale_radicite", mig.bisaccia.section_range("minerali")) \
		and mig.bisaccia.raccolta.count("tavoletta_seminatori") == 2
	var bp: BisacciaPanel = m.hud.panel
	bp.toggle()
	await kit.frames(2)
	var tabs := bp._views.filter(func(v: Dictionary) -> bool: return v.has("sec")).size()
	await kit.save("308_scomparti_tipo")
	bp.toggle()
	var ok: bool = routed and overflow and grows and counted and saved_ok and migrated and tabs == 10
	print("scomparti per tipo: smistati %s, pieno → barra rapida %s, Raccolta che cresce %s (%d → %d), contati %s, salvataggio %s, Bisaccia di prima %s, schede %d" % [
		routed, overflow, grows, r0, b.raccolta.slots.size(), counted, saved_ok, migrated, tabs])
	if not ok:
		print("ATTENZIONE: gli scomparti per tipo non vanno")
	_restore_bag(saved)


## C'è almeno una pila di `id` tra le caselle r.x e r.y?
static func _in(b: Bisaccia, id: String, r: Vector2i) -> bool:
	for i in range(r.x, r.y):
		if b.id_at(i) == id:
			return true
	return false


## 3 ott 2026: le caselle bloccate (Alt+clic). «Deposita tutto», il Seme della Dispensa e «Riordina» non le toccano;
## le altre si spostano come sempre; il lucchetto si vede nella casella.
func locks() -> void:
	var saved := _save_bag()
	var b: Bisaccia = m.character.bisaccia
	var d0: Bisaccia = m.character.dispensa
	for i in b.slots.size():
		b.slots[i] = {}
	var a := Bisaccia.HOTBAR + 4
	b.slots[a] = {"id": "humus", "n": 30}
	b.slots[Bisaccia.HOTBAR + 1] = {"id": "humus", "n": 20}
	b.slots[Bisaccia.HOTBAR + 7] = {"id": "legno", "n": 9}
	var on := b.toggle_lock(a)
	var chest := Bisaccia.new(20)
	var moved: int = m.storage.deposit_all(chest)
	var kept_dep: bool = b.id_at(a) == "humus" and b.count_at(a) == 30 and chest.count("humus") == 20 and chest.count("legno") == 9
	b.slots[Bisaccia.HOTBAR + 2] = {"id": "humus", "n": 5}
	var dsp: Bisaccia = m.backpack.dispensa()
	dsp.add("humus", 1)                                # la Dispensa lo contiene già: il Seme lo manderebbe
	m.backpack.send_surplus()
	var kept_seed: bool = b.count_at(a) == 30 and b.id_at(Bisaccia.HOTBAR + 2) == ""
	b.slots[Bisaccia.HOTBAR + 9] = {"id": "legno", "n": 3}
	b.sort_bag()
	var kept_sort: bool = b.locked(a) and b.id_at(a) == "humus" and b.id_at(Bisaccia.HOTBAR) == "legno"
	var bp: BisacciaPanel = m.hud.panel
	bp.toggle()
	await kit.frames(3)
	var shown := false
	for s in bp._slots:
		if s.visible and s.index == a and s._lock != null and s._lock.visible:
			shown = true
	await kit.save("307_bloccati")
	bp.toggle()
	var off := not b.toggle_lock(a)
	var ok: bool = on and moved > 0 and kept_dep and kept_seed and kept_sort and shown and off
	print("caselle bloccate: Deposita tutto %s, Seme della Dispensa %s, Riordina %s, lucchetto %s, si sblocca %s" % [
		kept_dep, kept_seed, kept_sort, shown, off])
	if not ok:
		print("ATTENZIONE: le caselle bloccate non vanno")
	m.character.dispensa = d0
	_restore_bag(saved)


## 3 ott 2026: gli scomparti. Munizioni, torce e Lumini ci vanno da soli (dopo la pila della barra rapida), si contano e
## si spendono; la pila della barra rapida finita si riempie da lì; appassendo restano addosso; il salvataggio li tiene.
func compartments() -> void:
	var saved := _save_bag()
	var b: Bisaccia = m.character.bisaccia
	var c0: Array = b.comps.to_array()
	for i in b.slots.size():
		b.slots[i] = {}
	for i in b.comps.slots.size():
		b.comps.slots[i] = {}
	b.slots[0] = {"id": "torcia", "n": 2}
	b.add("dardo", 30)
	b.add("torcia", 40)
	b.add("lumino", 120)
	b.slots[Bisaccia.HOTBAR + 2] = {"id": "legno", "n": 5}   # nelle caselle grandi: appassendo va nel fagotto
	var in_comps: bool = b.comps.count("dardo") == 30 and b.comps.count("lumino") == 120 and b.count_at(0) == 42 \
		and b.count("dardo") == 30 and b.count("legno") == 5
	b.add("torcia", 999)                               # la pila in mano è piena: il resto va nello scomparto
	var torch_comp := b.comps.count("torcia")
	b.slots[0]["n"] = 1
	b.take_one(0)                                      # finita la pila in mano: si riempie dallo scomparto
	var refilled := b.id_at(0) == "torcia" and b.count_at(0) > 0 and b.comps.count("torcia") < torch_comp
	var paid := b.remove("lumino", 20) and b.comps.count("lumino") == 100
	m.life._drop_bundle()                              # appassire: il fagotto prende solo le caselle grandi
	var kept_ok: bool = b.comps.count("dardo") == 30 and b.comps.count("lumino") == 100 and b.count("legno") == 0
	if m.life.bundle.x >= 0:
		m.world.stations.erase(m.life.bundle)
		m.world.chests.erase(m.life.bundle)
		m.view.remove_station(m.life.bundle)
		m.life.bundle = Vector2i(-1, -1)
	var back := Character.from_dict("prova_scomparti", JSON.parse_string(JSON.stringify(m.character.to_dict())))
	var saved_ok: bool = back != null and back.bisaccia.comps != null and back.bisaccia.comps.count("dardo") == 30
	var bp: BisacciaPanel = m.hud.panel
	bp.toggle()
	await kit.frames(2)
	var tab := -1
	for k in bp._views.size():
		if bp._views[k]["bag"] == b.comps:
			tab = k
	if tab >= 0:
		bp.view = tab
		bp._refresh()
		await kit.frames(3)
		await kit.save("306_scomparti")
	bp.view = 0
	bp.toggle()
	var ok: bool = in_comps and torch_comp > 0 and refilled and paid and kept_ok and saved_ok and tab >= 0
	print("scomparti: ci vanno da soli %s, la pila in mano si riempie %s, i Lumini si spendono %s, appassendo restano %s, salvataggio %s, scheda %s" % [
		in_comps, refilled, paid, kept_ok, saved_ok, tab >= 0])
	if not ok:
		print("ATTENZIONE: gli scomparti della Bisaccia non vanno")
	_restore_bag(saved)
	var cb: Bisaccia = Compartments.make(c0)
	for i in b.comps.slots.size():
		b.comps.slots[i] = cb.slots[i]
	b.comps.changed.emit()


## Voce 296: una tasca alla cintura prende da sola il suo tipo; ciò che contiene si conta per creare, si toglie, resta nella
## tasca quando la si leva e torna quando la si rimette; il salvataggio la tiene.
func pouches() -> void:
	var saved := _save_bag()
	var b: Bisaccia = m.character.bisaccia
	b.equip.erase("tasca_1")
	b.equip.erase("tasca_2")
	b.setup_sections(b.section_size, true)
	var n0 := b.section_range("minerali")
	var back0 := b.wear("tasca_1", {"id": "tasca_minatore_1", "n": 1})
	var n1 := b.section_range("minerali")
	var bigger := (n1.y - n1.x) == (n0.y - n0.x) + 10
	# lo scomparto pieno, e la barra rapida pure: togliendo la tasca, dieci minerali non stanno più da nessuna parte
	var hot := b.slots.slice(0, Bisaccia.HOTBAR).duplicate(true)
	for i in range(n1.x, n1.y):
		b.slots[i] = {"id": "minerale_radicite", "n": ItemsData.stack_of("minerale_radicite")}   # (piene: non si uniscono)
	for i in Bisaccia.HOTBAR:
		if b.slots[i].is_empty():
			b.slots[i] = {"id": "legno", "n": 1}
	var off := b.wear("tasca_1", {})
	var c: Array = (off.get("dati", {}) as Dictionary).get("c", [])
	var kept_in := c.size() == 10 and (b.section_range("minerali").y - b.section_range("minerali").x) == (n0.y - n0.x)
	b.wear("tasca_1", off)
	var again := b.count("minerale_radicite") == (n1.y - n1.x) * ItemsData.stack_of("minerale_radicite")
	for i in Bisaccia.HOTBAR:
		b.slots[i] = hot[i]
	var d: Dictionary = m.character.to_dict()
	var ch := Character.from_dict("prova_tasche", JSON.parse_string(JSON.stringify(d)))
	var saved_ok: bool = ch != null and ch.bisaccia.section_range("minerali") == b.section_range("minerali") and ch.bisaccia.count("minerale_radicite") == (n1.y - n1.x) * ItemsData.stack_of("minerale_radicite")
	var bp: BisacciaPanel = m.hud.panel
	bp.toggle()
	await kit.frames(3)
	await kit.save("301_zaino_tasca")
	bp.toggle()
	var ok: bool = back0.is_empty() and bigger and kept_in and again and saved_ok
	print("tasche: la Sacca del minatore allarga i Minerali di 10 %s, tolta tiene ciò che non ci sta %s, rimessa %s, salvataggio %s" % [
		bigger, kept_in, again, saved_ok])
	if not ok:
		print("ATTENZIONE: le tasche non vanno")
	_restore_bag(saved)


## Voce 297: un oggetto segnato «Non raccogliere» resta a terra; «Dritto nel Cestino» sparisce senza entrare nella Bisaccia.
func pick_rules() -> void:
	var saved := _save_bag()
	var b: Bisaccia = m.character.bisaccia
	var bk: Backpack = m.backpack
	var id := "humus"
	b.slots[b.slots.size() - 1] = {}                 # (le prove di prima possono riempire la Bisaccia: un posto libero)
	var r0 := bk.rule(id)
	var n0 := b.count(id)
	var d0 := _drops_of(id)                          # (solo i suoi: le prove di prima lasciano altro a terra)
	bk.set_rule(id, "lascia")
	m.drops.spawn(id, 3, m.player.position + Vector2(0, -8))
	await kit.seconds(1.5)
	var left_there: bool = _drops_of(id) == d0 + 1 and b.count(id) == n0
	bk.set_rule(id, "cestino")
	await kit.seconds(1.5)
	var trashed: bool = _drops_of(id) == d0 and b.count(id) == n0
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


func _drops_of(id: String) -> int:
	var n := 0
	for e in m.drops._items:
		if String(e["id"]) == id:
			n += 1
	return n


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
	var sent := dsp.count("ardesia") >= 40 and b.id_at(b.slots.size() - 2) == "spada_radice"
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
	var saved_ok: bool = ch != null and ch.dispensa != null and ch.dispensa.count("ardesia") >= 40 and ch.dispensa.slots.size() == 200
	# la Dispensa vicina con «usa per creare» dà gli ingredienti alla creazione (2 ott 2026, segnalato dall'utente)
	var at: Vector2i = m.player_cell() + Vector2i(2, -1)
	m.world.stations[at] = "dispensa"
	m.world.stations_changed()
	m.storage._update_pool()
	var crafts: bool = dsp in Crafting.pool and Crafting.in_pool("ardesia") >= 40
	m.world.stations.erase(at)
	m.world.stations_changed()
	m.storage._update_pool()
	print("Dispensa vicina negli ingredienti della creazione: %s" % crafts)
	var ok: bool = n1 == 60 and opened and sent and n2 == 120 and far_open and n3 == 200 and saved_ok and crafts
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
	b.slots[b.slots.size() - 1] = {}                 # (le prove di prima possono averla riempita: un posto per il basto)
	b.add("basto_radice", 1)
	var put: bool = bk.use_basto("basto_radice")
	if not put:
		print("ATTENZIONE: il basto non è andato alla creatura (nella Bisaccia %d, che seguono %d)" % [b.count("basto_radice"),
			m.herd.followers().size()])
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
