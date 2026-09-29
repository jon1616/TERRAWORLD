extends SceneTree
## Quanto dura la partita a obiettivi (29 set 2026, richiesta dell'utente: il gioco finito deve durare ~500 ore, e la
## misura deve essere veloce). Non gioca: fa i conti in pochi secondi, dai dati veri del gioco.
##   Godot_console.exe --headless --path . --script res://tools/durata.gd
## Scrive prove/durata.txt e lo stampa.
##
## «Finire il gioco» = svegliare del tutto l'Albero-Madre (tutti gli stadi di `MotherTreeData`) e seguire la catena
## lunga (`ChainsData`) fino al Seme Nero e al suo Guardiano. La parte senza fine (vigore oltre, leggende, Seme Primo,
## collezioni complete) non si conta.
##
## Il modello. La partita è una serie di **giri di mondo**: si pianta un Seme, si esplora il mondo fino al Fondo e al
## Guardiano, si torna. Un giro dura `WORLD_MIN` minuti (di più nei mondi più vigorosi) e porta con sé ciò che si trova
## per strada (`PER_WORLD`: traguardi e materiali). Per ogni stadio dell'Albero:
##   1. i traguardi (`stat`) chiedono giri di mondo finché il conto non basta (i giri si sommano per tutta la partita);
##   2. gli oggetti si prendono prima da ciò che i giri hanno portato; quello che manca si va a cercare apposta
##      (`RATE`: quanti all'ora, cercando solo quello). Gli oggetti fabbricati si scompongono nelle loro ricette.
##   3. i traguardi che non vengono dai giri (addomesticare, allevare) hanno un tempo loro (`STAT_MIN`).
## Poi la catena lunga (un Seme da progettare e un giro per tappa) e il mondo del Seme Nero.
## Il **giocatore medio** fa anche tutto il resto (casa, casse, bottega, pesca, perdersi, appassire): `MEDIO` moltiplica
## il tempo della via diretta. I numeri sotto sono stime da tarare con le partite vere (il Diario dell'utente).

const MEDIO := 1.6                     # il giocatore medio contro chi va dritto agli obiettivi
## Minuti di un giro di mondo al vigore v: `WORLD_MIN + WORLD_STEP × (v - 1)` (il primo come le tappe di tools/percorso.gd).
const WORLD_MIN := 115.0
const WORLD_STEP := 12.0
## Il vigore dei mondi che si visitano, giro dopo giro (poi resta l'ultimo).
const VIGOR := [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9, 10]
## Ciò che un giro di mondo porta, di media, per chi lo esplora fino al Guardiano.
const PER_WORLD := {
	"viaggi": 1.0, "guardiani": 1.0, "firme": 0.7, "geni_imparati": 3.0, "reliquiari": 0.5, "custodi": 0.4,
	"linfa_antica": 2.0, "frammento_albero": 2.0, "legno": 60.0, "humus": 120.0, "gelatina": 12.0, "seta_radice": 6.0,
	"fungo_luminoso": 10.0, "minerale_radicite": 30.0, "minerale_legnoferro": 24.0, "minerale_ambra": 14.0,
	"minerale_tizzonite": 6.0, "vuotite": 30.0, "cristallo_linfa": 8.0, "squama_brace": 2.0,
	"stele": 6.0, "centrali": 0.3, "scrigni_parola": 1.0,
	"stelle": 2.5, "meraviglie": 1.5, "ricordi": 1.0, "spedizioni": 0.5,        # Roadmap 23: l'Atlante per strada
}
## Roadmap 21: un Giardino perduto è un giro di mondo più lungo (le tre cure e il Custode) e porta ciò che vive solo lì.
const GARDEN_MULT := 1.5
const GARDEN := {
	"sommerso": {"perla_maree": 1.0, "guscio_lago": 12.0, "pesce_carpa_radice": 4.0, "specie_pescate": 4.0, "pesci": 30.0},
	"ferro": {"spola_viva": 1.0, "ingranaggio_radice": 14.0, "macchine": 6.0},
	"selvatico": {"cuore_rovo": 1.0, "setola_rovo": 10.0, "bacca_rovo": 20.0, "addomesticate": 1.0},
	"muto": {"parola_prima": 1.0, "eco_parola": 14.0, "stele": 8.0},
}
## Traguardi che non vengono dai giri: minuti per unità (fatti apposta).
const STAT_RATE := {"pesci": 0.3, "specie_pescate": 8.0, "pesci_leggendari": 120.0, "macchine": 10.0, "centrali": 60.0,
	"addomesticate": 20.0, "prodotti": 1.5, "raccolti": 1.0, "stele": 3.0, "scrigni_parola": 8.0}
