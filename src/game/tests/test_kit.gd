class_name TestKit
extends RefCounted
## Attrezzi comuni delle prove automatiche: attese, foto, ricerche di punti adatti nel mondo, fabbricare e piazzare.
## Ogni modulo di prove (`tests_*.gd`) riceve un TestKit e lavora sulla scena di gioco `m`.

const S := 16

var node: Node                          # il nodo delle prove (serve per l'albero della scena e la finestra)
var m: Node2D                           # la scena di gioco (main.gd)
var world: World


func _init(n: Node, main: Node2D) -> void:
	node = n
	m = main
	world = main.world


func frames(n: int) -> void:
	for k in n:
		await node.get_tree().process_frame


func seconds(s: float) -> void:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(s * 1000.0):
		await node.get_tree().process_frame


## Foto della finestra in prove/. Si aspettano 4 fotogrammi: `frame_post_draw` a volte non arriva e bloccava la prova,
## e con 2 fotogrammi a volte l'immagine era di qualche istante prima.
func save(name: String) -> void:
	await frames(4)
	var img := node.get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path("res://prove/%s.png" % name))
	print("salvato ", name)


func bisaccia() -> Bisaccia:
	return m.character.bisaccia


func nearest(list: Array, from: Vector2i, ok: Callable) -> Vector2i:
	var best := Vector2i(-1, -1)
	var bd := 1e12
	for c in list:
		if not ok.call(c):
			continue
		var d := Vector2(c - from).length_squared()
		if d < bd:
			bd = d
			best = c
	return best


## Una cella d'aria con pavimento vicino a c (entro `radius`).
func floor_near(c: Vector2i, radius: int) -> Vector2i:
	var best := Vector2i(-1, -1)
	var bd := 1e9
	for y in range(c.y - radius, c.y + radius + 1):
		for x in range(c.x - radius, c.x + radius + 1):
			if y < 2 or world.solid(x, y) or world.solid(x, y - 1) or not world.solid(x, y + 1):
				continue
			var d := Vector2(x - c.x, y - c.y).length()
			if d < bd and d > 1.5:
				bd = d
				best = Vector2i(x, y)
	return best


## Una cella d'aria su terreno piano e libero per `width` tessere (niente alberi, stazioni), vicina a c.
func flat_spot(c: Vector2i, width: int) -> Vector2i:
	for r in range(4, 200):
		for side in [1, -1]:
			var x: int = c.x + side * r
			var gy := world.surface[clampi(x, 0, world.w - 1)]
			var ok := true
			for dx in width:
				var cell := Vector2i(x + dx, gy - 1)
				var flat := world.surface[clampi(x + dx, 0, world.w - 1)] == gy
				if not flat or world.solid(cell.x, cell.y) or not world.solid(cell.x, gy) \
						or world.tree_at(cell).x >= 0 or not world.station_at(cell).is_empty():
					ok = false
					break
			if ok:
				return Vector2i(x + width / 2, gy - 1)
	return Vector2i(-1, -1)


func craft(id: String) -> bool:
	for r in RecipesData.making(id):
		if Crafting.craft(r, bisaccia()):
			return true
	return false


func slot_of(id: String) -> int:
	for i in Bisaccia.HOTBAR:
		if bisaccia().id_at(i) == id:
			return i
	return -1


## Mette in mano un oggetto: se non è nella barra rapida lo si aggiunge; restituisce la casella.
func hold(id: String) -> int:
	var s := slot_of(id)
	if s < 0:
		var b := bisaccia()
		if b.count(id) == 0:
			b.add(id, 1)
		s = slot_of(id)
		if s < 0:
			# è finito oltre la barra rapida (piena): lo si scambia con l'ultima casella della barra
			for i in b.slots.size():
				if b.id_at(i) == id:
					var last := Bisaccia.HOTBAR - 1
					var tmp := b.slots[last]
					b.slots[last] = b.slots[i]
					b.slots[i] = tmp
					b.changed.emit()
					s = last
					break
	if s >= 0:
		m.hud.select(s)
	return s


func place_station_near(item: String, c: Vector2i) -> bool:
	var slot := slot_of(item)
	if slot < 0:
		return false
	m.hud.select(slot)
	var sid := String(ItemsData.get_item(item)["place"])
	var size: Array = StationsData.STATIONS[sid]["size"]
	for dx in [2, -2, 3, -3, 4, -4, 5, -5, 1, -1, 0]:
		for dy in range(-3, 4):
			var cell: Vector2i = c + Vector2i(dx, dy)
			var o := cell - Vector2i(int(size[0]) / 2, int(size[1]) - 1)
			if m.actions.in_reach(cell) and world.station_fits(sid, o) and m.actions.build.place_station(cell, item):
				return true
	return false
