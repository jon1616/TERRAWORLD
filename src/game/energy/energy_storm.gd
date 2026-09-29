class_name EnergyStorm
extends RefCounted
## Roadmap 19, voce 207: ciò che il mondo fa alla rete. I **geni** (parte `run` di `GenesData`, chiavi `linfa_*`):
##   linfa_sole     le Foglie-lanterna danno di più (+50% con «Sole di Linfa»)
##   linfa_vento    i Mulini girano sempre almeno a questa parte (0,8 con «Vento perenne»)
##   linfa_vene     le vene portano di più (+50% con «Terra che conduce»: `EnergyGraph.cap_mult`)
## E la **Tempesta di Linfa** (evento `tempesta_linfa` di `EventsData`): le sorgenti danno il 50% in più, ma ogni tanto
## una vena di radice o di legnoferro di una rete che scorre si spezza, se la rete non ha una **Valvola di sfogo**. Le
## vene isolate con la gelatina non si spezzano.

const STORM := "tempesta_linfa"
const BOOST := 1.5
const BURST_EVERY := 90.0              # secondi in media tra due vene spezzate, per rete
const VALVE := "valvola_sfogo"

static var bursts := 0                 # vene spezzate (per le prove)
static var _told := 0.0


## I geni del mondo, letti a ogni ricostruzione della rete.
static func genes(e: Energy) -> Dictionary:
	var gs: Array = e.m.world_traits.genes if e.m.get("world_traits") != null else []
	var g := Genome.effects(gs, "run")
	EnergyGraph.cap_mult = 1.0 + float(g.get("linfa_vene", 0.0))
	return g


static func storm(e: Energy) -> bool:
	return e.m.get("events") != null and String(e.m.events.active) == STORM


## Quanto danno in più le sorgenti adesso.
static func boost(e: Energy) -> float:
	return BOOST if storm(e) else 1.0


## Dopo ogni conto: durante la Tempesta le reti che scorrono senza valvola rischiano una vena.
static func tick(e: Energy, dt: float) -> void:
	if not storm(e):
		return
	for ni in e.nets.size():
		var nt: Dictionary = e.nets[ni]
		if not bool(nt["flowing"]) or e.rng.randf() >= dt / BURST_EVERY:
			continue
		var safe := false
		for mc: Machine in nt["users"]:
			if mc.id == VALVE:
				safe = true
				break
		if not safe:
			burst(e, nt)


## Spezza una vena di radice o di legnoferro (non isolata) della rete: il grado sparisce, i fili restano.
static func burst(e: Energy, nt: Dictionary) -> bool:
	var w: World = e.m.world
	var weak: Array[Vector2i] = []
	for c: Vector2i in nt["cells"]:
		var b := w.vein_at(c.x, c.y)
		if VeinsData.tier(b) in [1, 2] and b & VeinsData.INSULATED == 0:
			weak.append(c)
	if weak.is_empty():
		return false
	var c := weak[e.rng.randi_range(0, weak.size() - 1)]
	w.set_vein(c.x, c.y, w.vein_at(c.x, c.y) & ~VeinsData.TIER_MASK)
	e._on_vein(c)
	e.m.view.refresh_vein(c)
	e.m.sfx.play("presenza", Vector2(c) * 16.0 + Vector2(8, 8))
	bursts += 1
	var now := Time.get_ticks_msec() / 1000.0
	if now - _told > 20.0:
		_told = now
		var dist := roundi((Vector2(c) * 16.0).distance_to(e.m.player.position) / 16.0)
		e.m.hud.toast("La Tempesta di Linfa ha spezzato una vena a %d m: una Valvola di sfogo protegge la rete" % dist)
	return true
