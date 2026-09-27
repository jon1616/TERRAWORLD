class_name Liquids
extends Node
## I liquidi che scorrono (voce 73, tipi in `LiquidsData`): un automa a celle sulle celle **attive** (quelle che possono
## ancora muoversi), solo vicino al Germogliato, a passi di `STEP` secondi e al più `MAX_UPDATES` celle per passo. Un
## liquido cade se sotto c'è posto, altrimenti si allarga a destra e a sinistra verso le celle più basse; fermo, esce
## dalle attive. Scavare accanto a un liquido lo risveglia (`World.on_change`). I mondi nascono con i liquidi già fermi.
## Chi sta dentro: il Germogliato nuota (`Player`), trattiene il respiro, la Linfa cura, la brace brucia (voce 74).

var m: Node2D
var view: LiquidView
var active := {}                        # indice della cella -> true
var breath := LiquidsData.BREATH
var breath_mult := 1.0                  # accessori (Branchie di muschio)
var _t := 0.0
var _flip := false
var _step_n := 0
var _hurt := 0.0
const RUN_MAX := 48                     # celle al più di un tratto che si livella
var bar: Label


func setup(main: Node2D) -> void:
	m = main
	m.world.on_change = _changed
	view = LiquidView.new()
	view.world = m.world
	m.view.add_child(view)
	bar = Label.new()
	bar.position = Vector2(1600 - 660, 124)      # sotto gli effetti delle pozioni, a sinistra della minimappa
	bar.size = Vector2(400, 20)
	bar.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	bar.add_theme_font_size_override("font_size", 14)
	bar.add_theme_color_override("font_color", Color("#8ec8ff"))
	bar.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	bar.add_theme_constant_override("outline_size", 5)
	bar.visible = false
	m.hud.add_child(bar)


func _exit_tree() -> void:
	if m != null and m.world != null:
		m.world.on_change = Callable()


## Una tessera cambiata: se è diventata piena il liquido lì sparisce; le celle attorno tornano attive.
func _changed(x: int, y: int) -> void:
	var w: World = m.world
	if w.solid(x, y) and w.liq(x, y) > 0:
		w.set_liq(x, y, 0, 0)
		view.touch(Vector2i(x, y))
	for d in [Vector2i(0, 0), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1)]:
		wake(x + d.x, y + d.y)


func wake(x: int, y: int) -> void:
	var w: World = m.world
	if x >= 0 and y >= 0 and x < w.w and y < w.h and (w.liquid[y * w.w + x] & 15) > 0:
		active[y * w.w + x] = true


## Versa del liquido (secchio, prove): livello 1-8.
func pour(c: Vector2i, level: int, type: int) -> void:
	var w: World = m.world
	if w.solid(c.x, c.y):
		return
	w.set_liq(c.x, c.y, mini(w.liq(c.x, c.y) + level, 8), type)
	wake(c.x, c.y)
	view.touch(c)


## Il secchio vuoto su un liquido: raccoglie una cella piena (dalla cella e dalle vicine dello stesso liquido).
func scoop(c: Vector2i) -> bool:
	var w: World = m.world
	if not m.actions.in_reach(c) or w.liq(c.x, c.y) == 0:
		return false
	var type := w.liq_type(c.x, c.y)
	var cells := [c, c + Vector2i(1, 0), c + Vector2i(-1, 0), c + Vector2i(0, 1), c + Vector2i(0, -1)]
	var have := 0
	for q in cells:
		if w.liq_type(q.x, q.y) == type:
			have += w.liq(q.x, q.y)
	if have < 4:
		m.hud.toast("Troppo poco liquido per riempire il secchio")
		return false
	var need := 8
	for q in cells:
		if need <= 0:
			break
		if w.liq_type(q.x, q.y) != type or w.liq(q.x, q.y) == 0:
			continue
		var n := mini(w.liq(q.x, q.y), need)
		need -= n
		w.set_liq(q.x, q.y, w.liq(q.x, q.y) - n, type)
		_changed(q.x, q.y)
		view.touch(q)
	var b: Bisaccia = m.character.bisaccia
	if not b.remove("secchio", 1):
		return false
	var full := "secchio_" + String(LiquidsData.TYPES[type]["id"])
	if b.add(full, 1) > 0:
		m.drops.spawn(full, 1, m.player.position)
	m.sfx.play("dono", Vector2(c) * 16.0)
	return true


## Il secchio pieno: versa il suo liquido nella cella (e il secchio torna vuoto).
func empty_bucket(c: Vector2i, id: String) -> bool:
	var w: World = m.world
	if not m.actions.in_reach(c) or w.solid(c.x, c.y):
		return false
	var type := int(ItemsData.get_item(id).get("liquid", 0))
	if w.liq(c.x, c.y) > 0 and w.liq_type(c.x, c.y) != type:
		return false
	var b: Bisaccia = m.character.bisaccia
	if not b.remove(id, 1):
		return false
	pour(c, 8, type)
	if b.add("secchio", 1) > 0:
		m.drops.spawn("secchio", 1, m.player.position)
	return true


func _process(dt: float) -> void:
	if not m.built:
		return
	_t += dt
	if _t >= LiquidsData.STEP:
		_t = 0.0
		step()
	_body(dt)


