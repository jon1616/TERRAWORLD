class_name TestsFlight
extends RefCounted
## Prove del volo (voce 90): senza ali il salto resta quello di sempre; le Ali di foglia sono un lungo salto (più
## alto, ma poco); le stellari un volo vero; la barra si consuma volando e torna a terra; in un mondo leggero dura di
## più; il mantello e le ali stanno nello stesso posto. Foto 157_volo.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func _wear(id: String) -> void:
	var b: Bisaccia = m.character.bisaccia
	if id == "":
		b.equip.erase("mantello")
	else:
		b.equip["mantello"] = id
	b.changed.emit()


## Salta tenendo Salto per `secs` secondi: quante tessere sopra il punto di partenza al massimo.
func _jump(start: Vector2i, secs: float) -> float:
	var p: Player = m.player
	m.snap_to(start)
	await kit.seconds(0.5)                 # a terra: la barra si ricarica
	var y0 := p.position.y
	var top := y0
	p.auto_jump = true
	p.jump_buf = 0.14
	var t := 0.0
	while t < secs:
		await kit.frames(1)
		t += p.get_process_delta_time()
		top = minf(top, p.position.y)
	p.auto_jump = false
	await kit.seconds(0.2)
	return (y0 - top) / 16.0


func run() -> void:
	var w: World = m.world
	var p: Player = m.player
	var res := {}
	var ctrl := p.control
	var eq0: Dictionary = m.character.bisaccia.equip.duplicate()
	var spot := kit.flat_spot(w.spawn + Vector2i(100, 0), 8)
	if spot.x < 0:
		print("ATTENZIONE: volo, nessun posto piano: provo alla partenza")
		spot = w.spawn
	kit.flatten(spot, 8)
	# cielo libero sopra
	for x in range(spot.x - 3, spot.x + 4):
		for y in range(maxi(spot.y - 40, 1), spot.y + 1):
			w.set_tile(x, y, TileDefs.AIR)
	m.view.refresh_around(spot)
	p.control = false
	p.auto_dir = 0.0
	_wear("")
	var h0: float = await _jump(spot, 1.5)
	_wear("ali_foglia")
	res["ali_nel_mantello"] = m.flight.id == "ali_foglia" and not p.wings.is_empty()
	var h1: float = await _jump(spot, 2.0)
	_wear("ali_stellari")
	var h3: float = await _jump(spot, 2.5)
	res["foglia_lungo_salto"] = h1 > h0 + 0.8 and h1 < h0 + 5.0
	res["stellari_volo_vero"] = h3 > h1 + 6.0
	# la barra: vuota dopo il volo, piena dopo un po' a terra
	p.auto_jump = true
	p.jump_buf = 0.14
	await kit.seconds(3.2)
	var spent := p.fly_left < 0.2
	p.auto_jump = false
	m.snap_to(spot)
	await kit.seconds(2.5)
	res["barra"] = spent and absf(p.fly_left - float(FlightData.WINGS["ali_stellari"]["time"])) < 0.05
	await kit.seconds(0.01)
	# in un mondo leggero dura di più
	var g0 := p.grav_mult
	p.grav_mult = 0.5
	p.auto_jump = true
	p.jump_buf = 0.14
	var wt := 0.0
	while not p.flying and wt < 2.0:
		await kit.frames(1)
		wt += p.get_process_delta_time()
	var a0 := p.fly_left
	await kit.seconds(0.3)
	var rate := (a0 - p.fly_left) / 0.3
	p.auto_jump = false
	p.grav_mult = g0
	res["leggero"] = rate > 0.3 and rate < 0.7
	print("volo, consumo nel mondo leggero: %.2f al secondo (atteso 0,5), attesa %.2f s" % [rate, wt])
	# in volo: la foto
	m.snap_to(spot)
	await kit.seconds(0.6)
	p.auto_jump = true
	p.jump_buf = 0.14
	await kit.seconds(0.7)
	await kit.save("157_volo")
	p.auto_jump = false
	await kit.seconds(1.5)
	# tutto com'era
	m.character.bisaccia.equip = eq0
	m.character.bisaccia.changed.emit()
	p.control = ctrl
	m.snap_to(spot)
	var bad := res.keys().filter(func(k: String) -> bool: return not res[k])
	print("volo: senza ali %.2f tessere, foglia %.2f, stellari %.2f; %s; non vanno: %s" % [h0, h1, h3, res, bad])
	if not bad.is_empty():
		print("ATTENZIONE: il volo non funziona come dovrebbe")
