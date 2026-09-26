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
	var tr := String(slot.get("tratto", ""))
	var dati: Dictionary = slot.get("dati", {})
	var mods: Array[Dictionary] = []
	if tr != "":
		mods.append(TraitsData.TRAITS.get(tr, {}))
	var fascia := String(dati.get("fascia", ""))
	if FormsData.FASCE.has(fascia):
		mods.append(FormsData.FASCE[fascia])
	for md in mods:
		for k in MULT:
			out[k] = float(out[k]) * float(md.get(MULT[k], 1.0))
		out["defense"] = float(out["defense"]) + float(md.get("scorza", 0.0))
	return out


## Il nome completo: «Lancia di legnoferro con fascia di seta [Spina]».
static func full_name(slot: Dictionary) -> String:
	var id := String(slot.get("id", ""))
	var n := String(ItemsData.get_item(id).get("name", id))
	var dati: Dictionary = slot.get("dati", {})
	var fascia := String(dati.get("fascia", ""))
	if FormsData.FASCE.has(fascia):
		n += " con fascia di %s" % FormsData.FASCE[fascia]["name"]
	var tr := String(slot.get("tratto", ""))
	return n if tr == "" else "%s [%s]" % [n, TraitsData.TRAITS[tr]["name"]]


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
	if String(st["elem"]) != "":
		parts.append("Elemento %s" % ElementsData.tag(String(st["elem"])))
	return " · ".join(parts)
