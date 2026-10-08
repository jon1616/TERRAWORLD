class_name IconVariety
extends RefCounted
## Le icone degli oggetti tutte diverse (29 set 2026: giocando, l'utente ne ha viste di uguali; `tools/icone_simili.py`
## ne contava 1606 in 497 gruppi). `ItemIcons.of` passa di qui per gli oggetti che non sono costrutti o arredi:
## 1. le forme che il codice non conosce prendono quella giusta (`ALIAS`: prima erano un cerchio rosa);
## 2. un oggetto che piazza una stazione ha per icona il disegno della stazione, rimpicciolito (casse, totem, trappole,
##    esche, meccanismi: prima avevano tutti la stessa cesta, torcia o gemma);
## 3. un oggetto che ha la stessa forma e lo stesso materiale di altri prende, se il nome lo dice, una forma più precisa
##    (`WORDS`: «Uovo…» → uovo, «Zanna…» → aculeo…);
## 4. se resta uguale ad altri, riceve una variante: specchiato, più scuro, più chiaro, di un'altra tinta (`vary`).
## Le varianti non dicono niente di vero: aspettano le forme nuove di Nano Banana (voce 105 bis). Il materiale si legge
## sempre nella scheda.

const ALIAS := {"guanto": "guanti", "corno": "aculeo", "cassa": "cesta"}

## Parole del nome → forma più precisa (solo per chi ha un doppione). Si cerca la parola intera, in minuscolo.
const WORDS := [
	["uovo", "uovo"], ["uova", "uovo"], ["occhio", "occhio"], ["cuore", "cuore"], ["nucleo", "cuore"],
	["zanna", "aculeo"], ["dente", "aculeo"], ["pungiglione", "aculeo"], ["spina", "aculeo"], ["becco", "aculeo"],
	["artiglio", "artiglio"], ["chela", "artiglio"], ["palco", "corona"], ["corona", "corona"],
	["piuma", "penna"], ["penna", "penna"], ["penne", "penna"], ["ali", "ali"], ["ala", "ali"], ["elitra", "ali"],
	["scaglia", "scaglia"], ["squama", "scaglia"], ["placca", "scaglia"], ["lastra", "scaglia"], ["carapace", "guscio"],
	["guscio", "guscio"], ["conchiglia", "guscio"], ["membrana", "membrana"], ["gelatina", "gel"], ["bava", "gel"],
	["seme", "seme"], ["semi", "seme"], ["nocciolo", "seme"], ["tubero", "tubero"], ["bulbo", "tubero"],
	["fungo", "fungo"], ["cappello", "fungo"], ["foglia", "foglia"], ["petali", "foglia"], ["fiore", "foglia"],
	["goccia", "goccia"], ["miele", "goccia"], ["resina", "goccia"], ["polvere", "polvere"], ["cenere", "polvere"],
	["sabbia", "polvere"], ["polline", "polvere"], ["velo", "velo"], ["mantello", "mantello"], ["cappuccio", "velo"],
	["scheggia", "cristallo"], ["frammento", "cristallo"], ["cristallo", "cristallo"], ["gemma", "gemma"],
	["perla", "gemma"], ["essenza", "essenza"], ["luce", "essenza"], ["fiamma", "essenza"], ["scintilla", "essenza"],
	["amuleto", "amuleto"], ["talismano", "amuleto"], ["collana", "collana"], ["anello", "anello"],
	["tavoletta", "tavoletta"], ["sigillo", "tavoletta"], ["chiave", "chiave"], ["lanterna", "lanterna"],
	["seta", "seta"], ["pelliccia", "seta"], ["pelo", "seta"], ["vello", "seta"], ["lana", "seta"], ["fibra", "seta"],
	["fune", "seta"], ["liana", "seta"], ["corda", "seta"], ["benda", "benda"], ["fascia", "benda"],
]

static var _station_of := {}          # oggetto → stazione che piazza
static var _station_icons := {}       # stazione → icona 16×16 (preparate tutte insieme: `warm`)
static var _groups := {}              # "forma|materiale" → oggetti in ordine, dopo le parole
static var _ready := false


## L'icona di un oggetto (dati `it` di `ItemsData`).
static func of(id: String, it: Dictionary) -> Image:
	_prepare()
	if _station_of.has(id) and OS.get_thread_caller_id() == OS.get_main_thread_id():
		warm()
		return _station_icons[_station_of[id]]
	var spec := spec_of(id, it)
	var img := ItemIcons.make(spec[0], spec[1])
	var g: Array = _groups.get(spec[0] + "|" + spec[1], [])
	var k := g.find(id)
	return vary(img, k) if k > 0 else img


