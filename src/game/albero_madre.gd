class_name AlberoMadre
extends Node
## Gli stadi dell'Albero-Madre (voce 63, dati in `MotherTreeData`, pannello `AlberoPanel`): il motivo della partita.
## Lo stato è del personaggio (`Character.albero` = {"stadio", "offerte": {indice: quanti già dati}}), perché i doni
## (poteri, Aiuole, categorie d'innesto) valgono in ogni mondo; l'Albero però si nutre e si sveglia solo nel Giardino.
## - Le offerte di oggetti si portano anche a più riprese (`offer`: prende dalla Bisaccia e dalle casse vicine); i
##   traguardi si leggono dai conteggi del personaggio.
## - Quando tutte le offerte dello stadio ci sono, `awaken` lo fa crescere: disegno nuovo nel Giardino, Aiuole in più,
##   poteri, abitanti, categorie d'innesto, una pagina di storia.
## - In ogni mondo, sotto gli obiettivi, una riga dice che cosa chiede adesso l'Albero (il filo da seguire).
## Un personaggio senza Giardino (le prove nel «Mondo di prova») non ha limiti d'innesto né la riga (`has_garden`).

const S := 16

var m: Node2D
var panel: AlberoPanel
var _label: Label
var _t := 0.0
signal grew(stage: int)


func setup(main: Node2D) -> void:
	m = main
	if m.character.albero.is_empty():
		m.character.albero = {"stadio": 0, "offerte": {}}
	_label = Label.new()
	_label.position = Vector2(16, 186)
	_label.size = Vector2(520, 60)
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color("#8ef0d8"))
	_label.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_label.add_theme_constant_override("outline_size", 5)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.hud.add_child(_label)
	panel = AlberoPanel.new()
	m.hud.add_child(panel)
	panel.setup(m, self)
	grew.connect(func(_s: int) -> void: panel._dirty = true)
	m.hud.overlays.append(panel)
	_apply()


func has_garden() -> bool:
	return int(m.character.stats.get("giardino", 0)) == 1


func stage() -> int:
	return int(m.character.albero.get("stadio", 0))


func done() -> bool:
	return stage() >= MotherTreeData.STAGES.size()


func current() -> Dictionary:
	return {} if done() else MotherTreeData.STAGES[stage()]


## Quanto manca a un'offerta: [quanti ne hai già dato o raggiunto, quanti ne servono].
func progress(i: int) -> Array:
	var o: Dictionary = current()["offers"][i]
	var need := int(o["n"])
	if o.has("stat"):
		return [mini(int(m.character.stats.get(String(o["stat"]), 0)), need), need]
	return [mini(int((m.character.albero["offerte"] as Dictionary).get(str(i), 0)), need), need]


func ready_to_wake() -> bool:
	if done():
		return false
	for i in (current()["offers"] as Array).size():
		var p := progress(i)
		if int(p[0]) < int(p[1]):
			return false
	return true


## Offre all'Albero tutto ciò che si ha di ciò che chiede (Bisaccia e casse vicine). Restituisce quanti oggetti.
func offer() -> int:
	if done():
		return 0
	var given := 0
	var off: Dictionary = m.character.albero["offerte"]
	var offers: Array = current()["offers"]
	for i in offers.size():
		var o: Dictionary = offers[i]
		if not o.has("item"):
			continue
		var p := progress(i)
		var k := mini(int(p[1]) - int(p[0]), Crafting.have(m.character.bisaccia, String(o["item"])))
		if k > 0 and Crafting.take(m.character.bisaccia, String(o["item"]), k):
			off[str(i)] = int(p[0]) + k
			given += k
	if given > 0:
		m.sfx.play("dono")
		Fx.puff(m.fx, _tree_pos(), Color(0.9, 1.7, 1.4))
	return given


## Lo stadio è completo: l'Albero cresce e dona.
func awaken() -> bool:
	if not ready_to_wake():
		return false
	var st: Dictionary = current()
	m.character.albero["stadio"] = stage() + 1
	m.character.albero["offerte"] = {}
	var gv: Dictionary = st["gives"]
	var news := []
	if gv.has("aiuola"):
		news.append("un'Aiuola in più")
	if gv.has("power"):
		news.append("il potere «%s»" % PowersData.POWERS[gv["power"]]["name"])
	if gv.has("npc"):
		news.append("arriverà %s" % NpcData.name_of(String(gv["npc"])))
	if gv.has("graft"):
		news.append("si possono innestare i geni di %s" % ", ".join(gv["graft"]))
	_apply()
	m.objectives.bump("albero")
	Fx.puff(m.fx, _tree_pos(), Color(1.2, 1.8, 1.4))
	Fx.puff(m.fx, _tree_pos() + Vector2(0, -60), Color(1.6, 1.6, 1.0))
	m.sfx.play("portale")
	if gv.has("lore"):
		m.guardian.lore.show_page(String(gv["lore"]))
	m.hud.toast("L'Albero-Madre cresce: «%s». %s" % [st["name"], ("Dona: " + ", ".join(news)) if not news.is_empty() else ""])
	grew.emit(stage())
	m.save_game()
	return true


## Mette in pratica ciò che lo stadio ha dato: Aiuole, disegno dell'Albero nel Giardino, poteri (`Powers`).
func _apply() -> void:
	var s := stage()
	if has_garden():
		m.aiuole.bonus = MotherTreeData.aiuole(s)
	if m.giardino.active:
		var ph := MotherTreeData.phase(s)
		var o: Vector2i = m.giardino.tree_o
		var want := "albero_madre_%d" % ph
		if o.x >= 0 and String(m.world.stations.get(o, "")) != want:
			m.world.stations[o] = want
			m.world.stations_changed()
			m.view.remove_station(o)
			m.view.add_station(o)
			m.light.dirty = true
	if "powers" in m and m.powers != null:
		m.powers.refresh()
	_t = 0.0


func _tree_pos() -> Vector2:
	var o: Vector2i = m.giardino.tree_o
	return Vector2(o) * S + Vector2(72, 120) if o.x >= 0 else m.player.position


## Clic destro sull'Albero (da `Giardino.touch_tree`): il pannello degli stadi.
func open() -> bool:
	panel.open()
	return true


## Le categorie di geni che il Banco dell'Innestatrice sa innestare (tutte, per chi non ha un Giardino).
func graftable() -> Array:
	return GenesData.CATEGORIES if not has_garden() else MotherTreeData.graftable(stage())


func _process(dt: float) -> void:
	if not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = 1.0
	# la riga che dice che cosa chiede adesso l'Albero, in ogni mondo
	_label.visible = has_garden() and not m.hud.is_open() and bool(Settings.v("riga_albero"))
	if not _label.visible:
		return
	if done():
		_label.text = "Albero-Madre: sveglio"
		return
	var parts := []
	var offers: Array = current()["offers"]
	for i in offers.size():
		var o: Dictionary = offers[i]
		var p := progress(i)
		var what := String(o.get("text", ItemsData.get_item(String(o.get("item", ""))).get("name", "")))
		parts.append("%s %d/%d" % [what, int(p[0]), int(p[1])] if int(p[0]) < int(p[1]) else "%s ✓" % what)
	_label.text = "Albero-Madre, «%s»: %s%s" % [current()["name"], " · ".join(parts),
		"  → torna all'Albero!" if ready_to_wake() else ""]
