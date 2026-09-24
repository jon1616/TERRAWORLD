class_name LightMap
extends RefCounted
## Luce a tessere alla Terraria, calcolata solo in una finestra attorno alla visuale e in un thread a parte.
## Ogni cella ha un colore di luce che si propaga ai vicini perdendo forza (poco nell'aria, molto nei blocchi).
## Il risultato è un'immagine di un pixel per tessera, stesa sul mondo ingrandita e sfumata, che moltiplica i colori:
## dove non arriva luce è buio pieno.

const AIR_DECAY := 0.915
const SOLID_DECAY := 0.62
const SKY := Color(1.0, 0.9, 0.78)
const TORCH := Color(2.3, 1.6, 0.95)
const PLAYER := Color(0.85, 0.72, 0.56)
const LW := 128                       # finestra in tessere (la visuale è circa 50×28)
const LH := 96
const RECENTER := 6                   # ricentra quando la visuale si sposta di tante tessere

var world: World
var image: Image
var tex: ImageTexture
var origin := Vector2i.ZERO           # cella del mondo nell'angolo in alto a sinistra dell'immagine mostrata
var dirty := true                     # il mondo è cambiato (scavo, torcia): va ricalcolata
var _center := Vector2i(-9999, -9999)
var _player := Vector2i(-9999, -9999)
var _task := -1
var _job: Dictionary = {}


func setup(w: World) -> void:
	world = w
	image = Image.create_empty(LW, LH, false, Image.FORMAT_RGB8)
	tex = ImageTexture.create_from_image(image)


## Chiamata ogni fotogramma. Restituisce true quando è pronta un'immagine nuova (l'origine può essere cambiata).
func update(view_center: Vector2i, player_cell: Vector2i) -> bool:
	var ready := false
	if _task >= 0 and WorkerThreadPool.is_task_completed(_task):
		WorkerThreadPool.wait_for_task_completion(_task)
		_task = -1
		origin = _job["origin"]
		tex.update(_job["image"])
		ready = true
	if _task < 0:
		var moved := absi(view_center.x - _center.x) >= RECENTER or absi(view_center.y - _center.y) >= RECENTER
		if dirty or moved or player_cell != _player:
			_start(view_center if moved or _center.x < -999 else _center, player_cell)
	return ready


## Calcolo immediato, senza thread (all'avvio e nelle prove automatiche).
func compute_now(view_center: Vector2i, player_cell: Vector2i) -> void:
	if _task >= 0:
		WorkerThreadPool.wait_for_task_completion(_task)
		_task = -1
	_start(view_center, player_cell)
	WorkerThreadPool.wait_for_task_completion(_task)
	_task = -1
	origin = _job["origin"]
	tex.update(_job["image"])


func _start(center: Vector2i, player_cell: Vector2i) -> void:
	_center = center
	_player = player_cell
	dirty = false
	var o := center - Vector2i(LW / 2, LH / 2)
	o.x = clampi(o.x, 0, maxi(world.w - LW, 0))
	o.y = clampi(o.y, -LH / 4, maxi(world.h - LH, 0))
	var job := {
		"origin": o, "tiles": world.tiles, "walls": world.walls, "decor": world.decor, "w": world.w, "h": world.h,
		"torches": world.torches_in(Rect2i(o, Vector2i(LW, LH))), "player": player_cell,
	}
	_job = job
	_task = WorkerThreadPool.add_task(_solve.bind(job), false, "luce")


