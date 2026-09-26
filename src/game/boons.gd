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
const LIGHT_TORCIA := Color(1.9, 1.35, 0.75)   # la torcia tenuta in mano: luce calda come quella piantata
## La luce della torcia in mano tremola come una fiamma: ogni FLICKER_STEP secondi cambia un poco d'intensità (due
## onde lente sommate e un soffio a caso). Non più spesso: ogni cambio ricalcola la luce nel suo thread.
const FLICKER_STEP := 0.09
const FLICKER := 0.14
const NAMES := {"bagliore": "Bagliore", "scorza": "Scorza di corteccia", "vigore": "Vigore", "rigoglio": "Rigoglio",
	"passo": "Passo lungo", "scavo": "Minatore", "spine": "Spine", "esca": "Esca", "fortuna": "Fortuna",
	"sazio": "Sazio", "vista": "Occhi della notte"}
const SAZIO := 1.05                    # sazio (voce 33): colpi e corsa un poco più forti, Vita un po' più svelta
const VISTA := Color(0.12, 0.12, 0.15)  # Pozione di notte: un chiarore minimo anche dove la luce non arriva
const RIGOGLIO := 3.0                  # la Vita ricresce tre volte più in fretta (Pozione di rigoglio)
const VIGORE := 1.2                    # danno ×1,2 con la Pozione di vigore

var m: Node2D
var active := {}                       # nome -> secondi che restano
var halo_mult := 1.0                   # accessori: alone più ampio (Anello di lucciola)
var _label: Label
var _last_light := Color.BLACK
var _flick_t := 0.0
var _flick_clock := 0.0
var _flick := 1.0
var _torch_t := 0.0


func setup(main: Node2D) -> void:
	m = main
	m.actions.boon.connect(add)
	_label = Label.new()
	_label.position = Vector2(1600 - 660, 96)       # a sinistra della minimappa, che sta sotto Vita e Linfa
	_label.size = Vector2(400, 40)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label.add_theme_font_size_override("font_size", 13)
	_label.add_theme_color_override("font_color", Color("#b8f4f0"))
	_label.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_label.add_theme_constant_override("outline_size", 5)
	m.hud.add_child(_label)


func add(boon_name: String, secs: float) -> void:
	active[boon_name] = maxf(float(active.get(boon_name, 0.0)), secs)
	var span := "%d minuti" % roundi(secs / 60.0) if secs >= 90.0 else "%d secondi" % roundi(secs)
	m.hud.toast("%s per %s" % [NAMES.get(boon_name, boon_name), span])


## Intensità della fiamma in mano (attorno a 1): aggiornata a piccoli passi, altrimenti ferma.
func _flicker(dt: float) -> float:
	_flick_clock += dt
	_flick_t -= dt
	if _flick_t <= 0.0:
		_flick_t = FLICKER_STEP
		var wave := 0.55 * sin(_flick_clock * 7.3) + 0.3 * sin(_flick_clock * 17.1)
		_flick = 1.0 + FLICKER * (wave + randf_range(-0.35, 0.35))
	return _flick


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
	m.vitals.boon_regen = (RIGOGLIO if active.has("rigoglio") else 1.0) * (1.25 if active.has("sazio") else 1.0)
	m.light.ambient_boost = VISTA if active.has("vista") else Color.BLACK
	# le pozioni dell'Alambicco (voce 25)
	m.player.boon_run = (1.3 if active.has("passo") else 1.0) * (SAZIO if active.has("sazio") else 1.0)
	m.actions.boon_dig = 1.5 if active.has("scavo") else 1.0
	m.combat.boon_thorns = 15 if active.has("spine") else 0
	m.fauna.rare_mult = 2.0 if active.has("esca") else 1.0
	m.fauna.boon_luck = 0.5 if active.has("fortuna") else 0.0
	var l: Color = LightMap.PLAYER * halo_mult
	if active.has("bagliore"):
		l = LIGHT_BAGLIORE
	var held := ItemsData.get_item(m.hud.current()["id"])
	var hk := String(held.get("kind", ""))
	if hk == "lanterna" or hk == "torcia":
		var ll: Color = held.get("light", LIGHT_LANTERNA if hk == "lanterna" else LIGHT_TORCIA)
		if hk == "torcia":
			ll = ll * _flicker(dt)
		l = Color(maxf(l.r, ll.r), maxf(l.g, ll.g), maxf(l.b, ll.b))
	# le torce piantate tremolano anch'esse: si ricalcola la luce a piccoli passi, solo se ce n'è qualcuna vicina
	_torch_t -= dt
	if _torch_t <= 0.0:
		_torch_t = FLICKER_STEP
		var win := Rect2i(m.light.origin, Vector2i(LightMap.LW, LightMap.LH))
		if not m.world.torches_in(win).is_empty():
			m.light.flicker_time += FLICKER_STEP
			m.light.dirty = true
	if l != _last_light:
		_last_light = l
		m.light.player_light = l
		m.light.dirty = true
