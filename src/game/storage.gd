class_name Storage
extends Node
## Le casse (26 set 2026, richiesta dell'utente; dati in `StorageData`):
## - la **creazione pesca dalle casse vicine**: ogni tanto si cercano le casse entro `CRAFT_REACH` tessere con
##   «usa per creare» e si danno a `Crafting.pool` (prima la Bisaccia, poi le casse); se il contenuto di una di queste
##   cambia, il pannello Creare si ridisegna;
## - le **impostazioni** di ogni cassa (`world_meta["casse"]`): nome (scritto sopra la cassa), «usa per creare», tipo
##   di oggetti che raccoglie;
## - i **pulsanti di comodità** (li chiamano `ChestPanel` e `BisacciaPanel`): deposita tutto, deposita simili,
##   rifornisci, e «Nelle casse vicine» (ogni oggetto della Bisaccia va nella cassa vicina che lo contiene già o che
##   raccoglie il suo tipo).
## La barra rapida non si svuota mai da sola: i pulsanti che depositano usano solo le 30 caselle grandi.

const S := 16

var m: Node2D
var _t := 0.0
var _watched := {}                     # Bisaccia delle casse della creazione -> true (segnale collegato)
var _labels := {}                      # origine -> Label del nome
var _label_t := 0.0


func setup(main: Node2D) -> void:
	m = main
	if not m.world_meta.has("casse"):
		m.world_meta["casse"] = {}
	_hook_where.call_deferred()


func _hook_where() -> void:
	if m != null and m.get("hud") != null and m.hud.panel != null:
		m.hud.panel.examine.where_fn = where_text


## (Voce 352, l'utente: «fatico a trovare ciò che mi serve») Dove ce l'hai: addosso, nella Dispensa, e nelle casse di
## questo mondo, dalla più vicina (al più quattro), con il nome della cassa e la distanza in tessere.
func where_text(id: String) -> String:
	var parts := []
	var on: int = m.character.bisaccia.count(id)
	if on > 0:
		parts.append("[color=#ffe8c0]%d[/color] addosso" % on)
	var dsp: Bisaccia = m.character.dispensa
	if dsp != null and dsp.count(id) > 0:
		parts.append("[color=#ffe8c0]%d[/color] nella Dispensa" % dsp.count(id))
	var found := []
	var me: Vector2 = m.player.position / 16.0
	for o in m.world.chests:
		var c: Bisaccia = m.world.chests[o]
		var n := c.count(id) if c != null else 0
		if n > 0:
			found.append([Vector2(o).distance_to(me), o, n])
	found.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	for f in found.slice(0, 4):
		var o: Vector2i = f[1]
		var name := String(settings(o)["nome"])
		if name == "":
			name = String(StationsData.STATIONS.get(String(m.world.stations.get(o, "")), {}).get("name", "cassa"))
		parts.append("[color=#ffe8c0]%d[/color] in «%s» (%d tessere)" % [int(f[2]), name, roundi(float(f[0]))])
	if found.size() > 4:
		parts.append("e in altre %d casse" % (found.size() - 4))
	if parts.is_empty():
		return "[color=#8ef0d8]Dove ce l'hai:[/color] [color=#6a8a84]da nessuna parte, in questo mondo.[/color]"
	return "[color=#8ef0d8]Dove ce l'hai:[/color] [color=#9fc8c0]%s.[/color]" % " · ".join(parts)


static func key(o: Vector2i) -> String:
	return "%d,%d" % [o.x, o.y]


func settings(o: Vector2i) -> Dictionary:
	var id := String(m.world.stations.get(o, ""))
	var d: Dictionary = (m.world_meta["casse"] as Dictionary).get(key(o), {})
	return {"nome": String(d.get("nome", "")), "creare": bool(d.get("creare", StorageData.DEFAULT_CRAFT.get(id, true))),
		"tipo": String(d.get("tipo", ""))}


func set_setting(o: Vector2i, k: String, v: Variant) -> void:
	var all: Dictionary = m.world_meta["casse"]
	var d: Dictionary = all.get(key(o), {})
	d[k] = v
	all[key(o)] = d
	_t = 0.0                               # la creazione se ne accorge subito
	_label_t = 0.0


