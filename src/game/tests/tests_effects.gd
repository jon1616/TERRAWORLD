class_name TestsEffects
extends RefCounted
## Prove degli effetti speciali (voce 85) con i primi oggetti unici: Tizzone incendia, l'Eco del fulmine salta su altre
## creature, Sete di Linfa cura, Ultima radice alza il danno con poca Vita, Slancio fa correre dopo una creatura
## sconfitta, Inverno addosso gela attorno, Rovo vivo restituisce il colpo, Muschio che nasconde nasconde da feriti,
## Seconda radice salva dall'appassire; la scheda mostra gli effetti. Foto 152_effetti.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func _dummy(at: Vector2) -> Creature:
	var c: Creature = m.fauna.add("grumo_muschio", at)
	c.hp_max = 900
	c.hp = 900
	c.calm = true
	return c


func _wear(slot: String, id: String) -> void:
	var b: Bisaccia = m.character.bisaccia
	b.equip[slot] = id
	b.changed.emit()


func run() -> void:
	var w: World = m.world
	var b: Bisaccia = m.character.bisaccia
	var ef: Effects = m.effects
	var eq0: Dictionary = b.equip.duplicate()
	m.snap_to(w.spawn)
	await kit.frames(3)
	m.vitals.refill()
	var p: Vector2 = m.player.position
	var res := {}
	# armi in mano
	kit.hold("lingua_tizzone")
	await kit.frames(2)
	var c1 := _dummy(p + Vector2(24, -8))
	for k in 12:
		m.combat._strike(c1, 5, p.x, 0.1)
	res["tizzone"] = c1.burn_t > 0.0
	kit.hold("ramo_temporale")
	await kit.frames(2)
	var c2 := _dummy(p + Vector2(40, -8))
	var c3 := _dummy(p + Vector2(60, -8))
	for k in 6:
		m.combat._strike(c1, 5, p.x, 0.1)
	res["fulmine"] = c2.hp < 900 or c3.hp < 900
	kit.hold("falce_sete")
	await kit.frames(2)
	m.vitals.hp = 40
	var hp0: int = m.vitals.hp
	m.combat._strike(c1, 40, p.x, 0.1)
	res["sete"] = m.vitals.hp > hp0
	m.vitals.hp = 20
	res["furia"] = absf(ef.hit_mult() - 1.35) < 0.01
	m.vitals.refill()
	# accessori
	_wear("accessorio_1", "corno_cacciatore")
	await kit.frames(2)
	var c4 := _dummy(p + Vector2(16, -8))
	m.fauna.kill(c4)
	await kit.frames(2)
	res["slancio"] = m.player.effect_run > 1.2
	_wear("accessorio_1", "cuore_inverno")
	var c6 := _dummy(m.player.position + Vector2(18, -8))
	await kit.seconds(0.7)
	res["gelo"] = c6.chill_t > 0.0
	m.fauna.kill_quietly(c6)
	_wear("accessorio_1", "rovo_vivo")
	await kit.frames(2)
	var c5 := _dummy(p + Vector2(20, -8))
	var h5 := c5.hp
	m.vitals.hurt(20)
	res["rovo"] = c5.hp < h5
	m.vitals.refill()
	_wear("accessorio_1", "muschio_ombra")
	await kit.frames(2)
	m.vitals.hp = 25
	m.vitals.hurt(3)
	await kit.frames(2)
	res["ombra"] = Behavior.effect_stealth < 1.0
	m.vitals.refill()
	_wear("accessorio_2", "seme_secondo")
	await kit.frames(2)
	m.vitals.hurt(9999)
	res["seconda"] = m.vitals.hp > 0 and ef.saved >= 1
	res["scheda"] = ItemInfo.bbcode("seme_secondo").contains("✦") and ItemInfo.bbcode("seme_secondo").contains("Oggetto unico")
	await kit.seconds(0.4)
	await kit.save("152_effetti")
	# si rimette tutto com'era
	for c in [c1, c2, c3, c5]:
		if is_instance_valid(c):
			m.fauna.kill_quietly(c)
	b.equip = eq0
	b.changed.emit()
	kit.hold("piccone_radicite")
	m.vitals.refill()
	var bad := res.keys().filter(func(k: String) -> bool: return not res[k])
	print("effetti: %s; non vanno: %s" % [res, bad])
	if not bad.is_empty():
		print("ATTENZIONE: gli effetti speciali non funzionano come dovrebbero")
