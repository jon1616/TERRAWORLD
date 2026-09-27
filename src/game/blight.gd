class_name Blight
extends Node
## L'Avvizzimento (voce 18, UNIVERSO.md «la minaccia»): le tessere avvizzite (`TileDefs.BLIGHTED`) contagiano piano
## terra, erbe e ardesia vicine finché il Guardiano del mondo dorme. Sconfitto il Guardiano, l'Avvizzimento si ferma;
## **curato**, si ritira un poco alla volta: la scelta del giocatore cambia il mondo.
## Si purifica anche a mano: il Seme di muschio (cerchio piccolo) e la Rugiada di Linfa (cerchio grande).
## Le tessere malate sono salvate con il mondo come tutte le altre; l'elenco `cells` si ricostruisce all'avvio.

const EVERY := 1.5                     # secondi tra un contagio (o un ritiro) e l'altro
const PER_TICK := 6                    # tessere contagiate (o guarite) a ogni giro
const SEED_R := 4                      # raggio della purificazione del Seme di muschio
const DEW_R := 7                       # raggio della Rugiada di Linfa

var m: Node2D
var cells: Array[Vector2i] = []
var paused := false                    # le prove lo fermano quando serve un mondo immobile
var spread_mult := 1.0                 # tratto «Avvizzito» del mondo (voce 39)
var _t := EVERY
var _rng := RandomNumberGenerator.new()
var _task := -1


func setup(main: Node2D) -> void:
	m = main
	# l'elenco delle tessere malate: si cerca in un thread (3 milioni di tessere)
	var w: World = m.world
	var found: Array[Vector2i] = []
	_task = WorkerThreadPool.add_task(func() -> void:
		var t := w.tiles
		for i in t.size():
			if t[i] >= TileDefs.AVV_TERRA and t[i] <= TileDefs.AVV_PIETRA:
				found.append(Vector2i(i % w.w, i / w.w))
		cells = found, false, "avvizzimento")


func ready() -> bool:
	if _task >= 0 and WorkerThreadPool.is_task_completed(_task):
		WorkerThreadPool.wait_for_task_completion(_task)
		_task = -1
	return _task < 0


func _process(dt: float) -> void:
	if not m.built or paused or not ready():
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = EVERY
	tick()


## Un giro di contagio (o di ritiro): secondo il Guardiano del mondo e il Seme Nero.
func tick() -> void:
	# voce 72: il Seme Nero curato fa ritirare l'Avvizzimento in tutti i mondi; spezzato, non si allarga più
	var sn := String(m.character.seme_nero)
	if sn == "curato":
		recede(PER_TICK)
		return
	match String(m.world_meta.get("guardiano", "dorme")):
		"dorme":
			if sn != "spezzato":
				spread(roundi(PER_TICK * spread_mult))
		"curato":
			recede(PER_TICK)


## Contagia fino a n tessere accanto a quelle già malate. Restituisce quante.
func spread(n: int) -> int:
	var done := 0
	var w: World = m.world
	for k in n * 8:                          # molti tentativi cadono dentro la macchia: il contagio vero è sul bordo
		if cells.is_empty() or done >= n:
			break
		var c: Vector2i = cells[_rng.randi_range(0, cells.size() - 1)]
		var q := c + Vector2i(_rng.randi_range(-1, 1), _rng.randi_range(-1, 1))
		if not w.inside(q.x, q.y):
			continue
		var b := TileDefs.blighted_of(w.tile(q.x, q.y))
		if b < 0:
			continue
		w.set_tile(q.x, q.y, b)
		var d := w.decor_at(q.x, q.y - 1)
		if d != 0 and not d in TileDefs.DECOR_CEILING:
			w.set_decor(q.x, q.y - 1, 0)          # fiori e felci sopra appassiscono
		cells.append(q)
		m.view.refresh_around(q)
		done += 1
	return done


## Guarisce fino a n tessere malate (il Guardiano è stato curato). Restituisce quante.
func recede(n: int) -> int:
	var done := 0
	while done < n and not cells.is_empty():
		var i := _rng.randi_range(0, cells.size() - 1)
		var c: Vector2i = cells[i]
		cells[i] = cells[cells.size() - 1]
		cells.pop_back()
		if _heal(c):
			done += 1
	return done


## Purifica un cerchio (Seme di muschio, Rugiada di Linfa). Restituisce le tessere guarite.
func purify(center: Vector2i, r: int) -> int:
	var n := 0
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			if dx * dx + dy * dy <= r * r and _heal(center + Vector2i(dx, dy)):
				n += 1
	if n > 0:
		var keep: Array[Vector2i] = []
		for c in cells:
			if m.world.tile(c.x, c.y) in TileDefs.BLIGHTED:
				keep.append(c)
		cells = keep
		Fx.puff(m.fx, Vector2(center) * 16.0 + Vector2(8, 8), Color(0.6, 1.8, 1.4))
		m.light.dirty = true
	return n


## Una tessera malata torna sana: la terra e l'ardesia com'erano, le erbe secondo il bioma della colonna.
func _heal(c: Vector2i) -> bool:
	var w: World = m.world
	var t := w.tile(c.x, c.y)
	var back := -1
	match t:
		TileDefs.AVV_TERRA:
			back = TileDefs.DIRT
		TileDefs.AVV_PIETRA:
			back = TileDefs.STONE
		TileDefs.AVV_MUSCHIO:
			back = int(BiomesData.BIOMES[BiomesData.at(w, c.x)]["grass"])
	if back < 0:
		return false
	w.set_tile(c.x, c.y, back)
	m.view.refresh_around(c)
	return true


## Uso dalla mano: Seme di muschio su una zona avvizzita.
func use_seed(c: Vector2i) -> bool:
	if not m.actions.in_reach(c):
		return false
	if not _near_blight(c, SEED_R):
		m.hud.toast("Il Seme di muschio serve sulle zone avvizzite")
		return false
	if not m.character.bisaccia.remove("seme_muschio", 1):
		return false
	var n := purify(c, SEED_R)
	m.hud.toast("Il muschio rifiorisce: %d tessere guarite" % n)
	return true


func _near_blight(c: Vector2i, r: int) -> bool:
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			if m.world.tile(c.x + dx, c.y + dy) in TileDefs.BLIGHTED:
				return true
	return false


## Nella colonna x la superficie è avvizzita? (per la scritta, il cielo e le creature)
static func surface_blighted(w: World, x: int) -> bool:
	var xx := clampi(x, 0, w.w - 1)
	for y in range(maxi(w.surface[xx] - 2, 0), mini(w.surface[xx] + 3, w.h)):
		if w.tile(xx, y) == TileDefs.AVV_MUSCHIO:
			return true
	return false


## Uscendo (menu, portale, chiusura) si aspetta il thread che cerca le tessere malate: scrive in questo nodo, e se
## il nodo sparisse prima il gioco si chiuderebbe con un errore di memoria (successo nella prova del viaggio).
func _exit_tree() -> void:
	if _task >= 0:
		WorkerThreadPool.wait_for_task_completion(_task)
		_task = -1
