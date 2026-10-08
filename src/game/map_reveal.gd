class_name MapReveal
extends Node
## La mappa del mondo esplorato (voce 11). Ciò che la luce tocca attorno al Germogliato viene segnato come visto
## (`World.explored`, salvato con il mondo) e dipinto in un'immagine di un pixel per tessera; il resto resta nero.
## L'immagine si costruisce in un thread all'avvio; poi ogni quarto di secondo si aggiungono le celle illuminate,
## e si ridipingono quelle illuminate già viste (per gli scavi e le costruzioni) a strisce: una riga su `STRIPES` a ogni
## giro, così in due secondi passano tutte (8 ott 2026: ridipingerle tutte insieme costava ~5 ms in un fotogramma).
## La mostra `MapPanel` (tasto M).

const EVERY := 0.25
const STRIPES := 8
const SKY := Color("#5f9aa8")
const VEIN := Color("#5cc8cc")             # Roadmap 19: le vene sulla mappa

var m: Node2D
var world: World
var on_new := Callable()                  # Roadmap 20: celle nuove scoperte (la maestria dell'esplorazione)
var _veins := PackedByteArray()           # Roadmap 19: le vene, prese una volta per giro (`color_at` è nel ciclo)
var image: Image
var tex: ImageTexture
var ready_img := false
var _task := -1
var _t := 0.0
var _stripe := 0
var _tile_col := PackedColorArray()
var _wall_col := PackedColorArray()


var _build_col := PackedColorArray()     # voce 128: il colore dei costrutti per materiale


func setup(main: Node2D) -> void:
	m = main
	world = m.world
	_tile_col.resize(TileDefs.TYPES + 1)
	for t in range(1, TileDefs.TYPES + 1):
		_tile_col[t] = TileDefs.palette_of(t)[2]
	for g in TileDefs.GRASSES:
		_tile_col[g] = TileDefs.palette_of(g)[3]           # le erbe un po' più chiare (voce 91: una per bioma)
	_wall_col.resize(TileDefs.WALLS + 1)
	for k in range(1, TileDefs.WALLS + 1):
		var src: Array = DecorPainter.WALL_SRC[k]
		_wall_col[k] = Px.sh(Color(src[1][1]), 0.6)
	# voce 128: le pareti costruite e i costrutti, dal colore del loro materiale
	_wall_col.resize(256)
	_build_col.resize(BuildData.MATERIALS.size())
	for mi in BuildData.MATERIALS.size():
		var pal: Array = BuildData.MATERIALS[mi]["pal"]
		_wall_col[BuildData.WALL_BASE + mi] = Px.sh(Color(String(pal[2])), 0.6)
		_build_col[mi] = Color(String(pal[3]))
	image = Image.create_empty(world.w, world.h, false, Image.FORMAT_RGB8)
	_task = WorkerThreadPool.add_task(_build, false, "mappa")


## Colore di una cella sulla mappa.
func color_at(i: int) -> Color:
	var t := world.tiles[i]
	if t == TileDefs.COSTRUTTO or t == TileDefs.COSTRUTTO_T:
		var k := world.build[i]
		return _build_col[(k - 1) / BuildData.FORMS.size()] if k > 0 else _tile_col[t]
	if t != TileDefs.AIR:
		return _tile_col[t]
	if i < _veins.size() and _veins[i] & 7 != 0:
		return VEIN                                         # Roadmap 19: le vene della rete, turchesi
	var wl := world.walls[i]
	return _wall_col[wl] if wl != 0 else SKY


func _build() -> void:
	_veins = world.vein
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
	if _t > 0.0:
		return
	_t = EVERY
	_stripe = (_stripe + 1) % STRIPES
	var n := reveal(false, _stripe)
	if n > 0 and on_new.is_valid():
		on_new.call(n)


## Segna come viste le celle illuminate nell'ultima immagine della luce (`all` = ridipinge anche quelle già viste;
## `stripe` >= 0 = ridipinge quelle già viste solo nelle righe di quella striscia).
func reveal(all := false, stripe := -1) -> int:
	var li: Image = m.light.image
	var o: Vector2i = m.light.origin
	# la luce si legge come byte (RGB8): con `get_pixel` su 12 000 celle il giro costava ~6 ms in un fotogramma
	var px := li.get_data()
	_veins = world.vein
	var ex := world.explored
	var ww := world.w
	var n := 0
	for y in LightMap.LH:
		var wy := o.y + y
		if wy < 0 or wy >= world.h:
			continue
		var again := all or y % STRIPES == stripe
		var row := y * LightMap.LW * 3
		for x in LightMap.LW:
			var wx := o.x + x
			if wx < 0 or wx >= ww:
				continue
			var k := row + x * 3
			if px[k] + px[k + 1] + px[k + 2] < 8:
				continue
			var i := wy * ww + wx
			if ex[i] == 0:
				world.explored[i] = 1
				n += 1
				image.set_pixel(wx, wy, color_at(i))
			elif again:
				image.set_pixel(wx, wy, color_at(i))
	return n


## Rivela un cerchio di celle attorno a una (la Mappa dei Seminatori), anche se non è mai stato illuminato.
func reveal_area(c: Vector2i, r: int) -> void:
	_veins = world.vein
	for y in range(c.y - r, c.y + r + 1):
		for x in range(c.x - r, c.x + r + 1):
			if world.inside(x, y) and Vector2(x - c.x, y - c.y).length() <= r:
				var i := y * world.w + x
				world.explored[i] = 1
				image.set_pixel(x, y, color_at(i))
	refresh_texture()


## Quante celle sono state viste (per le prove).
func explored_count() -> int:
	return world.explored.count(1)


func refresh_texture() -> void:
	if ready_img:
		tex.update(image)


## Uscendo si aspetta il thread che dipinge la mappa (vedi `Blight._exit_tree`).
func _exit_tree() -> void:
	if _task >= 0:
		WorkerThreadPool.wait_for_task_completion(_task)
		_task = -1
