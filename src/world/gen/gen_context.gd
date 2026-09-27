class_name GenContext
extends RefCounted
## Quello che le passate del generatore condividono: il seme, un generatore casuale, i rumori per nome e i parametri
## del mondo, che vengono dal Seme: vigore e geni (voce 42, `GenesData`: la parte `gen` di ogni gene).

var world_seed := 0
var rng := RandomNumberGenerator.new()
var pass_seed := 0                     # il seme della passata in corso (`begin`)
var params := {
	"surface_base": 0.27,       # altezza media della superficie, in frazione dell'altezza del mondo
	"hills": 55.0,              # ampiezza delle colline grandi, in tessere
	"vigore": 1,                # dal Seme (voce 12): più vigore = minerali più ricchi (vedi `PassMinerali`)
	"geni": [],                 # dal Seme (voce 42): il genoma; senza gene di superficie = tutti i biomi (il mondo casa)
}
var _gen := {}
## Appunti che una passata lascia alle successive (es. le uscite delle gallerie d'ingresso).
var notes := {}


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
