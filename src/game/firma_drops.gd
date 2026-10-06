class_name FirmaDrops
extends Node
## Da dove vengono le armi firma (voce 370; i dati nel pacchetto generato `src/data/vastita/armi_firma.gd`, tabelle
## «firma_f<fase>»: una a scelta tra le dieci della fase). La fase del posto è quella del mondo e dello strato
## (`SpineData.zone_phase`):
##   - ogni Guardiano risolto (curato o abbattuto) ne lascia una, della fase del suo mondo e del Fondo;
##   - i Signori, i Custodi, i capi delle maree, i Guardiani evocati e i capi delle prove ne lasciano una a volte (`BOSS`);
##   - gli scrigni delle rovine ne hanno una a volte (`PassRovine`, `SpineData.FIRMA_CHEST`).

const BOSS := 0.35

var m: Node2D
var dropped := 0                         # per le prove
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	m.guardian.resolved.connect(func(_how: String) -> void:
		drop(SpineData.zone_phase(int(m.world_meta.get("vigore", 1)), 4), m.guardian.heart_pos() + Vector2(16, -32)))
	m.fauna.killed.connect(_on_killed)


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
	if not is_instance_valid(c) or c.tame != null or not is_chief(c):
		return
	if _rng.randf() < BOSS:
		var s := StrataData.at(m.world, floori(c.position.x / 16.0), floori(c.position.y / 16.0))
		drop(SpineData.zone_phase(int(m.world_meta.get("vigore", 1)), s), c.position)


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
