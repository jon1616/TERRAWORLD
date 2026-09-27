class_name PlacesData
## I luoghi scritti a mano (voce 70, Roadmap 9): stanze progettate come disegni (una riga di caratteri per fila di
## tessere) che il generatore (`PassLuoghi`) mette **solo nei mondi con i geni giusti**, nello strato giusto,
## scavandole nel terreno. Ognuno ha un leggio con un pezzo della storia dei Seminatori, uno scrigno ricco con un
## **oggetto unico** e (voce 71) un enigma che apre la porta della stanza del tesoro. Trovarne uno è un evento.
## Legenda dei disegni:
##   #  pietra dei Seminatori     =  mattoni        r  radice antica     a  ambra      v  vuotite     c  cristallo
##   g  vetro di resina            .  aria con la parete dei Seminatori dietro          _  aria aperta (niente parete)
##   D  porta dei Seminatori (voce 71: si apre risolvendo l'enigma)
##   S  scrigno (2×1)   L  leggio (2×2)   T  stele (2×3)   P  pianta-seme (1×2)   M  maglio (2×1)
##   1-4  i meccanismi dell'enigma (voce 71)
##   (spazio)  il terreno resta com'è
## Il carattere di una stazione è il suo angolo in alto a sinistra; le altre celle che occupa sono «.».

const TILE := {"#": TileDefs.PIETRA_SEM, "=": TileDefs.MATTONI, "r": TileDefs.RADICE, "a": TileDefs.AMBRA,
	"v": TileDefs.VUOTITE, "c": TileDefs.CRYSTAL, "g": TileDefs.VETRO}
const STATION := {"S": "scrigno", "L": "leggio", "T": "stele", "P": "pianta_seme", "M": "maglio"}
## Voce 71: la stazione dei meccanismi 1-4 secondo il tipo di enigma del luogo.
const MECH := {"leve": "leva", "bracieri": "braciere", "piastre": "piastra", "cristalli": "cristallo_eco"}
## Secondi per premere tutte le piastre.
const PLATE_TIME := 5.0

