class_name ViewArt
extends RefCounted
## Le risorse del disegno del mondo che sono uguali in ogni mondo: le trame e le tavole (TileSet) del terreno e delle
## decorazioni, le texture delle stazioni. Prima si rifacevano a ogni ingresso in un mondo (quasi 8 secondi: il motore
## riordina le tessere di una tavola a ogni tessera aggiunta, e quelle del terreno sono 11.520). Ora si preparano una
## volta per sessione, in sottofondo, già dal menu (`Session._ready` chiama `start`); `WorldView` le prende con `get_all`
## e, se non sono ancora pronte, aspetta solo quello che manca (28 set 2026).
##
## **Nel thread solo lavoro di puro codice** (pixel, tavole): niente `load()` di file né altro che possa aver bisogno del
## thread principale, che intanto aspetta il thread e resterebbe fermo per sempre. Successo il 28 set 2026: le stazioni
## cominciarono a caricare i disegni di Nano Banana (`StationTemplates`) e il mondo non si apriva più. Le stazioni
## si fanno quindi nel thread principale, in `get_all`.

const S := 16

static var _res := {}
static var _thread: Thread = null


## Comincia a prepararle in un thread tutto suo (le trame del terreno usano poi più processori: `Par`).
static func start() -> void:
	if not _res.is_empty() or _thread != null:
		return
	# le tabelle che servono si caricano qui, nel thread principale, prima di cominciare
	var _warm := [TileDefs.TERRAIN_LAYERS.size(), TileDefs.TYPES, DecorPainter.ROWS]
	_thread = Thread.new()
	_thread.start(func() -> Dictionary: return _prepare())


## Le risorse pronte (aspetta il thread se sta ancora lavorando, o le fa subito se nessuno le ha cominciate).
static func get_all() -> Dictionary:
	if _thread != null:
		_res = _thread.wait_to_finish()
		_thread = null
	if _res.is_empty():
		_res = _prepare()
	if not _res.has("stations"):
		_res["stations"] = _stations()            # nel thread principale: possono caricare file
	if not _res.has("pronte"):
		# il bordo delle tavole (vedi `_tileset`) si riaccende qui, nel thread principale, a tavole finite
		for k in ["terrain", "terrain_glow", "misc", "misc_glow"]:
			((_res[k] as TileSet).get_source(0) as TileSetAtlasSource).use_texture_padding = true
		_res["pronte"] = true
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
	return out


## Le texture delle stazioni (nel thread principale: `StationArt` può caricare i disegni da file).
static func _stations() -> Dictionary:
	var st := {}
	for id in StationsData.STATIONS:
		var a := StationArt.make(id)
		st[id] = {"img": ImageTexture.create_from_image(a["img"]), "glow": ImageTexture.create_from_image(a["glow"])}
	return st


static func _tileset(tex: Texture2D, cols: int, rows: int) -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(S, S)
	var src := TileSetAtlasSource.new()
	# senza il bordo mentre si aggiungono le tessere: a ogni tessera il motore rifà il bordo nel thread principale, e
	# lì leggeva le tessere mentre questo thread le stava ancora aggiungendo («no tile at (101, 16)», 28 set 2026)
	src.use_texture_padding = false
	src.texture = tex
	src.texture_region_size = Vector2i(S, S)
	for r in rows:
		for c in cols:
			src.create_tile(Vector2i(c, r))
	ts.add_source(src, 0)
	return ts
