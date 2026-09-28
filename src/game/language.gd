class_name Language
extends Node
## La lingua dei Seminatori (voce 68, Roadmap 9; rifatta nella Roadmap 17: **si decifra**). Le parole che il personaggio
## conosce stanno in `Character.lingua` (valgono in tutti i mondi) con il loro **stato**:
##   vista (0)    l'ha vista su una stele, sa com'è scritta;
##   ipotesi (1)  l'ha vista in abbastanza frasi diverse (`LanguageData.LAYERS[strato].hyp`) da avere tre significati
##                possibili (`LanguageData.options`): nel Quaderno si prova quello giusto (`guess`);
##   certa (2)    confermata da un fatto: il significato giusto provato, il luogo indicato da una stele raggiunto, uno
##                scrigno a parola aperto, una tavoletta. Solo le parole certe «si sanno» (`known`).
## Un record: {s: stato, f: [le frasi in cui l'ha vista], x: [i significati scartati], r: 1 se deve vedere una frase
## nuova prima di riprovare}. Le stele di questo mondo in `world_meta["stele"]` (dalla passata `PassStele`); i segni sulla
## mappa in `world_meta["segni"]` (un luogo «forse» quando ogni parola della sua stele è almeno un'ipotesi, pieno quando
## ci si arriva: allora le parole diventano certe). Le tavolette confermano due parole viste. Il Quaderno delle parole
## (`LexiconPanel`) mostra tutto.

const VISTA := 0
const IPOTESI := 1
const CERTA := 2
const ARRIVE := 12.0                     # tessere dal luogo indicato: arrivato
const MAYBE_COLOR := Color("#e0b060")    # il segno «forse» sulla mappa

var m: Node2D
var panel: ReadPanel
var _rng := RandomNumberGenerator.new()
var _t := 0.0
var extra_words := 0                     # voce 142: una biblioteca nel mondo (`Rooms`): la tavoletta conferma di più

signal changed                           # una parola ha cambiato stato (il Quaderno si ridisegna)
signal confirmed(words: Array, how: String)   # parole diventate certe (consigli, obiettivi, prove)


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	if not m.world_meta.has("stele"):
		m.world_meta["stele"] = (m.world.gen_notes.get("stele", {}) as Dictionary).duplicate(true)
	if not m.world_meta.has("segni"):
		m.world_meta["segni"] = []
	# una stele senza frase (piazzata a mano, il Giardino): un pezzo di storia
	for o in m.world.stations:
		if String(m.world.stations[o]) == "stele" and not stele().has(_key(o)):
			stele()[_key(o)] = {"words": (LanguageData.LORE[absi(hash(o)) % LanguageData.LORE.size()] as Array).duplicate(), "hint": []}
	# i personaggi di prima della Roadmap 17: le parole che sapevano sono certe
	var lg: Dictionary = m.character.lingua
	for w in lg.keys():
		if not lg[w] is Dictionary:
			lg[w] = {"s": CERTA, "f": [], "x": []}
	panel = ReadPanel.new()
	m.hud.add_child(panel)
	m.hud.overlays.append(panel)
	_sync_stat()


func stele() -> Dictionary:
	return m.world_meta["stele"]


static func _key(o: Vector2i) -> String:
	return "%d,%d" % [o.x, o.y]


# ---------------------------------------------------------------- lo stato delle parole

func rec(w: String) -> Dictionary:
	return m.character.lingua.get(w, {})


## Lo stato di una parola (-1 = mai vista).
func state(w: String) -> int:
	var r := rec(w)
	return int(r.get("s", -1)) if not r.is_empty() else -1


func known(w: String) -> bool:
	return state(w) == CERTA


## Le parole certe (tutte, o di uno strato).
func count(layer := "") -> int:
	var n := 0
	for w in m.character.lingua:
		if state(String(w)) == CERTA and (layer == "" or LanguageData.layer_of(String(w)) == layer):
			n += 1
	return n


## [certe, ipotesi, viste, in tutto] di uno strato.
func tally(layer: String) -> Array:
	var out := [0, 0, 0, LanguageData.words_of(layer).size()]
	for w in LanguageData.words_of(layer):
		match state(String(w)):
			CERTA:
				out[0] += 1
			IPOTESI:
				out[1] += 1
			VISTA:
				out[2] += 1
	return out


## I significati ancora possibili di un'ipotesi (le parole, non i testi).
func options_left(w: String) -> Array:
	var x: Array = rec(w).get("x", [])
	return LanguageData.options(w).filter(func(o: String) -> bool: return not o in x)


