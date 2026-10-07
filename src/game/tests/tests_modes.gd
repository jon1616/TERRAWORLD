class_name TestsModes
extends RefCounted
## La difficoltà come contenuto (Roadmap 49, voce 405). Gruppo «modalita».
## Le tre modalità e i loro oggetti; in Radice dura le creature selvatiche sono più forti; nel Vuoto un boss dà il suo
## cimelio (un bonus per sempre) e un oggetto in più, e le ferite caricano la Furia del Giardiniere.

var kit: TestKit
var m: Node2D
var res := {}


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var mode0: int = m.modes.mode
	data()
	creatures()
	loot_and_relic()
	fury()
	m.modes.mode = mode0
	Creature.mode_hp = 1.0
	Creature.mode_dmg = 1.0
	Creature.mode_phase = 1.0
	print("modalita: %s" % str(res))
	if not res.values().all(func(x: Variant) -> bool: return x == true):
		print("ATTENZIONE: le modalità non vanno come dovrebbero")


func data() -> void:
	var own := 0
	var cimeli := 0
	for id in ItemsData.all():
		var it: Dictionary = ItemsData.all()[id]
		if int(it.get("modo", 0)) > 0:
			own += 1
		if String(it.get("kind", "")) == "cimelio":
			cimeli += 1
	res["dati"] = ModesData.MODES.size() == 3 and own >= 100 and cimeli >= 50
	print("modalità: %d; oggetti propri delle modalità dure %d, di cui cimeli %d" % [ModesData.MODES.size(), own, cimeli])


## In Radice dura una creatura selvatica ha più Vita e più danno.
func creatures() -> void:
	var a: Creature = m.fauna.add("lepre_linfa", m.player.position + Vector2(160, -8))
	a.strengthen(1.0)
	var hp0: int = a.hp_max
	m.fauna.kill(a)
	var md := ModesData.of(1)
	Creature.mode_hp = float(md["hp"])
	Creature.mode_dmg = float(md["dmg"])
	var b: Creature = m.fauna.add("lepre_linfa", m.player.position + Vector2(160, -8))
	b.strengthen(1.0)
	var hp1: int = b.hp_max
	m.fauna.kill(b)
	Creature.mode_hp = 1.0
	Creature.mode_dmg = 1.0
	res["creature"] = hp1 > hp0
	print("modalità, una lepre: Vita %d in Normale, %d in Radice dura" % [hp0, hp1])


## Nel Vuoto un capo dà il suo cimelio la prima volta e un oggetto in più; il cimelio dà il suo bonus per sempre.
func loot_and_relic() -> void:
	m.modes.mode = 2
	var seen: Dictionary = m.character.erbario.get("oggetti", {})
	var had := seen.has("cimelio_capo_cinghiale")
	seen.erase("cimelio_capo_cinghiale")
	var got: Array = m.firma._mode_loot("capo_cinghiale", 1.0)
	var relic := got.has("cimelio_capo_cinghiale")
	var extra := got.size() >= 2
	# il bonus: un cimelio della fortuna
	var lid := ""
	for cid in GearEffects.cimeli():
		if (ItemsData.get_item(String(cid))["cimelio"] as Dictionary).has("luck"):
			lid = String(cid)
			break
	var luck0: float = m.fauna.luck
	var had_l := seen.has(lid)
	seen[lid] = 1
	m.gear.refresh()
	var luck1: float = m.fauna.luck
	if not had_l:
		seen.erase(lid)
	if had:
		seen["cimelio_capo_cinghiale"] = 1
	m.gear.refresh()
	m.modes.mode = 0
	res["cimeli"] = relic and extra and luck1 > luck0
	print("modalità, il Vuoto: dal capo %s; fortuna %.2f → %.2f con «%s»" % [str(got), luck0, luck1, lid])


## Nel Vuoto le ferite caricano la Furia; piena, si scatena (più danno).
func fury() -> void:
	m.modes.mode = 2
	var d0: float = m.combat.dmg_mult
	var u0: int = m.modes.unleashed
	m.modes.charge = 95.0
	m.modes._on_wounded(maxi(m.vitals.hp_max / 10, 5))
	var on: bool = m.boons.active.has(ModesData.FURY_BOON)
	var d1: float = m.combat.dmg_mult
	m.boons.active.erase(ModesData.FURY_BOON)
	m.boons._refresh()
	m.modes.mode = 0
	m.modes.charge = 0.0
	res["furia"] = on and m.modes.unleashed == u0 + 1 and d1 > d0 * 1.4
	print("modalità, la Furia del Giardiniere: scatenata %s, danno ×%.2f → ×%.2f" % [on, d0, d1])
