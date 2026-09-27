class_name Chronicle
extends Node
## La cronaca: collega gli eventi del gioco agli avvisi, all'Erbario e ai conteggi degli obiettivi, così `main.gd`
## resta solo montaggio. Creature rare che nascono o svaniscono, rare sconfitte (conteggi per rarità), innesti,
## oggetti nati dai trofei, reliquie trovate e collezioni complete.

var m: Node2D


func setup(main: Node2D) -> void:
	m = main
	m.hud.panel.crafting.grafted.connect(func(_id: String) -> void: m.objectives.bump("innesti"))
	m.hud.panel.crafting.crafted.connect(_on_crafted)
	m.fauna.rare_spawned.connect(_on_rare)
	m.fauna.vanished.connect(func(c: Creature) -> void: m.hud.toast("%s iridata è svanita nel nulla" % c.data["name"]))
	m.fauna.killed.connect(_on_killed)
	m.erbario.discovered.connect(_on_discovered)


func _on_crafted(id: String, _n: int) -> void:
	if TrophyItemsData.ITEMS.has(id) and String(ItemsData.get_item(id).get("kind", "")) != "trofeo":
		m.objectives.bump("oggetti_trofeo")


func _on_rare(c: Creature) -> void:
	if c.ancient.rarity == "iridata":
		m.hud.toast("Una creatura iridata qui vicino: %s. Prendila prima che svanisca!" % c.data["name"])
	else:
		m.hud.toast("Una presenza ancestrale si risveglia qui vicino: %s" % c.data["name"])
	m.sfx.play("presenza")


## Le rare sconfitte: nell'Erbario per specie, e un conteggio per rarità per gli obiettivi.
func _on_killed(c: Creature) -> void:
	if not c.ancient:
		return
	var n: Dictionary = m.erbario.data["antiche"]
	n[c.base] = int(n.get(c.base, 0)) + 1
	m.objectives.bump({"antica": "antiche", "ancestrale": "ancestrali", "capobranco": "capibranco",
		"iridata": "iridate"}[c.ancient.rarity])
	# voce 98: le ancestrali e le iridate a volte lasciano un oggetto unico
	if c.ancient.rarity in ["ancestrale", "iridata"] and randf() < float(UniqueSeriesData.POOL_CHANCE["ancestrali"]):
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		m.drops.spawn(UniquesData.roll("ancestrali", rng, m.erbario.data["oggetti"]), 1, c.position + Vector2(0, -12))


## Le reliquie contano appena l'Erbario le ricorda: una collezione completa dà il suo bonus per sempre.
func _on_discovered(section: String, id: String) -> void:
	if section == "oggetti" and UniqueSeriesData.series_of(id) != "":
		_on_unique(id)
		return
	if section != "oggetti" or RelicsData.collection_of(id) == "":
		return
	var before: int = m.gear.relics.size()
	m.gear.refresh()
	var col := RelicsData.collection_of(id)
	if m.gear.relics.size() > before:
		m.hud.toast("Collezione completa: %s! Per sempre: %s" % [RelicsData.COLLECTIONS[col]["name"],
			RelicsData.COLLECTIONS[col]["desc"]])
	else:
		m.hud.toast("Reliquia trovata: %s" % ItemsData.get_item(id)["name"])



## Voce 98: un oggetto unico nuovo per l'Erbario: a che punto è la sua serie, e il premio se è completa.
func _on_unique(id: String) -> void:
	var sid := UniqueSeriesData.series_of(id)
	var sd: Dictionary = UniqueSeriesData.SERIES[sid]
	var found: Dictionary = m.erbario.data["oggetti"]
	var n := 0
	for x in sd["items"]:
		if found.has(x):
			n += 1
	m.objectives.bump("unici")
	var total: int = (sd["items"] as Array).size()
	if n == total:
		m.gear.refresh()
		m.objectives.bump("serie_unici")
		m.hud.toast("Serie completa: %s! Per sempre: %s" % [sd["name"], sd["desc"]])
	else:
		m.hud.toast("Oggetto unico: %s — serie «%s» %d su %d" % [ItemsData.get_item(id)["name"], sd["name"], n, total])
