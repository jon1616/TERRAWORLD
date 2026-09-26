class_name ItemTip
extends RefCounted
## La scheda di un oggetto nei suggerimenti (26 set 2026, scelta dell'utente: «ricchi, Esamina per il resto»): nome
## con il colore della qualità o del tipo, che cos'è, i valori veri (`Gear`: qualità, tratti, innesti, fascia),
## l'elemento, gli effetti che dà indossato, il set con quanti pezzi hai, il valore in Lumini e, tenendo Maiusc, il
## confronto con ciò che indossi o hai in mano. **Ricette e provenienza no**: sono in Esamina.
## `slot` = {"id", "n"?, "tratto"?, "dati"?}; `ctx`: "bag" (la Bisaccia, per set e confronto), "price" ("buy"/"sell"
## con il prezzo del mercante), "hand" (la casella in mano), "equipped" (la casella dell'equipaggiamento), "no_compare".

const ARMOR := ["elmo", "corazza", "gambali"]


static func card(slot: Dictionary, ctx := {}) -> TipCard:
	var id := String(slot.get("id", ""))
	var it := ItemsData.get_item(id)
	if it.is_empty():
		return null
	var n := int(slot.get("n", 1))
	var dati: Dictionary = slot.get("dati", {})
	var kind := String(it.get("kind", ""))
	var gear := Bisaccia.is_gear(id)
	var c := TipCard.new()
	var col := TipWordsData.kind_color(kind)
	if gear and dati.has("q"):
		col = Color(String(TraitsData.QUALITY[Gear.quality(slot)]["color"]))
	var title := Gear.full_name(slot)
	if title.ends_with("]") and title.contains(" ["):
		title = title.substr(0, title.rfind(" ["))   # i tratti sono scritti sotto, uno per riga
	c.title(title, col, id)
	# che cos'è: tipo, grado, materiale, quanti
	var what := [TipWordsData.kind_name(kind, String(it.get("form", "")))]
	if int(it.get("tier", 0)) > 0:
		what.append("grado %d" % int(it["tier"]))
	if gear and dati.has("q"):
		what.append("qualità %s" % TraitsData.QUALITY[Gear.quality(slot)]["name"])
	if n > 1:
		what.append("%d nella pila" % n)
	c.sub(" · ".join(what))
	_values(c, slot, it, kind)
	_specials(c, slot, it, kind, dati)
	_traits(c, slot, gear, dati)
	_effects(c, it)
	_sets(c, id, ctx)
	if String(it.get("desc", "")) != "":
		c.sep()
		c.text("[i][color=#%s]%s[/color][/i]" % [TipCard.SOFT.to_html(false), it["desc"]])
	_compare(c, slot, it, kind, ctx)
	_price(c, id, n, ctx)
	var hints := []
	if _comparable(slot, kind, ctx) != {} and not Tips.shift:
		hints.append("Maiusc: confronta con ciò che hai")
	c.hint(" · ".join(hints))
	return c


## Danno, colpi, forza, Scorza, portata… con i valori veri (qualità, tratti e fascia compresi).
static func _values(c: TipCard, slot: Dictionary, it: Dictionary, kind: String) -> void:
	var st := Gear.stats(slot)
	var rows := []
	if it.has("damage"):
		rows.append(["Danno", str(roundi(float(st["damage"])))])
	if it.has("speed"):
		rows.append(["Colpi al secondo", num(float(st["speed"]))])
	if it.has("power"):
		rows.append(["Forza", str(int(st["power"]))])
		if float(st["dig"]) != 1.0:
			rows.append(["Scavo", "%+d%%" % roundi((float(st["dig"]) - 1.0) * 100.0)])
	if it.has("defense"):
		rows.append(["Scorza", str(roundi(float(st["defense"])))])
	if int(st["pierce"]) > 0:
		rows.append(["Trafigge", str(int(st["pierce"]))])
	if it.has("knockback") and float(st["knockback"]) >= 2.0:
		rows.append(["Spinta", num(float(st["knockback"]), 1)])
	if kind == "bastone" and it.has("linfa"):
		rows.append(["Costo in Linfa", str(int(it["linfa"]))])
	elif it.has("linfa"):
		rows.append(["Ridà Linfa", str(int(it["linfa"]))])
	if it.has("heal"):
		rows.append(["Cura", str(int(it["heal"]))])
	if it.has("hook"):
		rows.append(["Portata", "%d tessere" % int(it["hook"].get("range", 0))])
	if it.has("blast"):
		rows.append(["Raggio", "%d tessere" % int(it["blast"].get("radius", 0))])
		rows.append(["Rompe la roccia fino a forza", str(int(it["blast"].get("power", 0)))])
	if it.has("throw"):
		rows.append(["Gittata", "%d tessere" % int(it["throw"].get("range", 0))])
	c.stats(rows)
	if it.has("power") and kind == "piccone":
		c.text(_digs(int(st["power"])))
	var el := String(st["elem"])
	if el.contains("+"):
		c.pair("Elementi", "%s e %s, alternati" % [ElementsData.tag(el.get_slice("+", 0)), ElementsData.tag(el.get_slice("+", 1))],
			Color("#8ef0d8"))
	elif el != "":
		c.pair("Elemento", ElementsData.tag(el), Color("#8ef0d8"))


