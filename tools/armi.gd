extends SceneTree
## Voce 182 (Roadmap 18): le armi, gli attrezzi e le armature a confronto, con i numeri di `FightModel`. Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/armi.gd
## Scrive prove/armi.txt e lo stampa:
##   1. danno al secondo di ogni forma per i metalli di base (contro difesa 0 e 10), con portata e area
##   2. squilibri: attrezzi che battono le armi dello stesso metallo, forme che dominano (meglio in tutto), metalli di un
##      grado che battono quelli del grado dopo
##   3. armature: Scorza per pezzo e set, quanto tolgono a un colpo tipico del loro strato
##   4. le leghe e i materiali dei geni: danno al secondo della spada rispetto ai metalli del loro grado
##   5. la qualità, i tratti e la tempra: quanto cambiano

const BASE := ["radicite", "legnoferro", "ambra", "linfa", "vuoto", "stellare"]
const FORMS := ["spada", "pugnale", "spadone", "lancia", "martello", "falcione", "frusta", "arco", "balestra", "verga",
	"piccone", "ascia", "trivella"]
## Il colpo tipico dello strato del metallo (media di `ZoneModel` a vigore 1 con danno × pericolo × 1,35).
const STRATUM_OF := {"radicite": 1, "legnoferro": 2, "ambra": 3, "linfa": 4, "vuoto": 4, "stellare": 4}

var out := ""


