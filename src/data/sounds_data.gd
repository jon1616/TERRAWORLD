class_name SoundsData
extends RefCounted
## I suoni del gioco, come ricette per `SfxSynth` (voce 17): niente file audio, tutto generato dal codice come la
## grafica. Solo dati.
##
## Un suono è una lista di strati sommati. Ogni strato:
##   wave   sine · tri · square · noise
##   f0, f1 frequenza all'inizio e alla fine (Hz; per il rumore è il taglio del filtro passa-basso)
##   dur    durata (s); delay: quando comincia (s)
##   att    attacco (s); dec: quanto in fretta si spegne (più alto = più secco)
##   vol    volume (0-1)
##   vib    vibrato: [velocità Hz, profondità in frazione della frequenza]
## `gain` in dB per suono; `var` = variazione casuale del tono a ogni colpo (0,08 = ±8%).

const SOUNDS := {
	# scavare e costruire
	"scavo_terra": {"gain": -8.0, "var": 0.12, "layers": [
		{"wave": "noise", "f0": 900, "f1": 500, "dur": 0.09, "att": 0.002, "dec": 30.0, "vol": 0.9},
		{"wave": "sine", "f0": 130, "f1": 80, "dur": 0.08, "att": 0.002, "dec": 35.0, "vol": 0.6}]},
	"scavo_roccia": {"gain": -9.0, "var": 0.1, "layers": [
		{"wave": "noise", "f0": 3200, "f1": 1800, "dur": 0.07, "att": 0.001, "dec": 45.0, "vol": 0.7},
		{"wave": "square", "f0": 900, "f1": 700, "dur": 0.03, "att": 0.001, "dec": 80.0, "vol": 0.25}]},
	"rompi": {"gain": -7.0, "var": 0.1, "layers": [
		{"wave": "noise", "f0": 1400, "f1": 400, "dur": 0.2, "att": 0.002, "dec": 16.0, "vol": 0.9},
		{"wave": "sine", "f0": 110, "f1": 60, "dur": 0.15, "att": 0.002, "dec": 20.0, "vol": 0.7}]},
	"posa": {"gain": -10.0, "var": 0.08, "layers": [
		{"wave": "sine", "f0": 180, "f1": 120, "dur": 0.08, "att": 0.002, "dec": 30.0, "vol": 0.8},
		{"wave": "noise", "f0": 1200, "f1": 800, "dur": 0.05, "att": 0.001, "dec": 50.0, "vol": 0.4}]},
	"legno": {"gain": -8.0, "var": 0.1, "layers": [
		{"wave": "tri", "f0": 240, "f1": 160, "dur": 0.12, "att": 0.001, "dec": 25.0, "vol": 0.8},
		{"wave": "noise", "f0": 1800, "f1": 900, "dur": 0.06, "att": 0.001, "dec": 40.0, "vol": 0.4}]},
	"albero_cade": {"gain": -6.0, "var": 0.05, "layers": [
		{"wave": "noise", "f0": 700, "f1": 200, "dur": 0.7, "att": 0.05, "dec": 4.0, "vol": 0.8},
		{"wave": "sine", "f0": 90, "f1": 45, "dur": 0.5, "att": 0.02, "dec": 6.0, "vol": 0.7, "delay": 0.25}]},
	"torcia": {"gain": -12.0, "var": 0.1, "layers": [
		{"wave": "noise", "f0": 4000, "f1": 2500, "dur": 0.25, "att": 0.01, "dec": 10.0, "vol": 0.6},
		{"wave": "sine", "f0": 300, "f1": 420, "dur": 0.15, "att": 0.02, "dec": 12.0, "vol": 0.3}]},
	# combattere
	"colpo": {"gain": -12.0, "var": 0.1, "layers": [
		{"wave": "noise", "f0": 500, "f1": 2400, "dur": 0.13, "att": 0.03, "dec": 14.0, "vol": 0.8}]},
	"colpito": {"gain": -7.0, "var": 0.12, "layers": [
		{"wave": "sine", "f0": 200, "f1": 90, "dur": 0.12, "att": 0.001, "dec": 22.0, "vol": 0.9},
		{"wave": "noise", "f0": 2500, "f1": 1000, "dur": 0.05, "att": 0.001, "dec": 50.0, "vol": 0.5}]},
	"morte": {"gain": -7.0, "var": 0.1, "layers": [
		{"wave": "noise", "f0": 1600, "f1": 300, "dur": 0.35, "att": 0.005, "dec": 9.0, "vol": 0.7},
		{"wave": "tri", "f0": 420, "f1": 110, "dur": 0.3, "att": 0.005, "dec": 9.0, "vol": 0.5}]},
	"ferita": {"gain": -6.0, "var": 0.06, "layers": [
		{"wave": "tri", "f0": 320, "f1": 140, "dur": 0.2, "att": 0.002, "dec": 14.0, "vol": 0.8},
		{"wave": "noise", "f0": 900, "f1": 400, "dur": 0.12, "att": 0.002, "dec": 20.0, "vol": 0.5}]},
	"tira": {"gain": -10.0, "var": 0.08, "layers": [
		{"wave": "tri", "f0": 700, "f1": 280, "dur": 0.09, "att": 0.001, "dec": 28.0, "vol": 0.6},
		{"wave": "noise", "f0": 3000, "f1": 1500, "dur": 0.08, "att": 0.001, "dec": 35.0, "vol": 0.4}]},
	"spora": {"gain": -12.0, "var": 0.15, "layers": [
		{"wave": "sine", "f0": 520, "f1": 300, "dur": 0.12, "att": 0.005, "dec": 18.0, "vol": 0.6, "vib": [30.0, 0.05]}]},
	# muoversi
	"salto": {"gain": -16.0, "var": 0.08, "layers": [
		{"wave": "sine", "f0": 240, "f1": 420, "dur": 0.1, "att": 0.005, "dec": 22.0, "vol": 0.6},
		{"wave": "noise", "f0": 1000, "f1": 1500, "dur": 0.08, "att": 0.005, "dec": 25.0, "vol": 0.3}]},
	"atterra": {"gain": -13.0, "var": 0.1, "layers": [
		{"wave": "sine", "f0": 100, "f1": 60, "dur": 0.08, "att": 0.001, "dec": 35.0, "vol": 0.8},
		{"wave": "noise", "f0": 700, "f1": 300, "dur": 0.06, "att": 0.001, "dec": 40.0, "vol": 0.5}]},
	# oggetti e mondo
	"raccogli": {"gain": -14.0, "var": 0.05, "layers": [
		{"wave": "sine", "f0": 880, "f1": 880, "dur": 0.05, "att": 0.002, "dec": 40.0, "vol": 0.6},
		{"wave": "sine", "f0": 1320, "f1": 1320, "dur": 0.07, "att": 0.002, "dec": 30.0, "vol": 0.6, "delay": 0.045}]},
	"crea": {"gain": -11.0, "var": 0.0, "layers": [
		{"wave": "tri", "f0": 523, "f1": 523, "dur": 0.12, "att": 0.003, "dec": 18.0, "vol": 0.6},
		{"wave": "tri", "f0": 659, "f1": 659, "dur": 0.12, "att": 0.003, "dec": 18.0, "vol": 0.6, "delay": 0.07},
		{"wave": "tri", "f0": 784, "f1": 784, "dur": 0.2, "att": 0.003, "dec": 12.0, "vol": 0.6, "delay": 0.14}]},
	"apri": {"gain": -11.0, "var": 0.05, "layers": [
		{"wave": "square", "f0": 200, "f1": 300, "dur": 0.12, "att": 0.005, "dec": 18.0, "vol": 0.3},
		{"wave": "noise", "f0": 1500, "f1": 800, "dur": 0.1, "att": 0.002, "dec": 25.0, "vol": 0.5}]},
	"pozione": {"gain": -12.0, "var": 0.05, "layers": [
		{"wave": "sine", "f0": 500, "f1": 700, "dur": 0.06, "att": 0.005, "dec": 30.0, "vol": 0.6},
		{"wave": "sine", "f0": 650, "f1": 900, "dur": 0.06, "att": 0.005, "dec": 30.0, "vol": 0.6, "delay": 0.09},
		{"wave": "sine", "f0": 800, "f1": 1100, "dur": 0.08, "att": 0.005, "dec": 25.0, "vol": 0.6, "delay": 0.18}]},
	"obiettivo": {"gain": -9.0, "var": 0.0, "layers": [
		{"wave": "tri", "f0": 659, "f1": 659, "dur": 0.15, "att": 0.003, "dec": 12.0, "vol": 0.55},
		{"wave": "tri", "f0": 784, "f1": 784, "dur": 0.15, "att": 0.003, "dec": 12.0, "vol": 0.55, "delay": 0.09},
		{"wave": "tri", "f0": 988, "f1": 988, "dur": 0.15, "att": 0.003, "dec": 12.0, "vol": 0.55, "delay": 0.18},
		{"wave": "sine", "f0": 1319, "f1": 1319, "dur": 0.6, "att": 0.005, "dec": 5.0, "vol": 0.5, "delay": 0.27}]},
	"portale": {"gain": -8.0, "var": 0.0, "layers": [
		{"wave": "sine", "f0": 180, "f1": 720, "dur": 1.2, "att": 0.2, "dec": 2.5, "vol": 0.6, "vib": [7.0, 0.04]},
		{"wave": "noise", "f0": 600, "f1": 3000, "dur": 1.0, "att": 0.3, "dec": 3.0, "vol": 0.4}]},
	"guardiano": {"gain": -5.0, "var": 0.0, "layers": [
		{"wave": "noise", "f0": 350, "f1": 180, "dur": 1.4, "att": 0.15, "dec": 2.2, "vol": 0.9},
		{"wave": "sine", "f0": 80, "f1": 55, "dur": 1.4, "att": 0.1, "dec": 2.0, "vol": 0.8, "vib": [5.0, 0.08]}]},
}

## Sottofondo di ogni strato (`StrataData`): toni bassi e lenti più un soffio di rumore, in un anello senza cuciture.
## tones = [[Hz, volume], …] (le frequenze sono multipli di 0,25 Hz: l'anello di 4 s si richiude perfetto),
## noise = [taglio del filtro, volume], lfo = respiro lento del volume (Hz).
const AMBIENT := [
	{"tones": [], "noise": [900.0, 0.18], "lfo": 0.25, "gain": -24.0},
	{"tones": [[110.0, 0.2], [165.0, 0.1]], "noise": [500.0, 0.12], "lfo": 0.25, "gain": -22.0},
	{"tones": [[70.0, 0.25], [105.0, 0.1]], "noise": [350.0, 0.15], "lfo": 0.5, "gain": -21.0},
	{"tones": [[220.0, 0.08], [330.0, 0.07], [440.0, 0.04]], "noise": [700.0, 0.08], "lfo": 0.75, "gain": -23.0},
	{"tones": [[55.0, 0.3], [58.25, 0.2]], "noise": [250.0, 0.15], "lfo": 0.25, "gain": -19.0},
]
const AMBIENT_LOOP := 4.0
