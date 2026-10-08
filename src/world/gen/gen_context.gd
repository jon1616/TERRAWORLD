class_name GenContext
extends RefCounted
## Quello che le passate del generatore condividono: il seme, un generatore casuale, i rumori per nome e i parametri
## del mondo, che vengono dal Seme: vigore e geni (voce 42, `GenesData`: la parte `gen` di ogni gene).

var world_seed := 0
var rng := RandomNumberGenerator.new()
var pass_seed := 0                     # il seme della passata in corso (`begin`)
var params := {
	# voce 441 (8 ott 2026): la superficie media sta a questa distanza dal FONDO del mondo (prima era una frazione
	# dell'altezza, 0,27): così le 200 righe del mondo alto 1200 vanno tutte al cielo e il sottosuolo resta uguale, anche
	# nei mondi più bassi delle prove. 730 = la profondità di prima (1000 − 270).
	"ground_depth": 730,
	"hills": 55.0,              # ampiezza delle colline grandi, in tessere
	"vigore": 1,                # dal Seme (voce 12): più vigore = minerali più ricchi (vedi `PassMinerali`)
	"geni": [],                 # dal Seme (voce 42): il genoma; senza gene di superficie = tutti i biomi (il mondo casa)
}
var _gen := {}
var _off := PackedInt32Array()
## Appunti che una passata lascia alle successive (es. le uscite delle gallerie d'ingresso).
var notes := {}
## La mappa dei posti occupati (pulizia del generatore, 28 set 2026): ogni struttura costruita annota il suo rettangolo
## con `claim`, e chi cerca un posto chiede `is_free` prima di costruire. Così nessuna struttura ne schiaccia un'altra
## (prima ogni passata guardava solo la roccia, e la pietra dei Seminatori di una stanza sembrava «roccia piena»).
var claims: Array = []                 # [Rect2i, chi]


func _init(sd: int) -> void:
	world_seed = sd
	rng.seed = sd


## Prima di ogni passata: il generatore casuale riparte da un seme suo, ricavato dal seme del mondo e dal nome della
## passata (pulizia del generatore, 28 set 2026). Così cambiare una passata non sposta più ciò che fanno le altre.
func begin(pass_name: String) -> void:
	pass_seed = ("%d|%s" % [world_seed, pass_name]).hash()
	rng.seed = pass_seed


## Un generatore casuale per una fascia di righe di una passata (vedi `GenBands`): lo stesso risultato sia che le
## fasce si facciano una alla volta, sia su più processori insieme.
func band_rng(band: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = ("%d|%d" % [pass_seed, band]).hash()
	return r


## Lo spostamento del confine degli strati per ogni colonna (`StrataData.offset`): calcolato una volta sola per mondo
## (prima lo rifacevano cinque passate). Lo strato di una cella: dep = y - surface[x] - off[x], poi il più profondo di
## `strata_tops()` che dep raggiunge.
func strata_off(w: World) -> PackedInt32Array:
	if _off.size() != w.w:
		_off.resize(w.w)
		for x in w.w:
			_off[x] = StrataData.offset(x, w.world_seed)
	return _off


func strata_tops() -> PackedInt32Array:
	var tops := PackedInt32Array()
	for st in StrataData.STRATA:
		tops.append(int(st["top"]))
	return tops


## Annota il rettangolo di una struttura appena costruita.
func claim(r: Rect2i, who: String) -> void:
	claims.append([r, who])


## Il rettangolo non tocca nessuna struttura già costruita.
func is_free(r: Rect2i) -> bool:
	for cl in claims:
		if (cl[0] as Rect2i).intersects(r):
			return false
	return true


## La somma degli effetti dei geni sul generatore (calcolata una volta sola).
func genes() -> Dictionary:
	if _gen.is_empty():
		_gen = Genome.effects(params.get("geni", []), "gen")
	return _gen


## Il gene di superficie ("" = nessuno: tutti i biomi).
func surface_gene() -> String:
	return Genome.surface_of(params.get("geni", []))


## Un rumore con seme proprio, derivato dal nome: ogni passata ha i suoi rumori indipendenti.
func noise(name: String, freq: float, octaves: int) -> FastNoiseLite:
	var n := FastNoiseLite.new()
	n.seed = world_seed + (name.hash() & 0xffff)
	n.frequency = freq
	n.fractal_octaves = octaves
	return n
