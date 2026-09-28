class_name Minimap
extends Control
## La minimappa (voce 38), in alto a destra sotto la Vita: un ritaglio della mappa esplorata (`MapReveal.image`)
## attorno al Germogliato, 2 pixel per tessera, con i segni delle radici viandanti, dei portali e del Focolare. Si
## copia solo il ritaglio (non si rimanda al disegno tutta la mappa del mondo) cinque volte al secondo. Tasto N:
## mostra o nasconde. Nascosta quando è aperto un pannello.

const TW := 110                        # tessere in larghezza
const TH := 64
const Z := 2.0
const EVERY := 0.2
const MARK := {"radice_viandante": Color("#72f0d0"), "portale": Color("#6ff0d8"), "focolare": Color("#ffb04a"),
	"fagotto": Color("#ff5a4a")}

var m: Node2D
var reveal: MapReveal
var shown := true
var _img: Image
var _tex: ImageTexture
var _origin := Vector2i.ZERO
var _t := 0.0


func setup(main: Node2D, r: MapReveal) -> void:
	m = main
	reveal = r
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(TW, TH) * Z + Vector2(4, 4)
	_img = Image.create_empty(TW, TH, false, Image.FORMAT_RGB8)
	_tex = ImageTexture.create_from_image(_img)
	visible = false


func _process(dt: float) -> void:
	if not m.built or not reveal.ready_img:
		return
	visible = shown and not m.hud.is_open()
	if not visible:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = EVERY
	position = Vector2(get_viewport_rect().size.x - size.x - 16.0, VitalsView.TOP)   # in alto a destra (Vita e Linfa sono in basso)
	var w: World = m.world
	var pc := Vector2i(floori(m.player.position.x / 16.0), floori(m.player.position.y / 16.0))
	_origin = Vector2i(clampi(pc.x - TW / 2, 0, w.w - TW), clampi(pc.y - TH / 2, 0, w.h - TH))
	_img.blit_rect(reveal.image, Rect2i(_origin, Vector2i(TW, TH)), Vector2i.ZERO)
	_tex.update(_img)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.04, 0.05, 0.9))
	draw_texture_rect(_tex, Rect2(Vector2(2, 2), Vector2(TW, TH) * Z), false)
	var w: World = m.world
	var area := Rect2i(_origin, Vector2i(TW, TH))
	for o in w.stations:
		var id := String(w.stations[o])
		if MARK.has(id) and area.has_point(o) and w.explored[o.y * w.w + o.x] != 0:
			_dot(Vector2(o) + Vector2(1, 1), MARK[id], 2.5)
	_dot(m.player.position / 16.0, Color("#ffb84a"), 3.0)
	draw_rect(Rect2(Vector2.ZERO, size), Color("#3aa08a"), false, 1.5)


func _dot(c: Vector2, col: Color, r: float) -> void:
	var p := Vector2(2, 2) + (c - Vector2(_origin)) * Z
	draw_circle(p, r + 1.5, Color(0.02, 0.03, 0.05))
	draw_circle(p, r, col)


func _unhandled_input(e: InputEvent) -> void:
	if Keys.pressed(e, "minimappa"):
		shown = not shown
		get_viewport().set_input_as_handled()
