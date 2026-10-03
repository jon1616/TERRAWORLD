class_name VoidVoiceData
extends RefCounted
## La Bocca (Roadmap 36, voce 347; canone in `UNIVERSO.md`): la cosa nel Vuoto che chiamò il Seme Nero. Non si vede mai.
## Nei luoghi malati (vicino all'Avvizzimento, nel mondo del Seme Nero, nel Fondo) a volte una scritta si rivolge al
## Germogliato. Dopo la scelta sul Seme Nero, se è stato curato, a volte risponde Saréth. Condizioni di `LoreConds`.
##   [chi («bocca» o «sareth»), frase, condizione]

const EVERY := [200.0, 420.0]            # secondi tra due scritte (a caso fra i due)
const NEAR := 7                          # tessere di Avvizzimento attorno al Germogliato che bastano
const COLORS := {"bocca": "#9a7ab8", "sareth": "#c8a0ff"}

const LINES := [
	["bocca", "Ti sento camminare.", {}],
	["bocca", "Anche tu hai fame. Lo so.", {}],
	["bocca", "Qui la terra è già mia. Resta un po'.", {}],
	["bocca", "Li svegli uno per uno. Io li aspetto tutti.", {"stat": "guardiani", "n": 1}],
	["bocca", "Quel Cuore era mio. Lo sarà di nuovo.", {"stat": "guardiani", "n": 2}],
	["bocca", "Ogni nome che spegni, lo tengo io.", {"spent": 2}],
	["bocca", "Ti hanno dato un nome? Io ne conosco uno più vecchio.", {"sower": "ilvenna", "n": 1}],
	["bocca", "Le cripte mentono. Io no.", {"stat": "catene", "n": 2}],
	["bocca", "L'Albero dorme ancora, dentro. Lo sento respirare.", {"albero": 6}],
	["bocca", "Quattro alberi. Ne è rimasto qualcuno?", {"stat": "perduti", "n": 2}],
	["bocca", "Mi hai sognato. Io ti sogno sempre.", {"dream": "gola"}],
	["bocca", "Più sai, più mi assomigli.", {"truths": 3}],
	["bocca", "Lei rispondeva. Rispondi anche tu.", {"nero": "si"}],
	["bocca", "Me l'hai tolta. Ne troverò un'altra.", {"nero": "spezzato"}],
	["sareth", "Non ascoltarla. Io l'ho fatto.", {"nero": "curato"}],
	["sareth", "Mi chiama ancora. Adesso chiama anche te.", {"nero": "curato"}],
	["sareth", "Se ti fa una promessa, è vera. È questo il guaio.", {"nero": "curato"}],
	["sareth", "Sei fatto anche di me. Mi dispiace.", {"all": [{"nero": "curato"}, {"dream": "linfa"}]}],
]
