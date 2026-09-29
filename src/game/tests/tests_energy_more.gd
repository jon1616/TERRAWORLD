class_name TestsEnergyMore
extends RefCounted
## Roadmap 19: le prove della rete dalla voce 196 in poi (sorgenti speciali, riserve, macchine, logica). Usa gli aiuti
## di `TestsEnergy` (`place`, `lay`, `ticks`, `clean_spot`).

var kit: TestKit
var m: Node
var t: TestsEnergy


func _init(tk: TestKit, base: TestsEnergy) -> void:
	kit = tk
	m = tk.m
	t = base


## Voce 196: la ruota della mandria, il parafulmine, la Radice-madre, la Radice del Giardino.
func special() -> void:
	var e: Energy = m.energy
	var w: World = m.world
	var p: Vector2i = await t.clean_spot(130, 36)
	var y := p.y
	# la ruota della mandria: una creatura della mandria di livello 3 che corre dentro = 25 pulsi; affamata niente
	var wheel := t.place("ruota_mandria", Vector2i(p.x, y))
	await t.ticks(2)
	var rm: Machine = e.machines[wheel]
	var cr: Creature = m.fauna.add("pecora_muschio", Vector2(wheel) * 16.0 + Vector2(24, 16))
	cr.set_process(false)
	cr.tame = BhMandria.new()
	cr.tame.rec = {"lvl": 3, "fame": 0.1}
	cr.vel = Vector2(60, 0)
	var running := rm.bh.produce(rm, e)
	cr.tame.rec["fame"] = 0.95
	var hungry := rm.bh.produce(rm, e)
	m.fauna.clear()
	print("ruota della mandria: una creatura di livello 3 dà %.0f pulsi, affamata %.0f" % [running, hungry])
	# il parafulmine: un fulmine nel temporale riempie l'Otre della sua rete
	var rod := t.place("parafulmine", Vector2i(p.x + 6, y))
	var otre := t.place("otre_linfa", Vector2i(p.x + 7, y))
	t.lay_row(p.x + 6, p.x + 7, y, 1)
	await t.ticks(2)
	var target: int = e.bolt_target(m.player_cell().x)
	var g0 := float((e.machines[otre] as Machine).st.get("g", 0.0))
	var hit: Vector2i = m.weather.strike()
	await t.ticks(1)
	var g1 := float((e.machines[otre] as Machine).st.get("g", 0.0))
	print("parafulmine: attira il fulmine sulla sua colonna %s, l'Otre da %.0f a %.0f gocce" % [target == rod.x and hit.x == rod.x, g0, g1])
	# la Radice-madre accanto al Cuore del mondo: curato 250, sconfitto 120, dorme 0
	var heart := Vector2i(p.x + 12, y - 2)
	w.stations[heart] = "cuore_vivo"
	var root := t.place("radice_madre", Vector2i(p.x + 16, y))
	await t.ticks(2)
	var mm: Machine = e.machines[root]
	var g_state = m.world_meta.get("guardiano", "dorme")
	m.world_meta["guardiano"] = "curato"
	var cured := mm.bh.produce(mm, e)
	m.world_meta["guardiano"] = "sconfitto"
	var beaten := mm.bh.produce(mm, e)
	m.world_meta["guardiano"] = "dorme"
	var asleep := mm.bh.produce(mm, e)
	m.world_meta["guardiano"] = g_state
	w.stations.erase(heart)
	print("Radice-madre: Cuore guarito %.0f, ferito %.0f, che dorme %.0f" % [cured, beaten, asleep])
	# la Radice del Giardino: fuori dal Giardino niente, nel Giardino vicino all'Albero 50 a stadio
	var groot := t.place("radice_giardino", Vector2i(p.x + 22, y))
	await t.ticks(2)
	var gm: Machine = e.machines[groot]
	var outside := gm.bh.produce(gm, e)
	var was_garden = m.world_meta.get("giardino", false)
	m.world_meta["giardino"] = true
	var tree_o := Vector2i(p.x + 28, y - 3)
	w.stations[tree_o] = "albero_madre_1"
	var inside := gm.bh.produce(gm, e)
	w.stations.erase(tree_o)
	m.world_meta["giardino"] = was_garden
	print("Radice del Giardino: fuori dal Giardino %.0f, vicino all'Albero %.0f (stadio %d)" % [outside, inside, m.albero.stage()])
	var ok := running >= 24.0 and hungry == 0.0 and target == rod.x and g1 >= g0 + 2900.0 and cured == 250.0 \
		and beaten == 120.0 and asleep == 0.0 and outside == 0.0 and inside >= 50.0
	if not ok:
		print("ATTENZIONE: le sorgenti speciali non danno ciò che devono")
	for o in [wheel, rod, otre, root, groot]:
		t.unplace(o)
