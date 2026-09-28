class_name Challenges
extends Node
## Le sfide dei Semi (voce 82, dati in `ChallengesData`). Il Sigillo di sfida si usa su un portale non ancora
## attraversato (`seal_portal`: il portale porta "sfida"); il mondo nuovo la riceve in `world_meta["sfida"]`
## = {"id", "livello", "t" (secondi giocati), "stato": "in corso" · "vinta" · "persa"}. Qui si applicano le regole
## (torce spente, tempo, Avvizzimento, solo antiche, Vita fragile, senza ritorno), si mostra la riga sotto l'orologio,
## si vince quando il Guardiano è risolto e si scrive il record in `Character.sfide` (id → {vinte, livello, record}).

var m: Node2D
var state := {}
var _label: Label
var _applied := false
var _hp0 := 0


func setup(main: Node2D) -> void:
	m = main
	state = m.world_meta.get("sfida", {})
	_label = Label.new()
	_label.position = Vector2(400, 44)             # in alto al centro: a sinistra ci sono orologio e obiettivi
	_label.size = Vector2(800, 20)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color("#ffb070"))
	_label.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_label.add_theme_constant_override("outline_size", 5)
	m.hud.add_child(_label)
	_label.add_to_group("hud_alto")
	m.guardian.resolved.connect(_on_resolved)
	m.vitals.died.connect(_on_died)
	apply()


func active() -> bool:
	return String(state.get("stato", "")) == "in corso"


func id() -> String:
	return String(state.get("id", ""))


func level() -> int:
	return int(state.get("livello", 1))


## Le regole della sfida in corso; quando finisce (vinta o persa) si tolgono.
func apply() -> void:
	var on := active()
	m.actions.no_torches = on and id() == "buio"
	m.fauna.force_ancient = on and id() == "antiche"
	if on and not _applied:
		_applied = true
		match id():
			"avvizzimento":
				m.blight.spread_mult *= ChallengesData.BLIGHT_MULT
				m.fauna.world_danger += ChallengesData.DANGER
			"fragile":
				_hp0 = m.vitals.hp_max
				var k := maxf(ChallengesData.FRAGILE - ChallengesData.FRAGILE_STEP * (level() - 1), 0.2)
				m.vitals.hp_max = maxi(roundi(_hp0 * k), 20)
				m.vitals.hp = mini(m.vitals.hp, m.vitals.hp_max)
				m.vitals.changed.emit()
	elif not on and _applied:
		_applied = false
		match id():
			"avvizzimento":
				m.blight.spread_mult /= ChallengesData.BLIGHT_MULT
				m.fauna.world_danger -= ChallengesData.DANGER
			"fragile":
				m.vitals.hp_max = _hp0
				m.vitals.changed.emit()
	_label.visible = not state.is_empty()


## Il Sigillo di sfida su un portale (clic con il Sigillo in mano). True se l'ha messo.
func seal_portal(c: Vector2i, item: String) -> bool:
	var st: Dictionary = m.world.station_at(c)
	if st.is_empty() or String(st["id"]) != "portale" or not m.actions.in_reach(c):
		m.hud.toast("Il Sigillo di sfida si usa su un portale")
		return false
	var e: Dictionary = m.portal._portals().get(Portal._key(st["origin"]), {})
	if e.is_empty() or e.get("ritorno", false) or String(e.get("mondo", "")) != "":
		m.hud.toast("La sfida si mette solo su un portale verso un mondo mai visitato")
		return false
	var cid := ChallengesData.of_item(item)
	if not m.character.bisaccia.remove(item, 1):
		return false
	e["sfida"] = cid
	m.hud.toast("Il portale porta la sfida «%s» (livello %d)" % [ChallengesData.LIST[cid]["name"], next_level(cid)])
	m.sfx.play("incanto", Vector2(c) * 16.0)
	return true


## Il livello della prossima sfida di questo tipo per il personaggio.
func next_level(cid: String) -> int:
	return int((m.character.sfide.get(cid, {}) as Dictionary).get("livello", 0)) + 1


## Il mondo nuovo: la sfida portata dal portale (lo chiama `main` prima di montare i moduli, o le prove).
static func start(meta: Dictionary, cid: String, lvl: int) -> void:
	meta["sfida"] = {"id": cid, "livello": lvl, "t": 0.0, "stato": "in corso"}


func _process(dt: float) -> void:
	if not m.built or state.is_empty():
		return
	if active():
		state["t"] = float(state.get("t", 0.0)) + dt
		if id() == "tempo" and float(state["t"]) > ChallengesData.limit(level()):
			lose("il tempo è finito")
	_label.text = line()


func line() -> String:
	var d: Dictionary = ChallengesData.LIST.get(id(), {})
	var t := float(state.get("t", 0.0))
	var s := "Sfida «%s» liv. %d" % [d.get("name", "?"), level()]
	match String(state.get("stato", "")):
		"vinta":
			return s + " · vinta in %s" % clock(t)
		"persa":
			return s + " · persa"
	if id() == "tempo":
		return s + " · restano %s" % clock(maxf(ChallengesData.limit(level()) - t, 0.0))
	return s + " · %s" % clock(t)


static func clock(t: float) -> String:
	return "%d:%02d" % [int(t) / 60, int(t) % 60]


func _on_died() -> void:
	if active() and id() == "senza_ritorno":
		lose("sei appassito")


func lose(why: String) -> void:
	state["stato"] = "persa"
	apply()
	m.hud.toast("Sfida persa: %s. Il mondo resta, senza la sfida." % why)


func _on_resolved(_how: String) -> void:
	if active():
		win()


## Vittoria: premio secondo il livello, medaglia la prima volta, record del personaggio.
func win() -> Dictionary:
	state["stato"] = "vinta"
	apply()
	var cid := id()
	var lvl := level()
	var rec: Dictionary = m.character.sfide.get(cid, {"vinte": 0, "livello": 0, "record": 0.0})
	var first := int(rec["vinte"]) == 0
	rec["vinte"] = int(rec["vinte"]) + 1
	rec["livello"] = maxi(int(rec["livello"]), lvl)
	var t := float(state.get("t", 0.0))
	var best := float(rec.get("record", 0.0)) <= 0.0 or t < float(rec["record"])
	if best:
		rec["record"] = t
	m.character.sfide[cid] = rec
	var at: Vector2 = m.player.position + Vector2(0, -24)
	for k in ChallengesData.REWARD:
		m.drops.spawn(k, int(ChallengesData.REWARD[k]) * lvl, at)
	if first:
		m.drops.spawn(String(ChallengesData.LIST[cid]["medal"]), 1, at)
	m.objectives.bump("sfide")
	m.hud.toast("Sfida vinta: «%s» livello %d in %s%s" % [ChallengesData.LIST[cid]["name"], lvl, clock(t),
		" — nuovo record!" if best else ""])
	return rec


## I record per il Semenzaio e l'Enciclopedia: una riga per sfida.
static func records(ch: Character) -> Array:
	var out := []
	for cid in ChallengesData.LIST:
		var r: Dictionary = ch.sfide.get(cid, {}) if ch != null else {}
		var d: Dictionary = ChallengesData.LIST[cid]
		if r.is_empty():
			out.append([String(d["name"]), "mai vinta · %s" % d["desc"]])
		else:
			var n := int(r["vinte"])
			out.append([String(d["name"]), "vinta %d %s · livello %d · tempo migliore %s" % [n, "volta" if n == 1 else "volte",
				int(r["livello"]), clock(float(r.get("record", 0.0)))]])
	return out
