class_name Echoes
extends Node
## Gli echi (Roadmap 36, voce 344; scene in `EchoesData`, disegno in `EchoFx`). Aprendo per la prima volta uno scrigno
## delle rovine (`Interact`, «scrigni_aperti»), a volte una scena del passato rivive sopra lo scrigno. Visti in
## `stats["eco_<id>"]`, contati in «echi»; nel Taccuino la pagina «Gli echi» con le battute, per rileggerle.

var m: Node2D
var paused := false
var _rng := RandomNumberGenerator.new()
var _clock := 0.0
var _last := -1e9


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()


func _process(dt: float) -> void:
	_clock += dt


func next() -> int:
	for i in EchoesData.ECHOES.size():
		var e: Array = EchoesData.ECHOES[i]
		if int(m.character.stats.get("eco_" + String(e[0]), 0)) == 0 and LoreConds.ok(m, e[2]):
			return i
	return -1


## Uno scrigno delle rovine aperto la prima volta, con l'angolo in o. Restituisce l'id dell'eco ("" se niente).
func on_chest(o: Vector2i, force := false) -> String:
	if paused and not force:
		return ""
	if not force and (_clock - _last < EchoesData.COOLDOWN or _rng.randf() > EchoesData.CHANCE):
		return ""
	var i := next()
	if i < 0:
		return ""
	_last = _clock
	var e: Array = EchoesData.ECHOES[i]
	var fx := EchoFx.new()
	var sid := String(m.world.stations.get(o, "scrigno"))
	var size: Array = StationsData.STATIONS.get(sid, {"size": [2, 2]})["size"]
	fx.position = Vector2(o.x * 16 + int(size[0]) * 8, o.y * 16 + int(size[1]) * 16)
	fx.setup(e[1])
	m.fx.add_child(fx)
	m.character.stats["eco_" + String(e[0])] = 1
	m.objectives.bump("echi")
	m.sfx.play("presenza", fx.position)
	if m.get("diary") != null:
		m.diary.note("Un eco nelle rovine: «%s»" % String(e[1][0][1]), "storia")
	return String(e[0])


func seen() -> int:
	var n := 0
	for e in EchoesData.ECHOES:
		if int(m.character.stats.get("eco_" + String(e[0]), 0)) >= 1:
			n += 1
	return n


func rows(selected: String) -> Array:
	if seen() == 0:
		return []
	return [["storia:echi", "Gli echi   ·   %d" % seen(), "#ffd08a" if selected == "storia:echi" else "#b8e8d8"]]


func detail() -> String:
	var t := "[color=#98c8b8]Scene rimaste nelle rovine, come un'impronta nella pietra.[/color]\n"
	for e in EchoesData.ECHOES:
		if int(m.character.stats.get("eco_" + String(e[0]), 0)) == 0:
			continue
		t += "\n"
		for l in e[1]:
			var sp := EchoesData.speaker(String(l[0]))
			var nm := String(sp["name"])
			# chi non è ancora stato risvegliato resta senza nome
			if String(l[0]) in SowersData.SOWERS and String(l[0]) != "sareth" \
					and int(m.character.stats.get("risveglio_" + String(l[0]), 0)) == 0:
				nm = "una voce"
			t += "[color=%s]%s[/color]: [color=#cfeee4]«%s»[/color]\n" % [String(sp["color"]), nm, String(l[1])]
	return t
