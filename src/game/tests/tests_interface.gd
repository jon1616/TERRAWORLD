class_name TestsInterface
extends RefCounted
## Prove della voce 29: la colonna Creare con tutte le stazioni vicine (categorie e ricerca), la scheda del
## Germogliato nella casella Esamina vuota, Riordina, l'aiuto con F1; foto 55_creare e 56_creare_armi.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var b: Bisaccia = m.character.bisaccia
	kit.make_room()
	var spot := kit.flat_spot(world.spawn + Vector2i(-40, 0), 16)
	if spot.x < 0:
		spot = kit.flat_spot(world.spawn, 8)
	if spot.x < 0:
		print("ATTENZIONE: nessun terreno per la prova dell'interfaccia")
		return
	kit.flatten(spot, 16)
	m.snap_to(spot)
	await kit.frames(3)
	var list := ["ceppo", "baccello_ardente", "maglio", "alambicco", "telaio", "mola"]
	for k in list.size():
		# ci si sposta lungo il terreno spianato: ogni stazione al suo posto, tutte a portata dal centro
		m.snap_to(Vector2i(spot.x - 12 + k * 5, spot.y))
		b.add(String(list[k]), 1)
		kit.place_station_near(String(list[k]), m.player_cell())
	m.snap_to(spot)
	await kit.frames(2)
	var near := Crafting.stations_near(world, m.player_cell())
	print("stazioni a portata per la prova dell'interfaccia: %s" % [near.keys()])
	# un po' di materiali perché qualche ricetta sia possibile
	for k in {"legno": 40, "gelatina": 20, "lingotto_radicite": 20, "seta_radice": 20, "sanguinella": 10, "ardesia": 30}:
		b.add(k, 20)
	var cp: CraftingPanel = m.hud.panel.crafting
	m.hud.panel.toggle()
	await kit.frames(3)
	var counts := []
	for k in CraftingPanel.CATS.size():
		cp.cat = k
		cp.refresh()
		await kit.frames(1)
		counts.append("%s %d" % [CraftingPanel.CATS[k][0], cp.shown_rows()])
	print("Creare, righe per categoria: %s" % ", ".join(counts))
	# il suggerimento di una casella ricetta (le caselle si riusano e lo scrivono solo quando il mouse ci passa sopra)
	cp.cat = 0
	cp.refresh()
	var tip := ""
	var tiles := cp.shown_tiles()
	if not tiles.is_empty():
		var tc := Tips.card_of(tiles[0])
		tip = tc.plain() if tc != null else ""
	print("Creare, suggerimento della prima ricetta: %s" % ("sì" if tip.strip_edges().length() > 3 else "NO"))
	# 28 set 2026: si sceglie una ricetta possibile, la sua scheda compare in Esamina e «Crea» fabbrica davvero (e suona)
	var ex: ExaminePanel = m.hud.panel.examine
	var made := "NO"
	var card_ok := false
	for t in cp.shown_tiles():
		if t.can:
			var out := String(t.r["out"])
			var before := b.count(out)
			var sounds := int(m.sfx.played.get("crea", 0))
			t.chosen.emit(t)
			await kit.frames(2)
			card_ok = ex._card.visible and ex._name.text.begins_with(String(ItemsData.get_item(out)["name"])) and not ex._make.disabled
			ex._make.pressed.emit()
			made = "%s ×%d%s" % [ItemsData.get_item(out)["name"], b.count(out) - before,
				", suonato" if int(m.sfx.played.get("crea", 0)) > sounds else ", NESSUN suono"]
			break
	print("Creare, ricetta scelta: scheda in Esamina %s; «Crea»: %s" % ["sì" if card_ok else "NO", made])
	cp.cat = 0
	cp.refresh()
	await kit.seconds(1.0)
	await kit.save("55_creare")
	cp.cat = 1
	cp._search.text = "bastone"
	cp.refresh()
	await kit.frames(3)
	print("Creare, Armi con la ricerca «bastone»: %d ricette" % cp.shown_rows())
	await kit.seconds(0.5)
	await kit.save("56_creare_armi")
	cp._search.text = ""
	# 30 set 2026: le categorie nuove. I banchi da lavoro stanno da soli; una sottocategoria scelta restringe la griglia
	cp.all_benches = true
	cp.cat = 1 + CraftCatsData.index_of("banchi")
	cp.sub = ""
	cp.refresh()
	await kit.frames(3)
	var bench_ids := []
	for t in cp.shown_tiles():
		bench_ids.append(String(t.r["out"]))
	var benches_ok := "ceppo" in bench_ids and "maglio" in bench_ids and not bench_ids.any(
		func(x: String) -> bool: return x.begins_with("trappola") or x.begins_with("totem") or MachinesData.is_machine(x))
	await kit.save("57_creare_banchi")
	cp.cat = 1 + CraftCatsData.index_of("blocchi")
	cp.refresh()
	await kit.frames(3)
	var all_blocks := cp.shown_rows()
	var chips := cp._chips.get_child_count()
	await kit.save("58_creare_blocchi")
	cp.sub = "Mattoni"
	cp.refresh()
	await kit.frames(2)
	var bricks := cp.shown_rows()
	print("Creare, categorie nuove: banchi da soli %s (%d), blocchi %d in %d sottocategorie, solo «Mattoni» %d" % [
		benches_ok, bench_ids.size(), all_blocks, chips - 1, bricks])
	if not benches_ok or chips < 3 or bricks <= 0 or bricks >= all_blocks:
		print("ATTENZIONE: le categorie di Creare non vanno")
	cp.all_benches = false
	cp.sub = ""
	cp.cat = 0
	cp.refresh()
	if tip.strip_edges().length() <= 3 or not card_ok or made == "NO" or not made.contains("suonato"):
		print("ATTENZIONE: il pannello Creare non funziona come dovrebbe")
	# la scheda del Germogliato
	var cc: CharacterCard = m.hud.panel.card
	cc.refresh()
	print("scheda del Germogliato: %s" % ("sì" if cc.text.text.contains("Scorza") else "NO"))
	m.hud.panel.toggle()
	# Riordina
	b.add("aculeo", 5)
	b.add("spada_radicite", 1)
	b.add("aculeo", 7)
	b.sort_bag()
	var kinds := []
	for i in range(Bisaccia.HOTBAR, b.slots.size()):
		if not b.slots[i].is_empty():
			kinds.append(Bisaccia.SORT_KINDS.find(String(ItemsData.get_item(b.id_at(i)).get("kind", ""))))
	var ordered := true
	for k in range(1, kinds.size()):
		if kinds[k] < kinds[k - 1]:
			ordered = false
	print("Riordina: %d pile, in ordine di tipo %s" % [kinds.size(), "sì" if ordered else "NO"])
	# F1
	var was: bool = m.hud.help
	var ev := InputEventKey.new()
	ev.keycode = KEY_F1
	ev.pressed = true
	m.hud._unhandled_input(ev)
	print("F1: aiuto da %s a %s" % ["visibile" if was else "nascosto", "visibile" if m.hud.help else "nascosto"])
	m.hud._unhandled_input(ev)
