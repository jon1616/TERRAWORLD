class_name TestsCascades
extends RefCounted
## Voce 482, le cascate (gruppo «cascate»): il mondo di prova ha le sue sorgenti; vicino a una l'acqua cade dritta fino
## al pelo dello specchio, lo scarico la toglie e il livello non sale (nemmeno dopo mezzo minuto). Foto 340_cascata.
## Voce 483: l'acqua versata lontano dal Germogliato (fuori dalla finestra dei liquidi) cade e si posa lo stesso.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await far()
	var w: World = m.world
	await kit.frames(2)
	var list: Array = m.world_meta.get("cascate", w.gen_notes.get("cascate", []))
	if list.is_empty():
		print("ATTENZIONE: il mondo di prova non ha cascate")
		return
	# la cascata con lo specchio più largo (si vede meglio e lo scarico lavora di più)
	var e: Array = list[0]
	for x in list:
		if int(x[5]) - int(x[4]) > int(e[5]) - int(e[4]):
			e = x
	var sx := int(e[0])
	var sy := int(e[1])
	var lx := sx + int(e[2])
	var ys := int(e[3])
	var x0 := int(e[4])
	var x1 := int(e[5])
	var spot := kit.floor_near(Vector2i(lx, sy), 14)
	if spot.x < 0:
		spot = Vector2i(lx, sy - 2)
	var was: bool = m.player.control
	m.player.control = false
	m.snap_to(spot)
	m.vitals.refill()
	var d0: int = m.cascades.drained
	await kit.seconds(4.0)
	# quante celle della caduta hanno acqua: il massimo in tre secondi (l'acqua scende a grumi)
	var fall := 0
	for k in 15:
		var n := 0
		for y in range(sy, ys):
			if w.liq(lx, y) > 0:
				n += 1
		fall = maxi(fall, n)
		await kit.seconds(0.2)
	await kit.save("340_cascata")
	var above0 := _above(w, lx, ys, x0, x1)
	await kit.seconds(25.0)
	var above1 := _above(w, lx, ys, x0, x1)
	var drained: int = m.cascades.drained - d0
	var drawn0: bool = not (m.cascades._fx.cols as Array).is_empty()
	m.player.control = was
	m.snap_to(w.spawn)
	print("cascate: %d nel mondo di prova; quella in (%d, %d) cade per %d righe, acqua nella caduta %d celle, scarico %d livelli, acqua sopra il pelo %d → %d livelli" % [
		list.size(), sx, sy, ys - sy, fall, drained, above0, above1])
	var drawn: bool = drawn0
	print("  il getto disegnato: %s" % ("sì" if drawn else "NO"))
	if fall <= 0 or not drawn or drained <= 0 or above1 > maxi(above0, 8) + 16:
		print("ATTENZIONE: la cascata non scorre o allaga")


## I livelli d'acqua nelle sei righe sopra il pelo, sullo specchio (fuori dalla colonna della caduta).
static func _above(w: World, lx: int, ys: int, x0: int, x1: int) -> int:
	var n := 0
	for y in range(ys - 6, ys):
		for x in range(x0 - 3, x1 + 4):
			if absi(x - lx) > 1:
				n += w.liq(x, y)
	return n


## Voce 483: una cella d'acqua nel cielo a 220 colonne dal Germogliato (fuori dalla finestra): dopo qualche secondo è
## caduta (la cella di partenza è vuota, l'acqua c'è ancora più in basso).
func far() -> void:
	var w: World = m.world
	var pc: Vector2i = m.player_cell()
	var x := clampi(pc.x + 220, 5, w.w - 5)
	if x - pc.x < LiquidsData.WINDOW.x + 10:
		x = clampi(pc.x - 220, 5, w.w - 5)
	var y := int(w.surface[x]) - 40
	while y > 3 and (w.solid(x, y) or w.liq(x, y) > 0):
		y -= 1
	m.liquids.pour(Vector2i(x, y), 8, 0)
	await kit.seconds(4.0)
	var below := 0
	for yy in range(y + 1, mini(y + 80, w.h)):
		for xx in range(x - 12, x + 13):
			below += w.liq(xx, yy)                    # (posata, si allarga ai lati)
	var gone := w.liq(x, y) == 0
	print("liquidi lontani: acqua versata a %d colonne dal Germogliato, la cella di partenza vuota %s, sotto %d livelli" % [
		absi(x - pc.x), "sì" if gone else "NO", below])
	if not gone or below <= 0:
		print("ATTENZIONE: i liquidi lontani restano fermi")
