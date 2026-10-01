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
