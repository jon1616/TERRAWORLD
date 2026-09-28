class_name BuilderTools
extends Node2D
## Gli strumenti del costruttore (voce 140, dati in `BuilderData`):
## - con un blocco in mano, **trascinare** posa in linea (orizzontale o verticale, secondo il verso del gesto); tenendo
##   il tasto «area» posa un rettangolo pieno. Ogni cella passa da `PlayerActions.place_block` (portata, appoggio,
##   Bisaccia): le regole sono le stesse del clic.
## - il **Martello**, clic destro su un costrutto, lo scolpisce nella forma dopo (stesso materiale, niente costo).
## - le **tinture**: clic su un costrutto lo colora, clic destro colora la parete costruita dietro (`World.tint`).
## - la **Tavola del progetto**: vuota, trascinare copia l'area; piena, un clic la rifà (`PLAN_REACH`), clic destro la
##   svuota.

const S := 16

var m: Node2D
var _from := Vector2i(-1, -1)            # dove è cominciato il trascinamento
var _kind := ""                          # "blocco" o "progetto"
var _down := false
var placed := 0                          # conteggi (prove)
var sculpted := 0
var dyed := 0
var plans := 0
var blueprints := 0                      # voce 145: i progetti dei Seminatori costruiti


func setup(main: Node2D) -> void:
	m = main
	z_index = 22


func _held() -> Dictionary:
	return m.hud.current()


func _kind_of(item: Dictionary) -> String:
	return String(ItemsData.get_item(String(item.get("id", ""))).get("kind", ""))


func _process(_dt: float) -> void:
	if m == null or not m.built:
		return
	var active: bool = m.actions.enabled and not m.hud.is_open()
	var down := active and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var k := _kind_of(_held())
	if down and not _down and (k == "blocco" or (k == "progetto" and _plan().is_empty())):
		_from = m.actions.mouse_cell()
		_kind = k
	elif not down and _down and _from.x >= 0:
		var to: Vector2i = m.actions.mouse_cell()
		if to != _from and _kind == k:
			if k == "blocco":
				fill(_cells(_from, to, Keys.held("area")), String(_held()["id"]))
			else:
				copy(Rect2i(_from, Vector2i.ZERO).expand(to).grow_individual(0, 0, 1, 1))
		_from = Vector2i(-1, -1)
	_down = down
	queue_redraw()


func _unhandled_input(e: InputEvent) -> void:
	if m == null or not m.built or not m.actions.enabled or m.hud.is_open():
		return
	if not (e is InputEventMouseButton) or not e.pressed:
		return
	var item := _held()
	var k := _kind_of(item)
	var c: Vector2i = m.actions.mouse_cell()
	if e.button_index == MOUSE_BUTTON_RIGHT:
		if k == "martello" and m.world.build_at(c.x, c.y) > 0:
			if sculpt(c):
				get_viewport().set_input_as_handled()
		elif k == "tintura":
			if dye(c, String(item["id"]), true):
				get_viewport().set_input_as_handled()
		elif k == "progetto" and not _plan().is_empty():
			m.character.bisaccia.data_at(m.hud.sel).clear()
			m.hud.toast("Tavola del progetto svuotata")
			get_viewport().set_input_as_handled()
	elif e.button_index == MOUSE_BUTTON_LEFT:
		if k == "tintura":
			dye(c, String(item["id"]), false)
			get_viewport().set_input_as_handled()
		elif k == "progetto" and not _plan().is_empty():
			build_plan(c)
			get_viewport().set_input_as_handled()
		elif k == "progetto_sem":
			build_blueprint(String(ItemsData.get_item(String(item["id"]))["project"]), c)   # voce 145
			get_viewport().set_input_as_handled()


## Le celle di una linea (secondo il verso più lungo) o di un rettangolo, dalle più vicine al punto di partenza.
func _cells(a: Vector2i, b: Vector2i, area: bool) -> Array:
	var out := []
	if area:
		var r := Rect2i(a, Vector2i.ZERO).expand(b).grow_individual(0, 0, 1, 1)
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				out.append(Vector2i(x, y))
		out.sort_custom(func(p: Vector2i, q: Vector2i) -> bool: return Vector2(p - a).length() < Vector2(q - a).length())
		return out.slice(0, BuilderData.AREA_MAX)
	var d := b - a
	var step := Vector2i(signi(d.x), 0) if absi(d.x) >= absi(d.y) else Vector2i(0, signi(d.y))
	var n := maxi(absi(d.x), absi(d.y))
	for i in mini(n, BuilderData.LINE_MAX) + 1:
		out.append(a + step * i)
	return out


