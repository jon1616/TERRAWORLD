extends SceneTree
## Voce 181 (Roadmap 18 «Il bilancio»): il giocatore simulato. Tre profili attraversano la partita a tappe (Superficie,
## prima notte, Sottobosco, Caverne, Profondità, Fondo, poi i mondi di vigore 2, 3, 5, 8, 12) e in ogni tappa giocano
## i suoi minuti: le creature arrivano come le fa nascere `Fauna` (specie, varianti, rare, sciami, scontri affollati del
## pericolo), ogni scontro toglie la Vita secondo `FightModel` (con il caso: le ferite sono contate una a una), tra uno
## scontro e l'altro la Vita ricresce come in `Vitals`, sotto un terzo della Vita chi ce l'ha beve una pozione, e sotto
## zero si appassisce e si ricomincia con la Vita piena. Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/percorso.gd -- [--giri 30]
## Scrive prove/percorso.txt e lo stampa.
##
## I profili (l'abilità è in `FightModel.SKILL`):
##   jon      l'utente (partita del 28-29 set 2026, dal Diario): l'arma migliore che trova ma **nessuna armatura**,
##            niente pozioni, esplora molto (più sorprese). Tarato sui suoi 4 appassimenti in 67 minuti.
##   medio    un umano medio: l'arma del suo grado, l'armatura di un grado sotto, a volte una pozione
##   attento  chi si equipaggia bene: arma e armatura del grado, pozioni
## Tutti, quando la Vita scende sotto la loro soglia («rest»: 20% jon, 35% medio, 50% attento), si fermano al riparo di
## una torcia finché la Vita non torna quasi piena (il tempo passa, ma niente scontri); la parte di tempo passata così
## è scritta come «riposo».
## L'obiettivo della Roadmap 18: «attento» con pressione bassa all'inizio che sale piano; «medio» con qualche
## appassimento all'ora dalle Caverne in poi; «jon» senza armatura che sente il muro.

const MATS := ["", "radicite", "legnoferro", "ambra", "linfa", "vuoto", "stellare"]
## Le tappe: nome, zone [[strato, vigore, notte, parte del tempo]], minuti, grado del metallo che si ha, Vita massima
## attesa (doni del Cuore di bocciolo, Guardiani curati), livelli di tempra. Il metallo: la linfa e il vuoto vogliono un
## materiale dei Guardiani (linfa dopo il primo, vuoto dopo il secondo), lo stellare le Schegge dei mondi di grado 1
## (vigore 5+); la tempra si fa fino a 2 livelli per grado del mondo (`VigorData.TEMPER_PER_GRADE`).
const STAGES := [
	["Primi passi (giorno)", [[0, 1, false, 1.0]], 15, 0, 100, 0],
	["La prima notte", [[0, 1, true, 1.0]], 10, 1, 100, 0],
	["Sottobosco", [[1, 1, false, 0.7], [0, 1, false, 0.3]], 20, 1, 100, 0],
	["Caverne", [[2, 1, false, 0.7], [1, 1, false, 0.3]], 25, 2, 110, 0],
	["Profondità", [[3, 1, false, 0.7], [2, 1, false, 0.3]], 25, 3, 120, 0],
	["Fondo (vigore 1)", [[4, 1, false, 0.7], [3, 1, false, 0.3]], 20, 3, 130, 0],
	["Mondo di vigore 2", [[2, 2, false, 0.3], [3, 2, false, 0.3], [4, 2, false, 0.4]], 40, 4, 160, 0],
	["Mondo di vigore 3", [[3, 3, false, 0.4], [4, 3, false, 0.6]], 40, 5, 190, 0],
	["Mondo di vigore 5", [[3, 5, false, 0.4], [4, 5, false, 0.6]], 40, 5, 240, 2],
	["Mondo di vigore 8", [[4, 8, false, 1.0]], 40, 6, 290, 2],
	["Mondo di vigore 12", [[4, 12, false, 1.0]], 40, 6, 350, 4],
]
## Creature affrontate al minuto con pericolo 1 (tarato sull'utente: 80 creature in 67 minuti, quasi tutte in
## Superficie e nel Sottobosco); crescono con la radice del pericolo della zona.
const PACE := 1.1
const POTION := 50                     # la Pozione di rugiada

const PROFILES := {
	"jon": {"weapon": "pugnale", "armor": -99, "potions": 0.0, "rest": 0.2},
	"medio": {"weapon": "spada", "armor": -1, "potions": 0.5, "rest": 0.35},
	"attento": {"weapon": "spada", "armor": 0, "potions": 1.0, "rest": 0.5},
}

