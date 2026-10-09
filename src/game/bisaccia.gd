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
	"accessorio_2", "accessorio_3", "accessorio_4"]        # 9 ott 2026: le tasche tolte, al loro posto due accessori

var slots: Array[Dictionary] = []
## Il caso per i tratti e i genomi degli oggetti che entrano (null = il caso di sempre). Il generatore del mondo ci
## mette il suo, così lo stesso seme riempie le casse sempre allo stesso modo.
var rng: RandomNumberGenerator = null
var equip := {}                        # "elmo"/"corazza"/"gambali"/"accessorio_N" -> id dell'oggetto indossato
var equip_traits := {}                 # posto -> tratto del pezzo indossato ("" o assente = nessuno)
var equip_data := {}                   # posto -> "dati" del pezzo indossato (voce 50)
## Le borse che ti seguono (il basto, voce 299): [{"t", "bag", "icon", "tip", "accept"}].
var carriers: Array = []
## Gli scomparti (munizioni, torce, Lumini: `Compartments`), solo nella Bisaccia del personaggio; null altrove.
var comps: Bisaccia = null
## Roadmap 53 «La Bisaccia a scomparti» (dati in `BagData`), solo nella Bisaccia del personaggio: dopo la barra rapida le
## caselle sono nove scomparti contigui, uno per tipo ([id, prima casella, dopo l'ultima]); ciò che entra va da solo
## nel suo. `section_size` = le caselle di ognuno. Vuoto = una Bisaccia
## semplice (ceste, scrigni, la Dispensa). La Raccolta è una borsa a parte, senza limite, che resta addosso.
var sections: Array = []
var section_size := 0
var raccolta: Bisaccia = null


## `size`: 40 per la Bisaccia; le ceste e gli scrigni usano la stessa classe con meno caselle.
func _init(size := SIZE) -> void:
	slots.resize(size)
	for i in size:
		slots[i] = {}


## Che tipo di oggetto va in un posto dell'equipaggiamento (i posti «accessorio_N» prendono gli accessori).
static func kind_of_slot(slot: String) -> String:
	return "accessorio" if slot.begins_with("accessorio") else slot


## Tutte le borse in più per un oggetto: chi ti segue (il basto, voce 299).
func _extra_for(_id: String) -> Array[Bisaccia]:
	var out: Array[Bisaccia] = []
	for c in carriers:
		out.append(c["bag"] as Bisaccia)
	return out


## La Bisaccia e tutte le borse in più (scomparti, Raccolta, basto): per contare ciò che si ha.
func all_bags() -> Array[Bisaccia]:
	var out: Array[Bisaccia] = [self]
	if comps != null:
		out.append(comps)
	if raccolta != null:
		out.append(raccolta)
	for c in carriers:
		out.append(c["bag"] as Bisaccia)
	return out


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


## Voce 295: la Bisaccia cresce (le Bisacce a gradi); le caselle nuove sono vuote, in fondo. Roadmap 53: con gli
## scomparti `size` è la grandezza di ognuno.
func grow(size: int) -> bool:
	if not sections.is_empty():
		if size <= section_size:
			return false
		setup_sections(size, true)
		return true
	if size <= slots.size():
		return false
	var old := slots.size()
	slots.resize(size)
	for i in range(old, size):
		slots[i] = {}
	changed.emit()
	return true


# ---------------------------------------------------------------- Roadmap 53: gli scomparti

## Le caselle dello scomparto `sec` (da, a) nella Bisaccia; (0, 0) se non c'è.
func section_range(sec: String) -> Vector2i:
	for s in sections:
		if String(s[0]) == sec:
			return Vector2i(int(s[1]), int(s[2]))
	return Vector2i.ZERO


## Lo scomparto della casella i ("" per la barra rapida o senza scomparti).
func section_at(i: int) -> String:
	for s in sections:
		if i >= int(s[1]) and i < int(s[2]):
			return String(s[0])
	return ""


## Le caselle di ogni scomparto (tutti grandi uguali).
func _section_sizes(size: int) -> Dictionary:
	var out := {}
	for id in BagData.ids():
		out[id] = size
	return out


