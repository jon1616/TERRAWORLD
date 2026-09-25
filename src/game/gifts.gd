class_name Gifts
extends RefCounted
## I doni da trovare (voce 21): Cuori di bocciolo e Stille perenni. Un clic con il dono in mano lo assorbe e alza per
## sempre la Vita o la Linfa massima del personaggio, fino a un tetto per ogni dono (`gift_max` in `ItemsData`).
## Quanti ne ha assorbiti sta nei conteggi del personaggio (`Character.stats`, "doni_<id>"), che si salvano.


## Assorbe un dono dalla mano. True se l'ha fatto.
static func absorb(m: Node2D, id: String) -> bool:
	var it := ItemsData.get_item(id)
	var ch: Character = m.character
	var key := "doni_" + id
	var n := int(ch.stats.get(key, 0))
	if n >= int(it["gift_max"]):
		m.hud.toast("Ne hai già assorbiti %d: il tuo corpo non ne accoglie altri" % n)
		return false
	if not ch.bisaccia.remove(id, 1):
		return false
	ch.stats[key] = n + 1
	var g: Array = it["gift"]
	var amount := int(g[1])
	match String(g[0]):
		"vita":
			ch.vita_extra += amount
			m.vitals.hp_max += amount
			m.vitals.heal(amount)
			m.hud.toast("Una foglia nuova! Vita massima %d (%d su %d)" % [m.vitals.hp_max, n + 1, int(it["gift_max"])])
		"linfa":
			ch.linfa_extra += amount
			m.vitals.linfa_max += amount
			m.vitals.linfa += amount
			m.vitals.changed.emit()
			m.hud.toast("La Linfa si allarga: Linfa massima %d (%d su %d)" % [m.vitals.linfa_max, n + 1, int(it["gift_max"])])
	m.sfx.play("dono")
	Fx.puff(m.fx, m.player.position, Color(2.0, 1.2, 1.3) if String(g[0]) == "vita" else Color(1.0, 1.9, 1.9))
	m.objectives.bump("doni")
	return true
