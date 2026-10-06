class_name Chains
extends Node
## Le catene di ricerca (voce 69, dati in `ChainsData`). Lo stato sta nel personaggio (`Character.catene`):
## {"lunga": {"tappa", "fatta"}, "brevi": [{"id", "name", "need", "text", "reward"}], "fatte": n, "n": contatore}.
## - `pending` (statico, per il generatore): le tappe aperte con i loro geni; `PassCatene` mette la cripta nei mondi
##   che nascono con quei geni.
## - Entrando in un mondo con una cripta aperta, la cripta si segna sulla mappa e una scritta lo dice.
## - Clic destro sul leggio della cripta: il pezzo di storia, il premio, l'indizio dopo (`ReadPanel`).
## - Le brevi si rinnovano: ce ne sono sempre `SHORT_OPEN` (dai geni già visti).
## Il Taccuino delle catene è una scheda del Semenzaio (`view`).

var m: Node2D
var _t := 2.0
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	var ch: Character = m.character
	if ch.catene.is_empty():
		ch.catene = {"lunga": {"tappa": -1, "fatta": false}, "brevi": [], "fatte": 0, "n": 0}
	if not m.world_meta.has("cripte"):
		var cr := []
		for e in m.world.gen_notes.get("cripte", []):
			var o: Vector2i = e["leggio"]
			cr.append({"catena": e["catena"], "tappa": e["tappa"], "x": o.x, "y": o.y})
		m.world_meta["cripte"] = cr
	for ch2 in m.hud.get_children():
		if ch2 is SemenzaioPanel:
			ch2.chains_view = view
	for e in m.world_meta["cripte"]:
		if is_open(String(e["catena"]), int(e["tappa"])):
			m.language.add_mark(Vector2i(int(e["x"]), int(e["y"])), "Cripta: %s" % title_of(String(e["catena"])), Color("#ffd24a"))
			m.hud.toast("In questo mondo c'è una cripta della catena «%s»: è segnata sulla mappa" % title_of(String(e["catena"])))


## Le tappe aperte di un personaggio: [{"id", "step", "need"}] (per il generatore dei mondi).
static func pending(ch: Character) -> Array:
	var out := []
	if ch == null or ch.catene.is_empty():
		return out
	var lg: Dictionary = ch.catene["lunga"]
	var st := int(lg["tappa"])
	if st >= 0 and not bool(lg["fatta"]):
		out.append({"id": "lunga", "step": st, "need": ChainsData.LONG["steps"][st]["need"]})
	for b in ch.catene["brevi"]:
		out.append({"id": String(b["id"]), "step": 0, "need": b["need"]})
	return out


## Questo genoma porta a una tappa aperta? Il nome della catena o "".
static func matches(ch: Character, g: Dictionary) -> String:
	var genes: Array = g.get("geni", [])
	var vig := int(g.get("vigore", 0))
	for p in pending(ch):
		var need: Dictionary = p["need"]
		var ok := vig == 0 or vig >= int(need.get("vigore", 0))
		for x in need.get("geni", []):
			if not x in genes:
				ok = false
		if ok:
			return _title(ch, String(p["id"]))
	return ""


func is_open(id: String, step: int) -> bool:
	if id == "lunga":
		var lg: Dictionary = m.character.catene["lunga"]
		return int(lg["tappa"]) == step and not bool(lg["fatta"])
	return _short(id) != {}


func _short(id: String) -> Dictionary:
	for b in m.character.catene["brevi"]:
		if String(b["id"]) == id:
			return b
	return {}


func title_of(id: String) -> String:
	return _title(m.character, id)


static func _title(ch: Character, id: String) -> String:
	if id == "lunga":
		var st := int(ch.catene["lunga"]["tappa"])
		return "%s · %s" % [ChainsData.LONG["name"], ChainsData.LONG["steps"][clampi(st, 0, 4)]["name"]]
	for b in ch.catene.get("brevi", []):
		if String(b["id"]) == id:
			return String(b["name"])
	return "una catena conclusa"


