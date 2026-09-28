class_name Filo
extends Node
## Il filo da seguire (28 set 2026, richiesta dell'utente: aiutare il giocatore nuovo). In alto al centro, una sola cosa
## da fare adesso e dove cercarla, scelta tra le fonti che il gioco ha già: la lista della spesa (`Spesa`), l'Albero-Madre
## (`AlberoMadre`), gli obiettivi (`ObjectivesData`) e la Bacheca (`Board`). Il tasto «filo» passa alla fonte dopo (la
## scelta si ricorda in `Character.guida["filo"]`). Quando il posto è noto, una freccia (`FiloMarker`) lo indica: il
## blocco del minerale più vicino già visto, l'albero più vicino per il legno, il banco giusto, l'Albero-Madre; se
## serve scendere, una freccia in basso con lo strato.

const SOURCES := ["lista", "albero", "obiettivo", "bacheca", "studio", "stanza", "cielo", "stele"]
const SOURCE_NAME := {"lista": "La tua lista", "albero": "Albero-Madre", "obiettivo": "Obiettivo", "bacheca": "Bacheca",
	"studio": "Studio", "stanza": "La casa", "cielo": "Il cielo", "stele": "La lingua dei Seminatori"}
const SCAN_X := 110                      # quanto lontano si cerca un blocco già visto (tessere)
const SCAN_Y := 70
const S := 16

var m: Node2D
var current := {}                       # il filo mostrato: {src, text, hint, item?, station?, cell?, down?}
var target := {}                        # {"cell": Vector2i} o {"down": strato} (lo disegna il segno)
var _label: RichTextLabel
var _marker: FiloMarker
var _t := 0.0
var _scan_t := 0.0
var _key := ""
var _count := 0                         # quante fonti hanno qualcosa da dire


func setup(main: Node2D) -> void:
	m = main
	_label = RichTextLabel.new()
	_label.bbcode_enabled = true
	_label.fit_content = true
	_label.position = Vector2(420, 44)
	_label.size = Vector2(760, 10)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("normal_font_size", 16)
	_label.add_theme_font_size_override("bold_font_size", 17)
	_label.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_label.add_theme_constant_override("outline_size", 4)
	m.hud.add_child(_label)
	_label.add_to_group("hud_alto")
	_marker = FiloMarker.new()
	_marker.filo = self
	m.hud.add_child(_marker)


func _unhandled_input(e: InputEvent) -> void:
	if m == null or not m.built or m.hud.is_open():
		return
	if Keys.pressed(e, "filo"):
		cycle()
		get_viewport().set_input_as_handled()


## Passa alla fonte dopo (tra quelle che hanno qualcosa da dire).
func cycle() -> void:
	var all := candidates()
	if all.size() < 2:
		return
	var i := 0
	for k in all.size():
		if all[k]["src"] == current.get("src", ""):
			i = k
	m.character.guida["filo"] = String(all[(i + 1) % all.size()]["src"])
	_t = 0.0
	_scan_t = 0.0


func _process(dt: float) -> void:
	if not m.built:
		return
	var on: bool = bool(Settings.v("filo")) and not m.hud.is_open()
	_label.visible = on
	var ch = m.get("challenges")
	_label.position.y = 44.0 + (24.0 if ch != null and ch._label != null and ch._label.visible else 0.0)
	_marker.visible = on
	if not on:
		return
	_t -= dt
	_scan_t -= dt
	if _t > 0.0:
		return
	_t = 1.0
	refresh()


## Rifà il filo (una volta al secondo; le prove lo chiamano direttamente).
func refresh() -> void:
	var all := candidates()
	_count = all.size()
	var want := String(m.character.guida.get("filo", ""))
	current = {}
	for c in all:
		if c["src"] == want:
			current = c
	if current.is_empty() and not all.is_empty():
		current = all[0]
	var key := "%s|%s" % [current.get("src", ""), current.get("text", "")]
	if key != _key:
		_key = key
		_scan_t = 0.0                            # un filo nuovo: il suo posto subito, non quello del filo di prima
	if _scan_t <= 0.0 or target.is_empty():
		_scan_t = 2.0
		target = _target(current)
	_label.text = text()
	_marker.queue_redraw()


