extends SceneTree
func _init() -> void:
	var w := World.new()
	w.generate(20260924)
	var l := LightMap.new()
	l.setup(w)
	var t: Vector2i = w.torches.keys()[1]
	print("torcia ", t)
	for dy in range(-6, 7, 2):
		var s := ""
		for dx in range(-10, 11, 2):
			var x := t.x + dx
			var y := t.y + dy
			var i := y * w.w + x
			s += "%s%.2f " % ["#" if w.solid(x, y) else ".", l.lr[i]]
		print(s)
	var im := l.image.duplicate()
	im.resize(w.w * 4, w.h * 4, Image.INTERPOLATE_NEAREST)
	im.save_png("res://prove/luce.png")
	quit()