## Rifà gli scomparti grandi `size` caselle. `keep`: ognuno tiene ciò che ha, al suo posto (ciò che non ci
## sta più va dove può); senza (la prima volta, o una Bisaccia di prima) tutto ciò che sta oltre la barra rapida si
## ridistribuisce nel suo scomparto. Restituisce le pile che non sono entrate da nessuna parte.
func setup_sections(size: int, keep: bool) -> Array:
	var old := {}
	var loose: Array = []
	if keep and not sections.is_empty():
		for s in sections:
			old[String(s[0])] = slots.slice(int(s[1]), int(s[2]))
	else:
		for i in range(HOTBAR, slots.size()):
			if not slots[i].is_empty():
				loose.append(slots[i])
	var fresh: Array[Dictionary] = []
	for i in mini(HOTBAR, slots.size()):
		fresh.append(slots[i])
	while fresh.size() < HOTBAR:
		fresh.append({})
	section_size = size
	var sizes := _section_sizes(size)
	sections = []
	for sec in BagData.ids():
		var n := int(sizes[sec])
		var a := fresh.size()
		var lst: Array = old.get(sec, [])
		for k in n:
			fresh.append(lst[k] if k < lst.size() else {})
		for k in range(n, lst.size()):
			if not (lst[k] as Dictionary).is_empty():
				loose.append(lst[k])
		sections.append([sec, a, a + n])
	slots = fresh
	var over := []
	for st in loose:
		var left := add_stack(st)
		if left > 0:
			var rest: Dictionary = (st as Dictionary).duplicate()
			rest["n"] = left
			over.append(rest)
	changed.emit()
	return over


## Gli scomparti di una Bisaccia salvata con loro: le caselle sono già al loro posto, si rifà solo la mappa.
func restore_sections(size: int) -> Array:
	var sizes := _section_sizes(size)
	var total := HOTBAR
	for sec in BagData.ids():
		total += int(sizes[sec])
	if total != slots.size():
		return setup_sections(size, false)         # (le misure non tornano: si ridistribuisce; il resto lo dà a chi chiama)
	section_size = size
	sections = []
	var a := HOTBAR
	for sec in BagData.ids():
		sections.append([sec, a, a + int(sizes[sec])])
		a += int(sizes[sec])
	return []


## Riempie le pile uguali e poi le caselle vuote tra `a` e `b`; restituisce ciò che non entra.
func _fill(id: String, n: int, a: int, b: int) -> int:
	var cap := ItemsData.stack_of(id)
	for i in range(a, b):
		if n <= 0:
			break
		if id_at(i) == id and count_at(i) < cap and not slots[i].has("dati"):
			var k := mini(cap - count_at(i), n)
			slots[i]["n"] = count_at(i) + k
			n -= k
	for i in range(a, b):
		if n <= 0:
			break
		if slots[i].is_empty():
			var k2 := mini(cap, n)
			slots[i] = {"id": id, "n": k2}
			var fresh := Genome.fresh_for_item(id, rng)     # un Seme di mondo nasce con il suo genoma (voce 42)
			if not fresh.is_empty():
				slots[i]["dati"] = fresh
			if is_gear(id):
				var t := TraitsData.roll(id, rng)
				if t != "":
					slots[i]["tratto"] = t
			n -= k2
	return n


## Nella Raccolta: non si riempie mai (cresce di una pagina quando serve).
func _to_raccolta(id: String, n: int) -> int:
	var guard := 0
	while n > 0 and guard < 64:
		n = raccolta.add(id, n)
		if n > 0:
			raccolta.grow(raccolta.slots.size() + BagData.PAGE)
		guard += 1
	return n


## `add` con gli scomparti: la pila uguale della barra rapida, poi (la Raccolta o) lo scomparto del suo tipo; se è pieno,
## una casella vuota della barra rapida; poi il basto di chi ti segue.
func _add_sections(id: String, n: int) -> int:
	var cap := ItemsData.stack_of(id)
	for i in HOTBAR:
		if n > 0 and id_at(i) == id and count_at(i) < cap and not slots[i].has("dati"):
			var k := mini(cap - count_at(i), n)
			slots[i]["n"] = count_at(i) + k
			n -= k
	if n > 0 and raccolta != null and BagData.is_collection(id):
		n = _to_raccolta(id, n)
	if n > 0:
		var r := section_range(BagData.section_of(id))
		if r.y > r.x:
			n = _fill(id, n, r.x, r.y)
	if n > 0:
		n = _fill(id, n, 0, HOTBAR)
	for c in carriers:
		if n <= 0:
			break
		var cb: Bisaccia = c["bag"]
		if cb.room_for(id) > 0:
			n = cb.add(id, n)
	changed.emit()
	return n


