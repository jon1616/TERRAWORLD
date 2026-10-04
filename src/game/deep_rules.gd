class_name DeepRules
extends Node
## Le regole del profondo in partita (voce 354, dati in `DeepRulesData`): l'udito delle creature secondo lo strato del
## Germogliato (`Mind.hear_mult`), le **imboscate** al buio (un gruppo che sbuca alle spalle, annunciato), il materiale
## dello strato dalle creature rare, la riga della regola sotto le scritte in alto. I branchi e le rare più frequenti li
## decide `Fauna.try_spawn` (secondo lo strato dove la creatura nasce); il rigore del Fondo lo fa salire `Harshness`.

const WARN := 1.2                       # secondi tra il fruscio e l'imboscata
const SHELTER := 9.0                    # tessere: una torcia o una lampada posata entro questa distanza ripara

var m: Node2D
var paused := false                     # le prove le fermano
var _rng := RandomNumberGenerator.new()
var _ambush_t := 60.0
var _pending := {}                      # l'imboscata annunciata: {"t", "rule", "stratum"}
var _label: Label
var ambushes := 0                       # quante imboscate (per le prove)


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	m.fauna.killed.connect(_on_killed)
	_label = Label.new()
	_label.position = Vector2(16, 47)              # sopra l'orologio (y 70), sotto le righe dei comandi
	_label.add_theme_font_size_override("font_size", 13)
	_label.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_label.add_theme_constant_override("outline_size", 5)
	_label.mouse_filter = Control.MOUSE_FILTER_PASS
	_label.visible = false
	m.hud.add_child(_label)
	Tips.attach(_label, func() -> Variant:
		var r := DeepRulesData.of(_stratum())
		return TipCard.new().title(String(r.get("name", "")), Color(String(r.get("color", "#ffffff")))).text(String(r.get("desc", ""))) \
			if not r.is_empty() else null)


func _stratum() -> int:
	return maxi(int(m.depth_watch.stratum), 0) if m.get("depth_watch") != null else 0


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	var s := _stratum()
	var r := DeepRulesData.of(s)
	Mind.hear_mult = float(r.get("hear", 1.0))
	_label.visible = not r.is_empty() and not m.hud.is_open()
	if _label.visible:
		_label.text = "%s: %s" % [StrataData.STRATA[s]["name"], String(r["name"]).to_lower()]
		_label.add_theme_color_override("font_color", Color(String(r["color"])))
	if paused or not m.fauna.enabled or m.life.dead:
		return
	if not _pending.is_empty():
		_pending["t"] = float(_pending["t"]) - dt
		if float(_pending["t"]) <= 0.0:
			ambush(_pending["rule"], int(_pending["stratum"]))
			_pending = {}
		return
	if not r.has("ambush"):
		_ambush_t = maxf(_ambush_t, 30.0)
		return
	_ambush_t -= dt
	if _ambush_t > 0.0:
		return
	var a: Dictionary = r["ambush"]
	_ambush_t = _rng.randf_range(float(a["every"][0]), float(a["every"][1]))
	if m.giardino.active or lit_by_player(m.world, m.player_cell(), SHELTER):
		return                                  # vicino alle tue luci non ci si fa sorprendere
	_pending = {"t": WARN, "rule": a, "stratum": s}
	m.sfx.play("presenza", m.player.position)
	m.hud.toast("Un fruscio, alle tue spalle…")


## Una luce posata dal giocatore (torcia, o una stazione che fa luce: lampade, baccello ardente…) entro r tessere?
## Nel profondo la luce naturale di funghi e cristalli non ripara: questa sì.
static func lit_by_player(w: World, c: Vector2i, r: float) -> bool:
	if w.torch_near(c, r):
		return true
	var d := int(ceil(r))
	for y in range(c.y - d, c.y + d + 1, 2):
		for x in range(c.x - d, c.x + d + 1, 2):
			var st := w.station_at(Vector2i(x, y))
			if not st.is_empty() and bool(StationsData.STATIONS.get(String(st["id"]), {}).get("light", false)) \
					and Vector2(x - c.x, y - c.y).length() < r:
				return true
	return false


## Un gruppo della stessa specie dello strato sbuca dietro il Germogliato, nel buio, e lo caccia subito.
func ambush(a: Dictionary, stratum: int) -> Array:
	var out := []
	var choices := CreaturesData.of_stratum(stratum, m.fauna.night, "")
	choices = choices.filter(func(e: Array) -> bool:
		var cd := CreaturesData.get_data(String(e[0]))
		return not cd.get("boss", false) and not cd.has("water") and float(e[1]) > 0.0)
	if choices.is_empty():
		return out
	var id := String(choices[_rng.randi_range(0, choices.size() - 1)][0])
	var behind := -1 if m.player.facing > 0 else 1
	var pc: Vector2i = m.player_cell()
	var n := _rng.randi_range(int(a["n"][0]), int(a["n"][1]))
	for tries in 30:
		if out.size() >= n:
			break
		var d := _rng.randi_range(int(a["dist"][0]), int(a["dist"][1]))
		var c := pc + Vector2i(behind * d, _rng.randi_range(-4, 2))
		for k in 8:
			var y := c.y + k
			if m.fauna._free(c.x, y) and (CreaturesData.get_data(id).get("fly", false) or m.world.solid(c.x, y + 1)):
				var cr: Creature = m.fauna.add(id, Vector2(c.x * 16 + 8, (y + 1) * 16 - CreaturesData.get_data(id)["half"][1] - 0.1))
				var mult: float = float(StrataData.STRATA[stratum]["danger"]) * m.fauna.vigor_mult
				cr.strengthen(mult, mult * DangerData.DAMAGE)
				cr.extra = true
				if cr.mind != null:
					cr.mind.state = Mind.HUNT
				out.append(cr)
				break
	if not out.is_empty():
		ambushes += 1
		m.objectives.bump("imboscate")
	return out


## Il materiale dello strato: dalle rare sempre, dalle comuni a volte (le chiamate in aiuto e i compagni no).
func _on_killed(c: Creature) -> void:
	if c.tame != null or c.boss or c.master != null:
		return
	var cell := Vector2i(floori(c.position.x / 16.0), floori(c.position.y / 16.0))
	var r := DeepRulesData.of(StrataData.at(m.world, cell.x, cell.y))
	if not r.has("loot"):
		return
	var n := 0
	if c.ancient != null and String(c.ancient.rarity) in ["antica", "ancestrale", "capobranco"]:
		n = _rng.randi_range(int(r["loot_n"][0]), int(r["loot_n"][1])) * (3 if String(c.ancient.rarity) == "ancestrale" else 1)
	elif _rng.randf() < float(r.get("loot_common", 0.0)):
		n = 1
	if n > 0:
		m.drops.spawn(String(r["loot"]), n, c.position + Vector2(0, -6))