## Quanti all'ora cercando solo quello (materiali grezzi e dalle creature).
const RATE := {
	"legno": 240.0, "humus": 600.0, "gelatina": 30.0, "seta_radice": 25.0, "fungo_luminoso": 40.0,
	"minerale_radicite": 90.0, "minerale_legnoferro": 70.0, "minerale_ambra": 45.0, "minerale_tizzonite": 30.0,
	"vuotite": 150.0, "cristallo_linfa": 25.0, "squama_brace": 8.0, "lana_muschio": 12.0, "miele_lume": 6.0,
	"linfa_antica": 0.0, "frammento_albero": 0.0,
	"squama_lume": 20.0, "guscio_lago": 30.0, "ingranaggio_radice": 30.0, "bacca_rovo": 40.0, "eco_parola": 30.0,
	"setola_rovo": 30.0, "pesce_carpa_radice": 6.0, "tavoletta_seminatori": 4.0,
	"perla_maree": 0.0, "spola_viva": 0.0, "cuore_rovo": 0.0, "parola_prima": 0.0, "polvere_iridata": 2.0,
}
## Traguardi che non vengono dai giri: minuti la prima volta (poi per ogni altro).
const STAT_MIN := {"addomesticate": [30.0, 20.0], "uova_allevate": [180.0, 60.0], "manti_rari": [360.0, 120.0]}
## La catena lunga: per ogni tappa, progettare il Seme (innesti, Fiale) più un giro per trovare la cripta.
const CHAIN_DESIGN_MIN := 45.0
const CHAIN_WORLD_FRACTION := 0.6
## Il mondo del Seme Nero e il suo Guardiano (più difficile di un giro normale).
const NERO_WORLD_MULT := 1.5

var out := PackedStringArray()
var have := {}                         # ciò che i giri hanno portato (traguardi cumulativi e materiali in tasca)
var worlds := 0
var minutes := 0.0
var world_min := 0.0
var focus_min := 0.0
var stat_min := 0.0
var mastery := {}                      # Roadmap 20: i punti dei pilastri presi per strada nella via diretta
## Roadmap 20, voce 218: in un giro di mondo, oltre ai traguardi di `PER_WORLD` (che passano per `MasteryData.STATS`),
## i punti che arrivano per strada: combattere (una parte del giro), scoprire la mappa, fabbricare e costruire un poco.
const WORLD_PTS := {"combattimento": 0.35, "esplorazione": 0.25, "giardino": 0.05, "orto": 0.03, "misteri": 0.05}
## Chi cura un pilastro apposta fa i suoi punti a questo ritmo (punti all'ora: un punto ≈ un minuto).
const PILLAR_RATE := 60.0


func _p(s: String) -> void:
	out.append(s)
	print(s)


