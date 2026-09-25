class_name TestsMap
extends RefCounted
## Prove della mappa (voce 11): dopo tutti i posti visitati dalle prove le celle viste sono segnate, la mappa si apre
## con i segni al posto giusto (foto 29_mappa); il salvataggio (dopo, in `TestsWorld.run_and_save`) la ritrova uguale.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	m.snap_to(kit.world.spawn)
	await kit.seconds(1.0)
	m.map_reveal.reveal(true)
	var n: int = m.map_reveal.explored_count()
	var total: int = kit.world.w * kit.world.h
	print("mappa: celle viste %d (%.1f%% del mondo), immagine pronta %s" % [n, 100.0 * n / total,
		"sì" if m.map_reveal.ready_img else "NO"])
	m.hud.map.toggle()
	m.hud.map.zoom = 0
	m.hud.map.queue_redraw()
	await kit.seconds(1.0)
	await kit.save("29_mappa")
	m.hud.map.toggle()
