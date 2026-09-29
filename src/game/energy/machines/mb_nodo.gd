class_name MbNodo
extends MachineBehavior
## I nodi della logica (voce 205). Un nodo tocca fili di più colori: uno è la sua **uscita** (`st.uscita`, nel pannello;
## all'inizio il colore più alto fra quelli che lo toccano), gli altri sono gli **ingressi**. L'uscita cambia sempre un
## passo dopo (`Impulse.STEP`), così un circuito chiuso su se stesso oscilla invece di bloccare il gioco.
## Il tipo è `p.kind` nei dati:
##   e          acceso se tutti gli ingressi sono accesi
##   o          acceso se almeno uno è acceso (e ripete i colpi)
##   non        acceso se nessun ingresso è acceso
##   ritardo    ripete ciò che arriva dopo `st.attesa` secondi
##   contatore  conta accensioni e colpi; al numero `st.n` dà un colpo e riparte da zero
##   memoria    con un ingresso ogni accensione alterna l'uscita; con due il colore più basso accende, l'altro spegne

const WAITS := [0.25, 0.5, 1.0, 2.0, 5.0]
const COUNTS := [2, 3, 5, 10, 20]


func _kind(mc: Machine) -> String:
	return String((mc.d.get("p", {}) as Dictionary).get("kind", ""))


## Il colore dell'uscita (-1 se il nodo non tocca fili).
static func out_of(mc: Machine) -> int:
	if mc.wired.is_empty():
		return -1
	var u := int(mc.st.get("uscita", -1))
	if mc.wired.has(u):
		return u
	var best := -1
	for k in mc.wired:
		best = maxi(best, int(k))
	return best


## Cambia il colore dell'uscita: i fili che il nodo guidava e quelli che guida adesso si rimettono in pari.
static func set_output(mc: Machine, e: Energy, k: int) -> void:
	mc.st["uscita"] = k
	e.impulse.refresh(mc)


## I colori degli ingressi, in ordine.
static func inputs(mc: Machine) -> Array[int]:
	var u := out_of(mc)
	var list: Array[int] = []
	for k in 4:
		if mc.wired.has(k) and k != u:
			list.append(k)
	return list


func _in_states(mc: Machine, e: Energy) -> Array[bool]:
	var s: Array[bool] = []
	for k in inputs(mc):
		s.append(bool(e.impulse.wnets[k][mc.wired[k]]["state"]))
	return s


## Il valore delle porte (e, o, non) dagli ingressi di adesso.
func _gate(mc: Machine, e: Energy) -> bool:
	var s := _in_states(mc, e)
	match _kind(mc):
		"e":
			if s.is_empty():
				return false
			for v in s:
				if not v:
					return false
			return true
		"o":
			return true in s
		"non":
			return not (true in s)
	return bool(mc.st.get("out", false))


## Le porte si rimettono in pari a ogni conto (dopo che i fili sono cambiati, o a un caricamento).
func tick(mc: Machine, e: Energy, _dt: float) -> void:
	if _kind(mc) in ["e", "o", "non"]:
		var v := _gate(mc, e)
		if v != bool(mc.st.get("out", false)):
			e.impulse.set_out(mc, v, Impulse.STEP)


func on_impulse(mc: Machine, e: Energy, k: int, kind: String) -> void:
	if k == out_of(mc):
		return                                       # ciò che esce non rientra
	match _kind(mc):
		"e", "non":
			e.impulse.set_out(mc, _gate(mc, e), Impulse.STEP)
		"o":
			if kind == "colpo":
				e.impulse.pulse(mc, Impulse.STEP)
			else:
				e.impulse.set_out(mc, _gate(mc, e), Impulse.STEP)
		"ritardo":
			var wait := float(mc.st.get("attesa", 1.0))
			if kind == "colpo":
				e.impulse.pulse(mc, wait)
			else:
				e.impulse.set_out(mc, kind == "su", wait)
		"contatore":
			if kind == "giu":
				return
			var n := int(mc.st.get("conto", 0)) + 1
			if n >= int(mc.st.get("n", 10)):
				n = 0
				e.impulse.pulse(mc, Impulse.STEP)
				mc.set_meta("flash", 0.3)
			mc.st["conto"] = n
		"memoria":
			var ins := inputs(mc)
			if ins.size() >= 2:
				if kind == "giu":
					return
				e.impulse.set_out(mc, k == ins[0], Impulse.STEP)
			elif kind != "giu":
				e.impulse.set_out(mc, not bool(mc.st.get("out", false)), Impulse.STEP)
	e.refresh_look(mc)


func panel_rows(mc: Machine, _e: Energy) -> Array:
	var rows := []
	if not mc.wired.is_empty():
		var row := []
		var u := out_of(mc)
		for k in 4:
			if not mc.wired.has(k):
				continue
			var kk := k
			row.append([String(VeinsData.WIRES[k]["name"]), u == k, func() -> void: set_output(mc, _e, kk)])
		rows.append(["Uscita", row])
	match _kind(mc):
		"ritardo":
			var row2 := []
			for w in WAITS:
				var wv := float(w)
				row2.append(["%s s" % str(wv).replace(".", ","), is_equal_approx(float(mc.st.get("attesa", 1.0)), wv),
					func() -> void: mc.st["attesa"] = wv])
			rows.append(["Attesa", row2])
		"contatore":
			var row3 := []
			for n in COUNTS:
				var nv := int(n)
				row3.append([str(nv), int(mc.st.get("n", 10)) == nv, func() -> void:
					mc.st["n"] = nv
					mc.st["conto"] = 0])
			rows.append(["Un colpo ogni", row3])
	return rows


func state_text(mc: Machine, _e: Energy) -> String:
	if mc.wired.size() < 2:
		return "da collegare: almeno un filo d'ingresso e uno d'uscita, di colori diversi"
	var t := "acceso" if bool(mc.st.get("out", false)) else "spento"
	var u := out_of(mc)
	t += ", esce sul filo %s" % String(VeinsData.WIRES[u]["name"]).to_lower()
	if _kind(mc) == "contatore":
		t += " (conto %d di %d)" % [int(mc.st.get("conto", 0)), int(mc.st.get("n", 10))]
	return t