func _init() -> void:
	var t0 := Time.get_ticks_msec()
	_p("QUANTO DURA LA PARTITA A OBIETTIVI (stima: nessuno gioca, sono conti sui dati)")
	_p("")
	_p("1. L'ALBERO-MADRE, stadio per stadio (ore della via diretta; tra parentesi il giocatore medio, ×%.1f)" % MEDIO)
	var done := {}
	for k in MotherTreeData.STAGES.size():
		var st: Dictionary = MotherTreeData.STAGES[k]
		var before := minutes
		var w0 := worlds
		var notes := []
		# Roadmap 21: guarire un Albero perduto = il giro del suo Giardino
		for o0 in st["offers"]:
			var o: Dictionary = o0["any"][0] if (o0 as Dictionary).has("any") else o0
			if o.has("stat") and String(o["stat"]).begins_with("perduto_"):
				_garden(String(o["stat"]).trim_prefix("perduto_"))
		# i traguardi dai giri di mondo
		for o0 in st["offers"]:
			var o: Dictionary = o0["any"][0] if (o0 as Dictionary).has("any") else o0      # la strada principale
			if o.has("stat") and PER_WORLD.has(String(o["stat"])):
				var need := float(o["n"])
				while float(have.get(String(o["stat"]), 0.0)) + 0.001 < need:
					_world()
		# gli oggetti: da ciò che si ha, il resto apposta
		for o0 in st["offers"]:
			var o: Dictionary = o0["any"][0] if (o0 as Dictionary).has("any") else o0      # la strada principale
			if o.has("item"):
				var extra := _item(String(o["item"]), float(o["n"]))
				if extra > 0.5:
					notes.append("%s %.0f min" % [String(ItemsData.get_item(String(o["item"])).get("name", o["item"])), extra])
		# i traguardi fatti apposta (pescare, costruire macchine, addomesticare…): quanto manca × minuti per unità
		for o0 in st["offers"]:
			var o: Dictionary = o0["any"][0] if (o0 as Dictionary).has("any") else o0
			var sk := String(o.get("stat", ""))
			if STAT_RATE.has(sk) and float(have.get(sk, 0.0)) < float(o["n"]):
				var miss := float(o["n"]) - float(have.get(sk, 0.0))
				var mm := miss * float(STAT_RATE[sk])
				minutes += mm
				focus_min += mm
				have[sk] = float(o["n"])
				_stat_points(sk, miss)
				notes.append("%s %.0f min" % [sk, mm])
		# i traguardi con un tempo loro
		for o0 in st["offers"]:
			var o: Dictionary = o0["any"][0] if (o0 as Dictionary).has("any") else o0      # la strada principale
			if o.has("stat") and STAT_MIN.has(String(o["stat"])):
				var sid := String(o["stat"])
				var t: Array = STAT_MIN[sid]
				var m := float(t[0]) if not done.has(sid) else float(t[1])
				done[sid] = true
				_stat_points(sid, 1.0)
				minutes += m
				stat_min += m
				notes.append("%s %.0f min" % [sid, m])
		_stat_points("albero", 1.0)
		var h := (minutes - before) / 60.0
		_p("   %2d «%s»: %5.1f h (%5.1f) · giri di mondo %d%s" % [k + 1, st["name"], h, h * MEDIO, worlds - w0,
			(" · apposta: " + ", ".join(notes)) if not notes.is_empty() else ""])
	var tree_h := minutes / 60.0
	_p("   l'Albero sveglio del tutto: %.0f h (%.0f), %d mondi" % [tree_h, tree_h * MEDIO, worlds])
	_p("")
	_p("2. LA CATENA LUNGA E IL SEME NERO")
	var before_chain := minutes
	for step in ChainsData.LONG["steps"]:
		var m := CHAIN_DESIGN_MIN + _world_minutes() * CHAIN_WORLD_FRACTION
		_stat_points("catene", 1.0)
		minutes += m
		_p("   «%s»: %.0f min (progettare il Seme, trovare la cripta)" % [step["name"], m])
	var nero := _world_minutes() * NERO_WORLD_MULT
	minutes += nero
	_p("   il mondo del Seme Nero e il suo Guardiano: %.0f min" % nero)
	_p("   catena e Seme Nero: %.1f h" % ((minutes - before_chain) / 60.0))
	_p("")
	var total := minutes / 60.0
	_p("3. IN TUTTO")
	_p("   via diretta: %.0f ore · giocatore medio: %.0f ore · obiettivo dell'utente: 500 ore (%.0f%%)" % [total, total * MEDIO,
		100.0 * total * MEDIO / 500.0])
	_p("   dove va il tempo (via diretta): giri di mondo %.0f h (%d mondi), cercare apposta %.0f h, allevare e addomesticare %.0f h, catena %.0f h" % [
		world_min / 60.0, worlds, focus_min / 60.0, stat_min / 60.0, (minutes - before_chain) / 60.0])
	_pillars(total)
	_p("   la lingua dei Seminatori si impara per strada (tools/lingua.gd: comune e antica in 5 mondi, la nera nel mondo del Seme Nero)")
	_p("   (conti fatti in %d ms)" % (Time.get_ticks_msec() - t0))
	var f := FileAccess.open("res://prove/durata.txt", FileAccess.WRITE)
	if f:
		f.store_string("\n".join(out))
	quit()


