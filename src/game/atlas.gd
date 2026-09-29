class_name Atlas
extends Node
## L'Atlante (Roadmap 23, voce 235; dati in `AtlasData`): una scheda per ogni mondo visitato, fuori dal Giardino, in
## `Character.atlante[id del mondo]` = {"nome", "vigore", "geni", "firma", "stelle": {stella: 1}, "meraviglie": {…}}.
## Mentre si gioca, ogni `TICK` secondi guarda le cinque stelle del mondo di adesso e segna le nuove: avviso, conteggio
## «stelle» (maestria dell'esplorazione) e, ogni `EVERY` stelle in tutto, un premio. `AtlasPanel` (tasto O) le mostra.

var m: Node2D
var panel: AtlasPanel
var wonders: Wonders                   # voce 237: le meraviglie del mondo
var pages: BiomePages                  # voce 236: le pagine dei biomi
var _t := 1.0


func setup(main: Node2D) -> void:
	m = main
	panel = AtlasPanel.new()
	m.hud.add_child(panel)
	panel.setup(m, self)
	m.hud.overlays.append(panel)
	pages = BiomePages.new(m)
	wonders = Wonders.new(m)
	if here():
		_record()


## Il mondo di adesso ha una scheda (tutti tranne il Giardino).
func here() -> bool:
	return m.world_id != "" and not (m.get("aiuole") != null and m.aiuole.is_home() and m.world_meta.has("giardino"))


func data() -> Dictionary:
	return m.character.atlante


func entry(wid: String = "") -> Dictionary:
	return data().get(m.world_id if wid == "" else wid, {})


func _record() -> void:
	var e: Dictionary = data().get(m.world_id, {})
	e["nome"] = String(m.world_meta.get("nome", m.world_id))
	e["vigore"] = int(m.world_meta.get("vigore", 1))
	e["geni"] = (m.world_meta.get("geni", []) as Array).duplicate()
	e["firma"] = String((m.world_meta.get("firma", {}) as Dictionary).get("id", ""))
	if not e.has("stelle"):
		e["stelle"] = {}
	if not e.has("meraviglie"):
		e["meraviglie"] = {}
	data()[m.world_id] = e


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = AtlasData.TICK
	pages.visit()                               # voce 236: i biomi si visitano anche nel Giardino
	pages.check()
	if here():
		check()


## Le stelle guadagnate adesso nel mondo di adesso (e le segna). Restituisce quelle nuove.
func check() -> Array:
	if not data().has(m.world_id):
		_record()
	var st: Dictionary = entry()["stelle"]
	var fresh := []
	for s in AtlasData.STARS:
		var id := String(s[0])
		if not st.has(id) and has_star(id):
			st[id] = 1
			fresh.append(id)
	for id in fresh:
		_gain(String(id))
	wonders.check()
	return fresh


## La stella è guadagnata, adesso, in questo mondo?
func has_star(id: String) -> bool:
	match id:
		"mappa":
			return map_frac() >= AtlasData.MAP_FRAC
		"firma":
			return bool((m.world_meta.get("firma", {}) as Dictionary).get("trovata", false))
		"guardiano":
			return String(m.world_meta.get("guardiano", "dorme")) in ["curato", "sconfitto"]
		"sigilli":
			var all := (m.world_meta.get("sigilli", []) as Array).size()
			return all > 0 and int(m.world_meta.get("sigilli_aperti", 0)) >= ceili(all * AtlasData.SEALS_FRAC)
		"segreti":
			var c := Secrets.counts_of(m.world_meta)
			return int(c[1]) > 0 and int(c[0]) >= int(c[1])
	return false


func map_frac() -> float:
	return float(m.map_reveal.explored_count()) / float(maxi(m.world.w * m.world.h, 1))


func _gain(id: String) -> void:
	m.objectives.bump("stelle")
	var n := total()
	var msg := "Atlante: una stella per «%s» (%s)" % [entry()["nome"], AtlasData.star_name(id)]
	if n % AtlasData.EVERY == 0:
		var gift := AtlasData.reward(n / AtlasData.EVERY)
		var parts := []
		for it in gift:
			var rest: int = m.character.bisaccia.add(String(it), int(gift[it]))
			if rest > 0:
				m.drops.spawn(String(it), rest, m.player.position)
			parts.append("%s ×%d" % [String(ItemsData.get_item(String(it)).get("name", it)), int(gift[it])])
		msg += " · %d stelle: %s" % [n, ", ".join(parts)]
	m.hud.toast(msg)
	m.sfx.play("dono")
	if m.get("diary") != null:
		m.diary.note(msg, "atlante")


## Tutte le stelle di tutti i mondi.
func total() -> int:
	var n := 0
	for wid in data():
		n += (data()[wid].get("stelle", {}) as Dictionary).size()
	return n


## Che cosa manca a un mondo (le stelle non ancora prese, con che cosa chiedono).
func missing(wid: String) -> Array:
	var st: Dictionary = entry(wid).get("stelle", {})
	var out := []
	for s in AtlasData.STARS:
		if not st.has(String(s[0])):
			out.append(String(s[0]))
	return out