## Ciò che solo certi oggetti hanno: pozioni, doni, Semi di mondo, creature nel vasetto, uova, incantesimi.
static func _specials(c: TipCard, slot: Dictionary, it: Dictionary, kind: String, dati: Dictionary) -> void:
	if it.has("boon"):
		var b: Array = it["boon"]
		c.pair("Effetto", "%s per %s" % [Boons.NAMES.get(String(b[0]), String(b[0]).capitalize()), _time(float(b[1]))],
			Color("#b8f080"))
	if it.has("gift"):
		var g: Array = it["gift"]
		c.pair("Per sempre", "+%d %s massima" % [int(g[1]), "Vita" if String(g[0]) == "vita" else "Linfa"], Color("#ff9ab8"))
	if it.has("graft"):
		var t := String(it["graft"])
		if TraitsData.TRAITS.has(t):
			c.pair("Innestata dà", "%s — %s" % [TraitsData.TRAITS[t]["name"], TraitsData.TRAITS[t]["desc"]], Color("#d890ff"))
	if dati.has("geni"):
		var v := Genome.vigor(dati)
		c.pair("Vigore", str(v) if v > 0 else "quello del mondo dove lo pianti, più uno", Color("#6ff0d0"))
		for x in Genome.genes(dati):
			var gd := GenesData.info(String(x))
			var ci: Dictionary = GenesData.CAT_INFO[String(gd["cat"])]
			var known := Genome.state(String(x)) > 0 or String(gd["cat"]) == "superficie"
			c.pair(String(ci["name"]), GenesData.tag(String(x)) if known else "[color=#6a8a84]? — un gene mai visto[/color]",
				Color(String(ci["color"])))
	if String(slot.get("id", "")) == "creatura" and dati.has("specie"):
		c.line(HerdInfo.short(dati), TipCard.SOFT)
	if String(slot.get("id", "")) == "uovo" and dati.has("specie"):
		c.line("Nell'Incubatrice si schiude in %d secondi" % int(HerdData.HATCH), TipCard.SOFT)


static func _traits(c: TipCard, slot: Dictionary, gear: bool, dati: Dictionary) -> void:
	var ts := Gear.traits(slot)
	if ts.is_empty() and not gear and not dati.has("fascia"):
		return
	c.sep()
	for i in ts.size():
		var t := String(ts[i])
		var head := "Tratto" if i == 0 and String(slot.get("tratto", "")) != "" else "Innesto"
		var desc := String(TraitsData.TRAITS[t]["desc"])
		var bad := (desc.begins_with("−") or desc.begins_with("-")) and not desc.contains("+")
		c.pair("%s %s" % [head, TraitsData.TRAITS[t]["name"]], desc, TipCard.BAD if bad else TipCard.GOLD)
	var fascia := String(dati.get("fascia", ""))
	if FormsData.FASCE.has(fascia):
		c.pair("Fascia di %s" % FormsData.FASCE[fascia]["name"], String(FormsData.FASCE[fascia]["desc"]))
	if gear:
		var free := Gear.free_slots(slot)
		c.line("Posti d'innesto: %d su %d%s" % [ts.size(), Gear.slots(slot), (" · %d liberi al Maglio" % free) if free > 0 else ""],
			TipCard.SOFT)


## Gli effetti che dà indossato (accessori, e le armature che ne hanno).
static func _effects(c: TipCard, it: Dictionary) -> void:
	var acc: Dictionary = it.get("acc", {})
	if acc.is_empty():
		return
	var out := []
	for k in acc:
		var l := TipWordsData.acc_line(String(k), acc[k])
		out.append("[color=#%s]%s[/color]" % [(TipCard.GOOD if l[1] else TipCard.BAD).to_html(false), l[0]])
	c.text("[color=#%s]Indossato:[/color] %s" % [Color("#80c8ff").to_html(false), " · ".join(out)])


