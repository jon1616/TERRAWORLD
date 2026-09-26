class_name Mechanisms
extends Node
## Enigmi e meccanismi dei Seminatori (voce 71): ogni luogo scritto a mano (voce 70) chiude la stanza del tesoro con
## una **porta dei Seminatori** (tessere `PORTA_SEM`, il piccone non le scalfisce) che si apre risolvendo il suo enigma:
##   bracieri   accenderli tutti (clic destro con una torcia nella Bisaccia: la consuma)
##   leve       metterle come dice il leggio, nella lingua dei Seminatori («ul» su, «nae» giù)
##   piastre    salirci sopra tutte entro `PlacesData.PLACE_TIME` secondi
##   cristalli  risvegliarli con l'arma dell'elemento giusto in mano (clic destro); la scheda dice quale
##   glifi      la porta porta una frase: si apre quando ne conosci tutte le parole (clic destro sulla porta)
##   chiave     la Chiave dei Seminatori, nascosta in uno scrigno delle rovine dello stesso mondo
## Lo stato è nell'appunto del luogo (`world_meta["luoghi"][i]["enigma"]`); lo stato dei meccanismi è la stazione
## stessa (braciere / braciere_acceso…).

const UP := "sopra"
const DOWN := "sotto"

var m: Node2D
var _plates := {}                      # indice del luogo -> {"1": secondi da quando è premuta…}


func setup(main: Node2D) -> void:
	m = main
	for e in m.places.list():
		if not e.has("enigma"):
			e["enigma"] = make(e, m.world.world_seed)


