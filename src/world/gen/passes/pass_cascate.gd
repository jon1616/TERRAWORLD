class_name PassCascate
extends GenPass
## Le cascate (voce 482, 9 ott 2026; rimaste fuori dalla Roadmap 60 perché «vogliono una sorgente che non allaghi la
## valle»). Si cercano i posti dove una parete di roccia sta sopra uno specchio d'acqua (laghi delle valli, falde e pozze
## delle caverne): l'acqua che esce dalla parete cade dritta nello specchio. Appunti "cascate"
## [[x della sorgente, y, lato (-1 sinistra, 1 destra), y del pelo dell'acqua, x0, x1 dello specchio]]: in gioco
## `Cascades` fa uscire l'acqua dalla sorgente e toglie quella che arriva sopra il pelo (lo «scarico»), così il livello
## non sale e la valle non si allaga. Si lavora solo sui dati del mondo: le tessere non cambiano.
## Dopo l'Acqua e le Acque di superficie; mai entro `AWAY` colonne dalla partenza (le prove costruiscono lì).

const MIN_FALL := 8                     # righe di caduta almeno
const MAX_FALL := 48
const MIN_POOL := 5                     # celle d'acqua almeno sul pelo dello specchio
const SPACING := 140                    # colonne fra due cascate
const MAX_N := 14
const AWAY := 150


func title() -> String:
	return "Cascate"


func run(w: World, c: GenContext) -> void:
	var out := []
	c.notes["cascate"] = out
	if bool(c.params.get("giardino", false)):
		return
	var W := w.w
	var liq := w.liquid
	var tiles := w.tiles
	var cand := []
	for x in range(2, W - 2):
		if absi(x - w.spawn.x) < AWAY:
			continue
		var y := 2
		while y < w.h - 2:
			var i := y * W + x
			var v := liq[i]
			# il pelo di uno specchio d'acqua: acqua (tipo 0) con sopra aria senza liquido
			if (v & 15) >= 6 and (v >> 4) == 0 and liq[i - W] == 0 and tiles[i - W] == TileDefs.AIR:
				var best := _spring_above(w, x, y)
				if not best.is_empty():
					var span := _span(w, x, y)
					if span.y - span.x + 1 >= MIN_POOL:
						cand.append([int(best[0]), int(best[1]), int(best[2]), y, span.x, span.y, y - int(best[1])])
				# il resto dello specchio, in giù, non interessa
				while y < w.h - 2 and (liq[y * W + x] & 15) > 0:
					y += 1
			y += 1
	# prima le più alte, distanti fra loro
	cand.sort_custom(func(a: Array, b: Array) -> bool: return int(a[6]) > int(b[6]))
	for e in cand:
		if out.size() >= MAX_N:
			break
		var far := true
		for o in out:
			if absi(int(o[0]) - int(e[0])) < SPACING:
				far = false
				break
		if far and w.station_at(Vector2i(int(e[0]), int(e[1]))).is_empty():   # (una volta per cascata: è lineare)
			out.append(e.slice(0, 6))


## La sorgente più alta sopra la cella d'acqua (x, ys): la colonna x è aria libera fino a lei, e accanto c'è una parete
## di roccia alta almeno tre celle. [x della sorgente, y, lato] o [].
static func _spring_above(w: World, x: int, ys: int) -> Array:
	var best := []
	var y := ys - 1
	while y > 2 and ys - y <= MAX_FALL:
		if w.solid(x, y) or w.liq(x, y) > 0:
			break
		if ys - y >= MIN_FALL:
			for side in [-1, 1]:
				var sx: int = x + side
				if _rock(w, sx, y) and _rock(w, sx, y - 1) and _rock(w, sx, y + 1):
					best = [sx, y, -side]          # il lato verso cui esce l'acqua: dalla sorgente alla colonna
		y -= 1
	return best


## Roccia o terra naturale (non un costrutto, non un Sigillo, non una porta).
static func _rock(w: World, x: int, y: int) -> bool:
	if not w.inside(x, y) or not w.solid(x, y):
		return false
	var t := w.tile(x, y)
	return t != TileDefs.COSTRUTTO and t != TileDefs.COSTRUTTO_T and not (t in TileDefs.SEALS.values()) and t != TileDefs.PORTA \
		and t != TileDefs.PORTA_SEM


## Le colonne dello specchio sulla riga del pelo (dove c'è acqua, a destra e a sinistra di x).
static func _span(w: World, x: int, y: int) -> Vector2i:
	var a := x
	while a > 1 and w.liq(a - 1, y) > 0 and w.liq_type(a - 1, y) == 0 and a > x - 200:
		a -= 1
	var b := x
	while b < w.w - 2 and w.liq(b + 1, y) > 0 and w.liq_type(b + 1, y) == 0 and b < x + 200:
		b += 1
	return Vector2i(a, b)
