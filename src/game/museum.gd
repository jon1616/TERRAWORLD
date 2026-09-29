class_name Museum
extends Node
## Il Museo del Giardino (Roadmap 26, voce 253; sale in `MuseumData`). Le **vetrine** sono contenitori da una casella:
## nel Giardino, ogni `TICK` secondi, un oggetto in una vetrina che fa parte di una sala entra nel Museo per sempre
## (`Character.stats["museo_<oggetto>"]`); una sala con tutti i pezzi è completa (`["sala_<sala>"]`): il suo bonus passa
## da `GearEffects` (`bonuses`), e ogni pezzo dà bellezza al Giardino (`GardenBeauty`).

var m: Node2D
var arch: Archaeology                  # voce 254: l'archeologia
var chron: Chronicles                  # voce 255: le cronache perdute
var _t := 2.0


func setup(main: Node2D) -> void:
	m = main
	arch = Archaeology.new(m)
	chron = Chronicles.new(m)


func _process(dt: float) -> void:
	if m == null or not m.built or m.get("beauty") == null or not m.beauty.home():
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = MuseumData.TICK
	scan()


## Guarda le vetrine del Giardino. Restituisce gli oggetti entrati adesso nel Museo.
func scan() -> Array:
	var fresh := []
	for o in m.world.stations:
		if String(m.world.stations[o]) != "vetrina":
			continue
		var chest: Bisaccia = m.world.chest_at(o)
		if chest == null:
			continue
		var id := chest.id_at(0)
		if id != "" and exhibit(id):
			fresh.append(id)
	return fresh


## Un oggetto entra nel Museo (se è di una sala e non c'era già). Vero se è nuovo.
func exhibit(id: String) -> bool:
	var h := MuseumData.hall_of(id)
	var st: Dictionary = m.character.stats
	if h == "" or int(st.get("museo_" + id, 0)) == 1:
		return false
	st["museo_" + id] = 1
	m.objectives.bump("museo")
	var have := count(h)
	var all := MuseumData.pieces(h).size()
	m.hud.toast("Nel Museo: %s (%s, %d su %d)" % [String(ItemsData.get_item(id).get("name", id)), MuseumData.HALLS[h]["name"], have, all])
	m.sfx.play("dono")
	if have >= all and int(st.get("sala_" + h, 0)) == 0:
		st["sala_" + h] = 1
		m.objectives.bump("sale_museo")
		m.gear.refresh()
		m.hud.toast("%s è completa: %s" % [MuseumData.HALLS[h]["name"], MuseumData.HALLS[h]["desc"]])
		if m.get("diary") != null:
			m.diary.note("%s è completa" % MuseumData.HALLS[h]["name"], "museo")
	return true


func count(h: String) -> int:
	var n := 0
	for id in MuseumData.pieces(h):
		n += int(m.character.stats.get("museo_" + String(id), 0))
	return n


func exhibited() -> int:
	var n := 0
	for h in MuseumData.HALLS:
		n += count(h)
	return n


## I bonus delle sale complete (per `GearEffects`).
static func bonuses(stats: Dictionary) -> Array:
	var out := []
	for h in MuseumData.HALLS:
		if int(stats.get("sala_" + h, 0)) == 1:
			out.append(MuseumData.HALLS[h]["bonus"])
	return out


## La riga del Museo nel Libro dei pilastri.
func line() -> String:
	var done := 0
	for h in MuseumData.HALLS:
		done += int(m.character.stats.get("sala_" + h, 0))
	return "Il Museo: %d pezzi su %d, sale complete %d su %d · %s" % [exhibited(), MuseumData.total(), done, MuseumData.HALLS.size(),
		chron.line()]
