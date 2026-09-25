class_name Sfx
extends Node
## I suoni della scena (voce 17): genera all'avvio i suoni di `SoundsData` e li suona da una piccola scorta di lettori
## (i suoni lontani dal Germogliato si sentono più piano). Il sottofondo dello strato si genera
## la prima volta che serve, in un thread, e sfuma nel nuovo quando si cambia strato.
## `played` conta i suoni suonati (per le prove).

const VOICES := 12
const HEAR := 16.0 * 40.0              # oltre questa distanza (px) un suono non si sente
const FADE := 1.5                      # secondi per sfumare da un sottofondo all'altro

var m: Node2D
var streams := {}
var played := {}
var volume_db := 0.0                   # volume generale degli effetti
var _players: Array[AudioStreamPlayer] = []
var _next := 0
var _amb: Array[AudioStreamPlayer] = []   # due lettori per sfumare
var _amb_streams := {}
var _amb_tasks := {}
var _amb_now := -1
var _amb_cur := 0


func setup(main: Node2D) -> void:
	m = main
	Settings.load_once()
	var k := 1
	for id in SoundsData.SOUNDS:
		streams[id] = SfxSynth.make(SoundsData.SOUNDS[id], k)
		k += 1
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	for i in 2:
		var a := AudioStreamPlayer.new()
		a.volume_db = -80.0
		add_child(a)
		_amb.append(a)


## Suona un effetto; `at` = punto del mondo da cui viene (INF = dal Germogliato stesso).
func play(id: String, at := Vector2.INF) -> void:
	if not streams.has(id):
		return
	var r: Dictionary = SoundsData.SOUNDS[id]
	var gain := float(r.get("gain", -10.0)) + volume_db + Settings.db(Settings.sfx)
	if Settings.sfx <= 0.001:
		return
	if at != Vector2.INF and m.player != null:
		var dist: float = at.distance_to(m.player.position)
		if dist > HEAR:
			return
		gain += linear_to_db(clampf(1.0 - dist / HEAR, 0.05, 1.0))
	var p := _players[_next]
	_next = (_next + 1) % VOICES
	p.stream = streams[id]
	p.volume_db = gain
	var v := float(r.get("var", 0.0))
	p.pitch_scale = 1.0 + randf_range(-v, v)
	p.play()
	played[id] = int(played.get(id, 0)) + 1


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	var s: int = m.depth_watch.stratum
	if s < 0:
		return
	if s != _amb_now:
		if not _amb_tasks.has(s):
			# generato in un thread; il risultato si legge solo quando il lavoro è finito
			var spec: Dictionary = SoundsData.AMBIENT[s]
			var box := [null]
			_amb_streams[s] = box
			_amb_tasks[s] = WorkerThreadPool.add_task(func() -> void: box[0] = SfxSynth.ambient(spec, 7 + s))
		elif int(_amb_tasks[s]) >= 0 and WorkerThreadPool.is_task_completed(_amb_tasks[s]):
			WorkerThreadPool.wait_for_task_completion(_amb_tasks[s])
			_amb_tasks[s] = -1
		if int(_amb_tasks[s]) < 0:
			_switch_ambient(s)
	# sfumatura tra i due lettori del sottofondo
	if _amb_now >= 0:
		var goal := float(SoundsData.AMBIENT[_amb_now]["gain"]) + volume_db + Settings.db(Settings.ambient)
		var cur := _amb[_amb_cur]
		var old := _amb[1 - _amb_cur]
		cur.volume_db = move_toward(cur.volume_db, goal, dt * 60.0 / FADE)
		old.volume_db = move_toward(old.volume_db, -80.0, dt * 60.0 / FADE)
		if old.volume_db <= -79.0 and old.playing:
			old.stop()


func _switch_ambient(s: int) -> void:
	_amb_now = s
	_amb_cur = 1 - _amb_cur
	var p := _amb[_amb_cur]
	p.stream = _amb_streams[s][0]
	p.volume_db = -60.0
	p.play()
