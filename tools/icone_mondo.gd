extends SceneTree
## Gli oggetti la cui icona dell'interfaccia NON viene da una forma dipinta (8 ott 2026): stazioni, costrutti, arredi,
## pareti, macchine — l'icona è il disegno del mondo ingrandito. Senza argomenti conta per tipo; con
## `-- --cat banchi` elenca gli oggetti di una categoria di Creare (`CraftCatsData.place_of`) con la stazione e la
## sottocategoria, e fa il foglio dei loro disegni di oggi in prove/icone/mondo_<cat>.png (numerati come l'elenco).
##   Godot_console.exe --headless --path . --script res://tools/icone_mondo.gd [-- --cat banchi]

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var i := args.find("--cat")
	var cat := String(args[i + 1]) if i >= 0 and i + 1 < args.size() else ""
	var st_of := {}
	for sid in StationsData.STATIONS:
		var item := str(StationsData.STATIONS[sid].get("item", ""))
		if item != "" and not st_of.has(item):
			st_of[item] = sid
	var all: Dictionary = ItemsData.all()
	var by := {}
	var rows := []
	var ids: Array = all.keys()
	ids.sort()
	for id in ids:
		var it: Dictionary = all[id]
		var why := ""
		if it.has("build"):
			why = "costrutto"
		elif str(it.get("place", "")).begins_with("arredo_"):
			why = "arredo in serie"
		elif int(it.get("wall", 0)) >= BuildData.WALL_BASE:
			why = "parete"
		elif st_of.has(id):
			why = "macchina" if MachinesData.MACHINES.has(st_of[id]) else "stazione"
		if why == "":
			continue
		if not by.has(why):
			by[why] = 0
		by[why] += 1
		if cat != "":
			var pl: Array = CraftCatsData.place_of(id, "")
			if String(pl[0]) == cat:
				rows.append([id, String(it.get("name", id)), st_of.get(id, ""), String(pl[1])])
	if cat == "":
		print(by)
		quit()
		return
	var cell := 56
	var out := Image.create_empty(10 * (cell + 4) + 4, ceili(rows.size() / 10.0) * (cell + 4) + 4, false, Image.FORMAT_RGBA8)
	out.fill(Color("#141019"))
	for k in rows.size():
		var r: Array = rows[k]
		print("%d|%s|%s|%s|%s" % [k + 1, r[0], r[1], r[2], r[3]])
		var img: Image = ItemIcons.ui(String(r[0]))
		img.convert(Image.FORMAT_RGBA8)
		if img.get_width() != 48:
			img.resize(48, 48, Image.INTERPOLATE_NEAREST)
		out.blend_rect(img, Rect2i(0, 0, 48, 48), Vector2i(4 + (k % 10) * (cell + 4) + 4, 4 + (k / 10) * (cell + 4) + 4))
	out.save_png(ProjectSettings.globalize_path("res://prove/icone/mondo_%s.png" % cat))
	quit()
