class_name PortalTip
extends PanelContainer
## Il riquadro che compare con il mouse sopra un portale (richiesta dell'utente, 26 set 2026): la scheda di
## `PortalInfo`, accanto al mouse. Il testo si rifà solo quando cambia il portale (leggere il mondo salvato costa),
## non compare con un pannello aperto.

const WIDTH := 460.0

var m: Node2D
var _text: RichTextLabel
var _at := Vector2i(-1, -1)
var _cell := Vector2i(-99999, -99999)
var pinned := false                    # nelle prove: resta dov'è, senza seguire il mouse


func setup(main: Node2D) -> void:
	m = main
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.02, 0.05, 0.06, 0.94)
	sb.border_color = Color("#8ef0d8")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(12)
	add_theme_stylebox_override("panel", sb)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.fit_content = true
	_text.scroll_active = false
	_text.custom_minimum_size = Vector2(WIDTH, 0)
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text.add_theme_font_size_override("normal_font_size", 14)
	add_child(_text)


func _process(_dt: float) -> void:
	if pinned:
		return
	if not m.built or m.hud.is_open():
		_hide()
		_cell = Vector2i(-99999, -99999)       # richiuso il pannello, si ricontrolla la cella
		return
	var c: Vector2i = m.actions.mouse_cell()
	if c != _cell:
		_cell = c
		var st: Dictionary = m.world.station_at(c)
		var o: Vector2i = st.get("origin", Vector2i(-1, -1))
		if st.is_empty() or String(st["id"]) != "portale":
			_hide()
			return
		if o != _at or not visible:
			_at = o
			_text.text = PortalInfo.text(m.portal, o)
			reset_size()
			visible = true
	if visible:
		_place()


func _hide() -> void:
	visible = false
	_at = Vector2i(-1, -1)


## Accanto al mouse, dentro lo schermo.
func _place() -> void:
	var vp := get_viewport_rect().size
	var mp := get_viewport().get_mouse_position()
	var p := mp + Vector2(24, 16)
	if p.x + size.x > vp.x - 8:
		p.x = mp.x - size.x - 24
	p.y = clampf(p.y, 8, maxf(vp.y - size.y - 8, 8))
	position = p


## Per le prove: la scheda di un portale senza il mouse.
func show_for(o: Vector2i) -> void:
	_at = o
	pinned = true
	_text.text = PortalInfo.text(m.portal, o)
	reset_size()
	visible = true
