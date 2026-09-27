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
	main.blight.paused = true
	main.hazards.paused = true
	main.events.paused = true              # niente eventi a caso sotto le misure
	main.villagers.paused = true           # gli abitanti arrivano solo quando lo chiede la prova             # l'Avvizzimento non si allarga sotto le misure delle altre prove
	# 28 set 2026: uno script delle prove che non compila fermava il giro senza chiuderlo (fino al tempo massimo):
	# si controllano tutti prima di cominciare, e se uno è rotto si esce subito dicendo quale
	var broken := _broken_scripts()
	if not broken.is_empty():
		print("ATTENZIONE: prove che non si compilano, giro fermato: %s" % [broken])
		get_tree().quit(1)
		return
	var kit := TestKit.new(self, main)
	if "--prova-portale" in OS.get_cmdline_user_args():
		await TestsPortalTrip.new(kit).run()
		return
	if "--prova-giardino" in OS.get_cmdline_user_args():
		await TestsHome.new(kit).run()             # Roadmap 8: il Giardino vero, l'Albero-Madre e ciò che ne nasce
		get_tree().quit()
		return
	# `--solo=doni,antiche`: solo alcuni gruppi di prove (per provare in fretta una voce nuova)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--solo="):
			for g in arg.trim_prefix("--solo=").split(","):
				await _group(kit, g)
			get_tree().quit()
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
	var hz := TestsHazards.new(kit)
	_mark("inizio")
	await w.places()
	_mark("w.places")
	await p.trees()
	_mark("p.trees")
	await p.crafting()
	_mark("p.crafting")
	await p.vitals()
	_mark("p.vitals")
	await p.movement()
	_mark("p.movement")
	await c.run()
	_mark("c.run")
	await st.run()
	_mark("st.run")
	await gd.run()
	_mark("gd.run")
	await gs.run()
	_mark("gs.run")
	await dn.run()
	_mark("dn.run")
	await rv.run()
	_mark("rv.run")
	await bi.run()
	_mark("bi.run")
	await mp.run()
	_mark("mp.run")
	await eb.run()
	_mark("eb.run")
	await tt.run()
	_mark("tt.run")
	await bl.run()
	_mark("bl.run")
	await an.run()
	_mark("an.run")
	await hz.run()
	_mark("hz.run")
	await TestsGifts.new(kit).run()
	_mark("TestsGifts")
	await TestsBestiary.new(kit).run()
	_mark("TestsBestiary")
	await TestsRarity.new(kit).run()
	_mark("TestsRarity")
	await TestsGems.new(kit).run()
	_mark("TestsGems")
	await TestsWorkshop.new(kit).run()
	_mark("TestsWorkshop")
	await TestsSets.new(kit).run()
	_mark("TestsSets")
	await TestsKeepers.new(kit).run()
	_mark("TestsKeepers")
	await TestsRelics.new(kit).run()
	_mark("TestsRelics")
	await TestsInterface.new(kit).run()
	_mark("TestsInterface")
	await TestsClicks.new(kit).run()
	_mark("TestsClicks")
	await TestsTorch.new(kit).run()
	_mark("TestsTorch")
	await TestsMobility.new(kit).run()
	_mark("TestsMobility")
	await TestsThrowing.new(kit).run()
	_mark("TestsThrowing")
	await TestsGarden.new(kit).run()
	_mark("TestsGarden")
	await TestsEvents.new(kit).run()
	_mark("TestsEvents")
	await TestsBuilding.new(kit).run()
	_mark("TestsBuilding")
	await TestsVillagers.new(kit).run()
	_mark("TestsVillagers")
	await TestsCompanions.new(kit).run()
	_mark("TestsCompanions")
	await TestsTravel.new(kit).run()
	_mark("TestsTravel")
	await TestsSeeds.new(kit).run()
	_mark("TestsSeeds")
	await TestsNewBiomes.new(kit).run()
	_mark("TestsNewBiomes")
	await TestsBagCost.new(kit).run()
	_mark("TestsBagCost")
	await TestsMusic.new(kit).run()
	_mark("TestsMusic")
	await TestsHero.new(kit).run()
	_mark("TestsHero")
	await TestsGenes.new(kit).run()
	_mark("TestsGenes")
	await TestsForms.new(kit).run()
	_mark("TestsForms")
	await TestsEcology.new(kit).run()
	_mark("TestsEcology")
	await TestsHerd.new(kit).run()
	_mark("TestsHerd")
	await TestsStorage.new(kit).run()
	_mark("TestsStorage")
	await TestsTrees.new(kit).run()
	_mark("TestsTrees")
	await TestsSeals.new(kit).run()
	_mark("TestsSeals")
	await TestsSeasons.new(kit).run()
	_mark("TestsSeasons")
	await TestsTips.new(kit).run()
	_mark("TestsTips")
	await TestsOptions.new(kit).run()
	_mark("TestsOptions")
	await TestsEncy.new(kit).run()
	_mark("TestsEncy")
	await TestsLanguage.new(kit).run()
	_mark("TestsLanguage")
	await TestsChains.new(kit).run()
	_mark("TestsChains")
	await TestsPlaces.new(kit).run()
	_mark("TestsPlaces")
	await TestsEnigmas.new(kit).run()
	_mark("TestsEnigmas")
	await TestsNero.new(kit).run()
	_mark("TestsNero")
	await TestsWater.new(kit).run()
	_mark("TestsWater")
	await TestsLiquids.new(kit).run()
	_mark("TestsLiquids")
	await TestsWeather.new(kit).run()
	_mark("TestsWeather")
	await TestsGravity.new(kit).run()
	_mark("TestsGravity")
	await TestsLiving.new(kit).run()
	_mark("TestsLiving")
	await TestsWorldTime.new(kit).run()
	_mark("TestsWorldTime")
	await TestsVigor.new(kit).run()
	_mark("TestsVigor")
	await TestsGuardianGen.new(kit).run()
	_mark("TestsGuardianGen")
	await TestsLegends.new(kit).run()
	_mark("TestsLegends")
	await TestsChallenges.new(kit).run()
	_mark("TestsChallenges")
	await TestsDiary.new(kit).run()
	_mark("TestsDiary")
	await TestsSummons.new(kit).run()
	_mark("TestsSummons")
	await ob.run()
	_mark("ob.run")
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
	await kit.hover(slot.get_global_rect().get_center())
	await kit.seconds(1.5)
	await kit.save("39_suggerimento")
	main.hud.panel.toggle()
	var heard: Dictionary = main.sfx.played
	var silent := SoundsData.SOUNDS.keys().filter(func(k: String) -> bool: return not heard.has(k))
	print("suoni suonati durante le prove: %d tipi su %d; mai sentiti: %s" % [heard.size(), SoundsData.SOUNDS.size(), silent])
	_mark("salvataggio, Bisaccia e finale")
	_report_times()
	get_tree().quit()


