class_name Spesa
extends Node
## La lista della spesa (28 set 2026, richiesta dell'utente: aiutare il giocatore nuovo). Il pulsante «Segna» di Esamina
## mette una ricetta nella lista (al più `MAX`); a destra, sotto la minimappa, la lista dice che cosa manca, anche gli
## ingredienti degli ingredienti (fino a `DEPTH` livelli), contando Bisaccia e casse vicine come «Creare»
## (`Crafting.have`). Fatta la ricetta, esce dalla lista da sola. `next_step` dice al filo (`Filo`) la prossima cosa da
## fare: raccogliere una materia prima, creare prima un ingrediente, o creare la ricetta. Si salva in
## `Character.guida["segnate"]` (le chiavi di `key`).

const MAX := 3
const DEPTH := 3
const ROWS_MAX := 9                      # righe per ricetta nella lista (le altre: «…»)
const GOLD := "#ffd08a"
const OK := "#8ef0a8"
const BAD := "#ff9a8a"
const MUTED := "#9fbfb8"

var m: Node2D
var _label: RichTextLabel
var _t := 0.0
var _dirty := true
var _by_key := {}


func setup(main: Node2D) -> void:
	m = main
	_label = RichTextLabel.new()
	_label.bbcode_enabled = true
	_label.fit_content = true
	_label.position = Vector2(1330, 236)
	_label.size = Vector2(262, 10)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("normal_font_size", 15)
	_label.add_theme_font_size_override("bold_font_size", 16)
	_label.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_label.add_theme_constant_override("outline_size", 4)
	m.hud.add_child(_label)
	_label.add_to_group(HudScrim.GROUP)          # (9 ott 2026) il fondo scuro dietro la scritta
	m.character.bisaccia.changed.connect(func() -> void: _dirty = true)
	var bp: BisacciaPanel = m.hud.panel
	bp.crafting.crafted.connect(_on_crafted)
	bp.mark_toggle = toggle                  # il pulsante «Segna» di Esamina
	bp.mark_has = is_marked


## La chiave di una ricetta (le ricette non hanno un nome): che cosa fa, dove, con che cosa.
static func key(r: Dictionary) -> String:
	var ins: Array = (r["in"] as Dictionary).keys()
	ins.sort()
	return "%s|%s|%s" % [r["out"], r["station"], ",".join(PackedStringArray(ins))]


func guida() -> Dictionary:
	var g: Dictionary = m.character.guida
	if not g.has("segnate"):
		g["segnate"] = []
	return g


func marked() -> Array[Dictionary]:
	if _by_key.is_empty():
		for r in RecipesData.all():
			_by_key[key(r)] = r
	var out: Array[Dictionary] = []
	for k in guida()["segnate"]:
		if _by_key.has(k):
			out.append(_by_key[k])
	return out


func is_marked(r: Dictionary) -> bool:
	return key(r) in guida()["segnate"]


## Segna o toglie una ricetta; restituisce se adesso è segnata.
func toggle(r: Dictionary) -> bool:
	var list: Array = guida()["segnate"]
	var k := key(r)
	var nm := String(ItemsData.get_item(String(r["out"])).get("name", r["out"]))
	if k in list:
		list.erase(k)
		m.hud.toast("«%s» tolta dalla lista" % nm)
	else:
		if list.size() >= MAX:
			list.remove_at(0)                    # la più vecchia lascia il posto
		list.append(k)
		m.hud.toast("«%s» nella lista, a destra: il filo ti porta a cercare ciò che manca" % nm)
	_dirty = true
	return k in list


## Le righe della lista di una ricetta: [oggetto, quanti ne hai (al più quanti servono), quanti servono, livello].
## Se un ingrediente manca e si può fabbricare, sotto ci sono i suoi ingredienti per la parte che manca.
func needs(r: Dictionary) -> Array:
	var rows := []
	_expand(r["in"], 1, 0, rows, {String(r["out"]): true})
	return rows