## L'icona dell'interfaccia (48 pixel: `ItemIcons.ui`), con le stesse varianti di quella del mondo.
static func of_ui(id: String, it: Dictionary) -> Image:
	_prepare()
	if _station_of.has(id):
		# 8 ott 2026 (l'utente: «molte icone ancora sono da fare… banchi e casse»): una stazione con una forma d'icona
		# dipinta usa quella (lo scrigno, l'incudine del Maglio…); le altre il loro disegno del mondo ingrandito
		var ss := spec_of(id, it)
		# trappole, totem e macchine hanno nei dati forme segnaposto (una gemma, un mantello, un'incudine): tengono il
		# disegno del mondo finché non hanno la forma loro (che comincia con il nome della categoria)
		var holder := String(CraftCatsData.place_of(id, "")[0]) in ["trappole", "totem", "rete"] \
				and not (String(ss[0]).begins_with("trappola_") or String(ss[0]).begins_with("totem_") \
				or String(ss[0]).begins_with("macchina_"))
		if ArtLib.has("icone48", ss[0]) and not holder:
			var si := ItemIcons.make_ui(ss[0], ss[1])
			var sk := _station_dup(id, ss[0] + "|" + ss[1])
			return vary(si, sk) if sk > 0 else si
		if OS.get_thread_caller_id() == OS.get_main_thread_id():
			warm()
			return ItemIcons.up3(CreatureFx.shade(_station_icons[_station_of[id]]))
	var spec := spec_of(id, it)
	var img := ItemIcons.make_ui(spec[0], spec[1])
	var g: Array = _groups.get(spec[0] + "|" + spec[1], [])
	var k := g.find(id)
	return vary(img, k) if k > 0 else img


## Le icone di tutte le stazioni che si piazzano, preparate una volta (~0,5 s): due stazioni con lo stesso disegno
## (tre gradi di una runa colorata, due radici, alcune macchine della rete) danno all'icona una variante. Si chiama
## durante il caricamento del mondo (`MainBoot.build_scene`), così giocando non si sente; solo nel thread principale
## (i disegni di Nano Banana si caricano da file).
static func warm() -> void:
	_prepare()
	if not _station_icons.is_empty():
		return
	var seen := {}
	var sids: Array = _station_of.values()
	sids.sort()
	for sid in sids:
		if _station_icons.has(sid):
			continue
		var img := station_icon(String(sid))
		var key := img.get_data().hex_encode().md5_text()
		var k := int(seen.get(key, 0))
		seen[key] = k + 1
		_station_icons[sid] = vary(img, k) if k > 0 else img


## La forma e il materiale con cui si disegna l'oggetto (alias e parole del nome comprese).
static func spec_of(id: String, it: Dictionary) -> Array:
	var ic: Array = it.get("icon", ["?", "ardesia"])
	var shape := str(ic[0])
	if not ArtLib.has("icone48", shape):
		shape = String(ALIAS.get(shape, shape))   # il soprannome solo per le forme ancora senza disegno (8 ott 2026)
	var mat := str(ic[1]) if ic.size() > 1 else "ardesia"
	if ic.size() > 2:
		mat = "duo:%s:%s" % [ic[1], ic[2]]
	if _dup_raw.get(str(ic[0]) + "|" + mat, 0) > 1:
		shape = _word_shape(String(it.get("name", id)), shape)
	return [shape, mat]


static var _dup_raw := {}


static func _prepare() -> void:
	if _ready:
		return
	_ready = true
	for sid in StationsData.STATIONS:
		var item := str(StationsData.STATIONS[sid].get("item", ""))
		if item != "" and not _station_of.has(item):
			_station_of[item] = sid
	var all := ItemsData.all()
	var ids: Array = all.keys()
	ids.sort()
	# prima si contano i doppioni dei dati (forma e materiale scritti), poi si rifanno i gruppi con le parole
	for id in ids:
		var it: Dictionary = all[id]
		if _skip(String(id), it):
			continue
		var ic: Array = it.get("icon", ["?", "ardesia"])
		var mat := str(ic[1]) if ic.size() > 1 else "ardesia"
		if ic.size() > 2:
			mat = "duo:%s:%s" % [ic[1], ic[2]]
		var raw := str(ic[0]) + "|" + mat
		_dup_raw[raw] = int(_dup_raw.get(raw, 0)) + 1
	for id in ids:
		var it: Dictionary = all[id]
		if _skip(String(id), it):
			continue
		var s := spec_of(String(id), it)
		var key := String(s[0]) + "|" + String(s[1])
		if not _groups.has(key):
			_groups[key] = []
		(_groups[key] as Array).append(id)


