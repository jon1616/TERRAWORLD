class_name TestsUniques
extends RefCounted
## Prove degli oggetti unici (voce 98): sono almeno 150, tutti in una serie, con storia e posto; il tiro da un pool
## preferisce quelli non ancora trovati; una serie completa (nell'Erbario) dà il suo bonus per sempre; trovarne uno lo
## annuncia con la serie; un effetto nuovo (Linfa raccolta) cura a ogni creatura sconfitta; la collezione
## nell'Enciclopedia dice quanti.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var res := {}
	var n := 0
	for id in ItemsData.all():
		if ItemsData.get_item(id).get("unique", false):
			n += 1
	res["almeno_150"] = n >= 150
	# il tiro preferisce i nuovi
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var pool := UniqueSeriesData.pool_items("profondo")
	var found := {}
	for id in pool.slice(0, pool.size() - 1):
		found[id] = 1
	res["preferisce_nuovi"] = UniquesData.roll("profondo", rng, found) == String(pool[pool.size() - 1])
	# una serie completa dà il bonus
	var ob: Dictionary = m.character.erbario.get("oggetti", {})
	var saved := ob.duplicate()
	var sid := "lame_perdute"
	var dmg0: float = m.combat.dmg_mult
	for id in UniqueSeriesData.SERIES[sid]["items"]:
		ob[id] = 1
	m.gear.refresh()
	res["serie_bonus"] = sid in m.gear.series and m.combat.dmg_mult > dmg0
	# trovarne uno: l'avviso con la serie (l'Erbario lo ricorda)
	ob.clear()
	ob.merge(saved)
	m.gear.refresh()
	var stat0 := int(m.character.stats.get("unici", 0))
	m.erbario.discovered.emit("oggetti", "arco_eco")
	res["annuncio"] = int(m.character.stats.get("unici", 0)) == stat0 + 1
	# Linfa raccolta: una creatura sconfitta cura
	var b: Bisaccia = m.character.bisaccia
	var eq0: Dictionary = b.equip.duplicate()
	b.equip["accessorio_1"] = "giglio_linfa"
	b.changed.emit()
	m.vitals.hp = 50
	var hp0: int = m.vitals.hp
	var cr: Creature = m.fauna.add("grumo_muschio", m.player.position + Vector2(20, -8))
	m.fauna.kill(cr)
	await kit.frames(2)
	res["linfa_raccolta"] = m.vitals.hp > hp0
	b.equip = eq0
	b.changed.emit()
	m.vitals.refill()
	# la collezione
	var cat := EncyCatalogs.inline("cat_unici")
	res["collezione"] = cat.contains("Unici trovati") and cat.contains("Lame perdute")
	var bad := res.keys().filter(func(k: String) -> bool: return not res[k])
	print("unici: %d in %d serie; %s; non vanno: %s" % [n, UniqueSeriesData.SERIES.size(), res, bad])
	if not bad.is_empty():
		print("ATTENZIONE: gli oggetti unici non funzionano come dovrebbero")
