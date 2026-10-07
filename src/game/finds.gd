class_name Finds
extends Node
## I ritrovamenti (Roadmap 45; dati nel pacchetto `src/data/vastita/ritrovamenti.gd`, in `ChestsData` e in
## `TransmuteData`):
##   - le **casse sigillate** dei biomi (voce 392) si aprono con la chiave del loro bioma, che si consuma; la chiave la
##     lasciano di rado (`KEY_CHANCE`) le creature di quel bioma, dopo il primo Guardiano risolto;
##   - i **mimi** (voce 393): una stazione che sembra la cassa del bioma; toccata, si sveglia la creatura;
##   - la **Pozza di Linfa antica** (voce 396): con un oggetto in mano, clic destro: diventa un altro della sua famiglia
##     (`TransmuteData`); si sveglia dopo il primo Guardiano. Le trasformazioni scoperte restano in
##     `Character.stats["trasf_<oggetto>"]` (l'Erbario le mostra).

const KEY_CHANCE := 0.0067               # una creatura su 150, dopo il primo Guardiano
const POOL := "pozza_linfa"

var m: Node2D
var keys_dropped := 0                    # per le prove
var mimics_woken := 0
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	m.fauna.killed.connect(_on_killed)


## Il clic destro su una stazione: true se è stato gestito qui (e non va aperta come una cassa qualunque).
func touch(o: Vector2i, id: String) -> bool:
	var mi := ChestsData.mimic_of(id)
	if not mi.is_empty():
		_wake(o, mi)
		return true
	if id == POOL:
		return _pool()
	var info := ChestsData.info(id)
	if not info.has("key"):
		return false
	var opened: Array = m.world_meta.get("sigillate", [])
	var k := "%d,%d" % [o.x, o.y]
	if k in opened:
		return false
	var key := String(info["key"])
	var b: Bisaccia = m.character.bisaccia
	if b.count(key) <= 0:
		m.hud.toast("È sigillata: serve la %s." % ItemsData.get_item(key).get("name", key))
		return true
	b.remove(key, 1)
	opened.append(k)
	m.world_meta["sigillate"] = opened
	m.objectives.bump("casse_sigillate")
	m.sfx.play("dono", Vector2(o) * 16.0)
	Fx.puff(m.fx, Vector2(o) * 16.0 + Vector2(16, 8), Color(1.8, 1.5, 0.8))
	m.hud.toast("La chiave gira: la cassa si apre.")
	return false                                   # ora si apre come le altre


func _wake(o: Vector2i, mi: Dictionary) -> void:
	m.world.stations.erase(o)
	m.view.remove_station(o)
	m.light.dirty = true
	var cid := String(mi["creature"])
	var d := CreaturesData.get_data(cid)
	var cr: Creature = m.fauna.add(cid, Vector2(o.x * 16 + 16, (o.y + 2) * 16 - float(d["half"][1]) - 0.1))
	var st := StrataData.at(m.world, o.x, o.y)
	var mult: float = float(StrataData.STRATA[st]["danger"]) * m.fauna.vigor_mult
	cr.strengthen(mult, m.fauna.dmg_for(mult) * DangerData.DAMAGE)
	cr.extra = true
	mimics_woken += 1
	m.objectives.bump("mimi")
	if m.get("juice") != null:
		m.juice.shake(4.0, 0.25)
	m.hud.toast("La cassa apre la bocca: è un mimo!")


func _on_killed(c: Creature) -> void:
	if not is_instance_valid(c) or c.tame != null or bool(c.data.get("boss", false)):
		return
	if int(m.character.stats.get("guardiani", 0)) < 1:
		return
	if _rng.randf() > KEY_CHANCE * (1.0 + maxf(float(m.fauna.luck), 0.0)):
		return
	var cell := Vector2i(floori(c.position.x / 16.0), floori(c.position.y / 16.0))
	var b := ChestsData.biome_at(m.world, cell, StrataData.at(m.world, cell.x, cell.y))
	if ItemsData.has("chiave_" + b):
		m.drops.spawn("chiave_" + b, 1, c.position)
		keys_dropped += 1


