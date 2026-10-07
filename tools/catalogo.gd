extends SceneTree
## Il catalogo di tutti gli oggetti per i generatori Python del piano «La vastità» (Roadmap 48, il commercio): scrive
## `tools/vastita_gen/catalogo.json` con, per ogni oggetto, nome, tipo, forma, materiale, fase (`PhasesData.of`), valore
## in Lumini (`ValueData.value`), se si fabbrica e se è unico, firma, raro o di un boss (quelli non si vendono nei negozi
## comuni). Da rifare quando cambiano gli oggetti:
##     Godot_console.exe --headless --path . --script res://tools/catalogo.gd


func _init() -> void:
	var out := {}
	for id in ItemsData.all():
		var it: Dictionary = ItemsData.all()[id]
		var s := String(id)
		var special: bool = bool(it.get("unique", false)) or it.has("firma") or it.has("raro_di") or it.has("segreto") \
			or s.begins_with("spoglie_") or s.begins_with("trofeo") or s.begins_with("sacchetto_") or String(it.get("kind", "")) == "reliquia"
		out[s] = {"name": String(it.get("name", s)), "kind": String(it.get("kind", "")), "form": String(it.get("form", "")),
			"mat": String(it.get("mat", "")), "phase": PhasesData.of(s), "value": ValueData.value(s),
			"crafted": not RecipesData.making(s).is_empty(), "special": special, "gen": it.has("gen"),
			"place": it.has("place"), "stack": int(it.get("stack", 1))}
	var f := FileAccess.open("res://tools/vastita_gen/catalogo.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "", true))
	f.close()
	print("catalogo: %d" % out.size())
	quit()
