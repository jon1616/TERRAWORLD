class_name WorldGen
extends RefCounted
## Il generatore di mondi: esegue le passate in ordine e misura quanto dura ciascuna.
## Per aggiungere qualcosa al mondo (un bioma, una struttura…) si scrive una passata nuova e la si mette qui.

const WIDTH := 3000
const HEIGHT := 1000
## Il Giardino (voce 62): piccolo, sospeso nel Vuoto.
const GARDEN_W := 480
const GARDEN_H := 240


static func passes() -> Array[GenPass]:
	return [
		PassTerreno.new(),
		PassArcipelago.new(),
		PassBiomi.new(),
		PassStrati.new(),
		PassGuscio.new(),
		PassGrotte.new(),
		PassVuoti.new(),
		PassRadici.new(),
		PassIngressi.new(),
		PassMinerali.new(),
		PassCristalli.new(),
		PassSottosuolo.new(),
		PassErba.new(),
		PassAlberi.new(),
		PassDecorazioni.new(),
		PassAvvizzimento.new(),
		PassCuore.new(),
		PassNero.new(),
		PassRovine.new(),
		PassPericoli.new(),
		PassDoni.new(),
		PassGemme.new(),
		PassTane.new(),
		PassNascondigli.new(),
		PassGeodi.new(),
		PassIsole.new(),
		PassFirma.new(),
		PassPianteSeme.new(),
		PassNidi.new(),
		PassSigilli.new(),
		PassLuoghi.new(),
		PassCatene.new(),
		PassStele.new(),
		PassAcqua.new(),
		PassSegretiStanze.new(),            # voce 96: stanze murate, passaggi, tesori, nidi nascosti
		PassSegretiAnomalie.new(),          # voce 97: camere-enigma, anomalie, visioni
		PassSegreti.new(),                  # voce 95: l'elenco dei segreti (non usa il caso, non sposta nulla)
		PassPartenza.new(),
		PassCollaudo.new(),                 # l'ultima: controlla le promesse del mondo e ripara ciò che può
	]


## Le passate del Giardino (voce 62): l'isola con l'Albero-Madre, poi alberi e piante come nei mondi.
static func garden_passes() -> Array[GenPass]:
	return [
		PassGiardino.new(),
		PassAlberi.new(),
		PassDecorazioni.new(),
		PassGiardinoRifinitura.new(),
		PassCollaudo.new(),
	]


## Genera un mondo dal seme (il Giardino se `params["giardino"]`). Restituisce i tempi di ogni passata: [[titolo, ms], …].
static func generate(w: World, sd: int, width: int = WIDTH, height: int = HEIGHT, params := {}) -> Array:
	var c := GenContext.new(sd)
	c.params.merge(params, true)
	w.setup(width, height)
	w.world_seed = sd
	var times := []
	w.gen_rng = c.rng
	for p in (garden_passes() if params.get("giardino", false) else passes()):
		var t0 := Time.get_ticks_usec()
		c.begin(p.title())
		p.run(w, c)
		times.append([p.title(), (Time.get_ticks_usec() - t0) / 1000])
	w.gen_notes = c.notes
	# finito il mondo, le casse tornano al caso di sempre
	w.gen_rng = null
	for o in w.chests:
		(w.chests[o] as Bisaccia).rng = null
	return times


## L'impronta di un mondo, una riga per parte (così si vede subito che cosa è cambiato). La usa anche la prova della
## ripetibilità del generatore (`TestsGenRepeat`, gruppo «base»).
static func fingerprint(w: World, name: String) -> PackedStringArray:
	var st := []
	for k in w.stations:
		st.append("%s=%s" % [k, w.stations[k]])
	st.sort()
	var tr := []
	for k in w.trees:
		for t in w.trees[k]:
			tr.append(str(t))
	tr.sort()
	var ch := []
	for k in w.chests:
		ch.append("%s=%s" % [k, (w.chests[k] as Bisaccia).slots])
	ch.sort()
	var out := PackedStringArray()
	for part in [["tessere", w.tiles.hex_encode()], ["pareti", w.walls.hex_encode()], ["biomi", w.biomes.hex_encode()],
			["decorazioni", w.decor.hex_encode()], ["liquidi", w.liquid.hex_encode()], ["superficie", str(w.surface)],
			["stazioni", str(st)], ["alberi", str(tr)], ["casse", str(ch)], ["partenza", str(w.spawn)]]:
		out.append("%-22s %s" % ["%s %s" % [name, part[0]], String(part[1]).md5_text()])
	return out
