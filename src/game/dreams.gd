class_name Dreams
extends Node
## I sogni (Roadmap 36, voce 343; dati in `DreamsData`). Usando un letto (`Masonry.slept`), se è passato abbastanza dal
## sogno di prima, il primo sogno pronto e non ancora visto: due righe nella pagina della storia. Visti in
## `stats["sogno_<id>"]`, contati in «sogni»; nel Taccuino la pagina «I sogni».

var m: Node2D
var paused := false
var _last := -1e9                        # secondi di gioco del sogno di prima (in questa sessione)
var _clock := 0.0


func setup(main: Node2D) -> void:
	m = main
	m.masonry.slept.connect(func(_o: Vector2i) -> void:
		if not paused:
			sleep())


func _process(dt: float) -> void:
	_clock += dt


## Il sogno che verrebbe adesso ("" se nessuno è pronto).
func next() -> String:
	for d in DreamsData.DREAMS:
		var id := String(d[0])
		if int(m.character.stats.get("sogno_" + id, 0)) == 0 and LoreConds.ok(m, d[3]):
			return id
	return ""


## Si dorme: forse un sogno. Restituisce il suo id ("" se niente).
func sleep(force := false) -> String:
	if not force and _clock - _last < DreamsData.COOLDOWN:
		return ""
	var id := next()
	if id == "":
		return ""
	_last = _clock
	var d: Array = DreamsData.DREAMS[DreamsData.index_of(id)]
	m.character.stats["sogno_" + id] = 1
	m.objectives.bump("sogni")
	if m.get("diary") != null:
		m.diary.note("Un sogno: %s" % d[1], "storia")
	m.guardian.lore.show_text(String(d[1]), String(d[2]))
	return id


func seen() -> int:
	var n := 0
	for d in DreamsData.DREAMS:
		if int(m.character.stats.get("sogno_" + String(d[0]), 0)) >= 1:
			n += 1
	return n


func rows(selected: String) -> Array:
	if seen() == 0:
		return []
	return [["storia:sogni", "I sogni   ·   %d" % seen(), "#ffd08a" if selected == "storia:sogni" else "#c8d8ff"]]


func detail() -> String:
	var t := "[color=#a8b8e8]Ciò che l'Albero-Madre ricorda, quando dormi. Non sempre: solo quando è successo qualcosa.[/color]\n"
	for d in DreamsData.DREAMS:
		if int(m.character.stats.get("sogno_" + String(d[0]), 0)) >= 1:
			t += "\n[color=#ffd8a8]%s[/color]\n[i][color=#cfeee4]%s[/color][/i]\n" % [d[1], String(d[2]).replace("\n", " ")]
	return t
