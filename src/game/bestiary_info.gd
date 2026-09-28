class_name BestiaryInfo
extends RefCounted
## L'Erbario vivo (voce 61): che cosa sa il Germogliato di una famiglia di creature, imparato giocando. Ogni riga
## compare quando l'ha scoperta — sconfiggendole (`STUDY` per la dieta, `WATCH` per chi cacciano e chi le caccia),
## dando loro da mangiare, prendendo uova dai nidi, addomesticandole, allevandole — e al posto di quelle che mancano
## c'è un indizio di come scoprirle. Lo scrive l'Erbario (scheda Famiglie, e sotto ogni creatura).

const WATCH := 3                       # sconfitte per capire la catena alimentare e dove vive
const ROLES := {"erbivoro": "Erbivori: brucano erba e fiori.", "predatore": "Predatori: cacciano altre famiglie.",
	"colonia": "Vivono in colonie.", "volante": "Volano.", "scavatore": "Scavano nella terra.", "neutro": "Vivono per conto loro."}
const NESTS := {"erba": "nidi d'erba", "tana": "tane", "alveare": "alveari", "formicaio": "formicai"}
const Q := "[color=#6a8a84]"
const E := "[/color]"


static func kills_of(ch: Character, fam: String) -> int:
	var n := 0
	for s in FamiliesData.FAMILIES[fam]["members"]:
		n += int((ch.erbario.get("creature", {}) as Dictionary).get(s, 0))
	return n


static func _names(fams: Array) -> String:
	var out := []
	for f in fams:
		out.append(String(FamiliesData.FAMILIES[f]["name"]).to_lower())
	return ", ".join(out)


## Quante varianti possibili ha una specie (taglie × elementi × indoli, compresa quella normale).
static func variants_total() -> int:
	return (FamiliesData.SIZES.size() + 1) * (FamiliesData.ELEM_ADJ.size() + 1) * (FamiliesData.TEMPERS.size() + 1)


static func variants_seen(ch: Character, fam: String) -> int:
	var n := 0
	for v in (ch.erbario.get("varianti", {}) as Dictionary):
		if FamiliesData.family_of(CreaturesData.base_of(String(v))) == fam:
			n += 1
	return n


## La scheda di una famiglia, in BBCode.
static func family(ch: Character, fam: String) -> String:
	var fd: Dictionary = FamiliesData.FAMILIES[fam]
	var eb := ch.erbario
	var kills := kills_of(ch, fam)
	var tamed := int((eb.get("addomesticate", {}) as Dictionary).get(fam, 0))
	var t := "[color=#cfeee4]%s[/color]\n" % ROLES.get(String(fd.get("role", "")), "Vivono per conto loro.")
	var mem := []
	for s in fd["members"]:
		mem.append(String(CreaturesData.CREATURES[s]["name"]) if (eb.get("creature", {}) as Dictionary).has(s) or tamed > 0 else "???")
	t += "[color=#9fc8c0]Specie: %s · sconfitte %d · addomesticate %d[/color]\n" % [", ".join(mem), kills, tamed]
	t += "[color=#9fc8c0]Varianti viste: %d su %d[/color] %s(taglia, elemento, indole: ognuna ha i suoi colori e i suoi valori)%s\n" % [
		variants_seen(ch, fam), variants_total() * (fd["members"] as Array).size(), Q, E]
	# dove vive
	if kills >= WATCH or tamed > 0:
		var where := {}
		for s in fd["members"]:
			var cd: Dictionary = CreaturesData.CREATURES[s]
			if cd.has("sky"):                            # Roadmap 16: le creature del cielo
				where["nel cielo: " + String(SkyData.get_biome(String(cd["sky"])).get("name", cd["sky"]))] = true
				continue
			for st in cd.get("strata", []):
				where[String(StrataData.STRATA[st]["name"])] = true
			for b in cd.get("biomes", []):
				where[BiomesData.name_of(String(b))] = true
		t += "[color=#9fc8c0]Dove vive: %s[/color]\n" % ", ".join(where.keys())
	else:
		t += "%sDove vive: ? (sconfiggine %d per capirlo)%s\n" % [Q, WATCH, E]
	# la catena alimentare
	var hunters := []
	for f in FamiliesData.FAMILIES:
		if fam in (FamiliesData.FAMILIES[f].get("prey", []) as Array):
			hunters.append(f)
	if kills >= WATCH or tamed > 0:
		if fd.has("prey"):
			t += "[color=#9fc8c0]Caccia: %s[/color]\n" % _names(fd["prey"])
		if not hunters.is_empty():
			t += "[color=#9fc8c0]La cacciano: %s (dove loro sono tante, lei è più rara)[/color]\n" % _names(hunters)
		if fd.get("pest", false):
			t += "[color=#ffb84a]Mangia anche le colture del giardino[/color]\n"
		if fd.get("migrate", false):
			t += "[color=#9fc8c0]All'alba e al tramonto i branchi migrano[/color]\n"
	elif fd.has("prey") or not hunters.is_empty():
		t += "%sCatena alimentare: ? (osservala, o sconfiggine %d)%s\n" % [Q, WATCH, E]
	# i nidi
	if fd.has("nest"):
		var nd: Dictionary = fd["nest"]
		if (eb.get("nidi", {}) as Dictionary).has(fam):
			t += "[color=#9fc8c0]Fa %s: un uovo ogni %d minuti circa, di più se li nutri; distruggerli svuota la zona[/color]\n" % [
				NESTS.get(String(nd["type"]), "nidi"), roundi(240.0 / 60.0)]
		else:
			t += "%sFa %s da qualche parte nel mondo: cercali e prendi un uovo (clic destro)%s\n" % [Q,
				NESTS.get(String(nd["type"]), "nidi"), E]
	# l'addomesticamento
	var tm := HerdData.tame_of(fam)
	if tm.is_empty():
		t += "[color=#ffb84a]Non si lascia addomesticare[/color]\n"
		return t
	var diff := int(tm["diff"])
	t += "[color=#8ef0d8]Si addomestica[/color] [color=#9fc8c0](difficoltà %s)[/color]\n" % ("★".repeat(diff) + "☆".repeat(5 - diff))
	if (eb.get("diete", {}) as Dictionary).has(fam) or kills >= HerdData.STUDY:
		t += "[color=#9fc8c0]Mangia: %s[/color]\n" % HerdInfo.diet_text(fam)
	else:
		t += "%sMangia: ? (prova a darle da mangiare, o sconfiggine %d)%s\n" % [Q, HerdData.STUDY, E]
	if tamed > 0:
		var p: Array = tm["produce"]
		t += "[color=#9fc8c0]Nel recinto: %s[/color]\n" % String(ItemsData.get_item(String(p[0]))["name"]).to_lower()
		if tm.has("aid_text"):
			t += "[color=#8ef0d8]Quando ti segue: %s[/color]\n" % tm["aid_text"]
		if tm.has("mount_text"):
			t += "[color=#8ef0d8]Si cavalca: %s[/color]\n" % tm["mount_text"]
	else:
		t += "%sCosa dà nel recinto, come ti aiuta, se si cavalca: addomesticane una per saperlo%s\n" % [Q, E]
	return t


