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


## Ricette usabili con queste stazioni (quelle «a mano» sempre).
static func available(near: Dictionary) -> Array:
	return RecipesData.all().filter(func(r: Dictionary) -> bool: return String(r["station"]) == "" or near.has(String(r["station"])))


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
