class_name Backpack
extends Node
## Lo zaino (Roadmap 30; dati in `BackpackData`). Voce 295: le Bisacce a gradi. Usarne una allarga la Bisaccia del
## Germogliato a tante caselle quante ne ha (per sempre, il contenuto resta); una più piccola della Bisaccia di adesso non
## si consuma. Il conteggio «bisaccia_caselle» dice fin dove si è arrivati.

var m: Node2D


func setup(main: Node2D) -> void:
	m = main


func use_bag(id: String) -> bool:
	var bd := BackpackData.bag_of(id)
	if bd.is_empty():
		return false
	var b: Bisaccia = m.character.bisaccia
	var n := int(bd["slots"])
	if n <= b.slots.size():
		m.hud.toast("La tua Bisaccia ha già %d caselle: questa ne ha %d" % [b.slots.size(), n])
		return false
	if not b.remove(id, 1):
		return false
	b.grow(n)
	m.character.stats["bisaccia_caselle"] = n
	m.hud.toast("%s: ora la Bisaccia ha %d caselle (le pagine in alto, accanto al titolo)" % [bd["name"], n])
	m.sfx.play("dono")
	return true
