extends SceneTree
## L'elenco di tutti i geni dei Semi di mondo, per categoria (nome, rarità, vigore minimo, come si ottiene, cosa fa)
## → prove/geni.txt. Uso: Godot_console.exe --headless --path . --script res://tools/geni.gd


func _init() -> void:
	var out := PackedStringArray()
	var tot := 0
	for cat in GenesData.CATEGORIES:
		var list: Array = GenesData.of_cat(String(cat))
		tot += list.size()
		out.append("\n== %s (%d) — si trova in: %s" % [GenesData.CAT_INFO[cat]["name"], list.size(), GenesData.CAT_INFO[cat]["where"]])
		for g in list:
			var d := GenesData.info(String(g))
			var how := ""
			if d.has("only"):
				how = " [solo %s]" % String(d["only"])
			if d.has("combo"):
				how += " [combo %s + %s]" % [GenesData.info(String(d["combo"][0])).get("name", d["combo"][0]),
					GenesData.info(String(d["combo"][1])).get("name", d["combo"][1])]
			out.append("%s\t%s\tvigore %d%s\t%s" % [String(d.get("name", g)), GenesData.RARITY[int(d.get("rar", 0))]["name"],
				int(d.get("vmin", 0)), how, String(d.get("desc", ""))])
	out.insert(0, "Geni: %d" % tot)
	var f := FileAccess.open("res://prove/geni.txt", FileAccess.WRITE)
	f.store_string("\n".join(out))
	print("geni: %d → prove/geni.txt" % tot)
	quit()
