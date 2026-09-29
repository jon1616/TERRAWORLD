class_name NpcWork
extends RefCounted
## I mestieri degli abitanti (Roadmap 22, voce 232): chi ha una bottega (`JOBS`) lavora per te. Gli si lasciano i
## materiali di un lavoro (fino a `MAX_BATCH` volte), e dopo un tempo (l'orologio vero: va avanti anche mentre sei via o
## a gioco chiuso) si ritirano i prodotti. Più affetto, meno tempo (`SPEED` per livello). Stato nel mondo del Giardino:
## `world_meta["botteghe"][abitante]` = {"job", "n", "fine"}. Solo regole; il bottone sta in `TradePanel`.
##   JOBS: abitante → [[materiali, prodotto, quanti, minuti], …]

const MAX_BATCH := 5
const SPEED := 0.08                    # −8% di tempo per livello d'affetto

const JOBS := {
	"viandante": [[{"legno": 10, "gelatina": 2}, "torcia", 30, 5]],
	"erborista": [[{"fungo_luminoso": 4, "gelatina": 2}, "pozione_rugiada", 3, 10]],
	"forgiatore": [[{"minerale_legnoferro": 6}, "lingotto_legnoferro", 3, 8], [{"minerale_ambra": 6}, "lingotto_ambra", 3, 12]],
	"vecchia_radice": [[{"humus": 30}, "seme_rugiada", 5, 20]],
	"mercante_semi": [[{"humus": 20, "lumino": 150}, "provetta", 3, 15]],
	"mandriano": [[{"legno": 20, "humus": 10}, "vasetto", 2, 15]],
	"pescatore": [[{"squama_lume": 4}, "esca_squama", 10, 10]],
	"palombara": [[{"guscio_lago": 3}, "esca_iridata", 5, 20]],
	"fabbro_radici": [[{"lingotto_legnoferro": 1, "legno": 2}, "vena_legnoferro", 20, 10]],
	"guardaboschi": [[{"bacca_rovo": 4, "miele_lume": 1}, "marmellata_rovo", 3, 15]],
	"cantastorie": [[{"eco_parola": 2}, "tavoletta_seminatori", 1, 30]],
	"tessitrice": [[{"seta_radice": 1, "gelatina": 1}, "filo_turchese", 30, 10]],
	"innestatrice": [[{"cristallo_linfa": 3}, "linfa_antica", 1, 60]],
	"cartografo": [[{"tavoletta_seminatori": 2}, "mappa_seminatori", 1, 30]],
}


static func has_shop(npc: String) -> bool:
	return JOBS.has(npc)


static func _all(meta: Dictionary) -> Dictionary:
	if not meta.has("botteghe"):
		meta["botteghe"] = {}
	return meta["botteghe"]


static func order(meta: Dictionary, npc: String) -> Dictionary:
	return _all(meta).get(npc, {})


## Minuti di un lavoro con l'affetto di adesso.
static func minutes(ch: Character, npc: String, job: int) -> float:
	return float(JOBS[npc][job][3]) * (1.0 - SPEED * NpcBonds.level(ch, npc))


## Quante volte si può fare il lavoro con ciò che si ha (Bisaccia e casse vicine), al più `MAX_BATCH`.
static func batches(ch: Character, npc: String, job: int) -> int:
	var n := MAX_BATCH
	var need: Dictionary = JOBS[npc][job][0]
	for it in need:
		n = mini(n, Crafting.have(ch.bisaccia, String(it)) / int(need[it]))
	return n


## Lascia i materiali del primo lavoro che si può fare (o di `job`). Restituisce il testo per l'avviso ("" se niente).
static func start(meta: Dictionary, ch: Character, npc: String, job := -1) -> String:
	if not has_shop(npc) or not order(meta, npc).is_empty():
		return ""
	var jobs: Array = JOBS[npc]
	for j in jobs.size():
		if job >= 0 and j != job:
			continue
		var n := batches(ch, npc, j)
		if n <= 0:
			continue
		var need: Dictionary = jobs[j][0]
		for it in need:
			Crafting.take(ch.bisaccia, String(it), int(need[it]) * n)
		var secs := minutes(ch, npc, j) * 60.0
		_all(meta)[npc] = {"job": j, "n": n, "fine": Time.get_unix_time_from_system() + secs}
		return "Al lavoro: %d %s tra %d minuti" % [int(jobs[j][2]) * n, ItemsData.get_item(String(jobs[j][1])).get("name", jobs[j][1]),
			ceili(secs / 60.0)]
	return ""


## Secondi che mancano (0 = pronto; -1 = nessun lavoro).
static func left(meta: Dictionary, npc: String) -> float:
	var o := order(meta, npc)
	if o.is_empty():
		return -1.0
	return maxf(float(o["fine"]) - Time.get_unix_time_from_system(), 0.0)


## Ritira i prodotti se sono pronti: {oggetto: quanti} ({} se non ancora).
static func collect(meta: Dictionary, npc: String) -> Dictionary:
	if left(meta, npc) != 0.0:
		return {}
	var o := order(meta, npc)
	var jb: Array = JOBS[npc][int(o["job"])]
	_all(meta).erase(npc)
	return {String(jb[1]): int(jb[2]) * int(o["n"])}


## La scritta del bottone della bottega.
static func label(meta: Dictionary, ch: Character, npc: String) -> String:
	var l := left(meta, npc)
	if l < 0.0:
		var jb: Array = JOBS[npc][0]
		return "Bottega: %s" % String(ItemsData.get_item(String(jb[1])).get("name", jb[1]))
	if l > 0.0:
		return "Pronto tra %d min" % ceili(l / 60.0)
	return "Ritira dalla bottega"


## Che cosa fa la bottega (per il suggerimento del bottone).
static func describe(ch: Character, npc: String) -> String:
	var rows := []
	for j in (JOBS[npc] as Array).size():
		var jb: Array = JOBS[npc][j]
		var parts := []
		for it in jb[0]:
			parts.append("%d %s" % [int(jb[0][it]), String(ItemsData.get_item(String(it)).get("name", it))])
		rows.append("%s → %d %s, %d minuti" % [", ".join(parts), int(jb[2]), String(ItemsData.get_item(String(jb[1])).get("name", jb[1])),
			ceili(minutes(ch, npc, j))])
	return "La bottega (fino a %d volte insieme; più affetto, meno tempo):\n%s" % [MAX_BATCH, "\n".join(rows)]
