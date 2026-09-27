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
		"provetta":
			return m.sampling.use_vial(id, c)
		"dono":
			return Gifts.absorb(m, id)
		"richiamo":
			return m.keepers.summon(id)
		"tavoletta":
			return m.language.use_tablet(id)           # voce 68
		"secchio":
			return m.liquids.scoop(c)                  # voce 73
		"secchio_pieno":
			return m.liquids.empty_bucket(c, id)
		"mappa":
			if id == "mappa_sigilli":
				return _seal_hint(id)                  # voce 65
			if id == "mappa_firma":
				return _firma_hint(id)
			return _map_hint(id)
		"rampino":
			return m.grapple.fire(id, m.fx.get_global_mouse_position())
		"coltura":
			return m.garden.plant(c, id)
		"compagno":
			return m.companions.toggle_pet(id)
		"laccio":
			return m.taming.lasso(id, m.fx.get_global_mouse_position())      # voce 59
		"vasetto":
			return m.taming.jar(m.fx.get_global_mouse_position())
		"creatura":
			return m.taming.release()
		"uovo":
			m.hud.toast("Un uovo si schiude nell'Incubatrice: posalo lì con il clic destro")
			return false
		"evocatore":
			return m.companions.summon(id)
		"annaffiatoio":
			return m.garden.water(c)
		"parete":
			return m.masonry.place_wall(c, id)
		"esplosivo", "ricurvo", "giavellotto":
			return m.throwing.throw(id, m.fx.get_global_mouse_position())
		"specchio":
			# lo Specchio del guizzo: si torna al punto di partenza del mondo
			Fx.puff(m.fx, m.player.position, Color(0.8, 1.6, 1.7))
			m.snap_to(m.world.spawn)
			m.sfx.play("portale")
			Fx.puff(m.fx, m.player.position, Color(0.8, 1.6, 1.7))
			m.hud.toast("Lo specchio ti riporta alla partenza")
			return true
	return false


## Voce 65, Mappa dei Sigilli: il luogo sigillato più vicino ancora chiuso, e il potere che lo apre.
func _seal_hint(id: String) -> bool:
	var best := Vector2i(-1, -1)
	var kind := ""
	var bd := 1e18
	for e in m.world_meta.get("sigilli", []):
		var c := Vector2i(int(e[1]), int(e[2]))
		var shell := c + Vector2i(-PassSigilli.W / 2 - 1, 0)
		if String(e[0]) != "alto" and not TileDefs.SEAL_KIND.has(m.world.tile(shell.x, shell.y)):
			continue                               # già aperto
		var d: float = (Vector2(c) * S).distance_squared_to(m.player.position)
		if d < bd:
			bd = d
			best = c
			kind = String(e[0])
	if best.x < 0 or not m.character.bisaccia.remove(id, 1):
		m.hud.toast("La mappa non indica niente in questo mondo")
		return false
	var power := "Salto delle spore e Radici-ponte"
	for p in PowersData.POWERS:
		if String(PowersData.POWERS[p]["seal"]) == kind:
			power = String(PowersData.POWERS[p]["name"])
	m.map_reveal.reveal_area(best, 6)
	m.hud.toast("Un luogo sigillato a %d tessere (%s): lo apre «%s». L'ho segnato sulla mappa (M)" % [int(sqrt(bd) / S),
		"in alto nel cielo" if kind == "alto" else _dir(best), power])
	m.sfx.play("apri")
	return true


## Voce 65, Mappa della firma: dove si trova la firma di questo mondo.
func _firma_hint(id: String) -> bool:
	var f: Dictionary = m.signature.info()
	if f.is_empty() or f.get("trovata", false) or not m.character.bisaccia.remove(id, 1):
		m.hud.toast("La firma di questo mondo l'hai già trovata" if f.get("trovata", false) else "Questo mondo non ha una firma")
		return false
	var c := Vector2i(int(f["x"]), int(f["y"]))
	m.map_reveal.reveal_area(c, 8)
	m.hud.toast("La firma di questo mondo è a %d tessere, %s. L'ho segnata sulla mappa (M)" % [
		int((Vector2(c) * S).distance_to(m.player.position) / S), _dir(c)])
	m.sfx.play("apri")
	return true


func _dir(c: Vector2i) -> String:
	var dx: float = c.x * S - m.player.position.x
	var dy: float = c.y * S - m.player.position.y
	return "%s, %s" % ["a destra" if dx > 0.0 else "a sinistra", "più in basso" if dy > 3 * S else ("più in alto" if dy < -3 * S else "alla stessa altezza")]


