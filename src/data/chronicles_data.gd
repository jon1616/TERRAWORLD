class_name ChroniclesData
extends RefCounted
## Le cronache perdute (Roadmap 26, voce 255; regole in `Chronicles`): otto storie dei Seminatori, ognuna in cinque
## frammenti che si trovano negli scrigni delle rovine (le tabelle «rovina_N» di `LootData`, più profonde per le storie
## più tarde). Ogni frammento è un oggetto che si legge nella sua scheda; con tutti e cinque la storia si ricompone
## (una pagina), dà un premio e va nel Museo (sala «cronache»).
##   [titolo, tabella delle rovine, premio, [cinque frammenti]]

const CHANCE := 0.05

const STORIES := {
	"primo_seme": ["Il primo seme", "rovina_1", {"linfa_antica": 2}, [
		"Prima dei mondi c'era soltanto il Vuoto, e nel Vuoto una radice che non finiva mai.",
		"I Seminatori la seguirono per un tempo che non sapevano contare, finché la radice non fece un nodo.",
		"Nel nodo c'era un seme grande come un pugno, caldo come una mano. Nessuno l'aveva piantato.",
		"Lo misero in una conca di Linfa e lo guardarono per sette notti: all'ottava si aprì, e ne uscì un mondo piccolo.",
		"Il primo mondo aveva un solo albero. Da quell'albero caddero i frutti di tutti gli altri: lo chiamarono Madre."]],
	"serra_vetro": ["La serra di vetro", "rovina_1", {"vetro_resina": 20, "polvere_iridata": 1}, [
		"Tra un mondo e l'altro i Seminatori costruirono serre di vetro, sospese nel Vuoto come lanterne.",
		"Nelle serre i semi riposavano prima di partire: al caldo, al buio, ascoltando il canto delle radici.",
		"Nelle serre c'era Ilvenna, che parlava ai semi uno per uno, per nome.",
		"Quando un seme era pronto, il custode lo portava all'Aiuola più vicina e lo lasciava andare.",
		"Delle serre oggi restano i vetri spezzati nelle rovine. Ma se li metti al sole, cantano ancora."]],
	"custode_sveglio": ["Il Custode che non dormiva", "rovina_2", {"scheggia_vigore": 6}, [
		"Ogni mondo ebbe un Cuore, e ogni Cuore un Guardiano che doveva proteggerlo dal Vuoto.",
		"I Guardiani dormivano: si svegliavano soltanto quando qualcosa si avvicinava al Cuore.",
		"Uno solo, Odràn, non dormiva mai. Guardava il Vuoto giorno e notte, e nel Vuoto vide qualcosa muoversi.",
		"Lo disse ai Seminatori, ma nessuno lo ascoltò: nel Vuoto, dicevano, non si muove niente.",
		"Quando l'Avvizzimento arrivò, fu il primo a combatterlo, e il primo ad ammalarsi. Ancora oggi aspetta chi lo curi."]],
	"lingua_radici": ["La lingua delle radici", "rovina_2", {"tavoletta_seminatori": 4}, [
		"I Seminatori non parlavano con la bocca: parlavano toccando le radici, e le radici portavano le parole lontano.",
		"Per non dimenticarle, incisero le parole nella pietra, con segni storti come radici.",
		"Ogni segno era una radice ferma: chi lo guardava a lungo sentiva la parola, anche senza capirla.",
		"Le parole più antiche erano poche e lente; le ultime, veloci e dure, le scrissero di fretta, prima di partire.",
		"Chi legge le stele non impara soltanto una lingua: ascolta i Seminatori che parlano ancora."]],
	"lite": ["La lite dei giardinieri", "rovina_3", {"linfa_antica": 3}, [
		"Venne il giorno in cui i Seminatori non furono più d'accordo.",
		"Alcuni volevano piantare solo semi sani. Saréth voleva provare un seme nato dal Vuoto, nero come la notte.",
		"«Un seme che nasce dal Vuoto può dare un mondo più grande di tutti», dicevano. «O divorarli tutti», rispondevano gli altri.",
		"La lite durò tanto che le Aiuole restarono vuote, e l'Albero-Madre cominciò a stancarsi.",
		"Una notte, senza dirlo a nessuno, qualcuno piantò il seme nero."]],
	"ultima_semina": ["L'ultima semina", "rovina_3", {"polvere_iridata": 4}, [
		"L'Avvizzimento partì dal mondo del seme nero e si mise a camminare lungo le radici.",
		"I Seminatori capirono che non potevano fermarlo con le mani: potevano solo rallentarlo.",
		"Per l'ultima volta seminarono insieme. Non mondi: Guardiani, uno in ogni Cuore. Nessuno scrisse di che cosa erano fatti.",
		"Poi chiusero i Sigilli, perché nessuno trovasse la strada verso ciò che avevano nascosto.",
		"L'Albero-Madre, stanco, lasciò cadere un ultimo frutto e si addormentò. Da quel frutto nascesti tu."]],
	"mani_linfa": ["Le mani di Linfa", "rovina_4", {"cristallo_linfa": 8}, [
		"Nessuno sa che aspetto avessero i Seminatori. Nelle rovine non c'è un solo ritratto.",
		"Ma sui muri delle serre ci sono impronte: mani lunghe, con le dita come radici sottili.",
		"Le impronte brillano appena di Linfa, come se chi le ha lasciate fosse fatto di Linfa anche lui.",
		"Forse i Seminatori non avevano un corpo come il nostro: forse erano Linfa che aveva imparato a camminare.",
		"Guarda le tue mani, Germogliato. Guarda le venature. Forse non sei così diverso da loro."]],
	"viaggio_vuoto": ["Il viaggio nel Vuoto", "rovina_4", {"linfa_antica": 5}, [
		"Dove sono andati i Seminatori? Le stele dicono «oltre». Ma le stele le scrissero loro.",
		"Oltre il Vuoto, raccontano i canti, c'è un altro Giardino, più grande, con un Albero ancora sveglio.",
		"Tre di loro partirono per chiedere aiuto a quell'Albero, seguendo la radice più lunga di tutte.",
		"Non sono tornati. Ma la radice c'è ancora, e dove finisce qualcuno ha lasciato un seme che nessuno ha piantato.",
		"Lo chiamano il Seme Primo. Chi lo pianterà saprà, forse, dove sono andati."]],
}


static func fragment_id(story: String, n: int) -> String:
	return "cronaca_%s_%d" % [story, n + 1]


static func items() -> Dictionary:
	var out := {}
	for s in STORIES:
		var d: Array = STORIES[s]
		for n in 5:
			out[fragment_id(s, n)] = {"name": "Cronaca: %s (%d/5)" % [String(d[0]), n + 1], "kind": "ricordo", "icon": ["tavoletta", "sem"],
				"stack": 5, "source": "scrigni delle rovine", "desc": "«%s»" % String(d[3][n])}
	return out


## Le voci da aggiungere alle tabelle delle rovine: {tabella: [voci di `LootData`]}.
static func loot() -> Dictionary:
	var out := {}
	for s in STORIES:
		var t := String(STORIES[s][1])
		if not out.has(t):
			out[t] = []
		for n in 5:
			(out[t] as Array).append({"item": fragment_id(s, n), "min": 1, "max": 1, "chance": CHANCE})
	return out
