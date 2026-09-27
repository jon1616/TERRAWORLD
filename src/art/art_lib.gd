class_name ArtLib
extends RefCounted
## La grafica fatta con Nano Banana (Roadmap 13, voce 100): png pronti in `res://arte/<cartella>/<nome>.png`, fatti
## dagli script di `tools/` (`tavola.py`, `illustrazione.py`) a partire dai disegni di `arte_ia/` (ogni cartella ha il
## suo `rifai.sh`). Se il file non c'è si ha `null` e chi chiama usa il disegno del codice di prima: una tavola che
## manca o si rifà non rompe niente.

static var _cache := {}


static func tex(cartella: String, nome: String) -> Texture2D:
	var p := "res://arte/%s/%s.png" % [cartella, nome]
	if _cache.has(p):
		return _cache[p]
	var t: Texture2D = null
	if ResourceLoader.exists(p):
		t = load(p) as Texture2D
	_cache[p] = t
	return t


static func has(cartella: String, nome: String) -> bool:
	return tex(cartella, nome) != null
