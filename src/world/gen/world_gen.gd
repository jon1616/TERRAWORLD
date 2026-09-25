class_name WorldGen
extends RefCounted
## Il generatore di mondi: esegue le passate in ordine e misura quanto dura ciascuna.
## Per aggiungere qualcosa al mondo (un bioma, una struttura…) si scrive una passata nuova e la si mette qui.

const WIDTH := 3000
const HEIGHT := 1000


static func passes() -> Array[GenPass]:
	return [
		PassTerreno.new(),
		PassBiomi.new(),
		PassStrati.new(),
		PassGrotte.new(),
		PassVuoti.new(),
		PassRadici.new(),
		PassIngressi.new(),
		PassMinerali.new(),
		PassCristalli.new(),
		PassErba.new(),
		PassAlberi.new(),
		PassDecorazioni.new(),
		PassAvvizzimento.new(),
		PassCuore.new(),
		PassRovine.new(),
		PassPartenza.new(),
	]


## Genera un mondo dal seme. Restituisce i tempi di ogni passata: [[titolo, ms], …].
static func generate(w: World, sd: int, width: int = WIDTH, height: int = HEIGHT, params := {}) -> Array:
	var c := GenContext.new(sd)
	c.params.merge(params, true)
	w.setup(width, height)
	w.world_seed = sd
	var times := []
	for p in passes():
		var t0 := Time.get_ticks_usec()
		p.run(w, c)
		times.append([p.title(), (Time.get_ticks_usec() - t0) / 1000])
	return times
