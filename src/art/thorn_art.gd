class_name ThornArt
extends RefCounted
## Roadmap 52, voce 418: i disegni delle spine dei biomi e della ragnatela (decorazioni 101-105, `TileDefs.THORNS`).
## Le spine stanno sul pavimento (dal basso in su), la ragnatela in un angolo sotto il soffitto.


static func draw(id: int, im: Image, gm: Image, rng: RandomNumberGenerator) -> bool:
	match id:
		101:
			_bramble(im, rng, Color("#1a1210"), Color("#3a2420"), Color("#ff8a3a"))
			for k in 3:
				var q := Vector2i(rng.randi_range(3, 12), rng.randi_range(8, 14))
				gm.set_pixel(q.x, q.y, Color("#ff9a40"))         # la brace che si vede nel buio
			return true
		102:
			# aghi di ghiaccio dritti, azzurri e chiari in punta
			for k in 6:
				var x := 2 + k * 2 + rng.randi_range(0, 1)
				var h := rng.randi_range(4, 9)
				for s in h:
					im.set_pixel(x, 15 - s, Color("#7ab0d4") if s < h - 1 else Color("#eef8ff"))
			return true
		103:
			_bramble(im, rng, Color("#2a1638"), Color("#4a2a5e"), Color("#c49af0"))
			for k in 3:
				var q := Vector2i(rng.randi_range(3, 12), rng.randi_range(7, 13))
				gm.set_pixel(q.x, q.y, Color("#c890ff"))         # le spore che brillano appena
			return true
		104:
			# schegge di vetro inclinate, trasparenti con il filo chiaro
			for k in 5:
				var x := 2 + k * 3
				var h := rng.randi_range(3, 7)
				var lean := 1 if k % 2 == 0 else -1
				for s in h:
					var px := clampi(x + (s * lean) / 3, 0, 15)
					var c := Color("#d8f0c8") if s == h - 1 else Color(0.66, 0.78, 0.62, 0.75)
					im.set_pixel(px, 15 - s, c)
			return true
		105:
			# una ragnatela nell'angolo in alto a sinistra: raggi e due giri di filo
			var silk := Color(0.86, 0.88, 0.9, 0.7)
			for r in 4:
				var a := r * PI / 6.0
				for d in 15:
					var x := int(cos(a) * d)
					var y := int(sin(a) * d)
					if x < 16 and y < 16:
						im.set_pixel(x, y, silk)
			for ring in [6.0, 11.0]:
				for t in 24:
					var a2 := t * (PI / 2.0) / 23.0
					var x2 := int(cos(a2) * ring)
					var y2 := int(sin(a2) * ring)
					if x2 < 16 and y2 < 16:
						im.set_pixel(x2, y2, silk)
			return true
	return false


## Un cespuglio di rovi: rami storti dal pavimento con le spine chiare.
static func _bramble(im: Image, rng: RandomNumberGenerator, dark: Color, mid: Color, tip: Color) -> void:
	for k in 4:
		var x := float(rng.randi_range(2, 13))
		var y := 15.0
		var dx := rng.randf_range(-0.6, 0.6)
		for s in rng.randi_range(6, 11):
			var px := clampi(int(x), 0, 15)
			var py := clampi(int(y), 0, 15)
			im.set_pixel(px, py, dark if s < 3 else mid)
			if s % 3 == 2:
				im.set_pixel(clampi(px + (1 if s % 2 == 0 else -1), 0, 15), py, tip)
			x += dx
			y -= 1.0
