extends SceneTree
## Il foglio delle creature di un pacchetto del bestiario (Roadmap 15): prove/bestiario_<file>.png, due fotogrammi per
## specie ingranditi ×3 su fondo scuro, per guardarle a occhio.
##   Godot_console.exe --headless --path . --script res://tools/bestiario.gd -- superficie

func _init() -> void:
	var name := "superficie"
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		name = args[0]
	var pack: Dictionary = (load("res://src/data/bestiary/%s.gd" % name) as GDScript).get("DATA")["creatures"]
	var ids := pack.keys()
	var cell := 40
	var cols := 6
	var rows := ceili(ids.size() / float(cols))
	var sheet := Image.create_empty(cols * cell * 2 * 3, rows * cell * 3, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#101820"))
	for i in ids.size():
		var cr: Dictionary = CreaturesData.get_data(String(ids[i]))
		var art: Array = cr["art"]
		var fr: Dictionary = CreatureArt.frames(String(art[0]), int(art[1]))
		for f in mini(2, (fr["frames"] as Array).size()):
			var tex = fr["frames"][f]
			var im: Image = tex.get_image() if tex is Texture2D else tex
			im = im.duplicate()
			im.resize(im.get_width() * 3, im.get_height() * 3, Image.INTERPOLATE_NEAREST)
			var ox := ((i % cols) * 2 + f) * cell * 3
			var oy := (i / cols) * cell * 3
			sheet.blend_rect(im, Rect2i(Vector2i.ZERO, im.get_size()), Vector2i(ox + 6, oy + 6))
	sheet.save_png("res://prove/bestiario_%s.png" % name)
	print("foglio: prove/bestiario_%s.png (%d specie)" % [name, ids.size()])
	quit()
