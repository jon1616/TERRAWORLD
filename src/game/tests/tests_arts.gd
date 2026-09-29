class_name TestsArts
extends RefCounted
## Roadmap 25 «Le arti»: maestria delle armi, tecniche, taglie, prove del Cerchio (gruppo `arti`).

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await mastery()
	await techniques()
	await bounties()
	await trials()
	await panel()


## Voce 247: una creatura sconfitta con la lancia in mano dà punti alla lancia; al rango 3 la tecnica si apre; il danno
## con la lancia cresce, con un'altra forma no.
func mastery() -> void:
	var ar: WeaponArts = m.arts
	var st: Dictionary = m.character.stats
	var saved := int(st.get("arte_lancia", 0))
	st["arte_lancia"] = 0
	var lance := "lancia_radicite"
	var fl := WeaponArts.form_of(lance)
	var fs := WeaponArts.form_of("spada_radicite")
	var fp := WeaponArts.form_of("piccone_radicite")
	var slot := kit.hold(lance)
	var foe: Creature = m.fauna.add("grumo_muschio", m.player.position + Vector2(40, -10))
	m.fauna.kill(foe)
	var got := ar.points("lancia")
	ar.add("lancia", ArtsData.points_for(3))
	var r := ar.rank("lancia")
	var mult: float = ar.mult_now()
	var ok: bool = fl == "lancia" and fs == "spada" and fp == "" and got >= 1 and r >= 3 and ArtsData.tech_grade(r) >= 1 \
		and is_equal_approx(mult, 1.0 + ArtsData.DMG_PER_RANK * r) and ArtsData.rank_of(ArtsData.points_for(10)) == 10
	print("maestria delle armi: forme %s/%s/%s; una creatura dà %d punti; rango %d, tecnica di grado %d, danno ×%.2f" % [fl, fs,
		fp if fp != "" else "(attrezzo)", got, r, ArtsData.tech_grade(r), mult])
	if not ok:
		print("ATTENZIONE: la maestria delle armi non va")
	st["arte_lancia"] = saved


## Voce 248: chiusa senza maestria; aperta costa Linfa e ha un'attesa; il fendente colpisce le creature attorno, la
## carica scatta in avanti, ogni forma ha la sua tecnica scritta nei dati.
func techniques() -> void:
	var tq: Techniques = m.techniques
	var st: Dictionary = m.character.stats
	var saved := {"spada": int(st.get("arte_spada", 0)), "lancia": int(st.get("arte_lancia", 0))}
	st["arte_spada"] = 0
	kit.hold("spada_radicite")
	var closed := tq.use()
	st["arte_spada"] = ArtsData.points_for(3)
	m.vitals.linfa = m.vitals.linfa_max
	var foe: Creature = m.fauna.add("grumo_muschio", m.player.position + Vector2(30, -8))
	var hp0: int = foe.hp
	var linfa0: int = m.vitals.linfa
	var done := tq.use(m.player.position + Vector2(50, 0))
	var hurt: bool = not is_instance_valid(foe) or not m.fauna.list.has(foe) or foe.hp < hp0
	var spent: bool = m.vitals.linfa < linfa0
	var again := tq.use()
	if is_instance_valid(foe) and m.fauna.list.has(foe):
		m.fauna.kill(foe)
	st["arte_lancia"] = ArtsData.points_for(3)
	kit.hold("lancia_radicite")
	m.vitals.linfa = m.vitals.linfa_max
	var x0: float = m.player.position.x
	tq.use(m.player.position + Vector2(200, 0))
	await kit.seconds(0.6)
	var moved: bool = absf(m.player.position.x - x0) > 3.0 * 16.0
	var all_forms := true
	for f in ArtsData.FORMS:
		all_forms = all_forms and ArtsData.TECHS.has(f) and tq.has_method("_" + String(ArtsData.TECHS[f]["kind"]))
	var ok: bool = closed != "" and done == "" and hurt and spent and again != "" and moved and all_forms
	print("tecniche: senza maestria «%s»; fendente colpisce %s, Linfa spesa %s, attesa «%s»; carica scatta %s; tutte le forme %s" % [
		closed, hurt, spent, again, moved, all_forms])
	if not ok:
		print("ATTENZIONE: le tecniche non vanno")
	for f in saved:
		st["arte_" + String(f)] = saved[f]


