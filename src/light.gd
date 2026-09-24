class_name LightMap
extends RefCounted
## Luce a tessere alla Terraria: ogni cella ha un colore di luce che si propaga ai vicini perdendo forza
## (poco nell'aria, molto nella roccia). Il risultato è un'immagine di un pixel per tessera, stesa sul mondo
## ingrandita e sfumata, che moltiplica i colori: dove non arriva luce è buio pieno.

const AIR_DECAY := 0.915
const SOLID_DECAY := 0.68
const SKY := Color(1.0, 0.9, 0.78)
const TORCH := Color(2.3, 1.6, 0.95)
const CRYSTAL := Color(0.85, 0.52, 1.35)
const GLOWSHROOM := Color(0.3, 0.8, 1.15)
const PLAYER := Color(0.85, 0.72, 0.56)
const PR := 12
const FACES := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]                        # raggio della luce del giocatore

var world: World
var w := 0
var h := 0
var lr := PackedFloat32Array()
var lg := PackedFloat32Array()
var lb := PackedFloat32Array()
var dec := PackedFloat32Array()
var image: Image
var tex: ImageTexture
# luce del giocatore, in una finestra attorno a lui
var pw := PR * 2 + 1
var pr := PackedFloat32Array()
var pg := PackedFloat32Array()
var pb := PackedFloat32Array()
var prect := Rect2i(-100, -100, 0, 0)


func setup(wd: World) -> void:
	world = wd
	w = wd.w
	h = wd.h
	lr.resize(w * h)
	lg.resize(w * h)
	lb.resize(w * h)
	dec.resize(w * h)
	for y in h:
		for x in w:
			dec[y * w + x] = SOLID_DECAY if wd.solid(x, y) else AIR_DECAY
	pr.resize(pw * pw)
	pg.resize(pw * pw)
	pb.resize(pw * pw)
	image = Image.create_empty(w, h, false, Image.FORMAT_RGB8)
	relight(Rect2i(0, 0, w, h))
	tex = ImageTexture.create_from_image(image)
	redraw(Rect2i(0, 0, w, h))


func emission(x: int, y: int) -> Color:
	var t := world.tile(x, y)
	if t == Tiles.CRYSTAL:
		return CRYSTAL
	if t != Tiles.AIR:
		return Color(0, 0, 0)
	var c := Color(0, 0, 0)
	if world.wall(x, y) == 0:
		c = SKY
	if world.decor[y * w + x] == Tiles.DECOR_GLOW:
		c = _max(c, GLOWSHROOM)
	if world.torches.has(Vector2i(x, y)):
		c = _max(c, TORCH)
	return c


func _max(a: Color, b: Color) -> Color:
	return Color(maxf(a.r, b.r), maxf(a.g, b.g), maxf(a.b, b.b))


func _prop(i: int, j: int) -> void:
	var d := dec[i]
	var v := lr[j] * d
	if v > lr[i]:
		lr[i] = v
	v = lg[j] * d
	if v > lg[i]:
		lg[i] = v
	v = lb[j] * d
	if v > lb[i]:
		lb[i] = v


## Ricalcola la luce fissa in un rettangolo (i bordi leggono la luce già calcolata fuori).
func relight(rect: Rect2i) -> void:
	rect = rect.intersection(Rect2i(0, 0, w, h))
	var x0 := rect.position.x
	var y0 := rect.position.y
	var x1 := rect.end.x
	var y1 := rect.end.y
	for y in range(y0, y1):
		for x in range(x0, x1):
			var e := emission(x, y)
			var i := y * w + x
			lr[i] = e.r
			lg[i] = e.g
			lb[i] = e.b
	for it in 2:
		for y in range(y0, y1):
			var row := y * w
			for x in range(maxi(x0, 1), x1):
				_prop(row + x, row + x - 1)
			for x in range(mini(x1 - 1, w - 2), x0 - 1, -1):
				_prop(row + x, row + x + 1)
		for x in range(x0, x1):
			for y in range(maxi(y0, 1), y1):
				_prop(y * w + x, (y - 1) * w + x)
			for y in range(mini(y1 - 1, h - 2), y0 - 1, -1):
				_prop(y * w + x, (y + 1) * w + x)


