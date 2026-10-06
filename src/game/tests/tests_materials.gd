class_name TestsMaterials
extends RefCounted
## Roadmap 31 «Il carattere dei materiali» (gruppo `carattere`): ogni materiale dà un bonus suo, i set delle leghe e dei
## materiali dei geni, i gioielli con il carattere del metallo. Ogni prova rimette com'erano Bisaccia ed effetti.

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await traits()
	await sets()
	await jewels()


## Voce 306: pezzi dello stesso tipo e grado di materiali diversi non sono più uguali; ogni pezzo forgiato porta il
## carattere del suo materiale (le leghe metà di ciascun metallo); l'arma in mano lo dà mentre la tieni.
func traits() -> void:
	var a: Dictionary = ItemsData.get_item("guanti_ambra")["acc"]
	var t: Dictionary = ItemsData.get_item("guanti_tizzonite")["acc"]
	var n: Dictionary = ItemsData.get_item("guanti_nimbite")["acc"]
	var differ: bool = a != t and t != n and a != n
	var alloy := MaterialsData.trait_of("lega_ambra_tizzonite")
	var half: bool = is_equal_approx(float(alloy.get("halo", 0.0)), 0.06) and is_equal_approx(float(alloy.get("thorns", 0.0)), 2.0)
	# ogni pezzo forgiato di un materiale con un carattere lo porta (indossato o in mano)
	var missing := []
	for mat in MaterialsData.all():
		var tr := MaterialsData.trait_of(String(mat))
		if tr.is_empty():
			missing.append("materiale " + String(mat))
			continue
		var key := String(tr.keys()[0])
		for f in FormsData.FORMS:
			if not FormsData.makes(String(f), String(mat)):
				continue                                  # voce 368: le forme degli stili non si fanno con le leghe
			var it := ItemsData.get_item(FormsData.item_id(String(f), String(mat)))
			var where: Dictionary = it.get("acc", {}) if FormsData.TRAIT_PART.has(f) else it.get("mano", {})
			if not where.has(key):
				missing.append(FormsData.item_id(String(f), String(mat)))
	# l'arma in mano: una spada di pallidite fa correre il 3% in più
	var b: Bisaccia = m.character.bisaccia
	var sel0: int = m.hud.sel
	var slot0 := b.slots[sel0].duplicate(true)
	b.slots[sel0] = {}
	b.changed.emit()
	m.gear.refresh()
	var run0: float = m.player.run_mult
	b.slots[sel0] = {"id": "spada_pallidite", "n": 1}
	b.changed.emit()
	m.gear.refresh()
	var run1: float = m.player.run_mult
	b.slots[sel0] = slot0
	b.changed.emit()
	m.gear.refresh()
	var held_ok := is_equal_approx(run1 / run0, 1.03)
	var line := String(TipWordsData.acc_line("defense", 0.25)[0])
	var ok: bool = differ and half and missing.is_empty() and held_ok and line == "Scorza +0,25"
	print("carattere dei materiali: guanti d'ambra %s · di tizzonite %s · di nimbite %s; lega ambra-tizzonite %s; pezzi senza carattere %d %s; spada di pallidite in mano: corsa ×%.3f; «%s»" % [
		a, t, n, alloy, missing.size(), missing.slice(0, 4), run1 / run0, line])
	if not ok:
		print("ATTENZIONE: il carattere dei materiali non va")


## Voce 307: ogni lega e ogni materiale dei geni ha il suo set di cinque pezzi; indossato tutto, il set è completo e dà il
## suo bonus (la lega: metà del set di ciascuno dei due metalli).
func sets() -> void:
	var all := SetsData.all()
	var alloys := 0
	var genes := 0
	var broken := []
	for mat in MaterialsData.all():
		if not all.has(mat):
			broken.append("senza set: " + String(mat))
			continue
		if (MaterialsData.all()[mat] as Dictionary).has("alloy"):
			alloys += 1
		elif (MaterialsData.all()[mat] as Dictionary).has("gene"):
			genes += 1
		for p in all[mat]["pieces"]:
			if not ItemsData.has(String(p)):
				broken.append(String(p))
	var b: Bisaccia = m.character.bisaccia
	var eq0 := b.equip.duplicate(true)
	var tr0 := b.equip_traits.duplicate(true)
	var da0 := b.equip_data.duplicate(true)
	var mat := "lega_radicite_legnoferro"
	for f in SetsData.ARMOR_FORMS:
		b.equip[String(f)] = "%s_%s" % [f, mat]           # (i posti dell'armatura hanno il nome della forma)
	b.equip_traits.clear()
	b.equip_data.clear()
	b.changed.emit()
	m.gear.refresh()
	var done: bool = mat in m.gear.sets
	var regen: float = m.vitals.regen_mult
	var bonus: Dictionary = all[mat]["bonus"]
	b.equip = eq0
	b.equip_traits = tr0
	b.equip_data = da0
	b.changed.emit()
	m.gear.refresh()
	var expect := SetsData.blend(SetsData.METAL_BONUS["radicite"]["bonus"], SetsData.METAL_BONUS["legnoferro"]["bonus"], 0.5)
	var ok: bool = broken.is_empty() and alloys == 36 and genes == 12 and done and bonus == expect and regen > 1.0
	print("set dei materiali: %d set in tutto, delle leghe %d, dei geni %d, difetti %s; armatura intera di ferrobruno: set completo %s, bonus %s, Vita ×%.2f" % [
		all.size(), alloys, genes, broken.slice(0, 4), done, bonus, regen])
	if not ok:
		print("ATTENZIONE: i set delle leghe e dei geni non vanno")


## Voce 308: due gioielli della stessa gemma e dello stesso grado, in metalli diversi, non sono più uguali; la gemma resta.
func jewels() -> void:
	var a: Dictionary = ItemsData.get_item("amuleto_brillaluce_ambra")["acc"]
	var t: Dictionary = ItemsData.get_item("amuleto_brillaluce_tizzonite")["acc"]
	var n: Dictionary = ItemsData.get_item("amuleto_brillaluce_nimbite")["acc"]
	var r: Dictionary = ItemsData.get_item("anello_sanguinella_pallidite")["acc"]
	var same := 0
	for gem in JewelsData.GEMS:
		var seen := {}
		for mat in MaterialsData.MATERIALS:
			for id in [JewelsData.amulet_id(String(gem), String(mat)), JewelsData.ring_id(String(gem), String(mat))]:
				var key := JSON.stringify(ItemsData.get_item(id)["acc"])
				if seen.has(key):
					same += 1
				seen[key] = 1
	var ok: bool = a != t and t != n and a.has("luck") and t.has("thorns") and n.has("jump") and r.has("damage") and r.has("run") and same == 0
	print("gioielli: amuleto di brillaluce d'ambra %s · di tizzonite %s · di nimbite %s; anello di sanguinella di pallidite %s; gioielli uguali tra loro %d" % [
		a, t, n, r, same])
	if not ok:
		print("ATTENZIONE: il carattere dei gioielli non va")
