class_name WeaponArts
extends Node
## La maestria delle armi (Roadmap 25, voce 247; dati in `ArtsData`). Una creatura sconfitta vicino al Germogliato con
## un'arma in mano dà punti alla forma di quell'arma (`Character.stats["arte_<forma>"]`); salire di rango dà danno in più
## con quella forma (`mult_now`, letto da `Combat._boon`) e apre le tecniche (voce 248).

var m: Node2D
var panel: ArtsPanel                   # voce 251: il pannello delle arti


## Roadmap 47, voce 402: la sala d'armi fa crescere le arti più in fretta (la scrive `Rooms`).
static var room_mult := 1.0

func setup(main: Node2D) -> void:
	m = main
	m.fauna.killed.connect(_on_kill)
	panel = ArtsPanel.new()
	m.hud.add_child(panel)
	panel.setup(m)
	m.hud.overlays.append(panel)


## La forma d'arma di un oggetto ("" se non è un'arma con maestria).
static func form_of(id: String) -> String:
	var it := ItemsData.get_item(id)
	var f := String(it.get("form", ""))
	if f == "":
		f = {"spada": "spada", "arco": "arco", "bastone": "verga"}.get(String(it.get("kind", "")), "")
	return f if ArtsData.FORMS.has(f) else ""


func held_form() -> String:
	return form_of(String(m.hud.current().get("id", "")))


func points(form: String) -> int:
	return int(m.character.stats.get("arte_" + form, 0))


func rank(form: String) -> int:
	return ArtsData.rank_of(points(form))


## Il danno in più con l'arma che si ha in mano.
func mult_now() -> float:
	var f := held_form()
	return 1.0 + ArtsData.DMG_PER_RANK * rank(f) if f != "" else 1.0


func _on_kill(c: Creature) -> void:
	if c.tame != null or c.docile:
		return
	var f := held_form()
	if f == "" or c.position.distance_to(m.player.position) > ArtsData.KILL_RANGE * 16.0:
		return
	add(f, maxi(1, roundi(float(c.hp_max) / ArtsData.HP_PER_PT)))


func add(form: String, pts: int) -> void:
	pts = maxi(1, roundi(pts * room_mult))         # voce 402: la sala d'armi
	var r0 := rank(form)
	m.character.stats["arte_" + form] = points(form) + pts
	var r1 := rank(form)
	for r in range(r0 + 1, r1 + 1):
		m.objectives.bump("ranghi_arma")
		var msg := "Maestria %s: rango %d (+%d%% di danno)" % [ArtsData.FORMS[form], r, roundi(ArtsData.DMG_PER_RANK * 100.0 * r)]
		if r in ArtsData.TECH_RANKS:
			var g := ArtsData.tech_grade(r)
			msg += " · tecnica «%s» %s" % [ArtsData.TECHS[form]["name"], "aperta" if g == 1 else "di grado %d" % g]
		m.hud.toast(msg)
		m.sfx.play("dono")
		if m.get("diary") != null:
			m.diary.note(msg, "arti")
