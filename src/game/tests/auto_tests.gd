class_name AutoTests
extends Node
## Prove automatiche con finestra (`-- --prove`): porta il giocatore in punti significativi del mondo, prova ogni parte
## del gioco, salva foto in prove/ e stampa i risultati. I moduli di prove stanno in `src/game/tests/`.


func run(main: Node2D) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prove"))
	main.player.control = false
	main.actions.enabled = false
	main.fauna.enabled = false            # le creature a caso disturberebbero le misure
	main.fauna.clear()
	main.day.paused = true                # mezzogiorno fisso: le foto restano confrontabili
	main.day.time = 0.5
	main.day.apply(true)
	main.objectives.paused = true
	main.blight.paused = true             # l'Avvizzimento non si allarga sotto le misure delle altre prove
	var kit := TestKit.new(self, main)
	if "--prova-portale" in OS.get_cmdline_user_args():
		await TestsPortalTrip.new(kit).run()
		return
	var w := TestsWorld.new(kit)
	var p := TestsPlayer.new(kit)
	var c := TestsCombat.new(kit)
	var st := TestsStrata.new(kit)
	var gd := TestsGuardian.new(kit)
	var gs := TestsGuardians.new(kit)
	var dn := TestsDay.new(kit)
	var rv := TestsRuins.new(kit)
	var mp := TestsMap.new(kit)
	var bi := TestsBiomes.new(kit)
	var eb := TestsErbario.new(kit)
	var tt := TestsTraits.new(kit)
	var ob := TestsObjectives.new(kit)
	var bl := TestsBlight.new(kit)
	var an := TestsAncient.new(kit)
	await w.places()
	await p.trees()
	await p.crafting()
	await p.vitals()
	await p.movement()
	await c.run()
	await st.run()
	await gd.run()
	await gs.run()
	await dn.run()
	await rv.run()
	await bi.run()
	await mp.run()
	await eb.run()
	await tt.run()
	await bl.run()
	await an.run()
	await ob.run()
	await w.run_and_save()
	# la Bisaccia aperta
	main.hud.panel.toggle()
	await kit.frames(12)
	await kit.save("07_bisaccia")
	# la casella «Esamina»: si posa un oggetto e compare a cosa serve
	var ex: ExaminePanel = main.hud.panel.examine
	main.hud.panel.held = {"id": "gelatina", "n": 1}
	ex._click(0, MOUSE_BUTTON_LEFT)
	await kit.seconds(5.0)                # dopo il giro lungo le foto arrivano in ritardo
	print("Esamina: gelatina posata %s, ricette che la usano %d" % ["sì" if not ex.held.is_empty() else "NO",
		ItemInfo.uses_of("gelatina").size()])
	await kit.save("40_esamina")

	# un suggerimento: il mouse sopra una casella della barra rapida, poi si aspetta che compaia
	var slot: Control = main.hud._slots[0]
	var at := slot.get_global_rect().get_center()
	get_viewport().warp_mouse(at)
	for k in 3:
		var mv := InputEventMouseMotion.new()
		mv.position = at + Vector2(k, 0)
		mv.global_position = mv.position
		Input.parse_input_event(mv)
		await kit.frames(2)
	await kit.seconds(1.5)
	await kit.save("39_suggerimento")
	main.hud.panel.toggle()
	var heard: Dictionary = main.sfx.played
	var silent := SoundsData.SOUNDS.keys().filter(func(k: String) -> bool: return not heard.has(k))
	print("suoni suonati durante le prove: %d tipi su %d; mai sentiti: %s" % [heard.size(), SoundsData.SOUNDS.size(), silent])
	get_tree().quit()
