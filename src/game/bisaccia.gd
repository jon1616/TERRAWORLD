class_name Bisaccia
extends RefCounted
## La Bisaccia del Germogliato: l'inventario. 40 caselle, le prime 10 sono la barra rapida. Ogni casella è vuota ({}) o
## {"id": oggetto, "n": quantità}, più "tratto" per l'equipaggiamento (voce 15, vedi `TraitsData`): un pezzo che entra
## senza tratto (fabbricato, trovato) ne tira uno a caso. Più l'equipaggiamento indossato (`equip`: elmo, corazza, gambali → id).
## Voce 41: una casella può portare anche "dati", un dizionario tutto suo (il genoma di un Seme di mondo, più avanti i
## componenti di un attrezzo). Una casella con dati è un oggetto unico: non si unisce mai a un'altra pila.
## Solo dati e regole (aggiungere, togliere, contare, indossare): nessun disegno.

signal changed

const SIZE := 40
const HOTBAR := 10
## Corredo iniziale del Germogliato.
const STARTER := [["piccone_radicite", 1], ["ascia_radicite", 1], ["spada_radice", 1], ["torcia", 10]]

## Voce 86: dieci posti (guanti, stivali, mantello, amuleto e anello oltre a quelli di prima). Il posto ha il nome del
## tipo di oggetto che prende, tranne «accessorio_N».
const EQUIP_SLOTS := ["elmo", "corazza", "gambali", "guanti", "stivali", "mantello", "amuleto", "anello", "accessorio_1",
	"accessorio_2"]

var slots: Array[Dictionary] = []
## Il caso per i tratti e i genomi degli oggetti che entrano (null = il caso di sempre). Il generatore del mondo ci
## mette il suo, così lo stesso seme riempie le casse sempre allo stesso modo.
var rng: RandomNumberGenerator = null
var equip := {}                        # "elmo"/"corazza"/"gambali"/"accessorio_N" -> id dell'oggetto indossato
var equip_traits := {}                 # posto -> tratto del pezzo indossato ("" o assente = nessuno)
var equip_data := {}                   # posto -> "dati" del pezzo indossato (voce 50)


## `size`: 40 per la Bisaccia; le ceste e gli scrigni usano la stessa classe con meno caselle.
func _init(size := SIZE) -> void:
	slots.resize(size)
	for i in size:
		slots[i] = {}


## Che tipo di oggetto va in un posto dell'equipaggiamento («accessorio_1» e «accessorio_2» prendono gli accessori).
static func kind_of_slot(slot: String) -> String:
	return "accessorio" if slot.begins_with("accessorio") else slot


func is_empty() -> bool:
	for s in slots:
		if not s.is_empty():
			return false
	return true


static func starter() -> Bisaccia:
	var b := Bisaccia.new()
	for s in STARTER:
		b.add(s[0], s[1])
	for s in b.slots:
		s.erase("tratto")                  # il corredo iniziale è semplice, senza tratti
	return b


func trait_at(i: int) -> String:
	return String(slots[i].get("tratto", ""))


## I dati propri della casella i ({} se non ne ha). Un Seme di mondo salvato prima dei genomi ne riceve uno adesso.
func data_at(i: int) -> Dictionary:
	if not slots[i].has("dati") and not slots[i].is_empty():
		var fresh := Genome.fresh_for_item(id_at(i))
		if not fresh.is_empty():
			slots[i]["dati"] = fresh
	return slots[i].get("dati", {})


## Un pezzo d'equipaggiamento (una casella a sé, con il suo tratto)?
static func is_gear(id: String) -> bool:
	return TraitsData.category_of(id) != "" and ItemsData.stack_of(id) == 1


func id_at(i: int) -> String:
	return String(slots[i].get("id", ""))


func count_at(i: int) -> int:
	return int(slots[i].get("n", 0))


