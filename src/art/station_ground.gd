class_name StationGround
extends RefCounted
## Le stazioni appoggiate davvero al terreno (29 set 2026, l'utente: «molte cose posate sul terreno sembrano staccate
## o non appoggiano in modo naturale»). Tre cose insieme:
## - `sink`: la stazione si disegna qualche pixel più in basso, dentro il terreno, che ha il bordo morbido e irregolare:
##   la base copre la superficie invece di stare sopra una linea che non c'è (la collisione non cambia);
## - `shadow`: un'ombra di contatto sotto la base, larga quanto lei, che si vede ai lati dell'oggetto sul terreno;
## - il contorno scuro sul lato di sotto non c'è più nei disegni di Nano Banana (`tools/tavola.py`, `senza_contorno_sotto`).

const SINK := 2                        # pixel dentro il terreno
const SHADOW_H := 3                    # righe dell'ombra
const SHADOW_A := 0.34                 # quanto è scura al centro

## Chi non affonda: le porte stanno nel vano della parete, non sul terreno.
const NO_SINK := ["porta", "porta_aperta", "porta_sem"]


static func sink(id: String) -> int:
	return 0 if id in NO_SINK or id.begins_with("porta") else SINK


## L'ombra di una stazione: {img, x} (x = dove comincia rispetto al bordo sinistro dell'immagine), o {} se l'immagine
## è vuota. La base è la parte piena delle ultime tre righe dell'oggetto.
static func shadow(img: Image) -> Dictionary:
	var w := img.get_width()
	var h := img.get_height()
	var bottom := -1
	for y in range(h - 1, -1, -1):
		for x in w:
			if img.get_pixel(x, y).a > 0.5:
				bottom = y
				break
		if bottom >= 0:
			break
	if bottom < 0:
		return {}
	var lo := w
	var hi := -1
	for y in range(maxi(bottom - 2, 0), bottom + 1):
		for x in w:
			if img.get_pixel(x, y).a > 0.5:
				lo = mini(lo, x)
				hi = maxi(hi, x)
	var sw := hi - lo + 1 + 4
	var out := Image.create(sw, SHADOW_H, false, Image.FORMAT_RGBA8)
	var c := Color(0.02, 0.01, 0.04)
	for y in SHADOW_H:
		# un'ellisse schiacciata a gradini di pixel: piena al centro, più corta e più chiara verso l'alto e il basso
		var shrink := absi(y - 1) * 2
		for x in range(shrink, sw - shrink):
			var edge := mini(x - shrink, sw - shrink - 1 - x)
			var a := SHADOW_A * (0.55 if edge < 2 else 1.0) * (0.7 if y != 1 else 1.0)
			out.set_pixel(x, y, Color(c.r, c.g, c.b, a))
	return {"img": out, "x": lo - 2}
