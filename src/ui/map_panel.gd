class_name MapPanel
extends Control
## La mappa a schermo intero (tasto M): ciò che si è esplorato, nero il resto. Rotella = ingrandisci/rimpicciolisci,
## trascinare con il clic sinistro = spostarsi. Segni: il Germogliato, la partenza, il Cuore del mondo, i portali, le
## ceste e gli scrigni (solo se il posto è già stato visto). M o Esc per chiudere.
## I segnali del giocatore (30 set 2026): clic destro mette o cambia un triangolo con un nome (`MapSignals`). Con il
## mouse sopra un segno qualunque, del gioco o del giocatore, la scheda dice che cos'è (`_hits`, `_spot`).

const ZOOMS := [0.5, 1.0, 2.0, 4.0, 8.0]
const MARK := {"player": Color("#ffb84a"), "spawn": Color("#8ef0d8"), "cuore": Color("#ff7a8a"),
	"portale": Color("#6ff0d8"), "scrigno": Color("#e8fff8"), "fagotto": Color("#ff5a4a"),
	"reliquiario": Color("#ffd24a"), "tana": Color("#c060ff"), "altare": Color("#5cc8cc"), "firma": Color("#fff08a"),
	"radice": Color("#72f0d0"), "incontro": Color("#f0c070")}

var m: Node2D
var reveal: MapReveal
var zoom := 1
var center := Vector2.ZERO            # cella al centro dello schermo
var _drag := false
var _legend: RichTextLabel
var travel_from := Vector2i(-1, -1)    # voce 38: aperta da una Radice viandante, un clic su un'altra ci porta
var _hint: Label
var _press := Vector2.ZERO
var signals: MapSignals                # la finestrella dei segnali del giocatore
var _hits: Array = []                  # i segni disegnati: [punto sullo schermo, nome, raggio], rifatti a ogni disegno
var _spot: Control                     # un controllo invisibile sopra il segno sotto il mouse: porta la sua scheda
var _spot_i := -1


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
	_legend.size = Vector2(1560, 30)
	_legend.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_legend.add_theme_font_size_override("normal_font_size", 16)
	var t := "[color=#cfeee4]Rotella: zoom · trascina: spostati · clic destro: segnale · M/Esc: chiudi[/color]    "
	for k in [["player", "tu"], ["spawn", "partenza"], ["cuore", "Cuore"], ["portale", "portale"], ["scrigno", "scrigni e ceste"], ["fagotto", "il tuo fagotto"], ["reliquiario", "reliquiari"], ["tana", "tane dei Custodi"], ["altare", "altari"], ["radice", "radici"], ["firma", "firma del mondo"]]:
		t += "[color=#%s]●[/color] [color=#cfeee4]%s[/color]   " % [(MARK[k[0]] as Color).to_html(false), k[1]]
	_legend.text = t + "[color=#ffd24a]▲[/color] [color=#cfeee4]i tuoi segnali[/color]"
	add_child(_legend)
	_hint = Label.new()
	_hint.position = Vector2(20, 20)
	_hint.add_theme_font_size_override("font_size", 22)
	_hint.add_theme_color_override("font_color", Color("#8ef0d8"))
	_hint.add_theme_color_override("font_outline_color", Color("#050c10"))
	_hint.add_theme_constant_override("outline_size", 6)
	_hint.text = "La radice ascolta: clic su un'altra Radice viandante per andarci"
	_hint.visible = false
	add_child(_hint)
	signals = MapSignals.new()
	add_child(signals)
	signals.setup(m)


## Aperta da una Radice viandante: si sceglie dove andare.
func open_travel(from: Vector2i) -> void:
	if not visible:
		toggle()
	travel_from = from
	_hint.visible = true
	# si inquadrano tutte le radici: il centro del loro riquadro, e l'ingrandimento più grande che le contiene
	var box := Rect2(Vector2(from), Vector2.ZERO)
	for o in m.travel.roots():
		box = box.expand(Vector2(o))
	center = box.get_center()
	zoom = 0
	for k in ZOOMS.size():
		if box.size.x * float(ZOOMS[k]) <= size.x * 0.8 and box.size.y * float(ZOOMS[k]) <= size.y * 0.7:
			zoom = k
	queue_redraw()


