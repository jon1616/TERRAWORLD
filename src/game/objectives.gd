class_name Objectives
extends Node
## Gli obiettivi del Germogliato (voce 16): controlla ogni secondo le condizioni di `ObjectivesData`, segna quelli
## raggiunti (`Character.obiettivi`, salvati con il personaggio), dà la ricompensa e mostra in alto a sinistra i
## prossimi tre. Tiene anche i conteggi del personaggio che servono alle condizioni (`Character.stats`): notti
## superate, scrigni aperti, viaggi tra i mondi, Cuore trovato.

const EVERY := 1.0

var m: Node2D
var _t := 0.5
var _label: RichTextLabel
var _last_day := -1
var paused := false                    # le prove li fermano: le ricompense cambierebbero i conti delle altre prove


func setup(main: Node2D) -> void:
	m = main
	_label = RichTextLabel.new()
	_label.bbcode_enabled = true
	_label.fit_content = true
	_label.position = Vector2(16, 94)
	_label.size = Vector2(520, 120)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("normal_font_size", 14)
	_label.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_label.add_theme_constant_override("outline_size", 5)
	m.hud.add_child(_label)
	_last_day = m.day.day
	refresh_label()


func stats() -> Dictionary:
	return m.character.stats


## Aggiunge 1 a un conteggio del personaggio (scrigni aperti, viaggi…).
func bump(stat: String) -> void:
	stats()[stat] = int(stats().get(stat, 0)) + 1


func done(id: String) -> bool:
	return id in m.character.obiettivi


func _process(dt: float) -> void:
	if not m.built:
		return
	# una notte superata: il contatore dei giorni è andato avanti mentre si giocava
	if m.day.day != _last_day:
		_last_day = m.day.day
		bump("notti")
	_t -= dt
	if _t > 0.0 or paused:
		return
	_t = EVERY
	check_all()


## Controlla gli obiettivi non ancora raggiunti (in ordine, ma anche quelli più avanti possono scattare prima).
func check_all() -> int:
	var n := 0
	for o in ObjectivesData.LIST:
		if not done(String(o["id"])) and _met(o["check"]):
			_complete(o)
			n += 1
	if n > 0:
		refresh_label()
	return n


func _complete(o: Dictionary) -> void:
	m.character.obiettivi.append(String(o["id"]))
	var got := []
	for id in o["reward"]:
		var q := int(o["reward"][id])
		var rest: int = m.character.bisaccia.add(id, q)
		if rest > 0:
			m.drops.spawn(id, rest, m.player.position)
		got.append("%d %s" % [q, ItemsData.get_item(id)["name"]])
	m.hud.toast("Obiettivo raggiunto: %s — ricevi %s" % [o["text"], ", ".join(got)])
	m.sfx.play("obiettivo")


func _met(c: Dictionary) -> bool:
	var b: Bisaccia = m.character.bisaccia
	if c.has("item"):
		var have := b.count(String(c["item"]))
		for k in b.equip:
			if b.equip[k] == c["item"]:
				have += 1
		return have >= int(c["n"])
	if c.has("station"):
		return String(c["station"]) in m.world.stations.values()
	if c.has("stratum"):
		return int(stats().get("strato_max", 0)) >= int(c["stratum"])
	if c.has("stat"):
		return int(stats().get(String(c["stat"]), 0)) >= int(c["n"])
	if c.has("kill"):
		return int((m.erbario.data["creature"] as Dictionary).get(String(c["kill"]), 0)) >= int(c["n"])
	if c.has("equip"):
		for k in b.equip:
			if Bisaccia.kind_of_slot(k) == String(c["equip"]):
				return true
		return false
	if c.has("guardian"):
		return String(m.world_meta.get("guardiano", "")) in ["sconfitto", "curato"]
	if c.has("erbario"):
		return m.erbario.percent() >= float(c["erbario"])
	if c.has("set"):
		return not m.gear.sets.is_empty()
	if c.has("collezione"):
		return m.gear.relics.size() >= int(c["collezione"])
	if c.has("any"):
		for id in c["any"]:
			if b.count(String(id)) > 0 or String(id) in b.equip.values():
				return true
		return false
	return false


func refresh_label() -> void:
	var t := "[color=#ffd08a]Obiettivi[/color]   [color=#6a8a84]%d su %d[/color]\n" % [m.character.obiettivi.size(),
		ObjectivesData.LIST.size()]
	var shown := 0
	for o in ObjectivesData.LIST:
		if done(String(o["id"])):
			continue
		t += "[color=#cfeee4]• %s[/color]\n" % o["text"]
		shown += 1
		if shown >= ObjectivesData.SHOWN:
			break
	if shown == 0:
		t += "[color=#8ef0d8]Tutti raggiunti: il Giardino ti aspetta oltre i portali.[/color]"
	_label.text = t
