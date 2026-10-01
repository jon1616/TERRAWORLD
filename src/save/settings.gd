class_name Settings
extends RefCounted
## Le impostazioni del giocatore, salvate sul computer (`user://impostazioni.json`, non nei salvataggi dei mondi).
## Quali sono, con i valori di partenza, lo dicono i dati: `OptionsData` (opzioni) e `KeysData` (tasti).
## Si leggono con `v(id)`; si cambiano con `set_v(id, valore)` (salva e applica). `sfx`, `ambient`, `music` restano
## per l'audio (moltiplicati dal volume generale in `db`).

const PATH := "user://impostazioni.json"
## I nomi di prima nel file (dal 25 set 2026): si leggono ancora.
const OLD := {"effetti": "effetti", "sottofondo": "ambiente", "musica": "musica"}

static var values := {}
static var keys := {}                  # azione -> [codici dei tasti] scelti dal giocatore (assenti = quelli di partenza)
static var sfx := 0.8
static var ambient := 0.7
static var music := 0.6
static var _loaded := false
static var _master := 1.0
static var no_save := false             # nelle prove: mai scrivere il file del giocatore


static func load_once() -> void:
	if _loaded:
		return
	_loaded = true
	defaults()
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		_sync()
		return
	var d: Variant = JSON.parse_string(f.get_as_text())
	if d is Dictionary:
		for k in d:
			var id := String(OLD.get(k, k))
			if values.has(id):
				values[id] = _clean(id, d[k])
		var t: Variant = d.get("tasti", {})
		if t is Dictionary:
			for a in t:
				if not KeysData.action(String(a)).is_empty() and t[a] is Array:
					keys[String(a)] = (t[a] as Array).map(func(x: Variant) -> int: return int(x))
	_sync()


## Le prove: valori di partenza, senza toccare il file del giocatore né la finestra; niente pausa (la finestra delle
## prove spesso non è in primo piano, e le prove aprono i pannelli aspettandosi che il mondo continui).
static func for_tests() -> void:
	_loaded = true
	no_save = true
	defaults()
	values["pausa_fuoco"] = false
	values["pausa_pannelli"] = false
	LightMap.floor_light = 0.0
	HpBar.mode = "ferite"


## Tutti i valori di partenza (anche per le prove, che non devono dipendere dalle scelte del giocatore).
static func defaults() -> void:
	values.clear()
	keys.clear()
	for o in OptionsData.OPTIONS:
		values[String(o["id"])] = o["def"]
	_sync()


static func v(id: String) -> Variant:
	if not _loaded:
		load_once()
	return values.get(id, OptionsData.get_opt(id).get("def"))


static func set_v(id: String, val: Variant) -> void:
	values[id] = _clean(id, val)
	_sync()
	apply()
	save()


static func save() -> void:
	if no_save:
		return
	var d := values.duplicate()
	d["tasti"] = keys
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(d, "\t"))


## Il JSON rilegge i numeri come decimali: si rimettono del tipo del valore di partenza.
static func _clean(id: String, val: Variant) -> Variant:
	var o := OptionsData.get_opt(id)
	var def: Variant = o.get("def")
	match typeof(def):
		TYPE_BOOL:
			return bool(val)
		TYPE_INT:
			return int(val)
		TYPE_FLOAT:
			var f := float(val)
			if String(o.get("type", "")) == "slider":
				f = clampf(f, float(o["min"]), float(o["max"]))
			return f
	return String(val)


static func _sync() -> void:
	sfx = float(values.get("effetti", sfx))
	ambient = float(values.get("ambiente", ambient))
	music = float(values.get("musica", music))
	_master = float(values.get("volume", 1.0))
	ItemsData.stack_mult = float(values.get("pile", 1.0))      # 28 set 2026: la grandezza delle pile
	StorageData.craft_reach = float(values.get("raggio_casse", StorageData.CRAFT_REACH))   # 1 ott 2026
	StationsData.craft_reach = roundi(float(values.get("raggio_banchi", StationsData.CRAFT_REACH)))


## Applica ciò che vale per tutto il gioco (schermo, fotogrammi); il resto lo leggono i moduli quando serve.
static func apply() -> void:
	match String(v("finestra")):
		"intero":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		"senza_bordi":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		_:
			if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if not "--disable-vsync" in OS.get_cmdline_args():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if bool(v("vsync")) else DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = int(v("fps_max"))
	LightMap.floor_light = float(v("chiarore"))
	HpBar.mode = String(v("barre_creature"))


## Da volume 0-1 a decibel da sommare (0 = muto), con il volume generale.
static func db(val: float) -> float:
	var x := val * _master
	return -80.0 if x <= 0.001 else linear_to_db(x)


## I tasti di un'azione: quelli scelti o quelli di partenza.
static func keys_of(action: String) -> Array:
	if keys.has(action):
		return keys[action]
	var a := KeysData.action(action)
	return a[2] if not a.is_empty() else []


static func set_keys(action: String, codes: Array) -> void:
	keys[action] = codes
	save()


static func reset_keys() -> void:
	keys.clear()
	save()