## Voce 218: i pilastri. Il grado preso per strada nella via diretta, e le ore che servono ancora a portarlo al 10
## curandolo apposta; poi il totale della partita «tutto al 10» contro le 500 ore dell'utente.
func _pillars(story_h: float) -> void:
	_p("")
	_p("4. I PILASTRI (la maestria, Roadmap 20): il grado preso per strada, le ore apposta fino al grado 10")
	var extra := 0.0
	for p in MasteryData.ORDER:
		var pts := float(mastery.get(p, 0.0))
		var g := MasteryData.grade_of(p, pts)
		var need := maxf(MasteryData.points_for(p, MasteryData.GRADES) - pts, 0.0)
		var h := need / PILLAR_RATE
		if p != "storia":
			extra += h
		_p("   %-28s grado %2d per strada (%5.0f punti) · ancora %5.1f h apposta (obiettivo %d h)" % [
			MasteryData.PILLARS[p]["name"], g, pts, h, int(MasteryData.PILLARS[p]["hours"])])
	# le ore apposta sono già ore di gioco vero: il giocatore medio allunga solo la via diretta
	_p("   tutto al grado 10: via diretta %.0f h + %.0f h apposta = %.0f ore; giocatore medio %.0f ore (obiettivo 500)" % [
		story_h, extra, story_h + extra, story_h * MEDIO + extra])
	_p("   (le ore apposta vengono dalle attività di ogni pilastro, che oggi in gran parte si ripetono: le Roadmap 21-28")
	_p("    aggiungono ciò che le rende nuove; questa misura dice quanta strada c'è, non quanto è varia)")
	_variety()


## Roadmap 22, voce 234: quanta strada di ogni pilastro è fatta di cose **diverse** (scritte una volta: capitoli, opere,
## isole, feste…) e non di ripetizioni. Minuti stimati per ogni cosa, contati dai dati.
func _variety() -> void:
	_p("")
	_p("5. LA VARIETÀ: le ore di cose diverse (fatte una volta) dentro ogni pilastro")
	var chapters := 0
	for nid in NpcStoriesData.STORIES:
		chapters += (NpcStoriesData.STORIES[nid] as Array).size()
	var quests := 0
	var visitors := 0
	for nid in NpcData.NPCS:
		quests += (NpcData.NPCS[nid].get("quests", []) as Array).size()
		if NpcData.NPCS[nid].get("visitor", false):
			visitors += 1
	var projects := 0
	var works := 0
	for id in ProjectsData.PROJECTS:
		if ProjectsData.PROJECTS[id].has("opera"):
			works += 1
		else:
			projects += 1
	var rows := {
		"giardino": [["isole", GardenIslandsData.ISLANDS.size(), 90.0], ["grandi opere", works, 150.0],
			["progetti dei Seminatori", projects, 25.0], ["feste", FestivalsData.FESTIVALS.size(), 40.0]],
		"abitanti": [["capitoli delle storie", chapters, 20.0], ["richieste", quests, 12.0],
			["botteghe", NpcWork.JOBS.size(), 15.0], ["visitatori", visitors, 20.0]],
		"esplorazione": [["meraviglie", WondersData.WONDERS.size(), 90.0], ["pagine dei biomi", BiomePagesData.pages().size(), 40.0],
			["accessori dei ricordi", WondersData.GEAR.size(), 30.0], ["attrezzi", ExplorerData.ITEMS.size(), 10.0],
			["firme dei mondi", SignaturesData.SIGNATURES.size(), 20.0]],
	}
	for p in rows:
		var tot := 0.0
		var parts := []
		for r in rows[p]:
			tot += float(r[1]) * float(r[2])
			parts.append("%s %d" % [r[0], int(r[1])])
		_p("   %-28s %.0f h di cose diverse (%s) su %d h di strada" % [MasteryData.PILLARS[p]["name"], tot / 60.0,
			", ".join(parts), int(MasteryData.PILLARS[p]["hours"])])


