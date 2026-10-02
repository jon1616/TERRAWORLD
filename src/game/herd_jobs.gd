class_name HerdJobs
extends RefCounted
## I lavori della mandria (Roadmap 24, voce 243): una creatura del recinto può lavorare (`rec["lavoro"]`, pulsante
## «Lavoro» del pannello). Chi lavora ha fame `HUNGER` volte più in fretta e prende esperienza.
##   aratura   le colture entro `PLOW_R` tessere dal recinto crescono di `PLOW` in più per ogni creatura che ara (al più 2)
##   cerca     ogni `FIND_SECS` secondi trova qualcosa secondo il ruolo della sua famiglia (`FINDS`), nella mangiatoia;
##             anche a gioco chiuso, come la produzione
##   canto     le altre creature del recinto producono come se avessero un'amica in più
## `Pens.tick` chiama `work`; `Garden.grow` chiede `plow_at` (le posizioni le raccoglie `Pens` a ogni giro).

const JOBS := {
	"aratura": {"name": "Aratura", "desc": "le colture vicine al recinto crescono di più"},
	"cerca": {"name": "Cerca", "desc": "trova qualcosa ogni tanto e lo lascia nella mangiatoia"},
	"canto": {"name": "Canto", "desc": "le altre creature del recinto producono di più"},
}
const ORDER := ["", "aratura", "cerca", "canto"]
const HUNGER := 1.5
const PLOW_R := 24.0
const PLOW := 0.2
const FIND_SECS := 480.0
## Che cosa trova chi cerca, secondo il ruolo della famiglia: [oggetto, quanti min, max, peso].
const FINDS := {
	"erbivoro": [["seme_lanterna", 1, 2, 3], ["fungo_luminoso", 1, 3, 3], ["humus", 4, 8, 2], ["bacca_rovo", 1, 3, 1]],
	"predatore": [["minerale_radicite", 2, 4, 3], ["minerale_legnoferro", 1, 3, 2], ["gelatina", 1, 3, 2], ["minerale_ambra", 1, 2, 1]],
	"volante": [["seta_radice", 1, 2, 3], ["gelatina", 1, 3, 2], ["polvere_iridata", 1, 1, 1]],
	"scavatore": [["minerale_legnoferro", 2, 4, 3], ["minerale_ambra", 1, 3, 2], ["cristallo_linfa", 1, 1, 1]],
	"_": [["humus", 3, 6, 3], ["fungo_luminoso", 1, 2, 2], ["seme_lanterna", 1, 1, 1]],
}


static func job_of(rec: Dictionary) -> String:
	return String(rec.get("lavoro", ""))


## Il lavoro dopo (il pulsante li fa girare). Solo chi vive nel recinto lavora.
static func next_job(rec: Dictionary) -> String:
	if rec["stato"] != "recinto":
		return "Solo le creature nel recinto lavorano"
	var i := ORDER.find(job_of(rec))
	var j := String(ORDER[(i + 1) % ORDER.size()])
	rec["lavoro"] = j
	rec["cerca"] = 0.0
	if j == "":
		return "%s non lavora più" % rec["nome"]
	return "%s ora fa: %s (%s)" % [rec["nome"], JOBS[j]["name"], JOBS[j]["desc"]]


## Un passo di lavoro nel recinto (da `Pens.tick`). `chest` è la mangiatoia.
static func work(m: Node2D, rec: Dictionary, chest: Bisaccia, dt: float, rng: RandomNumberGenerator) -> void:
	var j := job_of(rec)
	if j == "":
		return
	rec["fame"] = minf(float(rec["fame"]) + HerdData.HUNGER_RATE * dt * (HUNGER - 1.0) * Herd.hunger_k(), 1.0)
	if float(rec["fame"]) >= 0.8:
		return                                  # affamata non lavora
	if j == "cerca":
		rec["cerca"] = float(rec.get("cerca", 0.0)) + dt
		if float(rec["cerca"]) >= FIND_SECS:
			var f := find(rec, rng)
			if chest.add(String(f[0]), int(f[1])) == 0:
				rec["cerca"] = float(rec["cerca"]) - FIND_SECS
				m.herd.gain_xp(rec, 2, true)
				m.objectives.bump("ritrovamenti")
			else:
				rec["cerca"] = FIND_SECS            # la mangiatoia è piena
	else:
		rec["job_xp"] = float(rec.get("job_xp", 0.0)) + dt
		if float(rec["job_xp"]) >= 120.0:
			rec["job_xp"] = float(rec["job_xp"]) - 120.0
			m.herd.gain_xp(rec, 1, true)


## Che cosa trova una creatura: [oggetto, quanti].
static func find(rec: Dictionary, rng: RandomNumberGenerator) -> Array:
	var role := String(FamiliesData.FAMILIES.get(Herd.family_of(rec), {}).get("role", ""))
	var pool: Array = FINDS.get(role, FINDS["_"])
	var tot := 0
	for e in pool:
		tot += int(e[3])
	var x := rng.randi_range(1, tot)
	for e in pool:
		x -= int(e[3])
		if x <= 0:
			return [String(e[0]), rng.randi_range(int(e[1]), int(e[2]))]
	return [String(pool[0][0]), 1]


## Quante creature cantano nel recinto (per la produzione delle altre).
static func singers(members: Array, rec: Dictionary) -> int:
	var n := 0
	for r in members:
		if r != rec and job_of(r) == "canto" and float(r["fame"]) < 0.8:
			n += 1
	return n


## La crescita in più delle colture in una cella, dalle creature che arano (`plows`: le celle dei recinti, una per aratrice).
static func plow_at(plows: Array, c: Vector2i) -> float:
	var n := 0
	for p in plows:
		if Vector2(c - (p as Vector2i)).length() <= PLOW_R:
			n += 1
	return 1.0 + PLOW * mini(n, 2)