## Aggiunge: prima riempie le pile uguali, poi le caselle vuote (barra rapida per prima). Restituisce ciò che non entra.
func add(id: String, n: int) -> int:
	var cap := ItemsData.stack_of(id)
	for i in slots.size():
		if n <= 0:
			break
		if id_at(i) == id and count_at(i) < cap and not slots[i].has("dati"):
			var k := mini(cap - count_at(i), n)
			slots[i]["n"] = count_at(i) + k
			n -= k
	for i in slots.size():
		if n <= 0:
			break
		if slots[i].is_empty():
			var k := mini(cap, n)
			slots[i] = {"id": id, "n": k}
			var fresh := Genome.fresh_for_item(id, rng)     # un Seme di mondo nasce con il suo genoma (voce 42)
			if not fresh.is_empty():
				slots[i]["dati"] = fresh
			if is_gear(id):
				var t := TraitsData.roll(id, rng)
				if t != "":
					slots[i]["tratto"] = t
			n -= k
	changed.emit()
	return n


## Aggiunge una casella intera così com'è (con il suo tratto): serve per spostare tra Bisaccia e ceste senza perdere
## il tratto. Restituisce quanti non sono entrati.
func add_stack(s: Dictionary) -> int:
	if s.is_empty():
		return 0
	if not s.has("tratto") and not s.has("dati") and not is_gear(String(s["id"])):
		return add(String(s["id"]), int(s["n"]))
	for i in slots.size():
		if slots[i].is_empty():
			slots[i] = s.duplicate()
			changed.emit()
			return 0
	return int(s["n"])


## Quanti ne posso ancora mettere (per non raccogliere ciò che non entra).
func room_for(id: String) -> int:
	var cap := ItemsData.stack_of(id)
	var r := 0
	for i in slots.size():
		if slots[i].is_empty():
			r += cap
		elif id_at(i) == id and not slots[i].has("dati"):
			r += maxi(cap - count_at(i), 0)
	return r


func count(id: String) -> int:
	var c := 0
	for i in slots.size():
		if id_at(i) == id:
			c += count_at(i)
	return c


## Toglie n oggetti (dalle ultime caselle, così la barra rapida resta piena più a lungo). False se non bastano.
func remove(id: String, n: int) -> bool:
	if count(id) < n:
		return false
	for i in range(slots.size() - 1, -1, -1):
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
	if not held.is_empty() and id_at(i) == String(held["id"]) and ItemsData.stack_of(id_at(i)) > 1 \
			and not held.has("dati") and not slots[i].has("dati"):
		var cap := ItemsData.stack_of(id_at(i))
		var k := maxi(mini(cap - count_at(i), int(held["n"])), 0)
		slots[i]["n"] = count_at(i) + k
		var rest := int(held["n"]) - k
		changed.emit()
		return {} if rest <= 0 else {"id": held["id"], "n": rest}
	var out := slots[i]
	slots[i] = held
	changed.emit()
	return out


## Scorza totale dell'equipaggiamento indossato.
## Riordina la parte grande della Bisaccia (non la barra rapida): unisce le pile uguali e mette in fila per tipo
## (attrezzi, armature, accessori, pozioni, materiali…) e poi per nome. I tratti restano ai loro oggetti.
const SORT_KINDS := ["piccone", "ascia", "spada", "arco", "bastone", "munizione", "elmo", "corazza", "gambali", "guanti",
	"stivali", "mantello", "amuleto", "anello",
	"accessorio", "consumabile", "cura", "dono", "purifica", "lanterna", "specchio", "mappa", "richiamo", "stazione", "pinza",
	"vena", "filo", "isolante",
	"torcia", "piattaforma", "seme", "seme_mondo", "blocco", "materiale", "essenza", "trofeo", "reliquia", "ricordo", "provetta", "fiala", "uovo", "creatura", "vasetto", "laccio"]


