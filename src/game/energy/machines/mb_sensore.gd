class_name MbSensore
extends MachineBehavior
## I sensori (voce 204): comandi che accendono da soli i fili che toccano, a ogni conto del Flusso. Non chiedono pulsi.
## Il tipo è `p.kind` nei dati, le impostazioni nel pannello (`st`):
##   luce      acceso di giorno (o di notte, `st.inv`)
##   orecchio  acceso quando una creatura ostile è entro `st.r` tessere
##   acqua     acceso quando la sua cella ha almeno metà di un liquido (`st.tipo`: acqua, Linfa, brace, qualunque)
##   cassa     guarda il contenitore alla sua sinistra o destra: acceso se è pieno, vuoto o ha qualcosa (`st.se`)
##   riserva   acceso quando le riserve della sua rete sono sotto (o sopra) una soglia (`st.se`)
##   orologio  un colpo ogni `st.periodo` secondi
##   meteo     acceso con la pioggia, il temporale o qualunque maltempo (`st.tempo`)

const EARS := [6, 10, 16]
const PERIODS := [1.0, 5.0, 30.0, 120.0, 600.0]
const BAD := ["pioggia", "temporale", "nebbia", "cenere", "bufera"]


func _kind(mc: Machine) -> String:
	return String((mc.d.get("p", {}) as Dictionary).get("kind", ""))


func tick(mc: Machine, e: Energy, dt: float) -> void:
	var k := _kind(mc)
	if k == "orologio":
		var t := float(mc.st.get("t", 0.0)) + dt
		var per := float(mc.st.get("periodo", 5.0))
		if t >= per:
			t = fmod(t, per)
			e.impulse.pulse(mc)
			mc.set_meta("flash", 0.3)
		mc.st["t"] = t
		return
	var v := read(mc, e)
	if v != bool(mc.st.get("out", false)):
		e.impulse.set_out(mc, v)
		e.refresh_look(mc)


func on_impulse(_mc: Machine, _e: Energy, _k: int, _kind: String) -> void:
	pass


## Il valore del sensore adesso.
func read(mc: Machine, e: Energy) -> bool:
	var w: World = e.m.world
	match _kind(mc):
		"luce":
			var day: bool = e.m.day.daylight() > 0.5
			return day != bool(mc.st.get("inv", false))
		"orecchio":
			var r := float(mc.st.get("r", 10)) * 16.0
			for c in e.m.fauna.list:
				if is_instance_valid(c) and c.tame == null and c.damage > 0 and c.position.distance_to(mc.center()) <= r:
					return true
			return false
		"acqua":
			var lv := w.liq(mc.o.x, mc.o.y)
			if lv < 4:
				return false
			var want := int(mc.st.get("tipo", -1))
			return want < 0 or w.liq_type(mc.o.x, mc.o.y) == want
		"cassa":
			var box := MbBraccio._box_at(e, mc.o + Vector2i(-1, 0))
			if box == null:
				box = MbBraccio._box_at(e, mc.o + Vector2i(1, 0))
			if box == null:
				return false
			match String(mc.st.get("se", "qualcosa")):
				"piena":
					for s in box.slots:
						if s.is_empty():
							return false
					return true
				"vuota":
					return box.is_empty()
			return not box.is_empty()
		"riserva":
			if mc.net < 0:
				return false
			var nt: Dictionary = e.nets[mc.net]
			var fill := float(nt["stored"]) / maxf(float(nt["cap"]), 1.0)
			return fill < 0.25 if String(mc.st.get("se", "sotto")) == "sotto" else fill > 0.75
		"meteo":
			if e.m.get("weather") == null:
				return false
			var id := String(e.m.weather.id)
			match String(mc.st.get("tempo", "pioggia")):
				"pioggia":
					return id == "pioggia" or id == "temporale"
				"temporale":
					return id == "temporale"
			return id in BAD
	return false


func panel_rows(mc: Machine, e: Energy) -> Array:
	var rows := []
	match _kind(mc):
		"luce":
			var inv := bool(mc.st.get("inv", false))
			rows.append(["Acceso", [["di giorno", not inv, func() -> void: mc.st["inv"] = false],
				["di notte", inv, func() -> void: mc.st["inv"] = true]]])
		"orecchio":
			var row := []
			for r in EARS:
				var rr := int(r)
				row.append(["%d tessere" % rr, int(mc.st.get("r", 10)) == rr, func() -> void: mc.st["r"] = rr])
			rows.append(["Sente fino a", row])
		"acqua":
			var row2 := []
			for opt in [[-1, "qualunque"], [LiquidsData.ACQUA, "acqua"], [LiquidsData.LINFA, "Linfa"], [LiquidsData.BRACE, "brace"]]:
				var tv := int(opt[0])
				row2.append([String(opt[1]), int(mc.st.get("tipo", -1)) == tv, func() -> void: mc.st["tipo"] = tv])
			rows.append(["Liquido", row2])
		"cassa":
			var row3 := []
			for opt in [["qualcosa", "ha qualcosa"], ["piena", "è piena"], ["vuota", "è vuota"]]:
				var sv := String(opt[0])
				row3.append([String(opt[1]), String(mc.st.get("se", "qualcosa")) == sv, func() -> void: mc.st["se"] = sv])
			rows.append(["Acceso se la cassa", row3])
		"riserva":
			var se := String(mc.st.get("se", "sotto"))
			rows.append(["Acceso se le riserve", [["sono sotto un quarto", se == "sotto", func() -> void: mc.st["se"] = "sotto"],
				["sono oltre tre quarti", se == "sopra", func() -> void: mc.st["se"] = "sopra"]]])
		"orologio":
			var row4 := []
			for per in PERIODS:
				var pv := float(per)
				var lbl := ("%d s" % int(pv)) if pv < 60.0 else ("%d min" % int(pv / 60.0))
				row4.append([lbl, is_equal_approx(float(mc.st.get("periodo", 5.0)), pv), func() -> void: mc.st["periodo"] = pv])
			rows.append(["Un colpo ogni", row4])
		"meteo":
			var tv2 := String(mc.st.get("tempo", "pioggia"))
			rows.append(["Acceso con", [["la pioggia", tv2 == "pioggia", func() -> void: mc.st["tempo"] = "pioggia"],
				["il temporale", tv2 == "temporale", func() -> void: mc.st["tempo"] = "temporale"],
				["ogni maltempo", tv2 == "maltempo", func() -> void: mc.st["tempo"] = "maltempo"]]])
	e.refresh_look(mc)
	return rows


func state_text(mc: Machine, _e: Energy) -> String:
	if _kind(mc) == "orologio":
		return "un colpo ogni %s" % (("%d s" % int(mc.st.get("periodo", 5.0))) if float(mc.st.get("periodo", 5.0)) < 60.0 \
			else ("%d min" % int(float(mc.st.get("periodo", 5.0)) / 60.0)))
	return "acceso" if bool(mc.st.get("out", false)) else "spento"