## Voce 249: dopo il primo Guardiano tre taglie; la preda nasce, ancestrale e più forte; sconfitta dà il premio, entra
## nel registro e ne arriva un'altra.
func bounties() -> void:
	var bt: Bounties = m.bounties
	var st: Dictionary = m.character.stats
	var saved: Dictionary = m.character.taglie.duplicate(true)
	var g0 := int(st.get("guardiani", 0))
	st["guardiani"] = maxi(g0, 1)
	m.character.taglie = {}
	bt.fill()
	var n := bt.open_list().size()
	var b: Dictionary = bt.open_list()[0]
	var sh0: int = m.character.bisaccia.count("scheggia_vigore")
	var cr: Creature = bt.spawn(0)
	var born: bool = cr != null and cr.ancient != null and cr.hp_max > int(CreaturesData.get_data(String(b["cr"]))["hp"]) * 2
	if cr != null:
		m.fauna.kill(cr)
	var got: int = m.character.bisaccia.count("scheggia_vigore") - sh0
	var reg: Array = m.character.taglie.get("registro", [])
	var ok: bool = n == 3 and born and reg.size() == 1 and bt.open_list().size() == 3 and (got >= 4 or m.character.bisaccia.room_for("scheggia_vigore") < 4)
	print("taglie: %d aperte; «%s» in %s; nata %s (Vita %d); registro %d, schegge +%d, di nuovo %d aperte" % [n, bt.title(b),
		bt.where_text(b), born, cr.hp_max if cr != null else 0, reg.size(), got, bt.open_list().size()])
	if not ok:
		print("ATTENZIONE: le taglie non vanno")
	m.character.bisaccia.remove("scheggia_vigore", maxi(got, 0))
	m.character.taglie = saved
	st["guardiani"] = g0


## Voce 250: il primo clic destro spiega, il secondo comincia; le ondate crescono (un capo ogni cinque); vinte tutte, il
## premio e il record.
func trials() -> void:
	var tr: Trials = m.trials
	var st: Dictionary = m.character.stats
	var rec0 := int(st.get("prova_record", 0))
	var o: Vector2i = m.player_cell() + Vector2i(-1, 0)
	m.world.stations[o] = "arena"
	var first := tr.touch(o) and not tr.active
	tr.touch(o)
	var started: bool = tr.active and tr.wave == 1
	var sizes := []
	var boss_seen := false
	for k in Trials.WAVES:
		sizes.append(tr._list.size())
		for c in tr._list.duplicate():
			if is_instance_valid(c) and (c as Creature).ancient != null:
				boss_seen = true
			if is_instance_valid(c) and m.fauna.list.has(c):
				m.fauna.kill_quietly(c)
		tr._process(0.1)
	var sh0: int = m.character.bisaccia.count("scheggia_vigore")
	var won: bool = not tr.active and int(st.get("prova_record", 0)) == Trials.WAVES
	m.world.stations.erase(o)
	var ok: bool = first and started and won and boss_seen and int(sizes[Trials.WAVES - 1]) > int(sizes[0])
	print("prove del Cerchio: cominciata %s; ondate %s; capo %s; vinta %s (record %d)" % [started, str(sizes), boss_seen, won,
		int(st.get("prova_record", 0))])
	if not ok:
		print("ATTENZIONE: le prove del Cerchio non vanno")
	st["prova_record"] = rec0
	m.character.bisaccia.remove("scheggia_vigore", Trials.WAVES)
	m.character.bisaccia.remove("linfa_antica", 3)


## Voce 251: il pannello delle arti mostra la maestria, la tecnica, le taglie e le prove.
func panel() -> void:
	var p: ArtsPanel = m.arts.panel
	kit.hold("lancia_radicite")
	p.open()
	await kit.frames(3)
	await kit.save("254_arti")
	var t1: String = p.text_of("lancia")
	var t2: String = p.text_of("taglie")
	var t3: String = p.text_of("prove")
	p.close()
	var ok: bool = p.sel == "lancia" and "Carica" in t1 and "taglie" in t2.to_lower() and "record" in t3
	print("pannello delle arti: scelta %s; tecnica %s; taglie %s; prove %s" % [p.sel, "Carica" in t1, "taglie" in t2.to_lower(), "record" in t3])
	if not ok:
		print("ATTENZIONE: il pannello delle arti non va")
