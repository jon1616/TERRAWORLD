extends SceneTree
## Foglio degli alberi (26 set 2026): ogni specie di `TreesData` in ogni grandezza, due forme per grandezza, su un
## fondo scuro con il Germogliato (36 px) disegnato accanto per la misura. Salva prove/alberi.png e dice quanto costa
## disegnarli.
##   Godot_console.exe --headless --path . --script res://tools/alberi.gd


func _init() -> void:
	var cols := TreesData.SIZES.size() * 2
	var cw := 120
	var rh := 180
	var sheet := Image.create_empty(cols * cw + 60, TreesData.SPECIES.size() * rh, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#16303a"))
	var t0 := Time.get_ticks_msec()
	var n := 0
	for s in TreesData.SPECIES.size():
		var ground := (s + 1) * rh - 8
		for x in sheet.get_width():
			for y in range(ground, ground + 8):
				sheet.set_pixel(x, y, Color("#241624"))
		for size in TreesData.SIZES.size():
			for f in 2:
				var h := int(TreesData.SIZES[size]["h"])
				var tr := TreeArt.make(String(TreesData.SPECIES[s]["id"]), h, 7 + size * 31 + f * 131 + s * 977)
				n += 1
				var im: Image = tr["img"]
				var x0 := (size * 2 + f) * cw + cw / 2 - im.get_width() / 2
				sheet.blend_rect(im, Rect2i(Vector2i.ZERO, im.get_size()), Vector2i(x0, ground - im.get_height() + 3))
		# il Germogliato per la misura: un rettangolo ocra alto 36 px
		for y in range(ground - 36, ground):
			for x in range(cols * cw + 24, cols * cw + 34):
				sheet.set_pixel(x, y, Color("#d89040"))
	print("%d alberi disegnati in %d ms" % [n, Time.get_ticks_msec() - t0])
	sheet.save_png("res://prove/alberi.png")
	quit()
