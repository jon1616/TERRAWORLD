class_name TestsLore
extends RefCounted
## La storia vera (gruppo `storia`, Roadmap 36): i Seminatori nei Cuori, i sogni, gli echi, il Taccuino della verità, le
## leggende dei luoghi, la Bocca. Ogni prova rimette com'erano le statistiche del personaggio che tocca.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var st0: Dictionary = (m.character.stats as Dictionary).duplicate(true)
	var ma0: Variant = m.character.maestria.duplicate(true)       # (i conteggi danno punti di maestria: si rimettono)
	await sowers()
	m.character.stats = st0
	m.character.maestria = ma0


## Voce 342: curare risveglia (il nome, poi un ricordo alla volta), abbattere spegne; il Taccuino ne parla.
func sowers() -> void:
	var sw: Sowers = m.sowers
	sw.paused = true
	var st: Dictionary = m.character.stats
	for k in SowersData.ORDER + ["senza_nome"]:
		st.erase("risveglio_" + k)
		st.erase("spento_" + k)
	var none := sw.rows("").is_empty()
	var l1 := sw.on_resolved("nodo", "curato")
	var l2 := sw.on_resolved("nodo", "curato")
	sw.on_resolved("nodo", "sconfitto")
	sw.on_resolved("avvizzitore", "sconfitto")
	sw.on_resolved("generato", "curato")
	sw.on_resolved("colosso", "sconfitto")
	var det := sw.detail()
	var ok: bool = none and l1 == String(SowersData.SOWERS["odran"]["memories"][0]) \
		and l2 == String(SowersData.SOWERS["odran"]["memories"][1]) \
		and int(st.get("risveglio_odran", 0)) == 2 and int(st.get("spento_odran", 0)) == 1 \
		and int(st.get("spento_sareth", 0)) == 1 and det.contains("Odràn") and det.contains("Saréth") \
		and not det.contains("Varèk") and det.contains("?") and sw.rows("").size() == 1 \
		and m.chains.view("storia:seminatori")[2] == det
	print("Seminatori: Odràn risvegliato due volte («%s»), spento una; Saréth spenta; Varèk spento e ancora senza nome (%s); Taccuino %s" % [
		l2, "sì" if not det.contains("Varèk") else "NO", "sì" if sw.rows("").size() == 1 else "NO"])
	if not ok:
		print("ATTENZIONE: i Seminatori nei Cuori non vanno")
	sw.paused = false
