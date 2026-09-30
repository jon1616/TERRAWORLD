extends SceneTree
## Le ricette del pannello «Creare» per categoria (`CraftCatsData`) e, dentro ognuna, per tipo e banco: serve a vedere
## se una categoria è troppo piena o mescola cose diverse. → prove/categorie_creare.txt


func _init() -> void:
	var by_cat := {}
	var total := 0
	for r in RecipesData.all():
		var out := String(r["out"])
		var it := ItemsData.get_item(out)
		var cat := "%02d %s" % [CraftCatsData.of(out), String(CraftCatsData.CATS[CraftCatsData.of(out)][1])]
		var kind := CraftCatsData.sub_of(r)
		if not by_cat.has(cat):
			by_cat[cat] = {}
		by_cat[cat][kind] = int(by_cat[cat].get(kind, 0)) + 1
		total += 1
	var lines := ["Ricette: %d" % total, ""]
	var cats := by_cat.keys()
	cats.sort()
	for c in cats:
		var n := 0
		for k in by_cat[c]:
			n += int(by_cat[c][k])
		lines.append("%s: %d" % [c, n])
		var ks: Array = by_cat[c].keys()
		ks.sort_custom(func(a, b) -> bool: return int(by_cat[c][a]) > int(by_cat[c][b]))
		var parts := []
		for k in ks:
			parts.append("%s %d" % [k, int(by_cat[c][k])])
		lines.append("    " + ", ".join(parts))
	var f := FileAccess.open("res://prove/categorie_creare.txt", FileAccess.WRITE)
	f.store_string("\n".join(lines) + "\n")
	print("\n".join(lines))
	quit()
