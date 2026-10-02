class_name SoundSpace
extends RefCounted
## Roadmap 35, voce 338: il suono dello spazio attorno al Germogliato. Gli effetti e i sottofondi passano da un bus
## «Spazio» con un riverbero e un filtro:
##   - nelle grandi caverne l'eco cresce, nei cunicoli il suono è asciutto (l'aria attorno, misurata con 16 raggi)
##   - all'aperto quasi niente eco
##   - sott'acqua tutto è attutito (il filtro taglia gli acuti)
## e il fischio del vento, più forte in alto, con il vento forte e nel cielo (un sottofondo suo, `SoundsData.WIND`).
## `Sfx` lo crea e lo aggiorna; i valori si avvicinano piano a quelli nuovi (niente scatti).

const BUS := "Spazio"
const EVERY := 0.25
const RAYS := 16
const REACH := 22                      # tessere: oltre, un raggio conta come «aperto»
const OPEN_CUT := 20500.0
const WATER_CUT := 650.0

var m: Node2D
var wind_player: AudioStreamPlayer
var reverb: AudioEffectReverb
var lowpass: AudioEffectLowPassFilter
var goal := {"wet": 0.03, "room": 0.3, "damp": 0.5, "cut": OPEN_CUT, "wind": 0.0}
var now := {"wet": 0.03, "room": 0.3, "damp": 0.5, "cut": OPEN_CUT, "wind": 0.0}
var air := 0.0                         # l'aria media attorno (tessere), per le prove
var place := ""                        # «aperto», «caverna», «cunicolo», «acqua»
var _t := 0.0


func _init(main: Node2D) -> void:
	m = main
	var idx := AudioServer.get_bus_index(BUS)
	if idx < 0:
		AudioServer.add_bus()
		idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, BUS)
		AudioServer.set_bus_send(idx, "Master")
		var rv := AudioEffectReverb.new()
		rv.dry = 1.0
		rv.wet = 0.03
		rv.hipass = 0.2
		AudioServer.add_bus_effect(idx, rv)
		AudioServer.add_bus_effect(idx, AudioEffectLowPassFilter.new())
	reverb = AudioServer.get_bus_effect(idx, 0) as AudioEffectReverb
	lowpass = AudioServer.get_bus_effect(idx, 1) as AudioEffectLowPassFilter
	lowpass.cutoff_hz = OPEN_CUT


func update(dt: float) -> void:
	if m == null or not m.built or m.player == null:
		return
	_t -= dt
	if _t <= 0.0:
		_t = EVERY
		_measure()
	var k := clampf(dt * 2.5, 0.0, 1.0)
	for key in now:
		now[key] = lerpf(float(now[key]), float(goal[key]), k)
	reverb.wet = float(now["wet"])
	reverb.room_size = float(now["room"])
	reverb.damping = float(now["damp"])
	lowpass.cutoff_hz = float(now["cut"])
	if wind_player != null:
		var v := float(now["wind"])
		if v < 0.02:
			wind_player.volume_db = -80.0
		else:
			wind_player.volume_db = linear_to_db(v) + float(SoundsData.WIND["gain"]) + Settings.db(Settings.ambient)
		if not wind_player.playing and wind_player.stream != null:
			wind_player.play()


func _measure() -> void:
	var w: World = m.world
	var p: Vector2 = m.player.position
	var c := Vector2i(floori(p.x / 16.0), floori(p.y / 16.0))
	var head := Vector2i(c.x, floori((p.y - 10.0) / 16.0))
	var under := w.liq(head.x, head.y) >= 4
	var sky := true
	for y in range(c.y - 1, -1, -1):
		if w.solid(c.x, y):
			sky = false
			break
	# l'aria attorno: quanto vanno lontano 16 raggi prima di toccare la roccia
	var tot := 0.0
	for i in RAYS:
		var a := TAU * float(i) / RAYS
		var d := Vector2(cos(a), sin(a))
		var n := 1
		while n < REACH:
			var q := Vector2i(floori(c.x + 0.5 + d.x * n), floori(c.y + 0.5 + d.y * n))
			if not w.inside(q.x, q.y) or w.solid(q.x, q.y):
				break
			n += 1
		tot += n
	air = tot / RAYS
	var open := clampf((air - 3.0) / 13.0, 0.0, 1.0)
	if sky:
		place = "aperto"
		goal["wet"] = 0.04
		goal["room"] = 0.35
		goal["damp"] = 0.6
	elif air < 3.5:
		place = "cunicolo"
		goal["wet"] = 0.03
		goal["room"] = 0.15
		goal["damp"] = 0.8
	else:
		place = "caverna"
		goal["wet"] = 0.06 + 0.38 * open
		goal["room"] = 0.3 + 0.65 * open
		goal["damp"] = 0.6 - 0.35 * open
	goal["cut"] = WATER_CUT if under else OPEN_CUT
	if under:
		place = "acqua"
		goal["wet"] = float(goal["wet"]) * 0.5
	# il vento: all'aperto, più forte con il vento e più in alto sopra la superficie (nel cielo ancora di più)
	var wv := 0.0
	if sky and not under:
		var wind: float = absf(float(m.weather.wind)) if m.weather != null else 0.0
		var high := clampf(float(w.surface[clampi(c.x, 0, w.w - 1)] - c.y) / 60.0, 0.0, 1.0)
		wv = clampf(wind / 180.0, 0.0, 1.0) * 0.7 + high * 0.55
		if wind < 15.0 and high < 0.1:
			wv = 0.0
	goal["wind"] = clampf(wv, 0.0, 1.0)


## Le misure per le prove.
func state() -> Dictionary:
	return {"luogo": place, "aria": air, "eco": goal["wet"], "stanza": goal["room"], "filtro": goal["cut"], "vento": goal["wind"]}
