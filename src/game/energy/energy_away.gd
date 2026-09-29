class_name EnergyAway
extends RefCounted
## Roadmap 19, voce 197: la rete lavora anche mentre sei via (in un altro mondo, o a gioco chiuso). Entrando in un
## mondo, il tempo passato da quando lo si è visto l'ultima volta (`world_meta["rete"]["visto"]`, l'ora di sistema)
## si fa lavorare a metà velocità e al più per `MAX_SECS` (2 ore reali = 1 ora di lavoro), a passi di `STEP` secondi
## con il conto vero (`Energy.solve`): le riserve si riempiono, i combustibili si consumano, le macchine lavorano con i
## materiali delle loro casse. Poi un avviso «Mentre eri via…».

const MAX_SECS := 7200.0
const SPEED := 0.5
const STEP := 30.0
const MIN_AWAY := 60.0


static func run(e: Energy) -> String:
	var meta: Dictionary = e.meta()
	var now := Time.get_unix_time_from_system()
	var seen := float(meta.get("visto", 0.0))
	meta["visto"] = now
	if seen <= 0.0 or now - seen < MIN_AWAY or e.machines.is_empty():
		return ""
	var work := minf(now - seen, MAX_SECS) * SPEED
	var before := _stored(e)
	var steps := int(work / STEP)
	for i in steps:
		e.solve(STEP)
	e.away_worked += steps * STEP
	var gained := _stored(e) - before
	var t := "Mentre eri via la rete ha lavorato %d minuti" % roundi(steps * STEP / 60.0)
	if absf(gained) >= 1.0:
		t += ": le riserve hanno %s %d gocce" % ["preso" if gained > 0.0 else "dato", roundi(absf(gained))]
	return t


static func _stored(e: Energy) -> float:
	var s := 0.0
	for mc: Machine in e.machines.values():
		if mc.role() == "riserva":
			s += float(mc.st.get("g", 0.0))
	return s
