class_name MapPanel
extends Control
## La mappa a schermo intero (tasto M): ciò che si è esplorato, nero il resto. Rotella = ingrandisci/rimpicciolisci,
## trascinare con il clic sinistro = spostarsi. Segni: il Germogliato, la partenza, il Cuore del mondo, i portali, le
## ceste e gli scrigni (solo se il posto è già stato visto). M o Esc per chiudere.

const ZOOMS := [0.5, 1.0, 2.0, 4.0, 8.0]
const MARK := {"player": Color("#ffb84a"), "spawn": Color("#8ef0d8"), "cuore": Color("#ff7a8a"),
	"portale": Color("#6ff0d8"), "scrigno": Color("#e8fff8"), "fagotto": Color("#ff5a4a"),
	"reliquiario": Color("#ffd24a"), "tana": Color("#c060ff"), "altare": Color("#5cc8cc")}

var m: Node2D
var reveal: MapReveal
var zoom := 1
var center := Vector2.ZERO            # cella al centro dello schermo
var _drag := false
var _legend: RichTextLabel


func setup(main: Node2D, r: MapReveal) -> void:
	m = main
	reveal = r
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_legend = RichTextLabel.new()
	_legend.bbcode_enabled = true
	_legend.fit_content = true
	_legend.position = Vector2(20, 860)
	_legend.size = Vector2(1400, 30)
	_legend.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_legend.add_theme_font_size_override("normal_font_size", 14)
	var t := "[color=#cfeee4]Mappa · rotella: ingrandisci · trascina: spostati · M o Esc: chiudi[/color]     "
	for k in [["player", "tu"], ["spawn", "partenza"], ["cuore", "Cuore del mondo"], ["portale", "portale"], ["scrigno", "scrigni e ceste"], ["fagotto", "il tuo fagotto"], ["reliquiario", "reliquiari"], ["tana", "tane dei Custodi"], ["altare", "altari"]]:
		t += "[color=#%s]●[/color] [color=#cfeee4]%s[/color]   " % [(MARK[k[0]] as Color).to_html(false), k[1]]
	_legend.text = t
	add_child(_legend)


func toggle() -> void:
	visible = not visible
	if visible:
		# misura presa dalla finestra: sotto un CanvasLayer le ancore da sole non bastano
		position = Vector2.ZERO
		size = get_viewport_rect().size
		reveal.refresh_texture()
		center = m.player.position / 16.0
		queue_redraw()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed:
		if e.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = mini(zoom + 1, ZOOMS.size() - 1)
		elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = maxi(zoom - 1, 0)
		elif e.button_index == MOUSE_BUTTON_LEFT:
			_drag = true
		queue_redraw()
	elif e is InputEventMouseButton and not e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		_drag = false
	elif e is InputEventMouseMotion and _drag:
		center -= e.relative / float(ZOOMS[zoom])
		queue_redraw()


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo:
		if e.keycode == KEY_M:
			toggle()
			get_viewport().set_input_as_handled()
		elif e.keycode == KEY_ESCAPE and visible:
			toggle()
			get_viewport().set_input_as_handled()


## Da cella del mondo a punto sullo schermo.
func to_screen(c: Vector2) -> Vector2:
	return size * 0.5 + (c - center) * float(ZOOMS[zoom])


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.02, 0.03))
	if reveal.tex == null:
		return
	var z: float = ZOOMS[zoom]
	var w: World = m.world
	draw_texture_rect(reveal.tex, Rect2(to_screen(Vector2.ZERO), Vector2(w.w, w.h) * z), false)
	for o in w.stations:
		var id := String(w.stations[o])
		var key := ""
		if id.begins_with("cuore"):
			key = "cuore"
		elif id == "portale":
			key = "portale"
		elif id == "scrigno" or id == "cesta":
			key = "scrigno"
		elif id == "fagotto":
			key = "fagotto"
		elif id == "reliquiario":
			key = "reliquiario"
		elif id.begins_with("bozzolo") and id != "bozzolo_rotto":
			key = "tana"
		elif id == "altare":
			key = "altare"
		if key != "" and w.explored[o.y * w.w + o.x] != 0:
			_mark(Vector2(o) + Vector2(1, 1), MARK[key], 5.0)
	_mark(Vector2(w.spawn), MARK["spawn"], 6.0)
	_mark(m.player.position / 16.0, MARK["player"], 7.0)


func _mark(c: Vector2, col: Color, r: float) -> void:
	var p := to_screen(c)
	draw_circle(p, r + 2.0, Color(0.02, 0.03, 0.05))
	draw_circle(p, r, col)
