class_name TestsMusic
extends RefCounted
## Prove della musica (autoload `Musica`, file in `musica/`): i due brani si caricano; il sottofondo suona; con un boss
## sveglio vicino si passa al brano del boss (il sottofondo va in pausa); sconfitto il boss si torna al sottofondo, che
## riprende da dov'era; un brano che finisce ricomincia sfumando; con il volume a zero tace; sotto terra si abbassa.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func _db(id: String) -> float:
	return Musica.player_of(id).volume_db


func run() -> void:
	var mu: Node = Musica
	var loaded := "esplorazione %s, guardiano %s" % ["sì" if mu.has("esplorazione") else "NO", "sì" if mu.has("guardiano") else "NO"]
	if not mu.has("esplorazione") or not mu.has("guardiano"):
		print("ATTENZIONE: musica non caricata (%s): i file vanno in musica/ e serve --import" % loaded)
		return
	m.fauna.clear()
	m.snap_to(kit.world.spawn)
	await kit.seconds(1.0)
	var ex: AudioStreamPlayer = mu.player_of("esplorazione")
	var first := "%s, %.0f dB" % ["suona" if ex.playing and not ex.stream_paused else "NON suona", _db("esplorazione")]
	print("musica: caricata (%s, %.0f s e %.0f s); sottofondo %s" % [loaded,
		(mu._tracks["esplorazione"]["stream"] as AudioStream).get_length(),
		(mu._tracks["guardiano"]["stream"] as AudioStream).get_length(), first])
	# un boss sveglio vicino
	var pos_before: float = mu.player_of("esplorazione").get_playback_position()
	var boss: Creature = m.fauna.add("madre_grumi", m.player.position + Vector2(220, -60))
	boss.set_process(false)
	await kit.seconds(float(mu.SWITCH_FADE) + 0.8)
	var ex_paused: bool = mu.player_of("esplorazione").stream_paused
	print("boss vicino: brano «%s», guardiano %s (%.0f dB), sottofondo in pausa %s" % [mu.mode,
		"suona" if mu.player_of("guardiano").playing else "NON suona", _db("guardiano"), "sì" if ex_paused else "NO"])
	# sconfitto: dopo l'attesa si torna al sottofondo, che riprende da dov'era
	m.fauna.kill_quietly(boss)
	await kit.seconds(float(mu.CALM_WAIT) + float(mu.SWITCH_FADE) + 0.8)
	var pos_after: float = mu.player_of("esplorazione").get_playback_position()
	print("boss sconfitto: brano «%s», sottofondo di nuovo %s, ripreso da dov'era %s (%.0f s → %.0f s), guardiano fermo %s" % [
		mu.mode, "sì" if not mu.player_of("esplorazione").stream_paused else "NO",
		"sì" if pos_after >= pos_before else "NO", pos_before, pos_after,
		"sì" if not mu.player_of("guardiano").playing else "NO"])
	# un brano che finisce ricomincia sfumando nel suo inizio
	var p0: AudioStreamPlayer = mu.player_of("esplorazione")
	var length := (mu._tracks["esplorazione"]["stream"] as AudioStream).get_length()
	p0.seek(length - float(mu.LOOP_FADE) - 1.0)
	await kit.seconds(float(mu.LOOP_FADE) + 2.5)
	var p1: AudioStreamPlayer = mu.player_of("esplorazione")
	print("fine del brano: ricomincia sull'altro lettore %s, dall'inizio %s (%.1f s), il vecchio spento %s" % [
		"sì" if p1 != p0 and p1.playing else "NO", "sì" if p1.get_playback_position() < float(mu.LOOP_FADE) + 3.0 else "NO",
		p1.get_playback_position(), "sì" if not p0.playing else "NO"])
	# volume a zero, poi sotto terra
	var vol: float = Settings.music
	Settings.music = 0.0
	await kit.frames(3)
	var mute := _db("esplorazione") <= -79.0
	Settings.music = vol
	await kit.frames(3)
	var surface := _db("esplorazione")
	var deep := kit.world.spawn + Vector2i(0, 60)
	for y in range(deep.y - 2, deep.y + 1):
		kit.world.set_tile(deep.x, y, TileDefs.AIR)
	kit.world.set_tile(deep.x, deep.y + 1, TileDefs.STONE)
	m.snap_to(deep)
	await kit.seconds(1.5)
	print("volume della musica a zero: muta %s; sotto terra (strato %d) %.1f dB invece di %.1f" % ["sì" if mute else "NO",
		m.depth_watch.stratum, _db("esplorazione"), surface])
	m.snap_to(kit.world.spawn)
