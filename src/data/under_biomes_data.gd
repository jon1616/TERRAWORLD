class_name UnderBiomesData
## I biomi del sottosuolo (voce 43, nel formato dei dati dalla voce 91): li portano i geni della categoria «sottosuolo»
## (effetto `under` in `GenesData`) e li costruisce `PassSottosuolo`. Un bioma del sottosuolo nuovo = una riga qui, il
## gene che lo porta, e la sua funzione di costruzione (la forma) in `PassSottosuolo`.
##   name, desc   nome e frase (Enciclopedia, schede)
##   stratum      lo strato in cui nasce (`StrataData`)
##   count        quanti se ne provano a costruire in un mondo
##   build        la funzione di `PassSottosuolo` che ne scava uno
##   floor        la tessera del pavimento (che la vegetazione del bioma di superficie con la stessa erba veste da sola)

const UNDER := {
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
