class_name SavePaths
extends RefCounted
## Dove stanno i salvataggi e come si scrivono senza rischi: prima su un file temporaneo, poi il vecchio diventa la copia
## di sicurezza (.bak) e il temporaneo prende il suo posto. Se un file è illeggibile si legge la copia di sicurezza.
##
## user://salvataggi/personaggi/<id>.json
## user://salvataggi/mondi/<id>/mondo.json (dati leggibili) + mondo.bin (tessere compresse)

static var root := "user://salvataggi"


static func characters_dir() -> String:
	return root + "/personaggi"


static func worlds_dir() -> String:
	return root + "/mondi"


static func ensure(dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))


## Identificatore leggibile e unico: nome ripulito + data e ora.
static func new_id(name: String) -> String:
	var slug := ""
	for ch in name.to_lower():
		if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9"):
			slug += ch
		elif slug != "" and not slug.ends_with("_"):
			slug += "_"
	slug = slug.trim_suffix("_").left(20)
	if slug == "":
		slug = "senza_nome"
	var t := Time.get_datetime_dict_from_system()
	return "%s_%04d%02d%02d_%02d%02d%02d" % [slug, t.year, t.month, t.day, t.hour, t.minute, t.second]


static func write_atomic(path: String, bytes: PackedByteArray) -> Error:
	var abs_path := ProjectSettings.globalize_path(path)
	var tmp := abs_path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_buffer(bytes)
	f.close()
	var bak := abs_path + ".bak"
	if FileAccess.file_exists(abs_path):
		if FileAccess.file_exists(bak):
			DirAccess.remove_absolute(bak)
		DirAccess.rename_absolute(abs_path, bak)
	return DirAccess.rename_absolute(tmp, abs_path)


## Cancella un file salvato insieme alla sua copia di sicurezza e all'eventuale temporaneo rimasto.
static func delete_file(path: String) -> void:
	var abs_path := ProjectSettings.globalize_path(path)
	for p in [abs_path, abs_path + ".bak", abs_path + ".tmp"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)


## Cancella una cartella con tutto ciò che contiene.
static func delete_dir(path: String) -> void:
	var abs_path := ProjectSettings.globalize_path(path)
	if not DirAccess.dir_exists_absolute(abs_path):
		return
	for f in DirAccess.get_files_at(abs_path):
		DirAccess.remove_absolute(abs_path + "/" + f)
	for d in DirAccess.get_directories_at(abs_path):
		delete_dir(path + "/" + d)
	DirAccess.remove_absolute(abs_path)


## Legge un file; se manca o è vuoto prova la copia di sicurezza.
static func read(path: String) -> PackedByteArray:
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.is_empty() and FileAccess.file_exists(path + ".bak"):
		bytes = FileAccess.get_file_as_bytes(path + ".bak")
	return bytes


static func write_json(path: String, data: Dictionary) -> Error:
	return write_atomic(path, JSON.stringify(data, "\t").to_utf8_buffer())


static func read_json(path: String) -> Dictionary:
	for p in [path, path + ".bak"]:
		if not FileAccess.file_exists(p):
			continue
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(p))
		if parsed is Dictionary:
			return parsed
	return {}


static func now_text() -> String:
	return Time.get_datetime_string_from_system(false, true)
