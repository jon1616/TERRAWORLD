class_name Lords
extends Node
## I Signori dei luoghi (voce 135, dati in `src/data/bestiary/signori.gd`, fatti da `tools/gen_signori.py`): con
## l'esca rituale in mano, nel suo luogo (il bioma di superficie, il bioma del sottosuolo, lo strato o, dalla Roadmap 16,
## il bioma del cielo), il Signore
## arriva a una decina di tessere, con la barra in alto e la musica dei Guardiani. A metà Vita entra in **furia**
## (`Creature`: i comportamenti del campo `fury`). Sconfitto: il suo materiale unico e il trofeo, `world_meta["signori"]`.

const S := 16
const PACK := preload("res://src/data/bestiary/signori.gd")

var m: Node2D
var bar: BossBar
var active: Creature
var beaten := 0                          # (prove)

signal defeated(key: String)


func setup(main: Node2D) -> void:
	m = main
	bar = BossBar.new()
	m.hud.add_child(bar)
	m.fauna.killed.connect(_on_killed)


static func all() -> Dictionary:
	return PACK.DATA["lords"]


## Quanto è più forte un Signore del suo dato: il vigore, la radice del pericolo dello strato e in cielo metà del
## pericolo del bioma (un Signore è già un boss: non deve durare più del Guardiano). Voce 186 (Roadmap 18): la radice,
## perché con il pericolo pieno i Signori del Fondo duravano due minuti e mezzo e toglievano sei Vite (`tools/boss.gd`).
static func strength(vigor_mult: float, stratum: int, sky: String) -> float:
	var sky_k := 1.0 + (float(SkyData.get_biome(sky).get("danger", 1.0)) - 1.0) * 0.5 if sky != "" else 1.0
	return vigor_mult * sqrt(float(StrataData.STRATA[stratum]["danger"])) * sky_k


func _process(_dt: float) -> void:
	if active != null and not is_instance_valid(active):
		active = null
		bar.follow(null)


## Il Signore di questo posto (la sua chiave) o "".
func here() -> String:
	var pc: Vector2i = m.player_cell()
	var stratum := StrataData.at(m.world, pc.x, pc.y)
	var biome := String(BiomesData.BIOMES[BiomesData.at(m.world, pc.x)]["id"])
	var sky := SkyData.zone_at(m.world, pc.x, pc.y) if stratum == 0 else ""     # Roadmap 16: i Signori del cielo
	var under := ""
	if stratum > 0:
		for e in UnderBiomesData.pool_at(m.world, pc):
			var u := String(CreaturesData.CREATURES.get(String(e[0]), {}).get("under", ""))
			if u != "":
				under = u
				break
	for k in all():
		var wh: Dictionary = all()[k]["where"]
		if wh.has("sky"):
			if String(wh["sky"]) == sky:
				return String(k)
			continue
		if wh.has("biomes") and stratum == 0 and sky == "" and biome in (wh["biomes"] as Array):
			return String(k)
		if wh.has("under") and String(wh["under"]) == under:
			return String(k)
		if wh.has("stratum") and int(wh["stratum"]) == stratum and under == "":
			return String(k)
	return ""


## L'esca rituale in mano: se questo è il suo luogo, il Signore arriva.
func summon(item: String) -> bool:
	var cid := String(ItemsData.get_item(item).get("lord", ""))
	if cid == "":
		return false
	if active != null:
		m.hud.toast("Un Signore è già qui")
		return false
	var key := cid.trim_prefix("signore_")
	if here() != key:
		m.hud.toast("L'esca non ha odore qui: il %s vive altrove" % String(CreaturesData.CREATURES[cid]["name"]))
		return false
	if not m.character.bisaccia.remove(item, 1):
		return false
	spawn(cid)
	return true


func spawn(cid: String) -> Creature:
	var side := 1.0 if m.player.facing >= 0 else -1.0
	var at: Vector2 = m.player.position + Vector2(side * 10.0 * S, -3.0 * S)
	active = m.fauna.add(cid, at)
	var st := StrataData.at(m.world, m.player_cell().x, m.player_cell().y)
	var sky := SkyData.zone_at(m.world, m.player_cell().x, m.player_cell().y)
	active.strengthen(strength(m.fauna.vigor_mult, st, sky), strength(m.fauna.vigor_dmg, st, sky))
	active.provoke()
	bar.follow(active)
	m.sfx.play("guardiano")
	m.depth_watch.banner.show_stratum(String(active.data["name"]), "Il Signore di questo luogo è arrivato", Color("#ffb040"))
	return active


func _on_killed(c: Creature) -> void:
	if c != active:
		return
	active = null
	bar.follow(null)
	var key := String(c.data.get("lord", ""))
	var rec: Dictionary = m.world_meta.get("signori", {})
	rec[key] = int(rec.get(key, 0)) + 1
	m.world_meta["signori"] = rec
	beaten += 1
	m.objectives.bump("signori")
	m.hud.toast("Hai sconfitto il %s!" % String(c.data["name"]))
	defeated.emit(key)
