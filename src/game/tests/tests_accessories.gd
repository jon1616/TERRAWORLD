class_name TestsAccessories
extends RefCounted
## Gli accessori e il movimento (Roadmap 43, voci 383-388). Gruppo «accessori».
## Le abilità scattano dal movimento (salto, scatto, aggancio…) e fanno le loro cose (scia, scudo, magnete); i dati:
## sei accessori firma per fase tutti diversi, trenta linee dell'Officina, ali e rampini nuovi, animaletti con un dono.

var kit: TestKit
var m: Node2D
var res := {}


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	data()
	await abilities()
	await pets()
	print("accessori: %s" % str(res))
	if not res.values().all(func(x: Variant) -> bool: return x == true):
		print("ATTENZIONE: gli accessori e il movimento non vanno come dovrebbero")


func data() -> void:
	var firma := 0
	var sigs := {}
	var twins := 0
	for id in ItemsData.all():
		var s := String(id)
		if s.begins_with("acc_f"):
			firma += 1
			var it := ItemsData.get_item(s)
			var e := EffectsData.info(String((it["effects"] as Array)[0])).duplicate()
			e.erase("name")
			e.erase("desc")
			var sig := str(it["acc"].keys()) + str(e)
			if sigs.has(sig):
				twins += 1
			sigs[sig] = true
	var lines := 0
	for id in ItemsData.all():
		if String(id).begins_with("officina_") and String(id).ends_with("_4") and not RecipesData.making(String(id)).is_empty():
			lines += 1
	var rampini := 0
	for id in ItemsData.all():
		if String(id).begins_with("rampino_f") and ItemsData.get_item(String(id)).has("hook"):
			rampini += 1
	var wings := FlightData.WINGS.size()
	var top := ItemsData.get_item("ali_f23_veloci")
	res["dati"] = firma == 138 and twins == 0 and lines == 30 and rampini == 22 and wings >= 29 and top.has("effects") \
		and CompanionsData.PETS.size() >= 50
	print("accessori, i dati: firma %d (gemelli %d), linee dell'Officina %d, rampini %d, ali %d, animaletti %d" % [
		firma, twins, lines, rampini, wings, CompanionsData.PETS.size()])


## Un accessorio con un'abilità «salto», indossato: il salto la fa scattare. Poi scudo e magnete.
func abilities() -> void:
	var b: Bisaccia = m.character.bisaccia
	var eq0: Variant = b.equip.get("accessorio_1", null)
	var with_salto := ""
	for id in ItemsData.all():
		var s := String(id)
		if s.begins_with("acc_f") and String(EffectsData.info(String((ItemsData.get_item(s)["effects"] as Array)[0])).get("when", "")) == "salto":
			with_salto = s
			break
	b.equip["accessorio_1"] = with_salto
	m.effects.refresh()
	var f0: int = m.abilities.fired
	m.abilities._cool.clear()
	m.abilities.trigger("salto")
	var fired: bool = m.abilities.fired == f0 + 1
	m.abilities.run({"do": "scudo", "n": 7, "t": 0.3})
	var shield: int = m.vitals.ability_scorza
	m.abilities.run({"do": "magnete", "mult": 3.0, "t": 0.3})
	var mag: float = m.drops.ability_magnet
	await kit.seconds(0.5)
	var off: bool = m.vitals.ability_scorza == 0 and is_equal_approx(m.drops.ability_magnet, 1.0)
	if eq0 == null:
		b.equip.erase("accessorio_1")
	else:
		b.equip["accessorio_1"] = eq0
	m.effects.refresh()
	res["abilita"] = with_salto != "" and fired and shield == 7 and mag > 2.9 and off
	print("accessori, le abilità: «%s» al salto %s; scudo %d, magnete ×%.1f, poi finiscono %s" % [with_salto, fired, shield, mag, off])


## Un animaletto con un dono in «acc» si chiama e si congeda.
func pets() -> void:
	var pid := ""
	for k in CompanionsData.PETS:
		if CompanionsData.PETS[k].has("acc"):
			pid = String(k)
			break
	m.companions.call_pet(pid)
	await kit.frames(3)
	var out: bool = m.companions.pet != null and m.companions.pet.id == pid
	m.companions.dismiss_pet()
	res["animaletti"] = pid != "" and out and m.companions.pet == null
	print("accessori, l'animaletto «%s»: segue %s" % [pid, out])
