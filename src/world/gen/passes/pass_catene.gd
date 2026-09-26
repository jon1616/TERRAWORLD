class_name PassCatene
extends GenPass
## Le cripte delle catene di ricerca (voce 69): per ogni tappa aperta del personaggio (`params["catene"]`, da
## `Chains.pending`) i cui geni ci sono tutti nel mondo che nasce, una cripta dei Seminatori nel Sottobosco o nelle
## Caverne: una stanza di pietra lavorata con il **leggio** al centro (la tappa, il premio e l'indizio dopo, letti da
## `Chains`). Niente ingresso: la mappa la segna appena entri nel mondo, e la si raggiunge scavando.
## Appunti: `notes["cripte"]` = [{"catena", "tappa", "leggio"}].

const RW := 13
const RH := 6


func title() -> String:
	return "Cripte"


func run(w: World, c: GenContext) -> void:
	var out := []
	var genes: Array = c.params.get("geni", [])
	var vig := int(c.params.get("vigore", 1))
	for p in c.params.get("catene", []):
		var need: Dictionary = p["need"]
		var ok := vig >= int(need.get("vigore", 0))
		for g in need.get("geni", []):
			if not g in genes:
				ok = false
		if not ok:
			continue
		var o := _place(w, c)
		if o.x >= 0:
			out.append({"catena": String(p["id"]), "tappa": int(p.get("step", 0)), "leggio": o})
	c.notes["cripte"] = out


## Una stanza lontana dalla partenza e dal Cuore, nel Sottobosco o nelle Caverne; il leggio (2×2) sul pavimento.
func _place(w: World, c: GenContext) -> Vector2i:
	var rng := c.rng
	var cuore: Vector2i = c.notes.get("cuore", Vector2i(-9999, -9999))
	for k in 80:
		var x := rng.randi_range(80, w.w - 80 - RW)
		if absi(x - w.w / 2) < 120:
			continue
		var t0 := StrataData.top(1)
		var t1 := StrataData.top(3)
		var y := w.surface[x] + rng.randi_range(t0 + 10, t1 - 10)
		if y + 4 >= w.h or Vector2(Vector2i(x, y) - cuore).length() < 90.0:
			continue
		if _busy(w, x, y):
			continue
		for yy in range(y - RH - 1, y + 2):
			for xx in range(x - 1, x + RW + 1):
				var shell := yy == y - RH - 1 or yy == y + 1 or xx == x - 1 or xx == x + RW
				w.set_tile(xx, yy, TileDefs.PIETRA_SEM if shell else TileDefs.AIR)
				w.walls[yy * w.w + xx] = TileDefs.WALL_SEM
				w.set_decor(xx, yy, 0)
		var o := Vector2i(x + RW / 2 - 1, y - 1)
		w.stations[o] = "leggio"
		return o
	return Vector2i(-1, -1)


## C'è già qualcosa di costruito (stazioni) nel rettangolo della stanza?
func _busy(w: World, x: int, y: int) -> bool:
	for o in w.stations:
		if Rect2i(x - 4, y - RH - 5, RW + 8, RH + 10).has_point(o):
			return true
	return false
