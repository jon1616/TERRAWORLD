class_name TestsTravel
extends RefCounted
## Prove della voce 38: con una sola Radice viandante non si va da nessuna parte; con due, il clic destro apre la
## mappa in modo viaggio e un clic sull'altra radice ci porta; la minimappa si vede, segue il Germogliato e si
## nasconde con un pannello aperto. Foto 67_viaggio_mappa e 68_minimappa.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _plant(near: Vector2i) -> Vector2i:
	var spot := kit.flat_spot(near, 6)
	if spot.x < 0:
		return Vector2i(-1, -1)
	kit.flatten(spot, 6)
	m.snap_to(spot)
	m.character.bisaccia.add("radice_viandante", 1)
	var before: Array = m.travel.roots()
	if not kit.place_station_near("radice_viandante", spot):
		return Vector2i(-1, -1)
	for o in m.travel.roots():
		if not o in before:
			return o
	return Vector2i(-1, -1)


func run() -> void:
	var t: Travel = m.travel
	kit.make_room()
	var a := _plant(world.spawn + Vector2i(30, 0))
	var alone: bool = t.open_from(a) and not m.hud.map.visible
	var b := _plant(world.spawn + Vector2i(-170, 0))
	if a.x < 0 or b.x < 0:
		print("ATTENZIONE: radici viandanti non piantate (%s, %s)" % [a, b])
		return
	m.snap_to(a + Vector2i(1, 2))
	await kit.frames(3)
	t.open_from(a)
	await kit.frames(3)
	var travel_mode: bool = m.hud.map.visible and m.hud.map.travel_from == a
	await kit.save("67_viaggio_mappa")
	var went: bool = m.hud.map.pick_root(m.hud.map.to_screen(Vector2(b) + Vector2(1, 1)))
	await kit.frames(3)
	var arrived: bool = m.player.position.distance_to(Vector2(b) * S + Vector2(16, 40)) < 3.0 * S
	print("radici viandanti: sola «non trova compagne» %s; mappa in modo viaggio %s; viaggio %s, arrivato %s (%s); mappa chiusa %s" % [
		"sì" if alone else "NO", "sì" if travel_mode else "NO", "sì" if went else "NO", "sì" if arrived else "NO",
		t.describe(b), "sì" if not m.hud.map.visible else "NO"])
	# la minimappa
	var mm: Minimap = m.minimap
	mm.shown = true
	await kit.seconds(0.5)
	var seen: bool = mm.visible
	var o0: Vector2i = mm._origin
	m.snap_to(b + Vector2i(40, 0))
	await kit.seconds(0.5)
	var moved: bool = mm._origin != o0
	await kit.save("68_minimappa")
	m.hud.panel.visible = true
	await kit.frames(2)
	var hid: bool = not mm.visible
	m.hud.panel.visible = false
	print("minimappa: si vede %s, segue il Germogliato %s, nascosta con la Bisaccia aperta %s" % [
		"sì" if seen else "NO", "sì" if moved else "NO", "sì" if hid else "NO"])