func toggle() -> void:
	visible = not visible
	travel_from = Vector2i(-1, -1)
	signals.close()
	_hint.visible = false
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
			_press = e.position
		elif e.button_index == MOUSE_BUTTON_RIGHT and travel_from.x < 0:
			right_click(get_local_mouse_position())
		queue_redraw()
	elif e is InputEventMouseButton and not e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		_drag = false
		if travel_from.x >= 0 and e.position.distance_to(_press) < 6.0:
			pick_root(e.position)
	elif e is InputEventMouseMotion and _drag:
		center -= e.relative / float(ZOOMS[zoom])
		queue_redraw()


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo:
		if Keys.pressed(e, "mappa"):
			toggle()
			get_viewport().set_input_as_handled()
		elif e.keycode == KEY_ESCAPE and visible:
			if signals.visible:
				signals.close()             # Esc chiude prima la finestrella del segnale
			else:
				toggle()
			get_viewport().set_input_as_handled()


## Clic destro: sopra un tuo segnale lo si cambia, altrove se ne mette uno nuovo.
func right_click(at: Vector2) -> void:
	var all := MapSignals.list(m.world_meta)
	var best := -1
	var bd := 14.0
	for i in all.size():
		var d := to_screen(MapSignals.pos_of(all[i])).distance_to(at)
		if d <= bd:
			best = i
			bd = d
	if best >= 0:
		signals.open_edit(best, at)
	else:
		var c := center + (at - size * 0.5) / float(ZOOMS[zoom])
		signals.open_new(Vector2i(clampi(floori(c.x), 0, m.world.w - 1), clampi(floori(c.y), 0, m.world.h - 1)), at)


## Il segno sotto il mouse ha la sua scheda: un controllo invisibile gli sta sopra (uno nuovo per ogni segno, così il
## ritardo dei suggerimenti vale per ciascuno), e i clic passano alla mappa.
func _process(_dt: float) -> void:
	if not visible:
		return
	var at := get_local_mouse_position()
	var found := -1
	if not _drag and not signals.visible:
		var bd := 1e9
		for i in _hits.size():
			var d := (_hits[i][0] as Vector2).distance_to(at)
			if d <= float(_hits[i][2]) + 4.0 and d < bd:
				found = i
				bd = d
	if found == _spot_i and (found < 0 or _spot != null):
		if _spot != null:
			_spot.position = (_hits[found][0] as Vector2) - _spot.size * 0.5
		return
	if _spot != null:
		_spot.queue_free()
		_spot = null
	_spot_i = found
	if found < 0:
		return
	var r := float(_hits[found][2]) + 4.0
	var tip := String(_hits[found][1])
	_spot = Control.new()
	_spot.mouse_filter = Control.MOUSE_FILTER_PASS
	_spot.size = Vector2(r, r) * 2.0
	_spot.position = (_hits[found][0] as Vector2) - _spot.size * 0.5
	Tips.attach(_spot, func() -> Variant: return tip)
	add_child(_spot)
	move_child(_spot, 0)                        # sotto la legenda e la finestrella


## Il nome di un segno per la sua scheda.
func _hit(c: Vector2, label: String, r: float) -> void:
	_hits.append([to_screen(c), label, r])


## Il clic in modo viaggio: la radice più vicina al punto (entro 14 pixel) diventa la meta.
func pick_root(at: Vector2) -> bool:
	for o in m.travel.roots():
		if o != travel_from and to_screen(Vector2(o) + Vector2(1, 1)).distance_to(at) <= 14.0:
			var from := travel_from
			toggle()
			return m.travel.go(from, o)
	return false


