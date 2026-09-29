class_name MbEsposizione
extends MachineBehavior
## La Teca d'esposizione: una cassetta di una casella; con i suoi pulsi e qualcosa dentro si illumina. Nelle stanze è un
## mobile bello e il trofeo dentro conta per la sala dei trofei (`Rooms` guarda i contenitori).


func tick(mc: Machine, e: Energy, _dt: float) -> void:
	mc.lit = mc.on() and mc.power >= 0.99 and not e.m.world.chest_at(mc.o).is_empty()


func state_text(mc: Machine, e: Energy) -> String:
	var box: Bisaccia = e.m.world.chest_at(mc.o)
	if box.is_empty():
		return "vuota: mettici un trofeo o un oggetto unico (il pannello apre la teca)"
	return "espone: %s" % String(ItemsData.get_item(box.id_at(0)).get("name", box.id_at(0)))
