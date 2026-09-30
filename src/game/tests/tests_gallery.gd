class_name TestsGallery
extends RefCounted
## La galleria (voce 268): apre ogni pannello del gioco, lo fotografa in prove/galleria/ e controlla l'impaginazione con
## `LayoutCheck` (tagli, fuori schermo, fuori riquadro, testi sovrapposti). I problemi vanno in prove/galleria/problemi.txt
## e il riassunto nel registro. Serve a confrontare prima e dopo ogni voce della Roadmap 29. Gruppo «galleria».

var kit: TestKit
var m: Node2D
var report: Array[String] = []
var total := 0


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prove/galleria"))
	await kit.seconds(0.3)
	await _shot("00_hud")
	# la Bisaccia (con Creare ed Esamina) e la mappa
	m.hud.panel.toggle()
	await _shot("01_bisaccia", [m.hud.panel])
	var b: Bisaccia = m.character.bisaccia
	var first := -1
	for i in b.slots.size():
		if not b.slots[i].is_empty():
			first = i
			break
	if first >= 0:
		Tips.show_at(ItemTip.card(b.slots[first]), Vector2(700, 300))
		await _shot("02_suggerimento_oggetto", [m.get_tree().root.get_node("TipsLayer")])
		Tips.unpin()
	m.hud.panel.toggle()
	if m.hud.map != null:
		m.hud.map.toggle()
		await _shot("03_mappa", [m.hud.map])
		m.hud.map.toggle()
	# una cassa piena
	var o: Vector2i = kit.world.spawn + Vector2i(3, -1)
	kit.world.stations[o] = "forziere_ambra"
	m.view.add_station(o)
	var ch: Bisaccia = kit.world.chest_at(o)
	ch.add("legno", 30)
	ch.add("torcia", 12)
	m.interact.chest_panel.open(o, ch, "Forziere d'ambra")
	await _shot("04_cassa", [m.hud.panel, m.interact.chest_panel])
	m.interact.chest_panel.close()
	if m.hud.panel.visible:
		m.hud.panel.toggle()
	kit.world.stations.erase(o)
	kit.world.chests.erase(o)
	m.view.remove_station(o)
	# il commercio
	var tp: TradePanel = m.villagers.panel
	if tp != null:
		tp.m = m
		tp.open("viandante")
		await _shot("05_commercio", [m.hud.panel, tp])
		tp.close()
		if m.hud.panel.visible:
			m.hud.panel.toggle()
	# tutti i pannelli a tutto schermo
	var k := 10
	for ov in m.hud.overlays:
		if not is_instance_valid(ov):
			continue
		if not _call_any(ov, ["toggle", "open", "open_panel", "open_menu"]):
			report.append("(non so aprire %s)" % _cls(ov))
			continue
		await kit.frames(3)
		if not (ov as CanvasItem).is_visible_in_tree():
			report.append("(%s non si è aperto senza argomenti)" % _cls(ov))
			continue
		await _shot("%02d_%s" % [k, _cls(ov).to_snake_case()], [ov])
		k += 1
		_call_any(ov, ["close", "close_panel", "close_menu", "toggle"])
		await kit.frames(2)
		if (ov as CanvasItem).visible:
			(ov as CanvasItem).visible = false
	var f := FileAccess.open(ProjectSettings.globalize_path("res://prove/galleria/problemi.txt"), FileAccess.WRITE)
	f.store_string("\n".join(report))
	f.close()
	print("galleria: %d foto, %d problemi d'impaginazione (prove/galleria/problemi.txt)" % [k, total])


## `roots`: che cosa controllare (il pannello aperto); vuoto = l'interfaccia di gioco.
func _shot(name: String, roots: Array = []) -> void:
	await kit.frames(4)
	var probs := LayoutCheck.scan(roots if not roots.is_empty() else [m.hud])
	total += probs.size()
	report.append("== %s: %d problemi" % [name, probs.size()])
	for p in probs:
		report.append("   " + p)
	var img: Image = await Photo.take(m.get_viewport())
	img.save_png(ProjectSettings.globalize_path("res://prove/galleria/%s.png" % name))


## Chiama il primo metodo che l'oggetto ha e che si può chiamare senza argomenti.
func _call_any(o: Object, names: Array) -> bool:
	for n in names:
		if not o.has_method(n):
			continue
		for md in o.get_method_list():
			if String(md["name"]) == n and (md["args"] as Array).size() - (md["default_args"] as Array).size() == 0:
				o.call(n)
				return true
	return false


func _cls(o: Object) -> String:
	var s: Script = o.get_script()
	return s.get_global_name() if s != null and s.get_global_name() != "" else o.get_class()
