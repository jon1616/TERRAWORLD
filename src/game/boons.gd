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
var _vis_t := 0.0
var visions := 0                       # voce 398: quante cose le viste hanno fatto brillare (per le prove)


func setup(main: Node2D) -> void:
	m = main
	m.actions.boon.connect(add)
	_label = Label.new()
	_label.position = Vector2(1600 - 660, 150)      # sotto la minimappa e il filo (voce 353: il filo ora ha una riga in più)
	_label.size = Vector2(400, 40)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label.add_theme_font_size_override("font_size", 15)
	_label.add_theme_color_override("font_color", Color("#b8f4f0"))
	_label.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_label.add_theme_constant_override("outline_size", 5)
	m.hud.add_child(_label)


func add(boon_name: String, secs: float) -> void:
	active[boon_name] = maxf(float(active.get(boon_name, 0.0)), secs)
	if BoonsData.has(boon_name):
		_refresh()                                   # voce 398: gli effetti scritti come dati
	var span := "%d minuti" % roundi(secs / 60.0) if secs >= 90.0 else "%d secondi" % roundi(secs)
	m.hud.toast("%s per %s" % [label(boon_name), span])


## Intensità della fiamma in mano (attorno a 1): aggiornata a piccoli passi, altrimenti ferma.
func _flicker(dt: float) -> float:
	if not bool(Settings.v("tremolio")):
		return 1.0
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
	var gone := false
	for k in active.keys():
		active[k] = float(active[k]) - dt
		if float(active[k]) <= 0.0:
			active.erase(k)
			gone = gone or BoonsData.has(String(k))
			continue
		var t := int(active[k])
		text += "%s %d:%02d   " % [label(k), t / 60, t % 60]
	_label.text = text
	if gone:
		_refresh()
	_vis_t -= dt
	if _vis_t <= 0.0:
		_vis_t = 1.0
		_visions()
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



## Il nome di un effetto a tempo (voce 93: anche i rimedi dei rigori, `HarshData`; voce 398: quelli dei dati).
static func label(k: String) -> String:
	return String(NAMES.get(k, BoonsData.info(k).get("name", HarshData.boon_names().get(k, k))))


## Voce 398: gli effetti dei dati cambiano ciò che vale (come indossare un accessorio).
func _refresh() -> void:
	if m.get("gear") != null:
		m.gear.refresh()
	if m.get("effects") != null:
		m.effects.refresh()


## Gli «acc» degli effetti dei dati attivi adesso (li somma `GearEffects`).
func data_accs() -> Array:
	var out := []
	for k in active:
		if BoonsData.has(String(k)):
			out.append(BoonsData.info(String(k)).get("acc", {}))
	return out


func data_effects() -> Array:
	var out := []
	for k in active:
		out.append_array(BoonsData.info(String(k)).get("effects", []))
	return out


## Voce 398: le viste. Ogni secondo fanno brillare nel buio ciò che cercano (e i tesori e le trappole li segnano sulla
## mappa): scrigni e casse, creature, trappole e mimi, entro `VISION_R` tessere.
const VISION_R := 50.0


func _visions() -> void:
	var kinds := {}
	for k in active:
		var sp := String(BoonsData.info(String(k)).get("special", ""))
		if sp != "":
			kinds[sp] = true
	if kinds.is_empty():
		return
	var pc: Vector2i = m.player_cell()
	if kinds.has("creature"):
		for c in m.fauna.list:
			if is_instance_valid(c) and c.tame == null and c.position.distance_to(m.player.position) < VISION_R * 16.0:
				m.light.pulse(Vector2i(floori(c.position.x / 16.0), floori(c.position.y / 16.0)), Color(1.8, 0.6, 0.5), 1.1)
				visions += 1
	if kinds.has("tesori") or kinds.has("trappole"):
		for o in m.world.stations:
			if Vector2(o - pc).length() > VISION_R:
				continue
			var sid := String(m.world.stations[o])
			var treasure := ChestsData.is_found(sid) or sid == "reliquiario"
			var trap := TrapsData.is_trap(sid) or not ChestsData.mimic_of(sid).is_empty()
			if (treasure and kinds.has("tesori")) or (trap and kinds.has("trappole")):
				m.light.pulse(o, Color(2.0, 1.6, 0.6) if treasure else Color(2.0, 0.5, 0.4), 1.1)
				m.map_reveal.reveal_area(o, 2)
				visions += 1
