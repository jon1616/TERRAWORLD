class_name ExplorerTools
extends RefCounted
## Gli attrezzi dell'esploratore (Roadmap 23, voce 239; dati in `ExplorerData`), chiamati da `Interact`. Il campo della
## Tenda sta in `world_meta["campo"]` = [x, y] (uno per mondo: il nuovo prende il posto del vecchio) e in `Fauna.camp`.

var m: Node2D
var _scope_t := 0.0


func _init(main: Node2D) -> void:
	m = main
	var c: Array = m.world_meta.get("campo", [])
	if c.size() == 2:
		m.fauna.camp = Vector2i(int(c[0]), int(c[1]))


## Clic destro sulla Tenda: si rinasce qui e si pianta il campo.
func camp(o: Vector2i) -> bool:
	m.masonry.use_bed(o)
	var size: Array = StationsData.STATIONS["tenda_campo"]["size"]
	var c := o + Vector2i(int(size[0]) / 2, int(size[1]) - 1)
	m.world_meta["campo"] = [c.x, c.y]
	m.fauna.camp = c
	m.hud.toast("Campo piantato: rinasci qui, e le creature non nascono entro %d tessere" % int(ExplorerData.CAMP_R))
	return true


## Il cannocchiale: scopre la mappa attorno al punto guardato, se è abbastanza lontano da valerne la pena.
func scope(c: Vector2i) -> bool:
	var now := Time.get_ticks_msec() / 1000.0
	if now < _scope_t:
		return false
	var d := Vector2(c - m.player_cell()).length()
	if d > ExplorerData.SCOPE_REACH:
		m.hud.toast("Troppo lontano anche per il cannocchiale")
		return false
	if m.vitals.linfa < ExplorerData.SCOPE_LINFA:
		m.hud.toast("Serve Linfa per guardare lontano")
		return false
	m.vitals.linfa -= ExplorerData.SCOPE_LINFA
	_scope_t = now + ExplorerData.SCOPE_WAIT
	m.map_reveal.reveal_area(c, ExplorerData.SCOPE_R)
	m.map_reveal.refresh_texture()
	m.sfx.play("dono")
	m.hud.toast("Dal cannocchiale: la mappa si apre attorno al punto che guardi")
	return true


## La bussola: la meraviglia più vicina non ancora vista in questo mondo ("" se non ce ne sono).
func compass() -> String:
	var pc: Vector2i = m.player_cell()
	var best := {}
	var bd := 1e18
	for e in m.atlas.wonders.list():
		if e.get("vista", false):
			continue
		var d := Vector2(Vector2i(int(e["c"][0]), int(e["c"][1])) - pc).length()
		if d < bd:
			bd = d
			best = e
	if best.is_empty():
		var msg := "La bussola gira a vuoto: in questo mondo hai visto tutte le meraviglie" if not m.atlas.wonders.list().is_empty() \
			else "La bussola gira a vuoto: questo mondo non ha meraviglie"
		m.hud.toast(msg)
		return ""
	var dx := int(best["c"][0]) - pc.x
	var dy := int(best["c"][1]) - pc.y
	var hor := "%d tessere a %s" % [absi(dx), "est" if dx > 0 else "ovest"]
	var ver := "alla stessa altezza" if absi(dy) < 15 else "%d più in %s" % [absi(dy), "basso" if dy > 0 else "alto"]
	m.hud.toast("La bussola indica una meraviglia: %s, %s" % [hor, ver])
	m.sfx.play("dono")
	return String(best["k"])


## La Radice di ritorno: al Giardino (si consuma solo se il viaggio parte).
func go_home(id: String) -> bool:
	if m.aiuole.is_home():
		m.hud.toast("Sei già nel Giardino")
		return false
	var home: String = m.aiuole.home_id()
	if home == "" or home == m.world_id or not m.character.bisaccia.remove(id, 1):
		return false
	m.hud.toast("La radice si spezza e ti riporta a casa")
	m.save_game()
	Session.start_saved_world(home)
	m.get_tree().change_scene_to_file(Portal.GAME_SCENE)
	return true
