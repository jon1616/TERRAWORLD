extends SceneTree
## Voce 105: le forme disegnate (arte/forme/) in una tabella forma × materiale, ingrandita ×4, in prove/arte_forme.png:
## si guarda se la colorazione con le tavolozze dei materiali funziona. Senza finestra:
## Godot_console.exe --headless --path . --script res://tools/foglio_forme.gd [-- --solo=spada,elmo]

const MATERIALI := ["radicite", "legnoferro", "ambra", "cristallo", "brace", "vuotite", "lega:radicite:cristallo"]
const Z := 4


func _init() -> void:
	var forme: Array[String] = []
	for f in DirAccess.get_files_at("res://arte/forme"):
		if f.ends_with(".png"):
			forme.append(f.get_basename())
	forme.sort()
	# `-- --solo=a,b`: solo alcune forme (il foglio intero è lungo)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--solo="):
			forme = forme.filter(func(f: String) -> bool: return f in arg.trim_prefix("--solo=").split(","))
	var cell := 16 * Z + 8
	var out := Image.create(cell * MATERIALI.size() + 8, cell * forme.size() + 8, false, Image.FORMAT_RGBA8)
	out.fill(Color("#241a2c"))
	for r in forme.size():
		for c in MATERIALI.size():
			var im := ItemIcons.make(forme[r], MATERIALI[c])
			im.resize(16 * Z, 16 * Z, Image.INTERPOLATE_NEAREST)
			out.blend_rect(im, Rect2i(0, 0, 16 * Z, 16 * Z), Vector2i(8 + c * cell, 8 + r * cell))
	out.save_png(ProjectSettings.globalize_path("res://prove/arte_forme.png"))
	print("prove/arte_forme.png: %d forme × %d materiali (colonne: %s)" % [forme.size(), MATERIALI.size(), ", ".join(MATERIALI)])
	quit()
