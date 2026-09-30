extends SceneTree
## Il foglio dei baccelli dormienti (voce 301), ingranditi sei volte, su un fondo di grotta → prove/baccelli.png


func _init() -> void:
	var n := PodsData.LAST - PodsData.FIRST + 1
	var sheet := Image.create(n * 16 * 6 + (n + 1) * 8, 16 * 6 + 16, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#1a1218"))
	for k in n:
		var img: Image = (DecorPainter.decor(PodsData.FIRST + k)["img"] as Image).duplicate()
		img.resize(96, 96, Image.INTERPOLATE_NEAREST)
		sheet.blend_rect(img, Rect2i(0, 0, 96, 96), Vector2i(8 + k * 104, 8))
	sheet.save_png("res://prove/baccelli.png")
	print("prove/baccelli.png")
	quit()
