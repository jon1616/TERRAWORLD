class_name PassCollaudo
extends GenPass
## Il collaudatore (pulizia del generatore, 28 set 2026): l'ultima passata controlla le promesse di ogni mondo e ripara
## ciò che può. Le promesse:
## - le strutture non si sovrappongono (la mappa dei posti, `GenContext.claim`);
## - il Cuore del mondo c'è, e c'è la firma (non nel Giardino);
## - la partenza è sicura: aria per il corpo, un pavimento sotto, niente liquido né rovi o rune trappola vicini;
## - ogni stazione sta dentro il mondo, non ne copre un'altra e non è murata nella roccia.
## Scrive `notes["collaudo"]` = {"problemi": [...], "riparati": [...]}: le prove e `tools/mappe.gd` li leggono.

const SAFE := 3                        # tessere attorno alla partenza senza pericoli


func title() -> String:
	return "Collaudo"


func run(w: World, c: GenContext) -> void:
	var problems: Array[String] = []
	var fixed: Array[String] = []
	var garden := bool(c.params.get("giardino", false))
	# 1. strutture sovrapposte
	for i in c.claims.size():
		for j in range(i + 1, c.claims.size()):
			if (c.claims[i][0] as Rect2i).intersects(c.claims[j][0]):
				problems.append("sovrapposte: %s e %s a %s" % [c.claims[i][1], c.claims[j][1], (c.claims[j][0] as Rect2i).position])
	# 2. il Cuore e la firma
	if not garden:
		if not w.stations.values().has("cuore_mondo"):
			problems.append("manca il Cuore del mondo")
		if (c.notes.get("firma", {}) as Dictionary).is_empty():
			problems.append("manca la firma del mondo")
	# 3. la partenza
	_start(w, fixed)
	# 4. le stazioni
	_stations(w, c, problems, fixed)
	# 5. (voce 474) le liane su ogni parete più alta del salto, ancora una volta: le passate dopo `PassRocce` (la firma, le
	# tracce, i riferimenti, i laghi) fanno pareti nuove
	if not garden:
		PassRocce._wall_vines(w)
	# 6. quanto si raggiunge a piedi dalla partenza (`ReachMap`): solo su richiesta, costa ~1,5 s
	if bool(c.params.get("raggiungibile", false)) and not garden:
		var reach := reach_of(w, c.notes.get("correnti", []))
		c.notes["raggiungibile"] = reach
		if float(reach["superficie"]) < MIN_SURFACE:
			problems.append("la superficie si percorre a piedi solo per il %d%%" % roundi(100.0 * float(reach["superficie"])))
	c.notes["collaudo"] = {"problemi": problems, "riparati": fixed}


## La quota delle colonne di superficie che si raggiungono dalla partenza senza scavare (`ReachMap`): sotto, un problema.
const MIN_SURFACE := 0.85


## Quanto si raggiunge dalla partenza senza scavare: la quota delle colonne di superficie (un posto raggiunto entro 8 righe
## sopra o 8 sotto la terra: le bocche delle caverne scavano la cima del terreno senza cambiare `surface`) e i posti raggiunti in tutto. Lo usa anche la prova del gruppo «base».
static func reach_of(w: World, currents: Array) -> Dictionary:
	var r := ReachMap.of(w, currents)
	var cols := 0
	for x in w.w:
		var s := int(w.surface[x])
		for y in range(s - 8, s + 9):
			if r.at(x, y) >= 0:
				cols += 1
				break
	return {"superficie": float(cols) / w.w, "posti": r.reached}


## La partenza: il corpo (due tessere) nell'aria, un pavimento sotto, niente liquidi né pericoli vicino.
func _start(w: World, fixed: Array[String]) -> void:
	var s := w.spawn
	if not w.inside(s.x, s.y - 1) or not w.inside(s.x, s.y + 1):
		return
	for dy in [0, -1]:
		if w.solid(s.x, s.y + dy):
			w.set_tile(s.x, s.y + dy, TileDefs.AIR)
			fixed.append("partenza: tolta la roccia sul corpo")
		if w.liquid[(s.y + dy) * w.w + s.x] != 0:
			w.liquid[(s.y + dy) * w.w + s.x] = 0
			fixed.append("partenza: tolto il liquido")
	if not w.solid(s.x, s.y + 1):
		w.set_tile(s.x, s.y + 1, TileDefs.DIRT)
		fixed.append("partenza: messo il pavimento")
	for y in range(s.y - SAFE, s.y + SAFE + 1):
		for x in range(s.x - SAFE, s.x + SAFE + 1):
			if w.inside(x, y) and w.decor_at(x, y) in [TileDefs.DECOR_ROVO, TileDefs.DECOR_TRAP]:
				w.set_decor(x, y, 0)
				fixed.append("partenza: tolto un pericolo")


## Le stazioni: dentro il mondo, una sola per cella, non murate (le celle che coprono sono aria).
func _stations(w: World, c: GenContext, problems: Array[String], fixed: Array[String]) -> void:
	var owner := {}
	for o: Vector2i in w.stations:
		var id := String(w.stations[o])
		var size: Array = StationsData.STATIONS.get(id, {}).get("size", [1, 1])
		for dy in int(size[1]):
			for dx in int(size[0]):
				var q := o + Vector2i(dx, dy)
				if not w.inside(q.x, q.y):
					problems.append("stazione %s fuori dal mondo a %s" % [id, o])
					continue
				if owner.has(q):
					problems.append("stazioni una sopra l'altra: %s e %s a %s" % [owner[q], id, q])
				owner[q] = id
				if w.solid(q.x, q.y):
					w.set_tile(q.x, q.y, TileDefs.AIR)
					var inside := []
					for cl in c.claims:
						if (cl[0] as Rect2i).has_point(q):
							inside.append(cl[1])
					fixed.append("stazione %s a %s liberata dalla roccia (dentro: %s)" % [id, q, inside])
