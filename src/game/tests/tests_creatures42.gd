class_name TestsCreatures42
extends RefCounted
## Le creature della Roadmap 42 (voci 378-382). Gruppo «bestie».
## I mattoni nuovi dei comportamenti funzionano su una creatura vera (sparano, saltano, girano attorno); le risvegliate
## nascono solo dopo il Risveglio; ogni bioma ha le sue specie firma; gli stendardi cadono ogni 50 sconfitte e issati
## danno danno in più e ferite in meno; un evento con il capo lo fa arrivare all'obiettivo, e il segnale lo chiama.

var kit: TestKit
var m: Node2D
var res := {}


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await bricks()
	awake()
	signatures()
	banners()
	await events()
	m.fauna.clear(true)
	print("creature 42: %s" % str(res))
	if not res.values().all(func(x: Variant) -> bool: return x == true):
		print("ATTENZIONE: le creature della Roadmap 42 non vanno come dovrebbero")


## Voce 378: ogni mattone nuovo, messo su un grumo davanti al Germogliato, fa qualcosa (colpi, salti, movimento).
func bricks() -> void:
	m.snap_to(m.world.spawn)
	await kit.frames(3)
	m.fauna.clear(true)
	var did := {}
	for b in ["onda", "pioggia", "raggio", "spine", "molla", "rotola", "tonfo", "specchio", "orbita", "zigzag", "arrampica",
			"raffica", "balzo"]:
		var cr: Creature = m.fauna.add("grumo_muschio", m.player.position + Vector2(56, -8))
		cr.behaviors.clear()
		cr.behaviors.append(Behavior.make("vola" if b in ["orbita", "zigzag"] else "cammina"))
		cr.behaviors.append(Behavior.make(b))
		cr.target = m.player
		cr.provoke()
		cr.p = cr.p.duplicate()
		for k in ["wave_every", "rain_every", "beam_every", "ring_every", "roll_every", "slam_every", "burst_every"]:
			cr.p[k] = 0.3
		cr.p["sight"] = 40
		if b in ["orbita", "zigzag"]:
			cr.fly = true
		if b == "specchio":
			cr.boss = true
			cr.p["phase2"] = 0.9
			cr.hp = int(cr.hp_max * 0.5)
		var p0 := cr.position
		var s0: int = m.shots.count()
		var sum0 := cr.summons.size() + cr.minions
		var moved := 0.0
		var fired := false
		for f in 50:
			await kit.frames(1)
			if not is_instance_valid(cr):
				break
			moved = maxf(moved, cr.position.distance_to(p0))
			if m.shots.count() > s0 or not cr.fire.is_empty():
				fired = true
			if cr.minions > 0 or cr.summons.size() > sum0:
				fired = true
		did[b] = fired or moved > 6.0
		if is_instance_valid(cr):
			m.fauna.kill_quietly(cr)
		m.fauna.clear(true)
	var bad := did.keys().filter(func(k: String) -> bool: return not did[k])
	res["mattoni"] = bad.is_empty()
	print("creature 42, i mattoni nuovi: %d su %d fanno qualcosa; fermi %s" % [did.size() - bad.size(), did.size(), str(bad)])


## Voce 379: le risvegliate nascono solo dopo il Risveglio.
func awake() -> void:
	var was := CreaturesData.awake_on
	var v0 := CreaturesData.now_vigor
	CreaturesData.now_vigor = 5                     # (le risvegliate sono forti: di giorno al vigore 1 non nascono comunque)
	CreaturesData.awake_on = false
	var off := CreaturesData.of_stratum(0, false, "foresta").any(func(e: Array) -> bool: return String(e[0]).begins_with("ris_"))
	CreaturesData.awake_on = true
	var on := CreaturesData.of_stratum(0, false, "foresta").any(func(e: Array) -> bool: return String(e[0]).begins_with("ris_"))
	var sky_on := SkyData.pool_of("firmamento", false).any(func(e: Array) -> bool: return String(e[0]).begins_with("ris_"))
	CreaturesData.awake_on = was
	CreaturesData.now_vigor = v0
	var n := 0
	for id in CreaturesData.CREATURES:
		if CreaturesData.CREATURES[id].get("awake", false):
			n += 1
	res["risvegliate"] = not off and on and sky_on and n >= 90
	print("creature 42, le risvegliate: %d; nella foresta prima %s, dopo %s; nel firmamento dopo %s" % [n, off, on, sky_on])


