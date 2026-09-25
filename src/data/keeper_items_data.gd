class_name KeeperItemsData
extends RefCounted
## Gli oggetti dei Custodi degli strati (voce 27): ciò che lasciano (un materiale regale ciascuno, sempre), ciò che se
## ne fa, i richiami per risvegliarli all'Altare dei Seminatori, l'Altare stesso. Solo dati; uniti in `ItemsData.all()`
## e `RecipesData.all()`.

const ITEMS := {
	"altare": {"name": "Altare dei Seminatori", "kind": "stazione", "icon": ["altare", "sem"], "place": "altare", "stack": 99, "desc": "Un altare ricomposto con le pietre delle rovine. Con un richiamo in mano, un clic vicino all'altare risveglia un Custode già sconfitto."},
	# i materiali regali
	"gelatina_regale": {"name": "Gelatina regale", "kind": "materiale", "icon": ["gel", "cristallo"], "desc": "Il cuore tremolante della Madre dei grumi."},
	"seta_regale": {"name": "Seta regale", "kind": "materiale", "icon": ["seta", "ambra"], "desc": "Filo d'oro della Tessitrice delle radici: non si spezza."},
	"scaglia_madre": {"name": "Scaglia della Serpe madre", "kind": "materiale", "icon": ["scaglia", "linfa"], "desc": "Grande come una mano, calda di Linfa."},
	"nucleo_cavo": {"name": "Nucleo cavo", "kind": "materiale", "icon": ["geode", "nottilite"], "desc": "Dentro il Mietitore non c'era niente. Tranne questo."},
	# ciò che se ne fa
	"corona_gelatina": {"name": "Corona gelatinosa", "kind": "accessorio", "icon": ["corona", "cristallo"], "acc": {"jump": 1.3, "fall_safe": true, "regen": 1.2}, "desc": "Salto molto più alto, niente cadute, Vita +20%."},
	"cuscino_grumi": {"name": "Sacca dei grumi", "kind": "accessorio", "icon": ["sacca", "muschio"], "defense": 4, "acc": {"regen": 1.4}, "desc": "+4 Scorza e la Vita ricresce il 40% più in fretta."},
	"manto_tessitrice": {"name": "Manto della Tessitrice", "kind": "accessorio", "icon": ["mantello", "ambra"], "acc": {"glide": true, "stealth": 0.75, "thorns": 8}, "desc": "Planata, visto più tardi, chi ti tocca resta invischiato (8)."},
	"arco_seta": {"name": "Arco di seta regale", "kind": "arco", "icon": ["arco", "ambra"], "tier": 3, "damage": 15, "speed": 2.4, "knockback": 1.2, "multishot": 2, "desc": "La corda di seta regale tira due dardi a ogni colpo."},
	"anello_madre": {"name": "Anello della Serpe madre", "kind": "accessorio", "icon": ["anello", "linfa"], "acc": {"magic": 1.15, "linfa_regen": 1.4}, "desc": "Incantesimi +15%, Linfa +40%."},
	"bastone_serpe": {"name": "Bastone della Serpe", "kind": "bastone", "icon": ["bastone", "linfa"], "tier": 4, "damage": 20, "speed": 2.0, "knockback": 1.0, "spell": "serpe", "linfa": 7, "desc": "Tre piccole serpi di Linfa che cercano le creature."},
	"falce_mietitore": {"name": "Falce del Mietitore", "kind": "spada", "icon": ["falce", "nottilite"], "tier": 6, "damage": 46, "speed": 2.5, "knockback": 5.0, "desc": "Taglia come il Vuoto."},
	"cuore_cavo": {"name": "Cuore cavo", "kind": "accessorio", "icon": ["cuore", "vuotite"], "acc": {"damage": 1.15, "atk_speed": 1.1}, "desc": "+15% danno, colpi il 10% più rapidi."},
	# i richiami: risvegliano all'Altare un Custode già sconfitto in questo mondo
	"richiamo_madre": {"name": "Goccia di richiamo", "kind": "richiamo", "icon": ["goccia", "muschio"], "stack": 10, "desc": "All'Altare dei Seminatori risveglia la Madre dei grumi."},
	"richiamo_tessitrice": {"name": "Filo di richiamo", "kind": "richiamo", "icon": ["seta", "seta"], "stack": 10, "desc": "All'Altare dei Seminatori risveglia la Tessitrice delle radici."},
	"richiamo_serpe": {"name": "Scaglia di richiamo", "kind": "richiamo", "icon": ["scaglia", "cristallo"], "stack": 10, "desc": "All'Altare dei Seminatori risveglia la Serpe madre."},
	"richiamo_mietitore": {"name": "Eco del Vuoto", "kind": "richiamo", "icon": ["essenza", "vuotite"], "stack": 10, "desc": "All'Altare dei Seminatori risveglia il Mietitore cavo."},
}

const RECIPES := [
	{"out": "altare", "qty": 1, "in": {"pietra_seminatori": 15, "legno": 10, "torcia": 5}, "station": "ceppo"},
	{"out": "corona_gelatina", "qty": 1, "in": {"gelatina_regale": 6, "gelatina": 20}, "station": "maglio"},
	{"out": "cuscino_grumi", "qty": 1, "in": {"gelatina_regale": 5, "lingotto_radicite": 6}, "station": "maglio"},
	{"out": "manto_tessitrice", "qty": 1, "in": {"seta_regale": 6, "seta_radice": 10}, "station": "telaio"},
	{"out": "arco_seta", "qty": 1, "in": {"seta_regale": 5, "legno": 10, "lingotto_legnoferro": 4}, "station": "telaio"},
	{"out": "anello_madre", "qty": 1, "in": {"scaglia_madre": 5, "lingotto_ambra": 4}, "station": "mola"},
	{"out": "bastone_serpe", "qty": 1, "in": {"scaglia_madre": 6, "cristallo_linfa": 8}, "station": "maglio"},
	{"out": "falce_mietitore", "qty": 1, "in": {"nucleo_cavo": 6, "lingotto_tizzonite": 8}, "station": "maglio"},
	{"out": "cuore_cavo", "qty": 1, "in": {"nucleo_cavo": 5, "nottilite": 4}, "station": "mola"},
	{"out": "richiamo_madre", "qty": 1, "in": {"gelatina": 25, "lamella_fungo": 5}, "station": "altare"},
	{"out": "richiamo_tessitrice", "qty": 1, "in": {"seta_radice": 20, "aculeo": 6}, "station": "altare"},
	{"out": "richiamo_serpe", "qty": 1, "in": {"scaglia_linfa": 12, "polline_luminoso": 6}, "station": "altare"},
	{"out": "richiamo_mietitore", "qty": 1, "in": {"lama_vuoto": 3, "seta_vuoto": 8}, "station": "altare"},
]
