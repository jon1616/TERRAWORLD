class_name BiomesData
extends RefCounted
## I biomi di superficie (voce 13; **un file per bioma** dalla voce 91, in `src/data/biomes/`). La superficie di un
## mondo è divisa in tratti di qualche centinaio di colonne, ognuno con il suo bioma (`World.biomes`, uno per colonna,
## salva l'**indice** in `FILES`: i biomi nuovi vanno in fondo, e il primo è la foresta della partenza).
##
## Aggiungere un bioma = scrivere il suo file e aggiungerlo a `FILES`, più i suoi disegni (albero in `TreeArt`, piante
## in `BiomeDecorArt`); le tabelle delle tessere (`TileDefs`), gli alberi (`TreesData`), il generatore, la mappa, il
## tempo e le creature leggono da qui. Il foglio di tutti i biomi: `tools/biomi.gd` → prove/biomi.png.
##
## Campi di un bioma (`DATA`):
##   id, name, desc   nome e frase della scritta che compare entrando
##   trees            probabilità di un albero dove c'è posto (la foresta 0,4)
##   hills            quanto sono mosse le colline (1 = come il generatore di base)
##   lift             di quante tessere si alza (negativo) o si abbassa (positivo) la superficie
##   tint, color      colore del cielo e delle colline lontane; colore della scritta
##   weight           quanto spesso compare in un mondo senza gene di superficie
##   grass            la tessera d'erba in cima al terreno (un numero nuovo, oltre `TileDefs.TYPES_BASE`, per un bioma nuovo)
##   turf             l'erba: name (nome della tessera), layer (lo strato del terreno morbido), pal (5 colori, dal
##                    più scuro), specks (puntini chiari nella trama: 0 = nessuno)
##   tree             la specie d'albero: id, name, glow (luce dei baccelli), art (il disegno di `TreeArt`, di solito = id)
##   veg              la vegetazione sull'erba: [[fino a, cosa], …] tirando un numero a caso da 0 a 1; «cosa» è l'id di
##                    una decorazione o un nome: fronda, felce, fiori, fiore_0/1/2, sassi, spora, bagliore, fungo
##   decor            le decorazioni proprie del bioma: {id: {soft: "erba"|"pianta" (si semina sopra, si pascola),
##                    light: la luce che fa}} (disegni in `BiomeDecorArt`)
##   elem             l'elemento più probabile delle varianti delle creature che nascono qui (voce 55)
##   weather          i tempi che il bioma porta nel mondo: {stato: moltiplicatore} (vedi `WeatherData`)
##   gene             il gene di superficie che lo sceglie (`GenesData`, categoria superficie)

const FILES := [
	preload("res://src/data/biomes/foresta.gd"),
	preload("res://src/data/biomes/palude.gd"),
	preload("res://src/data/biomes/ambra.gd"),
	preload("res://src/data/biomes/brina.gd"),
	preload("res://src/data/biomes/cenere.gd"),
]

static var BIOMES: Array = _load()

const SPAWN_SAFE := 160                # colonne di foresta attorno alla partenza
const SEG_MIN := 220                   # lunghezza di un tratto di bioma, in colonne
const SEG_MAX := 440
const BLEND := 30                      # colonne di passaggio morbido del terreno tra due biomi


static func _load() -> Array:
	var out := []
	for f in FILES:
		out.append(f.DATA)
	return out


static func index_of(id: String) -> int:
	for k in BIOMES.size():
		if BIOMES[k]["id"] == id:
			return k
	return 0


static func at(w: World, x: int) -> int:
	return w.biomes[clampi(x, 0, w.w - 1)]


## Il bioma che ha questa tessera d'erba (vuoto se nessuno).
static func of_grass(t: int) -> Dictionary:
	for b in BIOMES:
		if int(b["grass"]) == t:
			return b
	return {}


## Un bioma dal suo id (vuoto se non esiste, come «avvizzito»).
static func by_id(id: String) -> Dictionary:
	for b in BIOMES:
		if b["id"] == id:
			return b
	return {}


## Il nome di un bioma dal suo id (l'id stesso se non esiste).
static func name_of(id: String) -> String:
	for b in BIOMES:
		if b["id"] == id:
			return String(b["name"])
	return id
