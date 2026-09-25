class_name LightMap
extends RefCounted
## Luce a tessere alla Terraria, calcolata solo in una finestra attorno alla visuale e in un thread a parte.
## Ogni cella ha un colore di luce che si propaga ai vicini perdendo forza (poco nell'aria, molto nei blocchi).
## Il risultato è un'immagine di un pixel per tessera, stesa sul mondo ingrandita e sfumata, che moltiplica i colori.
## Buio vero (richiesta dell'utente del 25 set 2026: «il buio non c'è, le torce non servono»): lontano dalle luci è nero
## pieno (`ambient` è nero in tutti gli strati; resta per effetti futuri, per esempio una pozione per vedere al buio). Il Germogliato porta un piccolo alone
## suo; per vedere lontano servono torce, Lanterna di Linfa o Pozione di bagliore. Le luci perdono forza in fretta:
## con AIR_DECAY 0,88 una torcia illumina in pieno ~6 tessere e sfuma fino a ~20, l'alone del giocatore ~8.

const AMBIENT := Color(0.14, 0.16, 0.21)
const AIR_DECAY := 0.88
const SOLID_DECAY := 0.5
const SKY := Color(0.92, 0.95, 1.0)
const TORCH := Color(2.2, 1.55, 0.9)
const STATION := Color(1.7, 1.0, 0.45)      # la brace del Baccello ardente
const PLAYER := Color(0.62, 0.52, 0.38)       # l'alone del Germogliato: vede solo attorno a sé
const CURVE := 0.85                     # < 1 schiarisce un poco i toni medi senza sollevare il buio
## Soglia di taglio: la luce cala a ogni tessera ma non arriva mai a zero, e la sua coda lunga lasciava vedere tutto
## (appunto dell'utente del 25 set 2026, con un'immagine di riferimento: dove la luce non arriva deve essere nero pieno).
## Sotto CUT è nero, sopra si riscala: il confine tra luce e buio diventa netto.
const CUT := 0.1
const LW := 128                       # finestra in tessere (la visuale è circa 50×28)
const LH := 96
const RECENTER := 6                   # ricentra quando la visuale si sposta di tante tessere

var world: World
var image: Image
var tex: ImageTexture
var origin := Vector2i.ZERO           # cella del mondo nell'angolo in alto a sinistra dell'immagine mostrata
var player_light := PLAYER            # la luce attorno al giocatore (più forte con la lanterna o il bagliore)
var ambient := AMBIENT                # chiarore minimo, secondo lo strato in cui si trova il giocatore
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
		image = _job["image"]
		tex.update(image)
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
	image = _job["image"]
	tex.update(image)


## Luminosità (0-1, come si vede) di una cella nell'ultima immagine calcolata; -1 se è fuori dalla finestra.
func value_at(c: Vector2i) -> float:
	var p := c - origin
	if p.x < 0 or p.y < 0 or p.x >= LW or p.y >= LH:
		return -1.0
	return image.get_pixelv(p).srgb_to_linear().get_luminance()


func _start(center: Vector2i, player_cell: Vector2i) -> void:
	_center = center
	_player = player_cell
	dirty = false
	var o := center - Vector2i(LW / 2, LH / 2)
	o.x = clampi(o.x, 0, maxi(world.w - LW, 0))
	o.y = clampi(o.y, -LH / 4, maxi(world.h - LH, 0))
	var job := {
		"origin": o, "tiles": world.tiles, "walls": world.walls, "decor": world.decor, "w": world.w, "h": world.h,
		"torches": world.torches_in(Rect2i(o, Vector2i(LW, LH))), "player": player_cell, "player_light": player_light,
		"decor_light": _decor_light(), "lights": _station_lights(Rect2i(o, Vector2i(LW, LH))), "ambient": ambient,
	}
	_job = job
	_task = WorkerThreadPool.add_task(_solve.bind(job), false, "luce")


## Stazioni che fanno luce nella finestra: [cella, colore].
func _station_lights(r: Rect2i) -> Array:
	var out := []
	for o in world.stations:
		var st: Dictionary = StationsData.STATIONS[world.stations[o]]
		if st.get("light", false):
			var size: Array = st["size"]
			var c: Vector2i = o + Vector2i(size[0] / 2, size[1] - 1)
			if r.has_point(c):
				out.append([c, st.get("light_color", STATION)])
	return out


## Luce di ogni decorazione (indice = id), nera se non ne emette.
static func _decor_light() -> PackedColorArray:
	var out := PackedColorArray()
	out.resize(TileDefs.DECOR_COUNT + 1)
	for id in TileDefs.DECOR_LIGHT:
		out[id] = TileDefs.DECOR_LIGHT[id]
	return out


## Il calcolo vero, nel thread: legge copie dei dati del mondo e scrive l'immagine nel lavoro.
static func _solve(job: Dictionary) -> void:
	var o: Vector2i = job["origin"]
	var tiles: PackedByteArray = job["tiles"]
	var walls: PackedByteArray = job["walls"]
	var decor: PackedByteArray = job["decor"]
	var ww: int = job["w"]
	var wh: int = job["h"]
	var amb: Color = job["ambient"]
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
	var dlight: PackedColorArray = job["decor_light"]
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
				if dc != 0:
					var cg := dlight[dc]
					r[i] = maxf(r[i], cg.r)
					g[i] = maxf(g[i], cg.g)
					b[i] = maxf(b[i], cg.b)
	var sources: Array = job["torches"]
	for tc in sources:
		var i: int = (tc.y - o.y) * LW + (tc.x - o.x)
		r[i] = maxf(r[i], TORCH.r)
		g[i] = maxf(g[i], TORCH.g)
		b[i] = maxf(b[i], TORCH.b)
	for lt in job["lights"]:
		var lc: Vector2i = lt[0]
		var col: Color = lt[1]
		var li: int = (lc.y - o.y) * LW + (lc.x - o.x)
		r[li] = maxf(r[li], col.r)
		g[li] = maxf(g[li], col.g)
		b[li] = maxf(b[li], col.b)
	var pc: Vector2i = job["player"] - o
	if pc.x >= 0 and pc.y >= 0 and pc.x < LW and pc.y < LH:
		var i := pc.y * LW + pc.x
		var pl: Color = job["player_light"]
		r[i] = maxf(r[i], pl.r)
		g[i] = maxf(g[i], pl.g)
		b[i] = maxf(b[i], pl.b)
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
			vr = maxf(vr, amb.r)
			vg = maxf(vg, amb.g)
			vb = maxf(vb, amb.b)
			vr = maxf(minf(vr, 1.0) - CUT, 0.0) / (1.0 - CUT)
			vg = maxf(minf(vg, 1.0) - CUT, 0.0) / (1.0 - CUT)
			vb = maxf(minf(vb, 1.0) - CUT, 0.0) / (1.0 - CUT)
			img.set_pixel(x, y, Color(pow(vr, CURVE), pow(vg, CURVE), pow(vb, CURVE)).linear_to_srgb())
	job["image"] = img
