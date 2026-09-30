class_name UiFx
extends RefCounted
## Il movimento dell'interfaccia (voce 273, guida `ARTE.md` §6; l'utente: «vivo ma sobrio»): brevi, mai d'impaccio a un
## comando. Si spengono con l'opzione «animazioni» e nelle prove (le foto e i controlli vogliono l'interfaccia ferma;
## la galleria le riaccende per provarle).

const OPEN := 0.14                     # un pannello che compare: dissolvenza e 6 px dal basso
const RISE := 6.0
const COUNT := 0.25                    # un numero che cambia conta verso il valore nuovo

static var enabled := true


static func on() -> bool:
	return enabled and bool(Settings.v("animazioni"))


## Un pannello che si apre: parte trasparente e 6 px più in basso, arriva in `OPEN` secondi con la curva «esce veloce».
## Il posto vero si ricorda nel pannello (`fx_y`), così una riapertura a metà non lo sposta.
static func appear(c: Control) -> void:
	if not on() or c == null:
		return
	if not c.has_meta("fx_y"):
		c.set_meta("fx_y", c.position.y)
	var y: float = c.get_meta("fx_y")
	if c.has_meta("fx_tw"):
		var old: Tween = c.get_meta("fx_tw")
		if old != null and old.is_valid():
			old.kill()
	c.modulate.a = 0.0
	c.position.y = y + RISE
	var tw := c.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "modulate:a", 1.0, OPEN)
	tw.tween_property(c, "position:y", y, OPEN)
	c.set_meta("fx_tw", tw)


## Un numero che conta verso il valore nuovo: `show` riceve il valore di passaggio (un intero) e lo scrive.
static func count(owner: Node, from: int, to: int, show: Callable) -> void:
	if not on() or from == to or owner == null or not owner.is_inside_tree():
		show.call(to)
		return
	var tw := owner.create_tween()
	tw.tween_method(func(v: float) -> void: show.call(roundi(v)), float(from), float(to), COUNT) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## Un lampo breve su un controllo (un valore guadagnato, una casella che riceve un oggetto).
static func flash(c: CanvasItem, col := Color(1.35, 1.3, 1.1)) -> void:
	if not on() or c == null:
		return
	c.modulate = col
	c.create_tween().tween_property(c, "modulate", Color.WHITE, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
