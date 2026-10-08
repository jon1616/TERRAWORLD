extends SceneTree
## La scheda di una creatura per il generatore di prompt (`tools/prompt_creatura.py`, 8 ott 2026): tutto ciò che il
## gioco sa di lei (dati, piano del corpo, comportamenti, famiglia, dove vive) e ciò che si vede del disegno di oggi
## (misura, colori più usati, parti che brillano). Scrive arte_ia/creature/schede/<id>.json e il riferimento
## arte_ia/creature/riferimenti/<id>.png (i fotogrammi di oggi ingranditi ×8).
##   Godot_console.exe --headless --path . --script res://tools/scheda_creatura.gd -- spinoriccio
##   … -- --coda    l'ordine di comparsa di tutte le creature da disegnare → arte_ia/creature/schede/coda.json

const OUT := "res://arte_ia/creature/"


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT + "schede"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT + "riferimenti"))
	if "--coda" in args:
		_coda()
	else:
		for id in args:
			_scheda(String(id))
	quit()


func _scheda(id: String) -> void:
	if not CreaturesData.CREATURES.has(id) and CreaturesData.get_data(id).is_empty():
		print("ATTENZIONE: creatura sconosciuta %s" % id)
		return
	var cd: Dictionary = CreaturesData.get_data(id)
	var art: Array = cd.get("art", ["?", 0])
	CreatureArt.code_only = true                # il disegno del codice, anche se ha già le pose di Nano Banana
	var fr: Dictionary = CreatureArt.frames(String(art[0]), int(art[1]))
	CreatureArt.code_only = false
	if cd.has("art_mods"):
		fr = VariantArt.apply(fr, cd["art_mods"])
	var frames: Array = fr["frames"]
	var im0: Image = (frames[0] as Image) if frames[0] is Image else (frames[0] as Texture2D).get_image()
	var fd: Dictionary = FamiliesData.FAMILIES.get(FamiliesData.family_of(id), {})
	var s := {
		"id": id, "name": cd.get("name", id), "base": CreaturesData.base_of(id), "shape": art[0], "variant": art[1],
		"w": im0.get_width(), "h": im0.get_height(), "frames": frames.size(),
		"hp": cd.get("hp", 0), "damage": cd.get("damage", 0), "speed": cd.get("speed", 60), "half": cd.get("half", [8, 8]),
		"behaviors": cd.get("behaviors", []), "fury": cd.get("fury", []), "p": cd.get("p", {}),
		"fly": cd.get("fly", false), "roll": cd.get("roll", false), "boss": cd.get("boss", false),
		"chief": cd.get("chief", false), "lord": cd.get("lord", false), "great": cd.get("great", false),
		"docile": cd.get("docile", false), "night": cd.get("night", false), "glow": cd.get("glow", false),
		"elem": cd.get("elem", ""), "weak": cd.get("weak", []), "biomes": cd.get("biomes", []),
		"strata": cd.get("strata", []), "under": cd.get("under", []), "sky": cd.get("sky", []),
		"water": cd.get("water", false), "awake": cd.get("awake", false), "season": cd.get("season", ""),
		"weather": cd.get("weather", ""), "disguise": cd.get("disguise", false), "upside": cd.get("upside", false),
		"art_mods": _plain(cd.get("art_mods", {})), "body": _plain(cd.get("body", {})),
		"family": FamiliesData.family_of(id), "role": fd.get("role", ""), "family_name": fd.get("name", ""),
		"palette": _palette(frames), "glow_cols": _palette(fr.get("glow", []), 4),
	}
	var f := FileAccess.open(ProjectSettings.globalize_path(OUT + "schede/%s.json" % id), FileAccess.WRITE)
	f.store_string(JSON.stringify(s, "\t"))
	f.close()
	_reference(frames, id)
	print("scheda: %s (%s, %dx%d, %d fotogrammi)" % [id, s["name"], s["w"], s["h"], s["frames"]])


## Un valore senza Color (il JSON non li conosce): i colori diventano «#rrggbb».
func _plain(v: Variant) -> Variant:
	if v is Color:
		return "#" + (v as Color).to_html(false)
	if v is Dictionary:
		var o := {}
		for k in v:
			o[k] = _plain(v[k])
		return o
	if v is Array:
		return (v as Array).map(func(x: Variant) -> Variant: return _plain(x))
	return v


