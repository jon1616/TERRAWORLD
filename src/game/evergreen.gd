class_name Evergreen
extends Node
## Il dopo (Roadmap 28, voce 265): la partita non finisce.
## - **Le stelle di maestria**: oltre il grado 10 di un pilastro, ogni `STAR_FRAC` delle sue ore di punti in più è una
##   stella (`Character.stats["stelle_<pilastro>"]`), con un piccolo premio (`STAR_GIFT`). Nessun limite.
## - **I Semi d'oro**: dopo il finale, ogni `GOLD_DAYS` giorni del Giardino l'Albero-Madre d'oro dona un Seme di mondo più
##   vigoroso del più forte che si è visitato, con un gene stellare (`stats["seme_oro_giorno"]` = il giorno dell'ultimo).

const STAR_FRAC := 0.1
const STAR_GIFT := {"polvere_iridata": 1, "linfa_antica": 1}
const GOLD_DAYS := 7
const TICK := 5.0

var m: Node2D
var _t := 3.0
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	if m.get("mastery") != null:
		m.mastery.gained.connect(func(p: String, _pts: float) -> void: stars_check(p))


## Le stelle di un pilastro guadagnate con i punti di adesso.
static func stars_of(pillar: String, pts: float) -> int:
	var top := MasteryData.points_for(pillar, MasteryData.GRADES)
	var step := float(MasteryData.PILLARS[pillar]["hours"]) * 60.0 * STAR_FRAC
	return 0 if pts < top else floori((pts - top) / step)


func stars(pillar: String) -> int:
	return int(m.character.stats.get("stelle_" + pillar, 0))


func stars_check(pillar: String) -> void:
	var have := stars_of(pillar, m.mastery.points(pillar))
	var old := stars(pillar)
	if have <= old:
		return
	m.character.stats["stelle_" + pillar] = have
	var gift := ""
	for k in range(old, have):
		gift = Lineage._give(m, STAR_GIFT)
		m.objectives.bump("stelle_maestria")
	m.hud.toast("%s: una stella oltre il grado 10 (%d) · %s" % [MasteryData.PILLARS[pillar]["name"], have, gift])
	m.sfx.play("dono")


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = TICK
	gold_check()


## Il Seme d'oro della settimana, nel Giardino dopo il finale. Vero se l'ha donato adesso.
func gold_check() -> bool:
	if int(m.character.stats.get("finale", 0)) < 1 or m.get("beauty") == null or not m.beauty.home() or m.get("day") == null:
		return false
	var day: int = m.day.day
	var last := int(m.character.stats.get("seme_oro_giorno", -GOLD_DAYS))
	if day - last < GOLD_DAYS:
		return false
	m.character.stats["seme_oro_giorno"] = day
	var g := golden_genome()
	var item := Genome.item_of(g)
	if m.character.bisaccia.add_stack({"id": item, "n": 1, "dati": g}) > 0:
		m.drops.spawn(item, 1, m.player.position, g)
	m.objectives.bump("semi_oro")
	m.hud.toast("L'Albero-Madre d'oro ti dona un Seme d'oro: vigore %d" % int(g["vigore"]))
	m.sfx.play("portale")
	return true


## Un Seme più vigoroso del mondo più forte dell'Atlante, con un gene stellare.
func golden_genome() -> Dictionary:
	var v := 3
	for wid in m.character.atlante:
		v = maxi(v, int(m.character.atlante[wid].get("vigore", 1)) + 2)
	var g := Genome.roll(_rng, v)
	var pool := []
	for k in GenesData.GENES:
		var d := GenesData.info(String(k))
		# (come il Seme Primo: i geni stellari, non di stagione, d'ombra o di superficie)
		if int(d.get("rar", 0)) == 3 and String(d.get("only", "")) != "stagione" and String(d.get("cat", "")) != "ombra" \
				and String(d.get("cat", "")) != "superficie" and not String(k) in (g["geni"] as Array):
			pool.append(String(k))
	if not pool.is_empty():
		var extra := String(pool[_rng.randi_range(0, pool.size() - 1)])
		var keep := []
		for x in g["geni"]:
			if GenesData.cat_of(String(x)) != GenesData.cat_of(extra):
				keep.append(x)
		keep.append(extra)
		g["geni"] = Genome.sort(keep)
	return g


func line() -> String:
	var parts := []
	for p in MasteryData.ORDER:
		if stars(String(p)) > 0:
			parts.append("%s %d" % [String(p), stars(String(p))])
	return "Stelle oltre il grado 10: " + (", ".join(parts) if not parts.is_empty() else "nessuna ancora")
