class_name BoonsData
## Gli effetti a tempo scritti come dati (Roadmap 46, voce 398; prima ogni effetto era scritto a mano in `Boons`).
## Li portano i pacchetti (campo «boons», le pozioni, le fiale e i piatti di `src/data/vastita/consumabili.gd`); un
## consumabile li accende con il suo campo "boon": [id, secondi] (o "boons" per più d'uno). Campi:
##   name     il nome sotto Vita e Linfa
##   acc      come gli accessori (`GearEffects`): valgono finché l'effetto dura
##   effects  righe di `EffectsData` (le fiale per l'arma: «i colpi bruciano»)
##   special  le viste di `Boons._visions`: "tesori" (scrigni e casse), "creature", "trappole" (trappole e mimi)

static var BOONS: Dictionary = BiomesData.pack("boons")


static func has(id: String) -> bool:
	return BOONS.has(id)


static func info(id: String) -> Dictionary:
	return BOONS.get(id, {})
