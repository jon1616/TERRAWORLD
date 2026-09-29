class_name TestsEnergy
extends RefCounted
## Roadmap 19 «La Linfa che scorre»: le prove della rete (gruppo `energia`). Un posto spianato vicino alla partenza,
## dove si posano vene e fili con la Pinza, si montano sorgenti, riserve e macchine, e si guarda che il Flusso e
## l'Impulso facciano ciò che devono.

const S := 16

var kit: TestKit
var m: Node
var spot := Vector2i(-1, -1)


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var ctl: bool = m.player.control
	m.player.control = false
	m.fauna.clear()
	m.day.paused = true
	kit.make_room()
	spot = kit.flat_spot(m.world.spawn, 12)
	if spot.x < 0:
		spot = m.world.spawn
		print("ATTENZIONE: energia: nessun posto piano, uso la partenza")
	kit.flatten(spot, 16)
	m.snap_to(spot)
	await kit.frames(4)
	await veins()
	m.player.control = ctl
	m.day.paused = false


## Voce 191: posare e riprendere vene e fili; il disegno; il salvataggio.
func veins() -> void:
	var b: Bisaccia = m.character.bisaccia
	var v: Veins = m.veins
	b.add("pinza_vene", 1)
	b.add("vena_radice", 40)
	b.add("vena_legnoferro", 10)
	b.add("filo_turchese", 30)
	b.add("filo_ambra", 30)
	kit.hold("pinza_vene")
	await kit.frames(3)
	var w: World = m.world
	var y := spot.y - 1
	var a := Vector2i(spot.x - 8, y)
	var n1 := v.line(a, Vector2i(spot.x + 8, y), 0)                  # 17 vene di radice in fila
	var n2 := v.line(Vector2i(spot.x, y), Vector2i(spot.x, y - 3), 1)  # un ramo di legnoferro (la cella del bivio cambia grado)
	var n3 := v.line(Vector2i(spot.x - 6, y - 2), Vector2i(spot.x + 6, y - 2), 4)   # un filo turchese sopra
	var n4 := v.line(Vector2i(spot.x - 2, y - 4), Vector2i(spot.x - 2, y + 0), 5)   # un filo d'ambra che lo incrocia
	var tiers_ok := VeinsData.tier(w.vein_at(spot.x - 8, y)) == 1 and VeinsData.tier(w.vein_at(spot.x, y - 3)) == 2
	var cross := w.vein_at(spot.x - 2, y - 2)
	var cross_ok := VeinsData.has_wire(cross, 0) and VeinsData.has_wire(cross, 1)
	var joins_ok := VeinsData.joins(w.vein_at(spot.x - 1, y), w.vein_at(spot.x, y)) and not VeinsData.joins(
		w.vein_at(spot.x - 1, y) | VeinsData.INSULATED, w.vein_at(spot.x, y))
	# riprendere torna nella Bisaccia
	var before := b.count("vena_radice")
	var took := v.take(Vector2i(spot.x + 8, y), 0)
	var back := b.count("vena_radice") == before + 1 and VeinsData.tier(w.vein_at(spot.x + 8, y)) == 0
	# scavare non taglia: una vena nella roccia resta
	w.set_tile(spot.x + 10, y, TileDefs.STONE)
	v.put(Vector2i(spot.x + 10, y), 0)
	m.actions.break_tile(Vector2i(spot.x + 10, y))
	var kept := VeinsData.tier(w.vein_at(spot.x + 10, y)) == 1
	m.view.set_show_wires(true)
	await kit.frames(4)
	await kit.save("230_vene")
	print("vene: posate %d radice, %d legnoferro, fili %d turchese e %d ambra; gradi %s, fili incrociati nella stessa cella %s, collegamenti e isolante %s, ripresa %s, scavando resta %s" % [
		n1, n2, n3, n4, "sì" if tiers_ok else "NO", "sì" if cross_ok else "NO", "sì" if joins_ok else "NO",
		"sì" if took and back else "NO", "sì" if kept else "NO"])
	if not (n1 == 17 and n2 >= 3 and n3 == 13 and n4 == 5 and tiers_ok and cross_ok and joins_ok and took and back and kept):
		print("ATTENZIONE: le vene non si posano come dovrebbero")
	# il salvataggio le tiene
	m.save_game()
	var l := WorldSave.load_world(m.world_id)
	var saved_ok: bool = l != null and l.vein == w.vein
	print("vene salvate e ricaricate: %s" % ("identiche" if saved_ok else "DIVERSE"))
	if not saved_ok:
		print("ATTENZIONE: le vene non si salvano")
