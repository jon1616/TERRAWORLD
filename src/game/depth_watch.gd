class_name DepthWatch
extends Node
## Segue in che strato si trova il Germogliato: sfuma il chiarore di fondo della luce verso il colore dello strato e,
## entrando in uno strato nuovo, mostra il suo nome. Un piccolo margine evita che la scritta lampeggi sul confine.

const MARGIN := 4                      # tessere oltre il confine prima di cambiare strato
const FADE := 1.5                      # velocità della sfumatura del chiarore
const BLIGHT := 99                     # «bioma» delle terre avvizzite (non sta in BiomesData: si allarga e si ritira)

var m: Node2D
var stratum := -1
var biome := -1                        # bioma di superficie sotto il giocatore (solo in superficie)
var banner: StratumBanner


func setup(main: Node2D) -> void:
	m = main
	banner = StratumBanner.new()
	m.hud.add_child(banner)
	stratum = _stratum_at(0)
	m.light.ambient = StrataData.STRATA[stratum]["ambient"]


func _stratum_at(margin: int) -> int:
	var c: Vector2i = m.player_cell()
	var dep: int = m.world.depth(c.x, c.y)
	var k := StrataData.index(c.x, dep, m.world.world_seed)
	if margin > 0 and stratum >= 0 and k != stratum:
		# si cambia solo se anche qualche tessera più in là (nella direzione del cambio) è nello strato nuovo
		var k2 := StrataData.index(c.x, dep + (margin if k > stratum else -margin), m.world.world_seed)
		if k2 != k:
			return stratum
	return k


## La Scorza di adesso (armatura, set, poteri, pozione).
func scorza() -> int:
	return m.vitals.scorza + m.vitals.set_scorza + m.vitals.scorza_bonus


## Il bioma di superficie di una colonna, o BLIGHT se lì la superficie è avvizzita.
func _biome_at(x: int) -> int:
	return BLIGHT if Blight.surface_blighted(m.world, x) else BiomesData.at(m.world, x)


func _process(dt: float) -> void:
	if not m.built:
		return
	var k := _stratum_at(MARGIN)
	if k != stratum:
		stratum = k
		var stats: Dictionary = m.character.stats
		stats["strato_max"] = maxi(int(stats.get("strato_max", 0)), k)
		var st: Dictionary = StrataData.STRATA[k]
		var rule := DeepRulesData.of(k)                   # voce 354: la regola dello strato, entrando
		banner.show_stratum(String(st["name"]), String(st["desc"]) + ((" · " + String(rule["name"])) if not rule.is_empty() else ""),
			Color(st["color"]))
		if not rule.is_empty():
			m.hud.toast(String(rule["desc"]))
		# voce 188: entrando in uno strato con una Scorza troppo bassa per quel punto della partita, un avviso
		var warn := DangerData.scorza_warning(scorza(), k, m.fauna.vigor)
		if warn != "":
			m.hud.toast(warn)
	# in superficie: la scritta del bioma quando se ne attraversa il confine (con un margine di qualche colonna)
	if stratum == 0:
		var x: int = m.player_cell().x
		var b := _biome_at(x)
		if b != biome and _biome_at(x - 6) == b and _biome_at(x + 6) == b:
			var first := biome < 0
			biome = b
			if not first:
				if b == BLIGHT:
					banner.show_stratum("Terre avvizzite", "L'Avvizzimento si mangia la terra: il Guardiano dorme ancora", Color("#a8a694"))
				else:
					var bd: Dictionary = BiomesData.BIOMES[b]
					banner.show_stratum(String(bd["name"]), String(bd["desc"]), Color(bd["color"]))
	var goal: Color = StrataData.STRATA[stratum]["ambient"]
	var a: Color = m.light.ambient
	if absf(a.r - goal.r) + absf(a.g - goal.g) + absf(a.b - goal.b) > 0.003:
		m.light.ambient = a.lerp(goal, minf(dt * FADE, 1.0))
		m.light.dirty = true               # la luce si ricalcola col nuovo chiarore