## Le righe in più sotto una creatura dell'Erbario: famiglia, varianti viste, e se si addomestica.
static func creature_extra(ch: Character, id: String) -> String:
	var fam := FamiliesData.family_of(id)
	if fam == "":
		return ""
	var n := 0
	for v in (ch.erbario.get("varianti", {}) as Dictionary):
		if CreaturesData.base_of(String(v)) == id:
			n += 1
	var t := "\n[color=#9fc8c0]Famiglia: %s · varianti viste %d su %d[/color]" % [FamiliesData.FAMILIES[fam]["name"], n, variants_total()]
	if not HerdData.tame_of(fam).is_empty():
		t += "\n[color=#8ef0d8]Si addomestica: vedi la scheda Famiglie[/color]"
	return t


const ROLE_GENE := {"erbivoro": "Pascoli", "predatore": "Cacciatori", "colonia": "Alveari"}


## Una famiglia mai incontrata: dove cercarla, a grandi linee (strati e biomi delle sue specie, il gene che la rende
## più comune).
static func hint(fam: String) -> String:
	var fd: Dictionary = FamiliesData.FAMILIES[fam]
	var where := {}
	for s in fd["members"]:
		var cd: Dictionary = CreaturesData.CREATURES[s]
		if cd.has("sky"):                                # Roadmap 16: in cielo, nel suo bioma
			where["nel cielo: " + String(SkyData.get_biome(String(cd["sky"])).get("name", cd["sky"]))] = true
			continue
		for st in cd.get("strata", []):
			where[String(StrataData.STRATA[st]["name"]).to_lower()] = true
		for b in cd.get("biomes", []):
			where[BiomesData.name_of(String(b))] = true
		if cd.get("night", false):
			where["di notte"] = true
	var t := "[color=#6a8a84]Non l'hai ancora incontrata.[/color]\n"
	t += "[color=#9fc8c0]Cercala: %s.[/color]\n" % (", ".join(where.keys()) if not where.is_empty() else "in luoghi speciali")
	var role := String(fd.get("role", ""))
	if ROLE_GENE.has(role):
		t += "[color=#9fc8c0]È più comune nei mondi con il gene %s (i Semi con quel gene, al Semenzaio).[/color]\n" % ROLE_GENE[role]
	t += "[color=#9fc8c0]Ogni mondo ha tre famiglie favorite e due assenti: se qui non c'è, prova un altro Seme.[/color]"
	return t


## I manti visti nascere, per la scheda Famiglie.
static func coats_line(ch: Character) -> String:
	var seen: Dictionary = ch.erbario.get("manti", {})
	var names := []
	for c in BreedData.COATS:
		if c != "":
			names.append(("[color=#ffd24a]%s[/color]" if BreedData.is_rare(c) else "%s") % BreedData.COATS[c]["name"] if seen.has(c) else "?")
	return "[color=#9fc8c0]Manti visti nascere: %d su %d — %s[/color]" % [seen.size(), BreedData.COATS.size() - 1, ", ".join(names)]
