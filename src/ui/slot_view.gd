class_name SlotView
extends Panel
## Una casella di oggetto nello stile «Radici e Linfa»: icona, quantità, bordo turchese (ambra se scelta).
## Usata dalla barra rapida e dalla Bisaccia.

signal clicked(index: int, button: int)

const SIZE := 56
const AMBER := Color("#ffb84a")
const TEAL := Color("#2f7a70")

static var _icons := {}
## Per le schede degli oggetti: () -> {"bag", "hand", "price"?} della partita in corso (lo imposta `TipsHook`).
static var context := Callable()

var index := 0
var _icon: TextureRect
var _count: Label
var _selected := false
var _hover := false
var _accent := Color(0, 0, 0, 0)       # la tinta della casella: il tipo dell'oggetto o la sua qualità (ARTE.md §2)
var slot_data := {}                    # l'oggetto intero della casella: {"id", "n", "tratto", "dati"}
var ghost_name := ""                   # un posto dell'equipaggiamento: il suo nome, per la scheda della casella vuota
var _ghost: TextureRect                # vuota, la casella mostra in trasparenza la sagoma di ciò che ci va
var tip_extra := {}                    # per questa casella: {"price": "buy", "cost": N} o {"equipped": true}


## L'icona dell'interfaccia (48 pixel, dipinta se c'è: `ItemIcons.ui`).
static func icon(id: String) -> Texture2D:
	if not _icons.has(id):
		_icons[id] = ImageTexture.create_from_image(ItemIcons.ui(id))
	return _icons[id]


static var _world_icons := {}


## L'icona del mondo (16 pixel, pixel art): l'attrezzo in mano, gli oggetti lanciati, le stelle cadenti.
static func world_icon(id: String) -> Texture2D:
	if not _world_icons.has(id):
		_world_icons[id] = ImageTexture.create_from_image(ItemIcons.of(id))
	return _world_icons[id]


func _init() -> void:
	custom_minimum_size = Vector2(SIZE, SIZE)
	size = Vector2(SIZE, SIZE)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_icon = TextureRect.new()
	_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.position = Vector2(4, 4)
	_icon.size = Vector2(48, 48)
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_icon)
	_count = Label.new()
	# (voce 272) i numeri nel carattere di pixel, a 2×, in basso a destra: la cella è alta quanto la casella e il testo
	# sta sul fondo, così la linea di base cade 4 px sopra il bordo (le code delle lettere sono vuote nei numeri)
	_count.position = Vector2(2, 0)
	_count.size = Vector2(SIZE - 6, SIZE)
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_count.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	PixelFont.apply(_count, 2, Color("#eafff6"), true)
	_count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_count)
	_restyle()
	mouse_entered.connect(func() -> void: _hover = true; _restyle())
	mouse_exited.connect(func() -> void: _hover = false; _restyle())
	Tips.attach(self, _tip)


## La scheda dell'oggetto nella casella (26 set 2026: suggerimenti ricchi, ricette e provenienza in Esamina).
func _tip() -> Variant:
	if slot_data.is_empty():
		if ghost_name != "":
			return TipCard.new().title(ghost_name, UiPalette.LINFA).line("Vuoto: posa qui un oggetto di questo tipo.", TipCard.SOFT)
		return null
	var ctx: Dictionary = (context.call() as Dictionary).duplicate() if context.is_valid() else {}
	ctx.merge(tip_extra, true)
	return ItemTip.card(slot_data, ctx)


func set_item(id: String, n: int, tratto := "", dati := {}) -> void:
	_icon.texture = icon(id) if id != "" else null
	_count.text = short_count(n) if n > 1 else ""
	slot_data = {"id": id, "n": n, "tratto": tratto, "dati": dati} if id != "" else {}
	# un filo dorato sotto l'icona se c'è un tratto
	_count.add_theme_color_override("font_color", Color("#ffd08a") if tratto != "" else Color.WHITE)
	if tratto != "" and n <= 1:
		_count.text = "✦"
	if _ghost != null:
		_ghost.visible = id == ""
	var ac := tint_of(slot_data)
	if ac != _accent:
		_accent = ac
		_restyle()


