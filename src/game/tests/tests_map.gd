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
	await signals()
	m.hud.map.toggle()


## I segnali del giocatore (30 set 2026): clic destro ne mette uno (triangolo, colore, nome), clic destro sopra lo
## cambia o lo toglie; ogni segno disegnato ha il suo nome per la scheda.
func signals() -> void:
	var mp: MapPanel = m.hud.map
	var all := MapSignals.list(m.world_meta)
	var n0 := all.size()
	mp.zoom = 2
	mp.center = Vector2(kit.world.spawn) + Vector2(20, 0)
	mp.queue_redraw()
	var at := mp.to_screen(Vector2(kit.world.spawn) + Vector2(30.5, -3.5))
	mp.right_click(at)
	var opened := mp.signals.visible and mp.signals.index == -1
	mp.signals._name.text = "vena d'ambra"
	mp.signals.pick("4ab8ff")
	mp.signals.confirm()
	var added := all.size() == n0 + 1 and String(all[n0]["n"]) == "vena d'ambra" and String(all[n0]["c"]) == "4ab8ff"
	mp.queue_redraw()
	await kit.frames(3)
	var names := []
	for h in mp._hits:
		names.append(String(h[1]))
	mp.right_click(mp.to_screen(MapSignals.pos_of(all[n0])))
	var editing: bool = mp.signals.visible and mp.signals.index == n0
	await kit.frames(3)
	await kit.save("29_mappa_segnale")
	mp.signals.remove()
	var ok: bool = opened and added and editing and "vena d'ambra" in names and "La partenza" in names \
		and all.size() == n0
	print("segnali sulla mappa: messo %s (%s), cambiato %s, tolto %s; nomi dei segni %d" % [added,
		"vena d'ambra" in names, editing, all.size() == n0, names.size()])
	if not ok:
		print("ATTENZIONE: i segnali della mappa non vanno")
