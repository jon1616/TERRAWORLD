class_name FiloRete
extends RefCounted
## Roadmap 19, voce 209: il primo circuito guidato. Il secondo stadio dell'Albero-Madre dona il corredo della rete
## (Pinza, vene, Tamburo, Otre, Lampade, Leva, filo turchese: `MotherTreeData`, dono `items`); da lì il **filo** (`Filo`,
## fonte «rete») porta passo passo al primo circuito: il Tamburo, la vena sotto, l'Otre, la Lampada, la Leva col filo.
## Finito (una Lampada accesa che un filo comanda) il personaggio lo ricorda (`stats.primo_circuito`) e il filo tace.

const STEPS := [
	["tamburo_radice", "Posa il Tamburo di radice", "è la prima sorgente: con il clic destro lo batti e dà Linfa"],
	["vena", "Posa una vena sotto il Tamburo con la Pinza delle vene", "clic e trascina per una linea; la vena passa anche nella roccia"],
	["otre_linfa", "Posa l'Otre di Linfa sulla stessa vena", "l'Otre tiene la Linfa che il Tamburo dà in più"],
	["lampada_baccello", "Posa una Lampada a baccello sulla vena", "le macchine sulla vena prendono i pulsi dalla rete"],
	["leva_radice", "Posa la Leva e tira un filo turchese fino alla Lampada", "con la Pinza, Maiusc+rotella sceglie il filo; la Leva accende e spegne la Lampada"],
]


## Il passo di adesso, o {} se il circuito è fatto (o se non si ha ancora la Pinza).
static func from(m: Node2D) -> Dictionary:
	if m.get("energy") == null or int(m.character.stats.get("primo_circuito", 0)) > 0:
		return {}
	var e: Energy = m.energy
	if _done(e):
		m.objectives.bump("primo_circuito")
		return {}
	if m.character.bisaccia.count("pinza_vene") <= 0 and e.machines.is_empty():
		return {}
	var drum := _first(e, "tamburo_radice")
	var st := {}
	if drum == null:
		st = _step(0)
	elif drum.net < 0:
		st = _step(1)
		st["cell"] = drum.o + Vector2i(0, drum.size().y - 1)
	elif _on_net(e, drum.net, "otre_linfa") == null:
		st = _step(2)
		st["cell"] = drum.o
	elif _on_net(e, drum.net, "lampada_baccello") == null:
		st = _step(3)
		st["cell"] = drum.o
	else:
		st = _step(4)
		st["cell"] = (_on_net(e, drum.net, "lampada_baccello") as Machine).o
	return st


static func _step(i: int) -> Dictionary:
	return {"text": String(STEPS[i][1]), "hint": String(STEPS[i][2])}


static func _first(e: Energy, id: String) -> Machine:
	for mc: Machine in e.machines.values():
		if mc.id == id:
			return mc
	return null


static func _on_net(e: Energy, ni: int, id: String) -> Machine:
	for mc: Machine in e.machines.values():
		if mc.id == id and mc.net == ni:
			return mc
	return null


## Fatto: una Lampada accesa che un filo tocca.
static func _done(e: Energy) -> bool:
	for mc: Machine in e.machines.values():
		if mc.id == "lampada_baccello" and mc.lit and not mc.wired.is_empty():
			return true
	return false
