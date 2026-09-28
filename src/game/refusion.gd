class_name Refusion
extends RefCounted
## La rifusione dei doppioni (29 set 2026, scelta dell'utente): al Maglio due oggetti **uguali** (stesso id: stessa
## forma e stesso materiale) diventano uno solo, che tiene il meglio dei due. Non è una ricetta: è una lavorazione
## (`CraftWork`) che vale per ogni arma, attrezzo, armatura e accessorio. Non si sale di materiale (per quello serve il
## metallo nuovo): si migliora ciò che si ha e si sfoltisce la Bisaccia.
## Le regole:
## - **qualità**: la più alta dei due; se sono uguali, un grado in più (fino a «capolavoro»);
## - **tratto di nascita**: il migliore (i tratti delle Essenze, poi i più rari, poi nessuno, poi quelli cattivi);
## - **innesti**: quelli dei due insieme, senza doppioni, finché ci sono posti (i posti li dà la qualità nuova);
## - **fascia**, **tempra**: la fascia del primo (o del secondo se il primo non l'ha), la tempra più alta.

const COST := {"polvere_brace": 2}


## Un tratto vale: 3 Essenza, 1-2 buono (più è raro più vale), 0 nessuno, -1 cattivo.
static func trait_score(t: String) -> float:
	if t == "" or not TraitsData.TRAITS.has(t):
		return 0.0
	var td: Dictionary = TraitsData.TRAITS[t]
	if td.get("essence", false):
		return 3.0
	for k in ["damage", "speed", "scorza", "run", "knock", "dig", "halo"]:
		if td.has(k) and float(td[k]) < (1.0 if k != "scorza" else 0.0):
			return -1.0
	return 1.0 + (10.0 - float(td.get("weight", 10))) / 10.0


## Il compagno migliore per la casella i: un'altra casella con lo stesso oggetto (-1 se non c'è).
static func partner(b: Bisaccia, i: int) -> int:
	var id := b.id_at(i)
	if id == "" or not Bisaccia.is_gear(id):
		return -1
	var best := -1
	var best_q := -1
	for j in b.slots.size():
		if j != i and b.id_at(j) == id:
			var q := Gear.quality(b.slots[j])
			if q > best_q:
				best_q = q
				best = j
	return best


## L'oggetto che nasce da due caselle (non tocca la Bisaccia).
static func result(a: Dictionary, b: Dictionary) -> Dictionary:
	var da: Dictionary = a.get("dati", {})
	var db: Dictionary = b.get("dati", {})
	var dati := da.duplicate(true)
	var qa := Gear.quality(a)
	var qb := Gear.quality(b)
	var q := maxi(qa, qb)
	if qa == qb:
		q = mini(q + 1, TraitsData.QUALITY.size() - 1)
	dati["q"] = q
	if String(dati.get("fascia", "")) == "" and String(db.get("fascia", "")) != "":
		dati["fascia"] = db["fascia"]
	var tp := maxi(int(da.get("tempra", 0)), int(db.get("tempra", 0)))
	if tp > 0:
		dati["tempra"] = tp
	var ta := String(a.get("tratto", ""))
	var tb := String(b.get("tratto", ""))
	var t := ta if trait_score(ta) >= trait_score(tb) else tb
	var out := {"id": a["id"], "n": 1}
	if t != "":
		out["tratto"] = t
	dati["innesti"] = []
	out["dati"] = dati
	var room := Gear.slots(out) - (1 if t != "" else 0)
	var inn := []
	for g in (da.get("innesti", []) as Array) + (db.get("innesti", []) as Array):
		if inn.size() >= room:
			break
		if String(g) != t and not String(g) in inn:
			inn.append(String(g))
	dati["innesti"] = inn
	if inn.is_empty():
		dati.erase("innesti")
	return out


## Rifonde la casella i con la sua gemella (`partner`). Vero se è riuscito.
static func refuse(b: Bisaccia, i: int) -> bool:
	var j := partner(b, i)
	if j < 0:
		return false
	for k in COST:
		if Crafting.have(b, k) < int(COST[k]):
			return false
	for k in COST:
		Crafting.take(b, k, int(COST[k]))
	j = partner(b, i)                    # (pagare può aver spostato le caselle? no, ma per sicurezza)
	if j < 0:
		return false
	var out := result(b.slots[i], b.slots[j])
	b.slots[i] = out
	b.slots[j] = {}
	b.changed.emit()
	return true
