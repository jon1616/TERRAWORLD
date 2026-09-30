class_name TestsBackpack
extends RefCounted
## Roadmap 30 «Lo zaino»: Bisacce a gradi, tasche, «non raccogliere», Dispensa, basto (gruppo `zaino`). Ogni prova
## rimette la Bisaccia com'era (caselle, contenuto, equipaggiamento) e i conteggi del personaggio.

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await bags()


## Lo stato della Bisaccia da rimettere dopo la prova: caselle, contenuto ed equipaggiamento.
func _save_bag() -> Dictionary:
	var b: Bisaccia = m.character.bisaccia
	return {"slots": b.slots.duplicate(true), "equip": b.equip.duplicate(true), "traits": b.equip_traits.duplicate(true),
		"data": b.equip_data.duplicate(true), "stats": m.character.stats.duplicate(true)}


func _restore_bag(s: Dictionary) -> void:
	var b: Bisaccia = m.character.bisaccia
	b.slots.clear()
	for e in s["slots"]:
		b.slots.append((e as Dictionary).duplicate(true))
	b.equip = (s["equip"] as Dictionary).duplicate(true)
	b.equip_traits = (s["traits"] as Dictionary).duplicate(true)
	b.equip_data = (s["data"] as Dictionary).duplicate(true)
	var st: Dictionary = m.character.stats
	for k in st.keys():
		if not (s["stats"] as Dictionary).has(k):
			st.erase(k)
	for k in s["stats"]:
		st[k] = s["stats"][k]
	b.changed.emit()


## Voce 295: una Bisaccia più grande allarga lo zaino (il contenuto resta), una più piccola non si consuma; il pannello si
## sfoglia a pagine; il salvataggio tiene le caselle.
func bags() -> void:
	var saved := _save_bag()
	var b: Bisaccia = m.character.bisaccia
	var n0 := b.slots.size()
	var first := b.slots[0].duplicate(true)
	b.slots[b.slots.size() - 1] = {}
	b.add("bisaccia_ambra", 1)
	var grown: bool = m.backpack.use_bag("bisaccia_ambra")
	var n1 := b.slots.size()
	b.add("bisaccia_seta", 1)
	var smaller: bool = m.backpack.use_bag("bisaccia_seta")
	var kept := b.count("bisaccia_seta") == 1 and b.slots[0] == first
	b.remove("bisaccia_seta", 1)
	b.slots[n1 - 1] = {"id": "legno", "n": 7}               # una casella in fondo, sull'ultima pagina
	var d: Dictionary = m.character.to_dict()
	var back := Character.from_dict("prova_zaino", JSON.parse_string(JSON.stringify(d)))
	var saved_ok: bool = back != null and back.bisaccia.slots.size() == n1 and back.bisaccia.id_at(n1 - 1) == "legno"
	var bp: BisacciaPanel = m.hud.panel
	bp.toggle()
	await kit.frames(3)
	var pages := bp._views.size()
	bp.view = pages - 1
	bp._refresh()
	await kit.frames(3)
	var last_seen := false
	for s in bp._slots:
		if s.visible and s.index == n1 - 1:
			last_seen = true
	await kit.save("300_zaino_pagine")
	bp.view = 0
	bp.toggle()
	var ok: bool = grown and n1 == 84 and not smaller and kept and saved_ok and pages == 3 and last_seen
	print("Bisacce a gradi: %d → %d caselle %s, una più piccola non si usa %s, contenuto al suo posto %s, salvataggio %s, pagine %d, ultima casella in vista %s" % [
		n0, n1, grown, not smaller, kept, saved_ok, pages, last_seen])
	if not ok:
		print("ATTENZIONE: le Bisacce a gradi non vanno")
	_restore_bag(saved)
