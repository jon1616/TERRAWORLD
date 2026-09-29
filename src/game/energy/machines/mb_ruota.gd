class_name MbRuota
extends MachineBehavior
## La Ruota d'acqua: l'acqua che la bagna (le celle d'acqua che toccano i suoi lati e il suo tetto) la fa girare, 5
## pulsi per cella, fino ai pulsi dei dati; l'acqua che si sta muovendo adesso (le celle attive dei liquidi) conta il
## 50% in più. Si legge il mondo com'è: niente calcolo dei liquidi lontani.

const PER_CELL := 5.0
const MOVING := 1.5


func produce(mc: Machine, e: Energy) -> float:
	var w: World = e.m.world
	var sz := mc.size()
	var cells: Array[Vector2i] = []
	for dy in sz.y:
		cells.append(Vector2i(mc.o.x - 1, mc.o.y + dy))
		cells.append(Vector2i(mc.o.x + sz.x, mc.o.y + dy))
	for dx in sz.x:
		cells.append(Vector2i(mc.o.x + dx, mc.o.y - 1))
	var active: Dictionary = e.m.liquids.active if e.m.get("liquids") != null else {}
	var sum := 0.0
	for c in cells:
		if w.liq(c.x, c.y) >= 4 and w.liq_type(c.x, c.y) == LiquidsData.ACQUA:
			sum += PER_CELL * (MOVING if active.has(c.y * w.w + c.x) else 1.0)
	return minf(sum, float(mc.d["pulsi"]))
