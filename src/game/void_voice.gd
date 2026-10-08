class_name VoidVoice
extends Node
## La Bocca (Roadmap 36, voce 347; frasi in `VoidVoiceData`). Quando il Germogliato è in un luogo malato (Avvizzimento
## entro poche tessere, il mondo del Seme Nero, il Fondo), ogni tanto una scritta lenta compare a metà schermo, nel
## colore di chi parla, e svanisce. Prima le frasi mai lette, poi a caso; «bocca» le conta (misteri).

const S := 16

var m: Node2D
var paused := false
var _t := 0.0
var _label: Label
var _show := 0.0                         # secondi dalla comparsa (negativo = niente in scena)
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	_t = _rng.randf_range(VoidVoiceData.EVERY[0] * 0.5, VoidVoiceData.EVERY[1] * 0.5)
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.size = Vector2(900, 40)
	_label.add_theme_font_size_override("font_size", 24)
	_label.add_theme_color_override("font_outline_color", Color(0.02, 0.0, 0.04))
	_label.add_theme_constant_override("outline_size", 6)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.modulate.a = 0.0
	m.hud.add_child(_label)
	_show = -1.0


## Un luogo malato? (vicino all'Avvizzimento, nel mondo del Seme Nero, nel Fondo)
func sick_here() -> bool:
	if bool(m.world_meta.get("nero", false)):
		return true
	var c: Vector2i = m.player_cell()
	if StrataData.at(m.world, c.x, c.y) >= 4:
		return true
	if Blight.surface_blighted(m.world, c.x) and c.y < int(m.world.surface[clampi(c.x, 0, m.world.w - 1)]) + 12:
		return true
	var r := VoidVoiceData.NEAR
	for dy in range(-r, r + 1, 2):
		for dx in range(-r, r + 1, 2):
			if m.world.tile(c.x + dx, c.y + dy) in TileDefs.BLIGHTED:
				return true
	return false


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	if _show >= 0.0:
		_show += dt
		var a := clampf(minf(_show / 1.5, (6.5 - _show) / 2.0), 0.0, 1.0)
		_label.modulate.a = a * 0.9
		if _show >= 6.5:
			_show = -1.0
			_label.modulate.a = 0.0
	if paused:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = 8.0                                     # (non è un luogo malato: si riguarda fra poco)
	if not sick_here():
		return
	if speak() != "":
		_t = _rng.randf_range(VoidVoiceData.EVERY[0], VoidVoiceData.EVERY[1])


## Una frase adesso (prima quelle mai lette). Restituisce la frase ("" se nessuna è pronta).
func speak() -> String:
	var st: Dictionary = m.character.stats
	var fresh := []
	var all := []
	for i in VoidVoiceData.LINES.size():
		var l: Array = VoidVoiceData.LINES[i]
		if LoreConds.ok(m, l[2]):
			all.append(i)
			if int(st.get("bocca_%d" % i, 0)) == 0:
				fresh.append(i)
	if all.is_empty():
		return ""
	# le frasi mai lette: prima quelle legate alla storia (la più avanti), poi quelle di sempre nel loro ordine;
	# lette tutte, una a caso
	var i: int = all[_rng.randi_range(0, all.size() - 1)]
	if not fresh.is_empty():
		var tied := fresh.filter(func(k: int) -> bool: return not (VoidVoiceData.LINES[k][2] as Dictionary).is_empty())
		i = tied[tied.size() - 1] if not tied.is_empty() else fresh[0]
	var l2: Array = VoidVoiceData.LINES[i]
	var first := int(st.get("bocca_%d" % i, 0)) == 0
	if first:
		st["bocca_%d" % i] = 1
		m.objectives.bump("bocca")
	var vs: Vector2 = m.get_viewport_rect().size
	_label.position = Vector2((vs.x - _label.size.x) * 0.5, vs.y * 0.38)
	_label.add_theme_color_override("font_color", Color(String(VoidVoiceData.COLORS[String(l2[0])])))
	_label.text = String(l2[1])
	_show = 0.0
	m.sfx.play("presenza")
	if m.get("diary") != null and first:
		m.diary.note("%s: «%s»" % ["Una voce" if String(l2[0]) == "bocca" else "Saréth", l2[1]], "storia")
	return String(l2[1])