## La Pozza: l'oggetto in mano diventa un altro della sua famiglia.
func _pool() -> bool:
	if int(m.character.stats.get("guardiani", 0)) < 1:
		m.hud.toast("La Linfa antica dorme: si sveglierà quando avrai risolto un Guardiano.")
		return true
	var held: Dictionary = m.hud.current()
	var id := String(held.get("id", ""))
	var to := TransmuteData.of(id)
	if to == "":
		m.hud.toast("La Linfa antica non cambia questo oggetto." if id != "" else
			"Tieni in mano un oggetto e toccala: la Linfa antica lo trasforma.")
		return true
	transmute(id, to)
	return true


func transmute(id: String, to: String) -> void:
	var b: Bisaccia = m.character.bisaccia
	b.remove(id, 1)
	var rest := b.add(to, 1)
	if rest > 0:
		m.drops.spawn(to, rest, m.player.position + Vector2(0, -16))
	var first := int(m.character.stats.get("trasf_" + id, 0)) == 0
	m.character.stats["trasf_" + id] = 1
	m.objectives.bump("trasformazioni")
	Fx.puff(m.fx, m.player.position + Vector2(0, -12), Color(0.6, 1.8, 1.6))
	m.sfx.play("dono")
	m.hud.toast("%s diventa %s%s" % [ItemsData.get_item(id).get("name", id), ItemsData.get_item(to).get("name", to),
		" (nuova trasformazione)" if first else ""])


## Voce 394: il guardiano di una struttura (la creatura più forte del suo bioma, antica e più robusta) si sveglia
## nella stanza del tesoro.
const GUARD_HP := 2.0
var guards := 0                          # per le prove


func guard(e: Dictionary) -> Creature:
	var b := String(PlacesData.PLACES[String(e["id"])].get("biome", ""))
	var cid := strongest_of(b)
	if cid == "":
		return null
	var d := CreaturesData.get_data(cid)
	var at := Vector2(float(e["x"]) + float(e["w"]) * 0.7, float(e["y"]) + float(e["h"]) - 2.0) * 16.0
	var cr: Creature = m.fauna.add(cid, at - Vector2(0, float(d["half"][1])))
	var st := StrataData.at(m.world, floori(at.x / 16.0), floori(at.y / 16.0))
	var mult: float = float(StrataData.STRATA[st]["danger"]) * m.fauna.vigor_mult
	cr.strengthen(mult * GUARD_HP, m.fauna.dmg_for(mult) * DangerData.DAMAGE)
	m.fauna.make_ancient(cr, "antica")
	cr.extra = true
	guards += 1
	m.hud.toast("Qualcosa si sveglia nella stanza del tesoro.")
	return cr


## La creatura più forte che vive in un bioma (di superficie, del sottosuolo o del cielo); il suo mimo se non ce n'è.
static var _strongest := {}


static func strongest_of(b: String) -> String:
	if _strongest.has(b):
		return String(_strongest[b])
	var best := ""
	var hp := -1
	for id in CreaturesData.CREATURES:
		var d: Dictionary = CreaturesData.CREATURES[id]
		if d.get("boss", false) or d.get("awake", false) or int(d.get("weight", 0)) <= 0 and not d.has("under") and not d.has("sky"):
			continue
		var here: bool = b in (d.get("biomes", []) as Array) or String(d.get("under", "")) == b or String(d.get("sky", "")) == b
		if here and int(d.get("hp", 0)) > hp:
			hp = int(d.get("hp", 0))
			best = String(id)
	if best == "" and CreaturesData.CREATURES.has("mimo_" + b):
		best = "mimo_" + b
	_strongest[b] = best
	return best

