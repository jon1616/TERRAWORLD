class_name JewelsData
## Amuleti e anelli (voce 86, Roadmap 12): una gemma incastonata in un metallo. Solo dati; gli oggetti e le ricette
## nascono da GEMS × i metalli di `MaterialsData.MATERIALS` (4 × 9 × 2 = 72 oggetti).
##   l'**amuleto** dà la qualità della gemma, più forte più il metallo è di grado alto ("amulet": per grado)
##   l'**anello** dà l'effetto speciale della gemma (`EffectsData`, uguale per tutti i metalli) e un po' della qualità
## Si fanno alla Mola del gemmaio: lingotti del metallo e la gemma.
## Roadmap 31, voce 308: la montatura aggiunge il **carattere** del suo metallo (`MaterialsData.trait_acc`: metà
## nell'amuleto, tre decimi nell'anello), così due gioielli della stessa gemma e dello stesso grado non sono uguali.

## Roadmap 52, voce 414: più le gemme dei pacchetti (campo «gems»: candorina, muschiata, fiammina, ombrina).
static var GEMS: Dictionary = _GEMS.merged(BiomesData.pack("gems"))
const _GEMS := {
	"brillaluce": {"name": "brillaluce", "amulet": {"halo": 0.08, "luck": 0.02}, "effect": "cielo_aperto"},
	"sanguinella": {"name": "sanguinella", "amulet": {"damage": 0.03}, "effect": "furia_bassa"},
	"lagunite": {"name": "lagunite", "amulet": {"regen": 0.06, "respiro": 0.2}, "effect": "rigenera_fermo"},
	"nottilite": {"name": "nottilite", "amulet": {"stealth": -0.03, "magic": 0.03}, "effect": "notturno"},
}
## Le chiavi che si sommano (le altre moltiplicano, partendo da 1).
const ADD := ["luck"]


static func amulet_id(gem: String, mat: String) -> String:
	return "amuleto_%s_%s" % [gem, mat]


static func ring_id(gem: String, mat: String) -> String:
	return "anello_%s_%s" % [gem, mat]


static func _acc(gem: String, tier: int, share: float) -> Dictionary:
	var out := {}
	var a: Dictionary = GEMS[gem]["amulet"]
	for k in a:
		var v := float(a[k]) * tier * share
		out[k] = snappedf(v, 0.001) if k in ADD else snappedf(1.0 + v, 0.001)
	return out


static func items() -> Dictionary:
	var out := {}
	for gem in GEMS:
		var gd: Dictionary = GEMS[gem]
		for mat in MaterialsData.MATERIALS:
			var md: Dictionary = MaterialsData.MATERIALS[mat]
			var tier := int(md["tier"])
			var label := String(md["label"])
			var frame := String(md.get("icon", mat))     # la montatura del metallo nell'icona (29 set 2026)
			out[amulet_id(gem, mat)] = {"name": "Amuleto di %s %s" % [gd["name"], label], "kind": "amuleto",
				"icon": ["amuleto", frame, gem], "tier": tier, "stack": 1, "gen": true,
				"acc": MaterialsData.merge_acc(_acc(gem, tier, 1.0), MaterialsData.trait_acc(mat, float(MaterialsData.SHARE["amuleto"]))),
				"desc": "Una %s incastonata %s." % [gd["name"], label]}
			out[ring_id(gem, mat)] = {"name": "Anello di %s %s" % [gd["name"], label], "kind": "anello",
				"icon": ["anello", frame, gem], "tier": tier, "stack": 1, "effects": [gd["effect"]],
				"acc": MaterialsData.merge_acc(_acc(gem, tier, 0.4), MaterialsData.trait_acc(mat, float(MaterialsData.SHARE["anello"]))),
				"gen": true, "desc": "Una %s incastonata %s." % [gd["name"], label]}
	return out


static func recipes() -> Array:
	var out := []
	for gem in GEMS:
		for mat in MaterialsData.MATERIALS:
			var md: Dictionary = MaterialsData.MATERIALS[mat]
			var bar := String(md["bar"])
			var n := 1 + int(md["tier"]) / 2
			out.append({"out": amulet_id(gem, mat), "qty": 1, "in": {bar: 4, gem: n}, "station": "mola"})
			out.append({"out": ring_id(gem, mat), "qty": 1, "in": {bar: 2, gem: n + 1}, "station": "mola"})
	return out
