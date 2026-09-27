class_name TestsSets
extends RefCounted
## Prove della voce 26: un set completo dà il suo bonus (e toglierne un pezzo lo toglie), la Scorza dei set conta
## nelle ferite, le vesti di seta si sommano al loro set, la casella Esamina dice di che set è un pezzo; foto 50_set con
## la Bisaccia aperta e un set completo.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _wear_all(ids: Array) -> void:
	var b: Bisaccia = m.character.bisaccia
	for sl in Bisaccia.EQUIP_SLOTS:
		b.wear(sl, {})
	var acc := 1
	for id in ids:
		var kind := String(ItemsData.get_item(id)["kind"])
		var slot := kind
		if kind == "accessorio":
			slot = "accessorio_%d" % acc
			acc += 1
		b.wear(slot, {"id": id, "n": 1})


func run() -> void:
	var b: Bisaccia = m.character.bisaccia
	var old := b.equip.duplicate()
	print("set: %d in tutto (%d di metallo)" % [SetsData.all().size(), SetsData.METAL_BONUS.size()])
	# pallidite: corsa e colpi
	_wear_all(["elmo_pallidite", "corazza_pallidite", "gambali_pallidite", "guanti_pallidite", "stivali_pallidite"])
	await kit.frames(1)
	print("set di pallidite completo %s: corsa ×%.2f, colpi ×%.2f" % [m.gear.sets, m.player.run_mult, m.combat.spd_mult])
	_wear_all(["elmo_pallidite", "corazza_pallidite", "gambali_pallidite", "guanti_pallidite"])
	await kit.frames(1)
	print("senza stivali: set %s, corsa ×%.2f" % [m.gear.sets, m.player.run_mult])
	# legnoferro: la Scorza del set conta nelle ferite
	_wear_all(["elmo_legnoferro", "corazza_legnoferro", "gambali_legnoferro", "guanti_legnoferro", "stivali_legnoferro"])
	await kit.frames(1)
	m.vitals.refill()
	var lost: int = m.vitals.hurt(30)
	print("set di legnoferro: Scorza dei pezzi %d + set %d, una ferita da 30 toglie %d" % [b.scorza(), m.vitals.set_scorza, lost])
	m.vitals.refill()
	# le vesti di seta: effetti dei pezzi e del set insieme
	_wear_all(["cappuccio_seta", "veste_seta", "calzari_seta"])
	await kit.frames(1)
	print("vesti di seta complete %s: incantesimi ×%.3f, Linfa ×%.3f" % [m.gear.sets, m.combat.magic_mult, m.vitals.linfa_regen_mult])
	# una coppia di accessori
	_wear_all(["anello_sanguinella", "anello_lagunite"])
	await kit.frames(1)
	print("coppia Fuoco e gelo %s: danno ×%.2f, incantesimi ×%.2f" % [m.gear.sets, m.combat.dmg_mult, m.combat.magic_mult])
	var info := ItemInfo.bbcode("elmo_ambra")
	print("Esamina di un elmo d'ambra: parla del set %s" % ("sì" if info.contains("Luce fossile") else "NO"))
	# foto: set d'ambra completo, Bisaccia aperta
	_wear_all(["elmo_ambra", "corazza_ambra", "gambali_ambra", "guanti_ambra", "stivali_ambra", "anello_nottilite", "occhio_vuoto"])
	m.hud.panel.toggle()
	await kit.seconds(1.5)
	await kit.save("50_set")
	m.hud.panel.toggle()
	for sl in Bisaccia.EQUIP_SLOTS:
		b.wear(sl, {})
		if old.has(sl):
			b.wear(sl, {"id": old[sl], "n": 1})
	await kit.frames(1)
