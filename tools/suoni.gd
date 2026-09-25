extends SceneTree
## Genera tutti i suoni di `SoundsData` (e i sottofondi degli strati) e li salva in prove/suoni/*.wav, con durata,
## picco e volume medio: per ascoltarli fuori dal gioco e per accorgersi di suoni muti o distorti.
## Uso: Godot_console.exe --headless --path . --script res://tools/suoni.gd


func _init() -> void:
	var dir := ProjectSettings.globalize_path("res://prove/suoni")
	DirAccess.make_dir_recursive_absolute(dir)
	var bad := 0
	var k := 1
	for id in SoundsData.SOUNDS:
		var w := SfxSynth.make(SoundsData.SOUNDS[id], k)
		k += 1
		bad += _report(id, w, dir)
	for s in SoundsData.AMBIENT.size():
		bad += _report("sottofondo_%d_%s" % [s, StrataData.STRATA[s]["id"]], SfxSynth.ambient(SoundsData.AMBIENT[s], 7 + s), dir)
	print("ESITO: %s" % ("tutto a posto" if bad == 0 else "%d suoni da controllare" % bad))
	quit()


func _report(id: String, w: AudioStreamWAV, dir: String) -> int:
	var d := w.data
	var n := d.size() / 2
	var peak := 0
	var sum := 0.0
	for i in n:
		var v := absi(d.decode_s16(i * 2))
		peak = maxi(peak, v)
		sum += float(v) * v
	var rms := sqrt(sum / maxf(n, 1)) / 32768.0
	var p := peak / 32768.0
	w.save_to_wav(dir + "/" + id + ".wav")
	var warn := ""
	if p < 0.05:
		warn = "  ← quasi muto"
	elif p >= 0.999:
		warn = "  ← distorto (tocca il massimo)"
	print("%-24s %5.2f s  picco %.2f  medio %.3f%s" % [id, float(n) / SfxSynth.RATE, p, rms, warn])
	return 0 if warn == "" else 1
