class_name Keys
extends RefCounted
## I comandi letti per nome (27 set 2026): i tasti li sceglie il giocatore nelle Opzioni (`Settings.keys_of`), i
## valori di partenza sono in `KeysData`. Nessun `KEY_…` scritto nel codice del gioco, tranne Esc e i numeri della
## barra rapida.


## Un tasto dell'azione appena premuto (non ripetuto tenendolo giù).
static func pressed(e: InputEvent, action: String) -> bool:
	if not (e is InputEventKey) or not e.pressed or e.echo:
		return false
	var k := (e as InputEventKey).keycode
	return k != KEY_NONE and k in Settings.keys_of(action)


## Un tasto dell'azione tenuto premuto adesso.
static func held(action: String) -> bool:
	for k in Settings.keys_of(action):
		if Input.is_key_pressed(int(k)):
			return true
	return false


## Il nome del primo tasto dell'azione («E», «Spazio», «F1»), per le scritte.
static func label(action: String) -> String:
	var ks := Settings.keys_of(action)
	return key_name(int(ks[0])) if not ks.is_empty() else "—"


## Tutti i tasti dell'azione («E / Tab»).
static func labels(action: String) -> String:
	return " / ".join(Settings.keys_of(action).map(func(k: Variant) -> String: return key_name(int(k))))


const NAMES := {KEY_SPACE: "Spazio", KEY_SHIFT: "Maiusc", KEY_TAB: "Tab", KEY_LEFT: "Freccia sinistra",
	KEY_RIGHT: "Freccia destra", KEY_UP: "Freccia su", KEY_DOWN: "Freccia giù", KEY_CTRL: "Ctrl", KEY_ALT: "Alt",
	KEY_ENTER: "Invio", KEY_BACKSPACE: "Cancella", KEY_CAPSLOCK: "Bloc Maiusc"}


static func key_name(k: int) -> String:
	if NAMES.has(k):
		return String(NAMES[k])
	return OS.get_keycode_string(k)


## Le due righe dell'aiuto in alto, con i tasti di adesso.
static func help_text() -> String:
	return "%s/%s muovi · %s salta · %s scendi dalle passerelle · clic sinistro usa · clic destro torcia o tocca (ceste, Cuore, portali)\n1-0 / rotella oggetti · %s Bisaccia · %s mappa · %s minimappa · %s Erbario · %s Enciclopedia · Esc pausa" % [
		label("sinistra"), label("destra"), label("salto"), label("giu"), label("bisaccia"), label("mappa"),
		label("minimappa"), label("erbario"), label("enciclopedia")]
