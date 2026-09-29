class_name TestsMemories
extends RefCounted
## Roadmap 26 «Memorie»: il Museo, l'archeologia, le porte a indovinello, i traguardi delle collezioni (gruppo `memorie`).

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func _restore(st: Dictionary, saved: Dictionary) -> void:
	for k in st.keys():
		if not saved.has(k):
			st.erase(k)
		else:
			st[k] = saved[k]


func run() -> void:
	await museum()
	await archaeology()
	await chronicles()


## Voce 253: le sale nascono dai dati; un pezzo in una vetrina entra nel Museo una volta sola; la sala completa dà il
## suo bonus e la bellezza cresce.
func museum() -> void:
	var mu: Museum = m.museum
	var st: Dictionary = m.character.stats
	var saved := st.duplicate()
	var sizes := {}
	for h in MuseumData.HALLS:
		sizes[h] = MuseumData.pieces(h).size()
	var gems: Array = MuseumData.pieces("gemme")
	var o: Vector2i = m.player_cell() + Vector2i(2, -1)
	m.world.stations[o] = "vetrina"
	var chest: Bisaccia = m.world.chest_at(o)
	chest.add(String(gems[0]), 1)
	var fresh := mu.scan()
	var again := mu.scan()
	var h0: float = m.boons.halo_mult
	for g in gems:
		mu.exhibit(String(g))
	m.gear.refresh()
	var complete := int(st.get("sala_gemme", 0)) == 1
	var halo_up: bool = m.boons.halo_mult > h0
	var beauty: int = int(m.beauty.parts().get("museo", 0))
	m.world.stations.erase(o)
	m.world.chests.erase(o)
	var ok: bool = int(sizes["reliquie"]) == 12 and int(sizes["meraviglie"]) == 12 and int(sizes["orto"]) == 12 and fresh.size() == 1 \
		and again.is_empty() and complete and halo_up and beauty >= 8 and MuseumData.total() >= 80
	print("museo: sale %s (in tutto %d); vetrina %s poi %s; sala delle gemme completa %s, alone più ampio %s; bellezza +%d" % [
		str(sizes), MuseumData.total(), str(fresh), str(again), complete, halo_up, beauty])
	if not ok:
		print("ATTENZIONE: il Museo non va")
	_restore(st, saved)
	m.gear.refresh()


## Voce 254: il mondo di prova ha i suoi giacimenti; senza Pennello niente; con il Pennello, otto colpi e un fossile dello
## strato; tre parti al Maglio fanno lo scheletro; fossili e scheletri sono sale del Museo.
func archaeology() -> void:
	var ar: Archaeology = m.museum.arch
	var sites := []
	for o in m.world.stations:
		if String(m.world.stations[o]) == "giacimento":
			sites.append(o)
	var o: Vector2i = m.player_cell() + Vector2i(1, 0)
	m.world.stations[o] = "giacimento"
	kit.hold("piccone_radicite")
	ar.brush(o)
	var untouched: bool = not m.world_meta.get("scavi", {}).has("%d,%d" % [o.x, o.y])
	kit.hold("pennello")
	var before: int = m.character.bisaccia.count("pennello")
	for k in ArchaeologyData.BRUSHES:
		ar.brush(o)
	var gone: bool = not m.world.stations.has(o)
	var got := ""
	for a in ArchaeologyData.ANIMALS:
		for p in ArchaeologyData.PARTS:
			var id := ArchaeologyData.fossil_id(String(a), String(p[0]))
			if m.character.bisaccia.count(id) > 0:
				got = id
	var r: Dictionary = RecipesData.making(ArchaeologyData.skeleton_id("grumo_primo"))[0]
	var ok: bool = sites.size() >= 10 and untouched and gone and got != "" and (r["in"] as Dictionary).size() == 3 \
		and MuseumData.pieces("fossili").size() == 24 and MuseumData.pieces("scheletri").size() == 8 and before >= 1
	print("archeologia: %d giacimenti nel mondo; senza pennello nessun colpo %s; esaurito %s; fossile %s; scheletro da %d parti" % [
		sites.size(), untouched, gone, got, (r["in"] as Dictionary).size()])
	if not ok:
		print("ATTENZIONE: l'archeologia non va")
	if got != "":
		m.character.bisaccia.remove(got, 1)


## Voce 255: i frammenti stanno nelle tabelle delle rovine; con tutti e cinque la storia si ricompone una volta sola.
func chronicles() -> void:
	var ch: Chronicles = m.museum.chron
	var st: Dictionary = m.character.stats
	var saved := st.duplicate()
	var er: Dictionary = m.character.erbario["oggetti"]
	var saved_er: Dictionary = er.duplicate()
	var in_loot := false
	for e in LootData.TABLES["rovina_1"]:
		in_loot = in_loot or String(e["item"]).begins_with("cronaca_primo_seme")
	st.erase("cronaca_primo_seme")
	for n in 4:
		er[ChroniclesData.fragment_id("primo_seme", n)] = 1
	var early := ch.check()
	er[ChroniclesData.fragment_id("primo_seme", 4)] = 1
	var done := ch.check()
	var again := ch.check()
	m.guardian.lore.visible = false
	var ok: bool = in_loot and early.is_empty() and done == ["primo_seme"] and again.is_empty() and ChroniclesData.STORIES.size() == 8 \
		and MuseumData.pieces("cronache").size() == 40
	print("cronache: nei bottini %s; con 4 frammenti %s, con 5 %s, di nuovo %s; storie %d" % [in_loot, str(early), str(done), str(again),
		ChroniclesData.STORIES.size()])
	if not ok:
		print("ATTENZIONE: le cronache non vanno")
	m.character.bisaccia.remove("linfa_antica", 2)
	er.clear()
	er.merge(saved_er)
	_restore(st, saved)
