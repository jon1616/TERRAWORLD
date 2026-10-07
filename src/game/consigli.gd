class_name Consigli
extends Node
## I consigli alla prima volta (28 set 2026, richiesta dell'utente): la prima volta che succede una cosa nuova (la notte,
## il buio sotto terra, un blocco troppo duro, la Bisaccia piena…) compare una scheda breve a destra, una volta sola
## per personaggio (`Character.guida["consigli"]`). Mentre si vede, il tasto dell'Enciclopedia apre il suo capitolo.
## I testi stanno in `ConsigliData`; qui c'è una condizione per consiglio (`_c_<id>`). Si spengono dalle Opzioni
## («consigli»); nelle prove sono fermi (`paused`), tranne nella loro.

const SHOW_TIME := 16.0
const EVERY := 0.5

var m: Node2D
var paused := false
var shown_id := ""                       # il consiglio sulla scheda adesso ("" = nessuno)
var _card: PanelContainer
var _title: Label
var _text: RichTextLabel
var _foot: Label
var _left := 0.0
var _t := 1.0
var _built_t := 0.0
var _flags := {}                         # le cose successe in un istante (blocco duro, rara, appassito, Bisaccia aperta)


func setup(main: Node2D) -> void:
	m = main
	paused = "--prove" in OS.get_cmdline_user_args()
	_card = PanelContainer.new()
	_card.add_theme_stylebox_override("panel", UiFrames.padded("forte", "normale", UiPalette.AMBRA, Vector2(14, 12)))
	_card.position = Vector2(1180, 560)
	_card.custom_minimum_size = Vector2(404, 0)
	_card.size = Vector2(404, 10)
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.visible = false
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(box)
	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 17)
	_title.add_theme_color_override("font_color", Color("#ffd08a"))
	box.add_child(_title)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.fit_content = true
	_text.custom_minimum_size = Vector2(380, 0)
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text.add_theme_font_size_override("normal_font_size", 14)
	_text.add_theme_font_size_override("bold_font_size", 14)
	_text.add_theme_color_override("default_color", Color("#dff5ee"))
	box.add_child(_text)
	_foot = Label.new()
	_foot.add_theme_font_size_override("font_size", 12)
	_foot.add_theme_color_override("font_color", Color("#6a8a84"))
	box.add_child(_foot)
	m.hud.add_child(_card)
	m.actions.too_hard.connect(func() -> void: _flags["piccone"] = true)
	m.fauna.rare_spawned.connect(func(_c: Creature) -> void: _flags["rara"] = true)
	m.vitals.died.connect(func() -> void: _flags["appassito"] = true)


func seen() -> Dictionary:
	var g: Dictionary = m.character.guida
	if not g.has("consigli"):
		g["consigli"] = {}
	return g["consigli"]


func _process(dt: float) -> void:
	if not m.built:
		return
	_built_t += dt
	# ciò che si vede solo mentre un pannello è aperto: il consiglio arriva dopo, a pannello chiuso
	if m.hud.panel.visible:
		_flags["bisaccia"] = true
	if m.interact.chest_panel.visible:
		_flags["cassa"] = true
	var open: bool = m.hud.is_open()
	_card.visible = shown_id != "" and not open
	if shown_id != "" and not open:
		_left -= dt
		_card.modulate.a = clampf(_left / 1.0, 0.0, 1.0)
		if _left <= 0.0:
			hide_card()
	_t -= dt
	if _t > 0.0 or paused or open or shown_id != "" or not bool(Settings.v("consigli")):
		return
	_t = EVERY
	check()


## Cerca il primo consiglio non ancora visto la cui condizione è vera, e lo mostra. Restituisce il suo id.
func check() -> String:
	for c in ConsigliData.LIST:
		var id := String(c["id"])
		if seen().has(id):
			continue
		if bool(call("_c_" + id)):
			show_tip(id)
			return id
	return ""


