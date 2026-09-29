class_name Milestones
extends RefCounted
## I traguardi delle collezioni (Roadmap 26, voce 256): premi una volta sola quando una grande collezione arriva a una
## soglia (gli accessori dei premi in `MuseumData.MILESTONE_ITEMS`; l'Erbario a un quarto, metà, tre quarti, tutto; ogni strato della lingua; tutte le reliquie; metà delle serie
## di unici; tutto il Museo). `Character.stats["traguardo_<id>"]`; li controlla `Museum` ogni `EVERY` secondi, ovunque.
##   [id, frase, premio]

const EVERY := 10.0
const LIST := [
	["erbario_25", "L'Erbario a un quarto", {"polvere_iridata": 3}],
	["erbario_50", "L'Erbario a metà", {"linfa_antica": 3, "polvere_iridata": 3}],
	["erbario_75", "L'Erbario a tre quarti", {"linfa_antica": 5, "scheggia_vigore": 8}],
	["erbario_100", "L'Erbario completo", {"sigillo_collezionista": 1}],
	["lingua_comune", "La lingua comune, tutta", {"tavoletta_seminatori": 5}],
	["lingua_antica", "La lingua antica, tutta", {"linfa_antica": 4}],
	["lingua_nera", "La lingua nera, tutta", {"corona_lingua": 1}],
	["reliquie", "Tutte le reliquie dei Seminatori", {"polvere_iridata": 6}],
	["serie_unici", "Metà delle serie di unici", {"linfa_antica": 5}],
	["museo", "Tutte le sale del Museo", {"polvere_iridata": 10, "linfa_antica": 5}],
]

var m: Node2D


func _init(main: Node2D) -> void:
	m = main


## È raggiunto adesso?
func reached(id: String) -> bool:
	match id:
		"erbario_25", "erbario_50", "erbario_75", "erbario_100":
			return m.erbario.percent() >= float(id.get_slice("_", 1)) - 0.001
		"lingua_comune", "lingua_antica", "lingua_nera":
			if m.get("language") == null:
				return false
			var ws := LanguageData.words_of(id.get_slice("_", 1))
			for w in ws:
				if not m.language.known(String(w)):
					return false
			return not ws.is_empty()
		"reliquie":
			return RelicsData.complete(m.character.erbario.get("oggetti", {})).size() >= RelicsData.COLLECTIONS.size()
		"serie_unici":
			return UniqueSeriesData.complete(m.character.erbario.get("oggetti", {})).size() * 2 >= UniqueSeriesData.SERIES.size()
		"museo":
			for h in MuseumData.HALLS:
				if int(m.character.stats.get("sala_" + h, 0)) == 0:
					return false
			return true
	return false


## I traguardi raggiunti adesso (e i premi).
func check() -> Array:
	var fresh := []
	var st: Dictionary = m.character.stats
	for e in LIST:
		var id := String(e[0])
		if int(st.get("traguardo_" + id, 0)) == 1 or not reached(id):
			continue
		st["traguardo_" + id] = 1
		fresh.append(id)
		m.objectives.bump("traguardi")
		var gift := Lineage._give(m, e[2])
		m.hud.toast("Traguardo: %s · %s" % [e[1], gift])
		m.sfx.play("obiettivo")
		if m.get("diary") != null:
			m.diary.note("Traguardo: %s" % e[1], "traguardo")
	return fresh
