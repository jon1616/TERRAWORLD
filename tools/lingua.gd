extends SceneTree
## Quanto dura imparare la lingua dei Seminatori (Roadmap 17, voce 178). Un giocatore simulato attraversa una serie di
## mondi (come una partita: vigore che sale, poi il mondo del Seme Nero) e in ognuno legge tutte le stele, prova i
## significati delle ipotesi a caso (con la regola vera: sbagliato = bloccato fino a una frase nuova), va ai luoghi
## «forse» e apre gli scrigni a parola quando la parola mancante è almeno un'ipotesi. Usa `Language` vero, con un
## «main» finto. Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/lingua.gd
## Scrive prove/lingua.txt e lo stampa.

const TRIP := [[101, 1, false], [102, 1, false], [103, 2, false], [104, 3, false], [105, 3, false], [106, 4, false],
	[107, 5, false], [108, 3, true]]

class FakeMain extends Node2D:
	var character: Character
	var world: World
	var world_meta := {}

var out := ""


func _init() -> void:
	var fm := FakeMain.new()
	fm.character = Character.create("prova")
	var lg := Language.new()
	lg.m = fm
	var rng := RandomNumberGenerator.new()
	rng.seed = 17
	var stele_tot := 0
	for trip in TRIP:
		var w := World.new()
		WorldGen.generate(w, int(trip[0]), WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": int(trip[1]), "nero": bool(trip[2]),
			"geni": ["cuore_nero"] if bool(trip[2]) else []})
		fm.world = w
		var st: Dictionary = w.gen_notes.get("stele", {})
		var chests: Dictionary = w.gen_notes.get("scrigni_parola", {})
		fm.world_meta = {"stele": st.duplicate(true), "segni": []}
		stele_tot += st.size()
		var guesses := 0
		var chest_open := 0
		var places := 0
		for k in st:
			lg.see(st[k]["words"], "%d:%s" % [int(trip[0]), k])
			# prova a caso le ipotesi non bloccate
			for wd in fm.character.lingua.keys():
				if lg.state(String(wd)) == Language.IPOTESI and not lg.rec(String(wd)).has("r"):
					var opts := lg.options_left(String(wd))
					lg.guess(String(wd), String(opts[rng.randi_range(0, opts.size() - 1)]))
					guesses += 1
		# i luoghi «forse»: ci va
		for k in st:
			var e: Dictionary = st[k]
			if not (e.get("hint", []) as Array).is_empty() and lg.guessed(e):
				lg.confirm(e["words"], "luogo")
				places += 1
		# gli scrigni a parola: aperti se la parola mancante è almeno un'ipotesi
		for k in chests:
			var e: Dictionary = chests[k]
			lg.see(e["words"], "scrigno:%d:%s" % [int(trip[0]), k])
			var gap := String(e["words"][int(e["gap"])])
			if lg.state(gap) >= Language.IPOTESI:
				lg.confirm([gap], "scrigno")
				chest_open += 1
		var row := "mondo %d (vigore %d%s): %d stele, prove %d, luoghi %d, scrigni aperti %d/%d ·" % [int(trip[0]), int(trip[1]),
			", Seme Nero" if bool(trip[2]) else "", st.size(), guesses, places, chest_open, chests.size()]
		for l in LanguageData.LAYER_ORDER:
			var t: Array = lg.tally(String(l))
			row += "  %s certe %d/%d (ipotesi %d)" % [String(l), int(t[0]), int(t[3]), int(t[1])]
		_p(row)
	_p("stele lette in tutto: %d" % stele_tot)
	var f := FileAccess.open("res://prove/lingua.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)
	quit()


func _p(s: String) -> void:
	print(s)
	out += s + "\n"
