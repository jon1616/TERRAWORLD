class_name TestsLanguage
extends RefCounted
## La lingua dei Seminatori (voce 68, rifatta nella Roadmap 17: si decifra). Gruppo «lingua»: leggere le stele fa
## vedere le parole e, dopo abbastanza frasi, nascono le ipotesi (voce 170-171); un significato sbagliato si scarta e
## blocca finché non si vede una frase nuova, e scartati tutti gli altri la parola è dedotta; una tavoletta conferma due
## parole viste; una stele di luogo con tutte ipotesi segna «forse» e arrivando al luogo le parole diventano certe.
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
	var had: Dictionary = m.character.lingua.duplicate(true)
	m.character.lingua.clear()
	# tutte le stele del mondo, lette una volta
	var all := []
	var target := Vector2i(-1, -1)
	for o in world.stations:
		if String(world.stations[o]) == "stele":
			all.append(o)
			var e: Dictionary = lg.stele().get(Language._key(o), {})
			if target.x < 0 and not (e.get("hint", []) as Array).is_empty():
				target = o
	if all.size() < 3 or target.x < 0:
		print("ATTENZIONE: troppo poche stele nel mondo di prova (%d), o nessuna che indica un luogo" % all.size())
		m.character.lingua = had
		return
	var first: bool = lg.read(all[0])
	await kit.frames(4)
	await kit.save("127_stele")
	lg.panel.visible = false
	var certe0 := lg.count()
	for o in all:
		lg.read(o)
		lg.panel.visible = false
	var t := lg.tally("comune")
	# un'ipotesi: sbagliata, bloccata, poi (frase nuova) sbagliata di nuovo → dedotta
	var hyp := ""
	for w in m.character.lingua:
		if lg.state(String(w)) == Language.IPOTESI:
			hyp = String(w)
			break
	var steps := []
	if hyp != "":
		var wrong: Array = lg.options_left(hyp).filter(func(o: String) -> bool: return o != hyp)
		steps.append(lg.guess(hyp, String(wrong[0])))
		steps.append(lg.guess(hyp, String(wrong[1])))             # bloccata: serve una frase nuova
		lg.see([hyp], "prova:frase_nuova")
		steps.append(lg.guess(hyp, String(wrong[1])))             # l'ultimo sbagliato: resta quello giusto
		steps.append(str(lg.state(hyp)))
	# la tavoletta conferma due parole viste
	var c0 := lg.count()
	var b := kit.bisaccia()
	b.add("tavoletta_seminatori", 1)
	var used := lg.use_tablet("tavoletta_seminatori")
	var tab := lg.count() - c0
	# la stele del luogo: tutte ipotesi → «forse»; arrivando → certe
	var e: Dictionary = lg.stele()[Language._key(target)]
	for w in e["words"]:
		if lg.state(String(w)) != Language.CERTA:
			var r: Dictionary = m.character.lingua.get(String(w), {"s": 0, "f": [], "x": []})
			r["s"] = Language.IPOTESI
			m.character.lingua[String(w)] = r
	e.erase("forse")
	e.erase("segnata")
	lg.read(target)
	lg.panel.visible = false
	var hint: Array = e["hint"]
	var maybe := false
	for s in m.world_meta["segni"]:
		if int(s[0]) == int(hint[0]) and int(s[1]) == int(hint[1]) and String(s[2]).begins_with("forse"):
			maybe = true
	m.snap_to(Vector2i(int(hint[0]), int(hint[1])))
	await kit.seconds(1.5)
	var sure: bool = lg.understood(e) == (e["words"] as Array).size() and bool(e.get("segnata", false))
	m.hud.map.toggle()
	await kit.frames(4)
	await kit.save("128_segno_sulla_mappa")
	m.hud.map.toggle()
	m.snap_to(world.spawn)
	print("lingua: %d stele; la prima lettura regala parole %d (0 atteso); lette tutte: certe %d, ipotesi %d, viste %d su %d; ipotesi «%s»: %s; tavoletta %s (+%d certe); luogo «forse» %s, arrivato e confermato %s" % [
		all.size(), certe0, t[0], t[1], t[2], t[3], LanguageData.sem(hyp) if hyp != "" else "-", steps, used, tab, maybe, sure])
	if not first or certe0 != 0 or t[1] < 3 or hyp == "" or steps != ["sbagliato", "", "dedotto", "2"] or tab != LanguageData.TABLET_WORDS \
			or not maybe or not sure:
		print("ATTENZIONE: la lingua dei Seminatori non funziona come dovrebbe")
	m.character.lingua = had
	lg._sync_stat()
	await lexicon()


## Voce 172: il Quaderno si apre con il suo tasto, mostra lo strato e una parola scelta; «È questo?» giusto la conferma.
func lexicon() -> void:
	var lg: Language = m.language
	var had: Dictionary = m.character.lingua.duplicate(true)
	m.character.lingua.clear()
	for o in world.stations:
		if String(world.stations[o]) == "stele":
			lg.read(o)
			lg.panel.visible = false
	var hyp := ""
	for w in m.character.lingua:
		if lg.state(String(w)) == Language.IPOTESI:
			hyp = String(w)
			break
	var lx: LexiconPanel = m.lexicon
	var ev := InputEventKey.new()
	ev.keycode = int(Settings.keys_of("quaderno")[0])
	ev.pressed = true
	lx._unhandled_input(ev)
	lx.selected = hyp
	lx._dirty = true
	await kit.frames(4)
	var opened := lx.visible
	var buttons := lx._opts.get_child_count()
	await kit.save("221_quaderno")
	var right := false
	for b in lx._opts.get_children():
		if (b as Button).text == "«%s»?" % LanguageData.it(hyp):
			(b as Button).pressed.emit()
			right = true
	await kit.frames(2)
	var certa := lg.state(hyp) == Language.CERTA
	lx.toggle()
	print("Quaderno: aperto con il tasto %s, parola «%s» con %d significati da provare, quello giusto la conferma %s" % [opened, LanguageData.sem(hyp), buttons, certa])
	if not opened or buttons != LanguageData.HYP_OPTIONS or not right or not certa:
		print("ATTENZIONE: il Quaderno delle parole non va come dovrebbe")
	m.character.lingua = had
	lg._sync_stat()
