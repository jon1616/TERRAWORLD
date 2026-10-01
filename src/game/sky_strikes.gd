class_name SkyStrikes
extends Node2D
## I fulmini annunciati del cielo (Roadmap 16): li chiamano le creature della tempesta (comportamento «folgore», con la
## richiesta «folgore» in `Creature.acts`), l'Occhio della Tempesta (voce 162) e i Nidi di tempesta da soli (voce 164).
## Prima la colonna si accende (una riga di luce che si fa più viva), poi il fulmine cade: ferisce chi è a meno di una
## tessera e mezza dalla colonna, sotto un tetto no. Si disegna qui (z sopra il mondo).

const S := 16
const HIT_R := 22.0                    # px dalla colonna: chi è più vicino è colpito
const FLASH := 0.25                    # secondi del lampo dopo la caduta

var m: Node2D
var pending: Array = []                # [{x, t, t0, damage, y0, y1}]
var flashes: Array = []                # [{x, t, y0, y1}]
var fallen := 0                        # conteggio (prove)
var hits := 0


func setup(main: Node2D) -> void:
	m = main
	z_index = 24


## Un fulmine sulla colonna x (px) tra `delay` secondi.
## `ally`: l'uid della scheda del compagno che lo chiama (Roadmap 32): ferisce le creature sotto, non il Germogliato.
func bolt(x: float, delay: float, damage: int, ally := -1) -> void:
	var cam_y: float = m.cam.get_screen_center_position().y
	pending.append({"x": x, "t": delay, "t0": delay, "damage": damage, "y0": cam_y - 400.0, "ally": ally})
	queue_redraw()


func _process(dt: float) -> void:
	if m == null or not m.built or (pending.is_empty() and flashes.is_empty()):
		return
	for b in pending.duplicate():
		b["t"] = float(b["t"]) - dt
		if float(b["t"]) <= 0.0:
			pending.erase(b)
			_fall(b)
	for f in flashes.duplicate():
		f["t"] = float(f["t"]) - dt
		if float(f["t"]) <= 0.0:
			flashes.erase(f)
	queue_redraw()


func _fall(b: Dictionary) -> void:
	var w: World = m.world
	var x := floori(float(b["x"]) / S)
	# il fulmine scende dall'alto della visuale fino al primo blocco sotto il Germogliato (o sotto di sé)
	var y := maxi(floori(float(b["y0"]) / S), 1)
	var bottom := mini(floori((m.player.position.y + 300.0) / S), w.h - 2)
	while y < bottom and not w.solid(x, y + 1):
		y += 1
	var at := Vector2(float(b["x"]), (y + 1) * S)
	fallen += 1
	flashes.append({"x": float(b["x"]), "t": FLASH, "y0": float(b["y0"]), "y1": at.y})
	m.sfx.play("scoppio", at)
	Fx.puff(m.fx, at, Color(1.6, 1.7, 2.2))
	if int(b.get("ally", -1)) >= 0:
		var uid := int(b["ally"])
		for o in m.fauna.list.duplicate():
			if absf(o.position.x - float(b["x"])) <= HIT_R and o.position.y <= at.y + 8.0:
				m.herd.fight.strike(m.herd.beasts.get(uid), m.herd.rec_of(uid), o, int(b["damage"]), float(b["x"]), "")
		return
	var p: Player = m.player
	var roofed: bool = m.weather != null and m.weather.roofed
	if absf(p.position.x - float(b["x"])) <= HIT_R and p.position.y <= at.y + 8.0 and not roofed:
		hits += 1
		m.combat._self_hurt(int(b["damage"]))
		m.life.flash(Color(1, 1, 1, 0.3), 0.2)


func _draw() -> void:
	for b in pending:
		var k := 1.0 - float(b["t"]) / maxf(float(b["t0"]), 0.01)     # da 0 (appena chiamato) a 1 (sta per cadere)
		var x := float(b["x"])
		var y1: float = m.player.position.y + 200.0
		draw_line(Vector2(x, float(b["y0"])), Vector2(x, y1), Color(0.75, 0.85, 1.0, 0.15 + 0.45 * k), 1.0 + 2.0 * k)
	for f in flashes:
		var a := float(f["t"]) / FLASH
		var x := float(f["x"])
		var pts := PackedVector2Array()
		var y := float(f["y0"])
		var y1 := float(f["y1"])
		var off := 0.0
		while y < y1:
			pts.append(Vector2(x + off, y))
			y += 24.0
			off = randf_range(-7.0, 7.0)
		pts.append(Vector2(x, y1))
		draw_polyline(pts, Color(0.9, 0.95, 1.0, a), 3.0)
		draw_polyline(pts, Color(1.4, 1.5, 2.0, a * 0.7), 1.0)
