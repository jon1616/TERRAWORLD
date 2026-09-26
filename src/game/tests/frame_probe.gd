class_name FrameProbe
extends RefCounted
## Dove va il tempo di un fotogramma (per le prove): dopo ogni figlio della scena di gioco si mette un nodo sonda che
## segna l'ora quando tocca a lui. Godot fa girare `_process` in ordine d'albero (un figlio con tutti i suoi figli, poi
## il successivo), quindi la differenza tra due sonde è il tempo di quel modulo. Quello che resta fino al fotogramma
## dopo è il disegno e la fisica. `mark()` all'inizio del fotogramma, `split()` alla fine.

var m: Node2D
var names: PackedStringArray = []
var stamps := PackedInt64Array()
var _probes: Array[Node] = []
var _start := 0
var _objects := 0
var _chunks := 0


class Probe:
	extends Node
	var owner_probe: FrameProbe
	var index := 0

	func _process(_dt: float) -> void:
		owner_probe.stamps[index] = Time.get_ticks_usec()


func attach(main: Node2D) -> void:
	m = main
	RenderingServer.viewport_set_measure_render_time(m.get_viewport().get_viewport_rid(), true)
	var kids := m.get_children()
	stamps.resize(kids.size())
	for i in kids.size():
		var p := Probe.new()
		p.owner_probe = self
		p.index = i
		var n: Node = kids[i]
		names.append(n.name if n.get_script() == null else "%s (%s)" % [n.name, (n.get_script() as Script).get_global_name()])
		m.add_child(p)
		m.move_child(p, n.get_index() + 1)
		_probes.append(p)


func detach() -> void:
	for p in _probes:
		p.queue_free()
	_probes.clear()


## Inizio del fotogramma (quando riprende la prova, al segnale `process_frame`).
func mark() -> void:
	_start = Time.get_ticks_usec()
	_objects = int(Performance.get_monitor(Performance.OBJECT_COUNT))
	_chunks = int(m.view.chunks.size())
	stamps.fill(0)


## I tempi del motore per l'ultimo fotogramma finito: process e fisica (tutti gli script), preparazione e disegno
## della scena sul processore e sulla scheda video, oggetti creati, blocchi del mondo nuovi.
func engine() -> String:
	var vp := m.get_viewport().get_viewport_rid()
	return "process %.1f ms, fisica %.1f ms, preparazione %.1f ms, disegno %.1f ms (scheda %.1f ms), oggetti %+d, blocchi %+d" % [
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
		RenderingServer.get_frame_setup_time_cpu(),
		RenderingServer.viewport_get_measured_render_time_cpu(vp),
		RenderingServer.viewport_get_measured_render_time_gpu(vp),
		int(Performance.get_monitor(Performance.OBJECT_COUNT)) - _objects, int(m.view.chunks.size()) - _chunks]


## Fine del fotogramma: [nome, ms] dei tempi più lunghi, più «disegno e fisica» per il resto.
func split(top := 5) -> Array:
	var now := Time.get_ticks_usec()
	var out := []
	var prev := _start
	for i in stamps.size():
		if stamps[i] == 0:
			continue
		out.append([names[i], (stamps[i] - prev) / 1000.0])
		prev = stamps[i]
	out.append(["disegno, fisica e il resto", (now - prev) / 1000.0])
	out.sort_custom(func(a: Array, b: Array) -> bool: return float(a[1]) > float(b[1]))
	return out.slice(0, top)