## Le parole di una frase sono state viste in questa frase (`key`, una per stele e mondo): quelle che arrivano alle
## frasi che servono diventano ipotesi. Restituisce le nuove ipotesi.
func see(words: Array, key: String) -> Array:
	var out := []
	var lg: Dictionary = m.character.lingua
	for w0 in words:
		var w := String(w0)
		if not LanguageData.WORDS.has(w):
			continue
		var r: Dictionary = lg.get(w, {"s": VISTA, "f": [], "x": []})
		var f: Array = r.get("f", [])
		if not key in f:
			f.append(key)
			if f.size() > 12:
				f.pop_front()
			r.erase("r")                           # una frase nuova: si può riprovare
		r["f"] = f
		if int(r.get("s", VISTA)) == VISTA and f.size() >= int(LanguageData.LAYERS[LanguageData.layer_of(w)]["hyp"]):
			r["s"] = IPOTESI
			out.append(w)
		lg[w] = r
	_sync_stat()
	changed.emit()
	return out


## Prova un significato di un'ipotesi: giusto → certa; sbagliato → scartato, e serve una frase nuova prima di riprovare.
## Se resta un solo significato possibile, è quello: la parola diventa certa da sé. Restituisce "giusto", "sbagliato",
## "dedotto" (sbagliato, ma ora si sa) o "" (non si può).
func guess(w: String, meaning: String) -> String:
	var r := rec(w)
	if r.is_empty() or int(r["s"]) != IPOTESI or r.has("r") or not meaning in options_left(w):
		return ""
	if meaning == w:
		confirm([w], "prova")
		return "giusto"
	var x: Array = r.get("x", [])
	x.append(meaning)
	r["x"] = x
	r["r"] = 1
	if options_left(w).size() <= 1:
		confirm([w], "deduzione")
		return "dedotto"
	changed.emit()
	return "sbagliato"


## Le parole diventano certe (da qualunque stato). Restituisce quelle nuove.
func confirm(words: Array, how := "") -> Array:
	var out := []
	var lg: Dictionary = m.character.lingua
	for w0 in words:
		var w := String(w0)
		if not LanguageData.WORDS.has(w) or state(w) == CERTA:
			continue
		var r: Dictionary = lg.get(w, {"f": [], "x": []})
		r["s"] = CERTA
		r.erase("r")
		lg[w] = r
		out.append(w)
	if not out.is_empty():
		_sync_stat()
		changed.emit()
		confirmed.emit(out, how)
	return out


## Com'era prima della Roadmap 17 (prove e premi): conferma.
func learn(words: Array) -> Array:
	return confirm(words, "dono")


func _sync_stat() -> void:
	m.character.stats["parole"] = count()
	m.character.stats["parole_antiche"] = count("antica")
	m.character.stats["parole_nere"] = count("nera")


# ---------------------------------------------------------------- le frasi

## La frase nella lingua dei Seminatori.
static func line_sem(words: Array) -> String:
	return " ".join(words.map(func(w: String) -> String: return LanguageData.sem(w)))


## La traduzione, parola per parola, con il colore dello stato: certa in italiano (ambra chiaro), ipotesi nella loro
## lingua con il «?» (arancio), vista nella loro lingua (grigio), mai vista più spenta.
func line_it(words: Array) -> String:
	return "  ".join(words.map(func(w: String) -> String: return word_bb(w)))


func word_bb(w: String) -> String:
	match state(w):
		CERTA:
			return "[color=#ffe8b0]%s[/color]" % LanguageData.it(w)
		IPOTESI:
			return "[color=#e0b060]‹%s›?[/color]" % LanguageData.sem(w)
		VISTA:
			return "[color=#8aa09a]‹%s›[/color]" % LanguageData.sem(w)
	return "[color=#4a5a56]‹%s›[/color]" % LanguageData.sem(w)


func understood(e: Dictionary) -> int:
	return (e["words"] as Array).filter(func(w: String) -> bool: return known(w)).size()


## Tutte le parole della frase sono almeno ipotesi?
func guessed(e: Dictionary) -> bool:
	return (e["words"] as Array).all(func(w: String) -> bool: return state(w) >= IPOTESI)


const LEGEND := "[font_size=13][color=#ffe8b0]certa[/color] · [color=#e0b060]‹ipotesi›?[/color] · [color=#8aa09a]‹vista›[/color]   —   %s: il Quaderno delle parole[/font_size]"


