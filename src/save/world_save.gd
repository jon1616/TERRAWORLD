class_name WorldSave
extends RefCounted
## Salvataggio di un mondo: tutto il mondo compresso (non seme + modifiche: il generatore cambierà spesso durante lo
## sviluppo e i mondi salvati non devono dipendere dalla sua versione). Caricare è molto più rapido che rigenerare.
##
## mondo.bin = "TWM1" + dimensione dei dati (4 byte) + dati compressi ZSTD (var_to_bytes di un dizionario di array)
## mondo.json = nome, seme, dimensioni, date, tempo di gioco, partenza, posizione di ogni personaggio; "formato" è la
## versione (`SaveMigrations.WORLD`): alla lettura `read_meta` lo porta alla forma di oggi

const MAGIC := "TWM1"


## 28 set 2026 (richiesta dell'utente: nel menu solo il mondo principale della partita): i mondi nati dai Semi di un
## Giardino si salvano dentro la sua cartella, `mondi/<giardino>/semi/<id>`; nel menu compare solo il Giardino
## (`list_main`), la rete dei mondi li vede tutti (`list`). Cancellando il Giardino se ne vanno anche loro.
const NESTED := "semi"
static var _where := {}                # cartella base + id -> cartella del mondo (trovata una volta)


## La cartella di un mondo: in cima (Giardini e mondi di prima) o dentro il suo Giardino.
static func dir_of(id: String) -> String:
	var root := SavePaths.worlds_dir()
	var key := root + "|" + id
	if _where.has(key):
		return _where[key]
	var direct := root + "/" + id
	if _exists(direct):
		return direct
	SavePaths.ensure(root)
	for g in DirAccess.get_directories_at(ProjectSettings.globalize_path(root)):
		var p := root + "/" + g + "/" + NESTED + "/" + id
		if _exists(p):
			_where[key] = p
			return p
	return direct


static func _exists(path: String) -> bool:
	return DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(path))


## Dove salvare un mondo nuovo: un mondo nato da un Seme va dentro il suo Giardino (se il Giardino c'è).
static func _home_dir(id: String, meta: Dictionary) -> String:
	var home := String(meta.get("casa", ""))
	if home == "" or home == id or bool(meta.get("giardino", false)):
		return ""
	var hd := SavePaths.worlds_dir() + "/" + home
	if not _exists(hd):
		return ""
	return hd + "/" + NESTED + "/" + id


static func save(w: World, id: String, meta: Dictionary) -> Error:
	var dir := dir_of(id)
	if not _exists(dir) and _home_dir(id, meta) != "":
		dir = _home_dir(id, meta)
		_where[SavePaths.worlds_dir() + "|" + id] = dir
	SavePaths.ensure(dir)
	var torches := PackedInt32Array()
	for c in w.torches:
		torches.append(c.x)
		torches.append(c.y)
	var trees := PackedInt32Array()
	for k in w.trees:
		for t in w.trees[k]:
			trees.append_array([t.x, t.y, t.z])
	var saplings := PackedInt32Array()
	for c in w.saplings:
		saplings.append_array([c.x, c.y, int(ceil(float(w.saplings[c])))])
	var crops := []
	for c in w.crops:
		var e: Array = w.crops[c]
		crops.append([c.x, c.y, String(e[0]), int(ceil(float(e[1]))), bool(e[2])])
	var stations := []
	for o in w.stations:
		stations.append([o.x, o.y, w.stations[o]])
	var chests := []
	for o in w.chests:
		chests.append([o.x, o.y, (w.chests[o] as Bisaccia).to_array()])
	var data := {
		"w": w.w, "h": w.h, "tiles": w.tiles, "walls": w.walls, "decor": w.decor, "surface": w.surface,
		"torches": torches, "trees": trees, "saplings": saplings, "stations": stations, "stazioni_v": 3, "plats": w.plats,
		"chests": chests, "explored": w.explored, "biomes": w.biomes, "crops": crops, "liquid": w.liquid, "build": w.build, "tint": w.tint,
	}
	var raw := var_to_bytes(data)
	var out := MAGIC.to_ascii_buffer()
	out.resize(8)
	out.encode_u32(4, raw.size())
	out.append_array(raw.compress(FileAccess.COMPRESSION_ZSTD))
	var err := SavePaths.write_atomic(dir + "/mondo.bin", out)
	if err != OK:
		return err
	meta["formato"] = SaveMigrations.WORLD
	meta["seme"] = w.world_seed
	meta["dimensioni"] = [w.w, w.h]
	meta["partenza"] = [w.spawn.x, w.spawn.y]
	meta["ultimo_salvataggio"] = SavePaths.now_text()
	return SavePaths.write_json(dir + "/mondo.json", meta)