func show_tip(id: String) -> void:
	var c := ConsigliData.by_id(id)
	seen()[id] = 1
	shown_id = id
	_left = SHOW_TIME
	_card.modulate.a = 1.0
	_title.text = String(c["title"])
	_text.text = _fill(String(c["text"]))
	_foot.text = "%s: leggi nell'Enciclopedia" % Keys.label("enciclopedia")
	m.encyclopedia.next_addr = "cap:%s" % c["cap"]
	_card.size = Vector2(404, 10)
	_card.visible = true
	m.sfx.play("obiettivo")


func hide_card() -> void:
	shown_id = ""
	_card.visible = false
	m.encyclopedia.next_addr = ""


## Il testo sulla scheda (per le prove).
func card_text() -> String:
	return "%s · %s" % [_title.text, _text.get_parsed_text()] if shown_id != "" else ""


static func _fill(t: String) -> String:
	for a in ["filo", "semenzaio", "bisaccia", "enciclopedia", "compagno", "cambia_compagno", "compagni"]:
		t = t.replace("{%s}" % a, Keys.label(a))
	return t


# ---------------------------------------------------------------- le condizioni (una per consiglio)

## Voce 355: il primo materiale del profondo nella Bisaccia.
func _c_risveglio() -> bool:
	for id in AwakenData.DEEP.values():
		if m.character.bisaccia.count(String(id)) > 0:
			return true
	return false


## Roadmap 52: in piedi su una terra che fa qualcosa (frana, scivola, appiccica, attutisce).
func _c_terra_viva() -> bool:
	var p: Player = m.player
	if not p.on_floor:
		return false
	var t: int = m.world.tile(floori(p.position.x / 16.0), floori((p.position.y + Player.HALF.y + 2.0) / 16.0))
	return TileDefs.FALLS[t] == 1 or TileDefs.SLIP[t] < 1.0 or TileDefs.STICK[t] < 1.0 or TileDefs.SOFT[t] < 1.0


## Roadmap 52: una corda, una liana o una catena nella Bisaccia, o aggrappato a una.
func _c_corde() -> bool:
	if m.player.climbing:
		return true
	for d in TileDefs.CLIMBS:
		if m.character.bisaccia.count(String(TileDefs.CLIMBS[d]["item"])) > 0:
			return true
	return false


## Voce 353: il commercio aperto con un abitante che ha dei servizi.
func _c_servizi() -> bool:
	var tp: TradePanel = m.villagers.panel if m.get("villagers") != null else null
	return tp != null and tp.visible and tp.npc != "" and not ServicesData.of_npc(tp.npc).is_empty()


func _c_benvenuto() -> bool:
	return _built_t > 3.0


func _c_lista() -> bool:
	return _flags.get("bisaccia", false) and not m.hud.panel.visible


func _c_notte() -> bool:
	return m.day.is_night()


func _c_sottoterra() -> bool:
	return m.depth_watch.stratum >= 1


func _c_profondo() -> bool:
	return m.depth_watch.stratum >= 2


## Voce 188: in uno strato con una Scorza troppo bassa per quel punto della partita.
func _c_armatura() -> bool:
	return m.depth_watch.stratum >= 1 and DangerData.scorza_warning(m.depth_watch.scorza(), m.depth_watch.stratum,
		m.fauna.vigor) != ""


func _c_piccone() -> bool:
	return _flags.get("piccone", false)


func _c_vita_bassa() -> bool:
	return m.vitals.hp > 0 and m.vitals.hp < m.vitals.hp_max * 0.35


func _c_appassito() -> bool:
	return _flags.get("appassito", false)


func _c_piena() -> bool:
	return m.character.bisaccia.slots.all(func(s: Dictionary) -> bool: return not s.is_empty())


func _c_stazione() -> bool:
	return "ceppo" in m.world.stations.values()


func _c_cassa() -> bool:
	return _flags.get("cassa", false)


func _c_acqua() -> bool:
	return m.liquids.bar.visible