func _stat_points(stat: String, n: float) -> void:
	for e in MasteryData.STATS.get(stat, []):
		mastery[String(e[0])] = float(mastery.get(String(e[0]), 0.0)) + float(e[1]) * n


## Roadmap 21: il giro di un Giardino perduto (una volta sola per Giardino).
func _garden(id: String) -> void:
	if have.has("perduto_" + id):
		return
	var m := (WORLD_MIN + WORLD_STEP * (int(LostGardensData.GARDENS[id]["vigore"]) - 1)) * GARDEN_MULT
	minutes += m
	world_min += m
	worlds += 1
	have["perduto_" + id] = 1.0
	have["perduti"] = float(have.get("perduti", 0.0)) + 1.0
	_stat_points("perduti", 1.0)
	for k in GARDEN[id]:
		have[k] = float(have.get(k, 0.0)) + float(GARDEN[id][k])
	for p in WORLD_PTS:
		mastery[p] = float(mastery.get(p, 0.0)) + m * float(WORLD_PTS[p])


func _world_minutes() -> float:
	var v := int(VIGOR[mini(worlds, VIGOR.size() - 1)])
	return WORLD_MIN + WORLD_STEP * (v - 1)


## Un giro di mondo: il tempo e ciò che porta.
func _world() -> void:
	var m := _world_minutes()
	minutes += m
	world_min += m
	worlds += 1
	for k in PER_WORLD:
		have[k] = float(have.get(k, 0.0)) + float(PER_WORLD[k])
		_stat_points(String(k), float(PER_WORLD[k]))
	for p in WORLD_PTS:
		mastery[p] = float(mastery.get(p, 0.0)) + m * float(WORLD_PTS[p])


## Prende n di un oggetto: da ciò che si ha, poi dalla ricetta (scomposta), poi cercando apposta. I minuti apposta.
func _item(id: String, n: float) -> float:
	var got := minf(float(have.get(id, 0.0)), n)
	have[id] = float(have.get(id, 0.0)) - got
	var miss := n - got
	if miss <= 0.0:
		return 0.0
	if RATE.has(id) and float(RATE[id]) > 0.0:
		var m := miss / float(RATE[id]) * 60.0
		minutes += m
		focus_min += m
		return m
	if RATE.has(id):
		# viene solo dai giri (Linfa antica, frammenti): altri giri finché basta
		var m0 := minutes
		while float(have.get(id, 0.0)) + 0.001 < miss:
			_world()
		have[id] = float(have.get(id, 0.0)) - miss
		return minutes - m0
	var recs: Array = RecipesData.making(id)
	if recs.is_empty():
		push_warning("durata: non so come si prende «%s»" % id)
		return 0.0
	var r: Dictionary = recs[0]
	var batches := ceilf(miss / maxf(float(r.get("qty", 1)), 1.0))
	var tot := 0.0
	for ing in r["in"]:
		tot += _item(String(ing), float(r["in"][ing]) * batches)
	return tot