## I colori più usati dei fotogrammi (senza il contorno quasi nero), dal più scuro.
func _palette(frames: Array, n := 7) -> Array:
	var count := {}
	for t in frames:
		var im: Image = (t as Image) if t is Image else (t as Texture2D).get_image()
		if im == null:
			continue
		for y in im.get_height():
			for x in im.get_width():
				var c := im.get_pixel(x, y)
				if c.a < 0.5 or c.get_luminance() < 0.06:
					continue
				var key := Color(snappedf(c.r, 0.04), snappedf(c.g, 0.04), snappedf(c.b, 0.04)).to_html(false)
				count[key] = int(count.get(key, 0)) + 1
	var keys := count.keys()
	keys.sort_custom(func(a: String, b: String) -> bool: return count[a] > count[b])
	var top: Array = keys.slice(0, n)
	top.sort_custom(func(a: String, b: String) -> bool: return Color(a).get_luminance() < Color(b).get_luminance())
	return top.map(func(k: String) -> String: return "#" + k)


func _reference(frames: Array, id: String) -> void:
	var k := 8
	var w := 0
	var h := 0
	for t in frames:
		var im: Image = (t as Image) if t is Image else (t as Texture2D).get_image()
		w += im.get_width() * k + 16
		h = maxi(h, im.get_height() * k)
	var out := Image.create_empty(w + 16, h + 32, false, Image.FORMAT_RGBA8)
	out.fill(Color("#181620"))
	var x := 16
	for t in frames:
		var im: Image = ((t as Image) if t is Image else (t as Texture2D).get_image()).duplicate()
		im.convert(Image.FORMAT_RGBA8)
		im.resize(im.get_width() * k, im.get_height() * k, Image.INTERPOLATE_NEAREST)
		out.blend_rect(im, Rect2i(Vector2i.ZERO, im.get_size()), Vector2i(x, 16))
		x += im.get_width() + 16
	out.save_png(ProjectSettings.globalize_path(OUT + "riferimenti/%s.png" % id))


## L'ordine in cui il giocatore incontra le creature: prima la superficie di giorno nei biomi più comuni, poi la notte,
## poi gli strati sotto, il cielo, i mondi dopo il Risveglio; i boss subito dopo le creature del loro posto.
func _coda() -> void:
	var rows := []
	var first_biomes := ["foresta", "palude", "ambra", "brina"]
	for id in CreaturesData.CREATURES:
		if "~" in String(id):
			continue
		var cd: Dictionary = CreaturesData.CREATURES[id]
		var sv: Variant = cd.get("strata", [])
		var strata: Array = sv if sv is Array else []
		var st := 9
		for s in strata:
			st = mini(st, int(s))
		var sky: Variant = cd.get("sky", [])
		if (sky is Array and not (sky as Array).is_empty()) or (sky is String and sky != "") or sky is Dictionary:
			st = mini(st, 1)
		var bv: Variant = cd.get("biomes", [])
		var biomes: Array = bv if bv is Array else []
		var common := biomes.is_empty() or biomes.any(func(b: Variant) -> bool: return String(b) in first_biomes)
		# le creature che chiedono un'occasione (eclissi, stagione, tempo, un luogo, la firma del mondo) dopo le altre
		var cond: bool = cd.get("eclipse", false) or str(cd.get("season", "")) != "" or str(cd.get("weather", "")) != "" 			or cd.get("lord", false) or cd.get("great", false) or String(id).begins_with("firma_")
		var key := [1 if cd.get("awake", false) else 0, st, 1 if cond else 0, 0 if common else 1,
			1 if cd.get("night", false) else 0,
			-int(cd.get("weight", 0))]
		var art: Array = cd.get("art", ["?", 0])
		rows.append({"id": id, "name": cd.get("name", id), "key": key, "shape": art[0], "variant": art[1],
			"boss": cd.get("boss", false), "chief": cd.get("chief", false)})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		for i in (a["key"] as Array).size():
			if a["key"][i] != b["key"][i]:
				return a["key"][i] < b["key"][i]
		return String(a["id"]) < String(b["id"]))
	var f := FileAccess.open(ProjectSettings.globalize_path(OUT + "schede/coda.json"), FileAccess.WRITE)
	f.store_string(JSON.stringify(rows, "\t"))
	f.close()
	print("coda: %d creature" % rows.size())