## Posa un blocco in ogni cella (le regole del clic); restituisce quanti.
func fill(cells: Array, id: String) -> int:
	var n := 0
	for c in cells:
		if m.character.bisaccia.id_at(m.hud.sel) != id:
			break                                   # finiti
		if m.actions.place_block(c, id):
			n += 1
	placed += n
	return n


## Il Martello scolpisce: la forma dopo, stesso materiale.
func sculpt(c: Vector2i) -> bool:
	var k: int = m.world.build_at(c.x, c.y)
	if k <= 0 or not m.actions.in_reach(c):
		return false
	var nf := BuildData.FORMS.size()
	var mi: int = (k - 1) / nf
	var fi: int = ((k - 1) % nf + 1) % nf
	m.world.set_build(c.x, c.y, mi * nf + fi + 1)
	m.view.refresh_around(c)
	m.light.dirty = true
	m.sfx.play("posa", Vector2(c) * S)
	sculpted += 1
	return true


## Colora (o sbiadisce) un costrutto, o con `wall` la parete costruita della cella. Una goccia per cella.
func dye(c: Vector2i, id: String, wall: bool) -> bool:
	var w: World = m.world
	if not m.actions.in_reach(c) or not w.inside(c.x, c.y):
		return false
	var t := BuilderData.dye_index(id)          # 0 = sbiadente
	if wall:
		if w.wall(c.x, c.y) < BuildData.WALL_BASE or w.wall_tint(c.x, c.y) == t:
			return false
		w.set_tint(c.x, c.y, w.block_tint(c.x, c.y), t)
	else:
		if w.build_at(c.x, c.y) <= 0 or w.block_tint(c.x, c.y) == t:
			return false
		w.set_tint(c.x, c.y, t, w.wall_tint(c.x, c.y))
	m.character.bisaccia.take_one(m.hud.sel)
	m.view.refresh_around(c)
	Fx.puff(m.fx, Vector2(c) * S + Vector2(8, 8), BuilderData.color(t) if t > 0 else Color(1.2, 1.2, 1.2))
	dyed += 1
	return true


func _plan() -> Dictionary:
	var b: Bisaccia = m.character.bisaccia
	if _kind_of(_held()) != "progetto":
		return {}
	return b.data_at(m.hud.sel).get("progetto", {})


## Copia un'area costruita nella Tavola del progetto in mano: costrutti, pareti costruite, colori.
func copy(r: Rect2i) -> int:
	r.size = Vector2i(mini(r.size.x, BuilderData.PLAN_W), mini(r.size.y, BuilderData.PLAN_H))
	var w: World = m.world
	var cells := []
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			var k := w.build_at(x, y)
			var wl := w.wall(x, y)
			if k > 0 or wl >= BuildData.WALL_BASE:
				cells.append([x - r.position.x, y - r.position.y, k, wl if wl >= BuildData.WALL_BASE else 0, w.tint_at(x, y)])
	if cells.is_empty():
		m.hud.toast("Qui non c'è niente di costruito da copiare")
		return 0
	var b: Bisaccia = m.character.bisaccia
	if not b.slots[m.hud.sel].has("dati"):
		b.slots[m.hud.sel]["dati"] = {}
	b.slots[m.hud.sel]["dati"]["progetto"] = {"w": r.size.x, "h": r.size.y, "cells": cells}
	b.changed.emit()
	m.hud.toast("Progetto copiato: %d celle (%d × %d)" % [cells.size(), r.size.x, r.size.y])
	return cells.size()


## Che cosa serve per rifare un progetto: oggetto -> quanti.
static func needs(plan: Dictionary) -> Dictionary:
	var out := {}
	for e in plan.get("cells", []):
		if int(e[2]) > 0:
			var id := BuildData.item_of(int(e[2]))
			out[id] = int(out.get(id, 0)) + 1
		if int(e[3]) > 0:
			var wid := "parete_%s" % BuildData.MATERIALS[int(e[3]) - BuildData.WALL_BASE]["id"]
			out[wid] = int(out.get(wid, 0)) + 1
	return out


