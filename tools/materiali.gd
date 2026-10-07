extends SceneTree
## L'elenco degli ingredienti per i generatori Python del piano «La vastità» (Roadmap 46): scrive
## `tools/vastita_gen/materiali.json` con, per ogni oggetto che non si indossa e non si impugna, il nome, il tipo, la fase
## (`PhasesData.of`) e da dove viene (le colture dell'orto, i prodotti della mandria, i pesci). Da rifare quando cambiano
## i materiali:
##     Godot_console.exe --headless --path . --script res://tools/materiali.gd


func _init() -> void:
	var crops := {}
	for c in CropsData.CROPS:
		var cd: Dictionary = CropsData.CROPS[c]
		for k in (cd.get("harvest", {}) as Dictionary):
			crops[String(k)] = true
	var herd := {}
	for f in HerdData.TAME:
		var td: Dictionary = HerdData.TAME[f]
		if td.get("produce", []) is Array and not (td["produce"] as Array).is_empty():
			herd[String(td["produce"][0])] = true
	var out := {}
	for id in ItemsData.all():
		var it: Dictionary = ItemsData.all()[id]
		var kind := String(it.get("kind", ""))
		if TraitsData.category_of(String(id)) != "" or it.has("damage") or it.has("place") or it.has("gen"):
			continue
		out[String(id)] = {"name": String(it.get("name", id)), "kind": kind, "phase": PhasesData.of(String(id)),
			"crop": crops.has(id), "herd": herd.has(id), "fish": kind == "pesce", "heal": int(it.get("heal", 0)),
			"boon": it.has("boon") or it.has("boons")}
	var f := FileAccess.open("res://tools/vastita_gen/materiali.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t", true))
	f.close()
	print("materiali: %d" % out.size())
	quit()
