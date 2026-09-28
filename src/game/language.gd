class_name Language
extends Node
## La lingua dei Seminatori (voce 68, Roadmap 9): una progressione di **conoscenza**. Le parole conosciute stanno nel
## personaggio (`Character.lingua`, valgono in tutti i mondi); le stele di questo mondo in `world_meta["stele"]`
## (dalla passata `PassStele`). Leggere una stele (clic destro) mostra la frase: le parole conosciute in italiano, le
## altre nella loro lingua; la prima lettura insegna una parola dal contesto. Quando una frase che indica un luogo è
## tutta compresa, il luogo si segna sulla mappa (`world_meta["segni"]`, disegnati da `MapPanel`).
## Le tavolette insegnano tre parole (prima quelle delle stele di questo mondo); il Cartografo le vende.

var m: Node2D
var panel: ReadPanel
var _rng := RandomNumberGenerator.new()


var extra_words := 0                     # voce 142: una biblioteca nel mondo (`Rooms`)


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
	panel = ReadPanel.new()
	m.hud.add_child(panel)
	m.hud.overlays.append(panel)
	_sync_stat()


func stele() -> Dictionary:
	return m.world_meta["stele"]


static func _key(o: Vector2i) -> String:
	return "%d,%d" % [o.x, o.y]


func known(w: String) -> bool:
	return m.character.lingua.has(w)


func count() -> int:
	return m.character.lingua.size()


## Impara delle parole: restituisce quelle nuove.
func learn(words: Array) -> Array:
	var out := []
	for w in words:
		if LanguageData.WORDS.has(w) and not known(String(w)):
			m.character.lingua[String(w)] = 1
			out.append(String(w))
	_sync_stat()
	return out


func _sync_stat() -> void:
	m.character.stats["parole"] = count()


## La frase nella lingua dei Seminatori.
static func line_sem(words: Array) -> String:
	return " ".join(words.map(func(w: String) -> String: return LanguageData.sem(w)))


## La traduzione: le parole conosciute in italiano, le altre nella loro lingua, spente, tra ‹ ›.
func line_it(words: Array) -> String:
	return "  ".join(words.map(func(w: String) -> String:
		return "[color=#ffe8b0]%s[/color]" % LanguageData.it(w) if known(w) else "[color=#5a706c]‹%s›[/color]" % LanguageData.sem(w)))


func understood(e: Dictionary) -> int:
	return (e["words"] as Array).filter(func(w: String) -> bool: return known(w)).size()


## Clic destro su una stele.
func read(o: Vector2i) -> bool:
	var e: Dictionary = stele().get(_key(o), {})
	if e.is_empty():
		return false
	var news := []
	if not e.get("letta", false):
		e["letta"] = true
		m.objectives.bump("stele")
		var unknown := (e["words"] as Array).filter(func(w: String) -> bool: return not known(w))
		if not unknown.is_empty():
			news = learn(unknown.slice(0, LanguageData.STELE_WORDS))
	var words: Array = e["words"]
	var t := "[font_size=26][color=#6ff0b8]%s[/color][/font_size]\n\n%s\n\n" % [line_sem(words), line_it(words)]
	var n := understood(e)
	t += "[color=#9fc8c0]Capisci %d parole su %d.[/color]" % [n, words.size()]
	if not news.is_empty():
		t += "\n[color=#8ff0a0]Dal contesto capisci una parola: «%s» vuol dire «%s».[/color]" % [LanguageData.sem(news[0]), LanguageData.it(news[0])]
	var hint: Array = e.get("hint", [])
	if not hint.is_empty():
		if n >= words.size():
			if not e.get("segnata", false):
				e["segnata"] = true
				add_mark(Vector2i(int(hint[0]), int(hint[1])), String(hint[2]), Color("#6ff0b8"))
				m.hud.toast("La stele indica un luogo: «%s» è segnato sulla mappa" % hint[2])
			t += "\n[color=#ffd08a]Il luogo che indica è segnato sulla mappa: %s.[/color]" % hint[2]
		else:
			t += "\n[color=#6a8a84]Indica un luogo: comprendi tutta la frase per sapere dove.[/color]"
	panel.show_text("Stele dei Seminatori", t)
	m.sfx.play("dono")
	return true


## Un segno sulla mappa (stele, catene): [x, y, nome, colore].
func add_mark(c: Vector2i, name: String, col: Color) -> void:
	for s in m.world_meta["segni"]:
		if int(s[0]) == c.x and int(s[1]) == c.y:
			return
	(m.world_meta["segni"] as Array).append([c.x, c.y, name, col.to_html(false)])


## Una tavoletta: tre parole, prima quelle delle stele di questo mondo che non conosci.
func use_tablet(id: String) -> bool:
	var here := []
	for k in stele():
		for w in stele()[k]["words"]:
			if not known(String(w)) and not w in here:
				here.append(String(w))
	var rest := LanguageData.WORDS.keys().filter(func(w: String) -> bool: return not known(w) and not w in here)
	here.shuffle()
	rest.shuffle()
	here.append_array(rest)
	if here.is_empty():
		m.hud.toast("Conosci già tutte le parole dei Seminatori")
		return false
	if not m.character.bisaccia.remove(id, 1):
		return false
	var got := learn(here.slice(0, LanguageData.TABLET_WORDS + extra_words))   # voce 142: la biblioteca
	m.hud.toast("Parole nuove: %s  (%d su %d)" % [", ".join(got.map(func(w: String) -> String:
		return "%s = %s" % [LanguageData.sem(w), LanguageData.it(w)])), count(), LanguageData.WORDS.size()])
	m.sfx.play("dono")
	return true
