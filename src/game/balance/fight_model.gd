class_name FightModel
extends RefCounted
## Voce 179 (Roadmap 18 «Il bilancio»): le formule del combattimento in un posto solo, senza finestra. Le leggono gli
## strumenti (`tools/bilancio.gd`, `tools/percorso.gd`) e le prove (`TestsArena`, che confronta il modello con uno
## scontro vero). Le regole vere restano nel gioco e sono le stesse: `Vitals.reduce` (la Scorza), `Creature.through`
## (la difesa delle creature), `Gear.stats` (l'arma), `Creature.strengthen` come la chiama `Fauna` (strato e vigore).
##
## Un duello: il Germogliato con un equipaggiamento contro **una** creatura di uno strato e di un vigore. Chi gioca
## ha un'**abilità** (`SKILL`), tarata con il bot in arena (voce 180, prove/arena.txt del 29 set 2026: nel duello il bot
## prende 0,09 contatti al secondo e una sorpresa alle spalle vale +0,26 ferite; il tempo per abbattere torna al 20%):
##   uptime   parte dello scontro in cui l'arma colpisce davvero (avvicinarsi, inseguire, aspettare il salto)
##   touch    contatti al secondo di una creatura che viene addosso, quando non è ferma per i colpi (al più 1/INVULN)
##   open     ferite d'apertura per creatura (chi arriva mentre scavi o guardi altrove, le sorprese)
##   dodge    parte dei proiettili evitati
##   bow_hit  parte dei dardi e degli incantesimi che vanno a segno
## Il bot gioca bene ma senza sorprese; i profili umani (voce 181) sono il bot con gli errori di chi gioca davvero:
## «attento» come il bot, «medio» il doppio dei contatti e più sorprese, «jon» tarato sul Diario dell'utente.

const SKILL := {
	"bot": {"uptime": 0.52, "touch": 0.13, "open": 0.0, "dodge": 0.5, "bow_hit": 0.7},
	"attento": {"uptime": 0.55, "touch": 0.15, "open": 0.12, "dodge": 0.5, "bow_hit": 0.7},
	"medio": {"uptime": 0.5, "touch": 0.28, "open": 0.3, "dodge": 0.4, "bow_hit": 0.6},
	"jon": {"uptime": 0.48, "touch": 0.22, "open": 0.28, "dodge": 0.35, "bow_hit": 0.6},
}
## Quanto ogni comportamento cambia i contatti (1 = chi salta o cammina addosso). Tarati con l'arena (voce 180).
const TOUCH_K := {"salta_verso": 1.0, "cammina": 1.0, "caccia": 1.0, "vola": 0.8, "carica": 1.25, "scatto": 1.2,
	"picchiata": 0.9, "agguato": 0.9, "scava": 0.9, "sbuca": 0.8, "teletrasporto": 0.8, "spara": 0.35, "ventaglio": 0.35,
	"bombarda": 0.5, "folgore": 0.4, "fugge": 0.0, "pascola": 0.0, "mandria": 0.0, "evoca": 0.5, "deriva": 0.7}
## I proiettili dei comportamenti: [parametro della cadenza, cadenza di base, colpi per raffica, danno di base, parte della
## raffica che può prendere il Germogliato]
const SHOTS := {"spara": ["rate", 2.5, 1, 10, 1.0], "ventaglio": ["fan_rate", 3.0, 5, 12, 0.35],
	"bombarda": ["rate", 2.0, 1, 12, 1.0], "folgore": ["bolt_every", 5.0, 1, -1, 1.0]}
const DART := 4                        # il dardo semplice (`Combat.AMMO`)
const MELEE_REACH := 2.0               # tessere: chi colpisce da lontano (lance, fruste) prende meno contatti


