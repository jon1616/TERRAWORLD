class_name NpcBonds
extends RefCounted
## I legami con gli abitanti (voce 65, dati in `NpcData`): l'**affetto** (0-100, nel personaggio:
## `Character.stats["affetto_<id>"]`) cresce con i doni (5 per ogni oggetto che gli piace, 1 per gli altri, al più 20 a dono), con le richieste
## compiute (+30) e un poco con gli acquisti; ogni 25 punti un livello: sconto del 5% per livello sulle merci e, ai
## livelli 2 e 4, un regalo. Le **richieste personali** sono una catena per abitante (`quests`), una alla volta
## (`Character.stats["richiesta_<id>"]` = quante già fatte): consegnare oggetti (dalla Bisaccia e dalle casse vicine) o
## raggiungere un traguardo. Solo regole: li usa `TradePanel`.

const GIFT_LIKED := 5                  # per oggetto che gli piace (al più 20 a dono)
const GIFT_OTHER := 1
const QUEST := 30
const BUY := 1
const PER_LEVEL := 25
const DISCOUNT := 0.05


static func affetto(ch: Character, id: String) -> int:
	return int(ch.stats.get("affetto_" + id, 0))


static func level(ch: Character, id: String) -> int:
	return mini(affetto(ch, id) / PER_LEVEL, 4)


## Voce 143: la felicità della casa cambia i prezzi (abitante → moltiplicatore, lo scrive `Homes`).
static var mood_mult := {}


## Il prezzo con lo sconto dell'affetto (e la felicità della casa).
static func price(ch: Character, id: String, base: int) -> int:
	return maxi(1, roundi(base * (1.0 - DISCOUNT * level(ch, id)) * float(mood_mult.get(id, 1.0))))


## Aggiunge affetto; restituisce il regalo dei livelli nuovi raggiunti ({oggetto: quanti}), da dare.
static func add(ch: Character, id: String, n: int) -> Dictionary:
	var before := level(ch, id)
	ch.stats["affetto_" + id] = mini(affetto(ch, id) + n, 100)
	var out := {}
	var gifts: Dictionary = NpcData.NPCS.get(id, {}).get("gifts", {})
	for lv in range(before + 1, level(ch, id) + 1):
		if gifts.has(lv):
			out[String(gifts[lv][0])] = int(out.get(String(gifts[lv][0]), 0)) + int(gifts[lv][1])
	return out


## Un dono: la pila in mano. Restituisce l'affetto guadagnato.
static func gift_value(id: String, item: String, n: int) -> int:
	var liked: Array = NpcData.NPCS.get(id, {}).get("likes", [])
	return mini((GIFT_LIKED if item in liked else GIFT_OTHER) * maxi(1, n), 20)


## La richiesta di adesso ({} se le ha fatte tutte).
static func quest(ch: Character, id: String) -> Dictionary:
	var qs: Array = NpcData.NPCS.get(id, {}).get("quests", [])
	var k := int(ch.stats.get("richiesta_" + id, 0))
	return qs[k] if k < qs.size() else {}


static func quest_ready(ch: Character, id: String) -> bool:
	var q := quest(ch, id)
	if q.is_empty():
		return false
	if q.has("stat"):
		return int(ch.stats.get(String(q["stat"]), 0)) >= int(q["n"])
	for it in q["need"]:
		if Crafting.have(ch.bisaccia, String(it)) < int(q["need"][it]):
			return false
	return true


## Consegna la richiesta: toglie gli oggetti, avanza la catena; restituisce la ricompensa da dare ({} se non si può).
static func deliver(ch: Character, id: String) -> Dictionary:
	if not quest_ready(ch, id):
		return {}
	var q := quest(ch, id)
	if q.has("need"):
		for it in q["need"]:
			Crafting.take(ch.bisaccia, String(it), int(q["need"][it]))
	ch.stats["richiesta_" + id] = int(ch.stats.get("richiesta_" + id, 0)) + 1
	var out: Dictionary = (q["reward"] as Dictionary).duplicate()
	var extra := add(ch, id, QUEST)
	for k in extra:
		out[k] = int(out.get(k, 0)) + int(extra[k])
	return out


## Come si scrive una richiesta, con quanto manca.
static func quest_text(ch: Character, id: String) -> String:
	var q := quest(ch, id)
	if q.is_empty():
		return "Nessuna richiesta: le hai fatte tutte."
	var need := ""
	if q.has("stat"):
		need = "(%d/%d)" % [mini(int(ch.stats.get(String(q["stat"]), 0)), int(q["n"])), int(q["n"])]
	else:
		var parts := []
		for it in q["need"]:
			parts.append("%s %d/%d" % [ItemsData.get_item(String(it))["name"], mini(Crafting.have(ch.bisaccia, String(it)), int(q["need"][it])),
				int(q["need"][it])])
		need = "(" + ", ".join(parts) + ")"
	return "«%s» %s" % [q["text"], need]
