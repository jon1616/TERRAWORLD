class_name DayCycle
extends Node
## Giorno e notte (voce 9): il tempo scorre sempre (UNIVERSO.md). Un giorno dura DAY secondi; `time` va da 0 a 1
## (0 mezzanotte, 0,25 alba, 0,5 mezzogiorno, 0,75 tramonto). Il sole sale e scende, il cielo si colora all'alba e al
## tramonto e si spegne di notte (restano luna e stelle), la luce del cielo in superficie cala (`LightMap.sky`), e di
## notte in superficie compaiono più creature, anche quelle della notte (`CreaturesData`, campo `night`).
## Ora e numero del giorno sono salvati nel mondo (`world_meta["ora"]`, `["giorno"]`).

const DAY := 1200.0                    # secondi di gioco per un giorno intero (20 minuti)
const START := 0.3                     # un mondo nuovo comincia al mattino
const NIGHT_SKY := Color(0.2, 0.24, 0.38)   # luce della luna: sopra la soglia della luce, fredda
const DAY_TINT := Color(1, 1, 1)
const DUSK_TINT := Color(1.05, 0.62, 0.52)
const NIGHT_TINT := Color(0.16, 0.2, 0.34)

var m: Node2D
var time := START
var day := 1
var paused := false                    # le prove fermano l'ora per avere foto confrontabili
var _last_sky := Color.BLACK
var _label: Label


func setup(main: Node2D) -> void:
	m = main
	time = float(m.world_meta.get("ora", START))
	day = int(m.world_meta.get("giorno", 1))
	_label = Label.new()
	_label.position = Vector2(16, 70)
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color("#cfeee4"))
	_label.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_label.add_theme_constant_override("outline_size", 5)
	m.hud.add_child(_label)
	apply(true)


## Quanto è giorno: 0 di notte, 1 in pieno giorno, sfumato tra alba (0,2-0,3) e tramonto (0,7-0,8).
func daylight() -> float:
	return smoothstep(0.2, 0.3, time) * (1.0 - smoothstep(0.7, 0.8, time))


func is_night() -> bool:
	return daylight() < 0.3


## Colore del cielo e della scena all'orizzonte: rosato all'alba e al tramonto, blu notte di notte.
func tint() -> Color:
	var d := daylight()
	var dusk := 1.0 - absf(d - 0.5) * 2.0          # massimo a metà dell'alba o del tramonto
	var c := NIGHT_TINT.lerp(DAY_TINT, sqrt(d))    # il cielo resta chiaro più a lungo della luce
	return c.lerp(DUSK_TINT, clampf(dusk, 0.0, 1.0) * 0.75)


## Come si vede una luce del cielo dopo la soglia e la curva di `LightMap` (mai zero, per poterci dividere).
func _seen(v: float) -> float:
	return maxf(pow(maxf(minf(v, 1.0) - LightMap.CUT, 0.0) / (1.0 - LightMap.CUT), LightMap.CURVE), 0.05)


func clock_text() -> String:
	var minutes := int(time * 24.0 * 60.0)
	return "Giorno %d · %02d:%02d%s" % [day, minutes / 60, (minutes / 5 * 5) % 60, "  (notte)" if is_night() else ""]


func _process(dt: float) -> void:
	if not m.built or paused:
		return
	time += dt / DAY
	if time >= 1.0:
		time -= 1.0
		day += 1
	m.world_meta["ora"] = time
	m.world_meta["giorno"] = day
	m.fauna.night = is_night()
	apply()


## Porta sole, cielo e luce all'ora attuale (`force` = subito, senza aspettare che cambi abbastanza).
func apply(force := false) -> void:
	var d := daylight()
	var sky: Color = NIGHT_SKY.lerp(LightMap.SKY, d)
	if force or absf(sky.r - _last_sky.r) + absf(sky.b - _last_sky.b) > 0.02:
		_last_sky = sky
		m.light.sky = sky
		m.light.dirty = true
	# l'immagine della luce moltiplica anche lo sfondo: il cielo verrebbe scurito due volte (dall'ora e dalla luce).
	# Si divide il colore dello sfondo per la luce che vi cade sopra, così a schermo resta `tint()`.
	var seen := Color(_seen(sky.r), _seen(sky.g), _seen(sky.b))
	var t := tint()
	var comp := Color(minf(t.r / seen.r, 6.0), minf(t.g / seen.g, 6.0), minf(t.b / seen.b, 6.0))
	m.background.set_time(time, comp, 1.0 - d, Color(1.0 / seen.r, 1.0 / seen.g, 1.0 / seen.b))
	_label.text = clock_text()
