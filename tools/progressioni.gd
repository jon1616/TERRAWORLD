extends SceneTree
## Voce 183 (Roadmap 18): le progressioni e l'economia. Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/progressioni.gd
## Scrive prove/progressioni.txt e lo stampa:
##   1. gli stadi dell'Albero-Madre: per ogni offerta di oggetti che cadono dalle creature, quante creature servono e
##      quanti minuti di caccia (al ritmo di `tools/percorso.gd`); le altre offerte con da dove vengono
##   2. la Vita e la Linfa massime: doni per mondo contro il tetto, Guardiani curati
##   3. l'economia: Lumini all'ora dalle creature per tappa, i premi della Bacheca, i prezzi delle merci degli abitanti

const PACE := 1.1                      # come `tools/percorso.gd`
const ZONES := [["Superficie", 0, 1], ["Sottobosco", 1, 1], ["Caverne", 2, 1], ["Profondità", 3, 1], ["Fondo", 4, 1],
	["Fondo, vigore 3", 4, 3], ["Fondo, vigore 8", 4, 8]]

var out := ""


func _init() -> void:
	_tree()
	_gifts()
	_economy()
	var f := FileAccess.open("res://prove/progressioni.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)
	quit()


func _p(s: String) -> void:
	print(s)
	out += s + "\n"


## Quante ne lascia in media una creatura (per tabella di bottino).
func _per_kill(table: String, item: String) -> float:
	var n := 0.0
	for e in LootData.TABLES.get(table, []):
		if String(e.get("item", "")) == item:
			n += float(e.get("chance", 1.0)) * (float(e.get("min", 1)) + float(e.get("max", 1))) / 2.0
	return n


## Chi lascia un oggetto: [[specie, per creatura, strato, parte delle nascite dello strato]].
func _sources(item: String) -> Array:
	var out_s := []
	for id in CreaturesData.CREATURES:
		var d: Dictionary = CreaturesData.CREATURES[id]
		if d.get("boss", false):
			continue
		var pk := _per_kill(String(d.get("loot", "")), item)
		if pk <= 0.0:
			continue
		for s in d.get("strata", []):
			var pl := ZoneModel.pool(int(s))
			var tot := 0.0
			for k in pl:
				tot += float(pl[k])
			var share := float(pl.get(id, 0.0)) / maxf(tot, 0.001)
			out_s.append([id, pk, int(s), share])
	return out_s


func _tree() -> void:
	_p("1. ALBERO-MADRE: le offerte, e quanto costano")
	var total := 0.0
	for k in MotherTreeData.STAGES.size():
		var st: Dictionary = MotherTreeData.STAGES[k]
		_p("   stadio %d «%s»" % [k + 1, st["name"]])
		for o0 in st["offers"]:
			var o: Dictionary = o0["any"][0] if (o0 as Dictionary).has("any") else o0      # la strada principale
			if o.has("stat"):
				_p("      traguardo: %s (%d)" % [o.get("text", o["stat"]), int(o["n"])])
				continue
			var item := String(o["item"])
			var n := int(o["n"])
			var hint := String(o.get("hint", ""))
			# solo gli oggetti che l'Albero dice «dalle creature» si contano a caccia (legno, humus, minerali, Cuori,
			# recinti hanno la loro strada: la si scrive)
			var hunted := (hint.begins_with("da") or hint.begins_with("dal")) and not "recinto" in hint and not "Cuor" in hint 				and not "alberi" in hint
			var src := _sources(item) if hunted else []
			if src.is_empty() and hint != "":
				_p("      %2d × %-22s %s" % [n, item, hint])
				continue
			if src.is_empty():
				var how := "fabbricato" if not RecipesData.making(item).is_empty() else "scavo, luoghi o doni"
				_p("      %2d × %-22s %s" % [n, item, how])
				continue
			# la fonte migliore: meno minuti
			var best := []
			var best_min := 1e9
			for e in src:
				var dz := ZoneModel.danger(int(e[2]), 1)
				var per_min := PACE * sqrt(dz) * float(e[3]) * float(e[1])
				var mins := n / maxf(per_min, 0.0001)
				if mins < best_min:
					best_min = mins
					best = e
			total += minf(best_min, 600.0)
			_p("      %2d × %-22s da %s (%s, %.2f a creatura, %.0f%% delle nascite): %.0f creature, ~%.0f minuti di caccia%s" % [
				n, item, best[0], StrataData.STRATA[int(best[2])]["name"], float(best[1]), 100.0 * float(best[3]),
				n / float(best[1]), best_min, "  !" if best_min > 60.0 else ""])
	_p("   caccia per tutte le offerte che cadono dalle creature: ~%.0f minuti" % total)
	_p("")


func _gifts() -> void:
	_p("2. VITA E LINFA MASSIME")
	for id in ["cuore_bocciolo", "stilla_perenne"]:
		var it := ItemsData.get_item(id)
		if it.is_empty():
			continue
		var g: Array = it["gift"]
		_p("   %s: +%d %s, al più %d volte (tetto +%d)" % [it["name"], int(g[1]), g[0], int(it["gift_max"]),
			int(g[1]) * int(it["gift_max"])])
	_p("   doni per mondo (PassDoni): %d boccioli e %d stille (se ne trova una parte: il tetto arriva in due o tre mondi)" % [
		PassDoni.BOCCIOLI, PassDoni.STILLE])
	_p("   Guardiano curato: +%d Vita per ogni mondo, **senza tetto** (vigore 12 ≈ %d mondi curati → +%d)" % [Guardian.HP_GIFT, 12,
		Guardian.HP_GIFT * 12])
	_p("")


func _economy() -> void:
	_p("3. ECONOMIA")
	for z in ZONES:
		var pl := ZoneModel.pool(int(z[1]))
		var hp := 0.0
		var wsum := 0.0
		for id in pl:
			var f := FightModel.foe(String(id), int(z[1]), int(z[2]))
			hp += float(f["hp"]) * float(pl[id])
			wsum += float(pl[id])
		hp /= maxf(wsum, 0.001)
		var per_kill := maxf(1.0, roundf(hp / FaunaExtra.LUMINI_HP))
		var rate := PACE * sqrt(ZoneModel.danger(int(z[1]), int(z[2])))
		_p("   creature, %-16s Vita media %4.0f → %2.0f Lumini a creatura, %.1f al minuto: ~%4.0f Lumini all'ora" % [z[0], hp,
			per_kill, rate, per_kill * rate * 60.0])
	_p("   (la pesca: sezione 5 di prove/bilancio.txt)")
	_p("   prezzi delle merci degli abitanti (comprare costa il doppio del valore):")
	for npc in NpcData.NPCS:
		var nd: Dictionary = NpcData.NPCS[npc]
		var row := []
		for g in nd.get("goods", []):
			row.append("%s %d" % [g[0], ValueData.buy_price(String(g[0]), 1)])
		if not row.is_empty():
			_p("      %s: %s" % [nd.get("name", npc), ", ".join(row)])
