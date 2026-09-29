class_name MachineBehavior
extends RefCounted
## Roadmap 19: il comportamento di una macchina della rete (uno per file in `machines/`, come i comportamenti delle
## creature). `Energy` chiama, per ogni conto del Flusso (ogni `Energy.TICK` secondi):
##   produce(mc, e)             le sorgenti: quanti pulsi danno adesso
##   demand(mc, e)              le macchine: quanti pulsi chiedono adesso (0 = ferme)
##   tick(mc, e, dt)            dopo il conto: `mc.power` dice quanto hanno avuto (0-1)
## e inoltre:
##   frame(mc, e, dt)           a ogni fotogramma, solo per chi ha `frame: true` nei dati (porte, piastre)
##   on_impulse(mc, e, k, tipo) l'Impulso sul filo del colore k: "su", "giu" o "colpo" (voce 193)
##   touch(mc, e)               clic destro sulla macchina (vero se ha fatto qualcosa; se no si apre il pannello)
##   removed(mc, e)             la macchina è stata tolta dal mondo
##   state_text(mc, e)          una riga per le schede e il pannello
## Le riserve le tratta `Energy` stesso (hanno `cap` e `io` nei dati).


static func make(bh: String) -> MachineBehavior:
	match bh:
		"tamburo":
			return MbTamburo.new()
		"sole":
			return MbSole.new()
		"lampada":
			return MbLampada.new()
		"leva":
			return MbLeva.new()
		"pulsante":
			return MbPulsante.new()
		"piastra":
			return MbPiastra.new()
		"porta":
			return MbPorta.new()
		"mulino":
			return MbMulino.new()
		"ruota":
			return MbRuota.new()
		"fuoco":
			return MbFuoco.new()
		"pozzo":
			return MbPozzo.new()
		"mandria":
			return MbRuotaMandria.new()
		"ascensore":
			return MbAscensore.new()
		"nastro":
			return MbNastro.new()
		"catapulta":
			return MbCatapulta.new()
		"porta_seme":
			return MbPortaSeme.new()
		"parafulmine":
			return MbParafulmine.new()
		"radice_madre":
			return MbRadiceMadre.new()
		"radice_giardino":
			return MbRadiceGiardino.new()
	return MachineBehavior.new()


func produce(_mc: Machine, _e: Energy) -> float:
	return 0.0


func demand(mc: Machine, _e: Energy) -> float:
	if mc.role() != "macchina" or not mc.on():
		return 0.0
	return float(mc.d.get("pulsi", 0))


func tick(_mc: Machine, _e: Energy, _dt: float) -> void:
	pass


func frame(_mc: Machine, _e: Energy, _dt: float) -> void:
	pass


## La reazione all'Impulso: «segue» (acceso finché il filo è acceso; un colpo alterna) o «alterna».
func on_impulse(mc: Machine, _e: Energy, _k: int, kind: String) -> void:
	var mode := String(mc.st.get("reazione", "segue"))
	match kind:
		"su":
			mc.st["on"] = true if mode == "segue" else not mc.on()
		"giu":
			if mode == "segue":
				mc.st["on"] = false
		"colpo":
			mc.st["on"] = not mc.on()


func touch(_mc: Machine, _e: Energy) -> bool:
	return false


## Righe in più del pannello: [[titolo, [[testo, premuto, azione], …]], …] (le impostazioni della macchina).
func panel_rows(_mc: Machine, _e: Energy) -> Array:
	return []


func removed(_mc: Machine, _e: Energy) -> void:
	pass


func state_text(mc: Machine, e: Energy) -> String:
	match mc.role():
		"sorgente":
			return "dà %d pulsi" % roundi(mc.made)
		"riserva":
			return "%d / %d gocce" % [roundi(float(mc.st.get("g", 0.0))), int(mc.d.get("cap", 0))]
		"comando":
			return "acceso" if bool(mc.st.get("out", false)) else "spento"
		"macchina":
			if not mc.on():
				return "spenta"
			if float(mc.d.get("pulsi", 0)) <= 0.0:
				return "pronta"
			if mc.net < 0:
				return "ferma: nessuna vena la tocca"
			if mc.power >= 0.99:
				return "lavora (%s)" % Energy.pulsi(mc.given)
			return "ferma: %s" % e.why(mc)
	return ""
