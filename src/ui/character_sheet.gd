class_name CharacterSheet
extends RefCounted
## La scheda del Germogliato (voce 29): mostra tutto ciò che conta adesso: Vita, Linfa, Scorza, i moltiplicatori di
## equipaggiamento, set, reliquie e pozioni, i set completi, le collezioni di reliquie, i doni assorbiti. Con tanti
## effetti diversi il giocatore deve poter vedere in un colpo d'occhio cosa ha.
## Roadmap 55 «Il volto chiaro»: le parti (`parts`) le impagina `CharacterCard` (etichette, valori in colonna); il testo
## con i colori (`bbcode`) resta per chi lo vuole in una riga.


## Le parti della scheda: name, vitals [[nome, valore, colore]], effects [[nome, valore]] o [testo], extra [bbcode],
## tail [[nome, valore]].
static func parts(m: Node2D) -> Dictionary:
	var v: Vitals = m.vitals
	var sc: int = v.scorza + v.scorza_bonus + v.set_scorza
	var out := {"name": m.character.name, "vitals": [["Vita", "%d/%d" % [v.hp, v.hp_max], UiPalette.BUONO],
		["Linfa", "%d/%d" % [v.linfa, v.linfa_max], UiPalette.LINFA], ["Scorza", "%d · −%d%% ferite" % [sc, roundi(Vitals.scorza_share(sc) * 100.0)],
		UiPalette.AMBRA]]}
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
		rows.append(["Ti vedono a", "%d%% della distanza" % roundi(Behavior.stealth * 100.0)])
	var luck: float = m.fauna.luck + m.fauna.boon_luck
	if luck > 0.0:
		rows.append(["Fortuna", "+%d%% di bottino" % roundi(luck * 50.0)])
	var th: int = m.combat.thorns + m.combat.boon_thorns
	if th > 0:
		rows.append(["Spine", "%d a chi ti tocca" % th])
	if m.player.glide:
		rows.append(["Planata tenendo Spazio"])
	if m.life.fall_safe:
		rows.append(["Nessuna ferita da caduta"])
	if m.fauna.rare_mult > 1.0:
		rows.append(["Creature rare", "×%.0f (Esca)" % m.fauna.rare_mult])
	out["effects"] = rows
	var extra := []
	for s in m.gear.sets:
		extra.append("[color=#ffd08a]Set %s[/color]" % SetsData.all()[s]["name"])
	if m.world_traits != null and m.world_traits.sheet_line() != "":
		extra.append(m.world_traits.sheet_line())
	if m.signature != null and m.signature.sheet_line() != "":
		extra.append("[color=#ffd24a]%s[/color]" % m.signature.sheet_line())
	for c in m.gear.relics:
		extra.append("[color=#ffd24a]Reliquie: %s[/color]" % RelicsData.COLLECTIONS[c]["name"])
	out["extra"] = extra
	var st: Dictionary = m.character.stats
	out["tail"] = [["Cuori di bocciolo", "%d/15" % int(st.get("doni_cuore_bocciolo", 0))],
		["Stille perenni", "%d/10" % int(st.get("doni_stilla_perenne", 0))], ["Erbario", "%d%%" % roundi(m.erbario.percent())],
		["Lumini", str(m.character.bisaccia.count("lumino"))]]
	return out


## Testo con i colori (BBCode), tutto in poche righe.
static func bbcode(m: Node2D) -> String:
	var p := parts(m)
	var t := "[font_size=18][color=#ffd08a]%s[/color][/font_size]\n" % p["name"]
	var vit := []
	for r in p["vitals"]:
		vit.append("%s [color=#%s]%s[/color]" % [r[0], (r[2] as Color).to_html(false), r[1]])
	t += " · ".join(vit) + "\n"
	var rows := []
	for r in p["effects"]:
		rows.append(String(r[0]) if (r as Array).size() == 1 else "%s [color=#cfeee4]%s[/color]" % [r[0], r[1]])
	t += "[color=#9fc8c0]%s[/color]\n" % ("\n".join(rows) if not rows.is_empty() else "Nessun effetto dall'equipaggiamento")
	if not (p["extra"] as Array).is_empty():
		t += " · ".join(p["extra"]) + "\n"
	var tail := []
	for r in p["tail"]:
		tail.append("%s %s" % [r[0], r[1]])
	t += "[color=#6a8a84]%s[/color]" % " · ".join(tail)
	return t


## Una riga «Danno ×1,15» solo se l'effetto c'è.
static func _mult(rows: Array, label: String, v: float) -> void:
	if absf(v - 1.0) > 0.001:
		rows.append([label, "×%.2f" % v])
