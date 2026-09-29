class_name LiquidTools
extends Node
## Spostare i liquidi (voce 119, Roadmap 14 «Le acque vive»: il giocatore si crea le sue zone di pesca). Due cose:
## - i **contenitori grandi** (Otre di legnoferro, Anfora d'ambra: campo `cap` in celle piene): clic su un liquido lo
##   raccoglie dall'alto dello specchio fino a riempirsi, clic altrove lo versa; ciò che contengono sta nei "dati"
##   della casella ({"liq": tipo, "n": livelli});
## - le **fonti** (stazioni `fonte_*`, campo `fonte` = tipo di liquido): versano piano il loro liquido nella cella
##   accanto alla bocca finché il bacino non sale fino a lei; lavorano solo vicino al Germogliato, come i liquidi.
## Il Secchio di radice (una cella) resta in `Liquids`.

const FOUNT_EVERY := 0.25               # secondi tra due getti di una fonte
const FOUNT_LEVELS := 4                 # livelli (1/8 di cella) a getto

var m: Node2D
var _t := 0.0
var _founts: Array[Vector2i] = []
var _count := -1


func setup(main: Node2D) -> void:
	m = main


# ---------------------------------------------------------------- i contenitori

## Clic con un contenitore in mano: raccoglie se si tocca un liquido (e c'è posto), altrimenti versa.
func use_container(c: Vector2i, id: String) -> bool:
	var w: World = m.world
	if not m.actions.in_reach(c):
		return false
	var b: Bisaccia = m.character.bisaccia
	var i: int = m.hud.sel if b.id_at(m.hud.sel) == id else Portal._slot_of(b, id)
	if i < 0:
		return false
	var d: Dictionary = b.data_at(i).duplicate()
	var cap := int(ItemsData.get_item(id).get("cap", 1)) * 8
	var have := int(d.get("n", 0))
	var type := int(d.get("liq", -1))
	var name := String(ItemsData.get_item(id)["name"])
	if w.liq(c.x, c.y) > 0 and have < cap and (have == 0 or w.liq_type(c.x, c.y) == type):
		type = w.liq_type(c.x, c.y)
		var got := take(c, cap - have)
		if got <= 0:
			return false
		d = {"liq": type, "n": have + got}
		_store(b, i, d)
		m.hud.toast("%s: %s %s/%d" % [name, LiquidsData.TYPES[type]["name"], _cells(have + got), cap / 8])
		m.sfx.play("dono", Vector2(c) * 16.0)
		return true
	if have > 0 and not w.solid(c.x, c.y):
		if w.liq(c.x, c.y) > 0 and w.liq_type(c.x, c.y) != type:
			return false
		var left := put(c, have, type)
		_store(b, i, {} if left <= 0 else {"liq": type, "n": left})
		m.hud.toast("%s: %s" % [name, "vuoto" if left <= 0 else "%s %s/%d" % [LiquidsData.TYPES[type]["name"], _cells(left), cap / 8]])
		return true
	return false


## Toglie fino a `levels` livelli dallo specchio che contiene c, dalle celle più in alto. Restituisce quanti.
func take(c: Vector2i, levels: int) -> int:
	var w: World = m.world
	var body := WaterBody.at(w, c, true)
	if body.is_empty():
		return 0
	var list := Array(body["list"] as PackedInt32Array)
	list.sort_custom(func(a: int, b: int) -> bool: return a / w.w < b / w.w)   # prima le righe in alto
	var got := 0
	var type := int(body["type"])
	for k in list:
		if got >= levels:
			break
		var x: int = k % w.w
		var y: int = k / w.w
		var n := mini(w.liq(x, y), levels - got)
		w.set_liq(x, y, w.liq(x, y) - n, type)
		got += n
		m.liquids.wake(x, y)
		m.liquids.view.touch(Vector2i(x, y))
	return got


## Versa `levels` livelli di un liquido a partire da c, riempiendo le celle d'aria vicine (poi i liquidi scorrono da
## soli). Restituisce quanti livelli non hanno trovato posto.
func put(c: Vector2i, levels: int, type: int) -> int:
	var w: World = m.world
	var todo: Array[Vector2i] = [c]
	var seen := {c: true}
	var left := levels
	while not todo.is_empty() and left > 0 and seen.size() < 400:
		var q: Vector2i = todo.pop_front()
		if w.solid(q.x, q.y) or (w.liq(q.x, q.y) > 0 and w.liq_type(q.x, q.y) != type):
			continue
		var n := mini(8 - w.liq(q.x, q.y), left)
		if n > 0:
			m.liquids.pour(q, n, type)
			left -= n
		for o in [Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1)]:
			var r: Vector2i = q + o
			if w.inside(r.x, r.y) and not seen.has(r):
				seen[r] = true
				todo.append(r)
	return left


func _store(b: Bisaccia, i: int, d: Dictionary) -> void:
	if d.is_empty():
		b.slots[i].erase("dati")
	else:
		b.slots[i]["dati"] = d
	b.changed.emit()


static func _cells(levels: int) -> String:
	return str(snappedf(levels / 8.0, 0.1)).trim_suffix(".0")


## Che cosa contiene un contenitore (per le schede): «Acqua 4,5/6» o «vuoto».
static func content_text(id: String, dati: Dictionary) -> String:
	var cap := int(ItemsData.get_item(id).get("cap", 1))
	if int(dati.get("n", 0)) <= 0:
		return "vuoto (può contenere %d celle)" % cap
	return "%s %s/%d celle" % [LiquidsData.TYPES[int(dati["liq"])]["name"], _cells(int(dati["n"])).replace(".", ","), cap]


# ---------------------------------------------------------------- le fonti

func _process(dt: float) -> void:
	if not m.built:
		return
	_t += dt
	if _t < FOUNT_EVERY:
		return
	_t = 0.0
	tick()


## Un getto di ogni fonte vicina al Germogliato. Restituisce quante hanno versato (per le prove).
func tick() -> int:
	var w: World = m.world
	if w.stations_rev() != _count:
		_count = w.stations_rev()
		_founts.clear()
		for o: Vector2i in w.stations:
			if StationsData.STATIONS.get(String(w.stations[o]), {}).has("fonte"):
				_founts.append(o)
	var pc: Vector2i = m.player_cell()
	var n := 0
	for o in _founts:
		if absi(o.x - pc.x) > LiquidsData.WINDOW.x or absi(o.y - pc.y) > LiquidsData.WINDOW.y:
			continue
		var id := String(w.stations.get(o, ""))
		if id == "":
			continue
		var st: Dictionary = StationsData.STATIONS[id]
		var type := int(st["fonte"])
		var q := mouth(o, id)
		if q.x < 0:
			continue
		var lv := w.liq(q.x, q.y)
		if lv >= 8 or (lv > 0 and w.liq_type(q.x, q.y) != type):
			continue
		m.liquids.pour(q, mini(FOUNT_LEVELS, 8 - lv), type)
		n += 1
	return n


## La cella in cui versa una fonte: accanto alla sua riga più bassa, a destra o (se lì c'è roccia) a sinistra.
func mouth(o: Vector2i, id: String) -> Vector2i:
	var w: World = m.world
	var size: Array = StationsData.STATIONS[id]["size"]
	var y := o.y + int(size[1]) - 1
	for q in [Vector2i(o.x + int(size[0]), y), Vector2i(o.x - 1, y)]:
		if w.inside(q.x, q.y) and not w.solid(q.x, q.y) and w.station_at(q).is_empty():
			return q
	return Vector2i(-1, -1)
