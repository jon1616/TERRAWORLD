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
	for k in ["creature", "oggetti", "pagine", "antiche"]:
		if not data.has(k):
			data[k] = {}
	m.fauna.killed.connect(func(c: Creature) -> void: add("creature", c.id))
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
static func entries(section: String) -> Array:
	match section:
		"creature":
			return CreaturesData.CREATURES.keys()
		"oggetti":
			# gli oggetti generati a centinaia (forme nuove, leghe) e le Fiale (che conta il Genario) restano fuori
			return ItemsData.all().keys().filter(func(k: String) -> bool:
				var it := ItemsData.get_item(k)
				return not it.get("gen", false) and String(it.get("kind", "")) != "fiala")
		"pagine":
			return LoreData.PAGES.keys()
	return []


static func title_of(section: String, id: String) -> String:
	match section:
		"creature":
			return String(CreaturesData.CREATURES[id]["name"])
		"oggetti":
			return String(ItemsData.get_item(id).get("name", id))
		"pagine":
			return String(LoreData.PAGES[id]["title"])
	return id


func known(section: String, id: String) -> bool:
	return (data[section] as Dictionary).has(id)


## Percentuale di completamento (0-100) di una sezione, o di tutto se `section` è vuota.
func percent(section := "") -> float:
	var tot := 0
	var got := 0
	for sec in (["creature", "oggetti", "pagine"] if section == "" else [section]):
		for id in entries(sec):
			tot += 1
			if known(sec, id):
				got += 1
	return 100.0 * got / maxi(tot, 1)
