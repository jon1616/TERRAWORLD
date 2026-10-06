class_name UnderBiomesData
## I biomi del sottosuolo (voce 43, nel formato dei dati dalla voce 91): li portano i geni della categoria «sottosuolo»
## (effetto `under` in `GenesData`) e li costruisce `PassSottosuolo`. Un bioma del sottosuolo nuovo = una riga qui, il
## gene che lo porta, e la sua funzione di costruzione (la forma) in `PassSottosuolo`.
##   name, desc   nome e frase (Enciclopedia, schede)
##   stratum      lo strato in cui nasce (`StrataData`)
##   count        quanti se ne provano a costruire in un mondo
##   build        la funzione di `PassSottosuolo` che ne scava uno
##   floor        la tessera del pavimento (che la vegetazione del bioma di superficie con la stessa erba veste da sola)

const _UNDER := {
	"fungaie": {"name": "Fungaie", "desc": "grandi sale con funghi giganti e il pavimento di spore",
		"stratum": 1, "count": 14, "build": "_fungaia", "floor": TileDefs.GRASS_SPORE},
	"geodi_brina": {"name": "Geodi di brina", "desc": "grotte tonde con il guscio di cristallo e dentro muschio di brina",
		"stratum": 2, "count": 20, "build": "_geode_brina", "floor": TileDefs.GRASS_BRINA},
	"fiumi_brace": {"name": "Fiumi di brace", "desc": "gallerie serpeggianti di brace liquida, pavimento di cenere viva",
		"stratum": 3, "count": 6, "build": "_fiume_brace", "floor": TileDefs.GRASS_CENERE},
	"laghi_linfa": {"name": "Laghi di Linfa", "desc": "caverne larghe con un lago di Linfa sul fondo",
		"stratum": 3, "count": 7, "build": "_lago_linfa", "floor": TileDefs.CRYSTAL},
	"cuore_cavo": {"name": "Cuore cavo", "desc": "una caverna immensa nel Fondo, pavimento di cristallo e schegge del Vuoto",
		"stratum": 4, "count": 1, "build": "_cuore_cavo", "floor": TileDefs.CRYSTAL},
}


## Voce 94: più quelli scritti come file (`BiomesData.UNDER_FILES`), con creature proprie (campo "under" e peso "uw").
static var UNDER: Dictionary = _merged()
static var _pools := {}


static func _merged() -> Dictionary:
	var out := _UNDER.duplicate()
	for u in BiomesData.UNDER:
		out[String(u["id"])] = u
	return out


## Le creature che nascono in un bioma del sottosuolo a partire dalla cella c (guarda il pavimento sotto): [[id, peso]]
## o vuoto se lì non c'è un bioma con creature sue (voce 94, usato da `Fauna.try_spawn`).
static func pool_at(w: World, c: Vector2i) -> Array:
	if _pools.is_empty():
		var floor_of := {}
		for u in BiomesData.UNDER:
			_pools[int(u["floor"])] = []
			floor_of[String(u["id"])] = int(u["floor"])
		# voce 133: tutte le creature con «under», dai file del sottosuolo e dai pacchetti del bestiario
		var all_cr := BiomesData.pack("creatures")
		for cid in all_cr:
			var u_id := String((all_cr[cid] as Dictionary).get("under", ""))
			if floor_of.has(u_id):
				(_pools[floor_of[u_id]] as Array).append([cid, int(all_cr[cid].get("uw", 1))])
		_pools[-1] = []
	for dy in 12:
		if w.solid(c.x, c.y + dy):
			var pool: Array = _pools.get(w.tile(c.x, c.y + dy), [])
			if CreaturesData.awake_on:
				return pool
			return pool.filter(func(e: Array) -> bool: return not bool(CreaturesData.CREATURES.get(String(e[0]), {}).get("awake", false)))
	return []
