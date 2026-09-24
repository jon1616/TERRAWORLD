class_name CreatureArt
extends RefCounted
## Creature semplici disegnate dal codice.

static func grumo(body: Color, light: Color, dark: Color) -> Image:
	var im := Px.img(16, 14)
	for y in 13:
		for x in 16:
			var dx := (x + 0.5 - 8.0) / 7.0
			var dy := (y + 0.5 - 12.5) / 9.0
			if y <= 12 and dx * dx + dy * dy <= 1.0:
				var t := 0.5 - dx * 0.3 - dy * 0.55
				var c := dark if t < 0.45 else (body if t < 0.8 else light)
				c.a = 0.88
				Px.put(im, x, y, c)
	Px.put(im, 5, 6, Color(1, 1, 1, 0.95))
	Px.put(im, 4, 7, Color(1, 1, 1, 0.8))
	Px.put(im, 9, 8, Px.OUTLINE)
	Px.put(im, 9, 9, Px.OUTLINE)
	Px.put(im, 12, 8, Px.OUTLINE)
	Px.put(im, 12, 9, Px.OUTLINE)
	Px.outline(im, Px.sh(dark, 0.45))
	return im