## Rifà il progetto con l'angolo in alto a sinistra in c: servono tutti i materiali nella Bisaccia; le celle occupate
## si saltano (e il loro materiale resta).
func build_plan(c: Vector2i) -> bool:
	var plan := _plan()
	var w: World = m.world
	var b: Bisaccia = m.character.bisaccia
	if Vector2(c - m.player_cell()).length() > BuilderData.PLAN_REACH:
		m.hud.toast("Troppo lontano per costruire il progetto")
		return false
	var need := needs(plan)
	var miss := []
	for id in need:
		if b.count(id) < int(need[id]):
			miss.append("%s (%d/%d)" % [String(ItemsData.get_item(id).get("name", id)), b.count(id), int(need[id])])
	if not miss.is_empty():
		m.hud.toast("Per il progetto mancano: " + ", ".join(miss.slice(0, 3)))
		return false
	var n := 0
	for e in plan["cells"]:
		var q := c + Vector2i(int(e[0]), int(e[1]))
		if not w.inside(q.x, q.y) or q.y >= w.h - 1:
			continue
		if int(e[3]) > 0 and w.wall(q.x, q.y) == 0:
			w.walls[q.y * w.w + q.x] = int(e[3])
			b.remove("parete_%s" % BuildData.MATERIALS[int(e[3]) - BuildData.WALL_BASE]["id"], 1)
			n += 1
		if int(e[2]) > 0 and not w.solid(q.x, q.y) and w.station_at(q).is_empty() and not w.torches.has(q):
			w.set_build(q.x, q.y, int(e[2]))
			b.remove(BuildData.item_of(int(e[2])), 1)
			n += 1
		w.set_tint(q.x, q.y, int(e[4]) & 15, int(e[4]) >> 4)
	var r := Rect2i(c, Vector2i(int(plan["w"]), int(plan["h"])))
	for y in range(r.position.y - 1, r.end.y + 1):
		for x in range(r.position.x - 1, r.end.x + 1):
			m.view.refresh_around(Vector2i(x, y))
	m.light.dirty = true
	m.sfx.play("posa", Vector2(c) * S)
	plans += 1
	m.hud.toast("Progetto costruito: %d pezzi" % n)
	return true


## Voce 145: un progetto dei Seminatori, con l'angolo in alto a sinistra in c. Servono tutti i materiali; le celle
## occupate si saltano (e il loro materiale resta nella Bisaccia).
func build_blueprint(id: String, c: Vector2i) -> bool:
	var w: World = m.world
	var b: Bisaccia = m.character.bisaccia
	if Vector2(c - m.player_cell()).length() > BuilderData.PLAN_REACH + 6.0:
		m.hud.toast("Troppo lontano per costruire il progetto")
		return false
	var need := ProjectsData.needs(id)
	var miss := []
	for it in need:
		if b.count(it) < int(need[it]):
			miss.append("%s (%d/%d)" % [String(ItemsData.get_item(it).get("name", it)), b.count(it), int(need[it])])
	if not miss.is_empty():
		m.hud.toast("Per il progetto mancano: " + ", ".join(miss.slice(0, 3)))
		return false
	var grid: Array = ProjectsData.PROJECTS[id]["grid"]
	var wall := ProjectsData.wall_id()
	var n := 0
	for pass_n in 2:                              # prima i blocchi e le pareti, poi le stazioni (vogliono il pavimento)
		n += _blueprint_pass(grid, c, wall, pass_n == 1)
	var sz := ProjectsData.size_of(id)
	for y in range(c.y - 1, c.y + sz.y + 1):
		for x in range(c.x - 1, c.x + sz.x + 1):
			m.view.refresh_around(Vector2i(x, y))
	m.light.dirty = true
	m.sfx.play("posa", Vector2(c) * S)
	blueprints += 1
	m.objectives.bump("progetti")
	m.hud.toast("%s: costruito (%d pezzi)" % [ProjectsData.PROJECTS[id]["name"], n])
	return true


