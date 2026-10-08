class_name Erbario
extends Node
## L'Erbario (voce 14, UNIVERSO.md «Da collezionare»): ciò che il Germogliato ha scoperto, salvato con il personaggio
## (`Character.erbario`). Tre sezioni:
##   creature  quante ne ha sconfitte (vedi `Fauna.killed`); incontrarle non basta, vanno affrontate
##   oggetti   ogni oggetto entrato almeno una volta nella Bisaccia (o indossato)
##   pagine    le pagine di storia lette (`LorePanel.page_shown`)
## La percentuale di completamento conta le voci scoperte su tutte quelle che esistono nei dati.

var m: Node2D
var data: Dictionary                   # il dizionario del personaggio: {"creature": {id: n}, "oggetti": {id: 1}, "pagine": {id: 1}}

signal discovered(section: String, id: String)


func setup(main: Node2D) -> void:
	m = main
	data = m.character.erbario
	for k in ["creature", "oggetti", "pagine", "antiche", "famiglie"]:
		if not data.has(k):
			data[k] = {}
	# voce 61: le famiglie delle creature già sconfitte (personaggi di prima)
	for s in data["creature"]:
		var f0 := FamiliesData.family_of(String(s))
		if f0 != "":
			data["famiglie"][f0] = 1
	m.fauna.killed.connect(func(c: Creature) -> void:
		if GuardianGen.is_gen(c.id):
			return                                   # voce 80: i Guardiani generati non sono specie dell'Erbario
		add("creature", c.base)
		if FamiliesData.family_of(c.base) != "":
			add("famiglie", FamiliesData.family_of(c.base))
		if c.id != c.base:
			add_variant(c.id))
	m.character.bisaccia.changed.connect(_scan)
	m.guardian.lore.page_shown.connect(func(id: String) -> void: add("pagine", id))
	_scan()


## Segna una scoperta (le creature contano quante volte). Restituisce true se è nuova.
func add(section: String, id: String) -> bool:
	var sec: Dictionary = data[section]
	var fresh := not sec.has(id)
	sec[id] = int(sec.get(id, 0)) + 1 if section == "creature" else 1
	if fresh:
		discovered.emit(section, id)
		if m.built and section != "oggetti":
			m.hud.toast("Erbario: nuova voce — %s" % title_of(section, id))
	return fresh


func _scan() -> void:
	var b: Bisaccia = m.character.bisaccia
	for s in b.slots:
		if not s.is_empty():
			add("oggetti", String(s["id"]))
	for k in b.equip:
		add("oggetti", String(b.equip[k]))


## Tutte le voci di una sezione, nell'ordine dei dati.
## Una variante sconfitta (voce 55): `data["varianti"][id] = quante`.
func add_variant(id: String) -> void:
	if not data.has("varianti"):
		data["varianti"] = {}
	data["varianti"][id] = int(data["varianti"].get(id, 0)) + 1


static var _items: Array = []


static func entries(section: String) -> Array:
	match section:
		"creature":
			return CreaturesData.CREATURES.keys()
		"oggetti":
			# gli oggetti generati a centinaia (forme nuove, leghe), le Fiale (che conta il Genario) e i pesci (voce 120:
			# la loro sezione, fuori dalla percentuale: la pesca non è indispensabile) restano fuori
			# (l'elenco non cambia durante la partita: si fa una volta, costava ~30 ms a ogni percentuale)
			if _items.is_empty():
				_items = ItemsData.all().keys().filter(func(k: String) -> bool:
					var it := ItemsData.get_item(k)
					return not it.get("gen", false) and not String(it.get("kind", "")) in ["fiala", "pesce"])
			return _items
		"pesci":
			return FishData.all().keys()
		"pagine":
			return LoreData.PAGES.keys()
		"famiglie":
			return FamiliesData.FAMILIES.keys()          # voce 61
	return []


static func title_of(section: String, id: String) -> String:
	match section:
		"creature":
			return String(CreaturesData.get_data(id)["name"])     # (anche le creature delle stagioni)
		"oggetti":
			return String(ItemsData.get_item(id).get("name", id))
		"pagine":
			return String(LoreData.PAGES[id]["title"])
		"famiglie":
			return String(FamiliesData.FAMILIES[id]["name"])
		"pesci":
			return String(FishData.info(id).get("name", id))
	return id


func known(section: String, id: String) -> bool:
	return (data.get(section, {}) as Dictionary).has(id)


## Percentuale di completamento (0-100) di una sezione, o di tutto se `section` è vuota.
## (8 ott 2026) Si ricorda finché restano lo stesso dizionario e lo stesso numero di voci conosciute: scorrere migliaia
## di oggetti costava ~4 ms, e i traguardi del Museo la chiedono ogni 10 s.
func percent(section := "") -> float:
	var sizes := []
	for sec in ["creature", "oggetti", "pagine", "famiglie"]:
		sizes.append((data.get(sec, {}) as Dictionary).size())
	if not is_same(_pct_of, data) or sizes != _pct_sizes:
		_pct_of = data
		_pct_sizes = sizes
		_pct_cache.clear()
	if not _pct_cache.has(section):
		_pct_cache[section] = _percent(section)
	return float(_pct_cache[section])


var _pct_cache := {}
var _pct_sizes := []
var _pct_of: Dictionary


func _percent(section: String) -> float:
	var tot := 0
	var got := 0
	for sec in (["creature", "oggetti", "pagine", "famiglie"] if section == "" else [section]):
		# si contano le voci conosciute (poche centinaia) che stanno nell'elenco, non tutto l'elenco (migliaia)
		var ids := _entry_set(sec)
		tot += ids.size()
		for id in (data.get(sec, {}) as Dictionary):
			if ids.has(id):
				got += 1
	return 100.0 * got / maxi(tot, 1)


static var _sets := {}


static func _entry_set(sec: String) -> Dictionary:
	if not _sets.has(sec):
		var d := {}
		for id in entries(sec):
			d[id] = true
		_sets[sec] = d
	return _sets[sec]


## Voce 120: un pesce pescato: quanti e il più grande (centimetri). Restituisce vero se è il primo o un record.
func add_fish(id: String, size: int) -> bool:
	if not data.has("pesci"):
		data["pesci"] = {}
	var sec: Dictionary = data["pesci"]
	var fresh := not sec.has(id)
	var e: Dictionary = sec.get(id, {"n": 0, "max": 0})
	var record := size > int(e.get("max", 0))
	e["n"] = int(e.get("n", 0)) + 1
	e["max"] = maxi(int(e.get("max", 0)), size)
	sec[id] = e
	if fresh:
		discovered.emit("pesci", id)
		if m.built:
			m.hud.toast("Erbario, Pesci: nuova voce — %s" % title_of("pesci", id))
	return fresh or record


## Voce 61: una creatura della famiglia addomesticata (o nata nell'Incubatrice), e un uovo preso da un suo nido.
func note_tamed(fam: String) -> void:
	add("famiglie", fam)
	if not data.has("addomesticate"):
		data["addomesticate"] = {}
	data["addomesticate"][fam] = int(data["addomesticate"].get(fam, 0)) + 1


func note_nest(fam: String) -> void:
	if not data.has("nidi"):
		data["nidi"] = {}
	data["nidi"][fam] = 1
