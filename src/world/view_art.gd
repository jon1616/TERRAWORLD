class_name ViewArt
extends RefCounted
## Le risorse del disegno del mondo che sono uguali in ogni mondo: le trame e le tavole (TileSet) del terreno e delle
## decorazioni, le texture delle stazioni. Prima si rifacevano a ogni ingresso in un mondo (quasi 8 secondi: il motore
## riordina le tessere di una tavola a ogni tessera aggiunta, e quelle del terreno sono 11.520). Ora si preparano una
## volta per sessione, in sottofondo, già dal menu (`Session._ready` chiama `start`); `WorldView` le prende con `get_all`
## e, se non sono ancora pronte, aspetta solo quello che manca (28 set 2026).

const S := 16

static var _res := {}
static var _thread: Thread = null


## Comincia a prepararle in un thread tutto suo (le trame del terreno usano poi più processori: `Par`).
static func start() -> void:
	if not _res.is_empty() or _thread != null:
		return
	# le tabelle che servono si caricano qui, nel thread principale, prima di cominciare
	var _warm := [TileDefs.TERRAIN_LAYERS.size(), TileDefs.TYPES, StationsData.STATIONS.size(), DecorPainter.ROWS]
	_thread = Thread.new()
	_thread.start(func() -> Dictionary: return _prepare())


## Le risorse pronte (aspetta il thread se sta ancora lavorando, o le fa subito se nessuno le ha cominciate).
static func get_all() -> Dictionary:
	if _thread != null:
		_res = _thread.wait_to_finish()
		_thread = null
	if _res.is_empty():
		_res = _prepare()
	return _res


## Chiudendo il gioco il thread non deve restare a metà.
static func finish() -> void:
	if _thread != null:
		_res = _thread.wait_to_finish()
		_thread = null


static func _prepare() -> Dictionary:
	var terrain := TerrainPainter.build()
	var misc := DecorPainter.build()
	var rows := TileDefs.TERRAIN_LAYERS.size()
	var out := {
		"terrain": _tileset(ImageTexture.create_from_image(terrain["img"]), 16 * TerrainPainter.VARIANTS, rows),
		"terrain_glow": _tileset(ImageTexture.create_from_image(terrain["glow"]), 16 * TerrainPainter.VARIANTS, rows),
		"misc": _tileset(ImageTexture.create_from_image(misc["img"]), DecorPainter.COLS, DecorPainter.ROWS),
		"misc_glow": _tileset(ImageTexture.create_from_image(misc["glow"]), DecorPainter.COLS, DecorPainter.ROWS),
	}
	var st := {}
	for id in StationsData.STATIONS:
		var a := StationArt.make(id)
		st[id] = {"img": ImageTexture.create_from_image(a["img"]), "glow": ImageTexture.create_from_image(a["glow"])}
	out["stations"] = st
	return out


static func _tileset(tex: Texture2D, cols: int, rows: int) -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(S, S)
	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(S, S)
	for r in rows:
		for c in cols:
			src.create_tile(Vector2i(c, r))
	ts.add_source(src, 0)
	return ts