## Le casse (stazioni con caselle, non il fagotto) entro `reach` tessere dal Germogliato, dalla più vicina.
func chests_near(reach: float) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var p: Vector2 = m.player.position
	for o in m.world.chests:
		var id := String(m.world.stations.get(o, ""))
		if id == "" or id in StorageData.NO_SETTINGS or not StationsData.STATIONS[id].has("slots"):
			continue
		if _center(o).distance_to(p) <= reach * S:
			out.append(o)
	# (le casse mai aperte non hanno ancora un contenuto in `world.chests`: sono vuote, non servono)
	out.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return _center(a).distance_squared_to(p) < _center(b).distance_squared_to(p))
	return out


func _center(o: Vector2i) -> Vector2:
	var size: Array = StationsData.STATIONS[String(m.world.stations[o])]["size"]
	return Vector2(o) * S + Vector2(size[0], size[1]) * S * 0.5


func _process(dt: float) -> void:
	if not m.built:
		return
	_t -= dt
	if _t <= 0.0:
		_t = 0.4
		_update_pool()
	_label_t -= dt
	if _label_t <= 0.0:
		_label_t = 0.5
		_update_labels()


## Le stazioni «dispensa» del mondo (si cercano di nuovo solo quando le stazioni cambiano).
var _disp: Array[Vector2i] = []
var _disp_rev := -1
func _dispense() -> Array[Vector2i]:
	var rev: int = m.world.stations_rev()
	if rev != _disp_rev:
		_disp_rev = rev
		_disp.clear()
		for o in m.world.stations:
			if String(m.world.stations[o]) == "dispensa":
				_disp.append(o)
	return _disp


## Le casse che danno gli ingredienti alla creazione.
func _update_pool() -> void:
	var pool: Array = []
	var near := chests_near(StorageData.craft_reach)
	if m.get("energy") != null:
		for o in EnergyLinks.linked_chests(m.energy):            # Roadmap 19: le casse della rete di un Nodo delle casse
			if not o in near:
				near.append(o)
	for o in near:
		if settings(o)["creare"]:
			pool.append(m.world.chests[o])
	# la Dispensa del Giardiniere: il suo contenuto è del personaggio (non sta in `world.chests`), ma la stazione vicina
	# con «usa per creare» lo dà alla creazione come una cassa (segnalato dall'utente, 2 ott 2026)
	if m.get("backpack") != null:
		for o in _dispense():
			if settings(o)["creare"] and _center(o).distance_to(m.player.position) <= StorageData.craft_reach * S:
				pool.append(m.backpack.dispensa())
				break
	var changed := pool.size() != Crafting.pool.size()
	if not changed:
		for i in pool.size():
			if pool[i] != Crafting.pool[i]:
				changed = true
				break
	Crafting.pool = pool
	for b in pool:
		if not _watched.has(b):
			_watched[b] = true
			(b as Bisaccia).changed.connect(_pool_changed.bind(b))
	if changed:
		_pool_changed(null)


func _pool_changed(b: Variant) -> void:
	if b == null or b in Crafting.pool:
		m.hud.panel.crafting.mark_dirty()


# ---- i pulsanti ----------------------------------------------------------------------------------------------------

## Sposta la casella i di `from` in `to` (quanto ci sta). Restituisce quanti oggetti ha spostato.
static func move_slot(from: Bisaccia, i: int, to: Bisaccia) -> int:
	if from.slots[i].is_empty():
		return 0
	var n := from.count_at(i)
	var rest := to.add_stack(from.slots[i])
	if rest <= 0:
		from.slots[i] = {}
	else:
		from.slots[i]["n"] = rest
	return n - rest


## Deposita tutto: le 30 caselle grandi della Bisaccia nella cassa.
func deposit_all(chest: Bisaccia) -> int:
	var b: Bisaccia = m.character.bisaccia
	var moved := 0
	for i in range(Bisaccia.HOTBAR, b.slots.size()):
		if not b.locked(i):
			moved += move_slot(b, i, chest)
	b.changed.emit()
	chest.changed.emit()
	return moved


