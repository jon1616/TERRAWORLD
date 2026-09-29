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
