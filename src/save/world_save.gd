class_name WorldSave
extends RefCounted
## Salvataggio di un mondo: tutto il mondo compresso (non seme + modifiche: il generatore cambierà spesso durante lo
## sviluppo e i mondi salvati non devono dipendere dalla sua versione). Caricare è molto più rapido che rigenerare.
##
## mondo.bin = "TWM1" + dimensione dei dati (4 byte) + dati compressi ZSTD (var_to_bytes di un dizionario di array)
## mondo.json = nome, seme, dimensioni, date, tempo di gioco, partenza, posizione di ogni personaggio

const MAGIC := "TWM1"
const FORMAT := 1


static func dir_of(id: String) -> String:
	return SavePaths.worlds_dir() + "/" + id


static func save(w: World, id: String, meta: Dictionary) -> Error:
	var dir := dir_of(id)
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
	var stations := []
	for o in w.stations:
		stations.append([o.x, o.y, w.stations[o]])
	var chests := []
	for o in w.chests:
		chests.append([o.x, o.y, (w.chests[o] as Bisaccia).to_array()])
	var data := {
		"w": w.w, "h": w.h, "tiles": w.tiles, "walls": w.walls, "decor": w.decor, "surface": w.surface,
		"torches": torches, "trees": trees, "saplings": saplings, "stations": stations, "plats": w.plats,
		"chests": chests, "explored": w.explored,
	}
	var raw := var_to_bytes(data)
	var out := MAGIC.to_ascii_buffer()
	out.resize(8)
	out.encode_u32(4, raw.size())
	out.append_array(raw.compress(FileAccess.COMPRESSION_ZSTD))
	var err := SavePaths.write_atomic(dir + "/mondo.bin", out)
	if err != OK:
		return err
	meta["formato"] = FORMAT
	meta["seme"] = w.world_seed
	meta["dimensioni"] = [w.w, w.h]
	meta["partenza"] = [w.spawn.x, w.spawn.y]
	meta["ultimo_salvataggio"] = SavePaths.now_text()
	return SavePaths.write_json(dir + "/mondo.json", meta)


## Carica un mondo salvato; null se i file mancano o sono rovinati (anche la copia di sicurezza).
static func load_world(id: String) -> World:
	var meta := read_meta(id)
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
	for s in data.get("stations", []):
		if StationsData.STATIONS.has(String(s[2])):
			w.stations[Vector2i(int(s[0]), int(s[1]))] = String(s[2])
	for ch in data.get("chests", []):
		var o := Vector2i(int(ch[0]), int(ch[1]))
		if w.stations.has(o):
			w.chests[o] = Bisaccia.from_array(ch[2], int(StationsData.STATIONS[w.stations[o]].get("slots", 20)))
	if data.has("explored") and (data["explored"] as PackedByteArray).size() == w.w * w.h:
		w.explored = data["explored"]
	if data.has("plats") and (data["plats"] as PackedByteArray).size() == w.w * w.h:
		w.plats = data["plats"]
	var saplings: PackedInt32Array = data.get("saplings", PackedInt32Array())
	for i in range(0, saplings.size(), 3):
		w.saplings[Vector2i(saplings[i], saplings[i + 1])] = float(saplings[i + 2])
	if w.tiles.size() != w.w * w.h or w.surface.size() != w.w:
		return null
	return w


static func read_meta(id: String) -> Dictionary:
	return SavePaths.read_json(dir_of(id) + "/mondo.json")


## Tutti i mondi salvati, dal più recente.
static func list() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var root := SavePaths.worlds_dir()
	SavePaths.ensure(root)
	for id in DirAccess.get_directories_at(root):
		var m := read_meta(id)
		if m.is_empty():
			continue
		m["id"] = id
		out.append(m)
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return String(a.get("ultimo_salvataggio", "")) > String(b.get("ultimo_salvataggio", "")))
	return out
