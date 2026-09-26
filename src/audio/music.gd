extends Node
## Autoload `Musica`: le musiche del gioco, fatte dall'utente con Gemini («crea musica») e salvate in `musica/`
## (`esplorazione` e `guardiano`, .ogg, .mp3 o .wav: si prende quella che c'è; senza file quel brano tace).
## Suona già nel menu e continua senza interruzioni entrando nel mondo, perché vive fuori dalle scene.
## - Il **sottofondo** (esplorazione) gira sempre; sotto terra si abbassa un poco (resta il sottofondo di grotta di
##   `Sfx`). Quando finisce ricomincia sfumando nel suo inizio (`LOOP_FADE`), così lo stacco non si sente.
## - Quando c'è un **boss** sveglio vicino (una creatura con `boss` non curata: Guardiani, Custodi e quelli che
##   verranno) i due brani si danno il cambio sfumando (`SWITCH_FADE`); il sottofondo resta in pausa e riprende da
##   dov'era, il brano del boss ricomincia a ogni scontro. Finito lo scontro si aspetta `CALM_WAIT` prima di tornare.
## - Volume in `Settings.music` (menu, Impostazioni). La scena di gioco si presenta con `attach` e si congeda con `detach`.

const DIR := "res://musica/"
const EXTS := ["ogg", "mp3", "wav"]
const TRACKS := ["esplorazione", "guardiano"]
const BASE_DB := {"esplorazione": -7.0, "guardiano": -5.0}
const UNDER_DB := -5.0                 # sotto terra
const LOOP_FADE := 4.0                 # secondi di dissolvenza quando un brano ricomincia
const SWITCH_FADE := 2.5               # secondi per passare da un brano all'altro
const CALM_WAIT := 3.0                 # secondi senza boss prima di tornare al sottofondo
const BOSS_RANGE := 16.0 * 45.0        # un boss più lontano di così non conta

var game: Node2D                       # la scena di gioco, se c'è (boss vicini e strato)
var mode := "esplorazione"
var _tracks := {}                      # id -> {stream, players[2], cur, level}
var _fade := {}                        # lettore -> dissolvenza propria (0-1) per il ricominciare
var _calm := 0.0


func _ready() -> void:
	Settings.load_once()
	for id in TRACKS:
		var t := {"stream": _load(id), "players": [], "cur": 0, "level": 1.0 if id == mode else 0.0}
		for i in 2:
			var p := AudioStreamPlayer.new()
			p.volume_db = -80.0
			add_child(p)
			t["players"].append(p)
			_fade[p] = 0.0
		_tracks[id] = t
	_start(String(mode))


## Il brano `id` dalla cartella della musica, nel primo formato che c'è (null se manca).
func _load(id: String) -> AudioStream:
	for e in EXTS:
		var path := "%s%s.%s" % [DIR, id, e]
		if ResourceLoader.exists(path):
			var s: AudioStream = load(path)
			if s is AudioStreamMP3:
				(s as AudioStreamMP3).loop = false   # il ricominciare lo fa `_process`, con la dissolvenza
			elif s is AudioStreamOggVorbis:
				(s as AudioStreamOggVorbis).loop = false
			elif s is AudioStreamWAV:
				(s as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_DISABLED
			return s
	return null


func has(id: String) -> bool:
	return _tracks.has(id) and _tracks[id]["stream"] != null


func attach(g: Node2D) -> void:
	game = g


func detach(g: Node2D) -> void:
	if game == g:
		game = null
	set_mode("esplorazione")


## Il lettore che sta suonando il brano (quello «corrente» dei due).
func player_of(id: String) -> AudioStreamPlayer:
	var t: Dictionary = _tracks[id]
	return t["players"][int(t["cur"])]


## Fa partire un brano dall'inizio (se non suona già) o lo riprende dalla pausa.
func _start(id: String) -> void:
	var t: Dictionary = _tracks[id]
	if t["stream"] == null:
		return
	var p := player_of(id)
	if p.stream_paused:
		p.stream_paused = false
	elif not p.playing:
		p.stream = t["stream"]
		_fade[p] = 1.0
		p.play()


func set_mode(m: String) -> void:
	if m == mode:
		return
	mode = m
	_start(m)
	if m == "guardiano":
		_calm = 0.0


func _boss_near() -> bool:
	if game == null or not is_instance_valid(game) or not game.get("built") or game.get("fauna") == null:
		return false
	for c in game.fauna.list:
		if c.boss and not c.calm and c.position.distance_to(game.player.position) < BOSS_RANGE:
			return true
	return false


func _process(dt: float) -> void:
	# quale brano: il boss appena ce n'è uno vicino, il sottofondo dopo un po' che non c'è più
	if _boss_near():
		_calm = 0.0
		set_mode("guardiano")
	elif mode == "guardiano":
		_calm += dt
		if _calm >= CALM_WAIT:
			set_mode("esplorazione")
	var under := 0.0
	if game != null and is_instance_valid(game) and game.get("built") and game.get("depth_watch") != null \
			and int(game.depth_watch.stratum) > 0:
		under = UNDER_DB
	for id in _tracks:
		var t: Dictionary = _tracks[id]
		if t["stream"] == null:
			continue
		t["level"] = move_toward(float(t["level"]), 1.0 if id == mode else 0.0, dt / SWITCH_FADE)
		_loop(t, dt)
		var base: float = float(BASE_DB[id]) + Settings.db(Settings.music) + (under if id == "esplorazione" else 0.0)
		for p: AudioStreamPlayer in t["players"]:
			var v := float(t["level"]) * float(_fade[p])
			p.volume_db = -80.0 if v <= 0.001 or Settings.music <= 0.001 else base + linear_to_db(v)
		# spento del tutto: il sottofondo si ferma dov'è (riprenderà da lì), il brano del boss si ferma e ricomincerà
		if float(t["level"]) <= 0.0 and id != mode:
			for p: AudioStreamPlayer in t["players"]:
				if p.playing and not p.stream_paused:
					if id == "esplorazione":
						p.stream_paused = true
					else:
						p.stop()


## Quando il brano sta per finire parte di nuovo dall'inizio sull'altro lettore, e i due si sfumano.
func _loop(t: Dictionary, dt: float) -> void:
	var stream: AudioStream = t["stream"]
	var cur: AudioStreamPlayer = t["players"][int(t["cur"])]
	var other: AudioStreamPlayer = t["players"][1 - int(t["cur"])]
	if cur.playing and not cur.stream_paused and not other.playing \
			and cur.get_playback_position() >= stream.get_length() - LOOP_FADE:
		other.stream = stream
		_fade[other] = 0.0
		other.play()
		t["cur"] = 1 - int(t["cur"])
		cur = other
		other = t["players"][1 - int(t["cur"])]
	if other.playing and not other.stream_paused:
		_fade[cur] = minf(float(_fade[cur]) + dt / LOOP_FADE, 1.0)
		_fade[other] = maxf(float(_fade[other]) - dt / LOOP_FADE, 0.0)
		if float(_fade[other]) <= 0.0:
			other.stop()
	else:
		_fade[cur] = 1.0
