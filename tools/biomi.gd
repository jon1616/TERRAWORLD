extends SceneTree
## Il foglio dei biomi (voce 91): una riga per bioma di `BiomesData`, con la trama dell'erba sopra l'humus, il cielo
## del bioma, l'albero in tre grandezze, le piante della sua vegetazione e le creature che vivono solo lì (o anche lì).
## Serve al controllo a occhio quando si aggiunge un bioma. Salva prove/biomi.png.
##   Godot_console.exe --headless --path . --script res://tools/biomi.gd

const ROW := 190
const W := 1180


func _init() -> void:
	var n := BiomesData.BIOMES.size()
	var sheet := Image.create_empty(W, n * ROW, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#101c22"))
	for i in n:
		var b: Dictionary = BiomesData.BIOMES[i]
		var y0 := i * ROW
		var ground := y0 + ROW - 40
		# il cielo del bioma e la fascia del colore della scritta
		var sky := Color("#2a6a78") * (b["tint"] as Color)
		sheet.fill_rect(Rect2i(0, y0, W, ground - y0), Color(sky, 1.0).darkened(0.35))
		sheet.fill_rect(Rect2i(0, y0, 8, ROW), Color(String(b["color"])))
		# il terreno: l'erba del bioma sopra l'humus, con le trame vere
		var turf: Dictionary = b["turf"]
		var grass := TerrainPainter.material(String(turf["layer"]), Px.pal(turf["pal"]), 7)
		var humus := TerrainPainter.material("humus", Px.pal(TileDefs.P_DIRT), 7)
		for x in range(8, W):
			for y in range(ground, y0 + ROW):
				var tex := grass if y < ground + 10 else humus
				sheet.set_pixel(x, y, tex[((y - ground) % 64) * 64 + (x % 64)])
		# l'albero in tre grandezze
		var sp: Dictionary = TreesData.SPECIES[i]
		var x := 20
		for size in 3:
			var tr := TreeArt.make(String(sp["art"]), int(TreesData.SIZES[size]["h"]), 11 + size * 31 + i * 977)
			var im: Image = tr["img"]
			sheet.blend_rect(im, Rect2i(Vector2i.ZERO, im.get_size()), Vector2i(x, ground - im.get_height() + 3))
			x += im.get_width() + 6
		# la vegetazione: ogni pianta della sua tabella, ingrandita ×2
		x += 20
		var rng := RandomNumberGenerator.new()
		for e in b.get("veg", []):
			var d := PassDecorazioni._veg([[1.0, e[1]]], 0.0, rng)
			if d <= 0:
				continue
			var im: Image = DecorPainter.decor(d)["img"]
			im.resize(32, 32, Image.INTERPOLATE_NEAREST)
			sheet.blend_rect(im, Rect2i(0, 0, 32, 32), Vector2i(x, ground - 30))
			x += 36
		# le creature del bioma (in superficie), ingrandite ×2
		x += 30
		for id in CreaturesData.CREATURES:
			var cd: Dictionary = CreaturesData.CREATURES[id]
			if not (b["id"] in cd.get("biomes", [])):
				continue
			var art: Array = cd.get("art", [])
			if art.size() < 2:
				continue
			var fr: Dictionary = CreatureArt.frames(String(art[0]), int(art[1]))
			var im: Image = (fr["frames"][0] as Image).duplicate()
			im.resize(im.get_width() * 2, im.get_height() * 2, Image.INTERPOLATE_NEAREST)
			if x + im.get_width() > W:
				break
			sheet.blend_rect(im, Rect2i(Vector2i.ZERO, im.get_size()), Vector2i(x, ground - im.get_height() + 2))
			x += im.get_width() + 8
		print("%s: albero %s, %d piante, erba «%s»" % [b["name"], sp["name"], (b.get("veg", []) as Array).size(), turf["name"]])
	sheet.save_png("res://prove/biomi.png")
	print("salvato prove/biomi.png (%d biomi)" % n)
	quit()
