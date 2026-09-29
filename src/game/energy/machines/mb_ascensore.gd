class_name MbAscensore
extends MachineBehavior
## L'Ascensore a bolla: quando ha i suoi pulsi, sopra di lui sale una colonna di bolle (larga quanto lui) fino al primo
## soffitto, al più `MAX_H` tessere. Dentro la colonna la gravità (`Gravity.columns`) solleva chi tiene premuto Salto,
## come una corrente ascensionale; tenendo giù si scende piano (`DOWN` px/s). Le bolle si vedono.

const MAX_H := 60
const DOWN := 110.0


func _column(mc: Machine, e: Energy) -> Rect2i:
	var w: World = e.m.world
	var top := mc.o.y - 1
	var n := 0
	while n < MAX_H and top - 1 >= 0:
		var free := true
		for dx in mc.size().x:
			if w.solid(mc.o.x + dx, top - 1):
				free = false
		if not free:
			break
		top -= 1
		n += 1
	return Rect2i(mc.o.x, top, mc.size().x, mc.o.y - top + 1)


func frame(mc: Machine, e: Energy, dt: float) -> void:
	var g: Gravity = e.m.gravity
	var on := mc.on() and mc.power >= 0.99
	if not on:
		if g.columns.has(mc.key):
			g.columns.erase(mc.key)
			_fx(mc, e, false)
		return
	var t := float(mc.get_meta("col_t", 0.0)) - dt
	if t <= 0.0 or not g.columns.has(mc.key):
		t = 1.0                              # la colonna si rimisura ogni secondo (si può costruire sopra)
		var col := _column(mc, e)
		if g.columns.get(mc.key) != col:
			g.columns[mc.key] = col
			_fx(mc, e, true)
	mc.set_meta("col_t", t)
	var p: Player = e.m.player
	if (g.columns[mc.key] as Rect2i).has_point(e.m.player_cell()) and Keys.held("giu") and p.vel.y > DOWN:
		p.vel.y = DOWN
		p.reset_fall()


func _fx(mc: Machine, e: Energy, on: bool) -> void:
	if mc.has_meta("fx"):
		var old: Variant = mc.get_meta("fx")
		if is_instance_valid(old):
			(old as Node).queue_free()
		mc.remove_meta("fx")
	if not on:
		return
	var r: Rect2i = e.m.gravity.columns[mc.key]
	var p := CPUParticles2D.new()
	p.amount = maxi(r.size.y, 8)
	p.lifetime = r.size.y * 16.0 / 90.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(r.size.x * 8.0, 2.0)
	p.direction = Vector2(0, -1)
	p.spread = 4.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 80.0
	p.initial_velocity_max = 100.0
	p.scale_amount_min = 1.5
	p.scale_amount_max = 3.0
	p.color = Color(0.7, 1.6, 1.6, 0.7)
	p.position = Vector2(r.position.x * 16.0 + r.size.x * 8.0, (mc.o.y) * 16.0)
	p.z_index = 3
	e.m.fx.add_child(p)
	mc.set_meta("fx", p)


func removed(mc: Machine, e: Energy) -> void:
	e.m.gravity.columns.erase(mc.key)
	_fx(mc, e, false)


func state_text(mc: Machine, e: Energy) -> String:
	if e.m.gravity.columns.has(mc.key):
		var r: Rect2i = e.m.gravity.columns[mc.key]
		return "la colonna sale per %d tessere (tieni il salto)" % (r.size.y - 1)
	return super.state_text(mc, e)
