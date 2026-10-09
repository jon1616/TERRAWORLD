extends SceneTree
## I salvataggi campione (voce 481, 9 ott 2026): la «versione stabile» dei salvataggi. In `campioni/<nome>/salvataggi/`
## c'è la copia di una partita vera (personaggi e mondi, come li scrive il gioco), in `campioni/<nome>/impronta.json`
## ciò che quella partita conteneva (oggetti, equipaggiamento, conteggi, tessere dei mondi). Questo strumento ricarica
## ogni campione con il gioco di oggi e confronta: se un cambio di formato ne rompe uno, lo dice prima che si perda una
## partita vera, e allora serve un passo in `SaveMigrations` (mai una lettura che «indovina»).
##   Godot_console.exe --headless --path . --script res://tools/campioni.gd               confronta (ESITO in fondo)
##   Godot_console.exe --headless --path . --script res://tools/campioni.gd -- --scrivi   scrive l'impronta dei nuovi
## Un campione nuovo (quando cambia un formato, o una partita vera arriva lontano): si copia la cartella dei salvataggi
## senza i .bak, `cp -r "$APPDATA/Godot/app_userdata/TERRAWORLD/salvataggi" campioni/<data>_<nome>/` e poi `--scrivi`.
## La cartella `campioni/` ha `.gdignore`: Godot non la importa, il gioco non la vede.

const BASE := "res://campioni"
const WORK := "user://campioni_verifica"

var errors := 0
var write := false


func _init() -> void:
	write = "--scrivi" in OS.get_cmdline_user_args()
	var names := DirAccess.get_directories_at(ProjectSettings.globalize_path(BASE))
	if names.is_empty():
		print("nessun campione in %s" % BASE)
	for n in names:
		_check(String(n))
	print("ESITO: %d campioni, %d errori" % [names.size(), errors])
	quit()


func _check(name: String) -> void:
	var src := BASE + "/" + name + "/salvataggi"
	var dst := WORK + "/" + name
	SavePaths.delete_dir(dst)
	_copy(ProjectSettings.globalize_path(src), ProjectSettings.globalize_path(dst))
	SavePaths.root = dst
	var got := {"personaggi": {}, "mondi": {}}
	for c in Character.list():
		if c == null:
			_bad(name, "un personaggio non si apre")
			continue
		got["personaggi"][c.id] = _of_character(c)
	for m in WorldSave.list():
		var id := String(m["id"])
		var w := WorldSave.load_world(id)
		if w == null:
			_bad(name, "il mondo %s non si apre" % id)
			continue
		got["mondi"][id] = _of_world(w, m)
	var path := BASE + "/" + name + "/impronta.json"
	var want := SavePaths.read_json(path)
	if want.is_empty() or write:
		if want.is_empty() or write:
			var f := FileAccess.open(path, FileAccess.WRITE)
			f.store_string(JSON.stringify(got, "\t", true))
			f.close()
			print("%s: impronta scritta (%d personaggi, %d mondi)" % [name, got["personaggi"].size(), got["mondi"].size()])
		return
	var diffs := _diff(want, got, "")
	for d in diffs:
		_bad(name, d)
	print("%s: %d personaggi, %d mondi, %s" % [name, got["personaggi"].size(), got["mondi"].size(),
		"tutto come prima" if diffs.is_empty() else "%d differenze" % diffs.size()])


## Ciò che conta di un personaggio: tutti gli oggetti che ha (in ogni borsa e nella Dispensa), ciò che indossa, i
## conteggi, l'Albero, la lingua, la mandria, la maestria.
static func _of_character(c: Character) -> Dictionary:
	var items := {}
	var bags: Array = c.bisaccia.all_bags()
	if c.dispensa != null:
		bags.append(c.dispensa)
	for b in bags:
		for s in (b as Bisaccia).slots:
			if not (s as Dictionary).is_empty():
				items[String(s["id"])] = int(items.get(String(s["id"]), 0)) + int(s["n"])
	var mast := {}
	for k in c.maestria:
		mast[k] = int((c.maestria[k] as Dictionary).get("p", 0))
	return {"nome": c.name, "oggetti": items, "indossa": c.bisaccia.equip.duplicate(), "stats": c.stats.size(),
		"albero": int(c.albero.get("stadio", 0)), "lingua": c.lingua.size(), "mandria": c.mandria.size(),
		"erbario": (c.erbario.get("creature", {}) as Dictionary).size(), "maestria": mast, "obiettivi": c.obiettivi.size()}


## Ciò che conta di un mondo: misura, tessere piene, pareti, stazioni, casse e ciò che contengono.
static func _of_world(w: World, m: Dictionary) -> Dictionary:
	var inside := 0
	for o in w.chests:
		for s in (w.chests[o] as Bisaccia).slots:
			if not (s as Dictionary).is_empty():
				inside += int(s["n"])
	return {"nome": String(m.get("nome", "")), "misura": [w.w, w.h], "piene": w.tiles.size() - w.tiles.count(0),
		"pareti": w.walls.size() - w.walls.count(0), "stazioni": w.stations.size(), "casse": w.chests.size(),
		"nelle_casse": inside, "torce": w.torches.size()}


## Le differenze tra l'impronta scritta e quella di oggi, in parole.
static func _diff(a: Variant, b: Variant, at: String) -> Array:
	var out := []
	if a is Dictionary and b is Dictionary:
		for k in a:
			if not (b as Dictionary).has(k):
				out.append("%s/%s: sparito" % [at, k])
			else:
				out.append_array(_diff(a[k], b[k], at + "/" + str(k)))
		for k in b:
			if not (a as Dictionary).has(k):
				out.append("%s/%s: in più" % [at, k])
		return out
	if a is Array and b is Array:
		if (a as Array).size() != (b as Array).size():
			out.append("%s: %s → %s" % [at, str(a), str(b)])
		else:
			for i in (a as Array).size():
				out.append_array(_diff(a[i], b[i], "%s[%d]" % [at, i]))   # (il JSON rilegge gli interi come decimali)
		return out
	if (a is float or a is int) and (b is float or b is int):
		if absf(float(a) - float(b)) > 0.001:
			out.append("%s: %s → %s" % [at, str(a), str(b)])
		return out
	if str(a) != str(b):
		out.append("%s: %s → %s" % [at, str(a), str(b)])
	return out


func _bad(name: String, what: String) -> void:
	errors += 1
	print("ERRORE %s: %s" % [name, what])


## Copia una cartella (senza le copie di sicurezza .bak).
static func _copy(from: String, to: String) -> void:
	DirAccess.make_dir_recursive_absolute(to)
	for f in DirAccess.get_files_at(from):
		if not f.ends_with(".bak"):
			DirAccess.copy_absolute(from + "/" + f, to + "/" + f)
	for d in DirAccess.get_directories_at(from):
		_copy(from + "/" + d, to + "/" + d)
