class_name GardenBeauty
extends Node
## La bellezza del Giardino (Roadmap 22, voce 227): un numero che dice quanto è vivo il Giardino, fatto di ciò che il
## giocatore ci costruisce e ci cura. Si calcola solo nel Giardino, ogni `EVERY` secondi:
##   le stanze ricordate (`Rooms`): il loro comfort, e `TYPE_BONUS` per ogni tipo diverso
##   gli abitanti: la loro felicità (`Homes`) / 10
##   le colture dell'orto: una ogni `CROPS_PER` (al più `CROPS_CAP`)
##   le macchine accese della rete: una ogni due (al più `MACHINES_CAP`)
## La bellezza più alta raggiunta sta in `Character.stats.bellezza_max`: ogni punto nuovo dà un punto di maestria del
## Giardino, e le soglie (`GardenBeautyData`, voci 228-233) aprono le isole, i visitatori, le feste.

const EVERY := 10.0
const TYPE_BONUS := 8
const CROPS_PER := 5
const CROPS_CAP := 40
const MACHINES_CAP := 40

var m: Node2D
var value := 0
var _t := 2.0


func setup(main: Node2D) -> void:
	m = main


func home() -> bool:
	return m.get("aiuole") != null and m.aiuole.is_home() and m.world_meta.has("giardino")


func best() -> int:
	return int(m.character.stats.get("bellezza_max", 0))


func _process(dt: float) -> void:
	if not m.built or not home():
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = EVERY
	update()


func update() -> int:
	value = measure()
	m.world_meta["bellezza"] = value
	var was := best()
	if value > was:
		m.character.stats["bellezza_max"] = value
		if m.get("mastery") != null:
			m.mastery.add("giardino", float(value - was))
	return value


## La bellezza di adesso, e le sue parti: [totale, {parte: punti}].
func parts() -> Dictionary:
	var out := {"stanze": 0, "tipi": 0, "abitanti": 0, "orto": 0, "rete": 0, "museo": 0}
	var types := {}
	for r in m.world_meta.get("stanze", []):
		var e: Dictionary = r
		out["stanze"] = int(out["stanze"]) + int(e.get("comfort", 0))
		if String(e.get("type", "stanza")) != "stanza":
			types[String(e["type"])] = true
	out["tipi"] = types.size() * TYPE_BONUS
	var happy := 0
	for nid in m.world_meta.get("felicita", {}):
		happy += int(m.world_meta["felicita"][nid])
	out["abitanti"] = happy / 10
	out["orto"] = mini(m.world.crops.size() / CROPS_PER, CROPS_CAP)
	var lit := 0
	if m.get("energy") != null:
		for mc: Machine in m.energy.machines.values():
			if mc.lit or (mc.role() == "macchina" and mc.power >= 0.99 and mc.on()):
				lit += 1
	out["rete"] = mini(lit / 2, MACHINES_CAP)
	out["museo"] = m.museum.exhibited() * MuseumData.PIECE_BEAUTY if m.get("museum") != null else 0   # voce 253
	return out


func measure() -> int:
	var t := 0
	var p := parts()
	for k in p:
		t += int(p[k])
	return t


## Una riga per il Libro dei pilastri.
func line() -> String:
	var p := parts()
	return "Bellezza del Giardino: [b]%d[/b] (la più alta: %d) · stanze %d, tipi di stanza %d, abitanti %d, orto %d, rete %d" % [
		value, best(), p["stanze"], p["tipi"], p["abitanti"], p["orto"], p["rete"]]
