class_name MbMietitrice
extends MachineBehavior
## La Mietitrice: con i suoi pulsi, ogni `EVERY` secondi raccoglie le colture mature nel raggio di `R` tessere nella sua
## cassetta (il raccolto e i semi di `CropsData`) e ripianta un seme dove ha raccolto.

const R := 8
const EVERY := 3.0

var _rng := RandomNumberGenerator.new()


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
	for c: Vector2i in w.crops.keys():
		if absi(c.x - mc.o.x) > R or absi(c.y - mc.o.y) > R:
			continue
		var cr: Array = w.crops[c]
		if float(cr[1]) > 0.0:
			continue
		var cd: Dictionary = CropsData.CROPS[String(cr[0])]
		for id in cd["harvest"]:
			var span: Array = cd["harvest"][id]
			box.add(String(id), _rng.randi_range(int(span[0]), int(span[1])))
		var seeds := _rng.randi_range(int(cd["seeds"][0]), int(cd["seeds"][1]))
		# ripianta: un seme torna nella terra, gli altri nella cassetta
		w.crops[c] = [String(cr[0]), float(cd["grow"]), false]
		w.set_decor(c.x, c.y, CropsData.SPROUT)
		if seeds > 1:
			box.add(String(cd["seed"]), seeds - 1)
		e.m.view.refresh_around(c)
		mc.st["raccolti"] = int(mc.st.get("raccolti", 0)) + 1
		e.m.objectives.bump("raccolti")


func state_text(mc: Machine, e: Energy) -> String:
	return super.state_text(mc, e) + " · raccolti: %d" % int(mc.st.get("raccolti", 0))
