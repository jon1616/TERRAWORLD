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
	var kit := TestKit.new(self, main)
	var w := TestsWorld.new(kit)
	var p := TestsPlayer.new(kit)
	var c := TestsCombat.new(kit)
	var st := TestsStrata.new(kit)
	await w.places()
	await p.trees()
	await p.crafting()
	await p.vitals()
	await p.movement()
	await c.run()
	await st.run()
	await w.run_and_save()
	# la Bisaccia aperta
	main.hud.panel.toggle()
	await kit.frames(12)
	await kit.save("07_bisaccia")
	main.hud.panel.toggle()
	get_tree().quit()
