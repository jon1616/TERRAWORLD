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
	var kit := TestKit.new(self, main)
	if "--prova-portale" in OS.get_cmdline_user_args():
		await TestsPortalTrip.new(kit).run()
		return
	var w := TestsWorld.new(kit)
	var p := TestsPlayer.new(kit)
	var c := TestsCombat.new(kit)
	var st := TestsStrata.new(kit)
	var gd := TestsGuardian.new(kit)
	var dn := TestsDay.new(kit)
	var rv := TestsRuins.new(kit)
	var mp := TestsMap.new(kit)
	var bi := TestsBiomes.new(kit)
	var eb := TestsErbario.new(kit)
	await w.places()
	await p.trees()
	await p.crafting()
	await p.vitals()
	await p.movement()
	await c.run()
	await st.run()
	await gd.run()
	await dn.run()
	await rv.run()
	await bi.run()
	await mp.run()
	await eb.run()
	await w.run_and_save()
	# la Bisaccia aperta
	main.hud.panel.toggle()
	await kit.frames(12)
	await kit.save("07_bisaccia")
	main.hud.panel.toggle()
	get_tree().quit()
