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
	# il suggerimento di una riga (le righe si riusano e lo scrivono solo quando il mouse ci passa sopra)
	var tip := ""
	for c in cp._list.get_children():
		if c is CraftingPanel.RecipeRow and (c as Control).visible:
			tip = (c as Control).get_tooltip(Vector2(5, 5))
			break
	print("Creare, suggerimento della prima ricetta: %s" % ("sì" if tip.strip_edges().length() > 3 else "NO"))
	cp.cat = 0
	cp.refresh()
	await kit.seconds(1.0)
	await kit.save("55_creare")
	cp.cat = 1
	cp._search.text = "bastone"
	cp.refresh()
	await kit.frames(3)
	print("Creare, Armi con la ricerca «bastone»: %d righe" % cp.shown_rows())
	await kit.seconds(0.5)
	await kit.save("56_creare_armi")
	cp._search.text = ""
	cp.cat = 0
	cp.refresh()
	# la scheda del Germogliato
	var ex: ExaminePanel = m.hud.panel.examine
	ex.refresh()
	print("scheda del Germogliato nella casella vuota: %s" % ("sì" if ex._text.text.contains("Scorza") else "NO"))
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
