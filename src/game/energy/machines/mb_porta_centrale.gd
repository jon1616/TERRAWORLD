class_name MbPortaCentrale
extends MbPorta
## La porta della sala interna di una Centrale dei Seminatori (voce 206): una Porta di radice viva che non si riprende.
## La comanda il filo viola del nodo E, acceso solo con le tre leve alzate; e si muove solo se la rete ha Linfa (il cuore
## sveglio e le vene riparate). La prima volta che si apre la Centrale si risveglia e dona ciò che custodiva: un
## progetto dei Seminatori, un unico della serie «Ingegni dei Seminatori» e Linfa antica.


func frame(mc: Machine, e: Energy, dt: float) -> void:
	super.frame(mc, e, dt)
	if bool(mc.st.get("open", false)) and not bool(mc.st.get("premio", false)):
		mc.st["premio"] = true
		_reward(mc, e)


func _reward(mc: Machine, e: Energy) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var at := mc.center() + Vector2(40, -8)             # nella sala dietro la porta
	var found: Dictionary = e.m.erbario.data.get("oggetti", {})
	var u := UniquesData.roll("centrali", rng, found)
	if u != "":
		e.m.drops.spawn(u, 1, at)
	var projects := ProjectsData.PROJECTS.keys()
	e.m.drops.spawn(ProjectsData.item_of(String(projects[rng.randi_range(0, projects.size() - 1)])), 1, at)
	e.m.drops.spawn("linfa_antica", 2, at)
	e.m.sfx.play("stella", at)
	e.m.hud.toast("La Centrale dei Seminatori si è risvegliata: ciò che custodiva è tuo")
	e.m.objectives.bump("centrali")
