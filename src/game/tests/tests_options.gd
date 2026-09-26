class_name TestsOptions
extends RefCounted
## Prove delle Opzioni e della pausa (27 set 2026): Esc apre il menu di pausa e ferma il mondo; le Opzioni (foto di due
## sezioni); l'ingrandimento cambia la visuale; il chiarore del buio arriva alla luce; «Pausa mentre crei» ferma il
## mondo con la Bisaccia aperta; un tasto cambiato funziona e l'aiuto lo scrive. Foto 121-123.
## Le prove non scrivono mai il file delle impostazioni del giocatore (`Settings.no_save`).

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _esc() -> void:
	var e := InputEventKey.new()
	e.keycode = KEY_ESCAPE
	e.pressed = true
	Input.parse_input_event(e)
	var u := InputEventKey.new()
	u.keycode = KEY_ESCAPE
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
	if m.get_tree().paused:
		print("ATTENZIONE: il mondo è rimasto in pausa")
