class_name HudTips
extends RefCounted
## Le schede delle parti dell'interfaccia di gioco (26 set 2026): Vita e Linfa (ricrescita, Scorza, doni, pozioni),
## l'orologio (ora, notte, stagione), gli obiettivi (premi e quanto manca), la riga dell'Albero-Madre (offerte e dove
## cercarle), gli effetti delle pozioni (tempo che resta), la minimappa. `attach` li collega una volta, a gioco pronto;
## i controlli diventano «di passaggio» (MOUSE_FILTER_PASS): ricevono il mouse per il suggerimento ma i clic
## arrivano lo stesso al mondo.


static func attach(m: Node2D) -> void:
	for ch in m.hud.get_children():
		if ch is VitalsView:
			_on(ch, func() -> Variant: return vitals(m))
	_on(m.day._label, func() -> Variant: return clock(m))
	_on(m.objectives._label, func() -> Variant: return objectives(m))
	_on(m.albero._label, func() -> Variant: return StationTip.mother_tree(m) if m.albero.has_garden() else null)
	_on(m.boons._label, func() -> Variant: return boons(m))
	if m.minimap != null:
		_on(m.minimap, func() -> Variant: return TipCard.simple("Minimappa: ciò che hai già visto attorno a te.\nN la nasconde, M apre la mappa grande."))


static func _on(c: Control, f: Callable) -> void:
	if c == null:
		return
	if c.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		c.mouse_filter = Control.MOUSE_FILTER_PASS
	Tips.attach(c, f)


static func vitals(m: Node2D) -> TipCard:
	var v: Vitals = m.vitals
	var c := TipCard.new()
	c.title("Il Germogliato", Color("#8ef0c0"))
	c.bar("Vita %d / %d" % [v.hp, v.hp_max], float(v.hp) / maxf(v.hp_max, 1), Color("#3aa08a"))
	c.bar("Linfa %d / %d" % [v.linfa, v.linfa_max], float(v.linfa) / maxf(v.linfa_max, 1), Color("#5cc8cc"))
	var sc: int = m.character.bisaccia.scorza() + v.set_scorza + v.scorza_bonus
	var rows := [["Scorza", "%d (toglie %d a ogni ferita)" % [sc, sc / 2]],
		["Ricrescita della Vita", "%s al secondo dopo %d s senza ferite" % [ItemTip.num(Vitals.REGEN * v.regen_mult * v.boon_regen, 1),
			roundi(Vitals.REGEN_DELAY)]],
		["Ricrescita della Linfa", "%s al secondo" % ItemTip.num(Vitals.LINFA_REGEN * v.linfa_regen_mult * v.pet_linfa, 1)]]
	c.stats(rows)
	if v.hp_max > Vitals.HP_MAX or v.linfa_max > Vitals.LINFA_MAX:
		c.line("Doni assorbiti: +%d Vita, +%d Linfa per sempre" % [v.hp_max - Vitals.HP_MAX, v.linfa_max - Vitals.LINFA_MAX], TipCard.GOOD)
	if v.potion_wait > 0.0:
		c.line("Prossima pozione tra %d s" % ceili(v.potion_wait), TipCard.SOFT)
	if v.poison_t > 0.0:
		c.line("Avvelenato: perdi Vita per %d s" % ceili(v.poison_t), TipCard.BAD)
	return c


static func clock(m: Node2D) -> TipCard:
	var d: DayCycle = m.day
	var c := TipCard.new()
	c.title("Giorno %d" % d.day, Color("#ffd08a"))
	var minutes := int(d.time * 24.0 * 60.0)
	c.sub("ore %02d:%02d · %s" % [minutes / 60, minutes % 60, "notte" if d.is_night() else "giorno"])
	c.line("Un giorno dura 20 minuti. Di notte escono creature più forti.", TipCard.SOFT)
	if m.seasons != null and m.seasons.current >= 0:
		var sd: Dictionary = m.seasons.info()
		c.sep()
		c.pair("Stagione del %s" % sd["name"], String(sd["desc"]), Color(sd["color"]))
		if m.seasons.fixed > 0:
			c.line("Eterna: un gene di questo mondo la tiene ferma", Color("#6ff0d0"))
		else:
			var next := SeasonsData.index(d.day, m.world.world_seed)
			var left := 0
			while SeasonsData.index(d.day + left, m.world.world_seed) == next and left < SeasonsData.DAYS + 1:
				left += 1
			var ns: Dictionary = SeasonsData.SEASONS[(next + 1) % SeasonsData.SEASONS.size()]
			c.line("Tra %d giorn%s arriva il %s" % [left, "o" if left == 1 else "i", ns["name"]], TipCard.SOFT)
	return c


static func objectives(m: Node2D) -> TipCard:
	var ob: Objectives = m.objectives
	var c := TipCard.new()
	c.title("Obiettivi", Color("#ffd08a"))
	c.sub("%d raggiunti su %d" % [m.character.obiettivi.size(), ObjectivesData.LIST.size()])
	var shown := 0
	for o in ObjectivesData.LIST:
		if ob.done(String(o["id"])):
			continue
		c.sep()
		c.line(String(o["text"]), TipCard.TEXT)
		var chk: Dictionary = o.get("check", {})
		if chk.has("stat"):
			var have := int(m.character.stats.get(String(chk["stat"]), 0))
			c.bar("%d / %d" % [mini(have, int(chk["n"])), int(chk["n"])], float(have) / maxf(float(chk["n"]), 1.0), Color("#ffd08a"))
		var rw := []
		for k in o.get("reward", {}):
			rw.append("%d %s" % [int(o["reward"][k]), ItemsData.get_item(String(k)).get("name", k)])
		if not rw.is_empty():
			c.pair("Premio", ", ".join(rw), Color("#ffd24a"))
		shown += 1
		if shown >= ObjectivesData.SHOWN:
			break
	return c


static func boons(m: Node2D) -> TipCard:
	var b: Boons = m.boons
	if b.active.is_empty():
		return null
	var c := TipCard.new()
	c.title("Effetti attivi", Color("#b8f080"))
	var rows := []
	for k in b.active:
		var secs := float(b.active[k])
		rows.append([String(Boons.NAMES.get(k, String(k).capitalize())), "%d:%02d" % [int(secs) / 60, int(secs) % 60]])
	c.stats(rows)
	return c
