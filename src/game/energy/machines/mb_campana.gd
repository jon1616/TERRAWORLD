class_name MbCampana
extends MachineBehavior
## La Campana d'allarme: a ogni impulso che si accende (o un colpo, o il clic destro) suona: gli abitanti del mondo
## corrono a casa per `SHELTER` secondi (`Npc.shelter_t`). Ogni suono costa `colpo` gocce (senza Linfa suona lo stesso:
## è una campana, ma allora non la sente nessuno lontano: solo l'avviso).

const SHELTER := 30.0


func ring(mc: Machine, e: Energy) -> void:
	var loud := e.spend(mc, float(mc.d.get("colpo", 0)))
	e.m.sfx.play("guardiano", mc.center())
	mc.set_meta("flash", 1.0)
	mc.st["suoni"] = int(mc.st.get("suoni", 0)) + 1
	e.m.hud.toast("La campana d'allarme suona!" + (" Gli abitanti corrono a casa." if loud else ""))
	if loud:
		for n in e.m.villagers.list:
			if is_instance_valid(n):
				n.shelter_t = SHELTER


func on_impulse(mc: Machine, e: Energy, _k: int, kind: String) -> void:
	if kind == "su" or kind == "colpo":
		ring(mc, e)


func touch(mc: Machine, e: Energy) -> bool:
	ring(mc, e)
	return true


func state_text(mc: Machine, _e: Energy) -> String:
	return "pronta · ha suonato %d volte" % int(mc.st.get("suoni", 0))
