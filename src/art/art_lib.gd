class_name ArtLib
extends RefCounted
## La grafica fatta con Nano Banana (Roadmap 13, voce 100): png pronti in `res://arte/<cartella>/<nome>.png`, fatti
## dagli script di `tools/` (`tavola.py`, `illustrazione.py`) a partire dai disegni di `arte_ia/` (ogni cartella ha il
## suo `rifai.sh`). Se il file non c'è si ha `null` e chi chiama usa il disegno del codice di prima: una tavola che
## manca o si rifà non rompe niente.

static var _cache := {}
static var _images := {}               # cartella -> {nome: Image RGBA8}, per chi disegna in un thread


## Carica come immagini tutti i disegni di una cartella: va chiamata nel thread principale prima di un lavoro in
## sottofondo che li usa (voce 107: le decorazioni si dipingono nel thread di `ViewArt`, dove un `load()` blocca).
static func preload_images(cartella: String) -> void:
	if _images.has(cartella):
		return
	var out := {}
	var dir := "res://arte/%s" % cartella
	if DirAccess.dir_exists_absolute(dir):
		for f in DirAccess.get_files_at(dir):
			# nel gioco esportato restano solo i .import: il nome del disegno è lo stesso
			var nome := f.trim_suffix(".import")
			if nome.ends_with(".png") and not out.has(nome.get_basename()):
				var t := tex(cartella, nome.get_basename())
				if t != null:
					out[nome.get_basename()] = IconTemplates.rgba(t)
	_images[cartella] = out


## Un disegno come immagine, già caricato con `preload_images`; nel thread principale lo carica se serve, negli altri
## thread restituisce null piuttosto che caricare.
static func image(cartella: String, nome: String) -> Image:
	if not _images.has(cartella):
		if OS.get_thread_caller_id() != OS.get_main_thread_id():
			return null
		preload_images(cartella)
	return _images[cartella].get(nome)


static func tex(cartella: String, nome: String) -> Texture2D:
	var p := "res://arte/%s/%s.png" % [cartella, nome]
	if _cache.has(p):
		return _cache[p]
	var t: Texture2D = null
	if ResourceLoader.exists(p):
		t = load(p) as Texture2D
	_cache[p] = t
	return t


## L'icona dentro un testo BBCode (schede, Enciclopedia): «[img]…[/img] » o niente se il file manca.
static func bb(cartella: String, nome: String, lato := 16) -> String:
	if not has(cartella, nome):
		return ""
	return "[img=%dx%d]res://arte/%s/%s.png[/img] " % [lato, lato, cartella, nome]


static func has(cartella: String, nome: String) -> bool:
	return tex(cartella, nome) != null