## Voce 380: ogni bioma di superficie ha due specie firma, con una combinazione di comportamenti che non ha nessun altro.
func signatures() -> void:
	var combos := {}
	var per := {}
	for id in CreaturesData.CREATURES:
		var s := String(id)
		if not s.begins_with("firma_"):
			continue
		var d: Dictionary = CreaturesData.CREATURES[id]
		per[s.get_slice("_", 1)] = int(per.get(s.get_slice("_", 1), 0)) + 1
		combos[str(d["behaviors"])] = int(combos.get(str(d["behaviors"]), 0)) + 1
	var others := 0
	for id in CreaturesData.CREATURES:
		if not String(id).begins_with("firma_") and combos.has(str(CreaturesData.CREATURES[id].get("behaviors", []))):
			others += 1
	res["firma"] = per.size() >= 25 and others == 0
	print("creature 42, le specie firma: posti %d; combinazioni condivise con altre specie %d" % [per.size(), others])


## Voce 381: lo stendardo cade alla cinquantesima sconfitta; issato, +10% danno e −10% ferite contro la famiglia.
func banners() -> void:
	var ch: Character = m.character
	var fam := "grumi"
	if not FamiliesData.FAMILIES.has(fam):
		fam = String(FamiliesData.FAMILIES.keys()[0])
	var k0: Variant = ch.stats.get("uccisi_fam_" + fam, null)
	var s0: Variant = ch.stats.get("stendardo_" + fam, null)
	ch.stats["uccisi_fam_" + fam] = BannersData.EVERY - 1
	var d0: int = m.banners.dropped
	var cr: Creature = m.fauna.add(String(FamiliesData.FAMILIES[fam]["members"][0]), m.player.position + Vector2(30, -10))
	cr.family = fam
	m.fauna.kill(cr)
	var dropped: bool = m.banners.dropped == d0 + 1
	ch.stats.erase("stendardo_" + fam)
	ch.bisaccia.add(BannersData.item_of(fam), 1)
	var raised: bool = m.banners.raise(BannersData.item_of(fam))
	var mult: float = m.banners.mult(fam)
	var guard: float = m.banners.guard(fam)
	for key in ["uccisi_fam_" + fam, "stendardo_" + fam]:
		ch.stats.erase(key)
	if k0 != null:
		ch.stats["uccisi_fam_" + fam] = k0
	if s0 != null:
		ch.stats["stendardo_" + fam] = s0
	var golds := 0
	for id in BannersData.items():
		if bool(BannersData.items()[id].get("gold", false)) and not RecipesData.making(String(id)).is_empty():
			golds += 1
	res["stendardi"] = dropped and raised and is_equal_approx(mult, BannersData.DAMAGE) and is_equal_approx(guard, BannersData.GUARD) and golds >= 40
	print("creature 42, gli stendardi: famiglie %d, d'oro %d; cade %s, issato %s, danno ×%.2f, ferite ×%.2f" % [
		FamiliesData.FAMILIES.size(), golds, dropped, raised, mult, guard])


## Voce 382: il segnale chiama l'evento; all'obiettivo arriva il capo.
func events() -> void:
	var ev: Events = m.events
	var was_paused := ev.paused
	ev.paused = true
	ev.stop()
	m.character.bisaccia.add("segnale_assalto_rovi", 1)
	var ok := ev.call_event("segnale_assalto_rovi")
	var started := ev.active == "assalto_rovi"
	ev.kills = int(EventsData.EVENTS["assalto_rovi"]["goal"]) - 1
	ev.boss_out = false
	var cr: Creature = m.fauna.add("cinghiale_rovo", m.player.position + Vector2(30, -10))
	m.fauna.kill(cr)
	await kit.frames(2)
	var boss: bool = ev.boss_out
	ev.stop()
	ev.paused = was_paused
	m.lords.bar.follow(null)
	m.fauna.clear(true)
	var n := 0
	for id in EventsData.EVENTS:
		if EventsData.EVENTS[id].has("boss"):
			n += 1
	res["eventi"] = ok and started and boss and n >= 8 and EventsData.EVENTS.size() >= 13
	print("creature 42, gli eventi: %d (con il capo %d); il segnale lo chiama %s; all'obiettivo arriva il capo %s" % [
		EventsData.EVENTS.size(), n, started, boss])
