extends SceneTree
## L'impronta del contenuto (pulizia del 28 set 2026): un'impronta (hash) di ogni tabella del gioco, con le chiavi in
## ordine, e le mappe di due mondi. Si lancia prima e dopo un riordino del codice: se tutto esce uguale, il gioco non è
## cambiato. Scrive prove/impronta.txt (e lo stampa).
##   Godot_console.exe --headless --path . --script res://tools/impronta.gd


func _sorted(d: Variant) -> Variant:
	if d is Dictionary:
		var keys: Array = (d as Dictionary).keys()
		keys.sort_custom(func(a: Variant, b: Variant) -> bool: return str(a) < str(b))
		var out := []
		for k in keys:
			out.append([str(k), _sorted(d[k])])
		return out
	if d is Array:
		var out2 := []
		for x in d:
			out2.append(_sorted(x))
		return out2
	return d


## Senza i campi che dicono solo dove sta un dato (debolezze e trofei dentro la creatura, pacchetto dentro il bioma):
## quei dati si contano già nelle loro tabelle.
func _strip(d: Dictionary, keys: Array) -> Dictionary:
	var out := {}
	for k in d:
		var e: Dictionary = (d[k] as Dictionary).duplicate()
		for x in keys:
			e.erase(x)
		out[k] = e
	return out


func _strip_list(a: Array, keys: Array) -> Array:
	var out := []
	for e in a:
		var d: Dictionary = (e as Dictionary).duplicate()
		for x in keys:
			d.erase(x)
		out.append(d)
	return out


func _h(name: String, v: Variant) -> String:
	var s := var_to_str(_sorted(v))
	return "%-22s %s  (%d)" % [name, s.md5_text(), (v as Dictionary).size() if v is Dictionary else (v as Array).size() if v is Array else 0]


func _init() -> void:
	var recipes := RecipesData.all().duplicate(true)
	recipes.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return var_to_str(_sorted(a)) < var_to_str(_sorted(b)))
	var lines := [
		_h("oggetti", ItemsData.all()),
		_h("ricette", recipes),
		_h("creature", _strip(CreaturesData.CREATURES, ["affinity", "trophy"])),
		_h("bottino", LootData.TABLES),
		_h("famiglie", FamiliesData.FAMILIES),
		_h("debolezze", ElementsData.AFFINITY),
		_h("trofei", TrophyItemsData.TROPHY_OF),
		_h("set", SetsData.all()),
		_h("geni", GenesData.GENES),
		_h("paesaggi", NamesData.LANDS),
		_h("aggettivi", NamesData.ADJ),
		_h("stazioni", StationsData.STATIONS),
		_h("biomi", _strip_list(BiomesData.BIOMES, ["creatures", "families", "loot", "items", "recipes", "sets", "genes", "lands", "fauna", "adj"])),
		_h("sottosuolo", UnderBiomesData.UNDER),
		_h("tessere_nomi", TileDefs.NAMES),
		_h("tessere_durezza", TileDefs.HARD),
		_h("strati_terreno", TileDefs.TERRAIN_LAYERS),
		_h("alberi", TreesData.SPECIES),
		_h("effetti", EffectsData.EFFECTS),
		_h("unici_serie", UniqueSeriesData.SERIES),
	]
	for sd in [1, 2]:
		var w := World.new()
		WorldGen.generate(w, sd, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 2, "geni": []})
		lines.append_array(world_lines(w, "mondo_%d" % sd))
	var text := "\n".join(lines)
	print(text)
	var f := FileAccess.open("res://prove/impronta.txt", FileAccess.WRITE)
	f.store_string(text + "\n")
	quit()


## L'impronta di un mondo, una riga per parte (così si vede subito che cosa è cambiato). La usa anche la prova della
## ripetibilità del generatore.
static func world_lines(w: World, name: String) -> PackedStringArray:
	var st := []
	for k in w.stations:
		st.append("%s=%s" % [k, w.stations[k]])
	st.sort()
	var tr := []
	for k in w.trees:
		for t in w.trees[k]:
			tr.append(str(t))
	tr.sort()
	var ch := []
	for k in w.chests:
		ch.append("%s=%s" % [k, (w.chests[k] as Bisaccia).slots])
	ch.sort()
	var out := PackedStringArray()
	for part in [["tessere", w.tiles.hex_encode()], ["pareti", w.walls.hex_encode()], ["biomi", w.biomes.hex_encode()],
			["decorazioni", w.decor.hex_encode()], ["liquidi", w.liquid.hex_encode()], ["superficie", str(w.surface)],
			["stazioni", str(st)], ["alberi", str(tr)], ["casse", str(ch)], ["partenza", str(w.spawn)]]:
		out.append("%-22s %s" % ["%s %s" % [name, part[0]], String(part[1]).md5_text()])
	return out