const GRIDS := {
	# voce 97: le camere-enigma, piccole e uguali: a sinistra il leggio e i tre meccanismi, dietro la porta lo scrigno
	"camera_bracieri": [
		"################",
		"#........#.....#",
		"#........#.....#",
		"#L.......D.....#",
		"#..1.2.3.D.S...#",
		"################",
	],
	"camera_leve": [
		"################",
		"#........#.....#",
		"#........#.....#",
		"#L.......D.....#",
		"#..1.2.3.D.S...#",
		"################",
	],
	"camera_piastre": [
		"################",
		"#........#.....#",
		"#........#.....#",
		"#L.......D.....#",
		"#..1.2.3.D.S...#",
		"################",
	],
	"camera_cristalli": [
		"################",
		"#........#.....#",
		"#........#.....#",
		"#L.......D.....#",
		"#..1.2.3.D.S...#",
		"################",
	],
	"biblioteca": [
		"rrrrrrrrrrrrrrrrrrrrrrrr",
		"r######################r",
		"r#...........#........#r",
		"r#...........#........#r",
		"r#...........#........#r",
		"r#...........#........#r",
		"r#.T..T..T...D........#r",
		"r#.........L.D........#r",
		"r#...........D...S....#r",
		"r######################r",
		"rrrrrrrrrrrrrrrrrrrrrrrr",
	],
	"serra": [
		"gggggggggggggggggggggggg",
		"gggggggggggggggggggggggg",
		"gg............#.......gg",
		"gg............#.......gg",
		"gg............#.......gg",
		"gg............#.......gg",
		"gg............D.......gg",
		"gg..P..P..PL..D.......gg",
		"gg.1..2..3....D...S...gg",
		"gggggggggggggggggggggggg",
		"gggggggggggggggggggggggg",
	],
	"osservatorio": [
		"________________________",
		"_#gggggggggggggggggggg#_",
		"_#gggggggggggggggggggg#_",
		"_#.............#......#_",
		"_#.............#......#_",
		"_#.............#......#_",
		"_#.............D......#_",
		"_#...L.........D......#_",
		"_#.1....2...3..D...S..#_",
		"_######################_",
		"________________________",
	],
	"alveare": [
		"aaaaaaaaaaaaaaaaaaaaaaaa",
		"aaaaaaaaaaaaaaaaaaaaaaaa",
		"aa................#...aa",
		"aa.a..a..a..a..a..#...aa",
		"aa................#...aa",
		"aa.a..a..a..a..a..#...aa",
		"aa................D...aa",
		"aa.......L........D...aa",
		"aa.1...2...3...4..DS..aa",
		"aaaaaaaaaaaaaaaaaaaaaaaa",
		"aaaaaaaaaaaaaaaaaaaaaaaa",
	],
	"forgia": [
		"########################",
		"########################",
		"##.............#......##",
		"##.............#......##",
		"##.............#......##",
		"##.............#......##",
		"##.............D......##",
		"##L............D......##",
		"##...M...1..2..D..S...##",
		"########################",
		"########################",
	],
	"cripta_brina": [
		"cccccccccccccccccccccccc",
		"cccccccccccccccccccccccc",
		"cc............#.......cc",
		"cc............#.......cc",
		"cc............#.......cc",
		"cc............#.......cc",
		"cc............D.......cc",
		"cc.....L......D.......cc",
		"cc...1.....2..D...S...cc",
		"cccccccccccccccccccccccc",
		"cccccccccccccccccccccccc",
	],
	"santuario": [
		"vvvvvvvvvvvvvvvvvvvvvvvv",
		"vvvvvvvvvvvvvvvvvvvvvvvv",
		"vv...........#........vv",
		"vv...........#........vv",
		"vv...........#........vv",
		"vv...........#........vv",
		"vv.......T...D........vv",
		"vv...L.......D........vv",
		"vv...........D...S....vv",
		"vvvvvvvvvvvvvvvvvvvvvvvv",
		"vvvvvvvvvvvvvvvvvvvvvvvv",
	],
	"tempio": [
		"cccccccccccccccccccccccc",
		"c######################c",
		"c#.............#......#c",
		"c#.............#......#c",
		"c#.............#......#c",
		"c#.............#......#c",
		"c#.T...........D......#c",
		"c#..........L..D......#c",
		"c#.....1.2.3...D..S...#c",
		"c######################c",
		"cccccccccccccccccccccccc",
	],
}

