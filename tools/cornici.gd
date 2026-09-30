extends SceneTree
## Le cornici dell'interfaccia (`UiFrames`, voce 270) in un foglio, ingrandite ×3, e allungate come in un pannello vero
## (9 pezzi): prove/cornici.png. Senza finestra: Godot_console.exe --headless --path . --script res://tools/cornici.gd

const KINDS := [["riquadro", "normale"], ["forte", "normale"], ["suggerimento", "normale"], ["casella", "normale"],
	["casella", "sopra"], ["casella", "scelto"], ["pulsante", "normale"], ["pulsante", "sopra"], ["pulsante", "premuto"],
	["pulsante", "spento"], ["pulsante", "scelto"], ["campo", "normale"], ["campo", "scelto"]]


func _init() -> void:
	var out := Image.create(1200, 60 + KINDS.size() * 0 + 700, false, Image.FORMAT_RGBA8)
	out.fill(Color("#1e2a2a"))
	var x := 10
	var y := 10
	for k in KINDS:
		var sb := UiFrames.box(String(k[0]), String(k[1]))
		var tex := sb.texture.get_image()
		var big := _nine(tex, 150, 90, int(sb.texture_margin_left))
		# (il centro si ripete come nel gioco)
		big.resize(big.get_width() * 2, big.get_height() * 2, Image.INTERPOLATE_NEAREST)
		if x + big.get_width() > 1190:
			x = 10
			y += 200
		out.blend_rect(big, Rect2i(Vector2i.ZERO, big.get_size()), Vector2i(x, y))
		x += big.get_width() + 12
	out.save_png(ProjectSettings.globalize_path("res://prove/cornici.png"))
	print("prove/cornici.png")
	quit()


## Allunga un'immagine a 9 pezzi a w×h (margine m), come fa StyleBoxTexture.
func _nine(src: Image, w: int, h: int, m: int) -> Image:
	var out := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var sw := src.get_width()
	var sh := src.get_height()
	for yy in h:
		var sy := yy if yy < m else (sh - (h - yy) if yy >= h - m else m + (yy - m) % maxi(sh - 2 * m, 1))
		for xx in w:
			var sx := xx if xx < m else (sw - (w - xx) if xx >= w - m else m + (xx - m) % maxi(sw - 2 * m, 1))
			out.set_pixel(xx, yy, src.get_pixel(sx, sy))
	return out
