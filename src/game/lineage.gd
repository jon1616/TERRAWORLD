class_name Lineage
extends RefCounted
## Le stirpi della mandria (Roadmap 24, voce 241). Ogni figlio nato da una coppia porta nelle sue doti:
##   padri   i nomi dei due genitori          nonni   i nomi dei nonni (fino a quattro)
##   capo    il capostipite (il genitore più antico della stirpe)
##   pura    da quante generazioni la variante (taglia, elemento, indole) resta la stessa: dalla `PURE_GEN` la creatura
##           è di **stirpe pura** e le sue doti valgono `PURE_BONUS` in più
## E la **collezione dei manti**: ogni coppia famiglia × manto raro nata la prima volta (`Character.stats["manto_<fam>_<manto>"]`),
## un premio ogni `EVERY`.

const PURE_GEN := 5
const PURE_BONUS := 1.1
const EVERY := 10
const REWARDS := [
	{"vasetto": 3, "polvere_iridata": 2},
	{"linfa_antica": 2, "polvere_iridata": 3},
	{"vasetto": 5, "linfa_antica": 3},
	{"polvere_iridata": 5, "linfa_antica": 3},
]


## I campi della stirpe di un figlio dei genitori a e b (la specie del figlio decide se la linea resta pura).
static func of_child(a: Dictionary, b: Dictionary, child_species: String) -> Dictionary:
	var ga: Dictionary = a.get("doti", {})
	var gb: Dictionary = b.get("doti", {})
	var nonni := []
	for g in [ga, gb]:
		for n in g.get("padri", []):
			nonni.append(String(n))
	var older: Dictionary = a if int(ga.get("gen", 0)) >= int(gb.get("gen", 0)) else b
	var capo := String((older.get("doti", {}) as Dictionary).get("capo", older.get("nome", "?")))
	var same: bool = String(a.get("specie", "")) == child_species and String(b.get("specie", "")) == child_species
	var pura := mini(int(ga.get("pura", 0)), int(gb.get("pura", 0))) + 1 if same else 0
	return {"padri": [String(a.get("nome", "?")), String(b.get("nome", "?"))], "nonni": nonni.slice(0, 4), "capo": capo, "pura": pura}


static func is_pure(g: Dictionary) -> bool:
	return int(g.get("pura", 0)) >= PURE_GEN


static func mult(g: Dictionary) -> float:
	return PURE_BONUS if is_pure(g) else 1.0


## Le righe della stirpe per la scheda della creatura (BBCode).
static func sheet(g: Dictionary) -> String:
	if not g.has("padri"):
		return ""
	var t := "[color=#8ef0d8]Stirpe di %s[/color] [color=#9fc8c0]· figlio di %s e %s" % [g.get("capo", "?"), g["padri"][0], g["padri"][1]]
	if not (g.get("nonni", []) as Array).is_empty():
		t += " · nonni: %s" % ", ".join(g["nonni"])
	t += "[/color]\n"
	var p := int(g.get("pura", 0))
	if p >= PURE_GEN:
		t += "[color=#ffd24a]Stirpe pura (%d generazioni della stessa variante): doti +%d%%[/color]\n" % [p, roundi((PURE_BONUS - 1.0) * 100.0)]
	elif p > 0:
		t += "[color=#9fc8c0]Linea pura da %d generazioni (a %d la stirpe è pura)[/color]\n" % [p, PURE_GEN]
	return t


## Una creatura appena nata: la collezione dei manti e la stirpe pura. Restituisce l'avviso ("" se niente di nuovo).
static func on_hatch(m: Node2D, rec: Dictionary) -> String:
	var g: Dictionary = rec.get("doti", {})
	var st: Dictionary = m.character.stats
	var msg := ""
	var coat := String(g.get("manto", ""))
	if BreedData.is_rare(coat):
		var key := "manto_%s_%s" % [Herd.family_of(rec), coat]
		if int(st.get(key, 0)) == 0:
			st[key] = 1
			m.objectives.bump("collezione_manti")
			var n := collected(st)
			msg = "Collezione dei manti: %d" % n
			if n % EVERY == 0:
				msg += " · " + _give(m, REWARDS[mini(n / EVERY - 1, REWARDS.size() - 1)])
	if int(g.get("pura", 0)) == PURE_GEN:
		m.objectives.bump("stirpi_pure")
		msg = ("%s · " % msg if msg != "" else "") + "%s è di stirpe pura!" % rec["nome"]
	return msg


static func _give(m: Node2D, gift: Dictionary) -> String:
	var parts := []
	for it in gift:
		var rest: int = m.character.bisaccia.add(String(it), int(gift[it]))
		if rest > 0:
			m.drops.spawn(String(it), rest, m.player.position)
		parts.append("%s ×%d" % [String(ItemsData.get_item(String(it)).get("name", it)), int(gift[it])])
	return ", ".join(parts)


## Quante coppie famiglia × manto raro sono nella collezione.
static func collected(st: Dictionary) -> int:
	var n := 0
	for k in st:
		if String(k).begins_with("manto_") and int(st[k]) == 1:
			n += 1
	return n


## Quante ce ne sono in tutto.
static func total() -> int:
	var rare := 0
	for c in BreedData.COATS:
		if BreedData.is_rare(c):
			rare += 1
	return rare * HerdData.TAME.size()
