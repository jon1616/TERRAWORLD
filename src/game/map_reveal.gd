class_name MapReveal
extends Node
## La mappa del mondo esplorato (voce 11). Ciò che la luce tocca attorno al Germogliato viene segnato come visto
## (`World.explored`, salvato con il mondo) e dipinto in un'immagine di un pixel per tessera; il resto resta nero.
## L'immagine si costruisce in un thread all'avvio; poi ogni quarto di secondo si aggiungono le celle illuminate,
## e ogni due secondi si ridipingono tutte quelle illuminate (per gli scavi e le costruzioni).
## La mostra `MapPanel` (tasto M).

const EVERY := 0.25
const REPAINT := 2.0
const SKY := Color("#5f9aa8")

var m: Node2D
var world: World
var image: Image
var tex: ImageTexture
var ready_img := false
var _task := -1
var _t := 0.0
var _rt := 0.0
var _tile_col := PackedColorArray()
var _wall_col := PackedColorArray()


func setup(main: Node2D) -> void:
	m = main
	world = m.world
	_tile_col.resize(TileDefs.TYPES + 1)
	for t in range(1, TileDefs.TYPES + 1):
		_tile_col[t] = TileDefs.palette_of(t)[2]
	_tile_col[TileDefs.GRASS] = Color(TileDefs.P_GRASS[3])
	_tile_col[TileDefs.GRASS_SPORE] = Color(TileDefs.P_GRASS_SPORE[3])
	_tile_col[TileDefs.GRASS_AMBRA] = Color(TileDefs.P_GRASS_AMBRA[3])
	_wall_col.resize(TileDefs.WALLS + 1)
	for k in range(1, TileDefs.WALLS + 1):
		var src: Array = DecorPainter.WALL_SRC[k]
		_wall_col[k] = Px.sh(Color(src[1][1]), 0.6)
	image = Image.create_empty(world.w, world.h, false, Image.FORMAT_RGB8)
	_task = WorkerThreadPool.add_task(_build, false, "mappa")


## Colore di una cella sulla mappa.
func color_at(i: int) -> Color:
	var t := world.tiles[i]
	if t != TileDefs.AIR:
		return _tile_col[t]
	var wl := world.walls[i]
	return _wall_col[wl] if wl != 0 else SKY


func _build() -> void:
	var ex := world.explored
	for i in ex.size():
		if ex[i] != 0:
			image.set_pixel(i % world.w, i / world.w, color_at(i))


func _process(dt: float) -> void:
	if _task >= 0:
		if not WorkerThreadPool.is_task_completed(_task):
			return
		WorkerThreadPool.wait_for_task_completion(_task)
		_task = -1
		tex = ImageTexture.create_from_image(image)
		ready_img = true
	if not m.built:
		return
	_t -= dt
	_rt -= dt
	if _t > 0.0:
		return
	_t = EVERY
	var all := _rt <= 0.0
	if all:
		_rt = REPAINT
	reveal(all)


## Segna come viste le celle illuminate nell'ultima immagine della luce (`all` = ridipinge anche quelle già viste).
func reveal(all := false) -> int:
	var li: Image = m.light.image
	var o: Vector2i = m.light.origin
	var n := 0
	for y in LightMap.LH:
		var wy := o.y + y
		if wy < 0 or wy >= world.h:
			continue
		for x in LightMap.LW:
			var wx := o.x + x
			if wx < 0 or wx >= world.w:
				continue
			var c := li.get_pixel(x, y)
			if c.r + c.g + c.b < 0.03:
				continue
			var i := wy * world.w + wx
			if world.explored[i] == 0:
				world.explored[i] = 1
				n += 1
				image.set_pixel(wx, wy, color_at(i))
			elif all:
				image.set_pixel(wx, wy, color_at(i))
	return n


## Quante celle sono state viste (per le prove).
func explored_count() -> int:
	return world.explored.count(1)


func refresh_texture() -> void:
	if ready_img:
		tex.update(image)