## Da cella del mondo a punto sullo schermo.
func to_screen(c: Vector2) -> Vector2:
	return size * 0.5 + (c - center) * float(ZOOMS[zoom])


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.02, 0.03))
	if reveal.tex == null:
		return
	var z: float = ZOOMS[zoom]
	var w: World = m.world
	_hits.clear()
	draw_texture_rect(reveal.tex, Rect2(to_screen(Vector2.ZERO), Vector2(w.w, w.h) * z), false)
	for o in w.stations:
		var id := String(w.stations[o])
		var key := ""
		if id.begins_with("cuore"):
			key = "cuore"
		elif id == "portale":
			key = "portale"
		elif ChestsData.is_chest(id):
			key = "scrigno"
		elif id == "fagotto":
			key = "fagotto"
		elif id == "reliquiario":
			key = "reliquiario"
		elif id.begins_with("bozzolo") and id != "bozzolo_rotto":
			key = "tana"
		elif id == "altare":
			key = "altare"
		elif id == "radice_viandante":
			key = "radice"
		elif EncountersData.KINDS.has(id):
			key = "incontro"                           # voce 303: i piccoli incontri (una volta visto il posto)
		# le radici viandanti le ha piantate il Germogliato: si vedono anche dove la mappa è ancora nera
		if key != "" and (w.explored[o.y * w.w + o.x] != 0 or key == "radice"):
			_mark(Vector2(o) + Vector2(1, 1), MARK[key], 8.0 if key == "radice" and travel_from.x >= 0 else 5.0)
			_hit(Vector2(o) + Vector2(1, 1), _station_name(o, id, key), 5.0)
	# la firma del mondo, una volta trovata (voce 44)
	if m.signature != null and m.signature.found():
		_mark(Vector2(m.signature.center()), MARK["firma"], 9.0)
		_hit(Vector2(m.signature.center()), "La firma del mondo", 9.0)
	# i segni delle stele e delle catene (voce 68): si vedono anche dove la mappa è ancora nera, con il nome
	for sg in m.world_meta.get("segni", []):
		var sc := to_screen(Vector2(float(sg[0]), float(sg[1])))
		var col := Color(String(sg[3]))
		draw_colored_polygon(PackedVector2Array([sc + Vector2(0, -9), sc + Vector2(8, 0), sc + Vector2(0, 9), sc + Vector2(-8, 0)]),
			Color(0.02, 0.03, 0.05))
		draw_colored_polygon(PackedVector2Array([sc + Vector2(0, -7), sc + Vector2(6, 0), sc + Vector2(0, 7), sc + Vector2(-6, 0)]), col)
		draw_string(ThemeDB.fallback_font, sc + Vector2(11, 5), String(sg[2]), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, col)
		_hit(Vector2(float(sg[0]), float(sg[1])), String(sg[2]), 8.0)
	# i segnali del giocatore: triangoli, visibili anche dove la mappa è nera
	for s in MapSignals.list(m.world_meta):
		MapSignals.triangle(self, to_screen(MapSignals.pos_of(s)), Color(String(s.get("c", "ffb84a"))), 7.0)
		_hit(MapSignals.pos_of(s), MapSignals.name_of(s), 8.0)
	_mark(Vector2(w.spawn), MARK["spawn"], 6.0)
	_hit(Vector2(w.spawn), "La partenza", 6.0)
	_mark(m.player.position / 16.0, MARK["player"], 7.0)
	_hit(m.player.position / 16.0, "Tu", 7.0)
	# voce 95: il contatore dei segreti
	if m.secrets != null and m.secrets.counts()[1] > 0:
		var sc2: Array = m.secrets.counts()
		draw_string(ThemeDB.fallback_font, Vector2(size.x - 318, 34), "Segreti trovati: %d su %d" % [sc2[0], sc2[1]],
			HORIZONTAL_ALIGNMENT_RIGHT, 300, 18, Color("#ffd24a") if sc2[0] == sc2[1] else Color("#8ef0d8"))


## Il nome di una stazione segnata: una cassa con un nome dato dal giocatore lo mostra.
func _station_name(o: Vector2i, id: String, key: String) -> String:
	var base := String(StationsData.STATIONS.get(id, {}).get("name", id))
	if key == "scrigno":
		var cfg: Dictionary = m.world_meta.get("casse", {}).get("%d,%d" % [o.x, o.y], {})
		if String(cfg.get("nome", "")) != "":
			return "%s «%s»" % [base, String(cfg["nome"])]
	if key == "fagotto":
		return "Il tuo fagotto"
	return base


func _mark(c: Vector2, col: Color, r: float) -> void:
	var p := to_screen(c)
	draw_circle(p, r + 2.0, Color(0.02, 0.03, 0.05))
	draw_circle(p, r, col)
