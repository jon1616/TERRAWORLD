class_name TestsLanguage
extends RefCounted
## Prove della lingua dei Seminatori (voce 68): il mondo ha le stele (quasi tutte indicano un luogo); leggerne una
## insegna una parola; una tavoletta ne insegna tre; capita tutta la frase, il luogo si segna sulla mappa.
## Foto 127_stele e 128_segno_sulla_mappa.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var lg: Language = m.language
	var had: Dictionary = m.character.lingua.duplicate()
	m.character.lingua.clear()
	var all := 0
	var hinted := 0
	var target := Vector2i(-1, -1)
	for o in world.stations:
		if String(world.stations[o]) == "stele":
			all += 1
			var e: Dictionary = lg.stele().get(Language._key(o), {})
			if not (e.get("hint", []) as Array).is_empty():
				hinted += 1
				if target.x < 0:
					target = o
	if target.x < 0:
		print("ATTENZIONE: nessuna stele che indica un luogo nel mondo di prova (%d stele)" % all)
		m.character.lingua = had
		return
	var e: Dictionary = lg.stele()[Language._key(target)]
	# la prima lettura: una parola dal contesto
	var read := lg.read(target)
	var after_read := lg.count()
	await kit.frames(4)
	await kit.save("127_stele")
	lg.panel.visible = false
	# una tavoletta: tre parole
	var b := kit.bisaccia()
	b.add("tavoletta_seminatori", 1)
	var used := lg.use_tablet("tavoletta_seminatori")
	var after_tab := lg.count()
	# tutta la frase: il luogo sulla mappa
	lg.learn(e["words"])
	var marks0: int = (m.world_meta["segni"] as Array).size()
	lg.read(target)
	lg.panel.visible = false
	var marks1: int = (m.world_meta["segni"] as Array).size()
	m.hud.map.toggle()
	await kit.frames(4)
	await kit.save("128_segno_sulla_mappa")
	m.hud.map.toggle()
	print("lingua: %d stele nel mondo (%d indicano un luogo); lettura %s, parole %d → dopo la tavoletta %d (%s); frase «%s» capita: segni %d → %d" % [
		all, hinted, "sì" if read else "NO", after_read, after_tab, "usata" if used else "NON usata",
		Language.line_sem(e["words"]), marks0, marks1])
	if all < 3 or not read or after_read < 1 or after_tab != after_read + LanguageData.TABLET_WORDS or marks1 != marks0 + 1:
		print("ATTENZIONE: la lingua dei Seminatori non funziona come dovrebbe")
	m.character.lingua = had