func _process(dt: float) -> void:
	if not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = 3.0
	var ch: Character = m.character
	var trips := int(ch.stats.get("viaggi", 0))
	if int(ch.catene["lunga"]["tappa"]) < 0 and trips >= ChainsData.START_LONG:
		ch.catene["lunga"]["tappa"] = 0
		m.hud.toast("Una voce tra le radici: una catena nuova nel Taccuino (Semenzaio, %s)" % Keys.label("semenzaio"))
	if trips >= ChainsData.START_SHORT:
		while (ch.catene["brevi"] as Array).size() < ChainsData.SHORT_OPEN:
			var b := make_short()
			if b.is_empty():
				break
			(ch.catene["brevi"] as Array).append(b)


## Una catena breve: due geni già visti di categorie diverse (niente geni che nascono solo così), un premio.
func make_short() -> Dictionary:
	var seen := []
	for g in GenesData.GENES:
		var d: Dictionary = GenesData.GENES[g]
		if Genome.state(String(g)) >= 1 and not d.has("only") and int(d.get("vmin", 0)) <= 3:
			seen.append(String(g))
	if seen.size() < 2:
		return {}
	seen.shuffle()
	var a := String(seen[0])
	var b := ""
	for g in seen:
		if GenesData.cat_of(String(g)) != GenesData.cat_of(a):
			b = String(g)
			break
	if b == "":
		return {}
	var ch: Character = m.character
	ch.catene["n"] = int(ch.catene.get("n", 0)) + 1
	var rw := {}
	var pool := ChainsData.SHORT_REWARDS.duplicate()
	pool.shuffle()
	for r in pool.slice(0, 2):
		rw.merge(r)
	var intro := String(ChainsData.SHORT_INTRO[_rng.randi_range(0, ChainsData.SHORT_INTRO.size() - 1)])
	return {"id": "b%d" % int(ch.catene["n"]), "name": String(ChainsData.SHORT_NAMES[_rng.randi_range(0, ChainsData.SHORT_NAMES.size() - 1)]),
		"need": {"geni": [a, b]}, "reward": rw,
		"text": "%s: «sotto un mondo con %s e %s c'è una piccola cripta dei Seminatori». Pianta un Seme con questi due geni." % [
			intro, GenesData.GENES[a]["name"], GenesData.GENES[b]["name"]]}


## Clic destro sul leggio di una cripta.
func read(o: Vector2i) -> bool:
	var e := {}
	for x in m.world_meta.get("cripte", []):
		if int(x["x"]) == o.x and int(x["y"]) == o.y:
			e = x
	if e.is_empty():
		if m.places != null and m.places.read(o):              # voce 70: il leggio di un luogo
			return true
		m.language.panel.show_text("Leggio dei Seminatori", "[color=#6a8a84]Il leggio è vuoto: chi scriveva qui non ha lasciato parole.[/color]")
		return true
	var id := String(e["catena"])
	var step := int(e["tappa"])
	if not is_open(id, step):
		var again := "[color=#9fc8c0]%s[/color]" % String(e.get("letto", "Hai già letto questo leggio.")).split("\n\n[font_size=22]")[0]
		if id == "lunga":
			again += inscription(step)                     # Roadmap 17: l'iscrizione si rilegge (e si capisce, più avanti)
		m.language.panel.show_text("Leggio dei Seminatori", again)
		return true
	var t := ""
	var rw := {}
	if id == "lunga":
		var sd: Dictionary = ChainsData.LONG["steps"][step]
		t = "[color=#ffd08a]%s[/color]\n\n%s\n" % [sd["name"], sd["found"]]
		rw = sd["reward"]
		m.character.catene["lunga"]["tappa"] = step + 1
		if step + 1 >= (ChainsData.LONG["steps"] as Array).size():
			m.character.catene["lunga"]["fatta"] = true
			m.character.catene["lunga"]["tappa"] = step
			t += "\n[color=#8ff0a0]La via del Seme Nero è compiuta.[/color]"
		else:
			t += "\n[color=#6ff0b8]La tappa dopo:[/color] %s" % ChainsData.LONG["steps"][step + 1]["clue"]
	else:
		var b := _short(id)
		t = "[color=#ffd08a]%s[/color]\n\nUna piccola cripta, e nella teca il dono dei Seminatori.\n" % b["name"]
		rw = b["reward"]
		(m.character.catene["brevi"] as Array).erase(b)
	e["letto"] = t
	t += "\n\n[color=#ffd24a]Premio:[/color] %s" % _give(rw)
	if id == "lunga":
		t += inscription(step)
	m.character.catene["fatte"] = int(m.character.catene.get("fatte", 0)) + 1
	m.objectives.bump("catene")
	m.language.panel.show_text("Leggio dei Seminatori", t)
	m.sfx.play("dono")
	return true