## Il testo del filo (anche per le prove).
func text() -> String:
	if current.is_empty():
		return ""
	var t := "[center][color=#ffd08a]➤[/color] [b]%s[/b]" % current["text"]
	if String(current.get("hint", "")) != "":
		t += "\n[font_size=14][color=#cfe8e2]%s[/color][/font_size]" % current["hint"]
	t += "\n[font_size=12][color=#9fbfb8]%s%s[/color][/font_size][/center]" % [SOURCE_NAME.get(current["src"], ""),
		(" · %s: un altro filo (%d)" % [Keys.label("filo"), _count]) if _count > 1 else ""]
	return t


# ---------------------------------------------------------------- le fonti

func candidates() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for src in SOURCES:
		var c: Dictionary = call("_from_" + src)
		if not c.is_empty():
			c["src"] = src
			out.append(c)
	return out


func _from_lista() -> Dictionary:
	var st: Dictionary = m.spesa.next_step()
	if st.is_empty():
		return {}
	var goal := _name(String((st["for"] as Dictionary)["out"]))
	if st.has("full"):
		return {"text": "Fai posto nella Bisaccia per creare %s" % goal, "hint": "casse, o il Cestino accanto al titolo della Bisaccia"}
	if st.has("craft"):
		var r: Dictionary = st["craft"]
		var what := _name(String(r["out"]))
		var first := "" if r == st["for"] else " (serve per %s)" % goal
		var stn := String(r["station"])
		if stn == "" or m.spesa.station_ok(r):
			return {"text": "Puoi creare %s%s" % [what, first], "hint": "apri la Bisaccia (%s): Creare" % Keys.label("bisaccia")}
		var sname := String(StationsData.STATIONS[stn]["name"])
		if _nearest_station(stn).x < 0:
			return {"text": "Costruisci un %s per creare %s" % [sname, what], "hint": ItemInfo.how_to_get(String(StationsData.STATIONS[stn].get("item", "")))}
		return {"text": "Vai al %s per creare %s%s" % [sname, what, first], "hint": "", "station": stn}
	return {"text": "Raccogli %s per %s  %d/%d" % [_name(String(st["item"])), goal, int(st["have"]), int(st["need"])],
		"hint": ItemInfo.how_to_get(String(st["item"])), "item": String(st["item"])}


func _from_albero() -> Dictionary:
	var al: AlberoMadre = m.albero
	if not al.has_garden() or al.done():
		return {}
	if al.ready_to_wake():
		return {"text": "L'Albero-Madre è pronto a crescere: torna da lui", "hint": "clic destro sull'Albero, nel Giardino",
			"tree": true}
	var offers: Array = al.current()["offers"]
	for i in offers.size():
		var o: Dictionary = offers[i]
		var p := al.progress(i)
		if int(p[0]) >= int(p[1]):
			continue
		if o.has("item"):
			var id := String(o["item"])
			if Crafting.have(m.character.bisaccia, id) >= int(p[1]) - int(p[0]):
				return {"text": "Porta all'Albero-Madre %s (%d/%d)" % [_name(id), int(p[0]), int(p[1])],
					"hint": "clic destro sull'Albero, nel Giardino", "tree": true}
			return {"text": "Per l'Albero-Madre: %s  %d/%d" % [_name(id), int(p[0]) + Crafting.have(m.character.bisaccia, id), int(p[1])],
				"hint": String(o.get("hint", "")), "item": id}
		return {"text": "Per l'Albero-Madre: %s  %d/%d" % [String(o.get("text", "")), int(p[0]), int(p[1])],
			"hint": String(o.get("hint", ""))}
	return {}


