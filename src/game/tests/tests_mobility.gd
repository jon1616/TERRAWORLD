class_name TestsMobility
extends RefCounted
## Prove della voce 31: il rampino si aggancia a un soffitto e tira su il Germogliato, il salto lo sgancia; il doppio
## salto porta più in alto del salto semplice; con gli artigli si scivola piano lungo una parete; foto 59_rampino.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


## Un pavimento in grotta con un soffitto a 6-10 tessere sopra.
func _under_ceiling() -> Vector2i:
	for r in range(30, 500, 5):
		for side in [1, -1]:
			var x: int = world.spawn.x + side * r
			for y in range(world.surface[x] + 20, world.surface[x] + 150):
				if world.solid(x, y) or not world.solid(x, y + 1):
					continue
				var up := 0
				while up < 12 and not world.solid(x, y - up - 1):
					up += 1
				if up >= 6 and up <= 10:
					return Vector2i(x, y)
	return Vector2i(-1, -1)


## Il salto più alto (in tessere) con `presses` pressioni del salto, a distanza di `gap` secondi.
func _jump_height(presses: int) -> float:
	var p: Player = m.player
	var spot := kit.flat_spot(world.spawn, 3)
	m.snap_to(spot)
	await kit.frames(4)
	var y0 := p.position.y
	var top := y0
	p.auto_jump = true
	for k in presses:
		if k > 0:
			p.jump_buf = 0.14
		# in secondi, non in fotogrammi: senza la sincronia verticale il gioco va a più di 130 fotogrammi al secondo
		var t0 := Time.get_ticks_msec()
		while Time.get_ticks_msec() - t0 < 330:
			await kit.frames(1)
			top = minf(top, p.position.y)
	p.auto_jump = false
	var t1 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t1 < 1000:
		await kit.frames(1)
		top = minf(top, p.position.y)
	return (y0 - top) / S


func run() -> void:
	var p: Player = m.player
	var b: Bisaccia = m.character.bisaccia
	var had_control := p.control
	p.control = false
	# doppio salto
	var single := await _jump_height(1)
	b.wear("accessorio_1", {})
	b.wear("accessorio_1", {"id": "baccello_vento", "n": 1})
	await kit.frames(2)
	var double := await _jump_height(2)
	print("doppio salto: salti in aria %d, altezza %.1f tessere (senza %.1f)" % [p.air_jumps, double, single])
	b.wear("accessorio_1", {})
	# rampino
	var c := _under_ceiling()
	if c.x < 0:
		print("ATTENZIONE: nessun soffitto per la prova del rampino")
	else:
		m.snap_to(c)
		await kit.frames(4)
		kit.hold("radice_uncino")
		var y0 := p.position.y
		var ok: bool = m.grapple.fire("radice_uncino", p.position + Vector2(8, -200))
		await kit.seconds(1.0)
		print("rampino: agganciato %s, salito di %.1f tessere, appeso %s" % ["sì" if ok else "NO", (y0 - p.position.y) / S,
			"sì" if p.hook != Vector2.INF else "NO"])
		m.boons.add("bagliore", 20.0)
		await kit.seconds(0.6)
		await kit.save("59_rampino")
		p.jump_buf = 0.14
		await kit.frames(3)
		print("rampino: il salto sgancia %s" % ("sì" if p.hook == Vector2.INF else "NO"))
		await kit.seconds(1.5)
	# artigli: contro una parete in aria si scivola piano
	b.wear("accessorio_1", {"id": "artigli_corteccia", "n": 1})
	await kit.frames(2)
	# una parete costruita apposta su un terreno spianato, alta 8 tessere
	var ws := kit.flat_spot(world.spawn, 8)
	kit.flatten(ws, 6)
	for y in range(ws.y - 8, ws.y + 1):
		world.set_tile(ws.x + 2, y, TileDefs.STONE)
	m.view.refresh_around(Vector2i(ws.x + 2, ws.y - 4))
	var wall := Vector2i(ws.x + 1, ws.y - 5)
	if wall.x < 0:
		print("ATTENZIONE: nessuna parete per la prova degli artigli")
	else:
		m.snap_to(wall)
		p.vel = Vector2(0, 200)
		p.auto_dir = 1.0
		var vmax := 0.0
		for f in 12:
			await kit.frames(1)
			vmax = maxf(vmax, p.vel.y)
		p.auto_dir = 0.0
		print("artigli: scivolando contro la parete la caduta resta a %.0f px/s (senza sarebbe fino a %.0f)" % [p.vel.y,
			Player.MAX_FALL])
	b.wear("accessorio_1", {})
	# com'era prima: rimettere il controllo alla tastiera bloccava le prove successive, che muovono il Germogliato
	# con i comandi simulati (nessuno premeva i tasti e restava fermo)
	p.control = had_control
	m.snap_to(world.spawn)
	await kit.frames(3)
