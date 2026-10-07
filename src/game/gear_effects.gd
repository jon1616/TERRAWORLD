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
##   allies     alleati in più dai bastoni evocatori (`GearEffects.allies`)
##   air_jumps  salti in aria (`Player.air_jumps`); wall: scivolare e saltare sulle pareti (`Player.wall_climb`)
##   dash       voce 127, la schivata (`Player.dash_ok`); dash_cd: × la sua ricarica
##   fish_*     voce 122, la pesca (`Fishing.gear`): fish_luck +, fish_wait ×, fish_size +, fish_double +, fish_any
##   grow, herd, pulsi  Roadmap 20 (i gradi dei pilastri): l'orto cresce ×, la mandria prende esperienza ×, le sorgenti
##              della rete danno × (`Garden.gear_grow`, `Herd.xp_mult`, `EnergyStorm.gear_pulsi`)
##   defense    Scorza in più (`Vitals.set_scorza`: set, gioielli, il carattere dei materiali); quella dei pezzi la
##              somma `Bisaccia.scorza`
## Voce 306: anche l'arma o l'attrezzo in mano dà il carattere del suo materiale (campo `mano`, `FormsData.item`): si
## ricalcola quando cambia l'oggetto scelto nella barra rapida.

const MULT := ["run", "jump", "halo", "regen", "dig", "stealth", "damage", "atk_speed", "linfa_regen", "magic", "respiro", "vento",
	"fish_wait", "dash_cd", "grow", "herd", "pulsi",
	# Roadmap 44, voce 389: il danno di ogni stile (elmi e set degli stili), moltiplica l'arma di quello stile in mano
	"st_mischia", "st_distanza", "st_linfa", "st_evocazione", "st_lancio", "st_canto", "st_cura", "st_radice"]

var m: Node2D
var sets: Array = []                   # i set completi indossati (per l'interfaccia)
var relics: Array = []                 # le collezioni di reliquie complete
var series: Array = []                 # voce 98: le serie di oggetti unici complete
var allies := 0                        # alleati in più insieme (voce 37, letto da `Companions`)