## Un passo della simulazione. Restituisce quante celle si sono mosse.
func step() -> int:
	_step_n += 1
	_flip = not _flip
	var w: World = m.world
	var W := w.w
	var liq := w.liquid
	var tiles := w.tiles
	var pc: Vector2i = m.player_cell()
	var win := Rect2i(pc - LiquidsData.WINDOW, LiquidsData.WINDOW * 2)
	var keys := active.keys()
	var done := 0
	var moved := 0
	var wake_list: Array[int] = []
	var leveled := {}
	for key in keys:
		if done >= LiquidsData.MAX_UPDATES:
			break
		var i: int = key
		var x := i % W
		var y := i / W
		if not win.has_point(Vector2i(x, y)):
			continue
		done += 1
		var v := liq[i]
		var lv := v & 15
		if lv == 0:
			active.erase(i)
			continue
		var ty := v >> 4
		if _step_n % int(LiquidsData.TYPES[ty]["flow"]) != 0:
			continue                              # i liquidi densi scorrono più piano
		var moved_here := false
		# giù
		if y + 1 < w.h:
			var b := i + W
			if not _solid(tiles[b]):
				var bv := liq[b]
				var bl := bv & 15
				var bt := bv >> 4
				if bl == 0 or (bt == ty and bl < 8):
					var n := mini(lv, 8 - bl)
					bl += n
					lv -= n
					liq[b] = bl | (ty << 4)
					wake_list.append(b)
					moved_here = true
				elif bt != ty and bl > 0:
					_react(w, x, y + 1, ty, bt)
		# ai lati: il tratto di liquido appoggiato su questa riga si livella tutto insieme (voce 73)
		if lv > 0 and not leveled.has(i) and _supported(liq, tiles, i, W, w.h, ty):
			liq[i] = lv | (ty << 4)
			var run: Array[int] = [i]
			for s in [-1, 1]:
				var k: int = x + s
				while k >= 0 and k < W and run.size() < RUN_MAX:
					var jj: int = y * W + k
					if _solid(tiles[jj]):
						break
					var jv := liq[jj]
					if (jv & 15) > 0 and (jv >> 4) != ty:
						_react(w, k, y, ty, jv >> 4)
						break
					run.append(jj)
					if (jv & 15) == 0 or not _supported(liq, tiles, jj, W, w.h, ty):
						break                     # una cella vuota (o sull'orlo) in fondo al tratto, poi basta
					k += s
			var total := 0
			for r in run:
				total += liq[r] & 15
			var avg := total / run.size()
			var rem := total % run.size()
			var order := run.duplicate()
			order.sort_custom(func(a: int, b2: int) -> bool: return (liq[a] & 15) > (liq[b2] & 15))
			for q in order.size():
				var r: int = order[q]
				var nl := avg + (1 if q < rem else 0)
				leveled[r] = true
				if nl != (liq[r] & 15):
					liq[r] = 0 if nl <= 0 else (nl | (ty << 4))
					wake_list.append(r)
					moved_here = true
			lv = liq[i] & 15
		liq[i] = 0 if lv <= 0 else (lv | (ty << 4))
		if moved_here:
			moved += 1
			wake_list.append(i)
			if y > 0:
				wake_list.append(i - W)
			view.touch(Vector2i(x, y))
		else:
			active.erase(i)
	for j in wake_list:
		if (liq[j] & 15) > 0:
			active[j] = true
			view.touch(Vector2i(j % W, j / W))
	w.liquid = liq
	return moved


## Una cella di liquido appoggiata: sotto c'è una tessera piena o lo stesso liquido pieno (allora non cade più).
static func _supported(liq: PackedByteArray, tiles: PackedByteArray, i: int, W: int, H: int, ty: int) -> bool:
	var b := i + W
	if b >= W * H:
		return true
	if tiles[b] != TileDefs.AIR:
		return true
	var bv := liq[b]
	return (bv & 15) == 8 and (bv >> 4) == ty


## Pieno per un liquido: ogni tessera che non è aria (le passerelle sono aria: il liquido ci passa).
static func _solid(t: int) -> bool:
	return t != TileDefs.AIR


## Due liquidi diversi si toccano (voce 74, `LiquidsData`): per ora nulla; la voce 74 aggiunge le reazioni.
func _react(_w: World, _x: int, _y: int, _a: int, _b: int) -> void:
	pass


## Il Germogliato nel liquido: respiro, cura della Linfa, brace che brucia.
func _body(dt: float) -> void:
	var p: Player = m.player
	var w: World = m.world
	var head := Vector2i(floori(p.position.x / 16.0), floori((p.position.y - Player.HALF.y + 3.0) / 16.0))
	var mid := Vector2i(floori(p.position.x / 16.0), floori(p.position.y / 16.0))
	var under := w.liq(head.x, head.y) >= 5
	var max_b := LiquidsData.BREATH * breath_mult
	if under and w.liq_type(head.x, head.y) != LiquidsData.BRACE:
		breath = maxf(breath - dt, 0.0)
	else:
		breath = minf(breath + dt * 6.0, max_b)
	bar.visible = breath < max_b - 0.05
	if bar.visible:
		bar.text = "Respiro  " + "●".repeat(ceili(breath / max_b * 8.0)) + "○".repeat(8 - ceili(breath / max_b * 8.0))
	_hurt += dt
	if _hurt < 0.5:
		return
	_hurt = 0.0
	if breath <= 0.0:
		m.vitals.hurt(roundi(LiquidsData.DROWN * 0.5))
	var lv := w.liq(mid.x, mid.y)
	if lv > 0:
		var td: Dictionary = LiquidsData.TYPES[w.liq_type(mid.x, mid.y)]
		if float(td["dps"]) > 0.0:
			m.vitals.hurt(roundi(float(td["dps"]) * 0.5))
		if float(td["heal"]) > 0.0:
			m.vitals.heal(roundi(float(td["heal"]) * 0.5))