static func _sets(c: TipCard, id: String, ctx: Dictionary) -> void:
	var bag: Bisaccia = ctx.get("bag")
	for sid in SetsData.of_item(id):
		var sd: Dictionary = SetsData.all()[sid]
		var total: int = (sd["pieces"] as Array).size()
		var worn := SetsData.worn(sid, bag.equip) if bag != null else 0
		var done := worn >= total
		c.sep()
		c.pair("Set «%s» %d/%d" % [sd["name"], worn, total], String(sd["desc"]), TipCard.GOOD if done else TipCard.GOLD)


## Il valore: al mercante il prezzo vero, altrove quanto vale.
static func _price(c: TipCard, id: String, n: int, ctx: Dictionary) -> void:
	var mode := String(ctx.get("price", ""))
	var gold := Color("#ffd24a")
	if mode == "buy":
		c.sep()
		c.pair("Prezzo", "%d Lumini" % int(ctx.get("cost", ValueData.buy_price(id, n))), gold)
		return
	if id == "lumino":
		return
	var v := ValueData.value(id)
	if v <= 0:
		return
	c.sep()
	if mode == "sell":
		c.pair("Venduto", "%d Lumini%s" % [ValueData.sell_price(id, n), " (tutta la pila)" if n > 1 else ""], gold)
	else:
		c.pair("Vale", "%d Lumini%s" % [v, (" · la pila %d" % (v * n)) if n > 1 else ""], gold)


## Con che cosa si confronta: l'armatura con quella indossata nello stesso posto, armi e attrezzi con ciò che hai in
## mano se è dello stesso tipo.
static func _comparable(slot: Dictionary, kind: String, ctx: Dictionary) -> Dictionary:
	if ctx.get("no_compare", false):
		return {}
	var bag: Bisaccia = ctx.get("bag")
	if bag == null or not Bisaccia.is_gear(String(slot.get("id", ""))):
		return {}
	if kind in ARMOR:
		if not bag.equip.has(kind) or ctx.get("equipped", false):
			return {}
		return bag._worn(kind)
	var hand: Dictionary = ctx.get("hand", {})
	if hand.is_empty() or hand == slot or String(hand.get("id", "")) == String(slot.get("id", "")) and hand.get("dati", {}) == slot.get("dati", {}):
		return {}
	if String(ItemsData.get_item(String(hand.get("id", ""))).get("kind", "")) != kind:
		return {}
	return hand


static func _compare(c: TipCard, slot: Dictionary, it: Dictionary, kind: String, ctx: Dictionary) -> void:
	if not Tips.shift:
		return
	var other := _comparable(slot, kind, ctx)
	if other.is_empty():
		return
	var a := Gear.stats(slot)
	var b := Gear.stats(other)
	var rows := []
	for k in [["damage", "Danno", "%+d"], ["speed", "Colpi al secondo", "%+.2f"], ["power", "Forza", "%+d"],
			["defense", "Scorza", "%+d"]]:
		if it.has(k[0]) or ItemsData.get_item(String(other["id"])).has(k[0]):
			rows.append([k[1], TipCard.delta(float(a[k[0]]) - float(b[k[0]]), String(k[2]))])
	c.sep()
	c.line("Rispetto a %s:" % Gear.full_name(other), Color("#80c8ff"))
	c.stats(rows)
	var ta := Gear.traits(slot).size()
	var tb := Gear.traits(other).size()
	if ta != tb:
		c.line("Tratti e innesti: %d contro %d" % [ta, tb], TipCard.GOOD if ta > tb else TipCard.BAD)


## Che cosa rompe un piccone: la roccia più dura che scava e la prossima che non scava ancora.
static func _digs(power: int) -> String:
	var best := ""
	var best_p := -1
	var next := ""
	var next_p := 100000
	for t in TileDefs.POWER:
		var need := int(TileDefs.POWER[t])
		if need <= 0 or need >= 999 or not TileDefs.NAMES.has(t):
			continue
		if need <= power and need > best_p:
			best_p = need
			best = String(TileDefs.NAMES[t])
		elif need > power and need < next_p:
			next_p = need
			next = String(TileDefs.NAMES[t])
	var out := "[color=#%s]Scava[/color] tutto fino a %s" % [Color("#8ef0d8").to_html(false),
		best if best != "" else "humus, ardesia e radicite"]
	if next != "":
		out += "  [color=#%s]· non ancora %s (forza %d)[/color]" % [TipCard.DIM.to_html(false), next, next_p]
	return out


## Un numero con la virgola, all'italiana.
static func num(v: float, dec := 2) -> String:
	return (("%." + str(dec) + "f") % v).replace(".", ",")


static func _time(s: float) -> String:
	if s >= 60.0:
		var mins := roundi(s / 60.0)
		return "%d minut%s" % [mins, "o" if mins == 1 else "i"]
	return "%d secondi" % roundi(s)
