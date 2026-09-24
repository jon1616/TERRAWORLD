class_name Bisaccia
extends RefCounted
## La Bisaccia del Germogliato: l'inventario. 40 caselle, le prime 10 sono la barra rapida. Ogni casella è vuota ({}) o
## {"id": oggetto, "n": quantità}. Solo dati e regole (aggiungere, togliere, contare): nessun disegno.

signal changed

const SIZE := 40
const HOTBAR := 10
## Corredo iniziale del Germogliato.
const STARTER := [["piccone_radicite", 1], ["ascia_radicite", 1], ["spada_radice", 1], ["torcia", 10]]

var slots: Array[Dictionary] = []


func _init() -> void:
	slots.resize(SIZE)
	for i in SIZE:
		slots[i] = {}


static func starter() -> Bisaccia:
	var b := Bisaccia.new()
	for s in STARTER:
		b.add(s[0], s[1])
	return b


func id_at(i: int) -> String:
	return String(slots[i].get("id", ""))


func count_at(i: int) -> int:
	return int(slots[i].get("n", 0))


## Aggiunge: prima riempie le pile uguali, poi le caselle vuote (barra rapida per prima). Restituisce ciò che non entra.
func add(id: String, n: int) -> int:
	var cap := ItemsData.stack_of(id)
	for i in SIZE:
		if n <= 0:
			break
		if id_at(i) == id and count_at(i) < cap:
			var k := mini(cap - count_at(i), n)
			slots[i]["n"] = count_at(i) + k
			n -= k
	for i in SIZE:
		if n <= 0:
			break
		if slots[i].is_empty():
			var k := mini(cap, n)
			slots[i] = {"id": id, "n": k}
			n -= k
	changed.emit()
	return n


## Quanti ne posso ancora mettere (per non raccogliere ciò che non entra).
func room_for(id: String) -> int:
	var cap := ItemsData.stack_of(id)
	var r := 0
	for i in SIZE:
		if slots[i].is_empty():
			r += cap
		elif id_at(i) == id:
			r += cap - count_at(i)
	return r


func count(id: String) -> int:
	var c := 0
	for i in SIZE:
		if id_at(i) == id:
			c += count_at(i)
	return c


## Toglie n oggetti (dalle ultime caselle, così la barra rapida resta piena più a lungo). False se non bastano.
func remove(id: String, n: int) -> bool:
	if count(id) < n:
		return false
	for i in range(SIZE - 1, -1, -1):
		if n <= 0:
			break
		if id_at(i) == id:
			var k := mini(count_at(i), n)
			slots[i]["n"] = count_at(i) - k
			n -= k
			if count_at(i) <= 0:
				slots[i] = {}
	changed.emit()
	return true


## Toglie uno dalla casella i (oggetto usato dalla barra rapida).
func take_one(i: int) -> void:
	if slots[i].is_empty():
		return
	slots[i]["n"] = count_at(i) - 1
	if count_at(i) <= 0:
		slots[i] = {}
	changed.emit()


## Scambia il contenuto di una casella con quello «in mano» (il cursore); unisce le pile uguali.
func swap_with(i: int, held: Dictionary) -> Dictionary:
	if not held.is_empty() and id_at(i) == String(held["id"]):
		var cap := ItemsData.stack_of(id_at(i))
		var k := mini(cap - count_at(i), int(held["n"]))
		slots[i]["n"] = count_at(i) + k
		var rest := int(held["n"]) - k
		changed.emit()
		return {} if rest <= 0 else {"id": held["id"], "n": rest}
	var out := slots[i]
	slots[i] = held
	changed.emit()
	return out


func to_array() -> Array:
	var out := []
	for s in slots:
		out.append([s.get("id", ""), s.get("n", 0)] if not s.is_empty() else [])
	return out


static func from_array(a: Array) -> Bisaccia:
	var b := Bisaccia.new()
	for i in mini(a.size(), SIZE):
		var e: Array = a[i]
		if e.size() == 2 and ItemsData.has(String(e[0])) and int(e[1]) > 0:
			b.slots[i] = {"id": String(e[0]), "n": int(e[1])}
	return b
