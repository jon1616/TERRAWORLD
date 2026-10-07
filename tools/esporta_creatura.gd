extends SceneTree
## Esporta i fotogrammi di una creatura: originali (1×), ingranditi (×8), il foglio e le maschere di luce.

const OUT := "C:/Users/Principale/Desktop/CLAUDE/TERRAWORLD/sprite_esperimento/"

func _init() -> void:
	var id := "corvo"
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		id = args[0]
	DirAccess.make_dir_recursive_absolute(OUT)
	var cr: Dictionary = CreaturesData.get_data(id)
	var art: Array = cr["art"]
	var fr: Dictionary = CreatureArt.frames(String(art[0]), int(art[1]))
	var frames: Array = fr["frames"]
	var glows: Array = fr.get("glow", [])
	print("creatura: %s (%s), fotogrammi: %d" % [cr.get("name", id), id, frames.size()])
	var big := 8
	var sheet: Image = null
	for i in frames.size():
		var im := _img(frames[i])
		print("  fotogramma %d: %dx%d" % [i + 1, im.get_width(), im.get_height()])
		im.save_png(OUT + "%s_%d.png" % [id, i + 1])
		var b := im.duplicate()
		b.resize(im.get_width() * big, im.get_height() * big, Image.INTERPOLATE_NEAREST)
		b.save_png(OUT + "%s_%d_x%d.png" % [id, i + 1, big])
		if sheet == null:
			sheet = Image.create_empty(im.get_width() * frames.size(), im.get_height(), false, Image.FORMAT_RGBA8)
		sheet.blit_rect(im, Rect2i(Vector2i.ZERO, im.get_size()), Vector2i(i * im.get_width(), 0))
		if i < glows.size():
			var g := _img(glows[i])
			if not g.is_invisible():
				g.save_png(OUT + "%s_%d_luce.png" % [id, i + 1])
	sheet.save_png(OUT + "%s_foglio.png" % id)
	quit()


func _img(t: Variant) -> Image:
	return ((t as Texture2D).get_image() if t is Texture2D else (t as Image)).duplicate()
