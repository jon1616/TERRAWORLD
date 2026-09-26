class_name GenContext
extends RefCounted
## Quello che le passate del generatore condividono: il seme, un generatore casuale, i rumori per nome e i parametri
## del mondo, che vengono dal Seme: vigore e geni (voce 42, `GenesData`: la parte `gen` di ogni gene).

var world_seed := 0
var rng := RandomNumberGenerator.new()
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
