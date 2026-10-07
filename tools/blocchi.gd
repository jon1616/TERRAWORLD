extends SceneTree
## Roadmap 52 «La terra dei mondi»: le tessere e le cose piazzabili del gioco contate per categorie, accanto ai numeri
## di Terraria (la tabella dell'EstrattoreDati dell'utente, solo ciò che ha una funzione: 66 terreni, 22 minerali, 8 gemme,
## 21 blocchi con un effetto, 20 tra liane, corde e spine, 38 postazioni, 9 contenitori, 7 piattaforme, 171 mobili).
## Poi l'elenco di ogni tessera con il suo tipo e il suo comportamento. Uscita in prove/blocchi.txt.
##   Godot_console.exe --headless --path . --script res://tools/blocchi.gd

## Le tessere scritte a mano in `TileDefs`, per categoria (quelle dei pacchetti hanno il campo «kind»).
const NATURAL_BASE := [1, 3, 8, 9, 10, 15, 16, 17, 31, 42, 51, 52, 53, 56]
const MINERAL_BASE := [4, 5, 6, 7, 18, 19, 40, 55, 57, 58]
const SPECIAL_BASE := [11, 12, 23, 26, 27, 28, 29, 30, 43, 47]      # nodi, sigilli, porte, pietre delle rovine, pareti finte
const TERRARIA := {"terreni": 66, "minerali": 22, "gemme": 8, "effetto": 21, "corde": 20, "postazioni": 38, "contenitori": 9,
	"piattaforme": 7, "mobili": 171}


func _init() -> void:
	var out := PackedStringArray()
	var natural := []
	var minerals := []
	var gems := []
	var special := []
	var built := []
	for t in range(1, TileDefs.TYPES + 1):
		if String(TileDefs.NAMES.get(t, "")) == "":
			continue
		var k := TileDefs.kind_of(t)
		if t in TileDefs.GRASSES or t in NATURAL_BASE or k in ["suolo", "roccia", "comune"]:
			natural.append(t)
		elif t in MINERAL_BASE or k == "minerale":
			minerals.append(t)
		elif k == "gemma":
			gems.append(t)
		elif t in SPECIAL_BASE:
			special.append(t)
		else:
			built.append(t)
	# i blocchi che fanno qualcosa: un comportamento delle tabelle di `TileDefs`, la luce, o un'apertura speciale
	var effect := []
	for t in range(1, TileDefs.TYPES + 1):
		if String(TileDefs.NAMES.get(t, "")) == "":
			continue
		if _behaviour(t) != "" or t in [22, 26, 27, 28, 29, 30, 47, 52, 53]:
			effect.append(t)
	var stations := {}
	for r in RecipesData.all():
		if String(r.get("station", "")) != "":
			stations[String(r["station"])] = true
	var chests := 0
	var furniture := 0
	for s in StationsData.STATIONS:
		if ChestsData.is_chest(String(s)):
			chests += 1
		elif not stations.has(String(s)):
			furniture += 1
	var ropes := TileDefs.CLIMBS.size() + 2 + TileDefs.THORNS.size()   # corde; rovo e runa trappola; spine dei biomi e ragnatela
	var plats := 1 + TileDefs.PLATS.size()
	var rows := [
		["Terreni e rocce naturali", natural.size(), "terreni", "%d erbe, %d terre, %d rocce, %d terre comuni, %d altre" % [
			TileDefs.GRASSES.size(), _count("suolo"), _count("roccia"), _count("comune"),
			natural.size() - TileDefs.GRASSES.size() - _count("suolo") - _count("roccia") - _count("comune")]],
		["Minerali (vene visibili)", minerals.size(), "minerali", "5 metalli, 12 della spina e del dopo, cristalli, nimbite, folgorite"],
		["Gemme nella roccia", gems.size(), "gemme", "più %d grappoli sui pavimenti" % TileDefs.DECOR_GEMS.size()],
		["Blocchi con un effetto", effect.size(), "effetto", "franare, scivolare, appiccicare, attutire, rimbalzare, crollare, pungere, scaldare, luce…"],
		["Liane, corde, spine", ropes, "corde", "corda, liana, catena, rovo spinoso, runa trappola, quattro spine dei biomi, ragnatela"],
		["Postazioni di creazione", stations.size(), "postazioni", ""],
		["Contenitori", chests, "contenitori", "a gradi, dei biomi, sigillate, la Dispensa"],
		["Piattaforme", plats, "piattaforme", "radice, nuvola, bava, rovo, ghiaccio, vento"],
		["Mobili e oggetti con una funzione", furniture, "mobili", "macchine, trappole, totem, nidi, meccanismi, fonti…"],
	]
	out.append("== Le tessere a confronto con Terraria (solo ciò che ha una funzione) ==")
	out.append("%-36s %6s %9s   %s" % ["categoria", "noi", "Terraria", ""])
	for r in rows:
		out.append("%-36s %6d %9d   %s" % [r[0], r[1], int(TERRARIA[r[2]]), r[3]])
	out.append("%-36s %6d %9s   %s" % ["Blocchi da costruzione (forme × materiali)", BuildData.kinds().size(), "estetici",
		"ognuno con isolamento, luce, bellezza, resistenza"])
	out.append("%-36s %6d %9d" % ["Liquidi", LiquidsData.TYPES.size(), 4])
	out.append("Tessere speciali (sigilli, porte, nodi, rovine): %d; costruite: %d" % [special.size(), built.size()])
	out.append("\n== Ogni tessera ==")
	for t in range(1, TileDefs.TYPES + 1):
		var nm := String(TileDefs.NAMES.get(t, ""))
		if nm == "":
			continue
		var k := TileDefs.kind_of(t)
		if k == "":
			k = "erba" if t in TileDefs.GRASSES else ("minerale" if t in minerals else ("naturale" if t in natural else ("speciale" if t in special else "costruita")))
		out.append("%3d  %-28s %-9s forza %3d  lascia %-22s %s" % [t, nm, k, int(TileDefs.POWER.get(t, 0)),
			String(TileDefs.DROP.get(t, "")), _behaviour(t)])
	var f := FileAccess.open("res://prove/blocchi.txt", FileAccess.WRITE)
	f.store_string("\n".join(out))
	print("\n".join(out))
	quit()


