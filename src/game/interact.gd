class_name Interact
extends Node
## Smista gli usi che `PlayerActions` non conosce: il clic sinistro con in mano Rugiada o Seme di mondo, e il clic
## destro su una stazione (portale, Cuore, cesta, scrigno). Così i moduli nuovi non gonfiano `PlayerActions`.

const S := 16

var m: Node2D
var chest_panel: ChestPanel


func setup(main: Node2D) -> void:
	m = main
	m.actions.use_hook = _use
	m.actions.touch_hook = touch
	chest_panel = ChestPanel.new()
	m.hud.add_child(chest_panel)
	chest_panel.setup(m.hud.panel)


func _use(kind: String, id: String, c: Vector2i) -> bool:
	match kind:
		"cura":
			if m.world.tile(c.x, c.y) == TileDefs.NODO:
				return m.guardian.cure_at(c)
			# la Rugiada di Linfa purifica anche un grande cerchio di terra avvizzita
			if m.actions.in_reach(c) and m.blight._near_blight(c, Blight.DEW_R) and m.character.bisaccia.remove(id, 1):
				m.hud.toast("La Linfa scorre nella terra malata: %d tessere guarite" % m.blight.purify(c, Blight.DEW_R))
				m.objectives.bump("purificate")
				return true
			return m.guardian.cure_at(c)
		"purifica":
			if m.blight.use_seed(c):
				m.objectives.bump("purificate")
				return true
			return false
		"seme_mondo":
			return m.portal.plant(c, id)
		"dono":
			return Gifts.absorb(m, id)
		"specchio":
			# lo Specchio del guizzo: si torna al punto di partenza del mondo
			Fx.puff(m.fx, m.player.position, Color(0.8, 1.6, 1.7))
			m.snap_to(m.world.spawn)
			m.sfx.play("portale")
			Fx.puff(m.fx, m.player.position, Color(0.8, 1.6, 1.7))
			m.hud.toast("Lo specchio ti riporta alla partenza")
			return true
	return false


## Clic destro su una cella: se c'è una stazione a portata, fa ciò che le spetta. True se ha fatto qualcosa.
func touch(c: Vector2i) -> bool:
	var st: Dictionary = m.world.station_at(c)
	if st.is_empty() or not m.actions.in_reach(c):
		return false
	var id := String(st["id"])
	var o: Vector2i = st["origin"]
	if StationsData.STATIONS[id].has("slots"):
		chest_panel.open(o, m.world.chest_at(o), String(StationsData.STATIONS[id]["name"]))
		m.sfx.play("apri", Vector2(o) * 16.0)
		if id == "scrigno":
			var opened: Array = m.world_meta.get("scrigni_aperti", [])
			if not "%d,%d" % [o.x, o.y] in opened:
				opened.append("%d,%d" % [o.x, o.y])
				m.world_meta["scrigni_aperti"] = opened
				m.objectives.bump("scrigni")
		return true
	match id:
		"portale":
			m.portal.travel(o)
			return true
		"cuore_mondo":
			m.hud.toast("Il Cuore batte piano, malato. %d nodi avvizziti sul soffitto" % m.guardian.nodes_left())
			return true
		"cuore_vivo":
			m.hud.toast("Il Cuore batte forte: il mondo è salvo")
			return true
	return false


func _process(_dt: float) -> void:
	# il fagotto svuotato sparisce: la Bisaccia è recuperata
	if chest_panel.visible and m.world.stations.get(chest_panel.origin, "") == "fagotto" 			and m.world.chest_at(chest_panel.origin).is_empty():
		var o := chest_panel.origin
		chest_panel.close()
		m.world.stations.erase(o)
		m.world.chests.erase(o)
		m.view.remove_station(o)
		m.light.dirty = true
		m.hud.toast("Bisaccia recuperata")
		return
	# allontanandosi dalla cesta aperta, si chiude
	if chest_panel.visible:
		var o := chest_panel.origin
		if (Vector2(o) * S + Vector2(S, S)).distance_to(m.player.position) > (StationsData.REACH + 3) * S:
			chest_panel.close()
