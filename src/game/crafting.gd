class_name Crafting
extends RefCounted
## Regole della fabbricazione (nessun disegno): quali stazioni sono vicine, quali ricette si possono usare, se bastano
## i materiali, e il fabbricare vero e proprio sulla Bisaccia.


## Stazioni a portata della cella c: {id: true}.
static func stations_near(world: World, c: Vector2i) -> Dictionary:
	var out := {}
	for o in world.stations:
		var id: String = world.stations[o]
		var sd: Dictionary = StationsData.STATIONS[id]
		if sd.has("slots") or sd.get("fixed", false):
			continue                           # ceste, scrigni, Cuore e portale non sono stazioni di lavoro
		var size: Array = sd["size"]
		var r := Rect2i(o, Vector2i(size[0], size[1])).grow(StationsData.REACH)
		if r.has_point(c):
			out[id] = true
	return out


## Gli oggetti che il personaggio ha già scoperto (`Character.erbario["oggetti"]`, lo imposta `main`): le ricette delle
## leghe (voce 52) e dei materiali dei geni (voce 53) si vedono solo quando se ne conoscono gli ingredienti, e le loro
## armi quando se ne è avuto il lingotto (sono centinaia: così l'elenco cresce con le scoperte).
static var known := {}


## Ricette usabili con queste stazioni (quelle «a mano» sempre).
static func available(near: Dictionary) -> Array:
	return RecipesData.all().filter(func(r: Dictionary) -> bool:
		return (String(r["station"]) == "" or near.has(String(r["station"]))) and _discovered(r))


static func _discovered(r: Dictionary) -> bool:
	var it := ItemsData.get_item(String(r["out"]))
	var mat := String(it.get("mat", ""))
	var md := MaterialsData.get_mat(mat)
	if mat != "" and (md.has("alloy") or md.has("gene")):
		return known.has(String(md["bar"]))       # le armi di una lega o di un materiale dei geni (voci 52-53)
	var out := String(r["out"])
	if out.begins_with("lingotto_") and MaterialsData.all().has(out.trim_prefix("lingotto_")):
		var bm := MaterialsData.get_mat(out.trim_prefix("lingotto_"))
		if bm.has("alloy") or bm.has("gene"):
			for k in r["in"]:
				if not known.has(k):
					return false
	return true


static func can_craft(r: Dictionary, b: Bisaccia) -> bool:
	for k in r["in"]:
		if b.count(k) < int(r["in"][k]):
			return false
	return b.room_for(String(r["out"])) >= int(r["qty"])


static func craft(r: Dictionary, b: Bisaccia) -> bool:
	if not can_craft(r, b):
		return false
	for k in r["in"]:
		b.remove(k, int(r["in"][k]))
	b.add(String(r["out"]), int(r["qty"]))
	return true


## Rinnova il tratto dell'oggetto nella casella i (al Maglio): costa `TraitsData.REFORGE_COST`, il tratto nuovo è
## sempre diverso dal vecchio. Restituisce il tratto nuovo, o "" se non si può.
static func reforge(b: Bisaccia, i: int) -> String:
	var id := b.id_at(i)
	if id == "" or not Bisaccia.is_gear(id):
		return ""
	for k in TraitsData.REFORGE_COST:
		if b.count(k) < int(TraitsData.REFORGE_COST[k]):
			return ""
	for k in TraitsData.REFORGE_COST:
		b.remove(k, int(TraitsData.REFORGE_COST[k]))
	var t := TraitsData.roll(id, null, b.trait_at(i) if b.trait_at(i) != "" else "-")
	b.slots[i]["tratto"] = t
	b.changed.emit()
	return t


## Innesta un'Essenza (di una creatura antica) sull'oggetto nella casella i: il suo tratto speciale prende il posto di
## quello che c'era. Restituisce il tratto nuovo, o "" se non si può.
static func graft(b: Bisaccia, i: int, essence: String) -> String:
	var id := b.id_at(i)
	if id == "" or not Bisaccia.is_gear(id) or not TraitsData.can_graft(essence, id) or not b.remove(essence, 1):
		return ""
	var t := String(ItemsData.get_item(essence)["graft"])
	b.slots[i]["tratto"] = t
	b.changed.emit()
	return t


## Avvolge una fascia (`FormsData.FASCE`) sul manico dell'oggetto nella casella i (al Telaio, voce 50): consuma il
## materiale, la fascia nuova prende il posto della vecchia. Vero se è riuscito.
static func wrap(b: Bisaccia, i: int, fascia: String) -> bool:
	var it := ItemsData.get_item(b.id_at(i))
	var fd: Dictionary = FormsData.FASCE.get(fascia, {})
	if fd.is_empty() or not String(it.get("form", "")) in FormsData.WRAPPABLE or b.count(String(fd["item"])) < int(fd["n"]):
		return false
	b.remove(String(fd["item"]), int(fd["n"]))
	var dati: Dictionary = b.slots[i].get("dati", {}).duplicate(true)
	dati["fascia"] = fascia
	b.slots[i]["dati"] = dati
	b.changed.emit()
	return true


## «Serve: 10 Legno di lanterna, 1 Gelatina di muschio — al Ceppo del Giardiniere»
static func describe(r: Dictionary, b: Bisaccia) -> String:
	var parts := []
	for k in r["in"]:
		var have := b.count(k)
		var need := int(r["in"][k])
		parts.append("%d %s (%d)" % [need, ItemsData.get_item(k)["name"], have])
	var where := "a mano, ovunque" if String(r["station"]) == "" else "vicino a: " + String(StationsData.STATIONS[r["station"]]["name"])
	var desc := String(ItemsData.get_item(r["out"]).get("desc", ""))
	return "Serve: %s\n%s%s" % [", ".join(parts), where, ("\n" + desc) if desc != "" else ""]