## Un gruppo di prove per nome (per `--solo=`).
func _broken_scripts() -> Array:
	var out := []
	for f in DirAccess.get_files_at("res://src/game/tests"):
		if f.ends_with(".gd"):
			var sc: Script = load("res://src/game/tests/" + f)
			if sc == null or not sc.can_instantiate():
				out.append(f)
	return out


## I tempi del giro lungo (28 set 2026: era arrivato a 9 minuti): quanto dura ogni gruppo, e alla fine i più lenti.
var _times: Array = []
var _last := 0


func _mark(name: String) -> void:
	var now := Time.get_ticks_msec()
	if _last > 0:
		_times.append([name, now - _last])
	_last = now


func _report_times() -> void:
	_times.sort_custom(func(a: Array, b: Array) -> bool: return int(a[1]) > int(b[1]))
	var tot := 0
	for t in _times:
		tot += int(t[1])
	var top := []
	for t in _times.slice(0, 25):
		top.append("%s %.1f s" % [t[0], int(t[1]) / 1000.0])
	print("tempi del giro: %.0f s nei gruppi; i più lenti: %s" % [tot / 1000.0, ", ".join(top)])


func _group(kit: TestKit, g: String) -> void:
	match g:
		"doni":
			await TestsGifts.new(kit).run()
		"bestiario":
			await TestsBestiary.new(kit).run()
		"rarita":
			await TestsRarity.new(kit).run()
		"gemme":
			await TestsGems.new(kit).run()
		"banchi":
			await TestsWorkshop.new(kit).run()
		"set":
			await TestsSets.new(kit).run()
		"custodi":
			await TestsKeepers.new(kit).run()
		"reliquie":
			await TestsRelics.new(kit).run()
		"interfaccia":
			await TestsInterface.new(kit).run()
		"torcia":
			await TestsTorch.new(kit).run()
		"mobilita":
			await TestsMobility.new(kit).run()
		"lanci":
			await TestsThrowing.new(kit).run()
		"giardino":
			await TestsGarden.new(kit).run()
		"eventi":
			await TestsEvents.new(kit).run()
		"biomi":
			await TestsBiomes.new(kit).run()
		"luoghi":
			await TestsWorld.new(kit).places()
		"germogliato":
			await TestsHero.new(kit).run()
		"musica":
			await TestsMusic.new(kit).run()
		"raccolta":
			await TestsBagCost.new(kit).run()
		"corsa":
			await TestsWorld.new(kit).run_and_save()
		"clic":
			await TestsClicks.new(kit).run()
		"diario":
			await TestsDiary.new(kit).run()
		"evocazioni":
			await TestsSummons.new(kit).run()
		"base":
			# 28 set 2026: il cuore del gioco in ~2 minuti (il giro intero ne dura 8-9): mondo, alberi, creazione,
			# Vita, movimento a 60 e 144 fotogrammi, combattimento, corsa, salvataggio e ricarica
			var wb := TestsWorld.new(kit)
			var pb := TestsPlayer.new(kit)
			await wb.places()
			await pb.trees()
			await pb.crafting()
			await pb.vitals()
			await pb.movement()
			await TestsCombat.new(kit).run()
			await TestsClicks.new(kit).run()
			await wb.run_and_save()
		"casa":
			await TestsBuilding.new(kit).run()
		"abitanti":
			await TestsVillagers.new(kit).run()
		"compagni":
			await TestsCompanions.new(kit).run()
		"viaggio":
			await TestsTravel.new(kit).run()
		"semi":
			await TestsSeeds.new(kit).run()
		"biomi_nuovi":
			await TestsNewBiomes.new(kit).run()
		"antiche":
			await TestsAncient.new(kit).run()
		"pericoli":
			await TestsHazards.new(kit).run()
		"combattimento":
			await TestsCombat.new(kit).run()
		"tratti":
			await TestsTraits.new(kit).run()
		"obiettivi":
			await TestsObjectives.new(kit).run()
		"guardiani":
			await TestsGuardians.new(kit).run()
		"rovine":
			await TestsRuins.new(kit).run()
		"geni":
			await TestsGenes.new(kit).run()
		"forme":
			await TestsForms.new(kit).run()
		"ecologia":
			await TestsEcology.new(kit).run()
		"mandria":
			await TestsHerd.new(kit).run()
		"casse":
			await TestsStorage.new(kit).run()
		"alberi":
			await TestsTrees.new(kit).run()
		"sigilli":
			await TestsSeals.new(kit).run()
		"stagioni":
			await TestsSeasons.new(kit).run()
		"suggerimenti":
			await TestsTips.new(kit).run()
		"opzioni":
			await TestsOptions.new(kit).run()
		"enciclopedia":
			await TestsEncy.new(kit).run()
		"lingua":
			await TestsLanguage.new(kit).run()
		"catene":
			await TestsChains.new(kit).run()
		"luoghi_scritti":
			await TestsPlaces.new(kit).run()
		"enigmi":
			await TestsEnigmas.new(kit).run()
		"seme_nero":
			await TestsNero.new(kit).run()
		"acqua":
			await TestsWater.new(kit).run()
		"liquidi":
			await TestsLiquids.new(kit).run()
		"meteo":
			await TestsWeather.new(kit).run()
		"gravita":
			await TestsGravity.new(kit).run()
		"terra_viva":
			await TestsLiving.new(kit).run()
		"tempo_mondi":
			await TestsWorldTime.new(kit).run()
		"vigore":
			await TestsVigor.new(kit).run()
		"guardiani_generati":
			await TestsGuardianGen.new(kit).run()
		"leggende":
			await TestsLegends.new(kit).run()
		"sfide":
			await TestsChallenges.new(kit).run()
		_:
			print("ATTENZIONE: gruppo di prove sconosciuto «%s»" % g)
