class_name BiomesData
extends RefCounted
## I biomi di superficie (voce 13; **un file per bioma** dalla voce 91, in `src/data/biomes/`). La superficie di un
## mondo è divisa in tratti di qualche centinaio di colonne, ognuno con il suo bioma (`World.biomes`, uno per colonna,
## salva l'**indice** in `FILES`: i biomi nuovi vanno in fondo, e il primo è la foresta della partenza).
##
## Questo file e i file dei biomi **non nominano altre classi** (nemmeno `TileDefs`): le tabelle comuni li leggono
## mentre si preparano, e un giro di dipendenze le lascerebbe a metà (successo con la mappa dei colori).
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
##   harsh            voce 93, il rigore di una terra estrema: {kind (di `HarshData`), rate (la barra si riempie in
##                    1/rate secondi allo scoperto), night (× di notte)} (regole in `Harshness`)
##   hurt_tile        voce 93, l'erba che ferisce chi ci sta sopra senza i piedi protetti: {dmg, text}
##   stagni           voce 118, gli stagni di superficie (dove si pesca): [quanti ogni 1000 colonne, larghezza min,
##                    max, profondità min, max] (0 = nessuno; senza il campo: pochi, `PassStagni.DEFAULT`)
##   fish             voce 120, i pesci degli stagni del bioma: {id: pesce} (campi in cima a `FishData`)
## Dalla voce 92 un bioma porta con sé anche il suo **pacchetto** (tutti facoltativi), che le tabelle comuni uniscono
## alle loro:
##   creatures        {id: voce di `CreaturesData`} con in più body (la ricetta del disegno per `BodyArt`), affinity
##                    ({weak, resist} di `ElementsData`) e trophy (l'id del trofeo che lasciano le rare)
##   families         {id: famiglia di `FamiliesData`}          loot     {tabella: voci di `LootData`}
##   items, recipes   oggetti e ricette (come `ItemsData` e `RecipesData`), il Seme di mondo e l'oggetto unico compresi
##   sets             {id: set di `SetsData`}                   genes    {id: gene di `GenesData`} (il suo di superficie)
##   lands            i paesaggi dei nomi dei mondi del suo gene (`NamesData.LANDS`)
##   fauna            creature che ci sono già e vivono anche qui (il bioma si aggiunge ai loro `biomes`)

const FILES := [
	preload("res://src/data/biomes/foresta.gd"),
	preload("res://src/data/biomes/palude.gd"),
	preload("res://src/data/biomes/ambra.gd"),
	preload("res://src/data/biomes/brina.gd"),
	preload("res://src/data/biomes/cenere.gd"),
	# voce 92: le terre temperate
	preload("res://src/data/biomes/prati.gd"),
	preload("res://src/data/biomes/rossa.gd"),
	preload("res://src/data/biomes/funghi.gd"),
	preload("res://src/data/biomes/torba.gd"),
	# voce 93: le terre estreme
	preload("res://src/data/biomes/vetro.gd"),
	preload("res://src/data/biomes/ghiacciaio.gd"),
	preload("res://src/data/biomes/pietra.gd"),
	preload("res://src/data/biomes/brace.gd"),
	# voce 94: i biomi rari (solo per mutazione: peso 0, gene `only: "mutazione"`)
	preload("res://src/data/biomes/iridato.gd"),
	preload("res://src/data/biomes/stellare.gd"),
	preload("res://src/data/biomes/sussurri.gd"),
]

## Voce 94: i biomi del sottosuolo scritti come file (campi in cima a `UnderBiomesData`, pacchetto come qui; in più
## `tiles`: {tessera: {name, hard, power, drop, pal, layer, specks, grass, square, glow}} le tessere nuove che portano).
const UNDER_FILES := [
	preload("res://src/data/biomes/sotto_canto.gd"),
	preload("res://src/data/biomes/sotto_giungla.gd"),
	preload("res://src/data/biomes/sotto_lago.gd"),
	preload("res://src/data/biomes/sotto_catacombe.gd"),
]

## Roadmap 16: i biomi del cielo (campi in cima a `SkyData`; pacchetto come qui, `tiles` come i biomi del sottosuolo).
const SKY_FILES := [
	preload("res://src/data/biomes/cielo_radici.gd"),
	preload("res://src/data/biomes/cielo_nubi.gd"),
	preload("res://src/data/biomes/cielo_vento.gd"),
	preload("res://src/data/biomes/cielo_cristallo.gd"),
	preload("res://src/data/biomes/cielo_tempesta.gd"),
	preload("res://src/data/biomes/cielo_firmamento.gd"),
]

