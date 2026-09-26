class_name Settings
extends RefCounted
## Le impostazioni del giocatore, salvate sul computer (`user://impostazioni.json`, non nei salvataggi dei mondi):
## il volume degli effetti, quello del sottofondo di grotta e quello della musica (0-1; 0 = muto).

const PATH := "user://impostazioni.json"

static var sfx := 0.8
static var ambient := 0.7
static var music := 0.6
static var _loaded := false


static func load_once() -> void:
	if _loaded:
		return
	_loaded = true
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var d: Variant = JSON.parse_string(f.get_as_text())
	if d is Dictionary:
		sfx = clampf(float(d.get("effetti", sfx)), 0.0, 1.0)
		ambient = clampf(float(d.get("sottofondo", ambient)), 0.0, 1.0)
		music = clampf(float(d.get("musica", music)), 0.0, 1.0)


static func save() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"effetti": sfx, "sottofondo": ambient, "musica": music}))


## Da volume 0-1 a decibel da sommare (0 = muto).
static func db(v: float) -> float:
	return -80.0 if v <= 0.001 else linear_to_db(v)