## Carica un mondo salvato; null se i file mancano o sono rovinati (anche la copia di sicurezza).
static func load_world(id: String) -> World:
	var meta := read_meta(id)
	if meta.has(SaveMigrations.TOO_NEW):
		push_error("il mondo %s viene da una versione più nuova del gioco" % id)
		return null
	var bytes := SavePaths.read(dir_of(id) + "/mondo.bin")
	var w := _decode(bytes)
	if w == null:
		bytes = FileAccess.get_file_as_bytes(dir_of(id) + "/mondo.bin.bak")
		w = _decode(bytes)
	if w == null:
		return null
	w.world_seed = int(meta.get("seme", 0))
	var sp: Array = meta.get("partenza", [w.w / 2, 0])
	w.spawn = Vector2i(int(sp[0]), int(sp[1]))
	return w


static func _decode(bytes: PackedByteArray) -> World:
	if bytes.size() < 8 or bytes.slice(0, 4).get_string_from_ascii() != MAGIC:
		return null
	var raw := bytes.slice(8).decompress(bytes.decode_u32(4), FileAccess.COMPRESSION_ZSTD)
	var data: Variant = bytes_to_var(raw)
	if not (data is Dictionary):
		return null
	var w := World.new()
	w.setup(int(data["w"]), int(data["h"]))
	w.tiles = data["tiles"]
	w.walls = data["walls"]
	w.decor = data["decor"]
	w.surface = data["surface"]
	var torches: PackedInt32Array = data["torches"]
	for i in range(0, torches.size(), 2):
		w.add_torch(Vector2i(torches[i], torches[i + 1]))
	var trees: PackedInt32Array = data["trees"]
	for i in range(0, trees.size(), 3):
		w.add_tree(Vector2i(trees[i], trees[i + 1]), trees[i + 2])
	# banchi e mobili rimpiccioliti (26 set 2026): quelli salvati prima scendono di quanto sono calati in altezza,
	# così restano appoggiati al pavimento; le ceste loro seguono lo stesso spostamento.
	var moved := {}
	# 28 set 2026: banchi e casse tornati alti due tessere (`V2_SIZE`): quelli salvati prima salgono di una
	var ver := int(data.get("stazioni_v", 1))
	for s in data.get("stations", []):
		if StationsData.STATIONS.has(String(s[2])):
			var id := String(s[2])
			var o0 := Vector2i(int(s[0]), int(s[1]))
			var o1 := o0
			var was: Array = []
			if ver < 2 and StationsData.OLD_SIZE.has(id):
				was = StationsData.OLD_SIZE[id]
			elif ver < 3 and StationsData.V2_SIZE.has(id):
				was = StationsData.V2_SIZE[id]
			if not was.is_empty():
				o1.y += int(was[1]) - int(StationsData.STATIONS[id]["size"][1])
				moved[o0] = o1
			w.stations[o1] = String(s[2])
	for ch in data.get("chests", []):
		var o := Vector2i(int(ch[0]), int(ch[1]))
		o = moved.get(o, o)
		if w.stations.has(o):
			w.chests[o] = Bisaccia.from_array(ch[2], int(StationsData.STATIONS[w.stations[o]].get("slots", 20)))
	if data.has("biomes") and (data["biomes"] as PackedByteArray).size() == w.w:
		w.biomes = data["biomes"]
	if data.has("explored") and (data["explored"] as PackedByteArray).size() == w.w * w.h:
		w.explored = data["explored"]
	if data.has("plats") and (data["plats"] as PackedByteArray).size() == w.w * w.h:
		w.plats = data["plats"]
	if data.has("build") and (data["build"] as PackedByteArray).size() == w.w * w.h:
		w.build = data["build"]                    # voce 128: i costrutti
	if data.has("tint") and (data["tint"] as PackedByteArray).size() == w.w * w.h:
		w.tint = data["tint"]                      # voce 140: i colori
	if data.has("liquid") and (data["liquid"] as PackedByteArray).size() == w.w * w.h:
		w.liquid = data["liquid"]                  # voce 73 (i mondi di prima: nessun liquido)
	var saplings: PackedInt32Array = data.get("saplings", PackedInt32Array())
	for i in range(0, saplings.size(), 3):
		w.saplings[Vector2i(saplings[i], saplings[i + 1])] = float(saplings[i + 2])
	for e in data.get("crops", []):
		if CropsData.CROPS.has(String(e[2])):
			w.crops[Vector2i(int(e[0]), int(e[1]))] = [String(e[2]), float(e[3]), bool(e[4])]
	if w.tiles.size() != w.w * w.h or w.surface.size() != w.w:
		return null
	return w