func setup(main: Node2D) -> void:
	m = main
	m.character.bisaccia.changed.connect(refresh)
	if m.get("hud") != null:
		m.hud.selected.connect(func(_it: Dictionary) -> void: refresh())     # voce 306: l'oggetto in mano
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
	e["allies"] = 0.0
	e["wall"] = false
	e["fall_safe"] = false
	for k in ["caldo", "acqua", "fresco", "filtro", "quota", "quieto"]:
		e[k] = 0.0                                 # voce 93: le protezioni dai rigori
	e["passo"] = false
	for k in ["fish_luck", "fish_size", "fish_double"]:
		e[k] = 0.0                                 # voce 122: la pesca
	e["fish_any"] = false
	e["dash"] = false                              # voce 127: la schivata
	var b: Bisaccia = m.character.bisaccia
	for slot in b.equip:
		_add(e, ItemsData.get_item(String(b.equip[slot])).get("acc", {}))
		var worn := b._worn(slot)                  # voce 54: il tratto e gli innesti del pezzo
		for k in ["run", "halo", "regen", "stealth"]:
			e[k] = float(e[k]) * Gear.effect(worn, k)
		e["luck"] = float(e["luck"]) + Gear.effect(worn, "luck")
		for k in ArmorData.WORN_KEYS:                # voce 391: le essenze della forgia sui pezzi d'armatura
			var ek := String(ArmorData.WORN_KEYS[k])
			e[ek] = float(e[ek]) * Gear.effect(worn, String(k))
		e["thorns"] = float(e["thorns"]) + Gear.effect(worn, "thorns")
	# voce 306: il carattere del materiale dell'arma o dell'attrezzo in mano
	if m.get("hud") != null:
		_add(e, ItemsData.get_item(b.id_at(m.hud.sel)).get("mano", {}))
	sets = SetsData.complete(b.equip)
	for s in sets:
		_add(e, SetsData.all()[s]["bonus"])
	# le collezioni di reliquie complete (voce 28): per sempre, trovate una volta
	relics = RelicsData.complete(m.character.erbario.get("oggetti", {}))
	for c in relics:
		_add(e, RelicsData.COLLECTIONS[c]["bonus"])
	# voce 98: le serie di oggetti unici complete, per sempre
	series = UniqueSeriesData.complete(m.character.erbario.get("oggetti", {}))
	for sr in series:
		_add(e, UniqueSeriesData.SERIES[sr]["bonus"])
	# voce 233: le grandi opere del Giardino (crescita dell'orto, Vita)
	for wk in ProjectsData.works_built(m.character.stats):
		var eff := {}
		for k in wk:
			if k in MULT:
				eff[k] = wk[k]
		_add(e, eff)
	# voce 253: le sale complete del Museo
	for mb in Museum.bonuses(m.character.stats):
		_add(e, mb)
	# Roadmap 20: i gradi della maestria dei pilastri, per sempre
	for mb in MasteryRewards.bonuses(m.character.maestria):
		_add(e, mb)
	# voce 64: i poteri dell'Albero-Madre
	if m.powers != null:
		for pb in m.powers.bonuses():
			_add(e, pb)
	# voce 59: i doni della mandria (chi ti segue, chi cavalchi)
	if m.herd != null:
		for hb in m.herd.bonuses():
			_add(e, hb)
	# voce 398: le pozioni, le fiale e i piatti scritti come dati (`BoonsData`)
	if m.get("boons") != null:
		for ba in m.boons.data_accs():
			_add(e, ba)
	# voce 388: il dono piccolo dell'animaletto che ti segue
	if m.get("companions") != null and m.companions.pet != null:
		_add(e, CompanionsData.PETS.get(m.companions.pet.id, {}).get("acc", {}))
	m.player.run_mult = e["run"]
	m.player.jump_mult = e["jump"]
	m.player.glide = e["glide"]
	m.player.air_jumps = int(e["air_jumps"])
	allies = int(e["allies"])
	m.player.wall_climb = e["wall"]
	m.player.dash_ok = e["dash"]
	m.player.dash_cd_mult = e["dash_cd"]
	m.life.fall_safe = e["fall_safe"]
	m.boons.halo_mult = e["halo"]
	m.vitals.regen_mult = e["regen"]
	m.fauna.luck = e["luck"]
	m.combat.thorns = int(e["thorns"])
	Behavior.stealth = e["stealth"]
	if m.get("liquids") != null:
		m.liquids.breath_mult = e["respiro"]         # voce 73: le Branchie di muschio
	if m.get("weather") != null:
		m.weather.wind_mult = e["vento"]             # voce 75: il Mantello del vento
	m.actions.dig_mult = e["dig"]
	m.combat.dmg_mult = e["damage"]
	m.combat.spd_mult = e["atk_speed"]
	m.vitals.linfa_regen_mult = e["linfa_regen"]
	m.combat.magic_mult = e["magic"]
	# voce 389: lo stile dell'arma in mano decide quale bonus di stile vale; gli alleati degli scettri il loro
	var held_style := StylesData.of_item(ItemsData.get_item(b.id_at(m.hud.sel))) if m.get("hud") != null else ""
	m.combat.style_mult = float(e.get("st_" + held_style, 1.0)) if held_style != "" else 1.0
	m.combat.ally_mult = e["st_evocazione"]
	if m.get("garden") != null:
		m.garden.gear_grow = e["grow"]           # Roadmap 20: i gradi dei pilastri
	if m.get("herd") != null:
		m.herd.xp_mult = e["herd"]
	EnergyStorm.gear_pulsi = e["pulsi"]
	m.vitals.set_scorza = roundi(float(e["defense"]))        # (voce 306: i pezzi ne danno anche un quarto)
	if m.get("fishing") != null:
		m.fishing.gear = {"luck": e["fish_luck"], "wait": e["fish_wait"], "size": e["fish_size"], "double": e["fish_double"],
			"any": e["fish_any"]}
	if m.get("harsh") != null:
		m.harsh.protect = {"caldo": e["caldo"], "acqua": e["acqua"], "fresco": e["fresco"], "filtro": e["filtro"],
			"quota": e["quota"], "quieto": e["quieto"]}
		m.harsh.passo = e["passo"]


## Somma un gruppo di effetti (di un pezzo o di un set) a quelli raccolti.
static func _add(e: Dictionary, acc: Dictionary) -> void:
	for k in acc:
		if k in MULT:
			e[k] = float(e[k]) * float(acc[k])
		elif k in ["luck", "thorns", "defense", "air_jumps", "allies", "caldo", "acqua", "fresco", "filtro", "quota", "quieto", "fish_luck", "fish_size",
				"fish_double"]:
			e[k] = float(e[k]) + float(acc[k])
		elif k in ["glide", "fall_safe", "wall", "passo", "fish_any", "dash"]:
			e[k] = bool(e[k]) or bool(acc[k])
