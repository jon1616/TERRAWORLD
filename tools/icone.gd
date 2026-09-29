extends SceneTree
## Tutte le icone degli oggetti come le vede il gioco (`ItemIcons.of`), in un atlante 16×16 (prove/icone/atlante.png,
## 64 per riga) con l'indice (prove/icone/indice.txt: n|id|nome|forma|materiale). Lo legge `tools/icone_simili.py`, che
## cerca le icone identiche o quasi (29 set 2026: giocando, l'utente ne ha viste alcune uguali). Senza finestra:
## Godot_console.exe --headless --path . --script res://tools/icone.gd

const PER_ROW := 64


func _init() -> void:
	var ids: Array = ItemsData.all().keys()
	ids.sort()
	var rows := (ids.size() + PER_ROW - 1) / PER_ROW
	var atlas := Image.create(PER_ROW * 16, rows * 16, false, Image.FORMAT_RGBA8)
	var lines := PackedStringArray()
	for i in ids.size():
		var id := String(ids[i])
		var it: Dictionary = ItemsData.get_item(id)
		var im := ItemIcons.of(id)
		if im.get_format() != Image.FORMAT_RGBA8:
			im.convert(Image.FORMAT_RGBA8)
		atlas.blit_rect(im, Rect2i(0, 0, 16, 16), Vector2i((i % PER_ROW) * 16, (i / PER_ROW) * 16))
		var ic: Array = it.get("icon", ["", ""])
		lines.append("%d|%s|%s|%s|%s" % [i, id, String(it.get("name", id)), str(ic[0]), str(ic[1]) if ic.size() > 1 else ""])
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prove/icone"))
	atlas.save_png(ProjectSettings.globalize_path("res://prove/icone/atlante.png"))
	var f := FileAccess.open(ProjectSettings.globalize_path("res://prove/icone/indice.txt"), FileAccess.WRITE)
	f.store_string("\n".join(lines))
	f.close()
	print("icone: %d oggetti in prove/icone/atlante.png" % ids.size())
	quit()