## Le schede in più del pannello (tasche, basto): [{"t", "bag", "from", "tip", "icon"}]. Le riempiono le voci 296 e 299.
func extra_views() -> Array:
	var out := []
	if comps != null:
		var ghosts := []
		var tip := []
		for c in BackpackData.COMPARTMENTS:
			tip.append("%s %d" % [c["name"], int(c["slots"])])
			for k in int(c["slots"]):
				ghosts.append([String(c["ghost"]), String(c["name"])])
		out.append({"t": "Scomparti", "icon": "", "bag": comps, "from": 0, "ghosts": ghosts,
			"tip": "Scomparti: %s caselle. Ciò che è del loro tipo ci va da solo, e appassendo resta addosso." % ", ".join(tip)})
	for c in carriers:
		out.append({"t": "", "icon": String(c.get("icon", "")), "bag": c["bag"], "from": 0, "tip": String(c.get("tip", ""))})
	return out


## Un pezzo d'equipaggiamento (una casella a sé, con il suo tratto)?
static func is_gear(id: String) -> bool:
	return TraitsData.category_of(id) != "" and ItemsData.stack_of(id) == 1


func id_at(i: int) -> String:
	return String(slots[i].get("id", ""))


func count_at(i: int) -> int:
	return int(slots[i].get("n", 0))


## Aggiunge: prima riempie le pile uguali, poi le caselle vuote (barra rapida per prima). Restituisce ciò che non entra.
func add(id: String, n: int) -> int:
	if comps == null and not sections.is_empty():
		return _add_sections(id, n)
	# gli scomparti: prima si completa la pila che hai già nella barra rapida, poi la casella del suo tipo
	if comps != null and Compartments.kind_of(id) != "":
		var cap0 := ItemsData.stack_of(id)
		for i in HOTBAR:
			if n > 0 and id_at(i) == id and count_at(i) < cap0 and not slots[i].has("dati"):
				var k0 := mini(cap0 - count_at(i), n)
				slots[i]["n"] = count_at(i) + k0
				n -= k0
		n = Compartments.add(comps, id, n)
		if n <= 0:
			changed.emit()
			return 0
	if not sections.is_empty():
		return _add_sections(id, n)               # Roadmap 53
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
	for c in carriers:                       # voce 299: ciò che non ci sta va sul basto di chi ti segue
		if n <= 0:
			break
		var cb: Bisaccia = c["bag"]
		if cb.room_for(id) > 0:
			n = cb.add(id, n)
	changed.emit()
	return n