func _blueprint_pass(grid: Array, c: Vector2i, wall: int, stations: bool) -> int:
	var w: World = m.world
	var b: Bisaccia = m.character.bisaccia
	var n := 0
	for y in grid.size():
		var row := String(grid[y])
		for x in row.length():
			var ch := row[x]
			var q := c + Vector2i(x, y)
			if ch == " " or not w.inside(q.x, q.y) or q.y >= w.h - 1:
				continue
			if ProjectsData.STATION.has(ch) != stations:
				continue
			var free := not w.solid(q.x, q.y) and w.station_at(q).is_empty() and not w.torches.has(q)
			if ProjectsData.BLOCK.has(ch):
				if free:
					var kk := ProjectsData.kind_of(ch)
					w.set_build(q.x, q.y, kk)
					b.remove(BuildData.item_of(kk), 1)
					n += 1
			elif ch == ".":
				if w.wall(q.x, q.y) == 0:
					w.walls[q.y * w.w + q.x] = wall
					b.remove("parete_" + ProjectsData.WALL_MAT, 1)
					n += 1
			elif ch == "_":
				if free and not w.plat(q.x, q.y):
					w.set_plat(q.x, q.y, true)
					b.remove("passerella", 1)
					n += 1
			elif ch == "*":
				if free:
					w.add_torch(q)
					m.view.add_torch(q)
					b.remove("torcia", 1)
					n += 1
			elif ProjectsData.STATION.has(ch):
				var sid := String(ProjectsData.STATION[ch])
				if w.station_fits(sid, q):
					w.stations[q] = sid
					m.view.add_station(q)
					b.remove(String(StationsData.STATIONS[sid]["item"]), 1)
					n += 1
				if w.wall(q.x, q.y) == 0:
					w.walls[q.y * w.w + q.x] = wall
	return n


func _draw() -> void:
	if m == null or not m.built:
		return
	var k := _kind_of(_held())
	if k == "progetto_sem":
		var pid := String(ItemsData.get_item(String(_held()["id"])).get("project", ""))
		if pid != "":
			var o: Vector2i = m.actions.mouse_cell()
			var sz := ProjectsData.size_of(pid)
			draw_rect(Rect2(Vector2(o) * S, Vector2(sz) * S), Color(0.6, 1.0, 0.85, 0.7), false, 1.0)
			var grid: Array = ProjectsData.PROJECTS[pid]["grid"]
			for y in grid.size():
				var row := String(grid[y])
				for x in row.length():
					if ProjectsData.BLOCK.has(row[x]):
						draw_rect(Rect2(Vector2(o + Vector2i(x, y)) * S + Vector2(3, 3), Vector2(10, 10)), Color(0.6, 1.0, 0.85, 0.3))
		return
	var col := Color(0.5, 1.0, 0.9, 0.5)
	if _down and _from.x >= 0 and (k == "blocco" or k == "progetto"):
		var to: Vector2i = m.actions.mouse_cell()
		if k == "progetto":
			var r := Rect2i(_from, Vector2i.ZERO).expand(to).grow_individual(0, 0, 1, 1)
			r.size = Vector2i(mini(r.size.x, BuilderData.PLAN_W), mini(r.size.y, BuilderData.PLAN_H))
			draw_rect(Rect2(Vector2(r.position) * S, Vector2(r.size) * S), Color(1.0, 0.85, 0.4, 0.8), false, 1.0)
		else:
			for c in _cells(_from, to, Keys.held("area")):
				draw_rect(Rect2(Vector2(c) * S, Vector2(S, S)), col, false, 1.0)
	elif k == "progetto" and not _plan().is_empty():
		var plan := _plan()
		var o: Vector2i = m.actions.mouse_cell()
		draw_rect(Rect2(Vector2(o) * S, Vector2(int(plan["w"]), int(plan["h"])) * S), Color(1.0, 0.85, 0.4, 0.6), false, 1.0)
		for e in plan["cells"]:
			if int(e[2]) > 0:
				draw_rect(Rect2(Vector2(o + Vector2i(int(e[0]), int(e[1]))) * S + Vector2(3, 3), Vector2(10, 10)), Color(1.0, 0.85, 0.4, 0.35))
