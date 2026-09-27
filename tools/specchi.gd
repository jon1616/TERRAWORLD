extends SceneTree
## Gli specchi di liquido dei mondi (voce 118): quanti, di che liquido, in che strato, quanti abbastanza grandi per
## pescare (`WaterBody.MIN_VOLUME`). `-- --semi 10 --da 1`, `--geni sommerso,…` per un genoma fisso.

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var n := 10
	var first := 1
	var genes := []
	for i in args.size():
		if args[i] == "--semi" and i + 1 < args.size():
			n = int(args[i + 1])
		elif args[i] == "--da" and i + 1 < args.size():
			first = int(args[i + 1])
		elif args[i] == "--geni" and i + 1 < args.size():
			genes = Array(args[i + 1].split(","))
	var total := {}
	for sd in range(first, first + n):
		var w := World.new()
		WorldGen.generate(w, sd, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 2, "geni": genes})
		var seen := PackedByteArray()
		seen.resize(w.w * w.h)
		var ok := {}
		var small := 0
		for i in w.w * w.h:
			if seen[i] == 1 or w.liquid[i] & 15 == 0:
				continue
			var b := WaterBody.at(w, Vector2i(i % w.w, i / w.w), true)
			for k in (b["list"] as PackedInt32Array):
				seen[k] = 1
			if not b["ok"]:
				small += 1
				continue
			var key := "%s · %s" % [LiquidsData.TYPES[int(b["type"])]["name"], StrataData.STRATA[int(b["stratum"])]["name"]]
			ok[key] = int(ok.get(key, 0)) + 1
			total[key] = int(total.get(key, 0)) + 1
		print("seme %d: stagni fatti %d · pescabili %s · troppo piccoli %d" % [sd, int(w.gen_notes.get("stagni", 0)), ok, small])
	print("in tutto (%d mondi): %s" % [n, total])
	quit()
