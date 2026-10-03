class_name Truth
extends Node
## Il Taccuino della verità (Roadmap 36, voce 345; domande in `TruthData`). Ogni pochi secondi guarda quali versioni il
## personaggio conosce (`LoreConds`) e se una domanda si può risolvere: la versione vera vista e la prova trovata. Una
## domanda risolta: la scritta grande, il premio, «verita» (misteri), `stats["verita_<id>"]`. Nel Taccuino la pagina
## «La verità»: le domande, le versioni con la loro fonte e, a domanda risolta, quale era vera.

const EVERY := 3.0

var m: Node2D
var paused := false
var _t := EVERY


func setup(main: Node2D) -> void:
	m = main


func _process(dt: float) -> void:
	if paused or m == null or not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = EVERY
	check()


## Le versioni conosciute di una domanda (indici).
func known(q: Dictionary) -> Array:
	var out := []
	var vs: Array = q["versions"]
	for i in vs.size():
		if LoreConds.ok(m, vs[i][2]):
			out.append(i)
	return out


func solved(q: Dictionary) -> bool:
	return int(m.character.stats.get("verita_" + String(q["id"]), 0)) >= 1


## Risolve ciò che si può: restituisce gli id risolti adesso; avvisa una volta delle versioni nuove.
func check() -> Array:
	var out := []
	var st: Dictionary = m.character.stats
	var fresh := false
	for q in TruthData.QUESTIONS:
		var k := known(q)
		for i in k:
			var key := "verita_vista_%s_%d" % [q["id"], i]
			if int(st.get(key, 0)) == 0:
				st[key] = 1
				fresh = true
		if solved(q):
			continue
		var true_seen := false
		for i in k:
			if String(q["versions"][i][3]) == "vera":
				true_seen = true
		if true_seen and LoreConds.ok(m, q["proof"]):
			st["verita_" + String(q["id"])] = 1
			m.objectives.bump("verita")
			for id in TruthData.REWARD:
				m.drops.spawn(id, int(TruthData.REWARD[id]), m.player.position + Vector2(0, -12))
			m.depth_watch.banner.show_stratum("Ora sai", String(q["q"]), Color("#d8c8ff"))
			if m.get("diary") != null:
				m.diary.note("Ora sai: %s" % q["q"], "storia")
			out.append(String(q["id"]))
	if fresh and out.is_empty() and m.built:
		m.hud.toast("Una versione nuova nel Taccuino della verità (Semenzaio, K)")
	return out


func rows(selected: String) -> Array:
	var open := 0
	var done := 0
	for q in TruthData.QUESTIONS:
		if not known(q).is_empty():
			open += 1
			if solved(q):
				done += 1
	if open == 0:
		return []
	return [["storia:verita", "La verità   ·   %d su %d" % [done, open], "#ffd08a" if selected == "storia:verita" else "#ffe0c8"]]


func detail() -> String:
	var t := "[color=#d8b8a8]Ognuno racconta la sua versione. Quando trovi la prova, sai qual è quella vera.[/color]\n"
	for q in TruthData.QUESTIONS:
		var k := known(q)
		if k.is_empty():
			continue
		var ok := solved(q)
		t += "\n[color=%s]%s[/color]%s\n" % ["#ffd08a" if ok else "#ffe8d0", q["q"], "  [color=#8ff0a0]✓[/color]" if ok else ""]
		var vs: Array = q["versions"]
		for i in k:
			var v: Array = vs[i]
			var mark := ""
			var col := "#cfeee4"
			if ok:
				match String(v[3]):
					"vera":
						mark = "  [color=#8ff0a0]vera[/color]"
						col = "#ffffff"
					"mezza":
						mark = "  [color=#e0c080]mezza verità[/color]"
					_:
						mark = "  [color=#ff8a78]falsa[/color]"
						col = "#8a9a98"
			t += "   [color=%s]«%s»[/color] [color=#7a8a88]— %s[/color]%s\n" % [col, v[0], v[1], mark]
		var hidden := vs.size() - k.size()
		if hidden > 0 and not ok:
			t += "   [color=#6a7a78]… %s[/color]\n" % ("un'altra versione da trovare" if hidden == 1 else "altre %d versioni da trovare" % hidden)
	return t
