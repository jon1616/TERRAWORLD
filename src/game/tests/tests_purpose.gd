class_name TestsPurpose
extends RefCounted
## Costruire con uno scopo (Roadmap 47, voci 401-403). Gruppo «scopo».
## I trofei dei boss (la sala dei trofei ferisce di più quel boss), le stanze con un mestiere (sala d'armi, forgia), i
## blocchi che reggono le esplosioni e quelli appiccicosi che rallentano le creature.

var kit: TestKit
var m: Node2D
var res := {}


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	trophies_and_rooms()
	forge()
	await blocks()
	print("scopo: %s" % str(res))
	if not res.values().all(func(x: Variant) -> bool: return x == true):
		print("ATTENZIONE: costruire con uno scopo non va come dovrebbe")


## Una sala dei trofei con il trofeo di un capo: più danno contro di lui; una sala d'armi: le arti crescono più in fretta.
func trophies_and_rooms() -> void:
	var boss_ok := RoomsData.boss_of_trophy("trofeo_capo_cinghiale") == "capo_cinghiale" \
		and RoomsData.boss_of_trophy("trofeo_falena") != "" and RoomsData.boss_of_trophy("trofeo_evento_assalto_rovi") == "evento_assalto_rovi"
	var had: bool = m.world_meta.has("stanze")
	var old: Array = m.world_meta.get("stanze", [])
	m.world_meta["stanze"] = [{"type": "trofei", "comfort": 0, "fams": [], "bosses": ["capo_cinghiale"], "x": 0, "y": 0, "w": 1, "h": 1},
		{"type": "sala_armi", "comfort": 0, "x": 0, "y": 0, "w": 1, "h": 1}]
	m.rooms._apply_world()
	var c: Creature = m.fauna.add("capo_cinghiale", m.player.position + Vector2(200, -8))
	var k: float = m.rooms.trophy_vs(c)
	var arms: float = WeaponArts.room_mult
	m.fauna.kill(c)
	if had:
		m.world_meta["stanze"] = old
	else:
		m.world_meta.erase("stanze")
	m.rooms._apply_world()
	res["trofei_stanze"] = boss_ok and is_equal_approx(k, 1.0 + RoomsData.BOSS_TROPHY) and is_equal_approx(arms, 1.0 + RoomsData.ARMS) \
		and is_equal_approx(WeaponArts.room_mult, 1.0)
	print("scopo, i trofei dei boss %s: contro il capo ×%.2f; sala d'armi ×%.2f" % [boss_ok, k, arms])


## La forgia: fondendo al Baccello ardente a volte i lingotti sono di più.
func forge() -> void:
	var b: Bisaccia = m.character.bisaccia
	kit.make_room()
	var r := {"out": "lingotto_radicite", "qty": 1, "in": {}, "station": "baccello_ardente"}
	var n0 := b.count("lingotto_radicite")
	Crafting.room_extra = {"baccello_ardente": 1.0}
	Crafting.craft(r, b)
	Crafting.room_extra = {}
	var got := b.count("lingotto_radicite") - n0
	b.remove("lingotto_radicite", got)
	res["forgia"] = got == 2
	print("scopo, la forgia: un lingotto fuso ne dà %d" % got)


## Un blocco di vuotite regge l'esplosione, uno d'ardesia no; una creatura sulla cera rallenta.
func blocks() -> void:
	var w: World = m.world
	var kv := _kind("costr_grezzo_vuotite")
	var ka := _kind("costr_grezzo_ardesia")
	var kc := _kind("costr_grezzo_cera")
	var pc: Vector2i = m.player_cell() + Vector2i(12, -6)
	for dy in range(6, 40):                       # un posto d'aria senza alberi sopra (l'esplosione non rompe sotto un albero)
		var q: Vector2i = m.player_cell() + Vector2i(12, -dy)
		if w.tile(q.x, q.y) == TileDefs.AIR and w.tile(q.x + 1, q.y) == TileDefs.AIR and w.tree_at(q + Vector2i(0, -1)).x < 0 				and w.tree_at(q + Vector2i(1, -1)).x < 0 and w.tree_at(q).x < 0 and w.tree_at(q + Vector2i(1, 0)).x < 0:
			pc = q
			break
	var cells := [pc, pc + Vector2i(1, 0)]
	for i in 2:
		var q: Vector2i = cells[i]
		var k := kv if i == 0 else ka
		w.set_tile(q.x, q.y, BuildData.tile_of(k))
		w.build[q.y * w.w + q.x] = k
	m.combat.god = true
	m.throwing.explode(Vector2(pc) * 16.0 + Vector2(16, 8), {"radius": 2.0, "power": 999, "damage": 0})
	var kept: bool = w.tile(pc.x, pc.y) == BuildData.tile_of(kv)
	var broke: bool = w.tile(pc.x + 1, pc.y) == TileDefs.AIR
	if not broke:
		print("scopo, l'ardesia: tessera %d, albero sopra %s" % [w.tile(pc.x + 1, pc.y), str(w.tree_at(pc + Vector2i(1, -1)))])
	for q in cells:
		w.set_tile(q.x, q.y, TileDefs.AIR)
		w.build[q.y * w.w + q.x] = 0
	m.view.refresh_around(pc)
	# la cera sotto i piedi di una creatura
	var fl: Vector2i = m.player_cell() + Vector2i(-10, 0)
	var floor_y := fl.y + 1
	var was: int = w.tile(fl.x, floor_y)
	var wasb: int = w.build[floor_y * w.w + fl.x]
	w.set_tile(fl.x, floor_y, BuildData.tile_of(kc))
	w.build[floor_y * w.w + fl.x] = kc
	var c: Creature = m.fauna.add("lepre_linfa", Vector2(fl.x * 16 + 8, floor_y * 16 - 8))
	var slow: float = c._floor_slow()
	m.fauna.kill(c)
	w.set_tile(fl.x, floor_y, was)
	w.build[floor_y * w.w + fl.x] = wasb
	m.view.refresh_around(fl)
	await kit.frames(1)
	res["blocchi"] = BuildData.blast_proof(kv) and kept and broke and slow < 1.0
	print("scopo, i blocchi: la vuotite regge %s, l'ardesia salta %s; sulla cera ×%.2f" % [kept, broke, slow])


func _kind(id: String) -> int:
	for e in BuildData.kinds():
		if String(e["id"]) == id:
			return int(e["kind"])
	return 0
