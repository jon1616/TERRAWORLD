class_name Dwellers
extends Node
## Chi abita le costruzioni (voce 146, Roadmap 15). Scelta dell'utente: fuori dagli assedi **nessuno distrugge nulla**;
## le costruzioni vivono lo stesso:
## - le **stanze lasciate al buio** e sole per un po' (`DARK_AFTER`) si riempiono di ragnatele negli angoli (rallentano,
##   si bruciano con una torcia in mano, e una luce nella stanza le tiene lontane);
## - sui **tetti** delle case in superficie a volte un uccello fa il nido («nido_tetto»): toccato, lascia piume e uova
##   (una volta al giorno).
## Si spegne dalle Opzioni («ospiti»). Le visite alle stanze in `world_meta["stanze_visite"]` (secondi di gioco).

const EVERY := 20.0
const DARK_AFTER := 480.0                # secondi senza visite (e senza luci) prima delle ragnatele
const WEB_LIFE := 1200.0                 # quanto durano quelle ragnatele (si bruciano prima con una torcia)
const NEST_CHANCE := 0.15                # a ogni controllo, per ogni casa di superficie senza nido
const NEST_EVERY := 600.0                # secondi tra un dono del nido e il seguente

var m: Node2D
var _t := 5.0
var webs_made := 0                       # (prove)
var nests_made := 0
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	var visits: Dictionary = m.world_meta.get("stanze_visite", {})
	var now: float = m.world_meta.get("tempo_gioco", 0.0)
	now += dt
	m.world_meta["tempo_gioco"] = now
	if not m.rooms.current.is_empty():
		visits[String(m.rooms.current["key"])] = now
	m.world_meta["stanze_visite"] = visits
	_t -= dt
	if _t > 0.0:
		return
	_t = EVERY
	if not bool(Settings.v("ospiti")):
		return
	check(now)


## Le ragnatele nelle stanze buie lasciate sole, i nidi sui tetti.
func check(now: float) -> void:
	var visits: Dictionary = m.world_meta.get("stanze_visite", {})
	for e in m.rooms.list():
		var key := String(e["key"])
		if not visits.has(key):
			visits[key] = now
		if String(m.rooms.current.get("key", "")) == key:
			continue
		if int(e.get("lights", 0)) == 0 and now - float(visits[key]) > DARK_AFTER and not e.get("ragni", false):
			_webs(e)
		if String(e["type"]) == "casa" and not e.get("nido", false) and _rng.randf() < NEST_CHANCE:
			_nest(e)


## Ragnatele negli angoli alti della stanza (celle libere).
func _webs(e: Dictionary) -> void:
	var w: World = m.world
	var x0 := int(e["x"])
	var y0 := int(e["y"])
	var x1 := x0 + int(e["w"]) - 1
	var n := 0
	for q in [Vector2i(x0, y0), Vector2i(x0 + 1, y0), Vector2i(x1, y0), Vector2i(x1 - 1, y0), Vector2i(x0, y0 + 1), Vector2i(x1, y0 + 1)]:
		if w.inside(q.x, q.y) and not w.solid(q.x, q.y) and w.station_at(q).is_empty():
			m.wiles.webs[q] = WEB_LIFE
			n += 1
	if n > 0:
		e["ragni"] = true
		webs_made += 1
		m.wiles.queue_redraw()


## Un nido sul tetto: la prima cella libera sopra il contorno alto, con il tetto sotto e il cielo sopra.
func _nest(e: Dictionary) -> void:
	var w: World = m.world
	var y := int(e["y"]) - 2                      # sopra il tetto (la riga del contorno è y - 1)
	if y < 2 or StrataData.at(w, int(e["x"]), y) > 0:
		return
	for x in range(int(e["x"]), int(e["x"]) + int(e["w"]) - 1):
		var o := Vector2i(x, y)
		if w.station_fits("nido_tetto", o) and w.surface[x] >= y:
			w.stations[o] = "nido_tetto"
			m.view.add_station(o)
			e["nido"] = true
			nests_made += 1
			return


## Clic destro sul nido del tetto: piume e uova, una volta ogni tanto.
func touch_nest(o: Vector2i) -> bool:
	var got: Dictionary = m.world_meta.get("nidi_tetto", {})
	var k := "%d,%d" % [o.x, o.y]
	var now: float = m.world_meta.get("tempo_gioco", 0.0)
	if got.has(k) and now - float(got[k]) < NEST_EVERY:
		m.hud.toast("Il nido è vuoto: torna più tardi")
		return true
	got[k] = now
	m.world_meta["nidi_tetto"] = got
	var at := (Vector2(o) + Vector2(1.0, 0.5)) * 16.0
	m.drops.spawn("piuma_pavoncella", _rng.randi_range(1, 3), at)
	var egg := _rng.randf() < 0.5 and ItemsData.has("uovo")
	if egg:
		m.drops.spawn("uovo", 1, at)
	m.hud.toast("Nel nido sul tetto: piume" + (" e un uovo" if egg else ""))
	return true


## Voce 148: l'alveare costruito si riempie di miele (uno ogni `HIVE_EVERY` secondi di gioco, al più `HIVE_MAX`).
const HIVE_EVERY := 120.0
const HIVE_MAX := 6


func hive_honey(o: Vector2i) -> int:
	var t: Dictionary = m.world_meta.get("alveari", {})
	var k := "%d,%d" % [o.x, o.y]
	var now: float = m.world_meta.get("tempo_gioco", 0.0)
	if not t.has(k):
		t[k] = now
		m.world_meta["alveari"] = t
	return mini(int((now - float(t[k])) / HIVE_EVERY), HIVE_MAX)


func touch_hive(o: Vector2i) -> bool:
	var n := hive_honey(o)
	if n <= 0:
		m.hud.toast("L'alveare è ancora vuoto: torna più tardi")
		return true
	var t: Dictionary = m.world_meta["alveari"]
	t["%d,%d" % [o.x, o.y]] = float(m.world_meta.get("tempo_gioco", 0.0))
	m.drops.spawn("miele_lume", n, (Vector2(o) + Vector2(0.5, 0.5)) * 16.0)
	m.hud.toast("Dall'alveare: %d miele di lume" % n)
	return true

