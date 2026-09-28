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


## I mondi della voce 173: uno di vigore 5 (la lingua antica) e quello del Seme Nero (la lingua nera).
static func jobs() -> Array:
	return [[7617, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 5}],
		[7618, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 3, "nero": true, "geni": ["cuore_nero"]}]]


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
	await layers()
	await word_chest()
	engraving()


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


## Voce 173: ogni parola antica e nera compare in una frase; un mondo di vigore 5 ha stele antiche, quello del Seme Nero
## stele nere; l'iscrizione di una cripta si capisce solo con tutte le parole certe, e allora dà il dono una volta.
func layers() -> void:
	var missing := []
	for l in ["antica", "nera"]:
		var pool: Array = LanguageData.LORE_ANCIENT if l == "antica" else LanguageData.LORE_BLACK
		for w in LanguageData.words_of(l):
			if not pool.any(func(f: Array) -> bool: return w in f):
				missing.append(w)
	var ws: Array[World] = await kit.gen_many(jobs())
	var counts := []
	for w in ws:
		var n := {"comune": 0, "antica": 0, "nera": 0}
		var st: Dictionary = w.gen_notes.get("stele", {})
		for k in st:
			var lay := "comune"
			for wd in st[k]["words"]:
				if LanguageData.layer_of(String(wd)) != "comune":
					lay = LanguageData.layer_of(String(wd))
			n[lay] += 1
		counts.append(n)
	# l'iscrizione della prima tappa
	var ch: Chains = m.chains
	var had: Dictionary = m.character.lingua.duplicate(true)
	var had_c: Dictionary = m.character.catene.duplicate(true)
	m.character.lingua.clear()
	var before: String = ch.inscription(0)
	var words: Array = LanguageData.LORE_BLACK[int(LanguageData.CRYPT_TRUTH[0][0])]
	m.language.confirm(words)
	var li0 := kit.bisaccia().count("linfa_antica")
	var after: String = ch.inscription(0)
	var gift := kit.bisaccia().count("linfa_antica") - li0
	var again := ch.inscription(0)
	var gift2 := kit.bisaccia().count("linfa_antica") - li0
	var truth := String(LanguageData.CRYPT_TRUTH[0][1])
	print("strati: parole senza frase %s; stele del mondo di vigore 5 %s, del mondo del Seme Nero %s; iscrizione: prima nascosta %s, poi capita %s, dono %d (una volta: %s)" % [
		missing, counts[0], counts[1], not truth in before, truth in after, gift, gift2 == gift])
	if not missing.is_empty() or int(counts[0]["antica"]) < 10 or int(counts[1]["nera"]) < 10 or truth in before or not truth in after 			or gift < 1 or gift2 != gift:
		print("ATTENZIONE: gli strati della lingua non vanno come dovrebbero")
	m.character.lingua = had
	m.character.catene = had_c
	m.language._sync_stat()


## Voce 174: gli scrigni a parola: ce ne sono; la ruota dei glifi offre parole della classe giusta; una sbagliata chiude
## il sigillo, la giusta lo apre (scrigno normale, bottino in più, la parola certa).
func word_chest() -> void:
	var wc: WordChests = m.word_chests
	var seals: Dictionary = wc.all()
	var n := seals.size()
	if n == 0:
		print("ATTENZIONE: nessuno scrigno a parola nel mondo di prova")
		return
	var lg: Language = m.language
	var had: Dictionary = m.character.lingua.duplicate(true)
	m.character.lingua.clear()
	var k := String(seals.keys()[0])
	var o := Vector2i(int(k.get_slice(",", 0)), int(k.get_slice(",", 1)))
	var e: Dictionary = seals[k]
	var gap := String(e["words"][int(e["gap"])])
	m.snap_to(o + Vector2i(-2, 1))
	await kit.frames(3)
	for so in world.stations:
		if String(world.stations[so]) == "stele":
			lg.read(so)
			lg.panel.visible = false
	var touched: bool = wc.touch(o)
	await kit.frames(4)
	await kit.save("222_scrigno_parola")
	wc.panel.visible = false
	var ch: Array = wc.choices(e)
	var same_class := ch.all(func(w: String) -> bool: return LanguageData.class_of(w) == LanguageData.class_of(gap))
	var wrong := ""
	for w in ch:
		if String(w) != gap:
			wrong = String(w)
			break
	var no: bool = wrong != "" and not wc.answer(o, wrong)
	var locked: bool = not wc.touch(o) or wc.panel.visible == false
	wc.panel.visible = false
	e["lock"] = 0.0
	var items0: int = world.chest_at(o).slots.filter(func(s: Dictionary) -> bool: return not s.is_empty()).size()
	var yes: bool = wc.answer(o, gap)
	m.interact.chest_panel.close()
	var items1: int = world.chest_at(o).slots.filter(func(s: Dictionary) -> bool: return not s.is_empty()).size()
	print("scrigni a parola: %d nel mondo; ruota %s, %d parole tutte della classe giusta %s; sbagliata «%s» chiude %s; giusta «%s» apre %s (%s, oggetti %d → %d, parola certa %s)" % [
		n, touched, ch.size(), same_class, LanguageData.sem(wrong), no, LanguageData.sem(gap), yes, world.stations.get(o, ""), items0, items1,
		lg.known(gap)])
	if n < 2 or not touched or not same_class or not gap in ch or not no or not yes or String(world.stations.get(o, "")) != "scrigno" 			or items1 <= items0 or not lg.known(gap):
		print("ATTENZIONE: gli scrigni a parola non vanno come dovrebbero")
	m.character.lingua = had
	lg._sync_stat()
	m.snap_to(world.spawn)


## Voce 175: incidere «brace» su una spada: il danno sale, i posti d'innesto restano; «radice» (delle armature) no.
func engraving() -> void:
	var b := kit.bisaccia()
	kit.make_room()
	var i := Bisaccia.HOTBAR + 2
	b.slots[i] = {"id": "spada_ambra", "n": 1, "dati": {"q": 1}}
	b.add("polvere_brace", 10)
	var free0 := Gear.free_slots(b.slots[i])
	var d0 := float(Gear.stats(b.slots[i])["damage"])
	var ok := Crafting.engrave(b, i, "brace")
	var d1 := float(Gear.stats(b.slots[i])["damage"])
	var free1 := Gear.free_slots(b.slots[i])
	var no_armor := not Crafting.engrave(b, i, "radice")          # «radice» è per le armature
	print("incisione «brace» sulla spada d'ambra: fatta %s, danno %.1f → %.1f, posti liberi %d → %d, «radice» su una spada no %s; nome «%s»" % [
		ok, d0, d1, free0, free1, no_armor, Gear.full_name(b.slots[i])])
	if not ok or d1 <= d0 or free1 != free0 or not no_armor:
		print("ATTENZIONE: le incisioni non vanno come dovrebbero")
	b.slots[i] = {}
	b.changed.emit()