## La tinta del fondo di una casella: gli attrezzi e le armi fini o capolavoro prendono il colore della qualità, gli
## altri oggetti quello del loro tipo (trofei, semi, fiale…); materiali e blocchi restano neutri, così i colori
## segnano ciò che conta.
static func tint_of(slot: Dictionary) -> Color:
	if slot.is_empty():
		return Color(0, 0, 0, 0)
	var id := String(slot.get("id", ""))
	if Bisaccia.is_gear(id):
		var q := Gear.quality(slot)
		return Color(String(TraitsData.QUALITY[q]["color"])) if q >= 2 else Color(0, 0, 0, 0)
	var kind := String(ItemsData.get_item(id).get("kind", ""))
	if kind in ["materiale", "blocco", ""] or not TipWordsData.KIND_COLORS.has(kind):
		return Color(0, 0, 0, 0)
	return TipWordsData.kind_color(kind)


## La sagoma dei posti dell'equipaggiamento (voce 278): la forma d'icona `shape` come un'ombra chiara.
func set_ghost(shape: String, label: String) -> void:
	ghost_name = label
	if _ghost == null:
		_ghost = TextureRect.new()
		_ghost.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_ghost.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_ghost.position = Vector2(4, 4)
		_ghost.size = Vector2(48, 48)
		_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_ghost)
		move_child(_ghost, 0)
	var key := "ghost:" + shape
	if not _icons.has(key):
		var img := ItemIcons.make(shape, "radicite")
		for y in img.get_height():
			for x in img.get_width():
				if img.get_pixel(x, y).a > 0.1:
					img.set_pixel(x, y, Color(UiPalette.TESTO_MUTO, 0.22))
		_icons[key] = ImageTexture.create_from_image(img)
	_ghost.texture = _icons[key]
	_ghost.visible = slot_data.is_empty()


## Il lucchetto di una casella bloccata (Alt+clic nella Bisaccia): un segno piccolo nell'angolo in alto a destra.
var _lock: TextureRect
static var _lock_tex: ImageTexture


func set_locked(on: bool) -> void:
	if not on:
		if _lock != null:
			_lock.visible = false
		return
	if _lock_tex == null:
		var im := Image.create(7, 8, false, Image.FORMAT_RGBA8)
		var c := Color("#ffd08a")
		var d := Color("#8a5a20")
		for x in range(1, 6):                      # l'arco
			im.set_pixel(x, 0, c if x in [2, 3, 4] else Color(0, 0, 0, 0))
		for y in range(1, 3):
			im.set_pixel(1, y, c)
			im.set_pixel(5, y, c)
		for y in range(3, 8):                      # il corpo, con il buco della chiave
			for x in 7:
				im.set_pixel(x, y, c if y > 3 or (x > 0 and x < 6) else c)
		im.set_pixel(3, 5, d)
		im.set_pixel(3, 6, d)
		_lock_tex = ImageTexture.create_from_image(im)
	if _lock == null:
		_lock = TextureRect.new()
		_lock.texture = _lock_tex
		_lock.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_lock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_lock.size = Vector2(14, 16)
		_lock.position = Vector2(SIZE - 17, 3)
		_lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_lock)
	_lock.visible = true


## Toglie la sagoma (le caselle della griglia sono riusate tra le viste: solo gli scomparti ne hanno una).
func clear_ghost() -> void:
	if _ghost != null:
		_ghost.queue_free()
		_ghost = null
		ghost_name = ""


func set_selected(on: bool) -> void:
	if on != _selected:
		_selected = on
		_restyle()


func _restyle() -> void:
	add_theme_stylebox_override("panel", UiFrames.box("casella", "scelto" if _selected else ("sopra" if _hover else "normale"), _accent))


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed:
		clicked.emit(index, e.button_index)
		accept_event()


## I numeri delle pile grandi in poche cifre (28 set 2026, pile fino a infinite): 12500 → «12,5k», 3400000 → «3,4M».
static func short_count(n: int) -> String:
	if n < 10000:
		return str(n)
	if n < 1000000:
		return _short(n / 1000.0, "k") if n < 100000 else "%dk" % (n / 1000)
	if n < 1000000000:
		return _short(n / 1000000.0, "M") if n < 100000000 else "%dM" % (n / 1000000)
	return _short(n / 1000000000.0, "G")


static func _short(v: float, unit: String) -> String:
	var t := "%.1f" % (floorf(v * 10.0) / 10.0)
	return t.trim_suffix(".0").replace(".", ",") + unit
