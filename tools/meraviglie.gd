extends SceneTree
## Roadmap 23, voce 237: le forme delle meraviglie viste dall'alto. Genera mondi finché non ha visto ogni meraviglia
## (al più `--semi` mondi) e salva un ritaglio della mappa attorno a ognuna, ingrandito: prove/meraviglie/<id>.png.
## Colori: tessere come in `tools/mappe.gd`, liquidi (acqua blu, Linfa turchese, brace arancio), cuore in magenta.

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var semi := 20
	for i in args.size():
		if args[i] == "--semi" and i + 1 < args.size():
			semi = int(args[i + 1])
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prove/meraviglie"))
	var seen := {}
	for sd in range(1, semi + 1):
		var w := World.new()
		WorldGen.generate(w, 7000 + sd, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 4})
		for e in w.gen_notes.get("meraviglie", []):
			var k := String(e["k"])
			if seen.has(k):
				continue
			seen[k] = sd
			_crop(w, e, "res://prove/meraviglie/%s.png" % k)
			print("%s: seme %d, centro %s, cuore %s" % [k, 7000 + sd, str(e["c"]), str(e["o"])])
		if seen.size() >= WondersData.WONDERS.size():
			break
	for k in WondersData.WONDERS:
		if not seen.has(k):
			print("ATTENZIONE: %s non è nata in %d mondi" % [k, semi])
	quit()


func _crop(w: World, e: Dictionary, path: String) -> void:
	var sz: Vector2i = WonderShapes.SIZE[String(e["k"])]
	var ctr := Vector2i(int(e["c"][0]), int(e["c"][1]))
	var half := Vector2i(mini(sz.x + 12, 120), mini(sz.y + 12, 120))
	var im := Image.create_empty(half.x * 2, half.y * 2, false, Image.FORMAT_RGB8)
	var liq := [Color("#2f6ec8"), Color("#1fb8a0"), Color("#d84a14")]
	for y in half.y * 2:
		for x in half.x * 2:
			var wx := ctr.x - half.x + x
			var wy := ctr.y - half.y + y
			var c := Color("#8aa8e0")
			if w.inside(wx, wy):
				var i := wy * w.w + wx
				var t := w.tiles[i]
				if t != TileDefs.AIR:
					c = Color(TileDefs.MAP_COLOR.get(t, "#ff00ff"))
				elif w.liquid[i] & 15 > 0:
					c = liq[clampi(w.liquid[i] >> 4, 0, 2)]
				elif w.walls[i] != 0:
					c = Color("#2a2420")
			im.set_pixel(x, y, c)
	var o := Vector2i(int(e["o"][0]), int(e["o"][1])) - (ctr - half)
	for dy in 2:
		for dx in 2:
			if o.x + dx >= 0 and o.y + dy >= 0 and o.x + dx < im.get_width() and o.y + dy < im.get_height():
				im.set_pixel(o.x + dx, o.y + dy, Color("#ff30ff"))
	im.resize(im.get_width() * 3, im.get_height() * 3, Image.INTERPOLATE_NEAREST)
	im.save_png(ProjectSettings.globalize_path(path))
