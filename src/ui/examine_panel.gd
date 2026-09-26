class_name ExaminePanel
extends Control
## La casella «Esamina» della Bisaccia aperta (in alto a sinistra): ci si posa un oggetto con il clic (come in una
## casella qualunque, con la pila in mano di `BisacciaPanel`) e accanto compare la sua scheda (`ItemInfo`): a cosa
## serve, in quali ricette, come si ottiene. Chiudendo la Bisaccia l'oggetto torna nella Bisaccia.

const W := 460.0
const H := 350.0

var panel: BisacciaPanel
var held := {}                         # l'oggetto posato nella casella
var _slot: SlotView
var _text: RichTextLabel
var sheet: Callable                    # () -> testo della scheda del Germogliato (voce 29), quando la casella è vuota


func setup(p: BisacciaPanel, pos: Vector2) -> void:
	panel = p
	position = pos
	size = Vector2(W, H)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frame := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.01, 0.04, 0.05, 0.97)
	sb.border_color = Color("#2f7a70")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(18)
	frame.add_theme_stylebox_override("panel", sb)
	frame.size = size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)
	var title := Label.new()
	title.text = "Esamina"
	title.position = Vector2(16, 8)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color("#ffb84a"))
	add_child(title)
	_slot = SlotView.new()
	_slot.position = Vector2(16, 44)
	_slot.clicked.connect(_click)
	add_child(_slot)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.position = Vector2(84, 44)
	_text.size = Vector2(W - 96, H - 56)
	_text.add_theme_font_size_override("normal_font_size", 14)
	_text.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_text)
	refresh()


func _click(_i: int, button: int) -> void:
	if button != MOUSE_BUTTON_LEFT:
		return
	var out := held
	held = panel.held
	panel.held = out
	panel.refresh_held()
	refresh()


## Mostra un oggetto senza toglierlo dalla Bisaccia (prove, e in futuro altri usi). `dati`: quelli propri della
## casella (il genoma di un Seme, voce 42).
func show_item(id: String, tratto := "", dati := {}) -> void:
	_text.text = ItemInfo.bbcode(id, tratto, dati)


func refresh() -> void:
	if held.is_empty():
		_slot.set_item("", 0)
		if sheet.is_valid():
			_text.text = sheet.call()
		else:
			_text.text = "[color=#6a8a84]Posa qui un oggetto con il clic per sapere a cosa serve, in quali ricette si usa e come si ottiene.[/color]"
		return
	_slot.set_item(String(held["id"]), int(held["n"]), String(held.get("tratto", "")))
	if not held.has("dati"):
		var fresh := Genome.fresh_for_item(String(held["id"]))   # un Seme salvato prima dei genomi
		if not fresh.is_empty():
			held["dati"] = fresh
	show_item(String(held["id"]), String(held.get("tratto", "")), held.get("dati", {}))


## La Bisaccia si chiude: l'oggetto esaminato torna dentro.
func give_back() -> void:
	if not held.is_empty():
		panel.bisaccia.add_stack(held)
		held = {}
		refresh()
