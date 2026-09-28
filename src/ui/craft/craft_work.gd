class_name CraftWork
extends RefCounted
## Le lavorazioni sull'oggetto in mano nel pannello «Creare» (la categoria «Lavorazioni»): al Maglio rinnovo del
## tratto, rifusione dei doppioni (`Refusion`), innesti delle Essenze e innesti da togliere; al Telaio le fasce del manico. Ogni lavorazione è una riga
## larga con l'icona, il testo e il costo nel suggerimento. Spostate qui dal pannello il 28 set 2026.


## Le righe per l'oggetto nella casella `hs` con questi banchi vicini (vuoto: niente da lavorare).
static func rows(p: CraftingPanel, hs: int, near: Dictionary) -> Array[Button]:
	var out: Array[Button] = []
	var bag := p.bisaccia
	if near.has("maglio") and Bisaccia.is_gear(bag.id_at(hs)):
		out.append(_reforge(p, hs))
		if Refusion.partner(bag, hs) >= 0:
			out.append(_refuse(p, hs))                 # la rifusione dei doppioni (29 set 2026)
		var seen := {}
		for s in bag.slots:
			var e := String(s.get("id", ""))
			if e != "" and not seen.has(e) and String(ItemsData.get_item(e).get("kind", "")) == "essenza":
				seen[e] = true
				if TraitsData.can_graft(e, bag.id_at(hs)):
					out.append(_graft(p, hs, e))
		for t in (bag.slots[hs].get("dati", {}) as Dictionary).get("innesti", []):
			out.append(_ungraft(p, hs, String(t)))
	if near.has("telaio") and String(ItemsData.get_item(bag.id_at(hs)).get("form", "")) in FormsData.WRAPPABLE:
		for f in FormsData.FASCE:
			out.append(_wrap(p, hs, f))
	return out


static func _reforge(p: CraftingPanel, i: int) -> Button:
	var bag := p.bisaccia
	var id := bag.id_at(i)
	var cost := ""
	var can := true
	for k in TraitsData.REFORGE_COST:
		cost += "%d %s" % [TraitsData.REFORGE_COST[k], ItemsData.get_item(k)["name"]]
		can = can and Crafting.have(bag, k) >= int(TraitsData.REFORGE_COST[k])
	var b := _row(id, can, "Rinnova il tratto: %s" % TraitsData.full_name(id, bag.trait_at(i)), cost)
	b.tooltip_text = "Al Maglio dei Seminatori: un tratto nuovo, sempre diverso dal vecchio.\nCosta %s." % cost
	b.pressed.connect(func() -> void:
		if Crafting.reforge(bag, i) != "":
			p.crafted.emit(id, 1)
		p.refresh())
	return b


static func _refuse(p: CraftingPanel, i: int) -> Button:
	var bag := p.bisaccia
	var id := bag.id_at(i)
	var j := Refusion.partner(bag, i)
	var res := Refusion.result(bag.slots[i], bag.slots[j])
	var cost := ""
	var can := true
	for k in Refusion.COST:
		cost += "%d %s" % [Refusion.COST[k], ItemsData.get_item(k)["name"]]
		can = can and Crafting.have(bag, k) >= int(Refusion.COST[k])
	var qn := func(s: Dictionary) -> String: return String(TraitsData.QUALITY[Gear.quality(s)]["name"])
	var b := _row(id, can, "Rifondi i due doppioni: %s + %s → %s" % [qn.call(bag.slots[i]), qn.call(bag.slots[j]),
		Gear.full_name(res)], cost)
	b.tooltip_text = "Al Maglio due oggetti uguali diventano uno solo: la qualità più alta (uguali: un grado in più), il tratto migliore, gli innesti di tutti e due finché c'è posto.
Costa %s." % cost
	b.pressed.connect(func() -> void:
		if Refusion.refuse(bag, i):
			p.crafted.emit(id, 1)
		p.refresh())
	return b


static func _graft(p: CraftingPanel, i: int, essence: String) -> Button:
	var bag := p.bisaccia
	var id := bag.id_at(i)
	var t := String(ItemsData.get_item(essence)["graft"])
	var free := Gear.free_slots(bag.slots[i])
	var b := _row(essence, true, "Innesta: %s [%s]" % [ItemsData.get_item(id)["name"], TraitsData.TRAITS[t]["name"]],
		("posti liberi %d" % free) if free > 0 else "prende il posto del tratto")
	b.tooltip_text = "%s: %s" % [ItemsData.get_item(essence)["name"], TraitsData.TRAITS[t]["desc"]]
	b.pressed.connect(func() -> void:
		if Crafting.graft(bag, i, essence) != "":
			p.crafted.emit(id, 1)
			p.grafted.emit(id)
		p.refresh())
	return b


static func _wrap(p: CraftingPanel, i: int, fascia: String) -> Button:
	var bag := p.bisaccia
	var fd: Dictionary = FormsData.FASCE[fascia]
	var can := Crafting.have(bag, String(fd["item"])) >= int(fd["n"])
	var cost := "%d %s" % [int(fd["n"]), ItemsData.get_item(String(fd["item"]))["name"]]
	var b := _row(String(fd["item"]), can, "Fascia di %s: %s (%s)" % [fd["name"], ItemsData.get_item(bag.id_at(i))["name"],
		fd["desc"]], cost)
	b.tooltip_text = "Al Telaio di foglie: si avvolge sul manico, e prende il posto della fascia di prima.\nCosta %s." % cost
	b.pressed.connect(func() -> void:
		var id := bag.id_at(i)
		if Crafting.wrap(bag, i, fascia):
			p.crafted.emit(id, 1)
		p.refresh())
	return b


static func _ungraft(p: CraftingPanel, i: int, t: String) -> Button:
	var bag := p.bisaccia
	var cost := ""
	var can := true
	for k in TraitsData.UNGRAFT_COST:
		cost += "%d %s" % [TraitsData.UNGRAFT_COST[k], ItemsData.get_item(k)["name"]]
		can = can and Crafting.have(bag, k) >= int(TraitsData.UNGRAFT_COST[k])
	var b := _row("maglio", can, "Togli l'innesto %s (l'Essenza si perde)" % TraitsData.TRAITS[t]["name"], cost)
	b.pressed.connect(func() -> void:
		var id := bag.id_at(i)
		if Crafting.ungraft(bag, i, t):
			p.crafted.emit(id, 1)
		p.refresh())
	return b


## Una riga larga: icona, testo, costo a destra; chiara se si può fare.
static func _row(icon_id: String, can: bool, text: String, cost: String) -> Button:
	var b := Button.new()
	b.icon = SlotView.icon(icon_id)
	b.expand_icon = true
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_constant_override("icon_max_width", 32)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.clip_text = true
	b.text = "%s   —   %s" % [text, cost]
	b.custom_minimum_size = Vector2(0, 46)
	b.add_theme_font_size_override("font_size", 15)
	RecipeRow.style(b, can, CraftCatsData.WORK)
	return b