## Voce 97: pacchetti di contenuto che non sono biomi (le creature nascoste): stessi campi del pacchetto.
const PACK_FILES := [
	preload("res://src/data/hidden_creatures.gd"),
	preload("res://src/data/bestiary/superficie.gd"),      # voce 132: il nuovo bestiario (fatto da tools/gen_bestiario.py)
	preload("res://src/data/bestiary/sottosuolo.gd"),      # voce 133
	preload("res://src/data/bestiary/tempo.gd"),           # voce 134
	preload("res://src/data/bestiary/signori.gd"),         # voce 135: i Signori dei luoghi (tools/gen_signori.py)
	preload("res://src/data/bestiary/guardiani.gd"),       # voce 136: tre Guardiani scritti a mano
	preload("res://src/data/bestiary/maree.gd"),           # voce 137: i premi delle maree
	preload("res://src/data/sky_pack.gd"),                 # Roadmap 16: gli oggetti del cielo
	preload("res://src/data/bestiary/cielo.gd"),           # voce 160: le creature del cielo (tools/gen_bestiario.py)
	preload("res://src/data/language_pack.gd"),            # Roadmap 17, voce 176: le ricette scritte nella lingua
	preload("res://src/data/energy_pack.gd"),              # Roadmap 19: la rete della Linfa (vene, fili, macchine)
	preload("res://src/data/lost_gardens_pack.gd"),        # Roadmap 21: i Giardini perduti
	preload("res://src/data/primo_pack.gd"),               # Roadmap 28: il Giardino oltre il Vuoto
	preload("res://src/data/vastita/armi_firma.gd"),       # Roadmap 40, voce 370: le armi firma (tools/gen_vastita.py)
	preload("res://src/data/vastita/guardiani.gd"),        # Roadmap 41, voci 373-374: i Guardiani della spina e i Sacchetti
	preload("res://src/data/vastita/capi.gd"),             # voci 375-377: capi erranti, boss facoltativi, superboss, corsa
	preload("res://src/data/vastita/bestiario.gd"),        # Roadmap 42, voci 379-380: le risvegliate e le specie firma
	preload("res://src/data/vastita/eventi.gd"),           # voce 382: gli eventi con il loro capo
	preload("res://src/data/vastita/accessori.gd"),        # Roadmap 43: accessori firma, Officina, ali, rampini, animaletti
	preload("res://src/data/vastita/armature.gd"),         # Roadmap 44: le spoglie dei boss
	preload("res://src/data/vastita/rari.gd"),             # voce 395: un raro per ogni specie
	preload("res://src/data/vastita/ritrovamenti.gd"),     # voci 392-393: casse dei biomi, chiavi, mimi
	preload("res://src/data/vastita/strutture.gd"),        # voce 394: le strutture dei biomi
	preload("res://src/data/vastita/segreti.gd"),          # voce 397: i semi segreti dei mondi
]

static var BIOMES: Array = _load()
static var UNDER: Array = _load_under()
static var SKY: Array = _load_sky()

const SPAWN_SAFE := 160                # colonne di foresta attorno alla partenza
const SEG_MIN := 220                   # lunghezza di un tratto di bioma, in colonne
const SEG_MAX := 440
const BLEND := 30                      # colonne di passaggio morbido del terreno tra due biomi


static func _load() -> Array:
	var out := []
	for f in FILES:
		out.append(f.DATA)
	return out


static func _load_under() -> Array:
	var out := []
	for f in UNDER_FILES:
		out.append(f.DATA)
	return out


static func _load_sky() -> Array:
	var out := []
	for f in SKY_FILES:
		out.append(f.DATA)
	return out


static func index_of(id: String) -> int:
	for k in BIOMES.size():
		if BIOMES[k]["id"] == id:
			return k
	return 0


static func at(w: Object, x: int) -> int:    # (niente tipo World: questo file non dipende da nessuno)
	return w.biomes[clampi(x, 0, w.w - 1)]


## Voce 92: l'unione di un campo-dizionario del pacchetto di tutti i biomi.
static func pack(key: String) -> Dictionary:
	var out := {}
	for f in FILES + UNDER_FILES + SKY_FILES + PACK_FILES:
		out.merge((f.DATA as Dictionary).get(key, {}))
	return out


## Voce 92: l'unione di un campo-elenco del pacchetto di tutti i biomi.
static func pack_list(key: String) -> Array:
	var out := []
	for f in FILES + UNDER_FILES + SKY_FILES + PACK_FILES:
		out.append_array((f.DATA as Dictionary).get(key, []))
	return out


## Voce 92: un campo di ogni creatura dei pacchetti ({id creatura: valore}), per debolezze e trofei.
static func pack_creatures(field: String) -> Dictionary:
	var out := {}
	var cr := pack("creatures")
	for id in cr:
		if (cr[id] as Dictionary).has(field):
			out[id] = cr[id][field]
	return out


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
