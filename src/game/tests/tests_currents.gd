class_name TestsCurrents
extends RefCounted
## Roadmap 27 «Acque e correnti»: i record e le gare di pesca, i contratti della rete (gruppo `correnti`).

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func _restore(st: Dictionary, saved: Dictionary) -> void:
	for k in st.keys():
		if not saved.has(k):
			st.erase(k)
		else:
			st[k] = saved[k]


func run() -> void:
	await records()
	await contest()


## Voce 258: la misura dà la medaglia; una medaglia migliore sostituisce la vecchia (con i premi di mezzo), una peggiore no.
func records() -> void:
	var ab: AnglerBook = m.angler
	ab.paused = false
	var st: Dictionary = m.character.stats
	var saved := st.duplicate()
	var mastery0: Dictionary = m.character.maestria.duplicate(true)   # i gradi della pesca cambierebbero le prove dopo
	var id := "pesce_carpa_lanterna"
	var span: Array = FishData.info(id)["size"]
	var lo := int(span[0])
	var hi := int(span[1])
	st.erase("record_" + id)
	var t0 := AnglerBook.tier_of(id, lo)
	var t3 := AnglerBook.tier_of(id, hi)
	var m0 := int(st.get("medaglie_pesca", 0))
	var gifts := ["lumino", "cassetta_alga", "polvere_iridata", "forziere_sommerso", "linfa_antica", "scrigno_fondo"]
	var had := {}
	for it in gifts:
		had[it] = m.character.bisaccia.count(it)
	m.fishing.fish_caught.emit(id, lo + roundi((hi - lo) * 0.5))
	var after_bronze := ab.medal(id)
	m.fishing.fish_caught.emit(id, hi)
	var after_gold := ab.medal(id)
	m.fishing.fish_caught.emit(id, lo + roundi((hi - lo) * 0.75))
	var still := ab.medal(id)
	var medals := int(st.get("medaglie_pesca", 0)) - m0
	var ok: bool = t0 == 0 and t3 == 3 and after_bronze == 1 and after_gold == 3 and still == 3 and medals == 3
	print("record di pesca: misure %d-%d; medaglie %d → %d → %d (conteggio +%d); %s" % [lo, hi, after_bronze, after_gold, still,
		medals, ab.line()])
	if not ok:
		print("ATTENZIONE: i record di pesca non vanno")
	for it in gifts:                               # via esattamente ciò che è stato dato: la Bisaccia delle prove è piena
		m.character.bisaccia.remove(it, maxi(m.character.bisaccia.count(it) - int(had[it]), 0))
	_restore(st, saved)
	m.character.maestria.clear()
	m.character.maestria.merge(mastery0)
	m.gear.refresh()
	ab.paused = true


## Voce 259: la gara del giorno sceglie una specie già pescata; una presa piccola non vince, una grande sì, una volta al
## giorno; un giorno senza vittoria azzera la serie.
func contest() -> void:
	var ab: AnglerBook = m.angler
	ab.paused = false
	var st: Dictionary = m.character.stats
	var saved := st.duplicate()
	var mastery0: Dictionary = m.character.maestria.duplicate(true)
	var er: Dictionary = m.character.erbario
	if not er.has("pesci"):
		er["pesci"] = {}
	var had_fish: bool = (er["pesci"] as Dictionary).has("pesce_carpa_lanterna")
	(er["pesci"] as Dictionary)["pesce_carpa_lanterna"] = {"n": 1, "max": 20}
	st["gara_serie"] = 2
	ab.new_day(100)
	var id := ab.contest
	var small := ab.need() - 1
	var g0 := int(st.get("gare_pesca", 0))
	var dust0: int = m.character.bisaccia.count("polvere_iridata")
	var crates0: int = m.character.bisaccia.count("cassetta_alga")
	ab._contest(id, small)
	var lost_small := int(st.get("gare_pesca", 0)) == g0
	ab._contest(id, ab.need())
	ab._contest(id, ab.need() + 5)
	var won_once := int(st.get("gare_pesca", 0)) == g0 + 1 and int(st.get("gara_serie", 0)) == 3
	ab.new_day(101)
	ab.new_day(102)                                # il 101 senza vittoria: la serie si azzera
	var reset := int(st.get("gara_serie", 0)) == 0
	var ok: bool = id != "" and lost_small and won_once and reset
	print("gare di pesca: oggi %s da %d cm; piccolo no %s; vinta una volta sola %s; serie azzerata %s" % [id, small + 1, lost_small, won_once, reset])
	if not ok:
		print("ATTENZIONE: le gare di pesca non vanno")
	m.character.bisaccia.remove("polvere_iridata", maxi(m.character.bisaccia.count("polvere_iridata") - dust0, 0))
	m.character.bisaccia.remove("cassetta_alga", maxi(m.character.bisaccia.count("cassetta_alga") - crates0, 0))
	if not had_fish:
		(er["pesci"] as Dictionary).erase("pesce_carpa_lanterna")
	_restore(st, saved)
	m.character.maestria.clear()
	m.character.maestria.merge(mastery0)
	m.gear.refresh()
	ab.paused = true
