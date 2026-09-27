class_name Vigor
extends Node
## Il vigore senza tetto (voce 79, dati in `VigorData`): il grado del mondo (vigore / 5) sceglie le indoli nuove delle
## creature (`Fauna.grade`, letto da `FamiliesData.roll_variant`), fa cadere le Schegge di vigore dalle creature e
## dai Guardiani, e fissa fin dove il Maglio tempra (`temper`, clic destro sul Maglio con l'attrezzo in mano).
## Le creature rigeneranti e gemelle si reggono in `Creature` (regen) e qui (`_on_killed`: la gemella si divide).

var m: Node2D
var grade := 0
var tempered := 0                      # per le prove
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	grade = VigorData.grade(int(m.world_meta.get("vigore", 1)))
	if m.giardino != null and m.giardino.active:
		grade = 0
	m.fauna.grade = grade
	m.fauna.killed.connect(_on_killed)
	if grade > 0 and not m.world_meta.get("grado_visto", false):
		m.world_meta["grado_visto"] = true
		m.hud.toast(arrival_text())


## «Vigore 10, grado 2: creature corazzate e rigeneranti; il Maglio tempra fino a +4.»
func arrival_text() -> String:
	var names := []
	for t in VigorData.tempers_for(grade):
		names.append(_plural(t))
	return "Vigore %d, grado %d: creature %s; Schegge di vigore; il Maglio tempra fino a +%d." % [
		int(m.world_meta.get("vigore", 1)), grade, ", ".join(names), VigorData.temper_cap(grade)]


static func _plural(t: String) -> String:
	return {"corazzata": "corazzate", "rigenerante": "rigeneranti", "gemella": "gemelle", "vorace": "voraci"}.get(t, t)


func _on_killed(c: Creature) -> void:
	if grade > 0:
		var n := 0
		if c.boss:
			n = VigorData.SHARD_BOSS * grade
		elif _rng.randf() < minf(VigorData.SHARD_CHANCE * grade, 0.6):
			n = 1 + _rng.randi_range(0, grade / 3)
		if n > 0:
			m.drops.spawn("scheggia_vigore", n, c.position + Vector2(0, -6))
	if bool(c.data.get("split", false)):
		split(c)


## La gemella sconfitta si divide in due creature piccole della stessa specie (senza indole: non si dividono ancora).
func split(c: Creature) -> Array:
	var pr := FamiliesData.parts(c.id)
	var out := []
	for k in 2:
		var id := FamiliesData.variant_id(String(pr[0]), "piccolo", String(pr[2]), "")
		var cd := CreaturesData.get_data(id)
		var at: Vector2 = c.position + Vector2(-10.0 if k == 0 else 10.0, float(c.half.y) - float(cd["half"][1]))
		var cr: Creature = m.fauna.add(id, at)
		cr.strengthen(m.fauna.vigor_mult, m.fauna.vigor_mult * DangerData.DAMAGE)
		cr.vel = Vector2(-80.0 if k == 0 else 80.0, -160.0)
		out.append(cr)
	return out


## Il livello di tempra di una casella.
static func level(slot: Dictionary) -> int:
	return int((slot.get("dati", {}) as Dictionary).get("tempra", 0))


## Tempra l'oggetto in mano, se si può: restituisce il messaggio da mostrare.
func temper_hand() -> String:
	var b: Bisaccia = m.character.bisaccia
	var i: int = m.hud.sel
	var slot: Dictionary = b.slots[i]
	var msg := temper(slot)
	if msg.begins_with("Temprato"):
		b.slots[i] = slot
		b.changed.emit()
		m.sfx.play("crea", m.player.position)
	m.hud.toast(msg)
	return msg


## Tempra una casella di un livello (se l'oggetto si tempra, il grado lo permette e le Schegge bastano).
func temper(slot: Dictionary) -> String:
	var it := ItemsData.get_item(String(slot.get("id", "")))
	if slot.is_empty() or not (it.has("form") or it.get("kind", "") in ["guanti", "stivali", "mantello", "piccone", "ascia", "spada", "arco", "elmo", "corazza", "gambali", "bastone"]):
		return "Il Maglio tempra solo attrezzi, armi e armature: tienine uno in mano."
	var lv := level(slot) + 1
	var cap := VigorData.temper_cap(grade)
	if lv > cap:
		if grade == 0:
			return "Il Maglio tempra solo nei mondi di vigore %d e oltre." % VigorData.STEP
		return "In un mondo di %s il Maglio tempra fino a +%d: serve un mondo più vigoroso." % [VigorData.grade_name(grade), cap]
	var cost := lv * VigorData.TEMPER_COST
	if Crafting.have(m.character.bisaccia, "scheggia_vigore") < cost:
		return "Per la tempra +%d servono %d Schegge di vigore." % [lv, cost]
	Crafting.take(m.character.bisaccia, "scheggia_vigore", cost)
	var dati: Dictionary = slot.get("dati", {})
	dati["tempra"] = lv
	slot["dati"] = dati
	tempered += 1
	return "Temprato: %s +%d." % [String(it.get("name", "")), lv]


## La riga per la scheda del Maglio.
func hint() -> String:
	if grade == 0:
		return "Tempra: solo nei mondi di vigore %d e oltre" % VigorData.STEP
	return "Tempra fino a +%d (%s)" % [VigorData.temper_cap(grade), VigorData.grade_name(grade)]
