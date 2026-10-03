class_name Compartments
extends RefCounted
## Gli scomparti della Bisaccia (3 ott 2026, richiesta dell'utente: «slot dedicati alle munizioni, alle torce ed ai soldi;
## se muori non li perdi»). Una piccola borsa fissa del personaggio (`Bisaccia.comps`), con caselle per tipo
## (`BackpackData.COMPARTMENTS`): munizioni (dardi, esplosivi, giavellotti), torce, Lumini. Ciò che si raccoglie di quel
## tipo ci va da solo (dopo aver completato la pila che hai già nella barra rapida); quando una pila della barra rapida
## finisce, si riempie da qui. Appassendo resta addosso: il fagotto prende solo le caselle grandi della Bisaccia.
## Si salva con il personaggio («scomparti»).


## Il tipo di scomparto di un oggetto ("" se non ne ha).
static func kind_of(id: String) -> String:
	var it := ItemsData.get_item(id)
	var k := String(it.get("kind", ""))
	for c in BackpackData.COMPARTMENTS:
		if k in (c["kinds"] as Array):
			return String(c["id"])
	return ""


## Il tipo della casella i dello scomparto.
static func kind_at(i: int) -> String:
	var from := 0
	for c in BackpackData.COMPARTMENTS:
		if i < from + int(c["slots"]):
			return String(c["id"])
		from += int(c["slots"])
	return ""


static func size() -> int:
	var n := 0
	for c in BackpackData.COMPARTMENTS:
		n += int(c["slots"])
	return n


## La borsa degli scomparti, dai dati salvati (un elenco di caselle).
static func make(saved: Array) -> Bisaccia:
	var b := Bisaccia.from_array(saved, size())
	b.set_meta("accept_at", func(i: int, id: String) -> bool: return kind_of(id) != "" and kind_of(id) == kind_at(i))
	return b


## Quanti ne entrano ancora nelle caselle del suo tipo.
static func room_for(b: Bisaccia, id: String) -> int:
	var k := kind_of(id)
	if k == "":
		return 0
	var cap := ItemsData.stack_of(id)
	var r := 0
	for i in b.slots.size():
		if kind_at(i) != k:
			continue
		if b.slots[i].is_empty():
			r += cap
		elif b.id_at(i) == id and not b.slots[i].has("dati"):
			r += maxi(cap - b.count_at(i), 0)
	return r


## Mette n oggetti nelle caselle del loro tipo; restituisce ciò che non entra.
static func add(b: Bisaccia, id: String, n: int) -> int:
	var k := kind_of(id)
	if k == "" or n <= 0:
		return n
	var cap := ItemsData.stack_of(id)
	for pass_empty in [false, true]:
		for i in b.slots.size():
			if n <= 0 or kind_at(i) != k:
				continue
			if not pass_empty and b.id_at(i) == id and b.count_at(i) < cap:
				var a := mini(cap - b.count_at(i), n)
				b.slots[i]["n"] = b.count_at(i) + a
				n -= a
			elif pass_empty and b.slots[i].is_empty():
				var a2 := mini(cap, n)
				b.slots[i] = {"id": id, "n": a2}
				n -= a2
	b.changed.emit()
	return n


## Prende fino a n oggetti di questo tipo dallo scomparto (per riempire una pila finita della barra rapida).
static func take(b: Bisaccia, id: String, n: int) -> int:
	var got := 0
	for i in range(b.slots.size() - 1, -1, -1):
		if got >= n:
			break
		if b.id_at(i) == id:
			var a := mini(b.count_at(i), n - got)
			b.slots[i]["n"] = b.count_at(i) - a
			got += a
			if b.count_at(i) <= 0:
				b.slots[i] = {}
	if got > 0:
		b.changed.emit()
	return got


## La prima volta: sposta negli scomparti ciò che è già nelle caselle grandi della Bisaccia (non la barra rapida).
static func gather(main: Bisaccia, b: Bisaccia) -> void:
	for i in range(Bisaccia.HOTBAR, main.slots.size()):
		var id := main.id_at(i)
		if id == "" or kind_of(id) == "" or main.slots[i].has("dati"):
			continue
		var left := add(b, id, main.count_at(i))
		if left <= 0:
			main.slots[i] = {}
		else:
			main.slots[i]["n"] = left