## Dà un premio e lo descrive.
func _give(rw: Dictionary) -> String:
	var names := []
	var bag: Bisaccia = m.character.bisaccia
	for k in rw:
		var n := int(rw[k])
		match String(k):
			"seme_raro":
				var g: Dictionary = m.board._rare_seed_genome()
				_add_seed(Genome.item_of(g), g)
				names.append("un Seme di mondo con un gene raro")
			"seme_nero":
				var g2 := {"geni": Genome.sort(["cenere", "abissale", "cuore_nero"]), "vigore": maxi(Genome.local_vigor, 4), "nero": true}
				_add_seed("seme_nero", g2)
				names.append("il Seme Nero")
			_:
				if bag.add(String(k), n) > 0:
					m.drops.spawn(String(k), n, m.player.position)
				names.append("%d %s" % [n, ItemsData.get_item(String(k)).get("name", k)])
	return ", ".join(names)


func _add_seed(item: String, g: Dictionary) -> void:
	if m.character.bisaccia.add_stack({"id": item, "n": 1, "dati": g}) > 0:
		m.drops.spawn(item, 1, m.player.position, g)


## Il Taccuino (scheda del Semenzaio): [titolo, righe [id, testo, colore], dettaglio].
func view(selected: String) -> Array:
	var ch: Character = m.character
	var rows := []
	var lg: Dictionary = ch.catene["lunga"]
	if int(lg["tappa"]) >= 0:
		var st := int(lg["tappa"])
		var txt := "%s   ·   %s" % [ChainsData.LONG["name"], "compiuta" if bool(lg["fatta"]) else "tappa %d di %d" % [st + 1, (ChainsData.LONG["steps"] as Array).size()]]
		rows.append(["lunga", txt, "#ffd08a" if selected == "lunga" else "#ffe8b0"])
	for b in ch.catene["brevi"]:
		rows.append([String(b["id"]), String(b["name"]), "#ffd08a" if selected == String(b["id"]) else "#cfeee4"])
	# Roadmap 36: le pagine della storia vera (i Seminatori, i sogni, la verità), ognuna appena c'è qualcosa da dire
	for mod in _story_modules():
		rows.append_array(mod.rows(selected))
	var nf := int(ch.catene.get("fatte", 0))
	var title := "Taccuino delle catene — %d %s" % [nf, "tappa compiuta" if nf == 1 else "tappe compiute"]
	return [title, rows, _detail(selected)]


func _detail(id: String) -> String:
	var t := _detail0(id)
	if id == "":
		t += "

" + records_text()                  # voce 82: i record delle sfide e le leggende
	return t


## I record del personaggio: le sfide dei Semi (voce 82) e le leggende compiute (voce 81).
func records_text() -> String:
	var ch: Character = m.character
	var t := "[color=#ffb070]Sfide dei Semi[/color]
"
	for r in Challenges.records(ch):
		t += "• [color=#ffd8b0]%s[/color] [color=#9fc8c0]— %s[/color]
" % [r[0], r[1]]
	var n := 0
	for k in LegendsData.LEGENDS:
		if ch.leggende.has(k):
			n += 1
	t += "
[color=#ffd08a]Leggende compiute[/color]: %d su %d%s" % [n, LegendsData.LEGENDS.size(),
		"  ·  Seme Primo " + ("piantato e compiuto" if ch.leggende.has("primo_fatto") else "ricevuto") if ch.leggende.has("primo_dato") else ""]
	return t