## Aggiunge una casella intera così com'è (con il suo tratto): serve per spostare tra Bisaccia e ceste senza perdere
## il tratto. Restituisce quanti non sono entrati.
func add_stack(s: Dictionary) -> int:
	if s.is_empty():
		return 0
	if not s.has("tratto") and not s.has("dati") and not is_gear(String(s["id"])):
		return add(String(s["id"]), int(s["n"]))
	if not sections.is_empty():
		# Roadmap 53: un oggetto unico nel suo scomparto (o nella Raccolta), poi nella barra rapida
		var sid := String(s["id"])
		if raccolta != null and BagData.is_collection(sid):
			if raccolta.add_stack(s) > 0:
				raccolta.grow(raccolta.slots.size() + BagData.PAGE)
				return raccolta.add_stack(s)
			return 0
		var r := section_range(BagData.section_of(sid))
		for i in range(r.x, r.y):
			if slots[i].is_empty():
				slots[i] = s.duplicate()
				changed.emit()
				return 0
		for i in HOTBAR:
			if slots[i].is_empty():
				slots[i] = s.duplicate()
				changed.emit()
				return 0
		return int(s["n"])
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
	if comps != null:
		r += Compartments.room_for(comps, id)
	if not sections.is_empty():
		# Roadmap 53: la barra rapida (pile uguali e caselle vuote), lo scomparto del suo tipo, la Raccolta, il basto
		if raccolta != null and BagData.is_collection(id):
			return 1 << 20
		var sr := section_range(BagData.section_of(id))
		for i in slots.size():
			if i >= HOTBAR and (i < sr.x or i >= sr.y):
				continue
			if slots[i].is_empty():
				r += cap
			elif id_at(i) == id and not slots[i].has("dati"):
				r += maxi(cap - count_at(i), 0)
		for c in carriers:
			r += (c["bag"] as Bisaccia).room_for(id)
		return r
	if not carriers.is_empty():
		for pb in _extra_for(id):
			r += pb.room_for(id)
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
	if not carriers.is_empty() or comps != null or raccolta != null:
		for b in all_bags():
			if b != self:
				c += b.count(id)              # anche ciò che sta negli scomparti, nella Raccolta e sul basto
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
	# voce 296: ciò che manca si prende dalle tasche (e dal basto)
	if n > 0:
		for b in all_bags():
			if b == self or n <= 0:
				continue
			var k := mini(b.count(id), n)
			if k > 0:
				b.remove(id, k)
				n -= k
	changed.emit()
	return true


## Toglie uno dalla casella i (oggetto usato dalla barra rapida).
func take_one(i: int) -> void:
	if slots[i].is_empty():
		return
	var id := id_at(i)
	slots[i]["n"] = count_at(i) - 1
	if count_at(i) <= 0:
		slots[i] = {}
		# la pila della barra rapida è finita: si riempie dallo scomparto (munizioni, torce, Lumini)
		if comps != null and i < HOTBAR:
			var got := Compartments.take(comps, id, ItemsData.stack_of(id))
			if got > 0:
				slots[i] = {"id": id, "n": got}
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
	"bisaccia", "torcia", "piattaforma", "seme", "seme_mondo", "blocco", "materiale", "essenza", "trofeo", "reliquia", "ricordo", "provetta", "fiala", "uovo", "creatura", "vasetto", "laccio", "legame"]


## Una casella bloccata (Alt+clic nella Bisaccia, 3 ott 2026): non la spostano il tasto Q, «Nelle casse», «Deposita
## tutto/simili», il Seme della Dispensa, e «Riordina» la lascia dov'è. Il segno sta nella casella («bloccato») e
## segue l'oggetto spostato a mano dentro la Bisaccia.
func locked(i: int) -> bool:
	return i >= 0 and i < slots.size() and bool(slots[i].get("bloccato", false))


func toggle_lock(i: int) -> bool:
	if slots[i].is_empty():
		return false
	if locked(i):
		slots[i].erase("bloccato")
	else:
		slots[i]["bloccato"] = true
	changed.emit()
	return locked(i)


func sort_bag(from := HOTBAR) -> void:
	if not sections.is_empty():
		for s in sections:                         # Roadmap 53: ogni scomparto per conto suo
			if int(s[2]) > from:
				_sort_range(maxi(int(s[1]), from), int(s[2]))
		changed.emit()
		return
	_sort_range(from, slots.size())
	changed.emit()


func _sort_range(from: int, to: int) -> void:
	to = mini(to, slots.size())
	var items: Array = []
	for i in range(from, to):
		if locked(i):
			continue                               # le caselle bloccate restano al loro posto
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
		while k < to and locked(k):
			k += 1                                 # (si salta la casella bloccata)
		# le pile uguali (senza tratto né dati) si uniscono finché c'è posto
		if k > from and not locked(k - 1) and slots[k - 1].get("id", "") == it["id"] and not it.has("tratto") and not slots[k - 1].has("tratto") \
				and not it.has("dati") and not slots[k - 1].has("dati"):
			var room := ItemsData.stack_of(String(it["id"])) - int(slots[k - 1]["n"])
			var moved := maxi(mini(room, int(it["n"])), 0)
			slots[k - 1]["n"] = int(slots[k - 1]["n"]) + moved
			it["n"] = int(it["n"]) - moved
			if int(it["n"]) <= 0:
				continue
		slots[k] = it
		k += 1


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
