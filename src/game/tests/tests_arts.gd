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
