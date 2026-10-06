class_name FirmaDrops
extends Node
## Da dove vengono le armi firma (voce 370; i dati nel pacchetto generato `src/data/vastita/armi_firma.gd`, tabelle
## «firma_f<fase>»: una a scelta tra le dieci della fase). La fase del posto è quella del mondo e dello strato
## (`SpineData.zone_phase`):
##   - ogni Guardiano risolto (curato o abbattuto) ne lascia una, della fase del suo mondo e del Fondo;
##   - i Signori, i Custodi, i capi delle maree, i Guardiani evocati e i capi delle prove ne lasciano una a volte (`BOSS`);
##   - gli scrigni delle rovine ne hanno una a volte (`PassRovine`, `SpineData.FIRMA_CHEST`).

const BOSS := 0.35
const ACC := 0.4                         # voce 383: un accessorio firma dai capi
const PET := 0.06                        # voce 388: un animaletto dai capi
const ESS := 0.3                         # voce 391: un'essenza della forgia dai capi e dai Sacchetti

var m: Node2D
var dropped := 0                         # per le prove
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	m.guardian.resolved.connect(func(_how: String) -> void:
		bag(String(m.guardian.info().get("id", "")), m.guardian.heart_pos() + Vector2(16, -32)))
	m.fauna.killed.connect(_on_killed)


## Voce 374: il Sacchetto di un Guardiano (quello dei Guardiani generati per chi non ne ha uno suo).
func bag(gid: String, at: Vector2) -> String:
	var id := "sacchetto_" + gid
	if not ItemsData.has(id):
		id = "sacchetto_generato"
	m.drops.spawn(id, 1, at)
	dropped += 1
	return id


## Apre un Sacchetto dalla mano: tutto nella Bisaccia (o a terra se non c'è posto). La prima volta il gioiello è sicuro.
func open_bag(id: String) -> bool:
	var b: Bisaccia = m.character.bisaccia
	if not b.remove(id, 1):
		return false
	var key := "aperti_" + id
	var first := int(m.character.stats.get(key, 0)) == 0
	m.character.stats[key] = int(m.character.stats.get(key, 0)) + 1
	var got := LootData.roll(String(ItemsData.get_item(id).get("table", id)), _rng, first)
	var arm := "armatura_" + id.trim_prefix("sacchetto_")       # voce 389: un pezzo delle spoglie del Guardiano
	if LootData.TABLES.has(arm):
		for k in LootData.roll(arm, _rng):
			got[k] = int(got.get(k, 0)) + 1
	if _rng.randf() < ESS * 2.0:                       # voce 391: un'essenza della forgia
		for k in LootData.roll("essenze_forgia", _rng):
			got[k] = int(got.get(k, 0)) + 1
	var names := []
	for it in got:
		var n := int(got[it])
		var left := b.add(String(it), n)                 # (restituisce quanti non ci stavano)
		if left > 0:
			m.drops.spawn(String(it), left, m.player.position + Vector2(0, -16))
		if not String(it) in ["lumino"] and not String(it).begins_with("lingotto_"):
			names.append(String(ItemsData.get_item(String(it)).get("name", it)))
	Fx.puff(m.fx, m.player.position + Vector2(0, -20), Color(1.8, 1.5, 0.8))
	m.sfx.play("dono")
	m.hud.toast("Nel Sacchetto: %s" % ", ".join(names))
	return true


## Le creature che contano come capi (non i Guardiani del Cuore: per loro c'è `resolved`).
static func is_chief(c: Creature) -> bool:
	var d: Dictionary = c.data
	if GuardianGen.is_gen(c.id):
		return false
	for g in GuardiansData.LIST:
		if String(g["creature"]) == c.base or String(g["creature"]) == c.id:
			return false
	return bool(d.get("boss", false)) or d.has("lord") or String(d.get("great", "")) != "" or c.has_meta("evocato")


func _on_killed(c: Creature) -> void:
	if not is_instance_valid(c) or c.tame != null:
		return
	# voce 374: un Guardiano rievocato al Cerchio lascia di nuovo il suo Sacchetto
	if c.has_meta("evocato"):
		for g in GuardiansData.LIST:
			if String(g["creature"]) == c.id:
				bag(String(g["id"]), c.position)
				return
		if GuardianGen.is_gen(c.id):
			bag("generato", c.position)
			return
		if ItemsData.has("sacchetto_" + c.id):              # voce 376: i boss facoltativi e i superboss
			m.drops.spawn("sacchetto_" + c.id, 1, c.position)
			dropped += 1
			return
	if not is_chief(c):
		return
	var s := StrataData.at(m.world, floori(c.position.x / 16.0), floori(c.position.y / 16.0))
	var ph := SpineData.zone_phase(int(m.world_meta.get("vigore", 1)), s)
	if _rng.randf() < BOSS:
		drop(ph, c.position)
	# Roadmap 43: un accessorio firma della fase (voce 383) e, raro, un animaletto (voce 388)
	if _rng.randf() < ACC:
		_roll("accessori_f%d" % clampi(ph, 1, 23), c.position)
	if _rng.randf() < PET:
		_roll("animaletti", c.position)
	if _rng.randf() < ESS:
		_roll("essenze_forgia", c.position)
	_roll("armatura_" + c.id, c.position)               # voce 389: un pezzo delle spoglie del capo (se ne ha)


func _roll(table: String, at: Vector2) -> void:
	if not LootData.TABLES.has(table):
		return
	var got := LootData.roll(table, _rng)
	for id in got:
		m.drops.spawn(String(id), 1, at)
		dropped += 1


## Fa cadere un'arma firma della fase. Restituisce il suo id ("" se la fase non ne ha).
func drop(phase: int, at: Vector2) -> String:
	var t := "firma_f%d" % clampi(phase, 1, 23)
	if not LootData.TABLES.has(t):
		return ""
	var got := LootData.roll(t, _rng)
	for id in got:
		m.drops.spawn(String(id), 1, at)
		dropped += 1
		m.hud.toast("Un'arma firma: %s" % String(ItemsData.get_item(String(id)).get("name", id)))
		return String(id)
	return ""
