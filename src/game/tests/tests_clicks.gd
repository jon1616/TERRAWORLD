class_name TestsClicks
extends RefCounted
## Clic veri sui menu (28 set 2026, segnalato dall'utente: «i menu non rispondono più ai comandi»). Le altre prove
## chiamano le funzioni dei pulsanti direttamente e non si accorgono se qualcuno si mangia i clic: qui il mouse clicca
## davvero una casella della Bisaccia (la pila va in mano e torna), una ricetta di Creare (compare in Esamina), una
## casella della cassa aperta e il pulsante «Riprendi» del menu di pausa. Fa parte del gruppo «base».

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func _center(c: Control) -> Vector2:
	return c.get_global_rect().get_center()


func run() -> void:
	var w: World = m.world
	var bp: BisacciaPanel = m.hud.panel
	var b: Bisaccia = m.character.bisaccia
	m.snap_to(w.spawn)
	# le prove di prima possono lasciare aperta una pagina di storia o un pannello: coprirebbero i clic
	m.guardian.lore.visible = false
	m.language.panel.visible = false
	for o in m.hud.overlays:
		o.visible = false
	await kit.frames(3)
	# 1. la Bisaccia: un clic prende la pila, un altro la posa
	var free := -1
	for i in range(Bisaccia.HOTBAR, b.slots.size()):
		if b.slots[i].is_empty():
			free = i
			break
	if free >= 0:
		b.slots[free] = {"id": "humus", "n": 7}
		b.changed.emit()
	if not bp.visible:
		bp.toggle()
	await kit.frames(3)
	var from := -1
	for s in bp._slots:
		if b.id_at(s.index) == "humus":
			from = s.index
			break
	var took := false
	var put_back := false
	if from >= 0:
		var sv: SlotView = bp._slots[from - Bisaccia.HOTBAR]
		await kit.click(_center(sv))
		took = not bp.held.is_empty()
		await kit.click(_center(sv))
		put_back = bp.held.is_empty() and b.id_at(from) == "humus"
	# 2. Creare: un clic su una ricetta la mostra in Esamina
	var shown := false
	# (una casella davvero visibile: le prove di prima lasciano una ricerca e l'elenco scorso più in basso)
	bp.crafting._search.text = ""                 # (le prove di prima lasciano una ricerca che nasconde tutto)
	var cat0: int = bp.crafting.cat
	var all0: bool = bp.crafting.all_benches
	var only0: bool = bp.crafting.only_possible
	bp.crafting.cat = 0
	bp.crafting.only_possible = false
	bp.crafting.all_benches = true               # (e senza banchi vicini non ci sarebbero ricette da cliccare)
	bp.crafting.refresh()
	bp.crafting._scroll.scroll_vertical = 0
	await kit.seconds(0.5)                       # le caselle si preparano poche per fotogramma
	var view := bp.crafting._scroll.get_global_rect()
	var tiles := bp.crafting.shown_tiles().filter(func(t: RecipeTile) -> bool: return view.encloses(t.get_global_rect()))
	if not tiles.is_empty():
		await kit.click(_center(tiles[0]))
		shown = bp.examine._card.visible and bp.crafting.selected == tiles[0].r
	else:
		print("ATTENZIONE: nessuna ricetta visibile in Creare per la prova dei clic")
	bp.crafting.cat = cat0
	bp.crafting.all_benches = all0
	bp.crafting.only_possible = only0
	bp.crafting.refresh()
	bp.toggle()
	await kit.frames(2)
	# 3. la cassa: un clic sulla casella con qualcosa dentro la prende in mano
	var o: Vector2i = w.spawn + Vector2i(3, -1)
	w.stations[o] = "cesta"
	m.view.add_station(o)
	w.chest_at(o).add("legno", 5)
	m.interact.touch(o)
	await kit.frames(4)
	var cp: ChestPanel = m.interact.chest_panel
	await kit.click(_center(cp._slots[0]))
	var chest_took := not bp.held.is_empty() and String(bp.held.get("id", "")) == "legno"
	await kit.click(_center(cp._slots[0]))
	cp.close()
	if bp.visible:
		bp.toggle()
	w.stations.erase(o)
	w.chests.erase(o)
	m.view.remove_station(o)
	# 4. il menu di pausa: «Riprendi» lo chiude
	var menu: PauseMenu = m.game_options.menu
	menu.open_menu()
	await kit.frames(4)
	var resume: Button = null
	for c in menu._box.get_children():
		if c is Button and (c as Button).text == "Riprendi":
			resume = c
	var closed := false
	if resume != null:
		await kit.click(_center(resume))
		await kit.frames(3)
		closed = not menu.visible
		if not closed:
			# un secondo tentativo (una volta su tanti il primo clic arrivava prima che il menu fosse pronto); il guasto
			# vero di prima fermava tutti i clic, anche questo
			await kit.seconds(0.3)
			await kit.click(_center(resume))
			await kit.frames(3)
			closed = not menu.visible
		if not closed:
			await kit.hover(_center(resume))
			print("diag Riprendi: sotto il mouse %s, menu in posizione %d su %d" % [m.get_viewport().gui_get_hovered_control(),
				menu.get_index(), menu.get_parent().get_child_count()])
	if menu.visible:
		menu.close_menu()
	if free >= 0 and b.id_at(free) == "humus":
		b.slots[free] = {}
		b.changed.emit()
	print("clic veri: Bisaccia presa %s e posata %s; ricetta in Esamina %s; casella della cassa %s; «Riprendi» del menu %s" % [
		"sì" if took else "NO", "sì" if put_back else "NO", "sì" if shown else "NO", "sì" if chest_took else "NO",
		"sì" if closed else "NO"])
	if not (took and put_back and shown and chest_took and closed):
		print("ATTENZIONE: i menu non rispondono ai clic")
