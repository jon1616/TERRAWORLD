class_name Chiefs
extends Node
## I capi erranti (voce 375, Roadmap 41; dati nel pacchetto generato `src/data/vastita/capi.gd`, campo «chiefs»).
## Ogni capo vive nei mondi del suo vigore (fino a `SPAN` vigori dopo) e in un suo strato; ci si imbatte esplorando:
## stando nello strato giusto, ogni `EVERY` secondi c'è `CHANCE` che compaia, lontano dalla visuale ma non troppo, con
## un avviso. Una volta per mondo (`world_meta["capi"]`). Combatte come le creature del suo posto, con molta più Vita
## (`HP`), e lascia le sue cose (la tabella «capo_<id>»: arma, gioielli, reliquia, trofeo).

const EVERY := 20.0
const CHANCE := 0.06
const SPAN := 2
const HP := 3.0
const DIST := [18, 30]                   # tessere dal Germogliato

var m: Node2D
var active: Creature
var met := 0                              # per le prove
var _t := 8.0
var _rng := RandomNumberGenerator.new()
static var LIST: Array = BiomesData.pack_list("chiefs")


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	m.fauna.killed.connect(func(c: Creature) -> void:
		if c == active:
			active = null
			m.lords.bar.follow(null))


func _process(dt: float) -> void:
	if not m.built or (active != null and is_instance_valid(active)):
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = EVERY
	if bool(m.world_meta.get("giardino", false)) or _rng.randf() > CHANCE:
		return
	var c := candidate()
	if not c.is_empty():
		spawn(c)


## Il capo che può comparire qui adesso ({} se nessuno).
func candidate() -> Dictionary:
	var v := int(m.world_meta.get("vigore", 1))
	var pc: Vector2i = m.player_cell()
	var s := StrataData.at(m.world, pc.x, pc.y)
	var seen: Dictionary = m.world_meta.get("capi", {})
	var ok := []
	for c in LIST:
		var cv := int(c["vigor"])
		if v >= cv and v <= cv + SPAN and int(c["stratum"]) == s and not seen.has(String(c["id"])):
			ok.append(c)
	return {} if ok.is_empty() else ok[_rng.randi_range(0, ok.size() - 1)]


## Fa comparire un capo vicino al Germogliato (in un posto libero, a terra se non vola). La creatura o null.
func spawn(c: Dictionary) -> Creature:
	var cid := String(c["creature"])
	var d := CreaturesData.get_data(cid)
	var pc: Vector2i = m.player_cell()
	for k in 40:
		var dx := _rng.randi_range(DIST[0], DIST[1]) * (1 if _rng.randf() < 0.5 else -1)
		var x := pc.x + dx
		for dy in range(-8, 9):
			var y := pc.y + dy
			if not m.fauna._free(x, y):
				continue
			if not d.get("fly", false) and not m.world.solid(x, y + 1):
				continue
			var cr: Creature = m.fauna.add(cid, Vector2(x * 16 + 8, (y + 1) * 16 - float(d["half"][1]) - 0.1))
			var st := StrataData.at(m.world, x, y)
			var mult: float = float(StrataData.STRATA[st]["danger"]) * m.fauna.vigor_mult
			cr.strengthen(mult * HP, m.fauna.dmg_for(mult) * DangerData.DAMAGE)
			cr.extra = true
			cr.provoke()
			active = cr
			met += 1
			var seen: Dictionary = m.world_meta.get("capi", {})
			seen[String(c["id"])] = 1
			m.world_meta["capi"] = seen
			m.lords.bar.follow(cr)
			m.sfx.play("presenza")
			m.depth_watch.banner.show_stratum(String(d["name"]), "Un capo errante ti ha sentito", Color("#ffb040"))
			return cr
	return null
