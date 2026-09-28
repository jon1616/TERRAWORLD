class_name PassStele
extends GenPass
## Le stele dei Seminatori (voce 68): una stele di pietra con una frase nella loro lingua, nelle rovine (una per
## rovina, se c'è posto) e due in superficie vicino alla partenza. Quasi tutte indicano un luogo vero di questo mondo
## (un Sigillo, un reliquiario, la firma, il Cuore, la tana di un Custode) dicendo dove, rispetto alla stele; le altre
## raccontano un pezzo di storia (`LanguageData.LORE`). Appunti: `notes["stele"]` = {"x,y": {"words", "hint"}}; il
## gioco li copia in `world_meta["stele"]` (`Language`).

const HINT_CHANCE := 0.72


func title() -> String:
	return "Stele"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var targets := _targets(c)
	var used := {}
	var out := {}
	var spots: Array[Vector2i] = []
	var obs := []                                           # Roadmap 17: le stele degli osservatori del cielo
	for ob in c.notes.get("osservatori", []):
		obs.append(Vector2i(int(ob[0]) + 3, int(ob[1]) - 3))
	for p in c.notes.get("rovine", []):
		var o := Vector2i(p.x + 1, p.y - 2)            # a sinistra dello scrigno, sul pavimento della stanza
		if _fits(w, o):
			spots.append(o)
	# due in superficie, vicino alla partenza: le prime parole si leggono subito
	for side in [-1, 1]:
		for k in 40:
			var x: int = clampi(w.w / 2 + side * rng.randi_range(40, 140), 10, w.w - 12)
			var o := Vector2i(x, w.surface[x] - 3)
			if w.surface[x + 1] == w.surface[x] and _fits(w, o):
				spots.append(o)
				break
	for o in spots:
		w.stations[o] = "stele"
		var e := {"words": [], "hint": []}
		if not targets.is_empty() and rng.randf() < HINT_CHANCE and o.y > w.surface[o.x] + 4:
			var best := -1
			var bd := 1e9
			for i in targets.size():
				if used.has(i):
					continue
				var d := Vector2(targets[i][1] - o).length()
				if d < bd:
					bd = d
					best = i
			if best >= 0:
				used[best] = true
				e = sentence(targets[best], o)
		if (e["words"] as Array).is_empty():
			e["words"] = (LanguageData.LORE[rng.randi_range(0, LanguageData.LORE.size() - 1)] as Array).duplicate()
		# Roadmap 17: lo strato della lingua. Il mondo del Seme Nero parla la lingua nera; gli osservatori del cielo e, nei
		# mondi di vigore 3 o più, quasi metà delle stele la lingua antica (frasi di storia: niente luogo indicato)
		var vig := int(c.params.get("vigore", 1))
		if bool(c.params.get("nero", false)) and rng.randf() < 0.8:
			e = {"words": (LanguageData.LORE_BLACK[rng.randi_range(0, LanguageData.LORE_BLACK.size() - 1)] as Array).duplicate(), "hint": []}
		elif o in obs or (vig >= 3 and rng.randf() < (0.6 if vig >= 5 else 0.45)):
			e = {"words": (LanguageData.LORE_ANCIENT[rng.randi_range(0, LanguageData.LORE_ANCIENT.size() - 1)] as Array).duplicate(), "hint": []}
		out["%d,%d" % [o.x, o.y]] = e
	c.notes["stele"] = out


## Tutti i luoghi che una stele può indicare: [tipo, cella, nome, parola del tipo].
func _targets(c: GenContext) -> Array:
	var t := []
	for s in c.notes.get("sigilli", []):
		if LanguageData.SEAL_WORD.has(String(s[0])):
			t.append(["sigillo", s[1], "Sigillo", LanguageData.SEAL_WORD[String(s[0])]])
	for n in c.notes.get("nascondigli", []):
		t.append(["reliquiario", n["origin"], "Reliquiario", ""])
	var f: Dictionary = c.notes.get("firma", {})
	if not f.is_empty():
		t.append(["firma", Vector2i(int(f["x"]), int(f["y"])), "La firma del mondo", ""])
	if c.notes.has("cuore"):
		t.append(["cuore", c.notes["cuore"], "Il Cuore del mondo", ""])
	for lg in c.notes.get("luoghi", []):                    # voce 70: i luoghi scritti a mano
		t.append(["luogo", Vector2i(int(lg["x"]) + int(lg["w"]) / 2, int(lg["y"]) + int(lg["h"]) / 2), "Un luogo dei Seminatori", ""])
	var dens: Dictionary = c.notes.get("tane", {})
	for k in dens:
		t.append(["tana", dens[k], "Tana di un Custode", ""])
	return t


## La frase di una stele che indica un luogo, con dove si trova rispetto alla stele.
static func sentence(tg: Array, from: Vector2i) -> Dictionary:
	var tmpl: Array = LanguageData.HINTS[String(tg[0])][0]
	var to: Vector2i = tg[1]
	var dx := to.x - from.x
	var dy := to.y - from.y
	var words := []
	for wd in tmpl:
		match String(wd):
			"{kind}":
				words.append(String(tg[3]))
			"{deep}":
				words.append("sotto" if dy > 15 else ("sopra" if dy < -15 else "qui"))
			"{dir}":
				if dx > 25:
					words.append("alba")
				elif dx < -25:
					words.append("tramonto")
			"{dist}":
				var d := Vector2(to - from).length()
				if d < 120.0:
					words.append("vicino")
				elif d < 500.0:
					words.append("lontano")
				else:
					words.append_array(["molto", "lontano"])
			_:
				words.append(String(wd))
	return {"words": words, "hint": [to.x, to.y, String(tg[2])]}


func _fits(w: World, o: Vector2i) -> bool:
	for y in range(o.y, o.y + 3):
		for x in range(o.x, o.x + 2):
			if not w.inside(x, y) or w.tile(x, y) != TileDefs.AIR or w.station_at(Vector2i(x, y)).size() > 0:
				return false
	return w.solid(o.x, o.y + 3) and w.solid(o.x + 1, o.y + 3)
