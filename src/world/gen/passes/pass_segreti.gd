class_name PassSegreti
extends GenPass
## I segreti del mondo (voce 95, dati in `SecretsData`): non costruisce nulla, mette in fila i posti nascosti che le
## passate di prima hanno fatto (dagli appunti `notes`, campo `from` di ogni tipo) e li scrive negli appunti
## `notes["segreti"]` = [{"k": tipo, "r": [x, y, larghezza, altezza], "g": grado, "f": trovato}]; `Secrets` li copia
## in `world_meta["segreti"]` alla prima entrata. Non usa il generatore di numeri a caso: non sposta nulla dopo di sé.


func title() -> String:
	return "Segreti"


func run(w: World, c: GenContext) -> void:
	var out := []
	for k in SecretsData.KINDS:
		var kd: Dictionary = SecretsData.KINDS[k]
		for p in _points(c, String(kd["from"])):
			var r: Array = p
			var nm := ""
			if r.size() == 6:                        # luoghi: [x, y, w, h, id del luogo, ""]
				var pid := String(r[4])
				if kd.has("prefix") and not pid.begins_with(String(kd["prefix"])):
					continue
				if kd.has("not_prefix") and pid.begins_with(String(kd["not_prefix"])):
					continue
				r = r.slice(0, 4)
			elif r.size() == 5:                      # voce 97: [x, y, w, h, nome proprio] (anomalie)
				nm = String(r[4])
				r = r.slice(0, 4)
			if r.size() == 2:
				var sz: Array = kd["size"]
				r = [int(r[0]) - int(sz[0]) / 2, int(r[1]) - int(sz[1]) / 2, int(sz[0]), int(sz[1])]
			if int(r[2]) <= 0 or not w.inside(int(r[0]), int(r[1])):
				continue
			var e := {"k": k, "r": r, "g": int(kd["grade"]), "f": false}
			if nm != "":
				e["n"] = nm
			out.append(e)
	c.notes["segreti"] = out


## I punti (o i riquadri) di un tipo di posto, dagli appunti delle passate: [x, y] o [x, y, larghezza, altezza].
static func _points(c: GenContext, from: String) -> Array:
	var out := []
	var n: Variant = c.notes.get(from, null)
	if n == null:
		return out
	match from:
		"nascondigli":
			for e in n:
				var o: Vector2i = e["origin"]
				out.append([o.x, o.y])
		"sigilli":
			for e in n:
				var q: Vector2i = e[1]
				out.append([q.x, q.y])
		"isole":
			for q in n:
				out.append([(q as Vector2i).x, (q as Vector2i).y])
		"luoghi", "camere":
			for e in n:
				out.append([int(e["x"]), int(e["y"]), int(e["w"]), int(e["h"]), String(e["id"]), ""])
		"firma":
			if not (n as Dictionary).is_empty():
				out.append([int(n["x"]), int(n["y"])])
		_:
			# i tipi delle voci 96-97 scrivono già [x, y] o [x, y, w, h]
			for e in n:
				out.append(e)
	return out
