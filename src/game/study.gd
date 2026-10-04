class_name Study
extends Node
## Studiare le creature (voce 138, Roadmap 15): l'Erbario diventa un bestiario a **gradi** per ogni specie:
##   0 sconosciuta · 1 **vista** (è passata entro `SEEN_R` tessere) · 2 **sconfitta** (almeno una volta) ·
##   3 **studiata** (sconfitte + punti di studio ≥ `need`: `KILLS` per le comuni, `KILLS_BOSS` per Guardiani e Signori;
##   la Provetta usata su una creatura dà `PROVETTA` punti).
## Ogni grado scopre qualcosa nella scheda della creatura (`WorldTip`): sconfitta → debolezze e resistenze; studiata →
## come si batte (le contromosse delle astuzie). Le specie studiate danno **+6% di danno** contro di loro, per sempre
## (`Combat`). Il filo propone la specie più vicina a essere studiata. Dati in `Character.erbario` («viste», «studio»).

const SEEN_R := 14.0
const KILLS := 12
const KILLS_BOSS := 3
const PROVETTA := 4
const BONUS := 0.06
const GRADES := ["sconosciuta", "vista", "sconfitta", "studiata"]

var m: Node2D
var _t := 0.0


func setup(main: Node2D) -> void:
	m = main
	if not m.character.erbario.has("studiate"):
		m.character.erbario["studiate"] = {}
		repair()
	for k in ["viste", "studio"]:
		if not m.character.erbario.has(k):
			m.character.erbario[k] = {}
	m.fauna.killed.connect(_on_killed)


## (Voce 350, 4 ott 2026) Fino ad oggi `_check` dava il premio dello studio a **ogni** sconfitta di una specie già
## studiata: nella partita dell'utente 459 «studiate» su 61 specie, e i Misteri al grado 10 in tre ore. Le specie
## studiate ora stanno in `erbario["studiate"]` (una volta sola); i personaggi di prima si correggono qui: il conteggio
## torna vero, i punti dei Misteri dati in più (`MasteryData.STATS`) si tolgono, le stelle si ricontano. I premi dei
## gradi già ricevuti restano.
func repair() -> void:
	var done: Dictionary = m.character.erbario["studiate"]
	for k in ["viste", "studio"]:
		if not m.character.erbario.has(k):
			m.character.erbario[k] = {}
	for base in m.character.erbario.get("creature", {}):
		if grade(String(base)) >= 3:
			done[String(base)] = 1
	var st: Dictionary = m.character.stats
	var extra := int(st.get("studiate", 0)) - done.size()
	if extra <= 0:
		return
	st["studiate"] = done.size()
	for e in MasteryData.STATS.get("studiate", []):
		var pillar := String(e[0])
		var md: Dictionary = m.character.maestria
		if not md.has(pillar):
			continue
		var rec: Dictionary = md[pillar]
		rec["p"] = maxf(float(rec.get("p", 0.0)) - float(e[1]) * extra, 0.0)
		var old := int(st.get("stelle_" + pillar, 0))
		var now := Evergreen.stars_of(pillar, float(rec["p"]))
		if now < old:
			st["stelle_" + pillar] = now
			st["stelle_maestria"] = maxi(int(st.get("stelle_maestria", 0)) - (old - now), 0)
	print("Studio: corretto il conteggio delle specie studiate (%d in più tolte)" % extra)


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = 1.0
	var seen: Dictionary = m.character.erbario["viste"]
	for c in m.fauna.list:
		if not seen.has(c.base) and c.position.distance_to(m.player.position) < SEEN_R * 16.0 and not c.buried:
			seen[c.base] = 1


func need(base: String) -> int:
	return KILLS_BOSS if bool(CreaturesData.get_data(base).get("boss", false)) else KILLS


func points(base: String) -> int:
	return int(m.character.erbario["creature"].get(base, 0)) + int(m.character.erbario["studio"].get(base, 0))


func grade(base: String) -> int:
	if points(base) >= need(base) and int(m.character.erbario["creature"].get(base, 0)) > 0 or int(m.character.erbario["studio"].get(base, 0)) >= need(base):
		return 3
	if int(m.character.erbario["creature"].get(base, 0)) > 0:
		return 2
	if m.character.erbario["viste"].has(base):
		return 1
	return 0


## Il danno contro una specie studiata.
func mult(base: String) -> float:
	return 1.0 + BONUS if grade(base) >= 3 else 1.0


## La Provetta su una creatura: punti di studio (la creatura sotto la cella, entro la portata).
func sample(c: Vector2i, item: String) -> bool:
	var at := (Vector2(c) + Vector2(0.5, 0.5)) * 16.0
	for cr in m.fauna.list:
		if cr.rect().grow(4.0).has_point(at) and not cr.boss:
			if not m.character.bisaccia.remove(item, 1):
				return false
			var was := grade(cr.base)
			var st: Dictionary = m.character.erbario["studio"]
			st[cr.base] = int(st.get(cr.base, 0)) + PROVETTA
			m.character.erbario["viste"][cr.base] = 1
			m.hud.toast("Provetta: studi la %s (%d/%d)" % [String(cr.data.get("name", cr.base)), mini(points(cr.base), need(cr.base)), need(cr.base)])
			_check(cr.base, was)
			return true
	return false


func _on_killed(c: Creature) -> void:
	# (l'Erbario conta la sconfitta nello stesso segnale: si guarda dopo)
	var base := c.base
	var was := grade(base) if int(m.character.erbario["creature"].get(base, 0)) == 0 else 2
	call_deferred("_check", base, was)


func _check(base: String, _was: int) -> void:
	if not m.character.erbario.has("studiate"):
		m.character.erbario["studiate"] = {}
	var done: Dictionary = m.character.erbario["studiate"]
	if grade(base) >= 3 and not done.has(base):
		done[base] = 1                         # una volta sola per specie (prima: a ogni sconfitta)
		m.hud.toast("Hai studiato %s: +%d%% di danno contro di lei, per sempre" % [String(CreaturesData.get_data(base).get("name", base)), roundi(BONUS * 100.0)])
		m.objectives.bump("studiate")
		m.sfx.play("dono")


## La riga della scheda: il grado e che cosa manca.
func line(base: String) -> String:
	var g := grade(base)
	if g >= 3:
		return "Erbario: studiata (+%d%% di danno)" % roundi(BONUS * 100.0)
	return "Erbario: %s · studio %d/%d" % [GRADES[g], mini(points(base), need(base)), need(base)]


## Per il filo: la specie sconfitta più vicina a essere studiata.
func next_to_study() -> Dictionary:
	var best := ""
	var best_left := 999
	for base in m.character.erbario["creature"]:
		if not CreaturesData.CREATURES.has(base) or grade(String(base)) >= 3:
			continue
		var left := need(String(base)) - points(String(base))
		if left < best_left:
			best_left = left
			best = String(base)
	if best == "":
		return {}
	return {"text": "Studia la %s: ancora %d (sconfitte o Provetta)" % [String(CreaturesData.get_data(best).get("name", best)), best_left],
		"hint": "studiata, fai più danno contro di lei e scopri come si batte"}
