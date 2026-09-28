class_name Seasons
extends Node
## Le stagioni mentre si gioca (voce 66, dati in `SeasonsData`): ogni secondo si guarda la stagione del mondo (dal
## giorno di `DayCycle`, sfasata dal seme; fissa se un gene del mondo la fissa) e, quando cambia, la si mette in
## pratica: pesi delle famiglie (`Fauna.season_roles/season_families`), la creatura della stagione
## (`Fauna.season_creature`), crescita delle colture (`Garden.season_mult`), eventi (`Events.season_mult`), colore
## del mondo (`Background.season_tint`), e una scritta grande con il nome della stagione. L'orologio in alto la dice.
## La Provetta nell'aria della superficie può catturare il gene della stagione (`Sampling`).

var m: Node2D
var current := -1
var fixed := 0                         # 1-4 se un gene del mondo la fissa
var _t := 0.0


func setup(main: Node2D) -> void:
	m = main
	fixed = int(Genome.effects(m.world_meta.get("geni", []), "run").get("season", 0))
	_update(true)


func info() -> Dictionary:
	return SeasonsData.SEASONS[maxi(current, 0)]


func title() -> String:
	return String(info()["name"]) + (" (eterno)" if fixed > 0 else "")


func _process(dt: float) -> void:
	if not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = 1.0
	_update(false)


func _update(first: bool) -> void:
	var s := SeasonsData.index(m.day.day, m.world.world_seed, fixed)
	if s == current:
		return
	current = s
	CreaturesData.now_season = String(SeasonsData.SEASONS[s]["id"]) if s >= 0 and s < SeasonsData.SEASONS.size() else ""   # voce 134
	var sd: Dictionary = SeasonsData.SEASONS[s]
	m.fauna.season_roles = sd["roles"]
	m.fauna.season_families = sd["families"]
	m.fauna.season_creature = String(sd["creature"]) if not m.giardino.active else ""
	m.garden.season_mult = float(sd["grow"])
	m.events.season_mult = float(sd["events"])
	m.background.season_tint = sd["tint"]
	m.day.apply(true)                                       # l'orologio mostra subito la stagione nuova
	if not first:
		m.depth_watch.banner.show_stratum("Stagione del %s" % sd["name"], String(sd["desc"]), sd["color"])
		m.objectives.bump("stagioni")
