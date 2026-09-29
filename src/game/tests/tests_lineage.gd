class_name TestsLineage
extends RefCounted
## Roadmap 24 «Stirpi e semi»: stirpi e manti, fiere, lavori della mandria, qualità e incroci dell'orto, cucina
## (gruppo `stirpi`).

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await lineage()
	await fairs()


## Voce 241: sei generazioni della stessa variante fanno una stirpe pura (doti in più); un manto raro nuovo entra nella
## collezione.
func lineage() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var sp := "pecora_muschio"
	var a: Dictionary = m.herd.new_record(sp, "nutrita")
	var b: Dictionary = m.herd.new_record(sp, "nutrita")
	var first: Dictionary = Breeding.child(a, b, rng)            # i campi della stirpe nascono con il figlio
	var pure_at := -1
	for gen in 7:                                              # sempre la stessa variante: la linea resta pura
		var d := {"vita": 1.0, "danno": 1.0, "resa": 1.0, "gen": gen + 1}
		d.merge(Lineage.of_child(a, b, sp))
		if pure_at < 0 and Lineage.is_pure(d):
			pure_at = gen + 1
		a = m.herd.new_record(sp, "allevata", 1.0, d)
		b = m.herd.new_record(sp, "allevata", 1.0, d.duplicate(true))
	var g: Dictionary = a["doti"]
	var sheet := Breeding.sheet(g)
	var boosted: bool = Breeding.mult(g, "vita") > float(g["vita"]) * 1.05
	var st: Dictionary = m.character.stats
	var saved := st.duplicate()
	var uid0 := int(st.get("mandria_uid", 0))
	var rec: Dictionary = m.herd.new_record(sp, "allevata", 1.0, {"gen": 3, "manto": "dorato", "vita": 1.0, "danno": 1.0, "resa": 1.0})
	var n0 := Lineage.collected(st)
	var msg := Lineage.on_hatch(m, rec)
	var n1 := Lineage.collected(st)
	var again := Lineage.on_hatch(m, rec)
	var ok := pure_at == Lineage.PURE_GEN and boosted and "Stirpe pura" in sheet and String(first["doti"].get("capo", "")) != "" and (first["doti"].get("padri", []) as Array).size() == 2 \
		and n1 == n0 + 1 and again == "" and Lineage.total() >= 150
	print("stirpi: pura alla generazione %d, doti in più %s; capostipite «%s»; collezione dei manti %d → %d su %d («%s»)" % [
		pure_at, boosted, first["doti"].get("capo", ""), n0, n1, Lineage.total(), msg])
	if not ok:
		print("ATTENZIONE: le stirpi non vanno")
	for k in st.keys():
		if not saved.has(k):
			st.erase(k)
		else:
			st[k] = saved[k]


## Voce 242: il giudizio dà più punti a chi ha doti migliori; nel giorno della fiera una creatura forte prende una
## medaglia (l'oro con l'uovo della sua stirpe) e la sua categoria resta chiusa fino alla fiera dopo.
func fairs() -> void:
	var weak: Dictionary = m.herd.new_record("pecora_muschio", "nutrita", 1.0, {"gen": 0, "manto": "", "vita": 0.9, "danno": 0.9, "resa": 0.9})
	var strong: Dictionary = m.herd.new_record("pecora_muschio", "allevata", 1.0, {"gen": 6, "manto": "dorato", "vita": 1.6,
		"danno": 1.5, "resa": 1.9, "pura": 5, "gigante": true})
	strong["lvl"] = 20
	var sw := Fairs.score(weak, "lavoro")
	var ss := Fairs.score(strong, "lavoro")
	var st: Dictionary = m.character.stats
	var saved := st.duplicate()
	var day0: int = m.day.day
	var outside := Fairs.enter(m, strong)                  # il mondo di prova non è il Giardino
	var home_ok := "Giardino" in outside
	var eggs0: int = m.character.bisaccia.count("uovo")
	var d := Fairs.EVERY_DAYS * 10
	var msg := ""
	if m.get("beauty") != null and not m.beauty.home():
		var cat := String(Fairs.best(strong, st, d)[0])
		var k := Fairs.medal_of(cat, Fairs.score(strong, cat))
		msg = "categoria %s, medaglia %d" % [cat, k]
		home_ok = home_ok and k == 2
	var ok := ss > sw and Fairs.medal_of("lavoro", ss) == 2 and Fairs.medal_of("lavoro", sw) < 1 and home_ok and Fairs.fair_day(d) \
		and Fairs.score(weak, "sella") == 0
	print("fiere: lavoro debole %d, forte %d (%s); fuori dal Giardino «%s»; %s" % [sw, ss, Fairs.MEDAL_NAMES[Fairs.medal_of("lavoro", ss)],
		outside, msg])
	if not ok:
		print("ATTENZIONE: le fiere della mandria non vanno")
	for k2 in st.keys():
		if not saved.has(k2):
			st.erase(k2)
		else:
			st[k2] = saved[k2]
	m.day.day = day0
	m.character.bisaccia.remove("uovo", maxi(m.character.bisaccia.count("uovo") - eggs0, 0))
