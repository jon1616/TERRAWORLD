class_name MbCulla
extends MachineBehavior
## La Culla calda: con i suoi pulsi scalda le Incubatrici vicine (a `R` tessere): le uova che covano lì si schiudono il
## 40% prima (`dati.cova_mult` letto da `Pens.incubate`). Spenta, le uova tornano ai tempi di sempre.

const R := 4
const FAST := 0.6


func tick(mc: Machine, e: Energy, _dt: float) -> void:
	var hot := mc.on() and mc.power >= 0.99
	mc.lit = hot
	var w: World = e.m.world
	for o: Vector2i in w.stations:
		if String(w.stations[o]) != "incubatrice" or absi(o.x - mc.o.x) > R or absi(o.y - mc.o.y) > R or not w.chests.has(o):
			continue
		var box: Bisaccia = w.chests[o]
		for i in box.slots.size():
			if box.id_at(i) != "uovo":
				continue
			var d: Dictionary = box.slots[i].get("dati", {})
			d["cova_mult"] = FAST if hot else 1.0
			box.slots[i]["dati"] = d
