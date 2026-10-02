class_name OrnamentArt
extends RefCounted
## Roadmap 33, voce 326: i dettagli dei bordi del mondo, disegnati solo nella vista (non sono tessere né decorazioni:
## non si raccolgono, non si salvano). Dove il terreno tocca l'aria, sotto terra: radichette e stalattiti che pendono dai
## soffitti, gocce di Linfa, ciottoli e schegge sui pavimenti. Ogni strato ha i suoi (`KINDS`); la scelta nasce dalla
## cella (`pick`), sempre uguale per la stessa cella. Le prove: il gruppo «volto».

const S := 16
## Le figure dell'atlante (una riga): indice -> [che cosa, dove: "su" pende dal soffitto, "giu" sta sul pavimento].
const TILES := [
	["radichetta", "su"], ["radichetta", "su"], ["radichetta", "su"], ["radichetta", "su"],
	["stalattite", "su"], ["stalattite", "su"], ["stalattite", "su"], ["stalattite", "su"],
	["ciottoli", "giu"], ["ciottoli", "giu"], ["ciottoli", "giu"], ["ciottoli", "giu"],
	["goccia", "su"], ["goccia", "su"],
	["scheggia", "giu"], ["scheggia", "giu"],
	["stalattite_vuoto", "su"], ["stalattite_vuoto", "su"], ["stalattite_vuoto", "su"],
	["ciottoli_scuri", "giu"], ["ciottoli_scuri", "giu"],
]
## Gli strati (indice = `StrataData`): figure del soffitto, figure del pavimento, quanto spesso (soffitto, pavimento).
const KINDS := [
	[[], [], 0.0, 0.0],
	[[0, 1, 2, 3], [19, 20], 0.42, 0.22],
	[[4, 5, 6, 7, 0, 1], [8, 9, 10, 11], 0.38, 0.26],
	[[4, 5, 12, 13, 12], [8, 9, 10, 11], 0.38, 0.24],
	[[16, 17, 18], [14, 15, 19], 0.36, 0.24],
]
const PAL := {
	"radichetta": ["#2a1a22", "#4a2e36", "#6a4646"],
	"stalattite": ["#2e3646", "#4a5468", "#6e7a90"],
	"ciottoli": ["#262c38", "#3e4656", "#5e6878"],
	"ciottoli_scuri": ["#22181e", "#3a2a30", "#584048"],
	"goccia": ["#1c4a4a", "#2f8a84", "#7ff0dc"],
	"scheggia": ["#24163a", "#4a2e78", "#9a6ae0"],
	"stalattite_vuoto": ["#1e1630", "#36285a", "#5a4688"],
}

static var _ts: TileSet


## La figura per una cella d'aria (-1 = nessuna): `up` = c'è roccia sopra, `down` = c'è roccia sotto.
static func pick(x: int, y: int, stratum: int, up: bool, down: bool) -> int:
	if stratum < 1 or stratum >= KINDS.size():
		return -1
	var k: Array = KINDS[stratum]
	var h := ((x * 73856093) ^ (y * 19349663) ^ 0x5bd1e995) & 0x7fffffff
	var r := float(h % 1000) / 1000.0
	if up and r < float(k[2]):
		var list: Array = k[0]
		return int(list[(h / 1000) % list.size()])
	if down and not up and r < float(k[3]):
		var list2: Array = k[1]
		return int(list2[(h / 1000) % list2.size()])
	return -1


static func tileset() -> TileSet:
	if _ts != null:
		return _ts
	var img := Image.create_empty(S * TILES.size(), S, false, Image.FORMAT_RGBA8)
	for i in TILES.size():
		_draw(img, i)
	var src := TileSetAtlasSource.new()
	src.texture = ImageTexture.create_from_image(img)
	src.texture_region_size = Vector2i(S, S)
	for i in TILES.size():
		src.create_tile(Vector2i(i, 0))
	_ts = TileSet.new()
	_ts.tile_size = Vector2i(S, S)
	_ts.add_source(src, 0)
	return _ts


static func _draw(img: Image, i: int) -> void:
	var kind := String(TILES[i][0])
	var p: Array = PAL[kind]
	var c0 := Color(String(p[0]))
	var c1 := Color(String(p[1]))
	var c2 := Color(String(p[2]))
	var ox := i * S
	var rng := RandomNumberGenerator.new()
	rng.seed = 4400 + i * 17
	match kind:
		"radichetta":
			for n in rng.randi_range(2, 3):
				var x := rng.randi_range(3, 12)
				var ln := rng.randi_range(4, 10)
				for y in ln:
					if y > 2 and rng.randf() < 0.25:
						x = clampi(x + (1 if rng.randf() < 0.5 else -1), 1, 14)
					_px(img, ox + x, y, c1 if y < ln - 2 else c2)
					if y < 2:
						_px(img, ox + x + 1, y, c0)
		"stalattite", "stalattite_vuoto":
			for n in rng.randi_range(1, 2):
				var cx := rng.randi_range(4, 11)
				var w := rng.randi_range(2, 3)
				var ln := rng.randi_range(4, 9)
				for y in ln:
					var half := maxi(int(round(w * (1.0 - float(y) / ln))), 0)
					for dx in range(-half, half + 1):
						_px(img, ox + cx + dx, y, c2 if dx == -half and y > 0 else (c0 if dx == half else c1))
		"goccia":
			var gx := rng.randi_range(5, 10)
			var gl := rng.randi_range(3, 6)
			for y in gl:
				_px(img, ox + gx, y, c1)
			_px(img, ox + gx, gl, c2)
			_px(img, ox + gx, gl + 1, c2)
			_px(img, ox + gx - 1, gl + 1, c1)
			_px(img, ox + gx + 1, gl + 1, c1)
			_px(img, ox + gx, gl + 2, c1)
		"ciottoli", "ciottoli_scuri":
			for n in rng.randi_range(2, 4):
				var x := rng.randi_range(1, 13)
				var w := rng.randi_range(1, 3)
				var h := rng.randi_range(1, 2)
				for yy in h:
					for xx in w:
						_px(img, ox + x + xx, S - 1 - yy, c2 if yy == h - 1 and xx == 0 else c1)
				_px(img, ox + x + w, S - 1, c0)
		"scheggia":
			for n in rng.randi_range(1, 2):
				var x := rng.randi_range(3, 12)
				var hh := rng.randi_range(2, 5)
				for yy in hh:
					_px(img, ox + x, S - 1 - yy, c2 if yy == hh - 1 else c1)
					if yy < hh - 2:
						_px(img, ox + x + 1, S - 1 - yy, c0)


static func _px(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
		img.set_pixel(x, y, c)