## L'enigma di un luogo, con i suoi parametri (sempre gli stessi per quel luogo di quel mondo).
static func make(e: Dictionary, sd: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([sd, e["id"], e["x"], e["y"]])
	var tipo := String(PlacesData.PLACES[String(e["id"])]["enigma"]["tipo"])
	var en := {"tipo": tipo, "risolto": false}
	var keys: Array = (e.get("mecc", {}) as Dictionary).keys()
	keys.sort()
	match tipo:
		"leve":
			var code := {}
			for k in keys:
				code[k] = rng.randf() < 0.5
			if not code.values().has(true):
				code[keys[0]] = true                   # mai tutte giù: sarebbe già risolto
			en["codice"] = code
		"cristalli":
			var els := {}
			var all: Array = ElementsData.ELEMENTS.keys()
			for k in keys:
				els[k] = String(all[rng.randi_range(0, all.size() - 1)])
			en["elementi"] = els
		"glifi":
			en["parole"] = (LanguageData.LORE[rng.randi_range(0, LanguageData.LORE.size() - 1)] as Array).duplicate()
	return en


func _cell(v: Variant) -> Vector2i:
	return Vector2i(int(v[0]), int(v[1]))


## Il luogo che ha il meccanismo in o (o la porta in o).
func place_of(o: Vector2i) -> Dictionary:
	for e in m.places.list():
		for k in e.get("mecc", {}):
			if _cell(e["mecc"][k]) == o:
				return e
		for d in e.get("porta", []):
			if _cell(d) == o:
				return e
	return {}


## Clic destro su un meccanismo.
func touch(o: Vector2i, id: String) -> bool:
	var e := place_of(o)
	if e.is_empty() or e["enigma"].get("risolto", false):
		return false
	match id:
		"braciere":
			if m.character.bisaccia.remove("torcia", 1):
				_set_st(o, "braciere_acceso")
				m.sfx.play("torcia", Vector2(o) * 16.0)
			else:
				m.hud.toast("Il braciere è spento: serve una torcia")
		"leva", "leva_su":
			_set_st(o, "leva_su" if id == "leva" else "leva")
			m.sfx.play("legno", Vector2(o) * 16.0)
		"cristallo_eco":
			var want := String(e["enigma"]["elementi"].get(_key_of(e, o), ""))
			var hand: Dictionary = m.hud.current()
			var el := String(Gear.stats({"id": hand["id"], "tratto": hand.get("tratto", ""), "dati": hand.get("dati", {})})["elem"]) \
				if String(hand["id"]) != "" else ""
			if want != "" and el.contains(want):
				_set_st(o, "cristallo_eco_desto")
				m.sfx.play("dono", Vector2(o) * 16.0)
			else:
				m.hud.toast("Il cristallo non risponde: vuole un'arma di %s in mano" % ElementsData.ELEMENTS[want]["name"])
				return true
		_:
			return false
	check(e)
	return true


func _key_of(e: Dictionary, o: Vector2i) -> String:
	for k in e["mecc"]:
		if _cell(e["mecc"][k]) == o:
			return String(k)
	return ""


func _set_st(o: Vector2i, id: String) -> void:
	m.view.remove_station(o)
	m.world.stations[o] = id
	m.view.add_station(o)
	m.light.dirty = true


## Clic destro su una porta dei Seminatori.
func touch_door(c: Vector2i) -> bool:
	var e := place_of(c)
	if e.is_empty():
		return false
	var en: Dictionary = e["enigma"]
	match String(en["tipo"]):
		"glifi":
			var words: Array = en["parole"]
			var t := "[font_size=24][color=#6ff0b8]%s[/color][/font_size]\n\n%s" % [Language.line_sem(words), m.language.line_it(words)]
			if m.language.understood({"words": words}) >= words.size():
				open(e)
				t += "\n\n[color=#8ff0a0]Pronunci la frase: la porta la riconosce e si apre.[/color]"
			else:
				t += "\n\n[color=#6a8a84]La porta si apre a chi sa leggerla: impara le parole che mancano.[/color]"
			m.language.panel.show_text("Porta dei Seminatori", t)
		"chiave":
			if m.character.bisaccia.remove("chiave_seminatori", 1):
				open(e)
			else:
				m.hud.toast("Chiusa a chiave: la Chiave dei Seminatori è in uno scrigno delle rovine di questo mondo")
		_:
			m.hud.toast(hint(e))
	return true


## Che cosa chiede l'enigma (per la porta, le schede e l'Enciclopedia).
func hint(e: Dictionary) -> String:
	var en: Dictionary = e["enigma"]
	if en.get("risolto", false):
		return "Aperta"
	match String(en["tipo"]):
		"bracieri":
			return "Accendi tutti i bracieri (clic destro, con una torcia)"
		"leve":
			return "Metti le leve come dice il leggio"
		"piastre":
			return "Sali su tutte le piastre entro %d secondi" % roundi(PlacesData.PLATE_TIME)
		"cristalli":
			return "Risveglia i cristalli con l'arma dell'elemento giusto in mano"
		"glifi":
			return "Si apre a chi sa leggere la sua frase (clic destro)"
		"chiave":
			return "Chiusa a chiave: serve la Chiave dei Seminatori"
	return ""


## Per il leggio: le leve scritte nella lingua dei Seminatori.
func lore_extra(e: Dictionary) -> String:
	var en: Dictionary = e.get("enigma", {})
	if String(en.get("tipo", "")) != "leve":
		return ""
	var words := []
	var keys: Array = (en["codice"] as Dictionary).keys()
	keys.sort()
	for k in keys:
		words.append(UP if bool(en["codice"][k]) else DOWN)
	return "\n\n[color=#9fc8c0]Sulle leve, da sinistra, è inciso:[/color]\n[color=#6ff0b8]%s[/color]\n%s" % [Language.line_sem(words), m.language.line_it(words)]


## È risolto? Allora la porta si apre.
func check(e: Dictionary) -> void:
	var en: Dictionary = e["enigma"]
	if en.get("risolto", false):
		return
	var ok := true
	for k in e.get("mecc", {}):
		var id := String(m.world.stations.get(_cell(e["mecc"][k]), ""))
		match String(en["tipo"]):
			"bracieri":
				ok = ok and id == "braciere_acceso"
			"leve":
				ok = ok and (id == "leva_su") == bool(en["codice"][k])
			"cristalli":
				ok = ok and id == "cristallo_eco_desto"
			"piastre":
				ok = ok and id == "piastra_premuta"
	if ok and not (e.get("mecc", {}) as Dictionary).is_empty():
		open(e)


func open(e: Dictionary) -> void:
	e["enigma"]["risolto"] = true
	var r := Rect2i(int(e["x"]), int(e["y"]), int(e["w"]), int(e["h"]))
	for d in e.get("porta", []):
		var c := _cell(d)
		if m.world.tile(c.x, c.y) == TileDefs.PORTA_SEM:
			m.world.set_tile(c.x, c.y, TileDefs.AIR)
			Fx.puff(m.fx, Vector2(c) * 16.0 + Vector2(8, 8), Color(1.6, 1.4, 0.6))
	m.view.refresh_rect(r)
	m.light.dirty = true
	m.sfx.play("portale", Vector2(r.get_center()) * 16.0)
	m.hud.toast("La porta dei Seminatori si apre")
	m.character.stats["enigmi"] = int(m.character.stats.get("enigmi", 0)) + 1


## Le piastre: premute mentre il Germogliato ci sta sopra; tutte entro il tempo, e l'enigma è risolto.
func _process(dt: float) -> void:
	if not m.built:
		return
	var feet := Vector2i(floori(m.player.position.x / 16.0), floori((m.player.position.y + Player.HALF.y - 2.0) / 16.0))
	var lst: Array = m.places.list()
	for i in lst.size():
		var e: Dictionary = lst[i]
		if String(e.get("enigma", {}).get("tipo", "")) != "piastre" or e["enigma"].get("risolto", false):
			continue
		var st: Dictionary = _plates.get(i, {})
		for k in e["mecc"]:
			var c := _cell(e["mecc"][k])
			if c == feet:
				press(e, String(k), st)
			elif st.has(k):
				st[k] = float(st[k]) + dt
				if float(st[k]) > PlacesData.PLATE_TIME:
					st.erase(k)
					_set_st(c, "piastra")
		_plates[i] = st


func press(e: Dictionary, k: String, st: Dictionary) -> void:
	var c := _cell(e["mecc"][k])
	if not st.has(k):
		_set_st(c, "piastra_premuta")
		m.sfx.play("legno", Vector2(c) * 16.0)
	st[k] = 0.0
	check(e)
