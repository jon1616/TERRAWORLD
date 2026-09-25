class_name Boons
extends Node
## Effetti a tempo delle pozioni e luce che il Germogliato porta con sé:
##   bagliore   il Germogliato brilla (luce più ampia e chiara attorno a lui)
##   scorza     +8 Scorza
## La Lanterna di Linfa, tenuta in mano, dà una luce turchese. Gli effetti attivi si leggono sotto Vita e Linfa.
## Non si salvano: bere una pozione e uscire la spreca, come dormire con una candela accesa.

const SCORZA := 8
const LIGHT_BAGLIORE := Color(1.9, 1.7, 1.3)
const LIGHT_LANTERNA := Color(1.0, 2.0, 1.9)
const NAMES := {"bagliore": "Bagliore", "scorza": "Scorza di corteccia", "vigore": "Vigore"}
const VIGORE := 1.2                    # danno ×1,2 con la Pozione di vigore

var m: Node2D
var active := {}                       # nome -> secondi che restano
var halo_mult := 1.0                   # accessori: alone più ampio (Anello di lucciola)
var _label: Label
var _last_light := Color.BLACK


func setup(main: Node2D) -> void:
	m = main
	m.actions.boon.connect(add)
	_label = Label.new()
	_label.position = Vector2(1600 - 420, 84)
	_label.size = Vector2(400, 40)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label.add_theme_font_size_override("font_size", 13)
	_label.add_theme_color_override("font_color", Color("#b8f4f0"))
	_label.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_label.add_theme_constant_override("outline_size", 5)
	m.hud.add_child(_label)


func add(boon_name: String, secs: float) -> void:
	active[boon_name] = maxf(float(active.get(boon_name, 0.0)), secs)
	m.hud.toast("%s per %d minuti" % [NAMES.get(boon_name, boon_name), roundi(secs / 60.0)])


func _process(dt: float) -> void:
	if not m.built:
		return
	var text := ""
	for k in active.keys():
		active[k] = float(active[k]) - dt
		if float(active[k]) <= 0.0:
			active.erase(k)
			continue
		var t := int(active[k])
		text += "%s %d:%02d   " % [NAMES.get(k, k), t / 60, t % 60]
	_label.text = text
	m.vitals.scorza_bonus = SCORZA if active.has("scorza") else 0
	var l: Color = LightMap.PLAYER * halo_mult
	if active.has("bagliore"):
		l = LIGHT_BAGLIORE
	if String(ItemsData.get_item(m.hud.current()["id"]).get("kind", "")) == "lanterna":
		l = Color(maxf(l.r, LIGHT_LANTERNA.r), maxf(l.g, LIGHT_LANTERNA.g), maxf(l.b, LIGHT_LANTERNA.b))
	if l != _last_light:
		_last_light = l
		m.light.player_light = l
		m.light.dirty = true
