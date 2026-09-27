class_name TestsGenRepeat
extends RefCounted
## La ripetibilità del generatore (28 set 2026): lo stesso seme deve dare sempre lo stesso mondo, in ogni parte (tessere,
## pareti, decorazioni, liquidi, stazioni, alberi, casse…). Il mondo si fa due volte: una con le passate a fasce su più
## processori (`GenBands`, come nel gioco) e una dentro il gruppo di thread, dove le fasce si fanno una alla volta
## (come nelle prove). Trovò subito un guasto: le casse si riempivano con il caso globale. Legge anche il collaudo del
## mondo (`PassCollaudo`). Fa parte del gruppo «base».

const SEED := 4242
const PARAMS := {"vigore": 3, "geni": []}

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var a := World.new()
	var t0 := Time.get_ticks_msec()
	WorldGen.generate(a, SEED, 1600, 900, PARAMS.duplicate(true))
	var t_par := Time.get_ticks_msec() - t0
	var b := World.new()
	t0 = Time.get_ticks_msec()
	var tid := WorkerThreadPool.add_task(func() -> void:
		WorldGen.generate(b, SEED, 1600, 900, PARAMS.duplicate(true)), true, "ripetibilità")
	while not WorkerThreadPool.is_task_completed(tid):
		await m.get_tree().process_frame
	WorkerThreadPool.wait_for_task_completion(tid)
	var t_seq := Time.get_ticks_msec() - t0
	var fa := WorldGen.fingerprint(a, "a")
	var fb := WorldGen.fingerprint(b, "a")
	var diff := []
	for k in fa.size():
		if fa[k] != fb[k]:
			diff.append(fa[k].get_slice(" ", 1))
	print("ripetibilità del generatore: stesso seme due volte (a fasce in parallelo %d ms, una alla volta %d ms): %s" % [
		t_par, t_seq, "identico in tutto" if diff.is_empty() else "DIVERSO in %s" % [diff]])
	if not diff.is_empty():
		print("ATTENZIONE: il generatore non dà lo stesso mondo con lo stesso seme")
	# il collaudatore (`PassCollaudo`): strutture sovrapposte, Cuore, firma, partenza, stazioni
	var col: Dictionary = a.gen_notes.get("collaudo", {})
	var probs: Array = col.get("problemi", [])
	print("collaudo del mondo: %d problemi %s, %d riparazioni %s" % [probs.size(), probs, (col.get("riparati", []) as Array).size(),
		col.get("riparati", [])])
	if not probs.is_empty() or not col.has("problemi"):
		print("ATTENZIONE: il collaudatore ha trovato problemi nel mondo")
