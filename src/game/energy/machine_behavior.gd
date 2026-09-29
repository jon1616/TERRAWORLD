class_name MachineBehavior
extends RefCounted
## Roadmap 19: il comportamento di una macchina della rete (uno per file in `machines/`, come i comportamenti delle
## creature). `Energy` chiama, per ogni conto del Flusso (ogni `Energy.TICK` secondi):
##   produce(mc, e)          le sorgenti: quanti pulsi danno adesso
##   demand(mc, e)           le macchine: quanti pulsi chiedono adesso (0 = ferme)
##   tick(mc, e, dt)         dopo il conto: `mc.power` dice quanto hanno avuto (0-1)
##   on_impulse(mc, e, c, v) l'Impulso sul filo del colore c: v = acceso (stato) o true per un colpo (voce 193)
##   state_text(mc, e)       una riga per le schede e il pannello
## Le riserve le tratta `Energy` stesso (hanno `cap` e `io` nei dati).


static func make(bh: String) -> MachineBehavior:
	match bh:
		"tamburo":
			return MbTamburo.new()
		"sole":
			return MbSole.new()
		"lampada":
			return MbLampada.new()
	return MachineBehavior.new()


func produce(_mc: Machine, _e: Energy) -> float:
	return 0.0


func demand(mc: Machine, _e: Energy) -> float:
	if mc.role() != "macchina" or not mc.on():
		return 0.0
	return float(mc.d.get("pulsi", 0))


func tick(_mc: Machine, _e: Energy, _dt: float) -> void:
	pass


func on_impulse(mc: Machine, _e: Energy, _color: int, value: bool) -> void:
	mc.st["on"] = value


func state_text(mc: Machine, e: Energy) -> String:
	match mc.role():
		"sorgente":
			return "dà %d pulsi" % roundi(mc.made)
		"riserva":
			return "%d / %d gocce" % [roundi(float(mc.st.get("g", 0.0))), int(mc.d.get("cap", 0))]
		"macchina":
			if not mc.on():
				return "spenta"
			if mc.net < 0:
				return "ferma: nessuna vena la tocca"
			if mc.power >= 0.99:
				return "lavora (%d pulsi)" % roundi(mc.given)
			return "ferma: la rete non basta (%s)" % e.why(mc)
	return ""
