class_name DepthWatch
extends Node
## Segue in che strato si trova il Germogliato: sfuma il chiarore di fondo della luce verso il colore dello strato e,
## entrando in uno strato nuovo, mostra il suo nome. Un piccolo margine evita che la scritta lampeggi sul confine.

const MARGIN := 4                      # tessere oltre il confine prima di cambiare strato
const FADE := 1.5                      # velocità della sfumatura del chiarore

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


func _process(dt: float) -> void:
	if not m.built:
		return
	var k := _stratum_at(MARGIN)
	if k != stratum:
		stratum = k
		var stats: Dictionary = m.character.stats
		stats["strato_max"] = maxi(int(stats.get("strato_max", 0)), k)
		var st: Dictionary = StrataData.STRATA[k]
		banner.show_stratum(String(st["name"]), String(st["desc"]), Color(st["color"]))
	# in superficie: la scritta del bioma quando se ne attraversa il confine (con un margine di qualche colonna)
	if stratum == 0:
		var x: int = m.player_cell().x
		var b := BiomesData.at(m.world, x)
		if b != biome and BiomesData.at(m.world, x - 6) == b and BiomesData.at(m.world, x + 6) == b:
			var first := biome < 0
			biome = b
			if not first:
				var bd: Dictionary = BiomesData.BIOMES[b]
				banner.show_stratum(String(bd["name"]), String(bd["desc"]), Color(bd["color"]))
	var goal: Color = StrataData.STRATA[stratum]["ambient"]
	var a: Color = m.light.ambient
	if absf(a.r - goal.r) + absf(a.g - goal.g) + absf(a.b - goal.b) > 0.003:
		m.light.ambient = a.lerp(goal, minf(dt * FADE, 1.0))
		m.light.dirty = true               # la luce si ricalcola col nuovo chiarore
