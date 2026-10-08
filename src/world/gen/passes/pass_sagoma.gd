class_name PassSagoma
extends GenPass
## La sagoma del mondo (voce 459, Roadmap 59 «Mondi che non si somigliano»): la grande scala del profilo, scelta dal
## genoma (`WorldShapesData`). Dopo i Biomi, che hanno già dato a ogni tratto le sue colline; tocca solo `World.surface`
## (le tessere le mette `PassStrati`). Gli strati si misurano dalla superficie: dove la terra scende, scendono con lei,
## quindi nessuna sagoma abbassa la terra più di quanto il Fondo può cedere (`MAX_DROP`).
## - **canyon**: una gola larga 230-330 colonne a 680-1080 dalla partenza, a gradoni di `ledge` righe (si scende
##   saltando di gradino in gradino; su ogni gradino una liana la mette `PassPilastri`, per risalire);
## - **terrazze**: le colline più alte e tagliate a ripiani; tra un ripiano e l'altro una scala di gradini da 3;
## - **sprofondato**: la terra in mezzo scende di 45-65 righe (il cielo più alto) e a 300-420 colonne da ogni bordo si
##   alza una cresta di 110-160 righe: una conca chiusa da due muraglie (verso i bordi la terra ridiscende al mare).
## La partenza resta piana. Appunti "sagoma" (l'id) e "canyon" [x0, x1, profondità].

const MAX_DROP := 110


func title() -> String:
	return "Sagoma"


func run(w: World, c: GenContext) -> void:
	var shape := WorldShapesData.of(c.genes())
	c.notes["sagoma"] = shape
	if bool(c.params.get("giardino", false)):
		return
	var d: Dictionary = WorldShapesData.SHAPES[shape]
	match shape:
		"canyon":
			_canyon(w, c, d)
		"terrazze":
			_terraces(w, c, d)
		"sprofondato":
			_sunk(w, c, d)


func _canyon(w: World, c: GenContext, d: Dictionary) -> void:
	var side := -1 if c.rng.randf() < 0.5 else 1
	var wd := c.rng.randi_range(int(d["w"][0]), int(d["w"][1]))
	var cx := w.spawn.x + side * c.rng.randi_range(int(d["gap"][0]), int(d["gap"][1]))
	cx = clampi(cx, wd / 2 + 280, w.w - wd / 2 - 280)
	var depth := mini(c.rng.randi_range(int(d["depth"][0]), int(d["depth"][1])), MAX_DROP)
	var ledge := int(d["ledge"])
	var x0 := cx - wd / 2
	var x1 := cx + wd / 2
	var rim := float(w.surface[x0] + w.surface[x1]) * 0.5
	var floor_y := int(rim) + depth
	var nz := c.noise("canyon", 0.05, 2)
	# le pareti: gradini di `ledge` righe larghi 4-7 colonne, dal bordo al fondo; il fondo piano, con un letto ondulato
	var steps := ceili(float(depth) / ledge)
	var run_w := 0
	var xs := []
	for k in steps:
		var sw := c.rng.randi_range(4, 7)
		xs.append(sw)
		run_w += sw
	for x in range(x0, x1):
		var from_edge := mini(x - x0, x1 - 1 - x)
		var y: int = floor_y + int(nz.get_noise_1d(x) * 2.0)
		if from_edge < run_w:
			# su quale gradino è questa colonna
			var acc := 0
			for k in steps:
				acc += int(xs[k])
				if from_edge < acc:
					y = int(rim) + mini((k + 1) * ledge, depth)
					break
		w.surface[x] = maxi(w.surface[x], y)
	c.notes["canyon"] = [x0, x1, depth]


func _terraces(w: World, c: GenContext, d: Dictionary) -> void:
	var step := c.rng.randi_range(int(d["step"][0]), int(d["step"][1]))
	var base := PassTerreno.base_of(w, c)
	var k := float(d["hills"])
	var flat := Vector2i(w.spawn.x - 8, w.spawn.x + 8)
	var s0 := w.surface[w.spawn.x]
	for x in w.w:
		var s := base + (float(w.surface[x]) - base) * k
		s = clampf(s, base - 140.0, base + MAX_DROP * 0.6)
		w.surface[x] = int(base + roundf((s - base) / step) * step)
	for x in range(flat.x, flat.y + 1):
		w.surface[x] = int(base + roundf((s0 - base) / step) * step)
	# le scale: al più 3 righe da una colonna all'altra (un salto), in avanti e all'indietro
	for pass_i in 2:
		var rng_x := range(1, w.w) if pass_i == 0 else range(w.w - 2, -1, -1)
		for x in rng_x:
			var prev: int = w.surface[x - 1] if pass_i == 0 else w.surface[x + 1]
			if w.surface[x] < prev - 3:
				w.surface[x] = prev - 3
	c.notes["terrazze"] = step


func _sunk(w: World, c: GenContext, d: Dictionary) -> void:
	var depth := c.rng.randi_range(int(d["depth"][0]), int(d["depth"][1]))
	var rims := [c.rng.randi_range(int(d["rim"][0]), int(d["rim"][1])), c.rng.randi_range(int(d["rim"][0]), int(d["rim"][1]))]
	var ridge := c.rng.randi_range(int(d["ridge"][0]), int(d["ridge"][1]))
	var nz := c.noise("creste", 0.04, 3)
	for x in w.w:
		var left := x < w.w / 2
		var e := x if left else w.w - 1 - x
		var rim: int = rims[0] if left else rims[1]
		# dentro la conca la terra scende; sulla cresta sale (una campana larga ~180 colonne, frastagliata)
		var t := clampf(float(e - rim) / 160.0, 0.0, 1.0)
		var down := depth * t * t * (3.0 - 2.0 * t)
		var r := absf(e - rim) / 90.0
		var up := ridge * exp(-r * r) * (0.85 + nz.get_noise_1d(x) * 0.3)
		w.surface[x] += int(down - up)
	c.notes["sprofondato"] = [depth, ridge, rims]
