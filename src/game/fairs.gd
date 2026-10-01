class_name Fairs
extends RefCounted
## Le fiere della mandria (Roadmap 24, voce 242): nel Giardino, un giorno ogni `EVERY_DAYS`. Una creatura della mandria
## si iscrive (pulsante «Alla fiera» del pannello della mandria) nella categoria in cui va meglio; ogni categoria accetta
## una creatura per fiera. Il giudizio (`score`) guarda doti, livello, manto e stirpe; le medaglie (`MEDALS`) danno premi
## per l'allevamento, l'oro anche **un uovo della sua stirpe**. Il record di ogni famiglia sta in
## `Character.stats["fiera_rec_<famiglia>"]`, la fiera di ogni categoria in `["fiera_<categoria>"]` (il giorno).

const EVERY_DAYS := 3
const CATS := {
	"lavoro": {"name": "Da lavoro", "desc": "quanto rende nel recinto"},
	"sella": {"name": "Da sella", "desc": "forza e resistenza di chi si cavalca"},
	"guardia": {"name": "Da guardia", "desc": "danno e Vita di chi combatte"},
	"bellezza": {"name": "Bellezza", "desc": "manto, grandezza, stirpe"},
}
## Le soglie di bronzo, argento e oro di ogni categoria.
const MEDALS := {"lavoro": [100, 145, 190], "sella": [105, 150, 195], "guardia": [105, 150, 195], "bellezza": [55, 95, 140]}
const MEDAL_NAMES := ["bronzo", "argento", "oro"]
const REWARDS := [
	{"vasetto": 2, "polvere_iridata": 1},
	{"laccio": 5, "linfa_antica": 1, "polvere_iridata": 2},
	{"polvere_iridata": 4, "linfa_antica": 2},
]


static func fair_day(day: int) -> bool:
	return day % EVERY_DAYS == 0


static func days_to_fair(day: int) -> int:
	return (EVERY_DAYS - day % EVERY_DAYS) % EVERY_DAYS


## Il punteggio di una creatura in una categoria (0 se non può gareggiare lì).
static func score(rec: Dictionary, cat: String) -> int:
	var g: Dictionary = rec.get("doti", {})
	var lvl := mini(int(rec.get("lvl", 1)), HerdData.LVL_WORK)
	var coat := String(g.get("manto", ""))
	match cat:
		"lavoro":
			return roundi(Breeding.mult(g, "resa") * 100.0) + lvl * 2
		"sella":
			if not Herd.tame_data(rec).has("mount"):
				return 0
			return roundi((Breeding.mult(g, "vita") + Breeding.mult(g, "danno")) * 50.0) + lvl * 2
		"guardia":
			if not Herd.fights(rec):
				return 0
			return roundi(Breeding.mult(g, "danno") * 70.0 + Breeding.mult(g, "vita") * 30.0) + lvl * 2
		"bellezza":
			var s := 0
			if BreedData.is_rare(coat):
				s += 40
			elif coat != "":
				s += 10
			if g.get("gigante", false):
				s += 25
			if Lineage.is_pure(g):
				s += 30
			return s + mini(int(g.get("gen", 0)) * 3, 30) + lvl
	return 0


## La categoria migliore per la creatura (tra quelle ancora libere oggi) e il suo punteggio: [categoria, punti].
static func best(rec: Dictionary, stats: Dictionary, day: int) -> Array:
	var bc := ""
	var bf := -1.0
	var bs := 0
	for c in CATS:
		if int(stats.get("fiera_" + c, -1)) == day:
			continue
		var s := score(rec, c)
		var th: Array = MEDALS[c]
		var f := float(s) / float(th[0])                    # quanto supera il bronzo della categoria
		if s > 0 and f > bf:
			bf = f
			bc = c
			bs = s
	return [bc, bs]


static func medal_of(cat: String, s: int) -> int:
	var th: Array = MEDALS[cat]
	var k := -1
	for i in th.size():
		if s >= int(th[i]):
			k = i
	return k


## Iscrive la creatura alla fiera di oggi. Restituisce l'avviso.
static func enter(m: Node2D, rec: Dictionary) -> String:
	if m.get("beauty") == null or not m.beauty.home():
		return "Le fiere della mandria si tengono nel Giardino"
	var day: int = m.day.day
	if not fair_day(day):
		return "Oggi non c'è la fiera: la prossima tra %d giorni" % days_to_fair(day)
	var st: Dictionary = m.character.stats
	if int(rec.get("fiera", -1)) == day:
		return "%s ha già gareggiato oggi" % rec["nome"]
	var b := best(rec, st, day)
	if String(b[0]) == "":
		return "Oggi le categorie in cui %s può gareggiare sono già prese" % rec["nome"]
	var cat := String(b[0])
	var s := int(b[1])
	st["fiera_" + cat] = day
	rec["fiera"] = day
	m.objectives.bump("fiere")
	var k := medal_of(cat, s)
	var msg := "Fiera, categoria «%s»: %s fa %d punti" % [CATS[cat]["name"], rec["nome"], s]
	var fam := Herd.family_of(rec)
	if s > int(st.get("fiera_rec_" + fam, 0)):
		st["fiera_rec_" + fam] = s
		msg += " (record della famiglia)"
	if k < 0:
		return msg + " · niente medaglia questa volta"
	msg += " · medaglia d'%s" % MEDAL_NAMES[k] if k == 1 or k == 2 else " · medaglia di %s" % MEDAL_NAMES[k]
	m.objectives.bump("medaglie")
	var parts := [Lineage._give(m, REWARDS[k])]
	if k == 2:
		m.objectives.bump("ori")
		var c := Breeding.child(rec, rec, RandomNumberGenerator.new())
		var egg := {"id": "uovo", "n": 1, "dati": {"fam": fam, "specie": c["specie"], "doti": c["doti"], "nato": "allevata",
			"genitori": [rec["nome"], rec["nome"]]}}
		if m.character.bisaccia.add_stack(egg) > 0:
			m.drops.spawn("uovo", 1, m.player.position, egg["dati"])
		parts.append("un uovo della sua stirpe")
	m.sfx.play("dono")
	return msg + ": " + ", ".join(parts)


## La riga del pannello della mandria.
static func line(m: Node2D) -> String:
	if m.get("day") == null:
		return ""
	var day: int = m.day.day
	return "Oggi c'è la fiera della mandria, nel Giardino!" if fair_day(day) else "La prossima fiera della mandria: tra %d giorni, nel Giardino" % days_to_fair(day)
