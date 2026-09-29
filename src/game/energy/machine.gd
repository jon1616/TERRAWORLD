class_name Machine
extends RefCounted
## Roadmap 19: una macchina della rete nel mondo (una per stazione di `MachinesData`), mentre si gioca. Lo stato che
## resta (acceso, priorità, gocce in riserva, impostazioni) sta in `st`, che è un pezzo di `world_meta["rete"]["m"]`:
## si salva con il mondo. Il resto si ricalcola.

var o := Vector2i.ZERO                 # l'angolo della stazione
var id := ""
var d: Dictionary = {}                 # i dati di `MachinesData`
var st: Dictionary = {}                # lo stato che si salva
var bh: MachineBehavior
var net := -1                          # la rete del Flusso a cui è attaccata (-1 nessuna)
var entry := Vector2i(-1, -1)          # la cella di vena da cui prende
var cap := 0.0                         # la portata della vena più stretta sulla strada dalle sorgenti
var power := 0.0                       # quanto di ciò che chiede ha avuto nell'ultimo conto (0-1)
var given := 0.0                       # pulsi avuti nell'ultimo conto
var made := 0.0                        # pulsi dati (le sorgenti) nell'ultimo conto
var wired := {}                        # colore -> rete del filo (voce 193)
var lit := false                       # fa luce adesso
var key := ""


func setup(origin: Vector2i, sid: String, state: Dictionary) -> void:
	o = origin
	id = sid
	d = MachinesData.get_machine(sid)
	st = state
	bh = MachineBehavior.make(String(d.get("bh", "")))
	key = "%d,%d" % [o.x, o.y]


func role() -> String:
	return String(d.get("role", "macchina"))


func size() -> Vector2i:
	var s: Array = d.get("size", [1, 1])
	return Vector2i(int(s[0]), int(s[1]))


func rect() -> Rect2i:
	return Rect2i(o, size())


## La priorità: 0 bassa, 1 normale, 2 alta (la sceglie il giocatore nel pannello).
func prio() -> int:
	return int(st.get("prio", 1))


## Acceso? (Un interruttore della macchina, o l'Impulso; senza fili è sempre acceso.)
func on() -> bool:
	return bool(st.get("on", true))


## Il centro in pixel (per le distanze).
func center() -> Vector2:
	return (Vector2(o) + Vector2(size()) * 0.5) * 16.0
