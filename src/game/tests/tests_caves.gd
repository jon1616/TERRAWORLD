class_name TestsCaves
extends RefCounted
## Roadmap 30 «Le grotte piene»: raccolti delle piante, baccelli dormienti, nascite delle creature, piccoli incontri,
## curiosità degli strati (gruppo `grotte`). Ogni prova rimette com'erano Bisaccia e conteggi.

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await harvest()


func _counts(ids: Array) -> Dictionary:
	var out := {}
	for id in ids:
		out[id] = m.character.bisaccia.count(String(id))
	return out


func _give_back(before: Dictionary) -> void:
	for id in before:
		var extra: int = m.character.bisaccia.count(String(id)) - int(before[id])
		if extra > 0:
			m.character.bisaccia.remove(String(id), extra)


## Voce 300: una pianta dei biomi tolta lascia il suo raccolto; una bacca si mangia, una fibra fa corda.
func harvest() -> void:
	var st: Dictionary = m.character.stats
	var n0 := int(st.get("piante_raccolte", 0))
	var before := _counts(["bacche_lanterna", "cardo_ambra"])
	var c: Vector2i = m.player_cell() + Vector2i(1, 0)
	var w: World = m.world
	var old := w.decor_at(c.x, c.y)
	w.set_decor(c.x, c.y, 33)
	m.actions.pick_decor(c)
	w.set_decor(c.x, c.y, 38)
	m.actions.pick_decor(c)
	await kit.seconds(1.5)
	var got_b: int = m.character.bisaccia.count("bacche_lanterna") - int(before["bacche_lanterna"])
	var got_c: int = m.character.bisaccia.count("cardo_ambra") - int(before["cardo_ambra"])
	var bumped := int(st.get("piante_raccolte", 0)) - n0
	var food := ItemsData.get_item("bacche_lanterna")
	var rope := false
	for r in RecipesData.making("corda_liana"):
		if (r["in"] as Dictionary).has("fronda_felce"):
			rope = true
	var dye := not RecipesData.making("tintura_arancio").filter(func(r: Dictionary) -> bool: return (r["in"] as Dictionary).has("cardo_ambra")).is_empty()
	var plants := 0
	for d in HarvestData.DECOR:
		if d >= 33:
			plants += 1
	var ok: bool = got_b >= 1 and got_c == 1 and bumped == 2 and String(food.get("kind", "")) == "consumabile" and rope and dye \
		and plants >= 55
	print("raccolti delle piante: %d piante dei biomi con un raccolto; bacche-lanterna +%d, cardo d'ambra +%d, conteggio +%d, le bacche si mangiano %s, la felce fa corda %s, il cardo tinge %s" % [
		plants, got_b, got_c, bumped, String(food.get("kind", "")) == "consumabile", rope, dye])
	if not ok:
		print("ATTENZIONE: i raccolti delle piante non vanno")
	w.set_decor(c.x, c.y, old)
	_give_back(before)
	st["piante_raccolte"] = n0
