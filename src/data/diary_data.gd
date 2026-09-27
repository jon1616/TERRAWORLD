class_name DiaryData
## I testi del diario della partita (voce 83). Solo dati: li usa `Diary`.
##   FIRSTS  la prima volta che un conteggio del personaggio (`Objectives.bump`) sale: la tappa da scrivere
##   EVERY   conteggi che meritano una tappa ogni volta (%d = quante in tutto)
##   COLORS  il colore della riga nella scheda «Storia» del Semenzaio, per tipo di tappa

const FIRSTS := {
	"viaggi": "Primo viaggio attraverso un portale",
	"cuore": "Primo Cuore del mondo trovato",
	"semine": "Primo seme piantato nell'orto",
	"raccolti": "Primo raccolto",
	"scrigni": "Primo Scrigno dei Seminatori aperto",
	"reliquiari": "Primo reliquiario trovato",
	"segreti": "Primo segreto trovato",
	"mondi_completi": "Primo mondo con tutti i segreti trovati",
	"innesti": "Primo innesto su un'arma o un'armatura",
	"geni_imparati": "Primo gene imparato",
	"mutazioni": "Primo Seme mutato all'Innestatrice",
	"addomesticate": "Prima creatura addomesticata",
	"uova": "Primo uovo trovato",
	"schiuse": "Primo uovo schiuso",
	"cavalcate": "Prima cavalcata",
	"abitanti": "Primo abitante arrivato",
	"richieste": "Prima richiesta di un abitante completata",
	"bacheca": "Prima richiesta della Bacheca completata",
	"custodi": "Primo Custode dello strato sconfitto",
	"sigilli": "Primo Sigillo aperto",
	"firme": "Prima firma di un mondo trovata",
	"stele": "Prima stele dei Seminatori letta",
	"catene": "Prima tappa di una catena compiuta",
	"purificate": "Prima terra avvizzita purificata",
	"eventi": "Primo evento del mondo",
	"eventi_vinti": "Primo evento superato",
	"doni": "Primo dono assorbito (Vita o Linfa per sempre)",
	"oggetti_trofeo": "Primo oggetto fatto con un trofeo",
	"reazioni": "Prima reazione tra elementi",
	"stagioni": "Prima stagione vista cambiare",
	"alleati": "Primo alleato evocato",
	"evocati": "Primo Guardiano evocato al Cerchio dei Seminatori",
}

const EVERY := {
	"leggende": "Leggenda compiuta (%d in tutto)",
	"sfide": "Sfida dei Semi vinta (%d in tutto)",
	"seme_primo": "Il Primo Mondo è compiuto",
}

const COLORS := {
	"guardiano": "#ffd08a", "vigore": "#8ef0d8", "albero": "#9fe070", "morte": "#ff8a78", "metallo": "#e0c080",
	"leggende": "#ffd24a", "leggenda": "#ffd24a", "sfide": "#ffb070", "seme_primo": "#ffe8a0", "viaggi": "#6ff0d8",
}
