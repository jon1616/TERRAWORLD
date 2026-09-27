class_name TestsWorldTime
extends RefCounted
## Prove del tempo dei mondi (voce 78): i Giorni brevi fanno correre l'ora, l'Eclissi spegne il sole a mezzogiorno e fa
## cadere la Polvere d'eclissi, la Notte eterna ferma l'ora a mezzanotte, Senza sole spegne il cielo lasciando le
## creature del giorno, e al buio le colture crescono piano tranne accanto a una torcia. Foto 144_eclissi, 145_senza_sole.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _genes(gs: Array) -> void:
	m.world_traits.genes = gs
	m.world_meta["geni"] = gs
	m.world_traits.apply()


## Quanto avanza l'ora in `secs` secondi veri.
func _pace(secs: float) -> float:
	var d: DayCycle = m.day
	d.time = 0.3
	d.paused = false
	var t := 0.0
	var t0 := d.time
	while t < secs:
		await kit.frames(1)
		t += m.get_process_delta_time()
	d.paused = true
	return (d.time - t0) / t


func run() -> void:
	var d: DayCycle = m.day
	var genes0: Array = m.world_meta.get("geni", [])
	var time0 := d.time
	var paused0 := d.paused
	m.snap_to(world.spawn)
	_genes([])
	var normal: float = await _pace(0.6)
	_genes(["giorni_brevi"])
	var fast: float = await _pace(0.6)
	# l'eclissi
	_genes(["eclissi"])
	d.time = 0.5
	d.paused = false
	await kit.frames(3)
	d.paused = true
	d.apply(true)
	var ec_on := d.eclipse_on
	var ec_night := d.is_night()
	var ec_clock := d.clock_text()
	var dust := 0
	for k in 12:
		if d.eclipse_drop(m.player.position + Vector2(20, -10), 0.5):
			dust += 1
	await kit.seconds(0.5)
	await kit.save("144_eclissi")
	# la notte eterna
	_genes(["notte_eterna"])
	d.time = 0.4
	d.paused = false
	await kit.seconds(0.4)
	d.paused = true
	var eternal := d.time == 0.0 and d.is_night() and d.clock_text().contains("Notte eterna")
	# senza sole
	_genes(["senza_sole"])
	d.time = 0.5
	d.apply(true)
	var sk: Color = m.light.sky
	var sunless := sk.r + sk.g + sk.b < 0.05 and not d.is_night()
	var grow_dark := d.dark_grow(world.spawn + Vector2i(30, -1))
	var tc := world.spawn + Vector2i(34, -1)
	world.add_torch(tc)
	var grow_lit := d.dark_grow(world.spawn + Vector2i(32, -1))
	world.remove_torch(tc)
	await kit.seconds(0.5)
	await kit.save("145_senza_sole")
	_genes(genes0)
	d.time = time0
	d.paused = paused0
	d.eclipse_on = false
	d.apply(true)
	print("tempo dei mondi: ora per secondo normale %.5f, giorni brevi %.5f (×%.1f); eclissi: accesa %s, notte %s, orologio «%s», polvere %d su 12; notte eterna ferma %s; senza sole: cielo %.2f, creature del giorno %s; colture al buio ×%.2f, con la torcia ×%.2f" % [
		normal, fast, fast / maxf(normal, 0.000001), "sì" if ec_on else "NO", "sì" if ec_night else "NO", ec_clock, dust,
		"sì" if eternal else "NO", sk.r + sk.g + sk.b, "sì" if sunless else "NO", grow_dark, grow_lit])
	if fast < normal * 2.0 or not ec_on or not ec_night or not ec_clock.contains("eclissi") or dust < 1 or not eternal \
			or not sunless or grow_dark >= 1.0 or grow_lit < 1.0:
		print("ATTENZIONE: il tempo dei mondi non funziona come dovrebbe")
