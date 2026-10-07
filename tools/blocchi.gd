extends SceneTree
## Le tessere del mondo, per il confronto con i blocchi di Terraria: ogni tipo con nome, durezza, forza, ciò che lascia,
## se è erba, se fa luce, se lascia passare la luce. Poi i minerali, le gemme, le decorazioni, i costrutti, le stazioni.
## Uscita in prove/blocchi.txt.


func _init() -> void:
	var out := PackedStringArray()
	out.append("== Tessere (tipi) ==")
	var extra: Dictionary = BiomesData.pack("tiles")
	var n := 0
	for t in range(1, TileDefs.TYPES + 1):
		var nm := ""
		var info := ""
		if extra.has(t):
			var d: Dictionary = extra[t]
			nm = String(d.get("name", "?"))
			var flags := []
			for k in ["grass", "glow", "square", "pass", "emit"]:
				if d.has(k):
					flags.append(k)
			info = "pacchetto  drop=%s power=%s %s" % [str(d.get("drop", "")), str(d.get("power", 0)), " ".join(flags)]
		else:
			nm = String(TileDefs.NAMES.get(t, ""))
			if nm == "" and TileDefs._DROP.has(t):
				nm = "(" + String(TileDefs._DROP[t]) + ")"
			if nm == "":
				continue
			info = "base  drop=%s power=%s" % [str(TileDefs._DROP.get(t, "")), str(TileDefs._POWER.get(t, 0))]
		n += 1
		out.append("%3d  %-28s %s" % [t, nm, info])
	out.append("tipi: %d (erbe: %d)" % [n, TileDefs.GRASSES.size()])
	out.append("\n== Vene (ORES) ==")
	for o in TileDefs.ORES:
		out.append("  %d da %d" % [int(o["type"]), int(o["min_depth"])])
	out.append("\n== Metalli della spina e del dopo (cadono scavando la roccia, non sono tessere) ==")
	for mt in SpineData.METALS:
		out.append("  %s (grado %d)" % [mt, int(SpineData.METALS[mt]["tier"])])
	out.append("\n== Decorazioni ==\n  tipi: %d" % TileDefs.DECOR_COUNT)
	out.append("\n== Costrutti ==\n  forme %d × materiali %d" % [BuildData.FORMS.size(), BuildData.MATERIALS.size()])
	out.append("\n== Stazioni ==\n  %d" % StationsData.STATIONS.size())
	var roles := {}
	for s in StationsData.STATIONS:
		var r := str(StationsData.role(s))
		roles[r] = int(roles.get(r, 0)) + 1
	out.append("  ruoli: " + str(roles))
	out.append("\n== Liquidi ==\n  " + str(LiquidsData.TYPES.size()))
	var f := FileAccess.open("res://prove/blocchi.txt", FileAccess.WRITE)
	f.store_string("\n".join(out))
	print("\n".join(out))
	quit()
