extends SceneTree
## Mappe dei mondi: genera N semi, salva mappe/mondo_<seme>.png (metà grandezza) e stampa i tempi di ogni passata
## e qualche conteggio (grotte, minerali, torce, alberi) per confrontare i semi tra loro.
##   Godot_console.exe --headless --path . --script res://tools/mappe.gd -- --semi 20 --da 1 [--intera]


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var n := int(_arg(args, "--semi", "20"))
	var first := int(_arg(args, "--da", "1"))
	var full := "--intera" in args
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://mappe"))
	var totals := {}
	for k in n:
		var sd := first + k
		var w := World.new()
		var t0 := Time.get_ticks_msec()
		var times := WorldGen.generate(w, sd)
		var ms := Time.get_ticks_msec() - t0
		for t in times:
			totals[t[0]] = int(totals.get(t[0], 0)) + int(t[1])
		var counts := _counts(w)
		print("seme %d: %d ms · aria sotto terra %d%% · radicite %d · legnoferro %d · ambra %d · cristalli %d · torce %d · alberi %d" % [
			sd, ms, counts["cave"], counts[TileDefs.RADICITE], counts[TileDefs.LEGNOFERRO], counts[TileDefs.AMBRA],
			counts[TileDefs.CRYSTAL], w.torches.size(), counts["trees"]])
		_save_map(w, "res://mappe/mondo_%d.png" % sd, full)
	var line := "media per passata:"
	for key in totals:
		line += " %s %d ms ·" % [key, int(totals[key]) / n]
	print(line)
	quit()


func _arg(args: PackedStringArray, key: String, def: String) -> String:
	var i := args.find(key)
	return args[i + 1] if i >= 0 and i + 1 < args.size() else def


func _counts(w: World) -> Dictionary:
	var c := {TileDefs.RADICITE: 0, TileDefs.LEGNOFERRO: 0, TileDefs.AMBRA: 0, TileDefs.CRYSTAL: 0, "cave": 0, "trees": 0}
	var under := 0
	var air := 0
	for y in w.h:
		for x in w.w:
			var t := w.tiles[y * w.w + x]
			if c.has(t):
				c[t] += 1
			if y > w.surface[x] + 6:
				under += 1
				if t == TileDefs.AIR:
					air += 1
	c["cave"] = 100 * air / maxi(under, 1)
	for k in w.trees:
		c["trees"] += (w.trees[k] as Array).size()
	return c


func _save_map(w: World, path: String, full: bool) -> void:
	var im := Image.create_empty(w.w, w.h, false, Image.FORMAT_RGB8)
	var cols := {}
	for t in TileDefs.MAP_COLOR:
		cols[t] = Color(TileDefs.MAP_COLOR[t])
	var sky := Color("#8aa8e0")
	var wall := Color("#2a2420")
	for y in w.h:
		for x in w.w:
			var i := y * w.w + x
			var t := w.tiles[i]
			var c: Color = cols[t] if t != TileDefs.AIR else (wall if w.walls[i] != 0 else sky)
			im.set_pixel(x, y, c)
	for t in w.torches:
		im.set_pixelv(t, Color("#ffcc40"))
	im.set_pixelv(w.spawn, Color("#ff2020"))
	if not full:
		im.resize(w.w / 2, w.h / 2, Image.INTERPOLATE_BILINEAR)
	im.save_png(ProjectSettings.globalize_path(path))
