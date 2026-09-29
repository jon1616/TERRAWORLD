class_name MbFabbrica
extends MachineBehavior
## Le macchine che fabbricano da sole (il Forno a Linfa, il Frantoio, il Telaio a Linfa): ogni `p.every` secondi di
## lavoro fanno una ricetta del loro banco (`p.station` in `RecipesData`) con ciò che c'è nella loro cassetta, e ci
## mettono il risultato. `p.prefix`: solo le ricette che fanno quell'oggetto (il forno: i lingotti); `p.choose`: la
## ricetta la sceglie il giocatore nel pannello (`st.ricetta`). Senza ingredienti o senza posto aspettano.

var _list := {}                        # banco -> ricette


func _recipes(mc: Machine) -> Array:
	var p: Dictionary = mc.d.get("p", {})
	var st := String(p.get("station", ""))
	if not _list.has(st):
		var out := []
		for r in RecipesData.all():
			if String(r.get("station", "")) != st or r.has("parole") or r.has("lavorazione"):
				continue
			if p.has("prefix") and not String(r["out"]).begins_with(String(p["prefix"])):
				continue
			out.append(r)
		_list[st] = out
	return _list[st]


func _can(box: Bisaccia, r: Dictionary) -> bool:
	for id in r["in"]:
		if box.count(String(id)) < int(r["in"][id]):
			return false
	return box.room_for(String(r["out"])) >= int(r.get("qty", 1))


func tick(mc: Machine, e: Energy, dt: float) -> void:
	mc.lit = false
	if not mc.on() or mc.power < 0.99:
		return
	var box: Bisaccia = e.m.world.chest_at(mc.o)
	var pick := {}
	var want := String(mc.st.get("ricetta", ""))
	for r in _recipes(mc):
		if bool(mc.d["p"].get("choose", false)) and String(r["out"]) != want:
			continue
		if _can(box, r):
			pick = r
			break
	if pick.is_empty():
		mc.st["t"] = 0.0
		return
	mc.lit = true
	var t := float(mc.st.get("t", 0.0)) + dt
	if t >= float(mc.d["p"].get("every", 4.0)):
		t = 0.0
		for id in pick["in"]:
			box.remove(String(id), int(pick["in"][id]))
		box.add(String(pick["out"]), int(pick.get("qty", 1)))
		mc.st["fatti"] = int(mc.st.get("fatti", 0)) + int(pick.get("qty", 1))
		box.changed.emit()
	mc.st["t"] = t


func panel_rows(mc: Machine, e: Energy) -> Array:
	if not bool(mc.d["p"].get("choose", false)):
		return []
	var list := _recipes(mc)
	if list.is_empty():
		return []
	var outs := []
	for r in list:
		if not String(r["out"]) in outs:
			outs.append(String(r["out"]))
	var cur := outs.find(String(mc.st.get("ricetta", "")))
	var name := String(ItemsData.get_item(outs[cur]).get("name", outs[cur])) if cur >= 0 else "nessuna"
	return [["Ricetta", [["◀", false, func() -> void:
		mc.st["ricetta"] = outs[posmod(cur - 1, outs.size())]
		e.refresh_look(mc)], [name, true, func() -> void: pass], ["▶", false, func() -> void:
		mc.st["ricetta"] = outs[posmod(cur + 1, outs.size())]
		e.refresh_look(mc)]]]]


func state_text(mc: Machine, e: Energy) -> String:
	if not mc.on() or mc.power < 0.99:
		return super.state_text(mc, e)
	var made := int(mc.st.get("fatti", 0))
	if bool(mc.d["p"].get("choose", false)) and String(mc.st.get("ricetta", "")) == "":
		return "ferma: scegli la ricetta nel pannello"
	if not mc.lit:
		return "aspetta: mancano gli ingredienti nella cassetta (fatti finora: %d)" % made
	return "lavora (fatti finora: %d)" % made
