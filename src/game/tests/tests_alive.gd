class_name TestsAlive
extends RefCounted
## Roadmap 15 «Il mondo abitato» (creature e costruzioni). Voce 127: gli attacchi si annunciano (il «!» di `TeleMark`) e
## la schivata c'è solo con un oggetto che la sblocca. Voce 128: i costrutti (forma × materiale). Gruppo «vivo».

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var b: Bisaccia = m.character.bisaccia
	var slots0 := b.slots.duplicate(true)
	var equip0 := b.equip.duplicate(true)
	await telegraphs()
	await dash()
	await builds()
	for i in slots0.size():
		b.slots[i] = slots0[i]
	b.equip = equip0
	b.changed.emit()


## Una creatura che carica, messa sulla linea del Germogliato: prima di partire accende il «!».
func telegraphs() -> void:
	var w: World = m.world
	var cid := ""
	for id in CreaturesData.CREATURES:
		var c: Dictionary = CreaturesData.CREATURES[id]
		if "carica" in (c.get("behaviors", []) as Array) and not c.get("fly", false) and not c.get("boss", false) \
				and 0 in (c.get("strata", []) as Array):
			cid = String(id)
			break
	var spot := kit.flat_spot(w.spawn + Vector2i(40, 0), 6)
	if cid == "" or spot.x < 0:
		print("ATTENZIONE: nessuna creatura che carica, o nessun posto piano, per la prova dei segnali")
		return
	kit.flatten(spot, 8)
	m.snap_to(spot)
	m.vitals.refill()
	await kit.frames(3)
	var cr: Creature = m.fauna.add(cid, m.player.position + Vector2(90, 0))
	var seen := 0.0
	var shot := false
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 5000 and is_instance_valid(cr):
		await kit.frames(1)
		seen = maxf(seen, cr.tele)
		if cr.tele > 0.15 and not shot:
			shot = true
			await kit.save("190_telegrafo")
	var has_mark := is_instance_valid(cr) and cr.get_children().any(func(n: Node) -> bool: return n is TeleMark)
	if is_instance_valid(cr):
		m.fauna.clear()
	m.vitals.refill()
	print("segnale degli attacchi: %s, prima della carica il «!» acceso %s (%.2f s), il segno c'è %s" % [cid,
		"sì" if seen > 0.1 else "NO", seen, "sì" if has_mark else "NO"])
	if seen <= 0.1 or not has_mark:
		print("ATTENZIONE: gli attacchi non si annunciano")


## La schivata: senza oggetto no; con il Cavigliere di vento sì (scatto, invulnerabilità, ricarica).
func dash() -> void:
	var b: Bisaccia = m.character.bisaccia
	var p: Player = m.player
	var no_item: bool = not m.dodge.dash()
	b.equip["accessorio_1"] = "cavigliere_vento"
	m.gear.refresh()
	await kit.seconds(0.2)
	var x0 := p.position.x
	m.combat.invuln = 0.0
	var ok: bool = m.dodge.dash()
	var inv: float = m.combat.invuln
	var again: bool = m.dodge.dash()
	await kit.seconds(0.35)
	var moved := absf(p.position.x - x0)
	print("schivata: senza oggetto no %s; con il Cavigliere sì %s, %.0f px, invulnerabile %.2f s, subito di nuovo no %s" % [
		"sì" if no_item else "NO", "sì" if ok else "NO", moved, inv, "sì" if not again else "NO"])
	if not no_item or not ok or moved < 24.0 or inv < 0.25 or again:
		print("ATTENZIONE: la schivata non va come dovrebbe")


## Voce 128: un muretto di costrutti (tutte le forme, tre materiali) con le pareti costruite dietro; uno si scava e
## lascia il suo oggetto; il mondo salvato e ricaricato li tiene.
func builds() -> void:
	var w: World = m.world
	var spot := kit.flat_spot(w.spawn + Vector2i(-40, 0), 12)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto piano per la prova dei costrutti")
		return
	kit.flatten(spot, 14)
	var nf := BuildData.FORMS.size()
	var placed := 0
	for mi in BuildData.MATERIALS.size():
		for fi in nf:
			var c := Vector2i(spot.x - 4 + fi, spot.y - 2 - mi * 2)
			for dy in 2:
				var q := c + Vector2i(0, -dy) if dy == 1 else c
				w.set_build(q.x, q.y, mi * nf + fi + 1)
				if w.inside(q.x, q.y - 7) and not w.solid(q.x, q.y - 7):
					w.walls[(q.y - 7) * w.w + q.x] = BuildData.WALL_BASE + mi   # le pareti costruite, più in alto
				placed += 1
	for x in range(spot.x - 6, spot.x + 8):
		for y in range(spot.y - 9, spot.y + 1):
			m.view.refresh_around(Vector2i(x, y))
	m.snap_to(Vector2i(spot.x + 6, spot.y))
	m.light.dirty = true
	await kit.seconds(0.4)
	await kit.save("191_costrutti")
	# si scava: lascia il suo oggetto
	var c0 := Vector2i(spot.x - 4, spot.y - 2)
	var k0 := w.build_at(c0.x, c0.y)
	var want := BuildData.item_of(k0)
	var n0: int = m.drops._items.size()
	m.actions.break_tile(c0)
	var dropped := false
	for d in m.drops._items.slice(n0):
		dropped = dropped or String(d["id"]) == want
	var gone := w.build_at(c0.x, c0.y) == 0 and w.tile(c0.x, c0.y) == TileDefs.AIR
	# salvato e ricaricato
	var saved := WorldSave.save(w, "prova_costrutti", {"nome": "costrutti"})
	var back := WorldSave.load_world("prova_costrutti")
	var same: bool = saved == OK and back != null and back.build == w.build
	WorldSave.delete("prova_costrutti")
	var vt := TileDefs.COSTRUTTO_T in [w.tile(spot.x + 4, spot.y - 2)]
	print("costrutti: %d piazzati (%d tipi), scavato lascia «%s» %s, tolto %s, salvati e ricaricati %s, vetrata trasparente %s" % [
		placed, BuildData.kinds().size(), want, "sì" if dropped else "NO", "sì" if gone else "NO", "sì" if same else "NO",
		"sì" if vt else "NO"])
	if not dropped or not gone or not same or not vt:
		print("ATTENZIONE: i costrutti non vanno come dovrebbero")
