class_name Gear
extends RefCounted
## I valori veri di **un** attrezzo, di un'arma o di un pezzo d'armatura (voce 50): l'oggetto di base (`ItemsData`,
## nato da forma × materiale), il suo tratto, la **fascia** (`FormsData.FASCE`, nei "dati" della casella) e, dalle voci
## 51 e 54, l'elemento, la qualità e gli innesti. Tutto ciò che colpisce, scava o para passa di qui: `Combat`, `Spells`,
## `PlayerActions`, la Scorza e la scheda in Esamina.
## `slot` è una casella: {"id", "tratto"?, "dati"?}.

## Le chiavi che moltiplicano (le altre si sommano).
const MULT := {"damage": "damage", "speed": "speed", "knockback": "knock", "dig": "dig"}


## I valori dell'oggetto nella casella: damage, speed, knockback, power, defense, pierce, dig, form, reach.
static func stats(slot: Dictionary) -> Dictionary:
	var id := String(slot.get("id", ""))
	var it := ItemsData.get_item(id)
	var out := {"damage": float(it.get("damage", 0)), "speed": float(it.get("speed", 0.0)),
		"knockback": float(it.get("knockback", 1.5)), "power": int(it.get("power", 0)), "defense": float(it.get("defense", 0)),
		"pierce": int(it.get("pierce", 0)), "dig": float(it.get("dig", 1.0)), "form": String(it.get("form", "")),
		"mat": String(it.get("mat", "")), "elem": String(it.get("elem", ""))}
	if out["elem"] == "" and out["mat"] != "":
		out["elem"] = String(MaterialsData.get_mat(String(out["mat"])).get("elemento", ""))   # voce 51
	var dati: Dictionary = slot.get("dati", {})
	var mods: Array[Dictionary] = []
	for t in traits(slot):
		mods.append(TraitsData.TRAITS.get(t, {}))
	var fascia := String(dati.get("fascia", ""))
	if FormsData.FASCE.has(fascia):
		mods.append(FormsData.FASCE[fascia])
	# voce 54: la qualità
	var qd: Dictionary = TraitsData.QUALITY[quality(slot)]
	out["damage"] = float(out["damage"]) * float(qd["mult"])
	out["defense"] = float(out["defense"]) * float(qd["mult"])
	out["speed"] = float(out["speed"]) * float(qd["speed"])
	for md in mods:
		for k in MULT:
			out[k] = float(out[k]) * float(md.get(MULT[k], 1.0))
		out["defense"] = float(out["defense"]) + float(md.get("scorza", 0.0))
	# voce 79: la tempra del Maglio
	var tp := int(dati.get("tempra", 0))
	if tp > 0:
		out["damage"] = float(out["damage"]) * (1.0 + VigorData.TEMPER_MULT * tp)
		out["defense"] = float(out["defense"]) * (1.0 + VigorData.TEMPER_MULT * tp)
		if int(out["power"]) > 0:
			out["power"] = int(out["power"]) + VigorData.TEMPER_POWER * tp
	return out


## I tratti dell'oggetto: quello con cui è nato ("tratto") e gli innesti delle Essenze ("dati.innesti", voce 54).
static func traits(slot: Dictionary) -> Array:
	var out := []
	if String(slot.get("tratto", "")) != "":
		out.append(String(slot["tratto"]))
	var dati: Dictionary = slot.get("dati", {})
	for t in dati.get("innesti", []):
		if TraitsData.TRAITS.has(String(t)):
			out.append(String(t))
	if TraitsData.TRAITS.has(String(dati.get("incisione", ""))):
		out.append(String(dati["incisione"]))          # Roadmap 17: l'incisione (non prende un posto)
	return out


## Un effetto di tutti i tratti insieme (somma per quelli additivi, prodotto per gli altri: vedi `TraitsData.ADDITIVE`).
static func effect(slot: Dictionary, key: String) -> float:
	var add := key in TraitsData.ADDITIVE
	var v := 0.0 if add else 1.0
	for t in traits(slot):
		var e := TraitsData.effect(t, key)
		v = v + e if add else v * e
	return v