static func _count(kind: String) -> int:
	var n := 0
	for t in TileDefs.KIND:
		if TileDefs.kind_of(int(t)) == kind:
			n += 1
	return n


## Che cosa fa una tessera (dalle stesse tabelle che legge il gioco).
static func _behaviour(t: int) -> String:
	var b := []
	if TileDefs.FALLS[t] == 1:
		b.append("frana")
	if TileDefs.SLIP[t] < 1.0:
		b.append("scivola")
	if TileDefs.STICK[t] < 1.0:
		b.append("appiccica")
	if TileDefs.SOFT[t] < 1.0:
		b.append("attutisce")
	if TileDefs.BOUNCE[t] > 0.0:
		b.append("rimbalza")
	if TileDefs.FRAGILE[t] > 0.0:
		b.append("crolla")
	if TileDefs.SPIKE[t] > 0.0:
		b.append("punge")
	if TileDefs.WARM[t] == 1:
		b.append("scalda")
	if TileDefs.LIQ_PASS[t] == 1:
		b.append("lascia passare i liquidi")
	if TileDefs.BLAST[t] == 1:
		b.append("regge le esplosioni")
	if TileDefs.QUIET[t] == 1:
		b.append("passi muti")
	if TileDefs.FERTILE[t] > 1.0:
		b.append("fertile")
	if TileDefs.FOSSIL[t] > 0.0:
		b.append("fossili")
	if TileDefs.DORMANT[t] == 1:
		b.append("dorme fino al Risveglio")
	if TileDefs.LIGHT_EMIT[t].r + TileDefs.LIGHT_EMIT[t].g + TileDefs.LIGHT_EMIT[t].b > 0.0:
		b.append("fa luce")
	return ", ".join(b)
