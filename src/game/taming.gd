class_name Taming
extends Node
## Addomesticare (voce 59): i tre modi di far entrare una creatura nella mandria (`Herd`) e i vasetti.
##   - il cibo: clic destro con il cibo della famiglia su una creatura che si fida (una docile non colpita, o una che
##     ha fame, è stordita o è indebolita): ogni pasto dà affetto (`HerdData.feed_gain`), a 100 è tua (`feed`)
##   - il Laccio: clic su una creatura stremata (meno del 40% della Vita): forse la prendi (`lasso`)
##   - le uova: nell'Incubatrice si schiudono in vasetti (`Pens`)
## Il cibo sbagliato non va: la dieta si scopre dandole il cibo giusto, o dopo averne sconfitte `HerdData.STUDY`.
## Il Vasetto porta una creatura della mandria come oggetto: la scheda va nei dati dell'oggetto (`jar`, `release`).

var m: Node2D
var h: Herd
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	h = m.herd
	_rng.randomize()


## Clic destro (da `Interact.touch`): sulla propria creatura la nutre o la accarezza; su una selvatica, con un cibo
## in mano, prova a darglielo. False se non c'entra (così il clic va avanti: torce, stazioni).
func touch(pos: Vector2) -> bool:
	var held: Dictionary = m.hud.current()
	var id := String(held.get("id", ""))
	var own := h.creature_at(pos, false)
	if own != null:
		var rec: Dictionary = own.tame.rec
		if id in Herd.tame_data(rec)["diet"]:
			m.character.bisaccia.remove(id, 1)
			rec["fame"] = 0.0
			rec["felice"] = minf(float(rec["felice"]) + 0.2, 1.0)
			h.gain_xp(rec, 3)
			m.hud.toast("%s mangia volentieri" % rec["nome"])
		else:
			rec["felice"] = minf(float(rec["felice"]) + 0.05, 1.0)
			m.hud.toast(HerdInfo.short(rec))
		Fx.puff(m.fx, own.position + Vector2(0, -own.half.y), Herd.HEARTS)
		return true
	if not HerdData.is_food(id):
		return false
	var c := h.creature_at(pos, true)
	if c == null:
		return false
	feed(c, id)
	return true


## Perché una creatura non si lascia addomesticare affatto ("" = si può).
static func untamable(c: Creature) -> String:
	if c.boss or c.ancient != null:
		return "Una creatura così non accetta padroni"
	if HerdData.tame_of(FamiliesData.family_of(c.base)).is_empty():
		return "%s non si lascia addomesticare" % c.data["name"]
	return ""


## Perché una creatura selvatica non accetta il cibo adesso ("" = lo accetta).
static func refuses(c: Creature) -> String:
	if c.docile and c.provoked:
		return "È arrabbiata: non si fida di chi l'ha colpita"
	if c.docile or c.hunger >= 0.5 or c.stun > 0.3 or c.hp < c.hp_max * 0.5:
		return ""
	return "Non si fida: è troppo in forze. Aspetta che abbia fame, stordiscila o indeboliscila"


## Dare da mangiare a una creatura selvatica: affetto, e a 100 è tua.
func feed(c: Creature, item: String) -> bool:
	var no := untamable(c)
	if no != "":
		m.hud.toast(no)
		return false
	if c.position.distance_to(m.player.position) > PlayerActions.REACH + 8.0:
		m.hud.toast("Troppo lontana: avvicinati con il cibo in mano")
		return false
	var fam := FamiliesData.family_of(c.base)
	var t := HerdData.tame_of(fam)
	if not item in t["diet"]:
		var known: Dictionary = m.character.erbario.get("diete", {})
		if known.has(fam) or int(m.character.erbario.get("creature", {}).get(c.base, 0)) >= HerdData.STUDY:
			m.hud.toast("Annusa e si volta: %s mangia %s" % [String(FamiliesData.FAMILIES[fam]["name"]).to_lower(), HerdInfo.diet_text(fam)])
		else:
			m.hud.toast("Annusa e si volta: non è il suo cibo (guarda cosa mangia, o studiane qualcuna)")
		return false
	var why := refuses(c)
	if why != "":
		m.hud.toast(why)
		return false
	m.character.bisaccia.remove(item, 1)
	if not m.character.erbario.has("diete"):
		m.character.erbario["diete"] = {}
	m.character.erbario["diete"][fam] = 1
	c.hunger = 0.0
	c.affection += HerdData.feed_gain(fam, String(FamiliesData.parts(c.id)[3]))
	Fx.puff(m.fx, c.position + Vector2(0, -c.half.y), Herd.HEARTS)
	m.sfx.play("raccogli", c.position)
	if c.affection >= 100.0:
		tame(c, "nutrita")
	else:
		m.hud.toast("%s mangia dalla tua mano: si fida al %d%%" % [c.data["name"], roundi(c.affection)])
	return true