func sort_bag(from := HOTBAR) -> void:
	var items: Array = []
	for i in range(from, slots.size()):
		if not slots[i].is_empty():
			items.append(slots[i])
		slots[i] = {}
	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ka := SORT_KINDS.find(String(ItemsData.get_item(String(a["id"])).get("kind", "")))
		var kb := SORT_KINDS.find(String(ItemsData.get_item(String(b["id"])).get("kind", "")))
		if ka != kb:
			return ka < kb
		return String(ItemsData.get_item(String(a["id"])).get("name", "")) < String(ItemsData.get_item(String(b["id"])).get("name", "")))
	var k := from
	for it in items:
		# le pile uguali (senza tratto né dati) si uniscono finché c'è posto
		if k > from and slots[k - 1].get("id", "") == it["id"] and not it.has("tratto") and not slots[k - 1].has("tratto") \
				and not it.has("dati") and not slots[k - 1].has("dati"):
			var room := ItemsData.stack_of(String(it["id"])) - int(slots[k - 1]["n"])
			var moved := maxi(mini(room, int(it["n"])), 0)
			slots[k - 1]["n"] = int(slots[k - 1]["n"]) + moved
			it["n"] = int(it["n"]) - moved
			if int(it["n"]) <= 0:
				continue
		slots[k] = it
		k += 1
	changed.emit()


func scorza() -> int:
	var d := 0.0
	for k in equip:
		d += float(Gear.stats(_worn(k))["defense"])   # voce 54: qualità, tratto e innesti del pezzo
	return roundi(d)


## Indossa ciò che si tiene in mano nel posto giusto; restituisce ciò che torna in mano (il pezzo tolto, o la pila se
## non va lì).
func wear(slot: String, held: Dictionary) -> Dictionary:
	if held.is_empty():
		if equip.has(slot):
			var off := _worn(slot)
			equip.erase(slot)
			equip_traits.erase(slot)
			equip_data.erase(slot)
			changed.emit()
			return off
		return {}
	var id := String(held["id"])
	if String(ItemsData.get_item(id).get("kind", "")) != kind_of_slot(slot) or int(held["n"]) != 1:
		return held
	for other in equip:
		if other != slot and equip[other] == id and kind_of_slot(other) == "accessorio":
			return held                        # due accessori uguali non sommano gli effetti
	var back := _worn(slot) if equip.has(slot) else {}
	equip[slot] = id
	if String(held.get("tratto", "")) != "":
		equip_traits[slot] = String(held["tratto"])
	else:
		equip_traits.erase(slot)
	if held.has("dati"):
		equip_data[slot] = held["dati"]
	else:
		equip_data.erase(slot)
	changed.emit()
	return back


## Il pezzo indossato in un posto, come casella (con il suo tratto).
func _worn(slot: String) -> Dictionary:
	var d := {"id": equip[slot], "n": 1}
	if String(equip_traits.get(slot, "")) != "":
		d["tratto"] = equip_traits[slot]
	if equip_data.has(slot):
		d["dati"] = equip_data[slot]
	return d


func to_array() -> Array:
	var out := []
	for s in slots:
		if s.is_empty():
			out.append([])
		elif s.has("dati"):
			out.append([s["id"], s["n"], String(s.get("tratto", "")), s["dati"]])
		elif s.has("tratto"):
			out.append([s["id"], s["n"], s["tratto"]])
		else:
			out.append([s["id"], s["n"]])
	return out


static func from_array(a: Array, size := SIZE) -> Bisaccia:
	var b := Bisaccia.new(size)
	for i in mini(a.size(), size):
		var e: Array = a[i]
		if e.size() >= 2 and ItemsData.has(String(e[0])) and int(e[1]) > 0:
			b.slots[i] = {"id": String(e[0]), "n": int(e[1])}
			if e.size() >= 3 and TraitsData.TRAITS.has(String(e[2])):
				b.slots[i]["tratto"] = String(e[2])
			if e.size() >= 4 and e[3] is Dictionary and not (e[3] as Dictionary).is_empty():
				b.slots[i]["dati"] = SaveMigrations.ints(e[3])
	return b