func _c_seme() -> bool:
	for s in m.character.bisaccia.slots:
		if not s.is_empty() and String(ItemsData.get_item(String(s["id"])).get("kind", "")) == "seme_mondo":
			return true
	return false


func _c_rara() -> bool:
	return _flags.get("rara", false)


func _c_guardiano() -> bool:
	return m.guardian.boss != null and is_instance_valid(m.guardian.boss)


func _c_gene() -> bool:
	return int(m.character.stats.get("geni_imparati", 0)) > 0


func _c_canna() -> bool:
	return String(ItemsData.get_item(String(m.hud.current().get("id", ""))).get("kind", "")) == "canna"


func _c_cassa_pescata() -> bool:
	for s in m.character.bisaccia.slots:
		if not s.is_empty() and String(ItemsData.get_item(String(s["id"])).get("kind", "")) == "cassetta":
			return true
	return false


# ---------------------------------------------------------------- Roadmap 15

func _c_allerta() -> bool:
	for c in m.fauna.list:
		if c.mind.state == Mind.ALERT and c.position.distance_to(m.player.position) < 14.0 * 16.0 and not c.docile:
			return true
	return false


func _c_stanza() -> bool:
	return m.get("rooms") != null and not m.rooms.current.is_empty() and String(m.rooms.current.get("type", "")) != "stanza"


func _c_marea() -> bool:
	return m.get("tides") != null and (m.tides.pending != "" or m.tides.active != "")


func _c_signore() -> bool:
	return String(ItemsData.get_item(String(m.hud.current().get("id", ""))).get("kind", "")) == "esca_signore"


func _c_studiata() -> bool:
	return int(m.character.stats.get("studiate", 0)) >= 1


func _c_progetto() -> bool:
	return String(ItemsData.get_item(String(m.hud.current().get("id", ""))).get("kind", "")) == "progetto_sem"


# ---------------------------------------------------------------- Roadmap 16

func _c_cielo() -> bool:
	return m.get("chiome") != null and m.chiome.here != ""


func _c_aria_sottile() -> bool:
	return m.get("harsh") != null and m.harsh.kind == "quota"


func _c_fulmine() -> bool:
	return m.get("strikes") != null and not m.strikes.pending.is_empty()


func _c_fagiolo() -> bool:
	return String(ItemsData.get_item(String(m.hud.current().get("id", ""))).get("kind", "")) == "fagiolo"


# ---------------------------------------------------------------- Roadmap 17

func _c_prima_stele() -> bool:
	return int(m.character.stats.get("stele", 0)) > 0


func _c_prima_ipotesi() -> bool:
	for w in m.character.lingua:
		if m.language.state(String(w)) == Language.IPOTESI:
			return true
	return false


func _c_prima_certa() -> bool:
	return m.language.count() > 0


func _c_scrigno_parola() -> bool:
	return m.word_chests != null and m.word_chests.panel.visible



# ---------------------------------------------------------------- Roadmap 19

func _c_pinza() -> bool:
	return String(m.hud.current().get("id", "")) == "pinza_vene"


func _c_rete_ferma() -> bool:
	if m.get("energy") == null:
		return false
	var p: Vector2 = m.player.position
	for mc: Machine in m.energy.machines.values():
		if mc.net < 0 and mc.role() in ["macchina", "sorgente", "riserva"] and not mc.d.get("gen", false) \
				and mc.center().distance_to(p) < 160.0:
			return true
	return false


func _c_tempesta_linfa() -> bool:
	return m.get("events") != null and String(m.events.active) == "tempesta_linfa"


func _c_centrale() -> bool:
	if m.get("energy") == null:
		return false
	var p: Vector2 = m.player.position
	for mc: Machine in m.energy.machines.values():
		if mc.id == "cuore_centrale" and mc.center().distance_to(p) < 320.0:
			return true
	return false


func _c_succhiavena() -> bool:
	return m.get("wiles") != null and m.wiles.sucked > 0


