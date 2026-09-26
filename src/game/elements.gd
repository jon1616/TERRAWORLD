class_name Elements
extends RefCounted
## Gli elementi in battaglia (voce 51, dati in `ElementsData`): un colpo con un elemento su una creatura. Debolezza o
## resistenza cambiano il danno (e l'Erbario se le ricorda); poi, se la creatura porta il segno di un altro elemento,
## scatta la **reazione**; altrimenti restano lo stato e il segno del nuovo. Chiamato da `Combat._strike`.


## Il danno del colpo dopo l'elemento (e i suoi effetti sulla creatura, sul Germogliato e attorno).
static func hit(combat: Combat, c: Creature, elem: String, dmg: int) -> int:
	if not ElementsData.ELEMENTS.has(elem):
		return dmg
	var m: Node2D = combat.m
	var aff := ElementsData.affinity(c.id, elem)
	if aff != 1.0:
		_remember(m, c.id, elem, 1 if aff > 1.0 else -1)
	var out := float(dmg) * aff
	var r := ElementsData.reaction(c.elem, elem) if c.elem != "" and c.elem != elem and c.elem_t > 0.0 else {}
	if not r.is_empty():
		c.elem = ""
		c.elem_t = 0.0
		out *= float(r.get("mult", 1.0))
		var st := float(r.get("stun", 0.0))
		if st > 0.0:
			c.stun = maxf(c.stun, st / 3.0 if c.boss else st)
		c.chill_t = maxf(c.chill_t, float(r.get("chill", 0.0)))
		Fx.float_text(c.get_parent(), c.position + Vector2(0, -c.half.y - 18), String(r["name"]) + "!", Color(String(r["color"])))
		m.objectives.bump("reazioni")
		if float(r.get("area", 0.0)) > 0.0:
			Fx.puff(m.fx, c.position, Color(2.2, 1.3, 0.5))
			for o in m.fauna.list.duplicate():
				if o != c and o.position.distance_to(c.position) < float(r["radius"]):
					if o.take_hit(maxi(int(out * float(r["area"])), 1), c.position.x, 0.6):
						m.fauna.kill(o)
		return maxi(roundi(out), 1)
	# lo stato dell'elemento, e il segno che aspetta una reazione
	var ed: Dictionary = ElementsData.ELEMENTS[elem]
	match String(ed["status"]):
		"brucia":
			c.burn_t = float(ed["time"])
			c.burn_dps = maxf(out * float(ed["dps"]), 1.0)
		"rallenta":
			c.chill_t = maxf(c.chill_t, float(ed["time"]))
		"avvelena":
			c.poison_t = maxf(c.poison_t, float(ed["time"]))
		"prosciuga":
			m.vitals.heal(maxi(roundi(out * float(ed["heal"])), 1))
		"vulnerabile":
			c.weak_t = float(ed["time"])
		"acceca":
			if not c.boss:
				c.stun = maxf(c.stun, float(ed["time"]))
	c.elem = elem
	c.elem_t = ElementsData.MARK_TIME
	return maxi(roundi(out), 1)


## L'Erbario ricorda debolezze (1) e resistenze (-1) scoperte: `erbario["elementi"][creatura][elemento]`.
static func _remember(m: Node2D, cid: String, elem: String, v: int) -> void:
	var eb: Dictionary = m.character.erbario
	if not eb.has("elementi"):
		eb["elementi"] = {}
	var known: Dictionary = eb["elementi"].get(cid, {})
	if known.has(elem):
		return
	known[elem] = v
	eb["elementi"][cid] = known
	var name := String(CreaturesData.CREATURES[cid]["name"]) if CreaturesData.CREATURES.has(cid) else cid
	m.hud.toast("%s: %s alla %s (Erbario)" % [name, "debole" if v > 0 else "resiste", String(ElementsData.ELEMENTS[elem]["name"]).to_lower()])
