extends SceneTree
## La mappa degli ecosistemi (voce 126, Roadmap 15 «Il mondo abitato»). Per ogni zona (i biomi di superficie, gli
## strati sotto terra, i biomi del sottosuolo con creature proprie, i liquidi) dice quali specie ci vivono, con che
## **ruoli** e con quanti **modi d'attacco** diversi, e segna i buchi: la regola della Roadmap è almeno `MIN_ROLES` ruoli
## e almeno `MIN_MODES` modi d'attacco per zona. Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/ecosistemi.gd
## Scrive prove/ecosistemi.txt e lo stampa. Le voci 132-134 riempiono i buchi che mostra.

const MIN_ROLES := 5
const MIN_MODES := 3
const MIN_OWN := 3                        # specie proprie di un bioma (quelle che lo rendono diverso dagli altri)
## Il modo d'attacco di ogni comportamento ("" = non attacca: si muove, fugge, pascola…).
const MODE := {
	"cammina": "contatto", "salta_verso": "salto", "vola": "volo", "carica": "carica", "scatto": "carica",
	"spara": "proiettile", "ventaglio": "proiettile", "bombarda": "dall'alto", "agguato": "agguato",
	"scava": "sbuca", "teletrasporto": "teletrasporto", "evoca": "evoca", "mimo": "mimetico", "guscio": "difesa",
	"nuota": "acqua", "caccia": "", "pascola": "", "fugge": "", "mandria": "",
	# voce 130: le astuzie
	"sbuca": "sbuca", "divide": "divide", "ladro": "ruba", "mimetico": "mimetico", "scudo": "difesa", "guaritore": "cura",
	"richiamo": "evoca", "parassita": "parassita", "tuffatore": "balzo", "tessitore": "ragnatela", "rosicchia": "",
	"fotofobo": "buio", "pastore": "gregge", "scoppia": "scoppio",
}

var out := ""


func _init() -> void:
	var zones := []                         # [nome, [id creatura…]]
	for b in BiomesData.BIOMES:
		var bid := String(b["id"])
		var list := []
		for cid in CreaturesData.CREATURES:
			var c: Dictionary = CreaturesData.CREATURES[cid]
			if c.get("boss", false) or not 0 in (c.get("strata", []) as Array):
				continue
			if c.has("biomes") and not bid in (c["biomes"] as Array):
				continue
			list.append(String(cid))
		zones.append(["superficie · %s" % b["name"], list, list.filter(func(i: String) -> bool:
			return (CreaturesData.CREATURES[i].get("biomes", []) as Array).has(bid))])
	for s in range(1, StrataData.STRATA.size()):
		var list := []
		for cid in CreaturesData.CREATURES:
			var c: Dictionary = CreaturesData.CREATURES[cid]
			if not c.get("boss", false) and s in (c.get("strata", []) as Array):
				list.append(String(cid))
		zones.append(["strato · %s" % StrataData.STRATA[s]["name"], list])
	for u in BiomesData.UNDER:
		# voce 133: anche le creature dei pacchetti del bestiario con «under»
		var ids := []
		for cid in CreaturesData.CREATURES:
			if String(CreaturesData.CREATURES[cid].get("under", "")) == String(u["id"]):
				ids.append(String(cid))
		if not ids.is_empty():
			zones.append(["sottosuolo · %s" % u.get("name", u["id"]), ids])
	var water := []
	for cid in CreaturesData.CREATURES:
		if "nuota" in (CreaturesData.CREATURES[cid].get("behaviors", []) as Array):
			water.append(String(cid))
	zones.append(["liquidi", water])
	var gaps := 0
	_p("MAPPA DEGLI ECOSISTEMI: %d specie, %d famiglie (regola: almeno %d ruoli e %d modi d'attacco per zona, %d specie proprie per bioma)" % [
		CreaturesData.CREATURES.size(), FamiliesData.FAMILIES.size(), MIN_ROLES, MIN_MODES, MIN_OWN])
	for z in zones:
		var roles := {}
		var modes := {}
		for cid in z[1]:
			for r in roles_of(String(cid)):
				roles[r] = int(roles.get(r, 0)) + 1
			for mo in modes_of(String(cid)):
				modes[mo] = int(modes.get(mo, 0)) + 1
		var own: Array = z[2] if z.size() > 2 else []
		var own_modes := {}
		for cid in own:
			for mo in modes_of(String(cid)):
				own_modes[mo] = true
		var bad: bool = roles.size() < MIN_ROLES or modes.size() < MIN_MODES or (z.size() > 2 and own.size() < MIN_OWN)
		if bad:
			gaps += 1
		_p("%s %-38s %2d specie%s · ruoli %d %s · modi %d %s" % ["!" if bad else " ", z[0], (z[1] as Array).size(),
			(" (proprie %d, modi propri %s)" % [own.size(), own_modes.keys()]) if z.size() > 2 else "", roles.size(),
			roles.keys(), modes.size(), modes.keys()])
	# i comportamenti usati e quelli mai usati
	var used := {}
	for cid in CreaturesData.CREATURES:
		for bh in CreaturesData.CREATURES[cid].get("behaviors", []):
			used[bh] = int(used.get(bh, 0)) + 1
	_p("\nzone con un buco: %d su %d" % [gaps, zones.size()])
	_p("comportamenti usati (specie): %s" % used)
	var f := FileAccess.open("res://prove/ecosistemi.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)
		f.close()
	print(out)
	quit()


func _p(t: String) -> void:
	out += t + "\n"


## I ruoli di una creatura: quello della sua famiglia e quelli che si vedono dai dati (notturna, volante, acquatica,
## sciame, scavatrice, rara, mini-boss).
static func roles_of(cid: String) -> Array:
	var c: Dictionary = CreaturesData.CREATURES[cid]
	var out := []
	var fam := FamiliesData.family_of(cid)
	if fam != "":
		out.append(String(FamiliesData.FAMILIES[fam].get("role", "neutro")))
	if c.get("night", false):
		out.append("notturno")
	if c.get("fly", false):
		out.append("volante")
	var bh: Array = c.get("behaviors", [])
	if "nuota" in bh:
		out.append("acquatico")
	if "scava" in bh:
		out.append("scavatore")
	if c.has("group"):
		out.append("sciame")
	if int(c.get("weight", 5)) <= 2:
		out.append("raro")
	if c.get("lord", false):
		out.append("signore")
	return out


static func modes_of(cid: String) -> Array:
	var out := []
	for bh in CreaturesData.CREATURES[cid].get("behaviors", []):
		var mo := String(MODE.get(String(bh), String(bh)))
		if mo != "" and not mo in out:
			out.append(mo)
	return out
