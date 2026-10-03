class_name TruthData
extends RefCounted
## Il Taccuino della verità (Roadmap 36, voce 345; canone in `UNIVERSO.md`). Le domande della storia, le versioni che
## si raccolgono (ognuna da una fonte: stele, cripte, Cronache, abitanti, Guardiani, sogni) e la prova che dice qual è
## quella vera. Una domanda compare con la prima versione vista; si risolve da sola quando si è vista la versione vera
## **e** si è trovata la prova. Condizioni di `LoreConds`. Solo dati: le regole in `Truth`.
##   versions: [testo, fonte, quando la si conosce, giudizio («vera», «falsa», «mezza»)]

const REWARD := {"linfa_antica": 1}

const QUESTIONS := [
	{"id": "seme", "q": "Come arrivò il Seme Nero?",
		"versions": [
			["Cadde dal cielo.", "le stele", {"stat": "stele", "n": 1}, "falsa"],
			["I Seminatori lo accolsero, per il suo potere.", "una cripta", {"stat": "catene", "n": 1}, "mezza"],
			["Fu chiamato dalla Bocca, nel Vuoto.", "la lingua nera", {"stat": "catene", "n": 3}, "mezza"],
			["Qualcuno lo lasciò andare.", "il Giardino muto", {"stat": "perduto_muto", "n": 1}, "vera"],
			["Saréth lo piantò, di notte, da sola.", "un eco", {"echo": "nome"}, "vera"]],
		"proof": {"echo": "bugia"}},
	{"id": "partiti", "q": "Dove sono andati i Seminatori?",
		"versions": [
			["Se ne andarono una mattina, senza dire niente.", "il Giardino selvatico", {"page": "perduto_selvatico"}, "falsa"],
			["Partirono oltre il Vuoto, a cercare aiuto.", "una Cronaca", {"stat": "cronaca_viaggio_vuoto", "n": 1}, "mezza"],
			["Seminarono Guardiani, uno in ogni Cuore.", "una Cronaca", {"stat": "cronaca_ultima_semina", "n": 1}, "mezza"],
			["Non sono andati da nessuna parte: sono i Guardiani.", "un Guardiano curato", {"sower": "odran", "n": 1}, "vera"]],
		"proof": {"any": [{"echo": "pezzi"}, {"sower": "ilvenna", "n": 4}]}},
	{"id": "male", "q": "Che cos'è l'Avvizzimento?",
		"versions": [
			["Una malattia dei mondi.", "l'Erbario", {"stat": "guardiani", "n": 1}, "falsa"],
			["Il Seme Nero beve la Linfa.", "una cripta", {"stat": "catene", "n": 2}, "mezza"],
			["Si nutre di fame e di memoria.", "Odràn", {"sower": "odran", "n": 3}, "vera"]],
		"proof": {"any": [{"echo": "canto"}, {"dream": "gola"}]}},
	{"id": "guardiani", "q": "Chi fece ammalare i Guardiani?",
		"versions": [
			["Il Seme Nero.", "il Colosso", {"page": "colosso_sconfitto"}, "mezza"],
			["Varèk, con le sue mani.", "Varèk", {"sower": "varek", "n": 3}, "vera"]],
		"proof": {"any": [{"echo": "pezzi"}, {"dream": "pietra"}]}},
	{"id": "alberi", "q": "Perché gli Alberi fratelli si persero?",
		"versions": [
			["Li fusero alle macchine per farli lavorare.", "il Giardino di ferro", {"page": "atto2_ferro"}, "mezza"],
			["Volevano farli cantare insieme, più forte della chiamata.", "Varèk", {"sower": "varek", "n": 2}, "vera"]],
		"proof": {"echo": "alberi"}},
	{"id": "ritorno", "q": "Chi è «l'ultimo giardiniere che ritorna»?",
		"versions": [
			["I Seminatori, un giorno.", "le stele", {"stat": "stele", "n": 4}, "falsa"],
			["Nessuno: i Seminatori non possono tornare.", "Odràn", {"sower": "odran", "n": 5}, "mezza"],
			["Tu.", "Maesh", {"stat": "ultimo_seminatore", "n": 1}, "vera"]],
		"proof": {"any": [{"dream": "radice"}, {"echo": "radice"}]}},
	{"id": "avvizzitore", "q": "Chi è l'Avvizzitore?",
		"versions": [
			["Il Seme Nero, cresciuto.", "la via del Seme Nero", {"stat": "catene", "n": 4}, "mezza"],
			["Saréth, la Voce.", "il Cuore del Seme Nero", {"nero": "si"}, "vera"]],
		"proof": {"any": [{"echo": "risposta"}, {"dream": "seme"}, {"spent": 1}]}},
	{"id": "germogliato", "q": "Di che cosa sei fatto?",
		"versions": [
			["Di un frutto dell'Albero-Madre.", "la Vecchia Radice", {}, "mezza"],
			["Della Linfa dei Seminatori.", "una Cronaca", {"stat": "cronaca_mani_linfa", "n": 1}, "mezza"],
			["Della Linfa di Saréth, soprattutto.", "un sogno", {"dream": "linfa"}, "vera"]],
		"proof": {"dream": "linfa"}},
]


static func get_q(id: String) -> Dictionary:
	for q in QUESTIONS:
		if String(q["id"]) == id:
			return q
	return {}