## La Mappa dei Seminatori: indica il reliquiario più vicino non ancora aperto e lo rivela sulla mappa.
func _map_hint(id: String) -> bool:
	var seen: Array = m.world_meta.get("reliquiari_aperti", [])
	var best := Vector2i(-1, -1)
	var bd := 1e18
	for o in m.world.stations:
		if m.world.stations[o] != "reliquiario" or "%d,%d" % [o.x, o.y] in seen:
			continue
		var d: float = (Vector2(o) * S).distance_squared_to(m.player.position)
		if d < bd:
			bd = d
			best = o
	if best.x < 0:
		m.hud.toast("La mappa non indica più nulla: li hai aperti tutti")
		return false
	if not m.character.bisaccia.remove(id, 1):
		return false
	var dx: float = best.x * S - m.player.position.x
	var dy: float = best.y * S - m.player.position.y
	var where := "a destra" if dx > 0.0 else "a sinistra"
	var depth := "più in basso" if dy > 3 * S else ("più in alto" if dy < -3 * S else "alla stessa altezza")
	m.hud.toast("Un reliquiario a %d tessere %s, %s. L'ho segnato sulla mappa (M)" % [int(sqrt(bd) / S), where, depth])
	m.map_reveal.reveal_area(best + Vector2i(1, 1), 7)
	m.sfx.play("apri")
	return true


## Clic destro su una cella: se c'è una stazione a portata, fa ciò che le spetta. True se ha fatto qualcosa.
func touch(c: Vector2i) -> bool:
	if m.taming.touch(m.fx.get_global_mouse_position()):
		return true                                      # voce 59: nutrire o accarezzare una creatura
	if TileDefs.SEAL_KIND.has(m.world.tile(c.x, c.y)) and m.actions.in_reach(c):
		return m.powers.open_seal(c)                     # voce 64: i Sigilli
	if m.world.tile(c.x, c.y) == TileDefs.PORTA_SEM and m.actions.in_reach(c):
		return m.mechanisms.touch_door(c)                # voce 71: le porte dei luoghi
	var npc: Npc = m.villagers.npc_at(Vector2(c) * S + Vector2(8, 8))
	if npc != null:
		return m.villagers.open_trade(npc)
	if m.garden.harvest(c):
		return true
	var st: Dictionary = m.world.station_at(c)
	if st.is_empty() or not m.actions.in_reach(c):
		return false
	var id := String(st["id"])
	var o: Vector2i = st["origin"]
	if StationsData.STATIONS[id].has("slots"):
		chest_panel.open(o, m.world.chest_at(o), String(StationsData.STATIONS[id]["name"]))
		m.sfx.play("apri", Vector2(o) * 16.0)
		if id == "reliquiario":
			var seen: Array = m.world_meta.get("reliquiari_aperti", [])
			if not "%d,%d" % [o.x, o.y] in seen:
				seen.append("%d,%d" % [o.x, o.y])
				m.world_meta["reliquiari_aperti"] = seen
				m.objectives.bump("reliquiari")
		if id == "scrigno":
			var opened: Array = m.world_meta.get("scrigni_aperti", [])
			if not "%d,%d" % [o.x, o.y] in opened:
				opened.append("%d,%d" % [o.x, o.y])
				m.world_meta["scrigni_aperti"] = opened
				m.objectives.bump("scrigni")
		return true
	match id:
		"porta", "porta_aperta":
			return m.masonry.toggle_door(o)
		"letto":
			return m.masonry.use_bed(o)
		"radice_viandante":
			return m.travel.open_from(o)
		"pianta_seme":
			m.sampling.harvest(o)
			return true
		"banco_innesti":
			m.innesto.open()
			return true
		"nido_erba", "nido_tana", "nido_alveare", "nido_formicaio":
			return m.ecology.touch_nest(o)             # voce 58
		"portale":
			m.portal.touch(o)
			return true
		"albero_madre_0", "albero_madre_1", "albero_madre_2", "albero_madre_3", "albero_madre_4":
			return m.giardino.touch_tree(o)                # voce 62
		"bacheca":
			return m.board.open()                          # voce 67
		"stele":
			return m.language.read(o)                      # voce 68
		"leggio":
			return m.chains.read(o)                        # voce 69
		"braciere", "braciere_acceso", "leva", "leva_su", "piastra", "piastra_premuta", "cristallo_eco", "cristallo_eco_desto":
			return m.mechanisms.touch(o, id)               # voce 71
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
