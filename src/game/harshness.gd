class_name Harshness
extends Node
## I rigori delle terre estreme (voce 93, dati in `HarshData` e nel campo `harsh` dei biomi): la barra del rigore del
## bioma in cui si trova il Germogliato, allo scoperto in superficie; la protezione dell'equipaggiamento (`GearEffects`
## somma le chiavi `caldo`, `acqua`, `fresco`, `filtro`), dei rimedi (`Boons`), del tetto e del Rifugio del viandante
## (`Zones`, chiave `riparo`); a barra piena ferite e penalità; il terreno che ferisce (campo `hurt_tile` dei biomi) se
## non si hanno i piedi protetti (chiave `passo`). La barra si disegna nell'HUD sotto Vita e Linfa (`HarshBar`).

var m: Node2D
var meters := {}                       # rigore -> 0..1
var kind := ""                         # il rigore del luogo in cui si è adesso ("" = nessuno)
var protect := {}                      # chiave `acc` -> 0..1 (la riempie `GearEffects`)
var passo := false                     # i piedi protetti dal terreno che ferisce
var run_mult := 1.0                    # le penalità, lette da `Player` e `Vitals`
var jump_mult := 1.0
var regen_mult := 1.0
var _hurt_t := 0.0
var _tile_t := 0.0
var _linfa_acc := 0.0
var _full := ""


func setup(main: Node2D) -> void:
	m = main
	for k in HarshData.KINDS:
		meters[k] = 0.0


## Il rigore di una cella di superficie: {kind, rate, night} del bioma (vuoto se il bioma non ne ha).
func harsh_at(x: int) -> Dictionary:
	var b: Dictionary = BiomesData.BIOMES[BiomesData.at(m.world, x)]
	return b.get("harsh", {})


## Quanto protegge adesso dal rigore k (0-1): equipaggiamento, rimedio, rifugio.
func shield(k: String) -> float:
	var kd: Dictionary = HarshData.KINDS[k]
	if m.boons.active.has(String(kd["boon"])):
		return 1.0
	if m.zones != null and m.zones.add_at(m.player.position, "riparo") > 0.0:
		return 1.0
	return clampf(float(protect.get(String(kd["acc"]), 0.0)), 0.0, 1.0)


func _process(dt: float) -> void:
	if not m.built or m.life.dead:
		return
	var pc: Vector2i = m.player_cell()
	var outside: bool = m.depth_watch.stratum == 0 and not m.giardino.active
	var h := harsh_at(pc.x) if outside else {}
	# voce 158: nel cielo alto l'aria sottile vince sul rigore del bioma di sotto
	var thin := float(SkyData.get_biome(m.chiome.here).get("thin", 0.0)) if m.get("chiome") != null and m.chiome.here != "" else 0.0
	if thin > 0.0:
		h = {"kind": "quota", "rate": HarshData.QUOTA_RATE * thin}
	kind = String(h.get("kind", ""))
	for k in meters:
		var v := float(meters[k])
		if k == kind:
			var rate := float(h["rate"]) * (float(h.get("night", 1.0)) if m.day.is_night() else 1.0)
			if m.weather != null and m.weather.roofed:
				rate *= HarshData.ROOF
			if m.rooms != null:
				rate *= m.rooms.shelter(k)                   # voce 144: una stanza ripara, i materiali isolano
			if m.weather != null:
				rate *= float(m.weather.state().get("rigore", 1.0))      # le tempeste dei biomi
			var s := shield(k)
			v = v + rate * (1.0 - s) * dt if s < 1.0 else maxf(v - HarshData.DECAY * dt, 0.0)
		else:
			v = maxf(v - HarshData.DECAY * dt, 0.0)
		meters[k] = clampf(v, 0.0, 1.0)
	_penalties(dt)
	m.player.harsh_run = run_mult
	m.player.harsh_jump = jump_mult
	m.vitals.harsh_regen = regen_mult
	_hurt_tile(dt, pc, outside)


## A barra piena: ferite e penalità (una sola barra alla volta può essere piena davvero: quella del luogo).
func _penalties(dt: float) -> void:
	run_mult = 1.0
	jump_mult = 1.0
	regen_mult = 1.0
	var full := ""
	for k in meters:
		if float(meters[k]) >= 1.0:
			full = k
	if full == "":
		_hurt_t = 0.0
		_full = ""
		return
	if full != _full:
		_full = full
		m.hud.toast("%s: %s" % [HarshData.KINDS[full]["name"], "cercati un riparo o un rimedio"])
	var kd: Dictionary = HarshData.KINDS[full]
	var pen: Dictionary = kd["penalty"]
	run_mult = float(pen.get("run", 1.0))
	jump_mult = float(pen.get("jump", 1.0))
	regen_mult = float(pen.get("regen", 1.0))
	if pen.has("linfa"):
		_linfa_acc += float(pen["linfa"]) * dt
		if _linfa_acc >= 1.0 and m.vitals.linfa > 0:
			_linfa_acc -= 1.0
			m.vitals.linfa -= 1
			m.vitals.changed.emit()
	_hurt_t -= dt
	if _hurt_t <= 0.0:
		_hurt_t = float(kd["every"])
		m.combat._self_hurt(int(kd["hurt"]))


## Il terreno che ferisce (vetro, brace viva): stando sopra senza i piedi protetti.
func _hurt_tile(dt: float, pc: Vector2i, outside: bool) -> void:
	_tile_t -= dt
	if _tile_t > 0.0 or passo or not m.player.on_floor:
		return
	_tile_t = HarshData.HURT_TILE_EVERY
	var under: int = m.world.tile(pc.x, pc.y + 1)
	var b := BiomesData.of_grass(under)
	if b.has("hurt_tile"):
		m.combat._self_hurt(int(b["hurt_tile"]["dmg"]))
		if not outside or randf() < 0.3:
			m.hud.toast(String(b["hurt_tile"]["text"]))