## Ogni luogo: nome, dove (strati, o "superficie"), i geni che lo chiamano (ne basta uno), la scritta del ritrovamento,
## la storia del leggio, l'oggetto unico dello scrigno, il colore, l'enigma (voce 71).
const PLACES := {
	# voce 97: le camere-enigma (niente geni: le mette `PassSegretiAnomalie` in ogni mondo, niente oggetto unico)
	"camera_bracieri": {"name": "Camera dei bracieri", "strata": [1, 3], "genes": [], "camera": true,
		"banner": "Tre bracieri spenti davanti a una porta", "color": "#ffb070", "unique": "",
		"lore": "«La porta si apre a chi porta luce.» Sotto, a matita: «Tre volte».", "enigma": {"tipo": "bracieri"}},
	"camera_leve": {"name": "Camera delle leve", "strata": [1, 3], "genes": [], "camera": true,
		"banner": "Tre leve di radice e una frase", "color": "#c89066", "unique": "",
		"lore": "Le leve si mettono come dice la frase del leggio, nella lingua dei Seminatori: «ul» su, «nae» giù.",
		"enigma": {"tipo": "leve"}},
	"camera_piastre": {"name": "Camera delle piastre", "strata": [1, 3], "genes": [], "camera": true,
		"banner": "Tre piastre nel pavimento", "color": "#9fc8c0", "unique": "",
		"lore": "«Chi corre abbastanza, entra.» Le piastre vanno premute tutte, e in fretta.", "enigma": {"tipo": "piastre"}},
	"camera_cristalli": {"name": "Camera dei cristalli", "strata": [1, 3], "genes": [], "camera": true,
		"banner": "Tre cristalli che aspettano un elemento", "color": "#8ef0d8", "unique": "",
		"lore": "Ogni cristallo risuona con un elemento: la sua scheda dice quale. Serve un'arma di quell'elemento in mano.",
		"enigma": {"tipo": "cristalli"}},
	"biblioteca": {"name": "La Biblioteca di radici", "strata": [1, 2], "genes": ["radici_giganti", "rovine_fitte", "rovine_sepolte", "eco_seminatori"],
		"banner": "Scaffali di radice, e stele fitte di parole", "color": "#c89066", "unique": "occhiali_seminatori",
		"lore": "Qui i Seminatori scrivevano tutto ciò che piantavano: ogni mondo una stele, ogni stele un nome. Mancano solo le ultime righe, strappate via: parlano di un seme che nessuno aveva piantato.",
		"enigma": {"tipo": "glifi"}},
	"serra": {"name": "La Serra dei Seminatori", "strata": [1, 1], "genes": ["fertile", "rigoglioso", "fioritura_eterna"],
		"banner": "Vetro e piante che crescono senza sole", "color": "#9ff0b8", "unique": "guanti_giardiniere",
		"lore": "Nella serra i Seminatori provavano i semi prima di piantarli nei mondi. Una targa: «Nessun seme va piantato se non si sa da dove viene». Sotto, qualcuno ha inciso: «Lui non lo sapeva».",
		"enigma": {"tipo": "leve"}},
	"osservatorio": {"name": "L'Osservatorio", "strata": [], "surface": true, "genes": ["stellato", "cuore_stellare", "eclissi", "aurora"],
		"banner": "Una cupola di vetro puntata sul cielo", "color": "#fff08a", "unique": "lente_stellare",
		"lore": "Da qui guardavano cadere i semi del cielo. Sul registro dell'ultima notte: «Una stella nera, senza luce. Non l'abbiamo vista cadere: l'abbiamo sentita.»",
		"enigma": {"tipo": "bracieri"}},
	"alveare": {"name": "L'Alveare colossale", "strata": [1, 2], "genes": ["alveari"],
		"banner": "Celle d'ambra grandi come stanze", "color": "#f0c060", "unique": "pettorale_cera",
		"lore": "Le api di lume servivano i Seminatori: portavano il polline da un mondo all'altro. Quando la malattia arrivò, furono le prime ad andarsene.",
		"enigma": {"tipo": "piastre"}},
	"forgia": {"name": "La Forgia antica", "strata": [3, 3], "genes": ["fiumi_brace", "vene_ricche", "metalli_nobili"],
		"banner": "Il calore dei Seminatori non si è mai spento", "color": "#ff9a5a", "unique": "anello_mantice",
		"lore": "Qui si forgiarono i primi attrezzi del giardino. Su un'incudine, un segno di brace: «Il ferro si piega, la radice no».",
		"enigma": {"tipo": "bracieri"}},
	"cripta_brina": {"name": "La Cripta di brina", "strata": [2, 3], "genes": ["geodi_brina", "brina", "gelo_perenne"],
		"banner": "Il gelo conserva ciò che il tempo ruberebbe", "color": "#9ad8ff", "unique": "cuore_brina_eterna",
		"lore": "I Seminatori conservavano qui i semi più preziosi, nel gelo. Uno scomparto è vuoto e annerito: qualcosa si è sciolto e se n'è andato.",
		"enigma": {"tipo": "cristalli"}},
	"santuario": {"name": "Il Santuario del Vuoto", "strata": [4, 4], "genes": ["abissale", "voragini", "cuore_cavo"],
		"banner": "Il silenzio del Fondo, e una porta chiusa", "color": "#b070ff", "unique": "vuoto_domato",
		"lore": "Il Vuoto non è vuoto: è fame. I Seminatori lo sapevano e costruirono qui la porta che lo teneva lontano. La chiave l'hanno nascosta in questo stesso mondo.",
		"enigma": {"tipo": "chiave"}},
	"tempio": {"name": "Il Tempio della Linfa", "strata": [3, 3], "genes": ["laghi_linfa", "radice_madre"],
		"banner": "La Linfa scorre qui come un fiume", "color": "#6ff0d8", "unique": "goccia_linfa_madre",
		"lore": "Tutta la Linfa dei mondi nasce da un'unica radice. Il tempio la venerava: «Chi cura la radice cura i mondi».",
		"enigma": {"tipo": "leve"}},
}

