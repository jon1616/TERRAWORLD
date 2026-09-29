class_name MbMungitrice
extends MachineBehavior
## La Mungitrice del recinto: con i suoi pulsi porta nella sua cassetta i prodotti della mandria (i `produce` di
## `HerdData.TAME`: lana, miele, gelatina…) che stanno nei Recinti-mangiatoia vicini (a `R` tessere). Il cibo resta
## nella mangiatoia (anche quello che qualche creatura produce, come la gelatina). Così il recinto non si ferma quando
## la mangiatoia è piena.

const R := 6
const EVERY := 2.0

static var _products := {}


static func products() -> Dictionary:
	if _products.is_empty():
		var food := {}
		for sp in HerdData.TAME:
			for f in HerdData.TAME[sp].get("diet", []):
				food[String(f)] = true
		for sp in HerdData.TAME:
			var p: Variant = HerdData.TAME[sp].get("produce")
			if p is Array and not (p as Array).is_empty() and not food.has(String(p[0])):
				_products[String(p[0])] = true            # il cibo (anche se qualcuno lo produce) resta nella mangiatoia
	return _products


func tick(mc: Machine, e: Energy, dt: float) -> void:
	if not mc.on() or mc.power < 0.99:
		return
	var t := float(mc.get_meta("t", 0.0)) - dt
	if t > 0.0:
		mc.set_meta("t", t)
		return
	mc.set_meta("t", EVERY)
	var w: World = e.m.world
	var box: Bisaccia = w.chest_at(mc.o)
	var prod := products()
	for o: Vector2i in w.stations:
		if String(w.stations[o]) != "recinto" or absi(o.x - mc.o.x) > R or absi(o.y - mc.o.y) > R or not w.chests.has(o):
			continue
		var pen: Bisaccia = w.chests[o]
		for i in pen.slots.size():
			var id := pen.id_at(i)
			if id == "" or not prod.has(id):
				continue
			var n := int(pen.slots[i]["n"])
			var rest := box.add(id, n)
			if rest < n:
				mc.st["munti"] = int(mc.st.get("munti", 0)) + n - rest
				pen.slots[i]["n"] = rest
				if rest == 0:
					pen.slots[i] = {}
		pen.changed.emit()


func state_text(mc: Machine, e: Energy) -> String:
	return super.state_text(mc, e) + " · raccolti dai recinti: %d" % int(mc.st.get("munti", 0))
