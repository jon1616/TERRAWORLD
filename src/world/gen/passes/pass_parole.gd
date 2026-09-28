class_name PassParole
extends GenPass
## Gli scrigni a parola (Roadmap 17, voce 174): in un terzo delle rovine lo scrigno è sigillato da una parola. Il sigillo
## è una frase di una stele di **questo** mondo con una parola mancante, scelta tra quelle che compaiono in almeno due
## stele: così si può dedurre leggendo le altre. Dopo `PassStele`. Negli appunti "scrigni_parola" {"x,y": {words, gap}}
## (li legge `WordChests`).

const SHARE := 0.34


func title() -> String:
	return "Scrigni a parola"


func run(w: World, c: GenContext) -> void:
	var st: Dictionary = c.notes.get("stele", {})
	var freq := {}
	var phrases := []
	for k in st:
		var words: Array = st[k]["words"]
		for wd in words:
			freq[String(wd)] = int(freq.get(String(wd), 0)) + 1
		if words.size() >= 4:
			phrases.append(words)
	var out := {}
	if phrases.is_empty():
		c.notes["scrigni_parola"] = out
		return
	var chests := []
	for o in w.stations:
		if String(w.stations[o]) == "scrigno" and o.y > w.surface[clampi(o.x, 0, w.w - 1)] + 5:
			chests.append(o)
	chests.sort()
	for o in chests:
		if c.rng.randf() > SHARE:
			continue
		var words: Array = phrases[c.rng.randi_range(0, phrases.size() - 1)]
		var gaps := []
		for i in words.size():
			if int(freq.get(String(words[i]), 0)) >= 2:
				gaps.append(i)
		if gaps.is_empty():
			continue
		w.stations[o] = "scrigno_parola"
		out["%d,%d" % [o.x, o.y]] = {"words": words.duplicate(), "gap": int(gaps[c.rng.randi_range(0, gaps.size() - 1)])}
	c.notes["scrigni_parola"] = out
