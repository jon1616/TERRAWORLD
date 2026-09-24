class_name Portal
extends Node
## Il Seme di mondo e il portale (voce 8, «anche solo come prova»). Il seme si pianta sul terreno: cresce un arco di
## radici con un vortice di Linfa. Toccandolo (clic destro) si salva e si passa al mondo nato da quel seme: la prima
## volta viene generato, poi si torna sempre allo stesso (`world_meta["portale_mondo"]`).
## Il seme del mondo nuovo nasce dal seme di questo mondo: stesso portale, stesso mondo, su ogni computer.
## Più avanti (Roadmap 2) i semi avranno specie, vigore e tratti, e si pianteranno nelle Aiuole del Giardino.

const GAME_SCENE := "res://src/game/main.tscn"

var m: Node2D


func setup(main: Node2D) -> void:
	m = main
	m.actions.use_hook = _use
	m.actions.touch_hook = _touch


## Clic sinistro con in mano qualcosa che PlayerActions non conosce.
func _use(kind: String, id: String, c: Vector2i) -> bool:
	match kind:
		"cura":
			return m.guardian.cure_at(c)
		"seme_mondo":
			return plant(c, id)
	return false


## Clic destro: il portale porta via, il Cuore dice come sta.
func _touch(c: Vector2i) -> bool:
	var st: Dictionary = m.world.station_at(c)
	if st.is_empty() or not m.actions.in_reach(c):
		return false
	match String(st["id"]):
		"portale":
			travel()
			return true
		"cuore_mondo":
			m.hud.toast("Il Cuore batte piano, malato. %d nodi avvizziti sul soffitto" % m.guardian.nodes_left())
			return true
		"cuore_vivo":
			m.hud.toast("Il Cuore batte forte: il mondo è salvo")
			return true
	return false


## Pianta il Seme di mondo con il mouse sul punto più basso al centro dell'arco (3×4 tessere, pavimento sotto).
func plant(c: Vector2i, id: String) -> bool:
	var o := c - Vector2i(1, 3)
	if not m.actions.in_reach(c) or not m.world.station_fits("portale", o):
		m.hud.toast("Serve spazio libero (3×4) e un pavimento sotto")
		return false
	var b: Bisaccia = m.character.bisaccia
	if not b.remove(id, 1):
		return false
	m.world.stations[o] = "portale"
	m.view.add_station(o)
	m.light.dirty = true
	m.guardian.lore.show_page("portale")
	return true


## Il mondo dall'altra parte: [id, nome, seme]; l'id è vuoto se non esiste ancora.
func destination() -> Array:
	var sd: int = hash([m.world.world_seed, "portale"]) & 0x7fffffff
	var id := String(m.world_meta.get("portale_mondo", ""))
	if id != "" and WorldSave.read_meta(id).is_empty():
		id = ""                                # il mondo è stato cancellato: si rigenera
	return [id, "Oltre %s" % String(m.world_meta.get("nome", "il portale")), sd]


func travel() -> void:
	var dest := destination()
	if String(dest[0]) != "":
		Session.start_saved_world(String(dest[0]))
	else:
		var nid := SavePaths.new_id(String(dest[1]))
		m.world_meta["portale_mondo"] = nid
		Session.start_new_world(String(dest[1]), int(dest[2]), nid)
	m.save_game()
	get_tree().change_scene_to_file(GAME_SCENE)
