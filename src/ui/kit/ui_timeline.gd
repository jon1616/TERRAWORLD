class_name UiTimeline
extends VBoxContainer
## Le tappe di una strada (Roadmap 55): i gradi di un pilastro, gli stadi dell'Albero-Madre, i ranghi di un'arte, le
## stelle di un mondo. Una linea verticale con un nodo per tappa: pieno e del colore della strada se fatto, con l'alone
## se è il prossimo, vuoto se è lontano; accanto il numero, il nome e ciò che dà.
## `set_steps([{num, title, text, state ("fatto", "ora", "poi"), icon}, …], colore, larghezza)`.

var color := UiPalette.AMBRA


func _init() -> void:
	add_theme_constant_override("separation", 0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_steps(steps: Array, col: Color, w: float) -> void:
	color = col
	UiKit.clear(self)
	for i in steps.size():
		var s: Dictionary = steps[i]
		var st := String(s.get("state", "poi"))
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 12)
		hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var node := _Node.new()
		node.state = st
		node.color = col
		node.first = i == 0
		node.last = i == steps.size() - 1
		node.num = str(s.get("num", ""))
		node.custom_minimum_size = Vector2(34, 0)
		node.size_flags_vertical = Control.SIZE_FILL
		hb.add_child(node)
		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 1)
		vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var top := Control.new()
		top.custom_minimum_size = Vector2(0, 5)
		vb.add_child(top)
		var head := HBoxContainer.new()
		head.add_theme_constant_override("separation", 8)
		var tcol := UiPalette.TESTO if st == "fatto" else (UiPalette.AMBRA_CHIARA if st == "ora" else UiPalette.TESTO_SPENTO)
		if s.has("icon") and s["icon"] != null:
			head.add_child(UiKit.icon_rect(s["icon"], 22))
		head.add_child(UiKit.label(String(s.get("title", "")), UiPalette.TESTO_PX, tcol, "forte"))
		if st == "ora":
			head.add_child(UiKit.chip("il prossimo", col, null, UiPalette.MINI))
		vb.add_child(head)
		var tx := String(s.get("text", ""))
		if tx != "":
			vb.add_child(UiKit.para(tx, w - 50.0, UiPalette.NOTA + 1, UiPalette.TESTO_MUTO if st == "poi" else UiPalette.TESTO_SPENTO))
		var bot := Control.new()
		bot.custom_minimum_size = Vector2(0, 9)
		vb.add_child(bot)
		hb.add_child(vb)
		add_child(hb)


class _Node:
	extends Control
	var state := "poi"
	var color := UiPalette.AMBRA
	var first := false
	var last := false
	var num := ""

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var cx := size.x * 0.5
		var cy := 16.0
		var line := Color(color, 0.55) if state == "fatto" else Color(UiPalette.BORDO_CHIARO, 0.35)
		if not first:
			draw_line(Vector2(cx, 0), Vector2(cx, cy - 10.0), line, 2.0, true)
		if not last:
			var lc := Color(color, 0.55) if state == "fatto" else Color(UiPalette.BORDO_CHIARO, 0.25)
			draw_line(Vector2(cx, cy + 10.0), Vector2(cx, size.y), lc, 2.0, true)
		var f := UiFonts.get_font("numeri")
		match state:
			"fatto":
				draw_circle(Vector2(cx, cy), 10.0, color, true, -1.0, true)
				_num(f, cx, cy, UiPalette.FONDO)
			"ora":
				for k in 4:
					draw_circle(Vector2(cx, cy), 12.0 + k * 2.0, Color(color, 0.10 - k * 0.022), true, -1.0, true)
				draw_circle(Vector2(cx, cy), 10.0, Color("#0b1415"), true, -1.0, true)
				draw_circle(Vector2(cx, cy), 10.0, color, false, 2.0, true)
				_num(f, cx, cy, color.lightened(0.3))
			_:
				draw_circle(Vector2(cx, cy), 10.0, Color("#0b1415"), true, -1.0, true)
				draw_circle(Vector2(cx, cy), 10.0, Color(UiPalette.BORDO_CHIARO, 0.5), false, 1.2, true)
				_num(f, cx, cy, UiPalette.TESTO_MUTO)

	func _num(f: Font, cx: float, cy: float, c: Color) -> void:
		if num == "":
			return
		var fs := 12 if num.length() <= 2 else 10
		var tw := f.get_string_size(num, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		draw_string(f, Vector2(cx - tw * 0.5, cy + fs * 0.36), num, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, c)
