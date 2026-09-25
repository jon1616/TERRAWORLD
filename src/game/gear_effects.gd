class_name GearEffects
extends Node
## Gli effetti di ciò che si indossa (campo `acc` in `ItemsData`, anche su elmi, corazze e gambali), dei tratti e dei
## **set completi** (voce 26, `SetsData`), ricalcolati ogni volta che cambia la Bisaccia:
##   run        corsa più veloce (moltiplica `Player.run_mult`)
##   jump       salto più alto (`Player.jump_mult`)
##   glide      tenendo Spazio in caduta si plana (`Player.glide`)
##   fall_safe  niente ferite da caduta (`Life.fall_safe`)
##   halo       alone del Germogliato più ampio (`Boons.halo_mult`)
##   regen      la Vita ricresce più in fretta (`Vitals.regen_mult`)
##   thorns     danno a chi tocca il Germogliato (`Combat.thorns`); luck: fortuna nel bottino (`Fauna.luck`)
##   dig        scavo e taglio più rapidi (`PlayerActions.dig_mult`); stealth: le creature vedono meno lontano
##   damage     danno × (`Combat.dmg_mult`); atk_speed: colpi più rapidi (`Combat.spd_mult`); linfa_regen: Linfa ×
##   magic      incantesimi dei bastoni più forti (`Combat.magic_mult`)
##   air_jumps  salti in aria (`Player.air_jumps`); wall: scivolare e saltare sulle pareti (`Player.wall_climb`)
##   defense    (solo nei bonus dei set) Scorza in più (`Vitals.set_scorza`); quella dei pezzi la somma
##              `Bisaccia.scorza`

const MULT := ["run", "jump", "halo", "regen", "dig", "stealth", "damage", "atk_speed", "linfa_regen", "magic"]

var m: Node2D
var sets: Array = []                   # i set completi indossati (per l'interfaccia)
var relics: Array = []                 # le collezioni di reliquie complete


func setup(main: Node2D) -> void:
	m = main
	m.character.bisaccia.changed.connect(refresh)
	refresh()


func refresh() -> void:
	var e := {}
	for k in MULT:
		e[k] = 1.0
	e["luck"] = 0.0
	e["thorns"] = 0.0
	e["defense"] = 0.0
	e["glide"] = false
	e["air_jumps"] = 0.0
	e["wall"] = false
	e["fall_safe"] = false
	var b: Bisaccia = m.character.bisaccia
	for slot in b.equip:
		_add(e, ItemsData.get_item(String(b.equip[slot])).get("acc", {}))
		var tr := String(b.equip_traits.get(slot, ""))
		for k in ["run", "halo", "regen", "stealth"]:
			e[k] = float(e[k]) * TraitsData.effect(tr, k)
		e["luck"] = float(e["luck"]) + TraitsData.effect(tr, "luck")
		e["thorns"] = float(e["thorns"]) + TraitsData.effect(tr, "thorns")
	sets = SetsData.complete(b.equip)
	for s in sets:
		_add(e, SetsData.all()[s]["bonus"])
	# le collezioni di reliquie complete (voce 28): per sempre, trovate una volta
	relics = RelicsData.complete(m.character.erbario.get("oggetti", {}))
	for c in relics:
		_add(e, RelicsData.COLLECTIONS[c]["bonus"])
	m.player.run_mult = e["run"]
	m.player.jump_mult = e["jump"]
	m.player.glide = e["glide"]
	m.player.air_jumps = int(e["air_jumps"])
	m.player.wall_climb = e["wall"]
	m.life.fall_safe = e["fall_safe"]
	m.boons.halo_mult = e["halo"]
	m.vitals.regen_mult = e["regen"]
	m.fauna.luck = e["luck"]
	m.combat.thorns = int(e["thorns"])
	Behavior.stealth = e["stealth"]
	m.actions.dig_mult = e["dig"]
	m.combat.dmg_mult = e["damage"]
	m.combat.spd_mult = e["atk_speed"]
	m.vitals.linfa_regen_mult = e["linfa_regen"]
	m.combat.magic_mult = e["magic"]
	m.vitals.set_scorza = int(e["defense"])


## Somma un gruppo di effetti (di un pezzo o di un set) a quelli raccolti.
static func _add(e: Dictionary, acc: Dictionary) -> void:
	for k in acc:
		if k in MULT:
			e[k] = float(e[k]) * float(acc[k])
		elif k in ["luck", "thorns", "defense", "air_jumps"]:
			e[k] = float(e[k]) + float(acc[k])
		elif k in ["glide", "fall_safe", "wall"]:
			e[k] = bool(e[k]) or bool(acc[k])
