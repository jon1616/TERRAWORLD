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
}
## Quanti all'ora cercando solo quello (materiali grezzi e dalle creature).
const RATE := {
	"legno": 240.0, "humus": 600.0, "gelatina": 30.0, "seta_radice": 25.0, "fungo_luminoso": 40.0,
	"minerale_radicite": 90.0, "minerale_legnoferro": 70.0, "minerale_ambra": 45.0, "minerale_tizzonite": 30.0,
	"vuotite": 150.0, "cristallo_linfa": 25.0, "squama_brace": 8.0, "lana_muschio": 12.0, "miele_lume": 6.0,
	"linfa_antica": 0.0, "frammento_albero": 0.0,
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
		# i traguardi dai giri di mondo
		for o in st["offers"]:
			if o.has("stat") and PER_WORLD.has(String(o["stat"])):
				var need := float(o["n"])
				while float(have.get(String(o["stat"]), 0.0)) + 0.001 < need:
					_world()
		# gli oggetti: da ciò che si ha, il resto apposta
		for o in st["offers"]:
			if o.has("item"):
				var extra := _item(String(o["item"]), float(o["n"]))
				if extra > 0.5:
					notes.append("%s %.0f min" % [String(ItemsData.get_item(String(o["item"])).get("name", o["item"])), extra])
		# i traguardi con un tempo loro
		for o in st["offers"]:
			if o.has("stat") and STAT_MIN.has(String(o["stat"])):
				var sid := String(o["stat"])
				var t: Array = STAT_MIN[sid]
				var m := float(t[0]) if not done.has(sid) else float(t[1])
				done[sid] = true
				minutes += m
				stat_min += m
				notes.append("%s %.0f min" % [sid, m])
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
	_p("   la lingua dei Seminatori si impara per strada (tools/lingua.gd: comune e antica in 5 mondi, la nera nel mondo del Seme Nero)")
	_p("   (conti fatti in %d ms)" % (Time.get_ticks_msec() - t0))
	var f := FileAccess.open("res://prove/durata.txt", FileAccess.WRITE)
	if f:
		f.store_string("\n".join(out))
	quit()


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
