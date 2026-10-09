class_name TestsOptions
extends RefCounted
## Prove delle Opzioni e della pausa (27 set 2026): Esc apre il menu di pausa e ferma il mondo; le Opzioni (foto di due
## sezioni); l'ingrandimento cambia la visuale; il chiarore del buio arriva alla luce; «Pausa mentre crei» ferma il
## mondo con la Bisaccia aperta; un tasto cambiato funziona e l'aiuto lo scrive; il tasto «osserva» ferma il mondo e
## la scheda di una creatura si legge a gioco fermo (9 ott 2026). Foto 121-124.
## Le prove non scrivono mai il file delle impostazioni del giocatore (`Settings.no_save`).

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _esc() -> void:
	_key(KEY_ESCAPE)


func _key(code: Key) -> void:
	var e := InputEventKey.new()
	e.keycode = code
	e.pressed = true
	Input.parse_input_event(e)
	var u := InputEventKey.new()
	u.keycode = code
	u.pressed = false
	Input.parse_input_event(u)


func run() -> void:
	var go: GameOptions = m.game_options
	# Esc: il menu di pausa, il mondo fermo
	_esc()
	await kit.frames(4)
	var menu_on := go.menu.visible
	var paused := m.get_tree().paused
	await kit.save("121_pausa")
	# le Opzioni dal menu
	go.menu.visible = false
	go.options.open()
	go.options.show_section("video")
	await kit.frames(4)
	await kit.save("122_opzioni_video")
	go.options.show_section("comandi")
	await kit.frames(4)
	await kit.save("123_opzioni_comandi")
	go.options.close_panel()
	go.menu.close_menu()
	await kit.frames(3)
	var resumed := not m.get_tree().paused
	# l'ingrandimento e il chiarore del buio
	Settings.set_v("zoom", 3.0)
	await kit.frames(3)
	var zoom3: float = m.cam.zoom.x
	Settings.set_v("zoom", 2.0)
	Settings.set_v("chiarore", 0.08)
	var fl := LightMap.floor_light
	Settings.set_v("chiarore", 0.0)
	# «Pausa mentre crei»
	Settings.set_v("pausa_bisaccia", true)
	m.hud.panel.toggle()
	await kit.frames(3)
	var craft_pause := m.get_tree().paused
	m.hud.panel.toggle()
	Settings.set_v("pausa_bisaccia", false)
	await kit.frames(3)
	# un tasto cambiato: la Bisaccia con I
	Settings.set_keys("bisaccia", [KEY_I])
	var ev := InputEventKey.new()
	ev.keycode = KEY_I
	ev.pressed = true
	var rebound := Keys.pressed(ev, "bisaccia")
	var help_ok := Keys.help_text().contains("I Bisaccia")
	var old := InputEventKey.new()
	old.keycode = KEY_E
	old.pressed = true
	var old_gone := not Keys.pressed(old, "bisaccia")
	Settings.reset_keys()
	print("opzioni: Esc apre la pausa %s e ferma il mondo %s, riprende %s; zoom 3 → %.1f; chiarore del buio %.2f; pausa mentre crei %s; tasto nuovo %s (aiuto %s, vecchio tolto %s); %d opzioni in %d sezioni, %d comandi" % [
		"sì" if menu_on else "NO", "sì" if paused else "NO", "sì" if resumed else "NO", zoom3, fl,
		"sì" if craft_pause else "NO", "sì" if rebound else "NO", "sì" if help_ok else "NO", "sì" if old_gone else "NO",
		OptionsData.OPTIONS.size(), OptionsData.SECTIONS.size(), KeysData.ACTIONS.size()])
	if not (menu_on and paused and resumed and absf(zoom3 - 3.0) < 0.01 and fl > 0.07 and craft_pause and rebound and old_gone):
		print("ATTENZIONE: le Opzioni non funzionano come dovrebbero")
	await _observe()
	await _menu()
	if m.get_tree().paused:
		print("ATTENZIONE: il mondo è rimasto in pausa")


## Il tasto «osserva»: il mondo si ferma (la creatura non si muove più), la sua scheda compare e resta; di nuovo il
## tasto e si riparte, ed Esc fa lo stesso senza aprire il menu di pausa.
func _observe() -> void:
	var go: GameOptions = m.game_options
	var cr: Creature = m.fauna.add("lepre_linfa", m.player.position + Vector2(70, -8))
	await m.get_tree().create_timer(0.3).timeout
	_key(int(Settings.keys_of("osserva")[0]))
	await kit.frames(4)
	var on := go.observing and m.get_tree().paused
	var p0 := cr.position if is_instance_valid(cr) else Vector2.ZERO
	Tips.mouse_at = m.get_viewport().get_canvas_transform() * p0
	await m.get_tree().create_timer(float(Settings.v("tip_ritardo_mondo")) + 0.8).timeout
	var still := is_instance_valid(cr) and cr.position.distance_to(p0) < 0.5
	var card := Tips.inst != null and Tips.inst.view.visible
	await kit.save("124_osserva")
	Tips.mouse_at = Vector2.INF
	_key(int(Settings.keys_of("osserva")[0]))
	await kit.frames(4)
	var off := not go.observing and not m.get_tree().paused
	_key(int(Settings.keys_of("osserva")[0]))
	await kit.frames(3)
	_esc()
	await kit.frames(4)
	var esc_off := not go.observing and not go.menu.visible and not m.get_tree().paused
	if go.menu.visible:
		go.menu.close_menu()
	if is_instance_valid(cr):
		m.fauna.kill_quietly(cr)
	print("osserva: il mondo si ferma %s, la creatura resta ferma %s, la sua scheda si vede %s, riparte con il tasto %s, con Esc %s" % [
		"sì" if on else "NO", "sì" if still else "NO", "sì" if card else "NO", "sì" if off else "NO", "sì" if esc_off else "NO"])
	if not (on and still and card and off and esc_off):
		print("ATTENZIONE: il tasto «osserva» non funziona come dovrebbe")


## Voce 480: il Menu del Giardiniere si apre con il suo tasto, mostra tutti i pannelli con il loro tasto e lo stato; un
## clic su una scheda chiude il menu e apre il pannello (qui la mappa).
func _menu() -> void:
	var gm: GardenerMenu = null
	for o in m.hud.overlays:
		if o is GardenerMenu:
			gm = o
	if gm == null:
		print("ATTENZIONE: il Menu del Giardiniere non c'è")
		return
	_key(int(Settings.keys_of("menu")[0]))
	await kit.frames(4)
	var shown := gm.visible
	var txt := gm.shown_text()
	var all_keys := true
	for e in GardenerMenu.ENTRIES:
		if not txt.contains(String(e[2])):
			all_keys = false
	await kit.save("125_menu_giardiniere")
	gm.choose("mappa")
	await kit.frames(5)
	var map_on: bool = m.hud.map.visible and not gm.visible
	if m.hud.map.visible:
		m.hud.map.toggle()
	await kit.frames(2)
	print("menu del Giardiniere: si apre %s, %d pannelli tutti scritti %s, stato dell'Erbario «%s», il clic apre la mappa %s" % [
		"sì" if shown else "NO", GardenerMenu.ENTRIES.size(), "sì" if all_keys else "NO", gm._status_of("erbario"),
		"sì" if map_on else "NO"])
	if not (shown and all_keys and map_on):
		print("ATTENZIONE: il Menu del Giardiniere non funziona come dovrebbe")
