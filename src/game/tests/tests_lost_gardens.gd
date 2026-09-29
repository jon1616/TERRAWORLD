class_name TestsLostGardens
extends RefCounted
## Roadmap 21 «Le radici del cosmo»: gli Atti dell'Albero e i Giardini perduti (gruppo `perduti`).

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await seeds()
	await cures()


## Voci 220-221: l'Atto II comincia dopo lo stadio 12; un Seme del cosmo piantato in un'Aiuola apre un portale verso il
## suo Giardino perduto (nome del Giardino, vigore e geni del Giardino, parametro «perduto» per il generatore).
func seeds() -> void:
	var acts_ok := MotherTreeData.act_of(0) == 0 and MotherTreeData.act_of(11) == 0 and MotherTreeData.act_of(12) == 1
	var b: Bisaccia = m.character.bisaccia
	var spot := kit.flat_spot(m.world.spawn + Vector2i(30, 0), 4)
	if spot.x < 0:
		spot = m.player_cell() + Vector2i(6, 0)
	m.snap_to(spot + Vector2i(-3, 0))
	await kit.frames(4)
	var gen := LostGardensData.genome("sommerso")
	b.add_stack({"id": "seme_cosmo_sommerso", "n": 1, "dati": gen})
	kit.hold("seme_cosmo_sommerso")
	kit.aiuola(spot)
	var planted: bool = m.portal.plant(spot, "seme_cosmo_sommerso")
	var o := spot - Vector2i(1, 3)
	var dest: Array = m.portal.destination(o)
	var e: Dictionary = m.portal._portals()[Portal._key(o)]
	var params: Dictionary = MainBoot.gen_params(dest[3], e.get("geni", []), false, m.character, false, String(e.get("perduto", "")))
	if m.guardian.lore.visible:
		m.guardian.lore.visible = false
	var ok := acts_ok and planted and String(dest[1]) == "Il Giardino sommerso" and int(dest[3]) == 4 \
		and String(params.get("perduto", "")) == "sommerso" and "sommerso" in (e.get("geni", []) as Array)
	print("Giardini perduti: atti %s; Seme del cosmo piantato %s → «%s», vigore %d, parametro «%s»" % [acts_ok, planted, dest[1],
		int(dest[3]), params.get("perduto", "")])
	if not ok:
		print("ATTENZIONE: gli Atti o i Semi del cosmo non vanno")
	m.view.remove_station(o)
	m.world.stations.erase(o)


## Voci 223-224: il Giardino selvatico finto nel mondo di prova: l'Albero guarisce con le sue tre cure (le bacche
## portate, un Cervo di rovo nella mandria, il Custode sconfitto), poi dona; attorno nascono le creature del Giardino.
func cures() -> void:
	var w: World = m.world
	var spot := kit.flat_spot(w.spawn + Vector2i(-60, 0), 12)
	if spot.x < 0:
		spot = m.player_cell() + Vector2i(-20, 0)
	kit.flatten(spot, 8)
	var o := Vector2i(spot.x - 4, spot.y - 12)
	for y in range(o.y, o.y + 13):
		for x in range(o.x, o.x + 9):
			w.set_tile(x, y, TileDefs.AIR)
	w.stations[o] = "albero_selvatico"
	m.view.add_station(o)
	var meta0: Variant = m.world_meta.get("perduto", null)
	m.world_meta["perduto"] = {"id": "selvatico", "tree": [o.x, o.y]}
	var lg := LostGardens.new()
	m.add_child(lg)
	lg.setup(m)
	m.snap_to(spot + Vector2i(-6, 0))
	await kit.frames(3)
	var pool_ok: bool = m.fauna.lost_pool.size() == 2
	# 1: le bacche
	m.character.bisaccia.add("bacca_rovo", 12)
	lg.touch(o)
	var c1 := lg.done("seme")
	# 2: un Cervo di rovo nella mandria
	var mandria0: Array = m.character.mandria.duplicate(true)
	m.character.mandria.append(m.herd.new_record("cervo_rovo", "laccio"))
	lg._check()
	var c2 := lg.done("bestia")
	# 3: il Custode si sveglia e si sconfigge
	lg.touch(o)
	var boss: Creature = null
	for c in m.fauna.list:
		if is_instance_valid(c) and c.id == "re_rovi":
			boss = c
	var woke := boss != null
	var had: int = m.character.bisaccia.count("corno_selvatico")
	if woke:
		m.fauna.kill(boss)
	await kit.frames(3)
	var healed := lg.healed() and String(w.stations.get(o, "")) == "albero_selvatico_vivo"
	var gift: bool = m.character.bisaccia.count("corno_selvatico") == had + 1
	await kit.save("245_albero_selvatico")
	if m.guardian.lore.visible:
		m.guardian.lore.visible = false
	print("Giardino selvatico: creature del Giardino %s; bacche %s, cervo %s, Custode sveglio %s; guarito %s, dono %s" % [
		pool_ok, c1, c2, woke, healed, gift])
	if not (pool_ok and c1 and c2 and woke and healed and gift):
		print("ATTENZIONE: le cure dell'Albero perduto non vanno")
	m.character.mandria = mandria0
	m.fauna.lost_pool = []
	m.fishing.on_catch = Callable()
	lg.id = ""
	lg.queue_free()
	if meta0 == null:
		m.world_meta.erase("perduto")
	else:
		m.world_meta["perduto"] = meta0
	m.view.remove_station(o)
	w.stations.erase(o)