func _init() -> void:
	_weapons()
	_armor()
	_alloys()
	_mods()
	var f := FileAccess.open("res://prove/armi.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)
	quit()


func _p(s: String) -> void:
	print(s)
	out += s + "\n"


func _w(id: String, cell := {}) -> Dictionary:
	var c := {"id": id}
	c.merge(cell)
	return FightModel.weapon(c, {})


## Danno al secondo contro una difesa (a colpo pieno, senza l'abilità).
func _ps(w: Dictionary, def := 0) -> float:
	return float(Creature.through(roundi(float(w["dmg"])), def)) * float(w["rate"])



func _dps_all() -> Dictionary:
	var t := {}
	for f in FORMS:
		t[f] = {}
		for mat in BASE:
			var id := "%s_%s" % [f, mat]
			if ItemsData.get_item(id).is_empty():
				continue
			t[f][mat] = _w(id)
	return t


func _dps_print(t: Dictionary) -> void:
	_p("1. DANNO AL SECONDO per forma e metallo (contro difesa 0 | contro difesa 10), colpo, colpi al secondo")
	for f in FORMS:
		var row := "   %-9s" % f
		for mat in BASE:
			if not t[f].has(mat):
				row += " | %-17s" % "—"
				continue
			var w: Dictionary = t[f][mat]
			row += " | %5.1f %5.1f (%2d×%.1f)" % [_ps(w), _ps(w, 10), roundi(float(w["dmg"])), float(w["rate"])]
		_p(row)
	_p("   (%s)" % ", ".join(BASE))
	_p("")


func _weapons() -> void:
	var t := _dps_all()
	_dps_print(t)
	_p("2. SQUILIBRI")
	var n := 0
	for mat in BASE:
		var sw: float = _ps(t["spada"][mat]) if t["spada"].has(mat) else 0.0
		for tool in ["piccone", "ascia", "trivella"]:
			if t[tool].has(mat) and _ps(t[tool][mat]) > sw * 0.7:
				_p("   ! %s di %s: %.1f al secondo, il %.0f%% della spada (%.1f): un attrezzo non dovrebbe fare da arma" % [
					tool, mat, _ps(t[tool][mat]), 100.0 * _ps(t[tool][mat]) / sw, sw])
				n += 1
	# una forma che batte tutte le altre in mischia sia contro difesa 0 sia contro 10, per ogni metallo
	var melee := ["spada", "pugnale", "spadone", "lancia", "martello", "falcione", "frusta"]
	for mat in BASE:
		var best := ""
		var b0 := 0.0
		for f in melee:
			if t[f].has(mat) and _ps(t[f][mat]) > b0:
				b0 = _ps(t[f][mat])
				best = f
		var worst := ""
		var w0 := 1e9
		for f in melee:
			if t[f].has(mat) and _ps(t[f][mat]) < w0:
				w0 = _ps(t[f][mat])
				worst = f
		_p("   %s: in mischia la più forte è %s (%.1f), la più debole %s (%.1f): rapporto %.2f" % [mat, best, b0, worst, w0, b0 / w0])
	# un metallo che batte il grado dopo
	for f in FORMS:
		for k in BASE.size() - 1:
			var a: String = BASE[k]
			var b: String = BASE[k + 1]
			if t[f].has(a) and t[f].has(b) and _ps(t[f][a]) > _ps(t[f][b]):
				_p("   ! %s: %s (%.1f) batte %s (%.1f)" % [f, a, _ps(t[f][a]), b, _ps(t[f][b])])
				n += 1
	_p("   %d segnalazioni" % n)
	_p("")


func _armor() -> void:
	_p("3. ARMATURE: Scorza dei pezzi e del set intero, e quanto tolgono a un colpo tipico del loro strato (vigore 1)")
	for mat in BASE + ["pallidite", "tizzonite", "nimbite"]:
		var eq := {}
		var parts := []
		for piece in ["elmo", "corazza", "gambali", "guanti", "stivali"]:
			var id := "%s_%s" % [piece, mat]
			if ItemsData.get_item(id).is_empty():
				continue
			eq[piece] = {"id": id}
			parts.append("%s %d" % [piece, roundi(float(Gear.stats({"id": id})["defense"]))])
		var fx := FightModel.effects(eq)
		var s: int = STRATUM_OF.get(mat, 2)
		var hit := _typical_hit(s)
		var left := Vitals.reduce(roundi(hit), int(fx["scorza"]))
		_p("   %-11s set %2d (%s) · colpo tipico dello strato %d: %2.0f → %d (−%.0f%%)" % [mat, int(fx["scorza"]), ", ".join(parts), s,
			hit, left, 100.0 * (1.0 - left / maxf(hit, 1.0))])
	_p("")


## Il danno medio al contatto delle creature di uno strato, a vigore 1.
func _typical_hit(s: int) -> float:
	var pl := ZoneModel.pool(s)
	var tot := 0.0
	var wsum := 0.0
	for id in pl:
		var f := FightModel.foe(String(id), s, 1)
		if float(f["contact"]) <= 0.0:
			continue
		tot += float(f["contact"]) * float(pl[id])
		wsum += float(pl[id])
	return tot / maxf(wsum, 0.001)


func _alloys() -> void:
	_p("4. LEGHE E MATERIALI DEI GENI: la spada di ognuno contro la spada di base del suo grado (danno al secondo)")
	var base_by_tier := {}
	for mat in BASE:
		base_by_tier[int(MaterialsData.get_mat(mat)["tier"])] = _ps(_w("spada_" + mat))
	var rows := []
	for mat in MaterialsData.all():
		if mat in BASE or ItemsData.get_item("spada_" + mat).is_empty():
			continue
		var tier := int(MaterialsData.get_mat(mat).get("tier", 0))
		var d := _ps(_w("spada_" + mat))
		var ref: float = base_by_tier.get(tier, 0.0)
		rows.append([d / maxf(ref, 0.01), "   %-24s grado %d  %5.1f  (base %5.1f, %+.0f%%)%s" % [mat, tier, d, ref,
			100.0 * (d / maxf(ref, 0.01) - 1.0), "  !" if d > ref * 1.25 or d < ref * 0.8 else ""]])
	rows.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) > float(b[0]))
	for r in rows:
		_p(String(r[1]))
	_p("")


func _mods() -> void:
	_p("5. QUALITÀ, TRATTI, TEMPRA sulla spada di ambra (danno al secondo)")
	var base := _ps(_w("spada_ambra"))
	_p("   base %.1f" % base)
	for q in TraitsData.QUALITY.size():
		_p("   qualità %-10s %.1f (%+.0f%%)" % [String(TraitsData.QUALITY[q].get("name", q)), _ps(_w("spada_ambra", {"dati": {"q": q}})),
			100.0 * (_ps(_w("spada_ambra", {"dati": {"q": q}})) / base - 1.0)])
	for tp in [1, 2, 4, 8]:
		var d := _ps(_w("spada_ambra", {"dati": {"tempra": tp}}))
		_p("   tempra %d: %.1f (%+.0f%%)" % [tp, d, 100.0 * (d / base - 1.0)])
