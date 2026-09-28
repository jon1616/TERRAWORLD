class_name Flight
extends Node2D
## Il volo (voce 90, dati in `FlightData`): legge le ali indossate nel posto del mantello e le dà al Germogliato
## (`Player.wings`; il volo stesso è in `Player._step`), disegna le ali dietro di lui (chiuse a terra, aperte che
## battono in volo) e la barra dell'autonomia sopra la testa quando non è piena.

var m: Node2D
var id := ""                           # le ali indossate ("" = nessuna)
var _flap := 0.0
var _mount := ""                       # Roadmap 16: le ali della cavalcatura che vola ("" = nessuna)


func setup(main: Node2D) -> void:
	m = main
	get_parent().remove_child(self)        # `main._mount` lo mette nella scena: le ali invece vanno sul Germogliato
	m.player.add_child(self)
	m.player.move_child(self, 0)           # prima del disegno del Germogliato: le ali stanno dietro
	m.character.bisaccia.changed.connect(refresh)
	refresh()


func refresh() -> void:
	var worn := String(m.character.bisaccia.equip.get("mantello", ""))
	id = String(ItemsData.get_item(worn).get("wings", "")) if worn != "" else ""
	_mount = _mount_wings()
	if _mount != "":
		id = _mount                            # in sella a una creatura che vola: vola lei
	var w: Dictionary = FlightData.get_wings(id)
	var p: Player = m.player
	p.wings = w
	p.fly_left = minf(p.fly_left, float(w.get("time", 0.0)))
	visible = not w.is_empty() and not w.get("hidden", false)
	queue_redraw()


## Le ali della cavalcatura su cui si è in sella ("" se non vola).
func _mount_wings() -> String:
	if m.get("herd") == null or m.herd.riding < 0:
		return ""
	return String(Herd.tame_data(m.herd.rec_of(m.herd.riding)).get("mount_wings", ""))


func _process(dt: float) -> void:
	if _mount_wings() != _mount:
		refresh()
	if id == "":
		return
	var p: Player = m.player
	_flap += dt * (14.0 if p.flying else 3.0)
	queue_redraw()


func _draw() -> void:
	if id == "":
		return
	var p: Player = m.player
	var w: Dictionary = FlightData.get_wings(id)
	var col := Color(String(w["color"]))
	var open := p.flying or p.gliding
	var beat := sin(_flap) if p.flying else 0.0
	var s := Vector2(-p.facing * 2.0, -9.0)          # le spalle
	for side in [-1.0, 1.0]:
		var k: float = side * (1.0 if open else 0.35)
		var up := -10.0 + beat * 7.0 if open else 4.0
		# una foglia-ala: bordo alto fino alla punta, poi tre penne che tornano alla spalla
		var tip := s + Vector2(k * 17.0, up)
		var pts := PackedVector2Array([s, s + Vector2(k * 8.0, up * 0.8 - 2.0), tip,
			s + Vector2(k * 15.0, up * 0.3 + 5.0), s + Vector2(k * 11.0, 6.0 + beat * 2.0),
			s + Vector2(k * 7.0, 8.0), s + Vector2(k * 3.0, 6.0)])
		draw_colored_polygon(pts, Color(col, 0.8))
		pts.append(s)
		draw_polyline(pts, col.darkened(0.5), 1.0)
		for f in [0.45, 0.7]:
			draw_line(s, s + (tip - s) * f + Vector2(0, 5.0 * f), col.lightened(0.35), 1.0)
	# la barra dell'autonomia, sopra la testa
	var full := float(w["time"])
	if p.fly_left < full - 0.01:
		var top := Vector2(-10, -Player.HALF.y - 12.0)
		draw_rect(Rect2(top - Vector2(1, 1), Vector2(22, 5)), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(top, Vector2(20.0 * p.fly_left / maxf(full, 0.01), 3)), col)
