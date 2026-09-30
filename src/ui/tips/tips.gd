class_name Tips
extends CanvasLayer
## Il sistema dei suggerimenti di tutto il gioco (autoload `TipsLayer`, 26 set 2026): uno solo, sopra ogni cosa, per
## l'interfaccia e per il mondo. Sostituisce i suggerimenti del motore (spenti in project.godot con un ritardo enorme).
##
## Da dove vengono le schede:
##   - un Control con `Tips.attach(control, funzione)`: la funzione restituisce una `TipCard` (o un testo);
##   - un Control con `tooltip_text` (o `_get_tooltip`): diventa una scheda di sole parole, senza toccare il codice;
##   - il mondo: la scena di gioco registra `Tips.set_world(funzione)`, che per la posizione del mouse restituisce
##     [chiave, costruttore] (la chiave dice quando si è passati a un'altra cosa) o [] se sotto il mouse non c'è niente.
##     Nel mondo la scheda arriva dopo un attimo di mouse fermo sulla stessa cosa, e sparisce premendo un tasto del
##     mouse (si sta scavando o combattendo).
## `Tips.shift` è vero con Maiusc premuto: le schede degli oggetti mostrano il confronto con ciò che si indossa.

## I ritardi (mouse fermo prima della scheda) sono nelle Opzioni: `tip_ritardo`, `tip_ritardo_mondo`.
const WARM := 0.35                     # appena chiusa una scheda, la successiva compare subito
const REFRESH := 0.45                  # le schede si rifanno ogni tanto (Vita di una creatura, crescita…)
const OFFSET := Vector2(20, 22)
const STILL := 4.0                     # pixel: il mouse che si sposta di meno è «fermo»

static var inst: Tips
static var shift := false
static var _world := Callable()
static var mouse_at := Vector2.INF     # nelle prove: il mouse «finto» in questo punto (il mouse vero può muoversi)
static var pinned := false             # nelle prove: la scheda resta dov'è (`show_at`) finché non si chiama `unpin`

var view: TipView
var _key: Variant = null               # a che cosa si riferisce la scheda (un Control o la chiave del mondo)
var _wait := 0.0
var _age := 0.0
var _cold := 99.0                      # da quanto non c'è una scheda
var _builder := Callable()
var _card_ms := 0.0                    # quanto è costata l'ultima scheda (per le prove)
var _last := ""                        # il testo dell'ultima scheda: se non è cambiato non si ridisegna
var _is_world := false                 # la scheda che si aspetta è di una cosa del mondo
var _still_at := Vector2.ZERO          # dove il mouse ha cominciato ad aspettare


func _ready() -> void:
	inst = self
	process_mode = Node.PROCESS_MODE_ALWAYS    # anche a gioco in pausa (Bisaccia, pannelli)
	layer = 100
	view = TipView.new()
	view.visible = false
	add_child(view)


## Un suggerimento per un controllo: `f` restituisce una `TipCard` o un testo (o null: niente).
static func attach(c: Control, f: Callable) -> void:
	c.set_meta("tip", f)


static func set_world(f: Callable) -> void:
	_world = f


static func clear_world() -> void:
	_world = Callable()


static func hide_now() -> void:
	if inst != null:
		inst._close()


## La scheda di un controllo, come la vedrebbe il giocatore (per le prove).
static func card_of(c: Control) -> TipCard:
	return _as_card(_provider(c).call()) if _provider(c).is_valid() else null


static func _as_card(v: Variant) -> TipCard:
	if v is TipCard:
		return v
	if v is String and String(v).strip_edges() != "":
		return TipCard.simple(String(v))
	return null


static func _provider(c: Control) -> Callable:
	if c.has_meta("tip"):
		return c.get_meta("tip")
	if c.tooltip_text != "":
		return func() -> Variant: return c.get_tooltip(c.get_local_mouse_position() if c.is_inside_tree() else Vector2.ZERO)
	return Callable()


