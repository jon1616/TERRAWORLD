class_name MbRadiceMadre
extends MachineBehavior
## La Radice-madre: accanto al Cuore del mondo (a `REACH` tessere) beve la sua Linfa. Il Cuore guarito (Guardiano
## curato) dà tutti i pulsi; il Cuore ferito (Guardiano sconfitto) ne dà `WOUNDED`; il Cuore che dorme ancora niente.

const REACH := 4
const WOUNDED := 120.0


func _heart(mc: Machine, e: Energy) -> String:
	var w: World = e.m.world
	for y in range(mc.o.y - REACH, mc.o.y + mc.size().y + REACH):
		for x in range(mc.o.x - REACH, mc.o.x + mc.size().x + REACH):
			var st: Dictionary = w.station_at(Vector2i(x, y))
			if not st.is_empty() and String(st["id"]).begins_with("cuore_"):
				return String(st["id"])
	return ""


func produce(mc: Machine, e: Energy) -> float:
	var h := _heart(mc, e)
	if h == "":
		return 0.0
	match String(e.m.world_meta.get("guardiano", "dorme")):
		"curato":
			return float(mc.d["pulsi"])
		"sconfitto":
			return WOUNDED
	return 0.0


func state_text(mc: Machine, e: Energy) -> String:
	if _heart(mc, e) == "":
		return "a secco: va posata accanto al Cuore del mondo (nel Fondo)"
	match String(e.m.world_meta.get("guardiano", "dorme")):
		"curato":
			return "il Cuore guarito dà %s" % Energy.pulsi(mc.made)
		"sconfitto":
			return "il Cuore ferito dà %s" % Energy.pulsi(mc.made)
	return "il Cuore dorme: risolvi il suo Guardiano"
