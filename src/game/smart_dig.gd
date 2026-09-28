class_name SmartDig
extends RefCounted
## Lo scavo intelligente (29 set 2026, richiesta dell'utente): tenendo premuto il piccone con il mouse su una cella
## vuota, si scavano uno dopo l'altro i blocchi a portata, prima i più vicini al mouse. Le regole che lo rendono sicuro:
## - solo la terra del mondo: mai costrutti, mattoni, vetro, porte, sigilli (ciò che hai costruito resta);
## - mai il blocco sotto i piedi, né quello sotto un albero o una stazione;
## - mai un blocco che tocca un liquido (non ti allaga);
## - solo i blocchi che toccano l'aria: avanza come uno scavo vero, non buca la roccia a caso;
## - con il tasto «vena» (Maiusc) tenuto all'inizio, solo i blocchi dello stesso tipo del primo (seguire un minerale).
## Il bersaglio scelto resta lo stesso finché non si rompe (il mouse che si sposta non fa saltare da un blocco all'altro).
## Si spegne nelle Opzioni («scavo_intelligente»); lo chiama `PlayerActions._process`.

const S := 16

var target := Vector2i(-1, -1)
var vein := -1                         # il tipo di blocco da seguire (-1: tutti)
var _vein_asked := false


## Il piccone è stato lasciato: la prossima pressione ricomincia da capo.
func reset() -> void:
	target = Vector2i(-1, -1)
	vein = -1
	_vein_asked = false


## La cella da scavare adesso: `c` (sotto il mouse) se è una cella che il giocatore indica da sé, altrimenti il blocco
## più vicino al mouse tra quelli ammessi (o (-1, -1) se non ce n'è).
func pick(pa: PlayerActions, c: Vector2i, mouse: Vector2, item: Dictionary) -> Vector2i:
	var w := pa.world
	if not _vein_asked:
		_vein_asked = true
		if Keys.held("vena") and w.solid(c.x, c.y):
			vein = w.tile(c.x, c.y)
	# il mouse indica un blocco, una decorazione, una torcia, una stazione: si fa come sempre
	if not w.inside(c.x, c.y) or w.solid(c.x, c.y) or w.decor_at(c.x, c.y) != 0 or w.torches.has(c) \
			or w.plat(c.x, c.y) or not w.station_at(c).is_empty():
		if w.solid(c.x, c.y) and vein < 0 and Keys.held("vena"):
			vein = w.tile(c.x, c.y)
		target = Vector2i(-1, -1)
		return c
	var power := int(ItemsData.get_item(String(item["id"])).get("power", 0))
	if target.x >= 0 and pa.in_reach(target) and allowed(pa, target, power):
		return target
	target = Vector2i(-1, -1)
	var best := INF
	var r := int(ceil(PlayerActions.REACH / S)) + 1
	var pc := Vector2i(floori(pa.player.position.x / S), floori(pa.player.position.y / S))
	for y in range(pc.y - r, pc.y + r + 1):
		for x in range(pc.x - r, pc.x + r + 1):
			var k := Vector2i(x, y)
			if not pa.in_reach(k) or not allowed(pa, k, power):
				continue
			var d := (Vector2(k) * S + Vector2(8, 8)).distance_squared_to(mouse)
			if d < best:
				best = d
				target = k
	return target if target.x >= 0 else c


## Un blocco che lo scavo intelligente può prendere da sé.
func allowed(pa: PlayerActions, k: Vector2i, power: int) -> bool:
	var w := pa.world
	if not w.inside(k.x, k.y) or k.y >= w.h - 1 or not w.solid(k.x, k.y):
		return false
	var t := w.tile(k.x, k.y)
	if vein >= 0 and t != vein:
		return false
	if t in TileDefs.BUILT or t == TileDefs.PORTA or t == TileDefs.PORTA_SEM or w.build_at(k.x, k.y) > 0:
		return false
	if power < int(TileDefs.POWER.get(t, 0)):
		return false
	# sotto i piedi
	var p := pa.player.position
	var feet := floori((p.y + Player.HALF.y + 1.0) / S)
	if k.y == feet and k.x >= floori((p.x - Player.HALF.x) / S) and k.x <= floori((p.x + Player.HALF.x - 0.1) / S):
		return false
	# sotto un albero o una stazione
	var up := k + Vector2i(0, -1)
	var tr := w.tree_at(up)
	if tr.x == up.x and tr.y == up.y:
		return false
	if not w.station_at(up).is_empty():
		return false
	# tocca l'aria, e non un liquido
	var open := false
	for dv in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var n: Vector2i = k + dv
		if w.liq(n.x, n.y) > 0:
			return false
		if not w.solid(n.x, n.y):
			open = true
	return open