## Gli effetti di un equipaggiamento (posto → casella), come `GearEffects`: danno, colpi, Scorza dei set e dei pezzi.
static func effects(equip: Dictionary) -> Dictionary:
	var e := {}
	for k in GearEffects.MULT:
		e[k] = 1.0
	for k in ["luck", "thorns", "defense", "air_jumps", "allies", "caldo", "acqua", "fresco", "filtro", "quota", "fish_luck",
			"fish_size", "fish_double"]:
		e[k] = 0.0
	for k in ["glide", "fall_safe", "wall", "passo", "fish_any", "dash"]:
		e[k] = false
	var ids := {}
	var pieces := 0.0
	for slot in equip:
		var it: Variant = equip[slot]
		var cell: Dictionary = it if it is Dictionary else {"id": String(it)}
		if String(cell.get("id", "")) == "":
			continue
		ids[slot] = String(cell["id"])
		GearEffects._add(e, ItemsData.get_item(String(cell["id"])).get("acc", {}))
		pieces += float(Gear.stats(cell)["defense"])
	for s in SetsData.complete(ids):
		GearEffects._add(e, SetsData.all()[s]["bonus"])
	e["scorza"] = roundi(pieces) + int(e["defense"])
	return e


## L'arma: danno per colpo, colpi al secondo, se tira da lontano, spinta, portata.
static func weapon(cell: Dictionary, fx: Dictionary = {}) -> Dictionary:
	var id := String(cell.get("id", ""))
	var it := ItemsData.get_item(id)
	var st := Gear.stats(cell)
	var dmg_k := float(fx.get("damage", 1.0))
	var spd_k := float(fx.get("atk_speed", 1.0))
	var use := ItemsData.use_of(id)
	var w := {"id": id, "ranged": false, "knock": float(st["knockback"]), "reach": 1.0, "linfa": 0.0}
	match use:
		"colpo":
			w["dmg"] = float(st["damage"]) * dmg_k
			w["rate"] = maxf(float(st["speed"]), 0.1) * spd_k
			var f := String(it.get("form", ""))
			if f in ["lancia", "frusta"]:
				w["reach"] = MELEE_REACH
		"scava", "abbatti":
			w["dmg"] = float(st["damage"]) * dmg_k
			w["rate"] = 1.0 / Combat.DIG_PERIOD
		"tira":
			w["dmg"] = (float(st["damage"]) + DART) * dmg_k
			w["rate"] = maxf(float(st["speed"]), 0.1) * spd_k
			w["ranged"] = true
		"incanta":
			var sp: Dictionary = SpellsData.SPELLS.get(String(it.get("spell", "")), {})
			w["dmg"] = float(st["damage"]) * dmg_k * float(fx.get("magic", 1.0)) * maxf(float(sp.get("n", 1)) * 0.6, 1.0)
			w["rate"] = maxf(float(st["speed"]), 0.1) * spd_k
			w["linfa"] = float(it.get("linfa", 0))
			w["ranged"] = true
		_:
			w["dmg"] = 0.0
			w["rate"] = 0.0
	return w


## Una creatura come la fa nascere `Fauna` in uno strato (0-4) e a un vigore; `extra` = pericolo del cielo o dei totem.
static func foe(id: String, stratum: int, vigor: int, extra := 1.0) -> Dictionary:
	var d := CreaturesData.get_data(id)
	var mult := float(StrataData.STRATA[clampi(stratum, 0, StrataData.STRATA.size() - 1)]["danger"]) \
		* VigorData.creature_mult(vigor) * extra
	var f := stats_of(d, mult, mult * DangerData.DAMAGE)
	f["id"] = id
	return f


## Come `Creature.strengthen`: Vita e danno al contatto moltiplicati (i boss senza il 1,35 del pericolo).
static func stats_of(d: Dictionary, hp_mult: float, dmg_mult: float) -> Dictionary:
	var p: Dictionary = d.get("p", {})
	var f := {"id": String(d.get("id", "")), "name": String(d.get("name", "")), "hp": float(roundi(float(d["hp"]) * hp_mult)),
		"contact": float(roundi(float(d["damage"]) * dmg_mult)), "def": int(d.get("defense", 0)),
		"knock": float(d.get("knock", 0.0)), "behaviors": d.get("behaviors", []), "shots": []}
	for b in f["behaviors"]:
		if SHOTS.has(b):
			var s: Array = SHOTS[b]
			var base_dmg := float(p.get("bolt_damage", d["damage"])) if int(s[3]) < 0 else float(p.get("shot_damage", s[3]))
			f["shots"].append({"every": float(p.get(String(s[0]), s[1])), "n": int(p.get("fan_n", s[2])) if b == "ventaglio" else 1,
				"dmg": base_dmg * shot_mult(dmg_mult), "share": float(s[4])})
	return f


