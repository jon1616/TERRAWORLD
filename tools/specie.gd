extends SceneTree
## L'elenco delle specie per i generatori Python del piano «La vastità» (voce 395): scrive
## `tools/vastita_gen/specie.json` con, per ogni specie che può lasciare un raro, ciò che serve a sceglierlo (nome, strati,
## risvegliata, cielo, elemento, peso, comportamenti). Da rifare quando si aggiungono specie:
##     Godot_console.exe --headless --path . --script res://tools/specie.gd


func _init() -> void:
	var out := {}
	for id in CreaturesData.CREATURES:
		var s := String(id)
		var d: Dictionary = CreaturesData.CREATURES[id]
		if bool(d.get("boss", false)) or d.has("lord") or String(d.get("great", "")) != "" or d.has("perduto_boss") \
				or s.begins_with("capo_") or s.begins_with("sfidante_") or s.begins_with("evento_") or s.ends_with("_amico") \
				or d.has("lost_boss") or int(d.get("weight", 0)) <= 0 and not d.get("awake", false) and not d.has("sky"):
			continue
		var strata: Array = d.get("strata", [])
		out[s] = {"name": String(d.get("name", s)), "strata": strata, "awake": bool(d.get("awake", false)),
			"sky": d.has("sky"), "elem": String(d.get("elem", "")), "weight": int(d.get("weight", 0)),
			"hp": int(d.get("hp", 0)), "bh": d.get("behaviors", []), "perduto": d.has("perduto"),
			"water": bool(d.get("water", false))}
	var f := FileAccess.open("res://tools/vastita_gen/specie.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t", true))
	f.close()
	print("specie: %d" % out.size())
	quit()