func _from_obiettivo() -> Dictionary:
	for o in ObjectivesData.LIST:
		if m.objectives.done(String(o["id"])):
			continue
		var c: Dictionary = o["check"]
		var out := {"text": String(o["text"]), "hint": ""}
		if c.has("item"):
			out["item"] = String(c["item"])
			out["hint"] = ItemInfo.how_to_get(String(c["item"]))
		elif c.has("station"):
			out["hint"] = ItemInfo.how_to_get(String(StationsData.STATIONS[String(c["station"])].get("item", "")))
		elif c.has("stratum"):
			out["down"] = int(c["stratum"])
			out["hint"] = "più in basso: %s" % StrataData.STRATA[int(c["stratum"])]["name"]
		elif c.has("kill") and CreaturesData.CREATURES.has(String(c["kill"])):
			out["hint"] = _lives(String(c["kill"]))
		return out
	return {}


## Voce 149: la prima stanza (quando c'è già un Focolare, ma nessuna stanza nel mondo).
func _from_stanza() -> Dictionary:
	if m.get("rooms") == null or not m.rooms.list().is_empty() or m.villagers._hearth().x < 0:
		return {}
	return {"text": "Costruisci la tua prima stanza: blocchi attorno, pareti dietro, una porta e un letto",
		"hint": "una stanza ripara dai rigori e, con gli arredi, aiuta (Enciclopedia: Le stanze e le case)"}


## Roadmap 16: dal secondo giorno, se il Germogliato non è mai salito in cielo, la corrente più vicina che ci porta.
func _from_cielo() -> Dictionary:
	if m.world.sky.is_empty() or int(m.character.stats.get("cielo_max", 0)) > 0 or m.day.day < 2 or m.giardino.active:
		return {}
	var best := Vector2i(-1, -1)
	var pc: Vector2i = m.player_cell()
	for cu in m.gravity.currents:
		var d: Dictionary = cu
		if d.get("cielo", false) and int(d["y1"]) >= int(m.world.surface[int(d["x"])]) - 3:
			var q := Vector2i(int(d["x"]), int(d["y1"]))
			if best.x < 0 or absi(q.x - pc.x) < absi(best.x - pc.x):
				best = q
	var c := {"text": "Sali alle isole del cielo", "hint": "entra in una corrente d'aria (foglie che salgono) e tieni premuto il salto: porta su dalla terra; o le radici che pendono dalle isole, o un Fagiolo di nuvola"}
	if best.x >= 0:
		c["cell"] = best
	return c


## Roadmap 17: il luogo «forse» più vicino di una stele: arrivandoci le sue parole diventano certe.
func _from_stele() -> Dictionary:
	var best := Vector2i(-1, -1)
	var pc: Vector2i = m.player_cell()
	for k in m.language.stele():
		var e: Dictionary = m.language.stele()[k]
		if e.get("forse", false) and not e.get("segnata", false):
			var h: Array = e["hint"]
			var q := Vector2i(int(h[0]), int(h[1]))
			if best.x < 0 or Vector2(q - pc).length() < Vector2(best - pc).length():
				best = q
	if best.x < 0:
		return {}
	return {"text": "Va' a vedere il luogo che una stele indica «forse»", "hint": "arrivandoci, le parole di quella stele diventano certe", "cell": best}


## Voce 138: la specie più vicina a essere studiata.
func _from_studio() -> Dictionary:
	return m.study.next_to_study() if m.get("study") != null else {}


func _from_bacheca() -> Dictionary:
	for r in (m.character.bacheca.get("aperte", []) as Array):
		if r is Dictionary and String(r.get("testo", "")) != "":
			return {"text": String(r["testo"]), "hint": "si consegna alla Bacheca dei Giardinieri, nel Giardino"}
	return {}


# ---------------------------------------------------------------- dove