## Il Laccio: prende una creatura stremata, forse.
func lasso(item: String, pos: Vector2) -> bool:
	var c := h.creature_at(pos, true)
	if c == null:
		m.hud.toast("Lancia il laccio su una creatura (clic sopra)")
		return false
	var no := untamable(c)
	if no != "":
		m.hud.toast(no)
		return false
	if c.position.distance_to(m.player.position) > PlayerActions.REACH + 24.0:
		m.hud.toast("Troppo lontana per il laccio")
		return false
	var ch := lasso_chance(c)
	if ch <= 0.0:
		m.hud.toast("È ancora troppo in forze: indeboliscila (meno del %d%% della Vita)" % roundi(HerdData.CAPTURE_HP * 100.0))
		return false
	m.character.bisaccia.remove(item, 1)
	if _rng.randf() < ch:
		tame(c, "laccio")
		return true
	c.provoke()
	c.stun = 0.0
	m.hud.toast("Si libera dal laccio! (%d%% di riuscita: più è debole, più è facile)" % roundi(ch * 100.0))
	return true


static func lasso_chance(c: Creature) -> float:
	var ch := HerdData.capture_chance(FamiliesData.family_of(c.base), float(c.hp) / float(c.hp_max))
	return ch * float({"feroce": 0.6, "docile": 1.3, "timida": 1.2}.get(String(FamiliesData.parts(c.id)[3]), 1.0))


## La creatura diventa tua: una scheda nuova, e al suo posto la creatura della mandria.
func tame(c: Creature, how: String) -> Dictionary:
	var rec := h.new_record(c.id, how, float(c.hp_max) / maxf(float(c.data["hp"]), 1.0))
	var pos := c.position
	var cname := String(c.data["name"])
	m.fauna.list.erase(c)
	c.queue_free()
	Fx.puff(m.fx, pos, Herd.HEARTS)
	Fx.puff(m.fx, pos + Vector2(0, -10), Herd.HEARTS)
	m.sfx.play("incanto", pos)
	h.add_record(rec)
	m.objectives.bump("addomesticate")
	var b := h.spawn(rec, "segue" if rec["stato"] == "segue" else "")
	if b != null:
		b.position = pos
	m.hud.toast("%s è tua! Si chiama %s (G: la mandria)%s" % [cname, rec["nome"],
		"" if rec["stato"] == "segue" else ". Ti seguono già in tre: riposa nel Giardino"])
	return rec


## Il Vasetto vuoto su una creatura della mandria: entra nel vasetto.
func jar(pos: Vector2) -> bool:
	var own := h.creature_at(pos, false)
	if own == null:
		m.hud.toast("Clic con il vasetto su una creatura della tua mandria")
		return false
	return jar_record(own.tame.rec)


func jar_record(rec: Dictionary) -> bool:
	var b: Bisaccia = m.character.bisaccia
	if b.count("vasetto") <= 0:
		m.hud.toast("Serve un Vasetto di radice vuoto")
		return false
	var uid := int(rec["uid"])
	if uid == h.riding:
		h.ride(false)
	var pos: Vector2 = h.beasts[uid].position if h.beasts.has(uid) else m.player.position
	h.despawn(uid)
	h.unpair(rec)
	h.records().erase(rec)
	b.remove("vasetto", 1)
	rec["stato"] = "vasetto"
	if b.add_stack({"id": "creatura", "n": 1, "dati": rec}) > 0:
		m.drops.spawn("creatura", 1, pos, rec)
	Fx.puff(m.fx, pos, Herd.HEARTS)
	m.hud.toast("%s è nel vasetto" % rec["nome"])
	h.changed_now()
	return true


## Usare un vasetto pieno (la casella in mano): la creatura esce e ti segue; il vasetto torna vuoto.
func release() -> bool:
	var b: Bisaccia = m.character.bisaccia
	var i: int = m.hud.sel
	if b.id_at(i) != "creatura":
		return false
	var rec: Dictionary = b.data_at(i).duplicate(true)
	if not rec.has("specie") or not CreaturesData.CREATURES.has(CreaturesData.base_of(String(rec["specie"]))):
		m.hud.toast("Il vasetto è vuoto")
		return false
	b.take_one(i)
	b.add("vasetto", 1)
	rec["t"] = Time.get_unix_time_from_system()
	h.add_record(rec)
	var c := h.spawn(rec, "segue" if rec["stato"] == "segue" else "")
	if c != null:
		c.position = m.player.position + Vector2(18.0 * m.player.facing, 0)
		Fx.puff(m.fx, c.position, Herd.HEARTS)
	m.hud.toast("%s esce dal vasetto%s" % [rec["nome"], "" if rec["stato"] == "segue" else " e va a riposare (ti seguono già in tre)"])
	return true
