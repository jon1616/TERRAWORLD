extends SceneTree
## Voce 290: il foglio «prima e dopo» del volume delle creature (`CreatureFx.shade`), per giudicarlo a occhio.
## prove/creature_volume.png: a coppie, il disegno com'era e com'è, ingrandito 3 volte.

func _init() -> void:
	var ids: Array = CreaturesData.CREATURES.keys()
	ids.sort()
	var pick: Array = []
	var seen := {}
	for id in ids:
		var art: Array = CreaturesData.CREATURES[id].get("art", [])
		if art.is_empty() or seen.has(str(art)):
			continue
		seen[str(art)] = true
		pick.append(art)
		if pick.size() >= 48:
			break
	var cell := 70
	var cols := 8
	var sheet := Image.create(cols * cell * 2 * 3 / 3 * 3, ceili(pick.size() / float(cols)) * cell * 3, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#3a5a58"))
	for k in pick.size():
		var art: Array = pick[k]
		var fr: Dictionary = CreatureArt.frames(String(art[0]), int(art[1]))
		var a: Image = fr["frames"][0]
		var b: Image = CreatureFx.shade(a)
		var x0 := (k % cols) * cell * 2 * 3
		var y0 := (k / cols) * cell * 3
		for pair in [[a, 0], [b, cell * 3]]:
			var im: Image = (pair[0] as Image).duplicate()
			im.convert(Image.FORMAT_RGBA8)
			im.resize(im.get_width() * 3, im.get_height() * 3, Image.INTERPOLATE_NEAREST)
			var r := Rect2i(0, 0, mini(im.get_width(), cell * 3), mini(im.get_height(), cell * 3))
			sheet.blend_rect(im, r, Vector2i(x0 + int(pair[1]), y0))
	sheet.save_png(ProjectSettings.globalize_path("res://prove/creature_volume.png"))
	print("prove/creature_volume.png: ", pick.size(), " creature")
	quit()
