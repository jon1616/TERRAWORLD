class_name GuardianGen
extends RefCounted
## Compone un Guardiano dal seme (voce 80, dati in `GuardianGenData`). L'id della creatura è «gg~<seme>»:
## `CreaturesData.get_data` lo riconosce e chiede qui i suoi dati, che quindi nascono sempre uguali dallo stesso seme
## (anche dopo un caricamento, senza salvarli). Il `Guardian` lo usa nei mondi di vigore 4 e oltre.

const PREFIX := "gg~"


static func id_for(sd: int) -> String:
	return PREFIX + str(absi(sd) % 1000000007)


static func is_gen(id: String) -> bool:
	return id.begins_with(PREFIX)


static func _rng(id: String) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = int(id.trim_prefix(PREFIX)) * 7919 + 80
	return r


## Le specie che possono fare da corpo.
static func bodies() -> Array:
	var out := []
	for f in FamiliesData.FAMILIES:
		for s in FamiliesData.FAMILIES[f]["members"]:
			if CreaturesData.CREATURES.has(s) and not s in GuardianGenData.NO_BODY:
				out.append(s)
	out.sort()
	return out


static func _pick_num(v: Variant, r: RandomNumberGenerator) -> Variant:
	if v is Array:
		var a: Array = v
		if a[0] is int and a[1] is int:
			return r.randi_range(int(a[0]), int(a[1]))
		return snappedf(r.randf_range(float(a[0]), float(a[1])), 0.01)
	return v


## I dati della creatura del Guardiano (come quelli di `CreaturesData`).
static func make(id: String) -> Dictionary:
	var r := _rng(id)
	var bs := bodies()
	var body := String(bs[r.randi_range(0, bs.size() - 1)])
	var src: Dictionary = CreaturesData.CREATURES[body]
	var fly := bool(src.get("fly", false))
	var fem := bool(FamiliesData.FAMILIES.get(FamiliesData.family_of(body), {}).get("fem", false))
	var elems: Array = GuardianGenData.ELEMENTS
	var elem := String(elems[r.randi_range(0, elems.size() - 1)])
	var elem2 := String(FamiliesData.OPPOSITE.get(elem, elem))
	if elem2 == elem or r.randf() < 0.4:
		elem2 = String(elems[r.randi_range(0, elems.size() - 1)])
		if elem2 == elem:
			elem2 = String(FamiliesData.OPPOSITE[elem])
	# gli attacchi: due o tre, solo quelli adatti al corpo
	var ok := []
	for a in GuardianGenData.ATTACKS:
		var ad: Dictionary = GuardianGenData.ATTACKS[a]
		if not ad.has("fly") or bool(ad["fly"]) == fly:
			ok.append(a)
	var picks := []
	var n := r.randi_range(2, 3)
	while picks.size() < n and not ok.is_empty():
		var a := String(ok[r.randi_range(0, ok.size() - 1)])
		ok.erase(a)
		picks.append(a)
	var behaviors := ["vola" if fly else "cammina"]
	var p := {"sight": 70, "leash": 26, "wobble": 30.0, "phase2": GuardianGenData.PHASE2,
		"shot_look": GuardianGenData.SHOT_LOOK.get(elem, "spora"), "summon": body}
	for a in picks:
		var ad: Dictionary = GuardianGenData.ATTACKS[a]
		behaviors.append(String(ad["bh"]))
		for k in ad["p"]:
			p[k] = _pick_num(ad["p"][k], r)
	# voce 186 (Roadmap 18, `tools/boss.gd`): due o tre attacchi a distanza insieme toglievano quattro Vite e mezza,
	# solo attacchi a contatto nemmeno una: chi tira molto tira più piano, chi non tira colpisce più forte
	var shooters := 0
	for a in picks:
		if a in GuardianGenData.SHOOTERS:
			shooters += 1
	if shooters >= 2:
		for k in ["fan_rate", "rate"]:
			if p.has(k):
				p[k] = float(p[k]) * GuardianGenData.MANY_SHOTS_SLOW
	var dmg_k := GuardianGenData.NO_SHOTS_DAMAGE if shooters == 0 else 1.0
	var titles: Array = GuardianGenData.TITLES[r.randi_range(0, GuardianGenData.TITLES.size() - 1)]
	var name := "%s %s %s" % [titles[1 if fem else 0], String(src["name"]).to_lower(), GuardianGenData.ELEM_NAME[elem]]
	var half := [maxi(roundi(float(src["half"][0]) * GuardianGenData.SCALE), 12),
		maxi(roundi(float(src["half"][1]) * GuardianGenData.SCALE), 12)]
	return {"name": name, "hp": r.randi_range(GuardianGenData.HP[0], GuardianGenData.HP[1]),
		"damage": roundi(r.randi_range(GuardianGenData.DAMAGE[0], GuardianGenData.DAMAGE[1]) * dmg_k),
		"defense": r.randi_range(GuardianGenData.DEFENSE[0], GuardianGenData.DEFENSE[1]), "knock": 1.0, "half": half,
		"speed": float(src.get("speed", 60)) * 1.1, "fly": fly, "behaviors": behaviors, "p": p, "loot": "",
		"art": src["art"], "strata": [], "weight": 0, "glow": true, "boss": true, "elem": elem, "weak": [FamiliesData.OPPOSITE[elem]],
		"resist": [elem], "phase_elem": elem2, "attacks": picks, "body": body, "base": body,
		"art_mods": {"elem": elem, "scale": GuardianGenData.SCALE, "temper": "feroce", "glow_body": true}}


## Le voci di `GuardiansData` per un Guardiano generato (cura, pagine, colore, frase del risveglio).
static func info(sd: int) -> Dictionary:
	var id := id_for(sd)
	var d := CreaturesData.get_data(id)
	var elem := String(d["elem"])
	return {"id": "generato", "creature": id, "cure": {"linfa_gg": GuardianGenData.DROP},
		"defeat": {"nucleo_" + elem: GuardianGenData.DROP},
		"pages": {"sconfitto": "generato_sconfitto", "curato": "generato_curato"},
		"color": VariantArt.ELEM_COLOR[elem].to_html(false), "wake": "Il Guardiano di questo mondo si risveglia: " + String(d["name"])}


## Una riga per le schede: «La Matriarca falena di brace del gelo · ventaglio, scatto».
static func describe(id: String) -> String:
	var d := CreaturesData.get_data(id)
	return "%s · %s" % [d["name"], ", ".join(d["attacks"])]
