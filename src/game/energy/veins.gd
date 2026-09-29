class_name Veins
extends Node
## Roadmap 19, voce 191: la Pinza delle vene. Con la Pinza in mano: clic sinistro e trascina = una linea di vene (o di
## fili) dal punto del clic a dove si lascia (come la linea del Martello), clic destro = riprende ciò che il modo scelto
## ha in quella cella (la vena, o il filo di quel colore); Maiusc+rotella = che cosa posare (quattro vene, quattro fili).
## Si posa solo ciò che si ha nella Bisaccia (una vena per cella); ripresa, torna nella Bisaccia.
## In mano, la Pinza mostra i fili dell'Impulso (`WorldView.set_show_wires`). Ogni cambio emette `changed(cella)`:
## la rete si rifà lì (`Energy`).

signal changed(c: Vector2i)

const LINE_MAX := 64                   # celle al più in una linea
const REACH := 26.0                    # tessere dal Germogliato: ci si arriva con il braccio della Pinza

var m: Node2D
var mode := 0                          # 0-3 le vene (radice … cristallo), 4-7 i fili (turchese … viola)
var placed := 0                        # celle posate (per le prove)
var _from := Vector2i(-1, -1)
var _down := false


func setup(main: Node2D) -> void:
	m = main


func holding() -> bool:
	if m == null or not m.built:
		return false
	var it := ItemsData.get_item(String(m.hud.current().get("id", "")))
	return String(it.get("kind", "")) == "pinza"


func _process(_dt: float) -> void:
	if m == null or not m.built:
		return
	var h := holding()
	var show: bool = h or bool(Settings.v("mostra_fili")) or (m.get("energy") != null and m.energy.eye_on())
	m.view.set_show_wires(show)
	# la linea: dal clic a dove si lascia il tasto
	var down: bool = h and m.actions.enabled and not m.hud.is_open() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if down and not _down:
		_from = m.actions.mouse_cell()
	elif not down and _down and _from.x >= 0:
		line(_from, m.actions.mouse_cell(), mode)
		_from = Vector2i(-1, -1)
	_down = down


func _unhandled_input(e: InputEvent) -> void:
	if not holding() or not m.actions.enabled or m.hud.is_open():
		return
	if e is InputEventMouseButton and e.pressed:
		var mb := e as InputEventMouseButton
		if mb.shift_pressed and mb.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			mode = posmod(mode + (1 if mb.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1), VeinsData.MODES)
			var have: int = m.character.bisaccia.count(VeinsData.mode_item(mode))
			m.hud.toast("Pinza: %s (ne hai %d)" % [VeinsData.mode_name(mode), have])
			get_viewport().set_input_as_handled()
		elif mb.button_index == MOUSE_BUTTON_RIGHT:
			if take(m.actions.mouse_cell(), mode):
				get_viewport().set_input_as_handled()
		elif mb.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()      # la linea la fa `_process` al rilascio


## Una linea di celle (secondo il verso più lungo) dal punto a al punto b.
static func cells(a: Vector2i, b: Vector2i) -> Array:
	var out := []
	var d := b - a
	var step := Vector2i(signi(d.x), 0) if absi(d.x) >= absi(d.y) else Vector2i(0, signi(d.y))
	var n := maxi(absi(d.x), absi(d.y))
	for i in mini(n, LINE_MAX) + 1:
		out.append(a + step * i)
	return out


## Posa una linea; restituisce quante celle.
func line(a: Vector2i, b: Vector2i, md: int) -> int:
	var n := 0
	for c in cells(a, b):
		if put(c, md):
			n += 1
	if n > 0:
		m.sfx.play("piazza", Vector2(b) * 16.0)
	elif m.character.bisaccia.count(VeinsData.mode_item(md)) == 0:
		m.hud.toast("Non hai %s: si fa al banco (vedi Creare)" % VeinsData.mode_name(md).to_lower())
	return n


func _near(c: Vector2i) -> bool:
	return (Vector2(c) * 16.0 + Vector2(8, 8)).distance_to(m.player.position) <= REACH * 16.0


## Posa in una cella ciò che il modo dice (se c'è posto e se lo si ha). Vero se ha posato.
func put(c: Vector2i, md: int) -> bool:
	var w: World = m.world
	if not w.inside(c.x, c.y) or not _near(c):
		return false
	var b: int = w.vein_at(c.x, c.y)
	var nb := b
	if md < 4:
		if VeinsData.tier(b) == md + 1:
			return false
		if VeinsData.tier(b) > 0:
			take(c, md)                           # un grado diverso si sostituisce (il vecchio torna nella Bisaccia)
			b = w.vein_at(c.x, c.y)
		nb = (b & ~VeinsData.TIER_MASK) | (md + 1)
	else:
		if VeinsData.has_wire(b, md - 4):
			return false
		nb = b | (1 << (VeinsData.WIRE_SHIFT + md - 4))
	var item := VeinsData.mode_item(md)
	if m.character.bisaccia.count(item) <= 0:
		return false
	m.character.bisaccia.remove(item, 1)
	w.set_vein(c.x, c.y, nb)
	m.view.refresh_vein(c)
	placed += 1
	changed.emit(c)
	return true


## Riprende da una cella ciò che il modo dice (la vena, o il filo di quel colore). Vero se ha ripreso qualcosa.
func take(c: Vector2i, md: int) -> bool:
	var w: World = m.world
	if not w.inside(c.x, c.y):
		return false
	var b: int = w.vein_at(c.x, c.y)
	var item := ""
	var nb := b
	if md < 4:
		var t := VeinsData.tier(b)
		if t == 0:
			return false
		item = String(VeinsData.TIERS[t]["item"])
		nb = b & ~(VeinsData.TIER_MASK | VeinsData.INSULATED)
	else:
		if not VeinsData.has_wire(b, md - 4):
			return false
		item = VeinsData.mode_item(md)
		nb = b & ~(1 << (VeinsData.WIRE_SHIFT + md - 4))
	w.set_vein(c.x, c.y, nb)
	if m.character.bisaccia.add(item, 1) > 0:
		m.drops.spawn(item, 1, Vector2(c) * 16.0 + Vector2(8, 8))
	m.view.refresh_vein(c)
	changed.emit(c)
	return true


## L'isolante (voce 191): una vena che non si collega alle vicine di un altro grado. Vero se ha cambiato qualcosa.
func toggle_insulation(c: Vector2i) -> bool:
	var b: int = m.world.vein_at(c.x, c.y)
	if VeinsData.tier(b) == 0:
		return false
	m.world.set_vein(c.x, c.y, b ^ VeinsData.INSULATED)
	m.view.refresh_vein(c)
	changed.emit(c)
	return true
