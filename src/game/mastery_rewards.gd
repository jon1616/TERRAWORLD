class_name MasteryRewards
extends RefCounted
## I premi dei gradi della maestria (Roadmap 20, voce 215; dati in `MasteryData.REWARDS`). Un grado dà oggetti (nella
## Bisaccia, o a terra se non c'è posto) e un bonus per sempre che `GearEffects` somma (`bonus`).


## Dà il premio del grado g di un pilastro; restituisce il testo per l'avviso («" · Lanterna di vena ×1"»).
static func give(m: Node2D, pillar: String, g: int) -> String:
	var r: Dictionary = MasteryData.reward(pillar, g)
	var parts := []
	for id in r.get("items", {}):
		var n := int(r["items"][id])
		var rest: int = m.character.bisaccia.add(String(id), n)
		if rest > 0:
			m.drops.spawn(String(id), rest, m.player.position)
		parts.append("%s ×%d" % [String(ItemsData.get_item(String(id)).get("name", id)), n])
	if r.has("bonus"):
		parts.append(String(r.get("text", "")))
		if m.get("gear") != null:
			m.gear.refresh()
	return ", ".join(parts.filter(func(x: String) -> bool: return x != ""))


## I bonus per sempre di tutti i gradi raggiunti (li somma `GearEffects`).
static func bonuses(maestria: Dictionary) -> Array:
	var out := []
	for p in MasteryData.ORDER:
		var pts := float((maestria.get(p, {}) as Dictionary).get("p", 0.0))
		var g := MasteryData.grade_of(p, pts)
		for k in range(1, g + 1):
			var r: Dictionary = MasteryData.reward(p, k)
			if r.has("bonus"):
				out.append(r["bonus"])
	return out
