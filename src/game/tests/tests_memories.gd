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
