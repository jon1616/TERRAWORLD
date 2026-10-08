class_name PassMari
extends GenPass
## I mari ai bordi (voce 461, Roadmap 59; scelta dell'utente: «mari ai bordi in quasi tutte» le sagome, non nel guscio e
## nei pilastri, `WorldShapesData.has_sea`). A ogni bordo del mondo, per 150-250 colonne, la terra scende in una spiaggia
## di `BEACH` colonne fino al livello del mare, poi il fondale cala verso il bordo (40-60 righe d'acqua), con uno o due
## isolotti che spuntano. Dopo la Sagoma, prima degli Strati: tocca solo la superficie; l'acqua la versa `PassAcqua`
## (dopo gli alberi: niente alberi sott'acqua) e lì nasce anche il relitto con il suo scrigno. Il posto del mare è preso
## (`claim`), così le strutture di superficie non ci finiscono dentro. Appunti "mari" [[x0, x1, livello], ...].

const W := [150, 250]
const BEACH := 46
const DEPTH := [40, 60]


func title() -> String:
	return "Mari"


func run(w: World, c: GenContext) -> void:
	c.notes["mari"] = []
	if bool(c.params.get("giardino", false)) or not WorldShapesData.has_sea(c.genes()):
		return
	var nz := c.noise("fondale", 0.04, 2)
	var seas := []
	for side in [-1, 1]:
		var sw := c.rng.randi_range(W[0], W[1])
		var inner := sw if side < 0 else w.w - 1 - sw          # la prima colonna di spiaggia, dalla parte di terra
		var level := int(w.surface[inner]) + 4                  # il livello del mare: poco sotto la riva
		var depth := c.rng.randi_range(DEPTH[0], DEPTH[1])
		for k in sw + 1:
			var x := inner - k if side < 0 else inner + k
			if x < 0 or x >= w.w:
				continue
			var y: float
			if k < BEACH:
				# la spiaggia: dalla riva al livello del mare + 3, in dolce discesa
				var t := float(k) / BEACH
				y = lerpf(float(w.surface[inner]), float(level + 3), t * t * (3.0 - 2.0 * t))
			else:
				var t := clampf(float(k - BEACH) / 60.0, 0.0, 1.0)
				y = level + 3 + (depth - 3) * t * t * (3.0 - 2.0 * t) + nz.get_noise_1d(x) * 4.0
			w.surface[x] = maxi(int(y), int(w.surface[x]))
		# gli isolotti: una o due gobbe che spuntano dall'acqua
		for i in c.rng.randi_range(1, 2):
			var ik := c.rng.randi_range(BEACH + 30, sw - 20)
			var iw := c.rng.randi_range(20, 34)
			var rise := depth + c.rng.randi_range(2, 6)
			for d in range(-iw, iw + 1):
				var k := ik + d
				var x := inner - k if side < 0 else inner + k
				if x < 1 or x >= w.w - 1:
					continue
				var t := 1.0 - absf(float(d)) / iw
				w.surface[x] = mini(w.surface[x], level + 3 + depth - int(rise * sqrt(t)))
		var x0 := 0 if side < 0 else inner
		var x1 := inner if side < 0 else w.w
		c.claim(Rect2i(x0, level - 40, x1 - x0, depth + 46), "mare")
		seas.append([x0, x1, level])
	c.notes["mari"] = seas
