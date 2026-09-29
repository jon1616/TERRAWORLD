class_name MbValvola
extends MachineBehavior
## La Valvola di sfogo (voce 207): non chiede pulsi; la sua presenza su una rete la protegge dalla Tempesta di Linfa
## (`EnergyStorm.tick` la cerca fra le macchine della rete).


func state_text(mc: Machine, e: Energy) -> String:
	if mc.net < 0:
		return "ferma: nessuna vena la tocca"
	return "protegge la rete dalla Tempesta di Linfa" + (" (adesso sfoga)" if EnergyStorm.storm(e) else "")
