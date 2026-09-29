class_name PassMeraviglie
extends GenPass
## Le meraviglie (Roadmap 23, voce 237; dati in `WondersData`): da due a tre per mondo, scelte a caso con i pesi (×4 se
## il mondo ha un gene che le chiama), mai due uguali. Ognuna ha la sua forma (le funzioni `_b_<id>` di
## `WonderShapes`) e al centro la stazione `cuore_meraviglia`. Negli appunti: `notes["meraviglie"]` =
## [{"k": id, "c": [x, y] (il centro, per vederla), "o": [x, y] (il cuore)}], che `Wonders` copia nel mondo.

const TRIES := 120


func title() -> String:
	return "Meraviglie"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var genes: Array = c.params.get("geni", [])
	var want := WondersData.MIN_COUNT + (1 if int(c.params.get("vigore", 1)) >= WondersData.EXTRA_VIGOR else 0)
	var out := []
	var used := {}
	while out.size() < want:                     # una forma che non trova posto lascia il turno a un'altra
		var k := _pick(rng, genes, used)
		if k == "":
			break
		used[k] = true
		for t in TRIES:
			var r := _try(w, c, k, rng)
			if not r.is_empty():
				out.append(r)
				break
	c.notes["meraviglie"] = out


func _pick(rng: RandomNumberGenerator, genes: Array, used: Dictionary) -> String:
	var tot := 0.0
	var ws := {}
	for k in WondersData.WONDERS:
		if used.has(k):
			continue
		var d: Dictionary = WondersData.WONDERS[k]
		var wt := float(d["weight"])
		for g in d.get("genes", []):
			if g in genes:
				wt *= 4.0
				break
		ws[k] = wt
		tot += wt
	var x := rng.randf() * tot
	for k in ws:
		x -= float(ws[k])
		if x <= 0.0:
			return String(k)
	return "" if ws.is_empty() else String(ws.keys()[0])


## Prova a costruirla in un punto a caso: {} se il posto non va.
func _try(w: World, c: GenContext, k: String, rng: RandomNumberGenerator) -> Dictionary:
	var d: Dictionary = WondersData.WONDERS[k]
	var sz: Vector2i = WonderShapes.SIZE[k]
	var x := rng.randi_range(80 + sz.x, w.w - 81 - sz.x)
	if absi(x - w.spawn.x) < 120:
		return {}
	var y: int
	if str(d["where"]) == "sup":
		y = w.surface[x]
	else:
		var st := int(d["where"])
		var top := w.surface[x] + StrataData.top(st) + sz.y
		var bot := w.surface[x] + (StrataData.top(st + 1) if st + 1 < StrataData.STRATA.size() else w.h - w.surface[x] - 20) - sz.y
		if bot <= top:
			return {}
		y = rng.randi_range(top, bot)
	var box := Rect2i(x - sz.x, y - sz.y, 2 * sz.x + 1, 2 * sz.y + 1)
	if box.position.y < 5 or box.end.y >= w.h - 5 or not c.is_free(box):
		return {}
	if str(d["where"]) != "sup" and not WonderShapes.solid_enough(w, box):
		return {}
	var heart: Vector2i = WonderShapes.build(k, w, Vector2i(x, y), rng)
	if heart.x < 0:
		return {}
	w.stations[heart] = "cuore_meraviglia"
	c.claim(box, "meraviglia")
	return {"k": k, "c": [x, y], "o": [heart.x, heart.y]}
