class_name TestsCompanions
extends RefCounted
## Prove della voce 37: il compagno arriva e se ne va con il clic, segue il Germogliato quando corre, i suoi doni
## (luce della Lucciolina, calamita del Grumetto, Linfa dello Spiritello), resta con il personaggio; i bastoni
## evocatori (Linfa spesa, al massimo due alleati, tre con il Fischietto) e gli alleati che sconfiggono una creatura.
## Foto 66_compagni.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var cp: Companions = m.companions
	var b: Bisaccia = m.character.bisaccia
	kit.make_room()
	var spot := kit.flat_spot(world.spawn + Vector2i(60, 0), 10)
	if spot.x < 0:
		print("ATTENZIONE: nessun terreno piano per i compagni")
		return
	kit.flatten(spot, 16)
	m.snap_to(spot)
	await kit.frames(3)
	# la Lucciolina: arriva, fa luce, segue
	var on := cp.toggle_pet("vasetto_lucciolina")
	await kit.seconds(0.5)
	var lit: bool = not (m.light.extra.get("compagno", []) as Array).is_empty()
	m.player.auto_dir = 1
	await kit.seconds(1.5)
	m.player.auto_dir = 0
	await kit.seconds(1.0)
	var near: bool = cp.pet != null and cp.pet.position.distance_to(m.player.position) < 5.0 * S
	print("Lucciolina: chiamata %s, fa luce %s, segue il Germogliato che corre %s, salvata nel personaggio (posto %d)" % [
		"sì" if on else "NO", "sì" if lit else "NO", "sì" if near else "NO", int(m.character.stats.get("compagno", 0))])
	# il Grumetto al suo posto: la calamita; poi lo Spiritello: la Linfa
	cp.toggle_pet("gelatina_viva")
	var mag: float = m.drops.magnet_mult
	cp.toggle_pet("goccia_spiritello")
	var lin: float = m.vitals.pet_linfa
	var only_one: bool = m.get_children().filter(func(n: Node) -> bool: return n is Ally and not n.is_queued_for_deletion()).size() == 1
	await kit.frames(2)
	cp.toggle_pet("goccia_spiritello")
	print("Grumetto: oggetti attirati ×%.1f; Spiritello: Linfa ×%.1f; un compagno alla volta %s; congedato %s (calamita ×%.1f)" % [
		mag, lin, "sì" if only_one else "NO", "sì" if cp.pet == null else "NO", m.drops.magnet_mult])
	cp.toggle_pet("vasetto_lucciolina")
	# gli evocatori: Linfa, quanti insieme
	cp.dismiss_allies()
	m.vitals.linfa = m.vitals.linfa_max
	var l0: int = m.vitals.linfa
	for i in 3:
		cp.summon("bastone_grumi_amici")
	var two: int = cp.allies.size()
	var spent: int = l0 - m.vitals.linfa
	var old := _wear(b, "fischietto_branco")
	m.gear.refresh()
	m.vitals.linfa = m.vitals.linfa_max
	cp.summon("bastone_falena_amica")
	cp.summon("bastone_vagavuoto")
	print("evocatori: dopo tre richiami %d alleati (Linfa spesa %d); con il Fischietto %d" % [two, spent, cp.allies.size()])
	# gli alleati combattono: una creatura vicina
	var cr: Creature = m.fauna.add("grumo_resina", m.player.position + Vector2(5 * S, -8))
	var hp0: int = cr.hp
	var t := 0.0
	while t < 8.0 and is_instance_valid(cr) and m.fauna.list.has(cr):
		await kit.seconds(0.25)
		t += 0.25
	var beaten: bool = not is_instance_valid(cr) or not m.fauna.list.has(cr)
	print("alleati contro un grumo (%d Vita): %s in %.1f s" % [hp0, "sconfitto" if beaten else "ancora vivo", t])
	if not beaten:
		print("ATTENZIONE: gli alleati non hanno sconfitto il grumo")
		m.fauna.kill_quietly(cr)
	m.vitals.linfa = m.vitals.linfa_max
	cp.summon("bastone_grumi_amici")
	await kit.seconds(0.6)
	await kit.save("66_compagni")
	cp.dismiss_allies()
	cp.dismiss_pet()
	_unwear(b, old)
	m.gear.refresh()


## Il Fischietto al posto del secondo accessorio (le prove di prima possono averli occupati tutti e due).
func _wear(b: Bisaccia, id: String) -> String:
	var old := String(b.equip.get("accessorio_2", ""))
	b.equip["accessorio_2"] = id
	return old


func _unwear(b: Bisaccia, old: String) -> void:
	if old == "":
		b.equip.erase("accessorio_2")
	else:
		b.equip["accessorio_2"] = old