## Il calcolo vero, nel thread: legge copie dei dati del mondo e scrive l'immagine nel lavoro.
static func _solve(job: Dictionary) -> void:
	var o: Vector2i = job["origin"]
	var tiles: PackedByteArray = job["tiles"]
	var walls: PackedByteArray = job["walls"]
	var decor: PackedByteArray = job["decor"]
	var ww: int = job["w"]
	var wh: int = job["h"]
	var n := LW * LH
	var r := PackedFloat32Array()
	var g := PackedFloat32Array()
	var b := PackedFloat32Array()
	var d := PackedFloat32Array()
	var solid := PackedByteArray()
	r.resize(n)
	g.resize(n)
	b.resize(n)
	d.resize(n)
	solid.resize(n)
	var cr := TileDefs.LIGHT_CRYSTAL
	var cg := TileDefs.LIGHT_GLOW_DECOR
	for y in LH:
		var wy := o.y + y
		for x in LW:
			var wx := o.x + x
			var i := y * LW + x
			var t := TileDefs.AIR
			var wl := 0
			var dc := 0
			if wy >= wh or wx < 0 or wx >= ww:
				t = TileDefs.STONE
			elif wy >= 0:
				var k := wy * ww + wx
				t = tiles[k]
				wl = walls[k]
				dc = decor[k]
			if t != TileDefs.AIR:
				solid[i] = 1
				d[i] = SOLID_DECAY
				if t == TileDefs.CRYSTAL:
					r[i] = cr.r
					g[i] = cr.g
					b[i] = cr.b
			else:
				d[i] = AIR_DECAY
				if wl == 0:
					r[i] = SKY.r
					g[i] = SKY.g
					b[i] = SKY.b
				if dc == TileDefs.DECOR_GLOW:
					r[i] = maxf(r[i], cg.r)
					g[i] = maxf(g[i], cg.g)
					b[i] = maxf(b[i], cg.b)
	var sources: Array = job["torches"]
	for tc in sources:
		var i: int = (tc.y - o.y) * LW + (tc.x - o.x)
		r[i] = maxf(r[i], TORCH.r)
		g[i] = maxf(g[i], TORCH.g)
		b[i] = maxf(b[i], TORCH.b)
	var pc: Vector2i = job["player"] - o
	if pc.x >= 0 and pc.y >= 0 and pc.x < LW and pc.y < LH:
		var i := pc.y * LW + pc.x
		r[i] = maxf(r[i], PLAYER.r)
		g[i] = maxf(g[i], PLAYER.g)
		b[i] = maxf(b[i], PLAYER.b)
	# propagazione: quattro passaggi (→ ← ↓ ↑), ripetuti due volte per girare gli angoli
	for it in 2:
		for y in LH:
			var row := y * LW
			for x in range(1, LW):
				var i := row + x
				var dd := d[i]
				var v := r[i - 1] * dd
				if v > r[i]:
					r[i] = v
				v = g[i - 1] * dd
				if v > g[i]:
					g[i] = v
				v = b[i - 1] * dd
				if v > b[i]:
					b[i] = v
			for x in range(LW - 2, -1, -1):
				var i := row + x
				var dd := d[i]
				var v := r[i + 1] * dd
				if v > r[i]:
					r[i] = v
				v = g[i + 1] * dd
				if v > g[i]:
					g[i] = v
				v = b[i + 1] * dd
				if v > b[i]:
					b[i] = v
		for x in LW:
			for y in range(1, LH):
				var i := y * LW + x
				var dd := d[i]
				var v := r[i - LW] * dd
				if v > r[i]:
					r[i] = v
				v = g[i - LW] * dd
				if v > g[i]:
					g[i] = v
				v = b[i - LW] * dd
				if v > b[i]:
					b[i] = v
			for y in range(LH - 2, -1, -1):
				var i := y * LW + x
				var dd := d[i]
				var v := r[i + LW] * dd
				if v > r[i]:
					r[i] = v
				v = g[i + LW] * dd
				if v > g[i]:
					g[i] = v
				v = b[i + LW] * dd
				if v > b[i]:
					b[i] = v
	# immagine: la faccia di un blocco che tocca l'aria prende quasi la luce dell'aria davanti; poi una curva che
	# schiarisce i toni medi e la codifica sRGB (la grafica 2D lavora in spazio lineare, vedi CLAUDE.md)
	var img := Image.create_empty(LW, LH, false, Image.FORMAT_RGB8)
	for y in LH:
		for x in LW:
			var i := y * LW + x
			var vr := r[i]
			var vg := g[i]
			var vb := b[i]
			if solid[i] == 1:
				for k in [i - 1, i + 1, i - LW, i + LW]:
					if k >= 0 and k < n and solid[k] == 0 and absi((k % LW) - x) <= 1:
						vr = maxf(vr, r[k] * 0.92)
						vg = maxf(vg, g[k] * 0.92)
						vb = maxf(vb, b[k] * 0.92)
			img.set_pixel(x, y, Color(pow(minf(vr, 1.0), 0.7), pow(minf(vg, 1.0), 0.7), pow(minf(vb, 1.0), 0.7)).linear_to_srgb())
	job["image"] = img