## Il posto da indicare: il blocco più vicino già visto, l'albero, il banco, l'Albero-Madre, o «più in basso».
func _target(c: Dictionary) -> Dictionary:
	if c.is_empty():
		return {}
	if c.has("cell"):
		return {"cell": c["cell"]}
	if c.get("tree", false) and m.giardino.active and m.giardino.tree_o.x >= 0:
		return {"cell": m.giardino.tree_o + Vector2i(4, 6)}
	if c.has("station"):
		var o := _nearest_station(String(c["station"]))
		return {"cell": o} if o.x >= 0 else {}
	if c.has("down"):
		return {"down": int(c["down"])} if m.depth_watch.stratum < int(c["down"]) else {}
	if c.has("item"):
		var id := String(c["item"])
		if id == "legno":
			var t := _nearest_tree()
			return {"cell": t} if t.x >= 0 else {}
		var tiles := tiles_of(id)
		if not tiles.is_empty():
			var q := _nearest_tile(tiles)
			if q.x >= 0:
				return {"cell": q}
			var deep := strata_of(tiles)
			if not deep.is_empty() and m.depth_watch.stratum < int(deep.min()):
				return {"down": int(deep.min())}
	return {}


## I tipi di tessera che, scavati, danno quell'oggetto.
static func tiles_of(id: String) -> Array:
	var out := []
	for t in TileDefs.DROP:
		if TileDefs.DROP[t] == id:
			out.append(int(t))
	return out


## Gli strati in cui nascono le vene di quei tipi di tessera ([] se non sono vene).
static func strata_of(tiles: Array) -> Array:
	var out := []
	for o in TileDefs.ORES:
		if int(o["type"]) in tiles:
			for k in o["strata"]:
				if not int(k) in out:
					out.append(int(k))
	return out


func _nearest_tile(tiles: Array) -> Vector2i:
	var w: World = m.world
	var pc: Vector2i = m.player_cell()
	var want := PackedByteArray()
	want.resize(TileDefs.TYPES + 1)
	for t in tiles:
		want[t] = 1
	var best := Vector2i(-1, -1)
	var bd := 1 << 30
	var tl := w.tiles
	var ex := w.explored
	for y in range(maxi(pc.y - SCAN_Y, 0), mini(pc.y + SCAN_Y, w.h)):
		var row := y * w.w
		for x in range(maxi(pc.x - SCAN_X, 0), mini(pc.x + SCAN_X, w.w)):
			var i := row + x
			if want[tl[i]] == 1 and ex[i] == 1:
				var d := (x - pc.x) * (x - pc.x) + (y - pc.y) * (y - pc.y)
				if d < bd:
					bd = d
					best = Vector2i(x, y)
	return best


func _nearest_tree() -> Vector2i:
	var pc: Vector2i = m.player_cell()
	var best := Vector2i(-1, -1)
	var bd := 1 << 30
	for k in m.world.trees:
		for t in m.world.trees[k]:
			var d: int = (t.x - pc.x) * (t.x - pc.x) + (t.y - pc.y) * (t.y - pc.y)
			if d < bd and absi(t.x - pc.x) < 200:
				bd = d
				best = Vector2i(t.x, t.y - 2)
	return best


func _nearest_station(id: String) -> Vector2i:
	var pc: Vector2i = m.player_cell()
	var best := Vector2i(-1, -1)
	var bd := 1 << 30
	for o: Vector2i in m.world.stations:
		if String(m.world.stations[o]) == id:
			var d := (o.x - pc.x) * (o.x - pc.x) + (o.y - pc.y) * (o.y - pc.y)
			if d < bd:
				bd = d
				best = o
	return best


static func _name(id: String) -> String:
	return String(ItemsData.get_item(id).get("name", id))


## Dove vive una creatura, in breve (strati e biomi).
static func _lives(cid: String) -> String:
	var cd: Dictionary = CreaturesData.CREATURES[cid]
	var where := []
	for k in cd.get("strata", []):
		where.append(String(StrataData.STRATA[int(k)]["name"]))
	var bs := []
	for b in cd.get("biomes", []):
		var bd := BiomesData.by_id(String(b))
		if not bd.is_empty():
			bs.append(String(bd["name"]))
	var t := "vive: %s" % ", ".join(where) if not where.is_empty() else ""
	if not bs.is_empty():
		t += (" · " if t != "" else "") + ", ".join(bs)
	return t