## Cancella per sempre un mondo (dal menu, dopo la conferma). I portali di altri mondi che portavano qui, al prossimo
## passaggio, faranno nascere di nuovo il mondo dal suo seme (vedi `Portal`).
static func delete(id: String) -> void:
	SavePaths.delete_dir(dir_of(id))
	_where.erase(SavePaths.worlds_dir() + "|" + id)


## I dati leggibili di un mondo, già portati alla forma di oggi (vedi `SaveMigrations`).
static func read_meta(id: String) -> Dictionary:
	var m := SavePaths.read_json(dir_of(id) + "/mondo.json")
	SaveMigrations.world_meta(m)
	return m


## Tutti i mondi salvati (anche quelli dentro i Giardini), dal più recente. I mondi nati dai Semi salvati prima del
## 28 set 2026 in cima alla cartella si spostano qui dentro il loro Giardino.
static func list() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var root := SavePaths.worlds_dir()
	SavePaths.ensure(root)
	for id in DirAccess.get_directories_at(ProjectSettings.globalize_path(root)):
		var m := read_meta(id)
		if m.is_empty():
			continue
		var into := _home_dir(id, m)
		if into != "":
			SavePaths.ensure(into.get_base_dir())
			if DirAccess.rename_absolute(ProjectSettings.globalize_path(root + "/" + id), ProjectSettings.globalize_path(into)) == OK:
				_where[root + "|" + id] = into
				m["dentro"] = true
		m["id"] = id
		out.append(m)
	for g in DirAccess.get_directories_at(ProjectSettings.globalize_path(root)):
		var nd := root + "/" + g + "/" + NESTED
		if not _exists(nd):
			continue
		for id in DirAccess.get_directories_at(ProjectSettings.globalize_path(nd)):
			if out.any(func(e: Dictionary) -> bool: return String(e["id"]) == id):
				continue
			_where[root + "|" + id] = nd + "/" + id
			var m := read_meta(id)
			if m.is_empty():
				continue
			m["id"] = id
			m["dentro"] = true
			out.append(m)
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return String(a.get("ultimo_salvataggio", "")) > String(b.get("ultimo_salvataggio", "")))
	return out


## I mondi da mostrare nel menu: i Giardini (e i mondi di prima, o quelli il cui Giardino non c'è più). I mondi nati
## dai Semi si raggiungono dal Giardino, con i portali.
static func list_main() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for m in list():
		if not bool(m.get("dentro", false)):
			out.append(m)
	return out
