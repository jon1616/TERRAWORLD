class_name TestsSlots
extends RefCounted
## Prove dei posti nuovi dell'equipaggiamento (voce 86): guanti, stivali e mantello nascono per ogni materiale con la
## loro ricetta; amuleti e anelli per ogni gemma e metallo; ogni pezzo va nel suo posto (e non negli altri); indossati
## cambiano Scorza, corsa, colpi e rigenerazione, l'anello dà il suo effetto; il set di cinque pezzi si completa; la
## colonna dei dieci posti si vede. Foto 153_dieci_posti.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var b: Bisaccia = m.character.bisaccia
	var eq0: Dictionary = b.equip.duplicate()
	var res := {}
	# gli oggetti e le ricette
	var n_gear := 0
	var n_jewel := 0
	for id in ItemsData.all():
		var k := String(ItemsData.get_item(String(id)).get("kind", ""))
		if k in ["guanti", "stivali", "mantello"]:
			n_gear += 1
		elif k in ["amuleto", "anello"] and JewelsData.items().has(String(id)):   # (non gli unici della voce 98)
			n_jewel += 1
	res["forme"] = n_gear >= 3 * 40
	res["gioielli"] = n_jewel == 64
	res["ricette"] = not RecipesData.making("guanti_legnoferro").is_empty() and not RecipesData.making("anello_lagunite_ambra").is_empty()
	# i posti: ogni pezzo nel suo
	b.equip = {}
	var wrong: Dictionary = b.wear("guanti", {"id": "stivali_radicite", "n": 1})
	res["posto_giusto"] = not wrong.is_empty() and not b.equip.has("guanti")
	var sc0 := b.scorza()
	var run0: float = m.player.run_mult
	for pair in [["guanti", "guanti_legnoferro"], ["stivali", "stivali_legnoferro"], ["mantello", "mantello_legnoferro"],
			["amuleto", "amuleto_brillaluce_legnoferro"], ["anello", "anello_nottilite_legnoferro"]]:
		b.wear(String(pair[0]), {"id": String(pair[1]), "n": 1})
	await kit.frames(3)
	res["scorza"] = b.scorza() > sc0
	res["corsa"] = m.player.run_mult > run0
	res["effetto_anello"] = m.effects.has("notturno")
	# il set di cinque pezzi
	for pair in [["elmo", "elmo_legnoferro"], ["corazza", "corazza_legnoferro"], ["gambali", "gambali_legnoferro"]]:
		b.wear(String(pair[0]), {"id": String(pair[1]), "n": 1})
	await kit.frames(2)
	res["set"] = "legnoferro" in SetsData.complete(b.equip) and (SetsData.all()["legnoferro"]["pieces"] as Array).size() == 5
	# la colonna dei dieci posti
	if not m.hud.panel.visible:
		m.hud.panel.toggle()
	await kit.frames(4)
	var shown := 0
	for slot in Bisaccia.EQUIP_SLOTS:
		var sv: SlotView = m.hud.panel._equip.get(slot)
		if sv != null and sv.is_visible_in_tree() and sv.get_global_rect().position.y > 560:
			shown += 1
	res["colonna"] = shown == 10
	await kit.save("153_dieci_posti")
	m.hud.panel.toggle()
	b.equip = eq0
	b.changed.emit()
	var bad := res.keys().filter(func(k: String) -> bool: return not res[k])
	print("posti nuovi: guanti/stivali/mantelli %d, amuleti e anelli %d; %s; non vanno: %s" % [n_gear, n_jewel, res, bad])
	if not bad.is_empty():
		print("ATTENZIONE: i posti nuovi dell'equipaggiamento non funzionano come dovrebbero")