var out := ""
var rng := RandomNumberGenerator.new()
var _zone_cache := {}


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var runs := 20
	var i := args.find("--giri")
	if i >= 0 and i + 1 < args.size():
		runs = int(args[i + 1])
	rng.seed = 181
	_p("PERCORSO (voce 181): %d giri per tappa. Per profilo: pressione media (Vita persa per creatura, %% della Vita)," % runs)
	_p("   appassimenti all'ora, secondi per abbattere, creature al minuto; «!» = sopra la fascia voluta")
	for pr in PROFILES:
		_p("")
		_p("== %s ==" % pr)
		var total_deaths := 0.0
		var total_min := 0.0
		for st in STAGES:
			var r := _stage(String(pr), st, runs)
			total_deaths += float(r["deaths"])
			total_min += float(st[2])
			_p("   %-22s %-24s pressione %4.0f%%  appassimenti/ora %4.1f%s  riposo %2.0f%%  abbatte in %4.1f s  (%s)" % [st[0],
				String(r["gear"]).left(24), float(r["pressure"]) * 100.0, float(r["deaths"]) * 60.0 / float(st[2]),
				" !" if float(r["deaths"]) * 60.0 / float(st[2]) > 3.0 else "  ", float(r["rest"]) * 100.0, float(r["ttk"]), r["note"]])
		_p("   in tutto: %.1f appassimenti in %d minuti (%.1f all'ora)" % [total_deaths, int(total_min), total_deaths * 60.0 / total_min])
	var f := FileAccess.open("res://prove/percorso.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)
	quit()


func _p(s: String) -> void:
	print(s)
	out += s + "\n"


## L'equipaggiamento di un profilo in una tappa.
func _loadout(pr: String, st: Array) -> Dictionary:
	var p: Dictionary = PROFILES[pr]
	var t: int = int(st[3])
	var wid := "spada_radice" if t == 0 else "%s_%s" % [String(p["weapon"]), MATS[t]]
	var weapon := {"id": wid}
	var tp := int(st[5])
	if tp > 0:
		weapon["dati"] = {"tempra": tp}
	var eq := {}
	var at := t + int(p["armor"])
	if at >= 1:
		for piece in ["elmo", "corazza", "gambali", "guanti", "stivali"]:
			var id := "%s_%s" % [piece, MATS[at]]
			if not ItemsData.get_item(id).is_empty():
				eq[piece] = {"id": id, "dati": {"tempra": tp}} if tp > 0 else {"id": id}
	var gear: String = wid.replace("_", " ") + (" + " + MATS[at] if at >= 1 else ", senza armatura")
	return {"weapon": weapon, "equip": eq, "hp": float(st[4]), "gear": gear}


## Le creature di una zona già pronte per il caso: [peso, scontro {lost, ttk, hit}] (varianti e rare comprese).
func _zone(pr: String, lo: Dictionary, z: Array) -> Array:
	var key := "%s|%s|%s" % [pr, lo["gear"], str(z)]
	if _zone_cache.has(key):
		return _zone_cache[key]
	var s := int(z[0])
	var v := int(z[1])
	var night := bool(z[2])
	var skill: Dictionary = FightModel.SKILL[pr]
	var fx := FightModel.effects(lo["equip"])
	var w := FightModel.weapon(lo["weapon"], fx)
	var sc := int(fx["scorza"])
	var dz := ZoneModel.danger(s, v, night)
	var crowd := ZoneModel.crowd(dz)
	var pl := ZoneModel.pool(s, night, v)
	var list := []
	var r2 := RandomNumberGenerator.new()
	r2.seed = 7
	for id in pl:
		var g: Array = CreaturesData.get_data(String(id)).get("group", [])
		var size := (float(g[0]) + float(g[1])) / 2.0 if not g.is_empty() else 1.0
		for k in 8:
			var f := FightModel.foe(FamiliesData.roll_variant(String(id), r2, "", dz, VigorData.grade(v)), s, v)
			if float(f["contact"]) <= 0.0 and (f["shots"] as Array).is_empty():
				continue
			var rr := AncientData.roll_rarity(dz, r2, not g.is_empty())
			if rr in ["antica", "ancestrale", "capobranco"]:
				f = FightModel.rare(f, rr)
			var du := FightModel.duel(w, sc, float(lo["hp"]), f, skill)
			var lost := float(du["lost"]) * crowd * (1.0 + 0.5 * (size - 1.0) / size)
			list.append([float(pl[id]) * size / 8.0, {"lost": lost, "ttk": float(du["ttk"]), "hit": maxf(float(du["hit"]), 1.0),
				"size": size, "rare": rr != ""}])
	_zone_cache[key] = list
	return list


func _pick(list: Array) -> Dictionary:
	var tot := 0.0
	for e in list:
		tot += float(e[0])
	var r := rng.randf() * tot
	for e in list:
		r -= float(e[0])
		if r <= 0.0:
			return e[1]
	return list[-1][1]


## Poisson (Knuth) per le ferite di uno scontro.
func _poisson(mean: float) -> int:
	if mean <= 0.0:
		return 0
	if mean > 30.0:
		return maxi(roundi(rng.randfn(mean, sqrt(mean))), 0)
	var l := exp(-mean)
	var k := 0
	var p := 1.0
	while true:
		p *= rng.randf()
		if p <= l:
			return k
		k += 1
	return k


## Una tappa giocata `runs` volte: {pressure, deaths (per giro), ttk, gear, note}.
func _stage(pr: String, st: Array, runs: int) -> Dictionary:
	var lo := _loadout(pr, st)
	var prof: Dictionary = PROFILES[pr]
	var fx := FightModel.effects(lo["equip"])
	var regen := Vitals.REGEN * float(lo["hp"]) / Vitals.HP_MAX * float(fx["regen"])
	var hp_max := float(lo["hp"])
	var deaths := 0
	var lost_sum := 0.0
	var fights := 0
	var ttk_sum := 0.0
	var rare_n := 0
	var cause := {"rara": 0, "sciame": 0, "comune": 0}
	var rest_t := 0.0
	for run in runs:
		for z in st[1]:
			var list := _zone(pr, lo, z)
			if list.is_empty():
				continue
			var secs := float(st[2]) * 60.0 * float(z[3])
			var dz := ZoneModel.danger(int(z[0]), int(z[1]), bool(z[2]))
			var rate := PACE * sqrt(dz) / 60.0          # creature al secondo
			var hp := hp_max
			var t := 0.0
			var potion_t := 0.0
			while t < secs:
				var gap := -log(maxf(rng.randf(), 0.0001)) / rate
				# la Vita ricresce dopo l'attesa senza ferite
				hp = minf(hp + maxf(gap - Vitals.REGEN_DELAY, 0.0) * regen, hp_max)
				t += gap
				potion_t -= gap
				var e := _pick(list)
				var hits := _poisson(float(e["lost"]) / float(e["hit"]))
				var lost := hits * float(e["hit"])
				lost_sum += lost / float(e["size"])
				fights += 1
				ttk_sum += float(e["ttk"])
				if bool(e["rare"]):
					rare_n += 1
				t += float(e["ttk"]) * float(e["size"])
				# a un terzo della Vita, chi ha pozioni beve (una ogni 30 s)
				var left := hp - lost
				if left > 0.0 and left < hp_max / 3.0 and potion_t <= 0.0 and rng.randf() < float(prof["potions"]):
					left = minf(left + POTION, hp_max)
					potion_t = Vitals.POTION_COOLDOWN
				elif left <= 0.0 and potion_t <= 0.0 and rng.randf() < float(prof["potions"]) * 0.5:
					left = minf(hp - lost * 0.5 + POTION, hp_max)   # a volte la pozione arriva in tempo, a metà scontro
					potion_t = Vitals.POTION_COOLDOWN
				hp = left
				if hp > 0.0 and hp < hp_max * float(prof["rest"]):
					var need := Vitals.REGEN_DELAY + (hp_max * 0.9 - hp) / regen
					rest_t += need
					t += need
					hp = hp_max * 0.9
				if hp <= 0.0:
					deaths += 1
					var ck := "rara" if bool(e["rare"]) else ("sciame" if float(e["size"]) > 1.0 else "comune")
					cause[ck] = int(cause[ck]) + 1
					hp = hp_max
					t += 20.0                           # si torna al punto di rinascita
	return {"pressure": lost_sum / maxi(fights, 1) / hp_max, "deaths": float(deaths) / runs, "ttk": ttk_sum / maxi(fights, 1),
		"gear": lo["gear"], "rest": rest_t / (runs * float(st[2]) * 60.0), "note": "%.1f creature/min, rare %.0f%%; appassimenti da rare %d, sciami %d, comuni %d" % [
			float(fights) / runs / float(st[2]), 100.0 * rare_n / maxi(fights, 1), int(cause["rara"]), int(cause["sciame"]),
			int(cause["comune"])]}