func tile_changed(c: Vector2i) -> void:
	dec[c.y * w + c.x] = SOLID_DECAY if world.solid(c.x, c.y) else AIR_DECAY
	var r := Rect2i(c - Vector2i(20, 20), Vector2i(41, 41))
	relight(r)
	_player_light()
	redraw(r)


## Luce portata dal giocatore: si calcola solo nella sua finestra e si somma (col massimo) a quella fissa.
func set_player(cell: Vector2i) -> void:
	var old := prect
	prect = Rect2i(cell - Vector2i(PR, PR), Vector2i(pw, pw))
	_player_light()
	redraw(old)
	redraw(prect)


func _player_light() -> void:
	pr.fill(0.0)
	pg.fill(0.0)
	pb.fill(0.0)
	var c := PR * pw + PR
	pr[c] = PLAYER.r
	pg[c] = PLAYER.g
	pb[c] = PLAYER.b
	var ox := prect.position.x
	var oy := prect.position.y
	var dl := PackedFloat32Array()
	dl.resize(pw * pw)
	for y in pw:
		for x in pw:
			var wx := ox + x
			var wy := oy + y
			dl[y * pw + x] = SOLID_DECAY if world.solid(wx, wy) else AIR_DECAY
	for it in 2:
		for y in pw:
			for x in range(1, pw):
				_pprop(y * pw + x, y * pw + x - 1, dl)
			for x in range(pw - 2, -1, -1):
				_pprop(y * pw + x, y * pw + x + 1, dl)
		for x in pw:
			for y in range(1, pw):
				_pprop(y * pw + x, (y - 1) * pw + x, dl)
			for y in range(pw - 2, -1, -1):
				_pprop(y * pw + x, (y + 1) * pw + x, dl)


func _pprop(i: int, j: int, dl: PackedFloat32Array) -> void:
	var d := dl[i]
	var v := pr[j] * d
	if v > pr[i]:
		pr[i] = v
	v = pg[j] * d
	if v > pg[i]:
		pg[i] = v
	v = pb[j] * d
	if v > pb[i]:
		pb[i] = v


## Luce di una cella: quella fissa più quella del giocatore.
func _lit(x: int, y: int) -> Color:
	var i := y * w + x
	var c := Color(lr[i], lg[i], lb[i])
	if prect.has_point(Vector2i(x, y)):
		var k := (y - prect.position.y) * pw + (x - prect.position.x)
		c = Color(maxf(c.r, pr[k]), maxf(c.g, pg[k]), maxf(c.b, pb[k]))
	return c


func redraw(rect: Rect2i) -> void:
	rect = rect.intersection(Rect2i(0, 0, w, h))
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var c := _lit(x, y)
			if world.solid(x, y):
				# la faccia di un blocco che tocca l'aria è illuminata quasi come l'aria davanti
				for o in FACES:
					var nx: int = x + o.x
					var ny: int = y + o.y
					if nx >= 0 and ny >= 0 and nx < w and ny < h and not world.solid(nx, ny):
						var n := _lit(nx, ny) * 0.92
						c = Color(maxf(c.r, n.r), maxf(c.g, n.g), maxf(c.b, n.b))
			var r := c.r
			var g := c.g
			var b := c.b
			# la grafica 2D lavora in spazio lineare: la texture va codificata sRGB, o il buio si raddoppia
			image.set_pixel(x, y, Color(pow(minf(r, 1.0), 0.7), pow(minf(g, 1.0), 0.7), pow(minf(b, 1.0), 0.7)).linear_to_srgb())
	if tex:
		tex.update(image)


func brightness_at(p: Vector2) -> Color:
	var x := clampi(int(p.x / 16.0), 0, w - 1)
	var y := clampi(int(p.y / 16.0), 0, h - 1)
	return image.get_pixel(x, y)