## I moduli della storia che hanno una pagina nel Taccuino (Roadmap 36): ognuno ha `rows(selected)` e `detail()`, e le sue
## righe hanno l'id «storia:<pagina>».
func _story_modules() -> Array:
	var out := []
	for k in ["cuore_desto", "sowers", "dreams", "echoes", "truth"]:
		if m.get(k) != null:
			out.append(m.get(k))
	return out


func _detail0(id: String) -> String:
	if id.begins_with("storia:"):
		for mod in _story_modules():
			for r in mod.rows(id):
				if String(r[0]) == id:
					return mod.detail()
	var ch: Character = m.character
	if id == "":
		if rows_empty():
			return "[color=#6a8a84]Ancora nessuna catena. Viaggia tra i mondi: le radici del Giardino cominceranno a parlare.[/color]"
		return "[color=#9fc8c0]Ogni catena dice di che geni deve essere fatto un mondo. Pianta un Seme con quei geni (all'Innestatrice puoi fissarli con le Fiale): nel mondo nuovo c'è una cripta dei Seminatori, segnata sulla mappa. Sul suo leggio: storia, premio e la tappa dopo.[/color]"
	var need := {}
	var t := ""
	if id == "lunga":
		var lg: Dictionary = ch.catene["lunga"]
		var st := int(lg["tappa"])
		if bool(lg["fatta"]):
			return "[color=#8ff0a0]La via del Seme Nero è compiuta: il Seme Nero è tuo.[/color]"
		var sd: Dictionary = ChainsData.LONG["steps"][st]
		t = "[font_size=22][color=#ffd08a]%s[/color][/font_size]\n[color=#9fc8c0]%s[/color]\n\n%s\n" % [ChainsData.LONG["name"], sd["name"], sd["clue"]]
		need = sd["need"]
	else:
		var b := _short(id)
		if b.is_empty():
			return ""
		t = "[font_size=22][color=#ffd08a]%s[/color][/font_size]\n\n%s\n" % [b["name"], b["text"]]
		need = b["need"]
	t += "\n[color=#8ef0d8]Il mondo deve avere:[/color]\n"
	for g in need.get("geni", []):
		var st2 := Genome.state(String(g))
		t += "• %s  [color=#6a8a84](%s)[/color]\n" % [GenesData.tag(String(g)), ["mai visto", "visto", "imparato: puoi fissarlo"][clampi(st2, 0, 2)]]
	if int(need.get("vigore", 0)) > 0:
		t += "• vigore %d o più\n" % int(need["vigore"])
	return t


func rows_empty() -> bool:
	return int(m.character.catene["lunga"]["tappa"]) < 0 and (m.character.catene["brevi"] as Array).is_empty()


## Roadmap 17, voce 173: l'iscrizione nella lingua del Seme Nero sul leggio della tappa `step`. Leggerla fa vedere le sue
## parole; capita tutta, dice la verità della tappa (e la prima volta un dono).
func inscription(step: int) -> String:
	if step < 0 or step >= LanguageData.CRYPT_TRUTH.size():
		return ""
	var ct: Array = LanguageData.CRYPT_TRUTH[step]
	var words: Array = LanguageData.LORE_BLACK[int(ct[0])]
	m.language.see(words, "cripta:%d" % step)
	var t := "\n\n[font_size=22][color=#b89ae0]%s[/color][/font_size]\n%s" % [Language.line_sem(words), m.language.line_it(words)]
	if m.language.understood({"words": words}) >= words.size():
		t += "\n[color=#e0d0ff]%s[/color]" % String(ct[1])
		var seen: Array = m.character.catene.get("verita", [])
		if not step in seen:
			seen.append(step)
			m.character.catene["verita"] = seen
			t += "\n[color=#ffd24a]Hai capito la verità della tappa: %s[/color]" % _give(LanguageData.CRYPT_GIFT)
	else:
		t += "\n[color=#6a8a84]Sotto, un'iscrizione nella lingua del Seme Nero: capiscila tutta e dirà che cosa accadde davvero.[/color]"
	return t