## Quanto crescono i proiettili con strato e vigore (oggi non crescono: voce 185).
static func shot_mult(_dmg_mult: float) -> float:
	return 1.0


## Una creatura rara (`AncientData.RARITIES`): più Vita e più danno.
static func rare(f: Dictionary, rarity: String) -> Dictionary:
	var r: Dictionary = AncientData.RARITIES[rarity]
	var out := f.duplicate(true)
	out["hp"] = roundf(float(f["hp"]) * float(r["hp"]))
	out["contact"] = roundf(float(f["contact"]) * maxf(float(r["damage"]), 0.0))
	return out


## Il contatto al secondo che una creatura porta, secondo i suoi comportamenti.
static func touch_k(f: Dictionary) -> float:
	var k := 1.0
	var any := false
	for b in f["behaviors"]:
		if TOUCH_K.has(b):
			k = float(TOUCH_K[b]) if not any else maxf(k, float(TOUCH_K[b]))
			any = true
	return k


## Il duello. `sc` = Scorza totale, `hp` = Vita massima. Restituisce: ttk (secondi per abbatterla), lost (Vita persa),
## hit (ferita di un contatto), to_die (contatti per appassire), dps (danno al secondo del Germogliato).
static func duel(w: Dictionary, sc: int, hp: float, f: Dictionary, skill: Dictionary) -> Dictionary:
	var per_hit := float(Creature.through(roundi(float(w["dmg"])), int(f["def"])))
	var up := float(skill["bow_hit"]) if bool(w["ranged"]) else float(skill["uptime"])
	var rate := float(w["rate"])
	if float(w["linfa"]) > 0.0:
		rate = minf(rate, Vitals.LINFA_REGEN * 1.6 / float(w["linfa"]))   # la Linfa finisce: si tira con quella che ricresce
	var dps := per_hit * rate * up
	var ttk := float(f["hp"]) / maxf(dps, 0.01)
	# ogni colpo ferma la creatura per un attimo: chi colpisce spesso la tiene lontana
	var stunned := clampf(Creature.HIT_STUN * rate * up, 0.0, 0.85)
	var touch := float(skill["touch"]) * touch_k(f) * (1.0 - stunned)
	if bool(w["ranged"]):
		touch *= 0.5                   # tirando si tiene la distanza, ma non sempre
	elif float(w["reach"]) > 1.0:
		touch *= 0.75
	touch *= 1.0 / (1.0 + float(w["knock"]) * (1.0 - float(f["knock"])) * 0.06)   # la spinta allontana
	var hit := float(Vitals.reduce(int(f["contact"]), sc)) if float(f["contact"]) > 0.0 else 0.0
	var in_rate := touch if hit > 0.0 else 0.0
	var in_dps := touch * hit
	var opening := float(skill.get("open", 0.0)) * minf(touch_k(f), 1.0) * hit
	for s in f["shots"]:
		var r := float(s["n"]) * float(s["share"]) * (1.0 - float(skill["dodge"])) / float(s["every"])
		in_rate += r
		in_dps += r * float(Vitals.reduce(roundi(float(s["dmg"])), sc))
	# dopo una ferita si è intoccabili per un poco: le ferite al secondo hanno un tetto
	var cap := 1.0 / Combat.INVULN
	if in_rate > cap:
		in_dps *= cap / in_rate
	var worst := maxf(hit, 1.0)
	return {"ttk": ttk, "lost": in_dps * ttk + opening, "hit": hit, "to_die": ceili(hp / worst), "dps": dps, "in_dps": in_dps}