## Chi non passa di qui: costrutti, pareti, arredi in serie (hanno icone loro) e chi piazza una stazione.
static var _station_groups := {}


## Le stazioni con la stessa forma e lo stesso materiale (la cassa di un bioma e la sua sigillata): il posto nel
## gruppo, in ordine di id, per la variante di `vary` (0 = la prima, uguale).
static func _station_dup(id: String, key: String) -> int:
	if _station_groups.is_empty():
		var all := ItemsData.all()
		var ids: Array = _station_of.keys()
		ids.sort()
		for sid in ids:
			if not all.has(sid):
				continue
			var sp := spec_of(String(sid), all[sid])
			var kk := String(sp[0]) + "|" + String(sp[1])
			if not _station_groups.has(kk):
				_station_groups[kk] = []
			(_station_groups[kk] as Array).append(sid)
	return (_station_groups.get(key, []) as Array).find(id)


static func _skip(id: String, it: Dictionary) -> bool:
	return it.has("build") or str(it.get("place", "")).begins_with("arredo_") or _station_of.has(id) \
			or int(it.get("wall", 0)) >= BuildData.WALL_BASE


static func _word_shape(name: String, shape: String) -> String:
	var words := name.to_lower().replace("'", " ").replace("’", " ").split(" ", false)
	for w in WORDS:
		if String(w[0]) in words and String(w[1]) != shape:
			return String(w[1])
	return shape


## Il disegno della stazione in 16×16: ogni riquadro prende il colore più frequente tra quelli pieni (una media
## sporcherebbe i colori), vuoto se è pieno per meno di un terzo.
static func station_icon(sid: String) -> Image:
	var src: Image = StationArt.make(sid)["img"]
	var w := src.get_width()
	var h := src.get_height()
	var f := maxi(1, ceili(maxf(w, h) / 16.0))
	var ow := ceili(float(w) / f)
	var oh := ceili(float(h) / f)
	var out := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	var ox := (16 - ow) / 2
	var oy := 16 - oh - maxi(0, (16 - oh) / 4)
	for y in oh:
		for x in ow:
			var count := {}
			var full := 0
			for yy in f:
				for xx in f:
					var sx := x * f + xx
					var sy := y * f + yy
					if sx >= w or sy >= h:
						continue
					var c := src.get_pixel(sx, sy)
					if c.a > 0.5:
						full += 1
						var key := c.to_rgba32()
						count[key] = int(count.get(key, 0)) + 1
			if full * 3 < f * f:
				continue
			var best := 0
			var n := -1
			for key in count:
				if int(count[key]) > n:
					n = int(count[key])
					best = int(key)
			out.set_pixel(ox + x, oy + y, Color.hex(best))
	return out


## La k-esima variante di un'icona che altrimenti sarebbe uguale a un'altra: più scura, più chiara, specchiata, e dalla
## settima una tinta un po' spostata. Il contorno (quasi nero) resta com'è.
static func vary(img: Image, k: int) -> Image:
	var out := img.duplicate() as Image
	# prima il tono (lo specchio su una forma simmetrica, una pozione, non cambiava quasi niente), poi lo specchio
	var tone := k % 3                             # 0 uguale, 1 più scuro, 2 più chiaro
	if (k / 3) % 2 == 1:
		out.flip_x()
	var hue := float(k / 6) * 0.07
	if tone == 0 and hue == 0.0:
		return out
	for y in out.get_height():
		for x in out.get_width():
			var c := out.get_pixel(x, y)
			if c.a < 0.5 or c.get_luminance() < 0.12:
				continue
			if tone == 1:
				c = c.darkened(0.22)
			elif tone == 2:
				c = c.lightened(0.22)
			if hue > 0.0:
				c = Color.from_hsv(fposmod(c.h + hue, 1.0), c.s, c.v, c.a)
			out.set_pixel(x, y, c)
	return out