## La qualità (0-3; «buono» se l'oggetto non è stato fabbricato).
static func quality(slot: Dictionary) -> int:
	var dati: Dictionary = slot.get("dati", {})
	return clampi(int(dati.get("q", 1)), 0, TraitsData.QUALITY.size() - 1)


## Quanti posti d'innesto ha l'oggetto (il tratto di nascita ne occupa uno).
static func slots(slot: Dictionary) -> int:
	var it := ItemsData.get_item(String(slot.get("id", "")))
	var res := int(MaterialsData.get_mat(String(it.get("mat", ""))).get("risonanza", 0)) if it.has("mat") else 0
	var tp := int((slot.get("dati", {}) as Dictionary).get("tempra", 0))       # voce 79: la tempra apre posti nuovi
	return mini(1 + maxi(quality(slot) - 1, 0) + res, TraitsData.MAX_SLOTS) + tp / VigorData.TEMPER_SLOT


## Posti ancora liberi per un innesto.
static func free_slots(slot: Dictionary) -> int:
	var inc := 1 if TraitsData.TRAITS.has(String((slot.get("dati", {}) as Dictionary).get("incisione", ""))) else 0
	return slots(slot) - traits(slot).size() + inc


## Il nome completo: «Lancia di legnoferro con fascia di seta [Spina]».
static func full_name(slot: Dictionary) -> String:
	var n0 := _full_name(slot)
	var tp := int((slot.get("dati", {}) as Dictionary).get("tempra", 0))
	return n0 + (" +%d" % tp if tp > 0 else "")


static func _full_name(slot: Dictionary) -> String:
	var id := String(slot.get("id", ""))
	var n := String(ItemsData.get_item(id).get("name", id))
	var dati: Dictionary = slot.get("dati", {})
	# voce 59: la creatura nel vasetto e l'uovo si chiamano per chi c'è dentro
	if id == "creatura" and dati.has("nome"):
		return "%s nel vasetto (%s, liv. %d)" % [dati["nome"], String(CreaturesData.get_data(String(dati["specie"]))["name"]).to_lower(),
			int(dati["lvl"])]
	if id == "uovo" and dati.has("specie"):
		var en := "Uovo di %s" % String(CreaturesData.get_data(String(dati["specie"]))["name"]).to_lower()
		return en + (" (allevato)" if dati.has("doti") else "")
	var q := quality(slot)
	if q != 1 and dati.has("q"):
		n += " " + String(TraitsData.QUALITY[q]["name"])
	var fascia := String(dati.get("fascia", ""))
	if FormsData.FASCE.has(fascia):
		n += " con fascia di %s" % FormsData.FASCE[fascia]["name"]
	var ts := traits(slot).map(func(t: String) -> String: return String(TraitsData.TRAITS[t]["name"]))
	return n if ts.is_empty() else "%s [%s]" % [n, ", ".join(ts)]


## Una riga con i valori, per la scheda in Esamina.
static func line(slot: Dictionary) -> String:
	var st := stats(slot)
	var it := ItemsData.get_item(String(slot.get("id", "")))
	var parts := []
	if it.has("damage"):
		parts.append("Danno %d" % roundi(float(st["damage"])))
	if it.has("speed"):
		parts.append("Colpi al secondo %.2f" % float(st["speed"]))
	if it.has("power"):
		parts.append("Forza %d" % int(st["power"]))
	if it.has("defense"):
		parts.append("Scorza %d" % roundi(float(st["defense"])))
	if int(st["pierce"]) > 0:
		parts.append("Trafigge %d" % int(st["pierce"]))
	if String(st["elem"]).contains("+"):
		parts.append("Elementi %s e %s, alternati" % [ElementsData.tag(String(st["elem"]).get_slice("+", 0)),
			ElementsData.tag(String(st["elem"]).get_slice("+", 1))])
	elif String(st["elem"]) != "":
		parts.append("Elemento %s" % ElementsData.tag(String(st["elem"])))
	return " · ".join(parts)
