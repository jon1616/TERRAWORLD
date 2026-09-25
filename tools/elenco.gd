extends SceneTree
## Stampa l'elenco di tutto ciò che c'è nel gioco, diviso per categorie, preso dalle tabelle dei dati.
## Uso: Godot_console.exe --headless --path . --script res://tools/elenco.gd


func _init() -> void:
	var items := ItemsData.all()
	var by_kind := {}
	for id in items:
		var k := String(items[id]["kind"])
		if not by_kind.has(k):
			by_kind[k] = []
		by_kind[k].append(String(items[id]["name"]))
	for k in by_kind:
		print("OGGETTI|%s|%s" % [k, "; ".join(by_kind[k])])
	for id in CreaturesData.CREATURES:
		var c: Dictionary = CreaturesData.CREATURES[id]
		var where := []
		for s in c["strata"]:
			where.append(String(StrataData.STRATA[s]["name"]))
		print("CREATURA|%s|%s|%d|%s|%s" % [c["name"], "boss" if c.get("boss", false) else ("notte" if c.get("night", false) else ""),
			int(c["hp"]), ", ".join(where), ",".join(c.get("biomes", []))])
	for s in StationsData.STATIONS:
		print("STAZIONE|%s" % StationsData.STATIONS[s]["name"])
	for t in TileDefs.NAMES:
		print("TESSERA|%s" % TileDefs.NAMES[t])
	for s in StrataData.STRATA:
		print("STRATO|%s" % s["name"])
	for b in BiomesData.BIOMES:
		print("BIOMA|%s" % b["name"])
	for t in TraitsData.TRAITS:
		print("TRATTO|%s|%s|%s" % [TraitsData.TRAITS[t]["name"], TraitsData.TRAITS[t]["desc"], ",".join(TraitsData.TRAITS[t]["for"])])
	for m in ItemsData.METALS:
		print("METALLO|%s|%d" % [ItemsData.METALS[m]["label"], int(ItemsData.METALS[m]["tier"])])
	print("RICETTE|%d" % RecipesData.all().size())
	print("OBIETTIVI|%d" % ObjectivesData.LIST.size())
	print("PAGINE|%s" % "; ".join(LoreData.PAGES.keys().map(func(k): return LoreData.PAGES[k]["title"])))
	quit()
