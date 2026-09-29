class_name AnglerBook
extends Node
## Il libro dei record di pesca (Roadmap 27, voce 258). A ogni pesce preso (`Fishing.caught`) guarda la sua misura dentro
## la taglia della specie (`FishData` "size"): oltre `TIERS[k]` della strada dalla più piccola alla più grande è una
## medaglia (bronzo, argento, oro). La medaglia più alta di ogni specie in `Character.stats["record_<pesce>"]` (1-3);
## ogni medaglia nuova ha il suo premio, ogni `GOLD_EVERY` ori un premio grande.
## Voce 259, **la gara del giorno**: ogni giorno del mondo il Pescatore sceglie una specie comune già pescata almeno una
## volta; chi ne prende una grande almeno quanto l'argento (`CONTEST_TIER`) vince. Le vittorie di giorni di fila fanno la
## serie (`stats["gara_serie"]`), che fa crescere il premio; un giorno senza vittoria la azzera.

const TIERS := [0.4, 0.7, 0.9]
const NAMES := ["bronzo", "argento", "oro"]
const REWARDS := [{"lumino": 25}, {"cassetta_alga": 1, "lumino": 40}, {"polvere_iridata": 1, "forziere_sommerso": 1}]   # (niente esche: le prove le contano)
const GOLD_EVERY := 10
const GOLD_REWARD := {"linfa_antica": 3, "scrigno_fondo": 1}
const CONTEST_TIER := 2
const CONTEST_POOL := ["comune", "non_comune"]

var m: Node2D
var paused := false                    # le prove: i premi non devono cambiare i conti delle prove della pesca
var contest := ""                      # voce 259: la specie della gara di oggi ("" = nessuna)
var _day := -1
var _won := false
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	if m.get("fishing") != null:
		m.fishing.fish_caught.connect(_on_caught)


## La medaglia di una misura (0 = nessuna, 1-3).
static func tier_of(id: String, size: int) -> int:
	var span: Array = FishData.info(id).get("size", [1, 2])
	var f := clampf(float(size - int(span[0])) / maxf(float(int(span[1]) - int(span[0])), 1.0), 0.0, 1.0)
	var t := 0
	for k in TIERS.size():
		if f >= float(TIERS[k]) - 0.0001:
			t = k + 1
	return t


func medal(id: String) -> int:
	return int(m.character.stats.get("record_" + id, 0))


func _process(_dt: float) -> void:
	if m == null or not m.built or paused or m.get("day") == null:
		return
	var d: int = m.day.day
	if d != _day:
		new_day(d)


## Voce 259: un giorno nuovo, una gara nuova (e la serie si azzera se ieri non si è vinto).
func new_day(d: int) -> void:
	if _day >= 0 and not _won:
		m.character.stats["gara_serie"] = 0
	_day = d
	_won = false
	var pool := []
	var er: Dictionary = m.character.erbario.get("pesci", {})
	for id in er:
		if String(FishData.info(String(id)).get("rar", "")) in CONTEST_POOL:
			pool.append(String(id))
	pool.sort()
	if pool.is_empty():
		contest = ""
		return
	_rng.seed = hash(str(d) + m.world_id)
	contest = String(pool[_rng.randi_range(0, pool.size() - 1)])
	m.hud.toast("La gara del Pescatore, oggi: %s di almeno %d cm" % [String(FishData.info(contest)["name"]), need()])


## La misura che vince la gara di oggi.
func need() -> int:
	var span: Array = FishData.info(contest).get("size", [1, 2])
	return ceili(int(span[0]) + (int(span[1]) - int(span[0])) * float(TIERS[CONTEST_TIER - 1]))


func _contest(id: String, size: int) -> void:
	if contest == "" or _won or id != contest or size < need():
		return
	_won = true
	var st: Dictionary = m.character.stats
	st["gara_serie"] = int(st.get("gara_serie", 0)) + 1
	var serie := int(st["gara_serie"])
	m.objectives.bump("gare_pesca")
	var gift := {"cassetta_alga": 1, "polvere_iridata": mini(serie, 3)}
	if serie % 5 == 0:
		gift["forziere_sommerso"] = 1
	m.hud.toast("Gara del Pescatore vinta! Serie di %d · %s" % [serie, Lineage._give(m, gift)])
	m.sfx.play("dono")


func _on_caught(id: String, size: int) -> void:
	if paused:
		return
	_contest(id, size)
	var t := tier_of(id, size)
	if t <= medal(id):
		return
	var st: Dictionary = m.character.stats
	var old := medal(id)
	st["record_" + id] = t
	var parts := []
	for k in range(old, t):
		parts.append(Lineage._give(m, REWARDS[k]))
		m.objectives.bump("medaglie_pesca")
	var msg := "Record di pesca: %s, medaglia d'%s" % [String(FishData.info(id).get("name", id)), NAMES[t - 1]] if t >= 2 \
		else "Record di pesca: %s, medaglia di bronzo" % String(FishData.info(id).get("name", id))
	if t == 3:
		m.objectives.bump("ori_pesca")
		if count(3) % GOLD_EVERY == 0:
			parts.append(Lineage._give(m, GOLD_REWARD))
	m.hud.toast(msg + " · " + ", ".join(parts))
	m.sfx.play("dono")


## Quante specie hanno almeno la medaglia t.
func count(t: int) -> int:
	var n := 0
	for id in FishData.all():
		if medal(String(id)) >= t:
			n += 1
	return n


func line() -> String:
	var t := "Record di pesca: ori %d, argenti %d, bronzi %d su %d specie" % [count(3), count(2), count(1), FishData.all().size()]
	if contest != "":
		t += " · gara di oggi: %s da %d cm%s (serie %d)" % [String(FishData.info(contest)["name"]), need(), " — vinta" if _won else "",
			int(m.character.stats.get("gara_serie", 0))]
	return t