func _expand(ins: Dictionary, times: int, depth: int, rows: Array, seen: Dictionary) -> void:
	var b: Bisaccia = m.character.bisaccia
	for id in ins:
		var need := int(ins[id]) * times
		var have := Crafting.have(b, String(id))
		rows.append([String(id), mini(have, need), need, depth])
		var miss := need - have
		if miss > 0 and depth + 1 < DEPTH and not seen.has(id):
			var rs := RecipesData.making(String(id))
			if not rs.is_empty():
				var sub: Dictionary = rs[0]
				var s2 := seen.duplicate()
				s2[id] = true
				_expand(sub["in"], ceili(miss / float(sub["qty"])), depth + 1, rows, s2)


func station_ok(r: Dictionary) -> bool:
	var st := String(r["station"])
	return st == "" or (m.hud.stations_near.call() as Dictionary).has(st)


## La prossima cosa da fare per le ricette segnate (per il filo):
## {"craft": ricetta, "for": ricetta segnata} (si può creare, o prima un ingrediente), {"item", "have", "need", "for"}
## (raccogliere), {"full": ricetta} (manca il posto nella Bisaccia), {} (niente di segnato).
func next_step() -> Dictionary:
	var b: Bisaccia = m.character.bisaccia
	for r in marked():
		if Crafting.can_craft(r, b):
			return {"craft": r, "for": r}
		var rows := needs(r)
		for i in rows.size():
			var row: Array = rows[i]
			if int(row[1]) >= int(row[2]):
				continue
			var sub := []
			for j in range(i + 1, rows.size()):
				if int(rows[j][3]) <= int(row[3]):
					break
				sub.append(rows[j])
			if sub.is_empty():
				return {"item": row[0], "have": row[1], "need": row[2], "for": r}
			if sub.all(func(s: Array) -> bool: return int(s[1]) >= int(s[2])):
				return {"craft": RecipesData.making(String(row[0]))[0], "for": r}
		return {"full": r}
	return {}


func _on_crafted(id: String, _n: int) -> void:
	var list: Array = guida()["segnate"]
	for r in marked():
		if String(r["out"]) == id:
			list.erase(key(r))
			m.hud.toast("«%s» fatta: tolta dalla lista" % ItemsData.get_item(id).get("name", id))
	_dirty = true


func _process(dt: float) -> void:
	if not m.built:
		return
	_t -= dt
	var on: bool = bool(Settings.v("lista_spesa")) and not guida()["segnate"].is_empty() and not m.hud.is_open()
	_label.visible = on
	if not on or (_t > 0.0 and not _dirty):
		return
	_t = 0.5
	_dirty = false
	_label.text = text()


## Il testo della lista (anche per le prove).
func text() -> String:
	var b: Bisaccia = m.character.bisaccia
	var t := "[color=%s]Da preparare[/color]  [color=%s](Segna, in Esamina)[/color]\n" % [GOLD, MUTED]
	for r in marked():
		var nm := String(ItemsData.get_item(String(r["out"])).get("name", r["out"]))
		var st := String(r["station"])
		var where := "" if st == "" else " [color=%s]· %s[/color]" % [MUTED, StationsData.STATIONS[st]["name"]]
		if Crafting.can_craft(r, b):
			t += "[b]%s[/b]%s [color=%s]✓ %s[/color]\n" % [nm, where, OK, "pronta" if station_ok(r) else "vai al banco"]
			continue
		t += "[b]%s[/b]%s\n" % [nm, where]
		var rows := needs(r)
		for i in mini(rows.size(), ROWS_MAX):
			var row: Array = rows[i]
			var col := OK if int(row[1]) >= int(row[2]) else BAD
			t += "%s%s %s [color=%s]%d/%d[/color]\n" % ["    ".repeat(int(row[3])), "•" if int(row[3]) == 0 else "◦",
				ItemsData.get_item(String(row[0])).get("name", row[0]), col, int(row[1]), int(row[2])]
		if rows.size() > ROWS_MAX:
			t += "[color=%s]    …[/color]\n" % MUTED
	return t
