class_name CharacterSheet
extends RefCounted
## La scheda del Germogliato (voce 29): quando la casella Esamina è vuota mostra tutto ciò che conta adesso: Vita,
## Linfa, Scorza, i moltiplicatori di equipaggiamento, set, reliquie e pozioni, i set completi, le collezioni di
## reliquie, i doni assorbiti. Con tanti effetti diversi il giocatore deve poter vedere in un colpo d'occhio cosa ha.


## Testo con i colori (BBCode) per la casella Esamina.
static func bbcode(m: Node2D) -> String:
	var v: Vitals = m.vitals
	var t := "[font_size=18][color=#ffd08a]%s[/color][/font_size]  [color=#6a8a84](posa un oggetto qui per esaminarlo)[/color]\n" % m.character.name
	t += "Vita [color=#8ef0c0]%d/%d[/color] · Linfa [color=#5cc8cc]%d/%d[/color] · Scorza [color=#ffb84a]%d[/color]\n" % [
		v.hp, v.hp_max, v.linfa, v.linfa_max, v.scorza + v.scorza_bonus + v.set_scorza]
	var rows := []
	_mult(rows, "Danno", m.combat.dmg_mult * (Boons.VIGORE if m.boons.active.has("vigore") else 1.0))
	_mult(rows, "Colpi", m.combat.spd_mult)
	_mult(rows, "Incantesimi", m.combat.magic_mult)
	_mult(rows, "Corsa", m.player.run_mult * m.player.boon_run)
	_mult(rows, "Salto", m.player.jump_mult)
	_mult(rows, "Scavo", m.actions.dig_mult * m.actions.boon_dig)
	_mult(rows, "Vita che ricresce", v.regen_mult * v.boon_regen)
	_mult(rows, "Linfa che ricresce", v.linfa_regen_mult)
	_mult(rows, "Alone", m.boons.halo_mult)
	if Behavior.stealth < 0.999:
		rows.append("Le creature ti vedono a [color=#cfeee4]%d%%[/color] della distanza" % roundi(Behavior.stealth * 100.0))
	var luck: float = m.fauna.luck + m.fauna.boon_luck
	if luck > 0.0:
		rows.append("Fortuna [color=#cfeee4]+%d%%[/color] di bottino in più" % roundi(luck * 50.0))
	var th: int = m.combat.thorns + m.combat.boon_thorns
	if th > 0:
		rows.append("Spine [color=#cfeee4]%d[/color] a chi ti tocca" % th)
	if m.player.glide:
		rows.append("Planata tenendo Spazio")
	if m.life.fall_safe:
		rows.append("Nessuna ferita da caduta")
	if m.fauna.rare_mult > 1.0:
		rows.append("Creature rare [color=#cfeee4]×%.0f[/color] (Esca)" % m.fauna.rare_mult)
	t += "[color=#9fc8c0]%s[/color]\n" % ("\n".join(rows) if not rows.is_empty() else "Nessun effetto dall'equipaggiamento")
	var extra := []
	for s in m.gear.sets:
		extra.append("[color=#ffd08a]Set %s[/color]" % SetsData.all()[s]["name"])
	for c in m.gear.relics:
		extra.append("[color=#ffd24a]Reliquie: %s[/color]" % RelicsData.COLLECTIONS[c]["name"])
	if not extra.is_empty():
		t += " · ".join(extra) + "\n"
	var st: Dictionary = m.character.stats
	var gifts := int(st.get("doni_cuore_bocciolo", 0))
	var drops := int(st.get("doni_stilla_perenne", 0))
	t += "[color=#6a8a84]Cuori di bocciolo %d/15 · Stille perenni %d/10 · Erbario %d%%[/color]" % [gifts, drops,
		roundi(m.erbario.percent())]
	return t


## Una riga «Danno ×1,15» solo se l'effetto c'è.
static func _mult(rows: Array, label: String, v: float) -> void:
	if absf(v - 1.0) > 0.001:
		rows.append("%s [color=#cfeee4]×%.2f[/color]" % [label, v])
