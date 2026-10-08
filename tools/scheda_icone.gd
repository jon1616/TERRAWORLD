extends SceneTree
## Le forme d'icona per il generatore di prompt (`tools/prompt_icone.py`, 8 ott 2026): per ogni forma quanti oggetti la
## usano, di che tipo, qualche nome d'esempio, i materiali più frequenti, e se ha già un disegno di Nano Banana.
## → arte_ia/icone/forme.json (in ordine: la forma più usata prima).
##   Godot_console.exe --headless --path . --script res://tools/scheda_icone.gd
## Con -- --foglio forma,forma… fa il foglio di controllo prove/icone/<nome>.png: ogni forma in sei materiali, a
## grandezza vera e ingrandita, e dentro una casella della Bisaccia (come si vede giocando).

const MATS := ["radicite", "legnoferro", "ambra", "cristallo", "tizzonite", "brina"]


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var i := args.find("--foglio")
	if i >= 0 and i + 1 < args.size():
		var nome := args[i + 2] if i + 2 < args.size() else "foglio"
		_sheet(Array(String(args[i + 1]).split(",", false)), nome)
	else:
		_scan()
	quit()


func _scan() -> void:
	var all: Dictionary = ItemsData.all()
	var by := {}
	for id in all:
		var it: Dictionary = all[id]
		var ic: Variant = it.get("icon", [])
		if not (ic is Array) or (ic as Array).is_empty():
			continue
		var sh := String(ic[0])
		var mat := String(ic[1]) if (ic as Array).size() > 1 else ""
		if not by.has(sh):
			by[sh] = {"shape": sh, "count": 0, "kinds": {}, "examples": [], "mats": {}}
		var r: Dictionary = by[sh]
		r["count"] = int(r["count"]) + 1
		var k := String(it.get("kind", "?"))
		r["kinds"][k] = int(r["kinds"].get(k, 0)) + 1
		r["mats"][mat] = int(r["mats"].get(mat, 0)) + 1
		if (r["examples"] as Array).size() < 6 and not it.has("gen"):
			(r["examples"] as Array).append(String(it.get("name", id)))
	var rows := by.values()
	for r in rows:
		r["drawn"] = FileAccess.file_exists("res://arte/forme/%s.png" % r["shape"])
		r["kinds"] = _top(r["kinds"], 4)
		r["mats"] = _top(r["mats"], 4)
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["count"]) > int(b["count"]))
	var f := FileAccess.open(ProjectSettings.globalize_path("res://arte_ia/icone/forme.json"), FileAccess.WRITE)
	f.store_string(JSON.stringify(rows, "\t"))
	f.close()
	print("forme: %d (disegnate %d)" % [rows.size(), rows.filter(func(r: Dictionary) -> bool: return r["drawn"]).size()])


func _top(d: Dictionary, n: int) -> Array:
	var ks := d.keys()
	ks.sort_custom(func(a: Variant, b: Variant) -> bool: return d[a] > d[b])
	return ks.slice(0, n)


## Il foglio di controllo: una riga per forma; l'icona dell'interfaccia (48 pixel, dentro una casella) in sei
## materiali, poi la stessa forma del mondo (16 pixel, ingrandita ×2) negli stessi materiali.
func _sheet(shapes: Array, nome: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prove/icone"))
	var slot := 56
	var row_h := slot + 10
	var w := 10 + MATS.size() * (slot + 6) + 24 + MATS.size() * 38
	var out := Image.create_empty(w, 10 + shapes.size() * row_h, false, Image.FORMAT_RGBA8)
	out.fill(Color("#141019"))
	for r in shapes.size():
		var y := 10 + r * row_h
		for m in MATS.size():
			var x := 10 + m * (slot + 6)
			out.fill_rect(Rect2i(x, y, slot, slot), Color("#3aa08a"))
			out.fill_rect(Rect2i(x + 2, y + 2, slot - 4, slot - 4), Color("#20262b"))
			var ui: Image = ItemIcons.make_ui(String(shapes[r]), String(MATS[m]))
			ui.convert(Image.FORMAT_RGBA8)
			out.blend_rect(ui, Rect2i(0, 0, ui.get_width(), ui.get_height()), Vector2i(x + 4, y + 4))
			var im: Image = CreatureFx.shade(ItemIcons.make(String(shapes[r]), String(MATS[m])))
			var sm := im.duplicate() as Image
			sm.resize(32, 32, Image.INTERPOLATE_NEAREST)
			var x2 := 10 + MATS.size() * (slot + 6) + 24 + m * 38
			out.fill_rect(Rect2i(x2, y + 12, 32, 32), Color("#2a3a30"))
			out.blend_rect(sm, Rect2i(0, 0, 32, 32), Vector2i(x2, y + 12))
	out.save_png(ProjectSettings.globalize_path("res://prove/icone/%s.png" % nome))
	print("foglio: prove/icone/%s.png (%d forme)" % [nome, shapes.size()])
