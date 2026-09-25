class_name SfxSynth
extends RefCounted
## Il sintetizzatore dei suoni (voce 17): trasforma le ricette di `SoundsData` in campioni PCM a 16 bit
## (`AudioStreamWAV`). Onde sinusoidali, triangolari, quadre e rumore filtrato, con scivolamento di frequenza,
## vibrato e inviluppo (attacco breve, poi spegnimento esponenziale).

const RATE := 22050


static func make(recipe: Dictionary, sd := 1) -> AudioStreamWAV:
	var layers: Array = recipe["layers"]
	var total := 0.0
	for L in layers:
		total = maxf(total, float(L.get("delay", 0.0)) + float(L["dur"]))
	var n := int(total * RATE) + 1
	var buf := PackedFloat32Array()
	buf.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	for L in layers:
		_layer(buf, L, rng)
	return _to_wav(buf, false)


static func _layer(buf: PackedFloat32Array, L: Dictionary, rng: RandomNumberGenerator) -> void:
	var start := int(float(L.get("delay", 0.0)) * RATE)
	var len := int(float(L["dur"]) * RATE)
	var wave := String(L["wave"])
	var f0 := float(L["f0"])
	var f1 := float(L["f1"])
	var att := maxf(float(L["att"]), 0.0005)
	var dec := float(L["dec"])
	var vol := float(L["vol"])
	var vib: Array = L.get("vib", [0.0, 0.0])
	var phase := 0.0
	var lp := 0.0
	for i in len:
		var k := start + i
		if k >= buf.size():
			break
		var t := float(i) / RATE
		var u := float(i) / maxf(len - 1, 1)
		var f := lerpf(f0, f1, u) * (1.0 + float(vib[1]) * sin(TAU * float(vib[0]) * t))
		var env := minf(t / att, 1.0) * exp(-dec * maxf(t - att, 0.0))
		env *= clampf((len - i) / (RATE * 0.004), 0.0, 1.0)   # niente clic alla fine
		var s := 0.0
		if wave == "noise":
			# rumore bianco passato in un filtro passa-basso a un polo, con il taglio che scivola da f0 a f1
			var a := 1.0 - exp(-TAU * f / RATE)
			lp += a * (rng.randf_range(-1.0, 1.0) - lp)
			s = lp * 1.6
		else:
			phase = fmod(phase + f / RATE, 1.0)
			match wave:
				"sine":
					s = sin(TAU * phase)
				"tri":
					s = 1.0 - 4.0 * absf(phase - 0.5)
				"square":
					s = 1.0 if phase < 0.5 else -1.0
		buf[k] += s * env * vol


## Il sottofondo di uno strato: un anello di AMBIENT_LOOP secondi che si richiude senza cuciture.
static func ambient(spec: Dictionary, sd := 7) -> AudioStreamWAV:
	var n := int(SoundsData.AMBIENT_LOOP * RATE)
	var fade := int(0.5 * RATE)
	var gen := PackedFloat32Array()
	gen.resize(n + fade)                  # mezzo secondo in più: la coda che si fonde con l'inizio
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	var nz: Array = spec["noise"]
	var a := 1.0 - exp(-TAU * float(nz[0]) / RATE)
	var lp := 0.0
	var lp2 := 0.0
	var lfo := float(spec["lfo"])
	for i in n + fade:
		var t := float(i) / RATE
		var s := 0.0
		for tone in spec["tones"]:
			s += sin(TAU * float(tone[0]) * t) * float(tone[1])
		lp += a * (rng.randf_range(-1.0, 1.0) - lp)
		lp2 += a * (lp - lp2)
		s += lp2 * float(nz[1]) * 3.0
		s *= 0.75 + 0.25 * sin(TAU * lfo * t)
		gen[i] = s
	# anello senza cuciture: l'inizio sfuma dalla coda (ciò che verrebbe dopo la fine) al suono vero,
	# così dall'ultimo campione si passa al primo come se il suono continuasse
	var buf := gen.slice(0, n)
	for i in fade:
		var w := float(i) / fade
		buf[i] = gen[i] * w + gen[n + i] * (1.0 - w)
	return _to_wav(buf, true)


static func _to_wav(buf: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	# limitatore: se la somma degli strati supera il massimo, tutto il suono si abbassa insieme (niente distorsione)
	var peak := 0.0
	for v in buf:
		peak = maxf(peak, absf(v))
	var scale := 26000.0 if peak * 26000.0 <= 31000.0 else 31000.0 / peak
	var data := PackedByteArray()
	data.resize(buf.size() * 2)
	for i in buf.size():
		data.encode_s16(i * 2, clampi(int(buf[i] * scale), -32768, 32767))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = data
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = buf.size()
	return w
