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
	var _warm := [TileDefs.TERRAIN_LAYERS.size(), TileDefs.TYPES, DecorPainter.ROWS, BuildData.kinds().size()]
	ArtLib.preload_images("vegetazione")      # voce 107: i disegni delle decorazioni, qui e non nel thread
	_thread = Thread.new()
	_thread.start(func() -> Dictionary: return _prepare())


## Le risorse pronte (aspetta il thread se sta ancora lavorando, o le fa subito se nessuno le ha cominciate).
static func get_all() -> Dictionary:
	ArtLib.preload_images("vegetazione")
	if _thread != null:
		_res = _thread.wait_to_finish()
		_thread = null
	if _res.is_empty():
		_res = _prepare()
	if not _res.has("stations"):
		_res["stations"] = _stations()            # nel thread principale: possono caricare file
	if not _res.has("pronte"):
		# il bordo delle tavole (vedi `_tileset`) si riaccende qui, nel thread principale, a tavole finite
		for k in ["terrain", "terrain_glow", "misc", "misc_glow", "built", "built_glow", "built_walls", "veins", "veins_glow",
				"wires"]:
			var ts: TileSet = _res[k]
			for si in ts.get_source_count():
				(ts.get_source(ts.get_source_id(si)) as TileSetAtlasSource).use_texture_padding = true
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
	var built := BuildPainter.build()               # voce 128: l'atlante dei costrutti (una riga per costrutto)
	var veins := VeinPainter.build()                # Roadmap 19: vene del Flusso e fili dell'Impulso
	var rows := TileDefs.TERRAIN_LAYERS.size()
	var out := {
		"terrain": _tileset_split(terrain["img"], 16 * TerrainPainter.VARIANTS, rows),
		"terrain_glow": _tileset_split(terrain["glow"], 16 * TerrainPainter.VARIANTS, rows),
		"misc": _tileset(ImageTexture.create_from_image(misc["img"]), DecorPainter.COLS, DecorPainter.ROWS),
		"misc_glow": _tileset(ImageTexture.create_from_image(misc["glow"]), DecorPainter.COLS, DecorPainter.ROWS),
		"built": _tileset(ImageTexture.create_from_image(built["img"]), BuildPainter.COLS, BuildData.kinds().size()),
		"built_glow": _tileset(ImageTexture.create_from_image(built["glow"]), BuildPainter.COLS, BuildData.kinds().size()),
		"built_walls": _tileset(ImageTexture.create_from_image(BuildPainter.walls()), BuildPainter.WALL_VARIANTS,
			BuildData.MATERIALS.size()),
		"veins": _tileset(ImageTexture.create_from_image(veins["img"]), VeinPainter.COLS, 4),
		"veins_glow": _tileset(ImageTexture.create_from_image(veins["glow"]), VeinPainter.COLS, 4),
		"wires": _tileset(ImageTexture.create_from_image(veins["wires"]), VeinPainter.COLS, 4),
	}
	return out


## Le texture delle stazioni (nel thread principale: `StationArt` può caricare i disegni da file).
static func _stations() -> Dictionary:
	var st := {}
	for id in StationsData.STATIONS:
		var a := StationArt.make(id)
		st[id] = {"img": ImageTexture.create_from_image(a["img"]), "glow": ImageTexture.create_from_image(a["glow"])}
		var sh := StationGround.shadow(a["img"])        # l'ombra di contatto sotto la base (29 set 2026)
		if not sh.is_empty():
			st[id]["shadow"] = ImageTexture.create_from_image(sh["img"])
			st[id]["shadow_x"] = sh["x"]
	return st


## Roadmap 52, voce 412: la tavola del terreno a pezzi di `TerrainPainter.SRC_ROWS` righe, una sorgente per pezzo
## (id = numero del pezzo): il motore riordina le tessere di una sorgente a ogni aggiunta, e una sola sorgente con
## tutte le righe costava 3,2 s.
static func _tileset_split(img: Image, cols: int, rows: int) -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(S, S)
	var per := TerrainPainter.SRC_ROWS
	var done := 0
	while done < rows:
		var r := mini(per, rows - done)
		var src := TileSetAtlasSource.new()
		src.use_texture_padding = false
		src.texture = ImageTexture.create_from_image(img.get_region(Rect2i(0, done * S, img.get_width(), r * S)))
		src.texture_region_size = Vector2i(S, S)
		for y in r:
			for c in cols:
				src.create_tile(Vector2i(c, y))
		ts.add_source(src, done / per)
		done += r
	return ts


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