## Quanti luoghi al più in un mondo.
const MAX_PER_WORLD := 3

## Gli oggetti unici dei luoghi.
const ITEMS := {
	"occhiali_seminatori": {"name": "Occhiali dei Seminatori", "kind": "accessorio", "icon": ["amuleto", "ardesia"], "stack": 1, "value": 300,
		"acc": {"luck": 0.12, "halo": 1.2}, "source": "lo scrigno della Biblioteca di radici", "desc": "Lenti di cristallo sottile: si vede ciò che altri non vedono."},
	"guanti_giardiniere": {"name": "Guanti del giardiniere", "kind": "accessorio", "icon": ["mantello", "muschio"], "stack": 1, "value": 300,
		"acc": {"regen": 1.3, "dig": 1.08}, "source": "lo scrigno della Serra dei Seminatori", "desc": "Consumati da mani che hanno piantato mille mondi."},
	"lente_stellare": {"name": "Lente stellare", "kind": "accessorio", "icon": ["amuleto", "brillaluce"], "stack": 1, "value": 320,
		"acc": {"halo": 1.6, "luck": 0.05}, "source": "lo scrigno dell'Osservatorio", "desc": "Raccoglie la luce delle stelle anche sotto terra."},
	"pettorale_cera": {"name": "Pettorale di cera", "kind": "accessorio", "icon": ["cuore", "ambra"], "stack": 1, "value": 280,
		"acc": {"thorns": 5, "regen": 1.1}, "source": "lo scrigno dell'Alveare colossale", "desc": "Cera d'ambra delle api di lume: punge chi ti tocca."},
	"anello_mantice": {"name": "Anello del mantice", "kind": "accessorio", "icon": ["anello", "brace"], "stack": 1, "value": 320,
		"acc": {"atk_speed": 1.1, "damage": 1.05}, "source": "lo scrigno della Forgia antica", "desc": "Caldo come la forgia da cui viene."},
	"cuore_brina_eterna": {"name": "Cuore di brina eterna", "kind": "accessorio", "icon": ["cuore", "cristallo"], "stack": 1, "value": 320,
		"acc": {"fall_safe": true, "run": 1.06}, "source": "lo scrigno della Cripta di brina", "desc": "Non si scioglie mai: attutisce ogni caduta."},
	"vuoto_domato": {"name": "Frammento di Vuoto domato", "kind": "accessorio", "icon": ["gemma", "vuotite"], "stack": 1, "value": 360,
		"acc": {"air_jumps": 1, "stealth": 0.85}, "source": "lo scrigno del Santuario del Vuoto", "desc": "Un pezzo di niente, tenuto a bada: un salto in aria in più."},
	"goccia_linfa_madre": {"name": "Goccia della Linfa madre", "kind": "accessorio", "icon": ["goccia", "linfa"], "stack": 1, "value": 360,
		"acc": {"linfa_regen": 1.4, "magic": 1.1}, "source": "lo scrigno del Tempio della Linfa", "desc": "Linfa della radice di tutti i mondi."},
	"chiave_seminatori": {"name": "Chiave dei Seminatori", "kind": "chiave", "icon": ["chiave", "ardesia"], "stack": 5, "value": 50,
		"source": "uno scrigno delle rovine dei mondi con il Santuario del Vuoto", "desc": "Apre una porta dei Seminatori chiusa a chiave (voce 71)."},
}


static func grid(id: String) -> Array:
	return GRIDS.get(id, [])