## Deposita simili: dalla Bisaccia (non la barra rapida) solo ciò che la cassa contiene già.
func deposit_similar(chest: Bisaccia) -> int:
	var b: Bisaccia = m.character.bisaccia
	var moved := 0
	for i in range(Bisaccia.HOTBAR, b.slots.size()):
		if b.id_at(i) != "" and not b.locked(i) and chest.count(b.id_at(i)) > 0:
			moved += move_slot(b, i, chest)
	b.changed.emit()
	chest.changed.emit()
	return moved


## Rifornisci: completa dalla cassa le pile che hai già nella Bisaccia (barra rapida compresa: torce, dardi, pozioni).
func restock(chest: Bisaccia) -> int:
	var b: Bisaccia = m.character.bisaccia
	var moved := 0
	for i in b.slots.size():
		var id := b.id_at(i)
		if id == "" or b.slots[i].has("dati") or b.slots[i].has("tratto"):
			continue
		var want := ItemsData.stack_of(id) - b.count_at(i)
		var got := mini(want, chest.count(id))
		if got > 0:
			chest.remove(id, got)
			b.slots[i]["n"] = b.count_at(i) + got
			moved += got
	b.changed.emit()
	return moved


## Il tasto «riponi» (29 set 2026, richiesta dell'utente): «Nelle casse vicine» senza aprire la Bisaccia.
func _unhandled_input(e: InputEvent) -> void:
	if m == null or not m.built or not Keys.pressed(e, "riponi") or not bool(Settings.v("riponi_tasto")):
		return
	get_viewport().set_input_as_handled()
	m.hud.toast(stash_text(quick_stack()))


static func stash_text(r: Dictionary) -> String:
	if int(r["n"]) > 0:
		return "Riposti %d oggetti in %d casse" % [int(r["n"]), int(r["casse"])]
	return "Nessuna cassa vicina li vuole: scegli il tipo di una cassa, o mettici un oggetto uguale"


## Nelle casse vicine: ogni oggetto delle caselle grandi va nella cassa più vicina che lo contiene già, o che raccoglie
## il suo tipo. Restituisce {oggetti spostati, casse usate}.
func quick_stack() -> Dictionary:
	var b: Bisaccia = m.character.bisaccia
	var chests := chests_near(StorageData.STACK_REACH)
	var moved := 0
	var used := {}
	for i in range(Bisaccia.HOTBAR, b.slots.size()):
		var id := b.id_at(i)
		if id == "" or b.locked(i):
			continue                       # (3 ott 2026) le caselle bloccate restano nella Bisaccia
		var cat := StorageData.category_of(id)
		for pass_n in 2:                   # prima chi lo contiene già, poi chi raccoglie il suo tipo
			for o in chests:
				var st := settings(o)
				if st["tipo"] == "nulla":
					continue
				var chest: Bisaccia = m.world.chests[o]
				var ok: bool = chest.count(id) > 0 if pass_n == 0 else st["tipo"] == cat
				if ok:
					var k := move_slot(b, i, chest)
					if k > 0:
						moved += k
						used[o] = true
						chest.changed.emit()
				if b.slots[i].is_empty():
					break
			if b.slots[i].is_empty():
				break
	b.changed.emit()
	return {"n": moved, "casse": used.size()}


# ---- i nomi sopra le casse -----------------------------------------------------------------------------------------

func _update_labels() -> void:
	var want := {}
	for o in chests_near(StorageData.LABEL_REACH):
		var n := String(settings(o)["nome"])
		if n != "":
			want[o] = n
	for o in _labels.keys():
		if not want.has(o) or not m.world.stations.has(o):
			(_labels[o] as Label).queue_free()
			_labels.erase(o)
	for o in want:
		var l: Label = _labels.get(o)
		if l == null:
			l = Label.new()
			l.add_theme_font_size_override("font_size", 9)
			l.add_theme_color_override("font_color", Color("#cfeee4"))
			l.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.05))
			l.add_theme_constant_override("outline_size", 3)
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.z_index = 27
			m.fx.add_child(l)
			_labels[o] = l
		l.text = String(want[o])
		var size: Array = StationsData.STATIONS[String(m.world.stations[o])]["size"]
		l.size = Vector2(120, 12)
		l.position = Vector2(o) * S + Vector2(int(size[0]) * S * 0.5 - 60.0, -13.0)
