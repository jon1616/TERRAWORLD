class_name CuoreDesto
extends Node
## Il Risveglio del Cuore (Roadmap 39, voce 364; la spina in `SpineData`) e il Diario della spina (voce 366).
##
## La prima grande soglia della partita, come il passaggio alla modalità difficile di Terraria: risolto (curato o
## abbattuto) il Guardiano di un mondo di vigore `VIGOR` o più, **tutti i mondi cambiano**, anche quelli già visitati:
##   - nelle rocce dei mondi di vigore 6 e oltre compaiono i metalli del Risveglio (`GeneMaterials.spine_for`);
##   - le creature antiche nascono più spesso (`RARE`) e se li portano dentro;
##   - nel Giardino cresce una seconda radice: un'Aiuola in più (`Aiuole.max_aiuole`);
##   - i Guardiani dei mondi di vigore 5 e oltre lasciano la Linfa del Cuore (`SpineData.ITEMS`: Vita per sempre).
## Nel personaggio: `stats["risveglio_cuore"]` (1 = avvenuto). Una pagina nel Taccuino del Semenzaio («La spina»).

const VIGOR := 4
const RARE := 1.25
const HEART_GIFT := 2                    # Linfa del Cuore per Guardiano risolto, dal vigore 5

var m: Node2D
var paused := false                      # (le prove chiamano `awaken` a mano)


func setup(main: Node2D) -> void:
	m = main
	m.guardian.resolved.connect(func(how: String) -> void:
		if not paused:
			on_resolved(how))
	apply()


static func awake(ch: Character) -> bool:
	return int(ch.stats.get("risveglio_cuore", 0)) >= 1


## Le leve del mondo dopo il Risveglio (a ogni ingresso e quando avviene).
func apply() -> void:
	m.fauna.awake_rare = RARE if awake(m.character) else 1.0
	if m.get("gene_mats") != null:
		m.gene_mats.refresh()


func on_resolved(_how: String) -> void:
	var v := int(m.world_meta.get("vigore", 1))
	if awake(m.character) and v >= 5:
		m.drops.spawn("linfa_cuore", HEART_GIFT, m.guardian.heart_pos() + Vector2(0, -32))
	if not awake(m.character) and v >= VIGOR:
		awaken()


## Il Risveglio: una volta per personaggio.
func awaken() -> void:
	if awake(m.character):
		return
	m.character.stats["risveglio_cuore"] = 1
	apply()
	if m.get("diary") != null:
		m.diary.note("Il Cuore si è risvegliato: tutti i mondi sono cambiati", "guardiano")
	if m.get("juice") != null:
		m.juice.shake(6.0, 0.6)
	m.depth_watch.banner.show_stratum("Il Risveglio del Cuore", "Tutti i mondi rispondono: metalli nuovi, una radice nuova",
		Color("#ff86c8"))
	var t := get_tree().create_timer(4.0)
	var me: WeakRef = weakref(self)
	t.timeout.connect(func() -> void:
		var s: CuoreDesto = me.get_ref()
		if s != null and s.m.get("guardian") != null:
			s.m.guardian.lore.show_page("risveglio_cuore"))


## --- Il Diario della spina (voce 366): una pagina del Taccuino ---------------------------------------------------

## La fase della partita a cui è arrivato il personaggio: il metallo migliore trovato e il mondo più vigoroso visitato.
func phase_now() -> int:
	var best := 0
	var found: Dictionary = m.character.erbario.get("oggetti", {})
	for id in found:
		var sid := String(id)
		if sid.begins_with("lingotto_"):
			var md := MaterialsData.get_mat(sid.trim_prefix("lingotto_"))
			if not md.is_empty() and not md.has("alloy"):
				best = maxi(best, SpineData.phase_of_tier(int(md["tier"])))
	var v := 1
	if m.get("diary") != null:
		v = maxi(m.diary.count("vigore_max"), 1)
	return clampi(maxi(best, SpineData.phase_of_vigor(v) - 1), 0, PhasesData.PHASES.size() - 1)


func rows(selected: String) -> Array:
	var f := phase_now()
	return [["storia:spina", "La spina   ·   fase %d, %s" % [f, PhasesData.phase_name(f)],
		"#ffd08a" if selected == "storia:spina" else "#ffe0c8"]]


func detail() -> String:
	var f := phase_now()
	var t := "[color=#d8b8a8]La strada della partita: ventiquattro fasi, i metalli di ognuna e le soglie che cambiano i mondi.[/color]\n"
	t += "\nSei alla fase [b]%d[/b], [color=%s]%s[/color]." % [f, PhasesData.RARITIES[clampi(f / 2, 0, 11)][1], PhasesData.phase_name(f)]
	if awake(m.character):
		t += "\n[color=#ff86c8]Il Cuore si è risvegliato[/color]: i metalli nuovi sono nelle rocce dei mondi vigorosi."
	else:
		t += "\n[color=#ff86c8]La prima soglia[/color]: risolvi il Guardiano di un mondo di vigore %d o più. Tutti i mondi cambieranno." % VIGOR
	t += "\n\n[b]I metalli[/b]"
	var found: Dictionary = m.character.erbario.get("oggetti", {})
	for mat in MaterialsData.MATERIALS.keys() + SpineData.METALS.keys():
		var md := MaterialsData.get_mat(String(mat))
		var have := found.has(String(md.get("bar", "")))
		var p := SpineData.phase_of_tier(int(md["tier"]))
		var col := "#8ff0a0" if have else ("#ffe8d0" if p <= f + 2 else "#8a7a70")
		var where := ""
		if SpineData.METALS.has(mat):
			var r: Dictionary = SpineData.METALS[mat]["raw"]
			where = " — mondi di vigore %d e oltre, %s" % [int(r["vigor"]), ["in superficie", "dal Sottobosco", "dalle Caverne",
				"dalle Profondità", "nel Fondo"][int(r["stratum"])]]
		t += "\n[color=%s]%s %s[/color]  fase %d · filo %d%s" % [col, "✓" if have else "·", String(md["label"]).trim_prefix("di ").trim_prefix("d'"),
			p, int(md["filo"]), where]
	t += "\n\n[b]Le fasi[/b]"
	for i in PhasesData.PHASES.size():
		var ph: Array = PhasesData.PHASES[i]
		var col2 := "#8ff0a0" if i < f else ("#ffd08a" if i == f else "#8a7a70")
		t += "\n[color=%s]%d · %s[/color]%s" % [col2, i, ph[0], ("  [color=#a89888]→ %s[/color]" % ph[1]) if String(ph[1]) != "" and i >= f else ""]
	return t