# ---------------------------------------------------------------- Roadmap 20

func _c_maestria() -> bool:
	if m.get("mastery") == null:
		return false
	for p in MasteryData.ORDER:
		if m.mastery.grade(p) >= 1:
			return true
	return false


# ---------------------------------------------------------------- Roadmap 21

func _c_perduto() -> bool:
	return m.get("lost_gardens") != null and m.lost_gardens.active()


func _c_bellezza() -> bool:
	return int(m.character.stats.get("bellezza_max", 0)) >= 20


func _c_visitatore() -> bool:
	return m.get("visitors") != null and m.visitors.npc != null


func _c_storia() -> bool:
	for nid in NpcStoriesData.STORIES:
		if int(m.character.stats.get("richiesta_" + String(nid), 0)) >= (NpcData.NPCS[nid].get("quests", []) as Array).size():
			return true
	return false


func _c_stella() -> bool:
	return int(m.character.stats.get("stelle", 0)) >= 1


func _c_meraviglia() -> bool:
	return int(m.character.stats.get("meraviglie", 0)) >= 1


func _c_stirpe() -> bool:
	return int(m.character.stats.get("uova_allevate", 0)) >= 1


func _c_incrocio() -> bool:
	return int(m.character.stats.get("ibridi", 0)) >= 1


func _c_ricettario() -> bool:
	return int(m.character.stats.get("raccolti", 0)) >= 5


func _c_tecnica() -> bool:
	for f in ArtsData.FORMS:
		if int(m.character.stats.get("arte_" + String(f), 0)) >= ArtsData.points_for(int(ArtsData.TECH_RANKS[0])):
			return true
	return false


func _c_taglia() -> bool:
	return int(m.character.stats.get("guardiani", 0)) >= 1 and m.get("bounties") != null and not m.bounties.open_list().is_empty()


func _c_cronaca() -> bool:
	for k in (m.character.erbario.get("oggetti", {}) as Dictionary):
		if String(k).begins_with("cronaca_"):
			return true
	return false


func _c_fossile() -> bool:
	return int(m.character.stats.get("fossili", 0)) >= 1


func _c_medaglia_pesca() -> bool:
	return int(m.character.stats.get("medaglie_pesca", 0)) >= 1


func _c_contratto() -> bool:
	return int(m.character.stats.get("contratti", 0)) >= 1


func _c_atto_terzo() -> bool:
	return int(m.character.stats.get("albero", 0)) >= 24


func _c_seme_oro() -> bool:
	return int(m.character.stats.get("semi_oro", 0)) >= 1


## Roadmap 30: la Bisaccia (non la barra rapida) quasi piena.
func _c_zaino_pieno() -> bool:
	var b: Bisaccia = m.character.bisaccia
	var free := 0
	for i in range(Bisaccia.HOTBAR, b.slots.size()):
		if b.slots[i].is_empty():
			free += 1
	return free <= 3


func _c_baccello() -> bool:
	return int(m.character.stats.get("baccelli_aperti", 0)) >= 1


func _c_incontro() -> bool:
	return not (m.world_meta.get("incontri", {}) as Dictionary).is_empty()


func _c_pagina() -> bool:
	return m.character.bisaccia.count(EncountersData.PAGE_ITEM) > 0


## Roadmap 32: la prima creatura nella Sacca dei legami, il primo KO, il primo oggetto per i compagni.
func _c_primo_compagno() -> bool:
	return m.get("bonds") != null and not m.bonds.bag().is_empty()


func _c_compagno_ko() -> bool:
	if m.get("bonds") == null:
		return false
	for r in m.bonds.bag():
		if bool(r.get("ko", false)):
			return true
	return false


func _c_oggetto_compagno() -> bool:
	var b: Bisaccia = m.character.bisaccia
	for i in b.slots.size():
		var id := b.id_at(i)
		if id != "" and BondsData.items().has(id) and String(BondsData.items()[id].get("kind", "")) == "legame":
			return true
	return false
