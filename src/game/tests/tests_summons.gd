class_name TestsSummons
extends RefCounted
## Prove dell'evocazione dei Guardiani (voce 84): senza Cerchio o senza averlo affrontato non si evoca; con il Richiamo
## il Nodo nasce sopra il Cerchio, attorno non nasce niente, sconfitto lascia il bottino dell'evocazione (niente Linfa
## antica) e il Richiamo si consuma; un Guardiano generato si evoca con il Sigillo (che resta) e un Seme d'eco. Foto
## 151_evocazione.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var w: World = m.world
	var sm: Summons = m.summons
	var ch: Character = m.character
	var b: Bisaccia = kit.bisaccia()
	var g0: Dictionary = ch.guardiani.duplicate(true)
	ch.guardiani = {}
	m.vitals.refill()
	var spot := kit.flat_spot(w.spawn + Vector2i(20, 0), 6)
	if spot.x < 0:
		spot = w.spawn
	kit.flatten(spot, 6)
	m.snap_to(spot)
	await kit.frames(3)
	b.add("richiamo_nodo", 2)
	var no_arena := sm.summon("richiamo_nodo")
	var o := spot + Vector2i(-1, 0)
	w.stations[o] = "arena"
	m.view.add_station(o)
	var not_met := sm.summon("richiamo_nodo")
	sm.remember("guardiano_nodo")
	var ok := sm.summon("richiamo_nodo")
	var boss: Creature = sm.active
	var quiet: bool = m.fauna.quiet_c == o
	await kit.seconds(0.8)
	await kit.save("151_evocazione")
	var sap0 := b.count("linfa_antica")
	var frag0 := b.count("frammento_nodo")
	if boss != null:
		boss.position = m.player.position + Vector2(20, -10)
		m.fauna.kill(boss)
	await kit.seconds(1.2)
	var got := b.count("frammento_nodo") - frag0
	var no_sap := b.count("linfa_antica") == sap0
	var ended: bool = sm.active == null and m.fauna.quiet_c.x < 0
	var used := b.count("richiamo_nodo") == 1
	# un Guardiano generato, con il Sigillo e un Seme d'eco
	var gid := GuardianGen.id_for(424242)
	sm.remember(gid)
	b.add_stack({"id": "sigillo_guardiano", "n": 1, "dati": Summons.sigil_of(gid)})
	b.add("seme_eco", 1)
	var si := -1
	for i in b.slots.size():
		if b.id_at(i) == "sigillo_guardiano":
			si = i
	var gen_ok := sm.summon("sigillo_guardiano", b.data_at(si))
	var gen_boss: Creature = sm.active
	var gen_right := gen_boss != null and gen_boss.id == gid
	if gen_boss != null:
		m.fauna.kill_quietly(gen_boss)
		sm._end()
	var sigil_kept := b.count("sigillo_guardiano") == 1 and b.count("seme_eco") == 0
	# si rimette tutto com'era
	b.remove("richiamo_nodo", b.count("richiamo_nodo"))
	b.remove("sigillo_guardiano", b.count("sigillo_guardiano"))
	w.stations.erase(o)
	m.view.remove_station(o)
	ch.guardiani = g0
	m.vitals.refill()
	print("evocazioni: senza Cerchio %s, mai affrontato %s, con il Richiamo %s (quiete attorno %s); sconfitto: frammenti +%d, niente Linfa antica %s, fine %s, Richiamo consumato %s; generato con il Sigillo %s (quello giusto %s, Sigillo resta e Seme d'eco consumato %s)" % [
		"no" if not no_arena else "SÌ", "no" if not not_met else "SÌ", "sì" if ok else "NO", "sì" if quiet else "NO", got,
		"sì" if no_sap else "NO", "sì" if ended else "NO", "sì" if used else "NO", "sì" if gen_ok else "NO",
		"sì" if gen_right else "NO", "sì" if sigil_kept else "NO"])
	if no_arena or not_met or not ok or not quiet or got < 10 or not no_sap or not ended or not used or not gen_ok \
			or not gen_right or not sigil_kept:
		print("ATTENZIONE: l'evocazione dei Guardiani non funziona come dovrebbe")