## Clic destro su una stele.
func read(o: Vector2i) -> bool:
	var e: Dictionary = stele().get(_key(o), {})
	if e.is_empty():
		return false
	var first: bool = not e.get("letta", false)
	if first:
		e["letta"] = true
		m.objectives.bump("stele")
	var news := see(e["words"], "%d:%s" % [m.world.world_seed, _key(o)])
	var words: Array = e["words"]
	var layer := LanguageData.layer_of(String(words[0])) if not words.is_empty() else "comune"
	for w in words:
		if LanguageData.layer_of(String(w)) != "comune":
			layer = LanguageData.layer_of(String(w))
	var t := "[font_size=26][color=%s]%s[/color][/font_size]\n\n%s\n\n" % [LanguageData.LAYERS[layer]["color"], line_sem(words), line_it(words)]
	var n := understood(e)
	t += "[color=#9fc8c0]Parole certe %d su %d%s.[/color]" % [n, words.size(),
		"" if layer == "comune" else " · %s" % String(LanguageData.LAYERS[layer]["name"]).to_lower()]
	if first and news.is_empty() and n < words.size():
		t += "\n[color=#8aa09a]Queste parole ora le hai «viste». Ritrovale in altre frasi (%d in tutto) e te ne farai un'ipotesi.[/color]" % \
			int(LanguageData.LAYERS[layer]["hyp"])
	if not news.is_empty():
		t += "\n[color=#e0b060]Hai visto %s in abbastanza frasi: ora ne hai un'ipotesi. Nel Quaderno puoi provare il significato.[/color]" % \
			", ".join(news.map(func(w: String) -> String: return "«%s»" % LanguageData.sem(w)))
	var hint: Array = e.get("hint", [])
	if not hint.is_empty():
		if n >= words.size():
			_mark_sure(e, hint)
			t += "\n[color=#ffd08a]Il luogo che indica è segnato sulla mappa: %s.[/color]" % hint[2]
		elif guessed(e):
			if not e.get("forse", false):
				e["forse"] = true
				add_mark(Vector2i(int(hint[0]), int(hint[1])), "forse: %s" % hint[2], MAYBE_COLOR)
				m.hud.toast("Credi di capire dove indica la stele: «forse» sulla mappa. Vai a vedere per esserne certo")
			t += "\n[color=#e0b060]Credi di capire: indica un luogo, segnato «forse» sulla mappa. Arrivandoci le sue parole diventano certe.[/color]"
		else:
			t += "\n[color=#6a8a84]Indica un luogo: quando avrai un'ipotesi su ogni parola saprai dove cercare.[/color]"
	t += "\n\n" + LEGEND % Keys.label("quaderno")
	panel.show_text("Stele dei Seminatori", t)
	m.sfx.play("dono")
	return true


func _mark_sure(e: Dictionary, hint: Array) -> void:
	if e.get("segnata", false):
		return
	e["segnata"] = true
	var c := Vector2i(int(hint[0]), int(hint[1]))
	var marks: Array = m.world_meta["segni"]
	for i in range(marks.size() - 1, -1, -1):
		if int(marks[i][0]) == c.x and int(marks[i][1]) == c.y:
			marks.remove_at(i)                       # il «forse» diventa un segno pieno
	add_mark(c, String(hint[2]), Color("#6ff0b8"))
	m.hud.toast("La stele indica un luogo: «%s» è segnato sulla mappa" % hint[2])


## Ogni secondo: arrivati al luogo di una stele «forse», le sue parole diventano certe.
func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = 1.0
	var pc: Vector2i = m.player_cell()
	for k in stele():
		var e: Dictionary = stele()[k]
		if not e.get("forse", false) or e.get("segnata", false):
			continue
		var hint: Array = e.get("hint", [])
		if hint.is_empty() or Vector2(pc - Vector2i(int(hint[0]), int(hint[1]))).length() > ARRIVE:
			continue
		var got := confirm(e["words"], "luogo")
		_mark_sure(e, hint)
		m.hud.toast("Eri nel posto giusto: %s" % ("«%s» ora sono parole certe" % ", ".join(got.map(func(w: String) -> String:
			return "%s = %s" % [LanguageData.sem(w), LanguageData.it(w)])) if not got.is_empty() else "la stele diceva il vero"))
		m.sfx.play("dono")


## Un segno sulla mappa (stele, catene): [x, y, nome, colore].
func add_mark(c: Vector2i, name: String, col: Color) -> void:
	for s in m.world_meta["segni"]:
		if int(s[0]) == c.x and int(s[1]) == c.y:
			return
	(m.world_meta["segni"] as Array).append([c.x, c.y, name, col.to_html(false)])


## Una tavoletta: conferma due parole tra quelle viste o ipotizzate (prima quelle delle stele di questo mondo, prima le
## ipotesi). Se non hai visto niente da confermare non si consuma.
func use_tablet(id: String) -> bool:
	var here := {}
	for k in stele():
		for w in stele()[k]["words"]:
			here[String(w)] = true
	var cand: Array = m.character.lingua.keys().filter(func(w: String) -> bool: return state(w) != CERTA)
	cand.sort_custom(func(a: String, b: String) -> bool:
		var ka := (0 if here.has(a) else 2) + (0 if state(a) == IPOTESI else 1)
		var kb := (0 if here.has(b) else 2) + (0 if state(b) == IPOTESI else 1)
		return ka < kb)
	if cand.is_empty():
		m.hud.toast("La tavoletta spiega parole che non hai ancora visto: prima leggi qualche stele")
		return false
	if not m.character.bisaccia.remove(id, 1):
		return false
	var got := confirm(cand.slice(0, LanguageData.TABLET_WORDS + extra_words), "tavoletta")   # voce 142: la biblioteca
	m.hud.toast("La tavoletta conferma: %s  (certe %d su %d)" % [", ".join(got.map(func(w: String) -> String:
		return "%s = %s" % [LanguageData.sem(w), LanguageData.it(w)])), count(), LanguageData.WORDS.size()])
	m.sfx.play("dono")
	return true
