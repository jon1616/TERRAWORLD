class_name RecipeTile
extends Button
## Una ricetta nella griglia di «Creare» (28 set 2026, pannello riprogettato su richiesta dell'utente: «impaginazione
## nettamente migliore, con sfondo scuro, pratica, intuitiva e chiara»). Un riquadro del colore della sua categoria
## (`CraftCatsData`) con l'icona di ciò che nasce, la quantità, e sotto una barra: quanto degli ingredienti hai già
## (piena e verde = si può fare). Attenuata se non si può fare, cornice ambra se è quella scelta.
## Clic: la sceglie (la sua scheda compare in Esamina, con il pulsante «Crea»); doppio clic: crea una volta;
## Maiusc+clic: crea cinque volte. Come la vecchia riga è **un nodo solo** che si disegna da sé, e si riusa.

signal chosen(tile: RecipeTile)
signal quick(tile: RecipeTile, times: int)

const SIZE := 60
const AMBER := Color("#ffb84a")
const OK := Color("#7ee8a0")
const PART := Color("#e8c060")
const NONE := Color("#e06a5a")

static var _styles := {}

var r: Dictionary
var bag: Bisaccia
var can := false
var picked := false                    # è quella scelta
var fill := 0.0                        # quanto degli ingredienti hai (0-1)
var color := Color("#2f7a70")
var _tex: Texture2D
var _qty := 1


func setup(recipe: Dictionary, b: Bisaccia) -> void:
	r = recipe
	bag = b
	var out := String(r["out"])
	_qty = int(r["qty"])
	color = CraftCatsData.color_of(out)
	_tex = SlotView.icon(out)
	custom_minimum_size = Vector2(SIZE, SIZE)
	focus_mode = Control.FOCUS_NONE
	flat = true
	Tips.attach(self, _tip)
	gui_input.connect(_on_gui)


## I numeri secondo la Bisaccia di adesso: `possible` = si può fare, `have_n` i conteggi (Bisaccia e casse vicine).
func refresh(possible: bool, have_n: Dictionary) -> void:
	var tot := 0.0
	var got := 0.0
	for k in r["in"]:
		var need := float(r["in"][k])
		tot += 1.0
		got += minf(float(have_n.get(k, 0)) / need, 1.0)
	var f := got / maxf(tot, 1.0)
	if possible != can or absf(f - fill) > 0.001:
		can = possible
		fill = f
		queue_redraw()


func set_picked(on: bool) -> void:
	if on != picked:
		picked = on
		queue_redraw()


## I clic sulla casella. (Non chiamarla `_input`: quello è il metodo che il motore chiama per OGNI clic del gioco, e
## con `accept_event` le mille caselle si mangiavano tutti i clic di tutti i menu, 28 set 2026.)
func _on_gui(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		if e.double_click:
			quick.emit(self, 1)
		elif e.shift_pressed:
			quick.emit(self, 5)
		else:
			chosen.emit(self)
		accept_event()


func _draw() -> void:
	var rc := Rect2(Vector2.ZERO, size)
	draw_style_box(_box(color, can, picked, is_hovered()), rc)
	var a := 1.0 if can else 0.42
	draw_texture_rect(_tex, Rect2(10, 6, 40, 40), false, Color(1, 1, 1, a))
	if _qty > 1:
		var f := ThemeDB.fallback_font
		var t := "×%d" % _qty
		draw_string_outline(f, Vector2(size.x - 6 - f.get_string_size(t, 0, -1, 12).x, 44), t, 0, -1, 12, 3, Color(0, 0, 0))
		draw_string(f, Vector2(size.x - 6 - f.get_string_size(t, 0, -1, 12).x, 44), t, 0, -1, 12, Color("#f2fff9"))
	# la barra degli ingredienti
	var bw := size.x - 14
	draw_rect(Rect2(7, size.y - 9, bw, 4), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(7, size.y - 9, bw * fill, 4), OK if can else (PART if fill >= 0.5 else NONE))


static func _box(col: Color, possible: bool, sel: bool, hover: bool) -> StyleBox:
	return UiFrames.box("casella", "scelto" if sel else ("sopra" if hover else "normale"), Color(col, 1.0 if possible else 0.3))


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER or what == NOTIFICATION_MOUSE_EXIT:
		queue_redraw()


## La scheda al passaggio del mouse: l'oggetto che nasce e gli ingredienti con quanti ne hai.
func _tip() -> Variant:
	var ctx: Dictionary = (SlotView.context.call() as Dictionary).duplicate() if SlotView.context.is_valid() else {}
	var c := ItemTip.card({"id": String(r["out"]), "n": int(r.get("qty", 1))}, ctx)
	if c == null:
		return null
	if not c.blocks.is_empty() and String(c.blocks[-1]["t"]) == "hint":
		c.blocks.pop_back()
	c.sep()
	var rows := []
	for k in r["in"]:
		var need := int(r["in"][k])
		var have := Crafting.have(bag, String(k))
		rows.append([String(ItemsData.get_item(String(k)).get("name", k)), "%d / %d" % [mini(have, need), need],
			TipCard.GOOD if have >= need else TipCard.BAD])
	c.line("Serve", TipCard.GOLD)
	c.stats(rows)
	c.hint("Clic: scegli · doppio clic: crea · Maiusc+clic: crea 5")
	return c
