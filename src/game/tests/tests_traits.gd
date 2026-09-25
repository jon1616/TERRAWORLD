class_name TestsTraits
extends RefCounted
## Prove dei tratti dell'equipaggiamento (voce 15): distribuzione dei tratti tirati, un'arma fabbricata ne riceve uno,
## il tratto cambia il danno, Scorza e corsa dei pezzi indossati, rinnovo al Maglio, e (nel salvataggio che segue)
## tratti conservati nella Bisaccia e nell'equipaggiamento.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var seen := {}
	for k in 400:
		var t := TraitsData.roll("spada_ambra")
		seen[t] = int(seen.get(t, 0)) + 1
	print("tratti di 400 spade: %s" % seen)
	var b: Bisaccia = m.character.bisaccia
	b.add("spada_legnoferro", 1)
	var slot := -1
	for i in b.slots.size():
		if b.id_at(i) == "spada_legnoferro":
			slot = i
	b.slots[slot]["tratto"] = "spina"
	var base := int(ItemsData.get_item("spada_legnoferro")["damage"])
	print("spada di legnoferro [Spina]: danno %d → %d, nome «%s»" % [base,
		roundi(base * TraitsData.effect("spina", "damage")), TraitsData.full_name("spada_legnoferro", "spina")])
	# indossare: la Scorza e la corsa tengono conto dei tratti
	var sc0 := b.scorza()
	b.wear("elmo", {"id": "elmo_legnoferro", "n": 1, "tratto": "muschio_fitto"})
	b.wear("gambali", {"id": "gambali_legnoferro", "n": 1, "tratto": "piuma"})
	await kit.frames(2)
	print("tratti indossati: Scorza %d → %d, corsa ×%.2f" % [sc0, b.scorza(), m.player.run_mult])
	# rinnovo al Maglio
	b.add("polvere_brace", 3)
	var old := b.trait_at(slot)
	var nw := Crafting.reforge(b, slot)
	print("rinnovo al Maglio: da «%s» a «%s», polvere rimasta %d" % [old, nw, b.count("polvere_brace")])
