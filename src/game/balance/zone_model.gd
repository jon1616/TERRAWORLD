class_name ZoneModel
extends RefCounted
## Voce 179 (Roadmap 18): una zona intera secondo `FightModel`. Le creature che ci nascono (come `Fauna.try_spawn`:
## specie dello strato e del bioma, varianti di taglia, elemento e indole, rare, sciami), ognuna con il suo duello, e la
## media pesata come le nascite. Le creature che non feriscono (timide, pascolanti) non contano come scontri.
##
## `fight` restituisce:
##   pressure  Vita persa per ogni creatura sconfitta, in parte della Vita massima (0,15 = 15%): il numero guida
##   ttk       secondi per abbatterne una;  lost: Vita persa per scontro;  deadly: parte degli scontri in cui tre
##             contatti o meno fanno appassire;  hit: ferita media di un contatto;  n: specie contate
##   rare      parte degli scontri con una rara (antica, ancestrale, capobranco)

const SAMPLES := 10                    # varianti tirate per ogni specie
## Le creature si sommano: più il pericolo è alto più spesso ne arriva una mentre combatti con un'altra. L'arena (voce
## 180) dice che in tre insieme ogni creatura ferisce circa il doppio che da sola; la parte di scontri affollati cresce
## con il tetto di creature del pericolo (`DangerData.cap`).
const CROWD_PER_CAP := 0.08
const CROWD_MAX := 0.6
const CROWD_EXTRA := 1.2


## Quanto pesano le creature che arrivano insieme in una zona di quel pericolo.
static func crowd(dz: float) -> float:
	return 1.0 + clampf(CROWD_PER_CAP * (DangerData.cap(dz) - 1), 0.0, CROWD_MAX) * CROWD_EXTRA


## I biomi di superficie che nascono davvero (peso > 0).
static func surface_biomes() -> Array:
	var out := []
	for b in BiomesData.BIOMES:
		if int(b.get("weight", 0)) > 0:
			out.append(String(b["id"]))
	return out


## Le specie di uno strato con il loro peso (in superficie: la media dei biomi).
static func pool(stratum: int, night := false) -> Dictionary:
	var out := {}
	if stratum == 0:
		var bs := surface_biomes()
		for b in bs:
			for e in CreaturesData.of_stratum(0, night, b):
				out[String(e[0])] = float(out.get(String(e[0]), 0.0)) + float(e[1]) / bs.size()
	else:
		for e in CreaturesData.of_stratum(stratum, night, ""):
			out[String(e[0])] = float(out.get(String(e[0]), 0.0)) + float(e[1])
	return out


## Il pericolo di `DangerData` in quel posto (per le varianti e le rare).
static func danger(stratum: int, vigor: int, night := false) -> float:
	var d: float = DangerData.STRATUM[stratum]
	if stratum == 0 and night:
		d += DangerData.NIGHT
	return d + DangerData.VIGOR * (vigor - 1)


## Una zona: `loadout` = {"weapon": casella, "equip": {posto: casella}, "hp": Vita massima}.
static func fight(loadout: Dictionary, stratum: int, vigor: int, skill: Dictionary, night := false, sd := 18) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	var fx := FightModel.effects(loadout.get("equip", {}))
	var w := FightModel.weapon(loadout["weapon"], fx)
	var sc := int(fx["scorza"])
	var hp := float(loadout.get("hp", Vitals.HP_MAX))
	var dz := danger(stratum, vigor, night)
	var grade := VigorData.grade(vigor)
	var pl := pool(stratum, night)
	var crowd_k := crowd(dz)
	var acc := {"w": 0.0, "lost": 0.0, "ttk": 0.0, "deadly": 0.0, "hit": 0.0, "rare": 0.0, "n": 0}
	for id in pl:
		var base_w := float(pl[id])
		var g: Array = CreaturesData.get_data(String(id)).get("group", [])
		var size := (float(g[0]) + float(g[1])) / 2.0 if not g.is_empty() else 1.0
		for k in SAMPLES:
			var vid := FamiliesData.roll_variant(String(id), rng, "", dz, grade)
			var f := FightModel.foe(vid, stratum, vigor)
			if float(f["contact"]) <= 0.0 and (f["shots"] as Array).is_empty():
				continue
			var r := AncientData.roll_rarity(dz, rng, not g.is_empty())
			if r in ["antica", "ancestrale", "capobranco"]:
				f = FightModel.rare(f, r)
			var du := FightModel.duel(w, sc, hp, f, skill)
			var lost := float(du["lost"]) * crowd_k
			if size > 1.0:
				lost *= 1.0 + 0.5 * (size - 1.0) / size   # in sciame ti toccano in più d'uno (ogni compagna è uno scontro)
			var wt := base_w / SAMPLES * size
			acc["w"] = float(acc["w"]) + wt
			acc["lost"] = float(acc["lost"]) + wt * lost
			acc["ttk"] = float(acc["ttk"]) + wt * float(du["ttk"])
			acc["hit"] = float(acc["hit"]) + wt * float(du["hit"])
			acc["deadly"] = float(acc["deadly"]) + (wt if int(du["to_die"]) <= 3 else 0.0)
			acc["rare"] = float(acc["rare"]) + (wt if r != "" and r != "iridata" else 0.0)
		acc["n"] = int(acc["n"]) + 1
	var tw := maxf(float(acc["w"]), 0.0001)
	return {"pressure": float(acc["lost"]) / tw / hp, "lost": float(acc["lost"]) / tw, "ttk": float(acc["ttk"]) / tw,
		"hit": float(acc["hit"]) / tw, "deadly": float(acc["deadly"]) / tw, "rare": float(acc["rare"]) / tw, "n": int(acc["n"]),
		"scorza": sc, "dps": float(FightModel.duel(w, sc, hp, {"hp": 1.0, "contact": 0.0, "def": 0, "knock": 0.0,
			"behaviors": [], "shots": []}, skill)["dps"])}
