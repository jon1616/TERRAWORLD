class_name TestsDay
extends RefCounted
## Prove del giorno e della notte (voce 9): luce del cielo a mezzogiorno, al tramonto e a mezzanotte in superficie,
## foto del tramonto e della notte, e creature della notte che compaiono solo di notte.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func _sky_at(t: float) -> float:
	m.day.time = t
	m.day.apply(true)
	m.light.compute_now(m.player_cell(), m.player_cell())
	return m.light.value_at(m.player_cell() + Vector2i(0, -6))


func run() -> void:
	var spot := kit.flat_spot(kit.world.spawn, 4)
	m.snap_to(spot)
	await kit.frames(5)
	var noon := _sky_at(0.5)
	var dusk := _sky_at(0.76)
	await kit.seconds(1.5)
	await kit.save("26_tramonto")
	var night := _sky_at(0.0)
	await kit.seconds(1.5)
	await kit.save("27_notte")
	print("cielo in superficie: mezzogiorno %.2f, tramonto %.2f, mezzanotte %.2f; orologio «%s»" % [noon, dusk, night, m.day.clock_text()])
	# creature della notte: compaiono solo con la notte
	var seen_night := false
	m.fauna.night = true
	for k in 200:
		var c: Creature = m.fauna.try_spawn()
		if c and c.data.get("night", false):
			seen_night = true
	m.fauna.clear()
	m.fauna.night = false
	var seen_day := false
	for k in 200:
		var c: Creature = m.fauna.try_spawn()
		if c and c.data.get("night", false):
			seen_day = true
	m.fauna.clear()
	print("creature della notte: di notte %s, di giorno %s" % ["sì" if seen_night else "NO", "sì (ERRORE)" if seen_day else "no"])
	# pericolo per zona (voce 20): tetto di creature e ritmo delle nascite
	var line := "pericolo:"
	var sx: int = kit.world.spawn.x
	for row in [["superficie di giorno", 0, false], ["superficie di notte", 0, true]]:
		var d := DangerData.at(kit.world, Vector2i(sx, kit.world.surface[sx] - 1), bool(row[2]), 1)
		line += " %s %.1f (tetto %d, una ogni %.1f s) ·" % [row[0], d, DangerData.cap(d), DangerData.SPAWN_EVERY / d]
	for k in range(1, StrataData.STRATA.size()):
		var y: int = kit.world.surface[sx] + StrataData.top(k) + 20
		var d2 := DangerData.at(kit.world, Vector2i(sx, mini(y, kit.world.h - 10)), false, 1)
		line += " %s %.1f (tetto %d) ·" % [StrataData.STRATA[k]["name"], d2, DangerData.cap(d2)]
	print(line)
	_sky_at(0.5)