func _process(dt: float) -> void:
	shift = Keys.held("confronta") or String(Settings.v("tip_confronto")) == "sempre"
	if pinned:
		return
	if not bool(Settings.v("tip_attivi")):
		_close()
		return
	view.scale = Vector2.ONE * float(Settings.v("tip_scala"))
	var vp := get_viewport()
	var fake := mouse_at != Vector2.INF
	var hov: Control = null if fake else vp.gui_get_hovered_control()
	var key: Variant = null
	var builder := Callable()
	var world := false
	var blocked := false
	var c := hov
	while c != null:
		var p := _provider(c)
		if p.is_valid():
			key = c
			builder = p
			break
		if c.mouse_filter == Control.MOUSE_FILTER_STOP:
			blocked = true
		c = c.get_parent() as Control
	if key == null and not blocked and _world.is_valid() and bool(Settings.v("tip_mondo")) \
			and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) \
			and not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var r: Array = _world.call(mouse_at if fake else vp.get_mouse_position())
		if not r.is_empty():
			key = r[0]
			builder = r[1]
			world = true
	if key == null:
		_close()
		_cold += dt
		return
	if not _same(key):
		_key = key
		_builder = builder
		_age = 0.0
		_is_world = world
		_still_at = _mouse()
		# Nell'interfaccia una scheda tira l'altra (appena aperta o chiusa, la successiva è subito). Nel mondo no: quasi
		# ogni cella ha la sua scheda, e passando il mouse sul terreno il ritardo non si vedeva mai (30 set 2026, l'utente).
		if world:
			_wait = float(Settings.v("tip_ritardo_mondo"))
		else:
			_wait = 0.0 if _cold < WARM or view.visible else float(Settings.v("tip_ritardo"))
		if _wait <= 0.0:
			_build()
		else:
			view.visible = false
		return
	if not view.visible:
		# nel mondo il ritardo conta a mouse fermo: muovendolo si ricomincia
		if _is_world and _mouse().distance_to(_still_at) > STILL:
			_still_at = _mouse()
			_wait = float(Settings.v("tip_ritardo_mondo"))
			return
		_wait -= dt
		if _wait <= 0.0:
			_build()
		return
	_age += dt
	if _age >= REFRESH or shift != bool(view.get_meta("shift", false)):
		_age = 0.0
		_builder = builder
		_build()
	_place()


## È ancora la stessa cosa di prima? (un Control o una chiave del mondo; il Control di prima può essere sparito)
func _same(key: Variant) -> bool:
	if _key == null or typeof(key) != typeof(_key):
		return false
	if _key is Object:
		return is_instance_valid(_key) and key == _key
	return key == _key


func _build() -> void:
	var t0 := Time.get_ticks_usec()
	var card := _as_card(_builder.call()) if _builder.is_valid() else null
	if card == null:
		view.visible = false
		return
	var plain := card.plain()
	if not view.visible or plain != _last or shift != bool(view.get_meta("shift", false)):
		view.show_card(card)
		_last = plain
	view.set_meta("shift", shift)
	_card_ms = (Time.get_ticks_usec() - t0) / 1000.0
	if not view.visible:
		view.visible = true
		view.modulate.a = 0.0
		create_tween().tween_property(view, "modulate:a", 1.0, 0.09)
	_cold = 0.0
	_place()


func _close() -> void:
	if view.visible:
		view.visible = false
		_cold = 0.0
	_key = null
	_builder = Callable()


## Accanto al mouse, in basso a destra; se esce dallo schermo passa dall'altra parte.
func _place() -> void:
	var vs := get_viewport().get_visible_rect().size
	var mp := mouse_at if mouse_at != Vector2.INF else get_viewport().get_mouse_position()
	view.size = view.get_combined_minimum_size()
	var sz := view.size * view.scale
	var p := mp + OFFSET
	if p.x + sz.x > vs.x - 6.0:
		p.x = mp.x - sz.x - 12.0
	if p.y + sz.y > vs.y - 6.0:
		p.y = mp.y - sz.y - 14.0               # in basso (barra rapida): sopra il mouse, così non copre le caselle
		if p.y < 6.0:
			p.y = maxf(vs.y - sz.y - 6.0, 6.0)
	view.position = Vector2(maxf(p.x, 6.0), maxf(p.y, 6.0))


func _mouse() -> Vector2:
	return mouse_at if mouse_at != Vector2.INF else get_viewport().get_mouse_position()


## Per le prove: mostra una scheda in un punto preciso, senza il mouse.
static func show_at(card: TipCard, at: Vector2) -> void:
	inst.view.show_card(card)
	inst.view.visible = true
	inst.view.modulate.a = 1.0
	inst.view.size = inst.view.get_combined_minimum_size()
	inst.view.position = at
	pinned = true


static func unpin() -> void:
	pinned = false
	if inst != null:
		inst._close()
