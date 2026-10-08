class_name StratumBanner
extends Control
## La scritta grande che compare entrando in uno strato nuovo: il nome in alto al centro, una riga sotto, poi svanisce.

var _title: Label
var _sub: Label
var _tw: Tween


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title = _label(34, 146)
	# (voce 276) il nome nel carattere di pixel a 4×, con un'ombra netta: un'insegna, non una scritta
	_title.remove_theme_font_size_override("font_size")
	_title.remove_theme_constant_override("outline_size")
	UiFonts.apply(_title, 4, Color(0, 0, 0, 0), true)
	_title.add_theme_constant_override("shadow_offset_x", 4)
	_title.add_theme_constant_override("shadow_offset_y", 4)
	_title.offset_bottom = 146 + UiFonts.size(4)
	_sub = _label(16, 196)
	modulate.a = 0.0


func _label(size: int, y: float) -> Label:
	var l := Label.new()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	l.offset_top = y
	l.offset_bottom = y + size * 1.5
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.05, 0.9))
	l.add_theme_constant_override("outline_size", 8)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l


func show_stratum(title: String, sub: String, col: Color) -> void:
	# larghezza presa dalla finestra a ogni comparsa: sotto un CanvasLayer le ancore non bastano
	var w := get_viewport_rect().size.x
	for l in [_title, _sub]:
		(l as Label).position.x = 0.0
		(l as Label).size.x = w
	_place()
	_title.text = title
	_title.add_theme_color_override("font_color", col)
	_sub.text = sub
	_sub.add_theme_color_override("font_color", Color(0.85, 0.88, 0.9))
	if _tw:
		_tw.kill()
	_tw = create_tween()
	_tw.tween_property(self, "modulate:a", 1.0, 0.6)
	_tw.tween_interval(2.6)
	_tw.tween_property(self, "modulate:a", 0.0, 1.4)


## (voce 291) sotto le barre dei boss, se ce ne sono (prima l'insegna passava sopra la barra della Regina). Si ricontrolla
## a ogni fotogramma mentre si vede: la barra scende quando il filo va a capo.
func _place() -> void:
	var dy := 0.0
	for n in get_tree().get_nodes_in_group("boss_bar"):
		var bb := n as Control
		if bb != null and bb.visible:
			dy = maxf(dy, bb.global_position.y - global_position.y + 34.0 - 146.0)
	_title.offset_top = 146.0 + dy
	_title.offset_bottom = _title.offset_top + UiFonts.size(4)
	_sub.offset_top = 196.0 + dy
	_sub.offset_bottom = _sub.offset_top + 24.0


func _process(_dt: float) -> void:
	if modulate.a > 0.01:
		_place()
