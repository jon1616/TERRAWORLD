class_name OptionsData
## Le opzioni del gioco (27 set 2026, richiesta dell'utente: «una ampia e completa schermata delle opzioni che copra
## tutti gli aspetti del gioco»). Solo dati: ogni opzione è una riga; `Settings` le salva, `OptionsPanel` le mostra,
## i moduli le leggono con `Settings.v(id)`. Aggiungere un'opzione = una riga qui + chi la legge.
## Tipi: "slider" (min, max, step, fmt: "pct" percentuale, "s" secondi), "bool", "choice" (choices: [[valore, nome]]).
## I comandi (tasti) sono in `KeysData`.

const SECTIONS := [
	["audio", "Audio"], ["video", "Video"], ["interfaccia", "Interfaccia"], ["gioco", "Gioco"],
	["suggerimenti", "Suggerimenti"], ["comandi", "Comandi"],
]

const OPTIONS := [
	# audio
	{"id": "volume", "sec": "audio", "name": "Volume generale", "type": "slider", "min": 0.0, "max": 1.0, "step": 0.05,
		"fmt": "pct", "def": 1.0, "desc": "Alza o abbassa tutto insieme: musica, effetti e ambiente."},
	{"id": "musica", "sec": "audio", "name": "Musica", "type": "slider", "min": 0.0, "max": 1.0, "step": 0.05, "fmt": "pct",
		"def": 0.6, "desc": "Le musiche di esplorazione e dei Guardiani."},
	{"id": "effetti", "sec": "audio", "name": "Effetti", "type": "slider", "min": 0.0, "max": 1.0, "step": 0.05, "fmt": "pct",
		"def": 0.8, "desc": "Scavo, colpi, passi, creature, interfaccia."},
	{"id": "ambiente", "sec": "audio", "name": "Ambiente", "type": "slider", "min": 0.0, "max": 1.0, "step": 0.05, "fmt": "pct",
		"def": 0.7, "desc": "Il sottofondo di ogni strato: vento, gocce, grotte."},
	{"id": "musica_boss", "sec": "audio", "name": "Musica degli scontri", "type": "bool", "def": true,
		"desc": "Vicino a un Guardiano parte il suo brano. Spento: resta la musica di esplorazione."},
	# video
	{"id": "finestra", "sec": "video", "name": "Schermo", "type": "choice", "def": "finestra",
		"choices": [["finestra", "In una finestra"], ["intero", "Schermo intero"], ["senza_bordi", "Finestra senza bordi, a tutto schermo"]],
		"desc": "Come si apre il gioco sullo schermo."},
	{"id": "vsync", "sec": "video", "name": "Sincronia verticale", "type": "bool", "def": true,
		"desc": "Il gioco disegna al ritmo dello schermo: niente strappi nell'immagine."},
	{"id": "fps_max", "sec": "video", "name": "Fotogrammi al secondo, al massimo", "type": "choice", "def": 0,
		"choices": [[0, "Senza limite"], [30, "30"], [60, "60"], [120, "120"], [144, "144"], [240, "240"]],
		"desc": "Un tetto ai fotogrammi: consuma meno se il computer scalda."},
	{"id": "zoom", "sec": "video", "name": "Ingrandimento della visuale", "type": "choice", "def": 2.0,
		"choices": [[1.5, "Lontano (1,5×)"], [2.0, "Normale (2×)"], [2.5, "Vicino (2,5×)"], [3.0, "Molto vicino (3×)"]],
		"desc": "Quanto è grande il mondo sullo schermo. Lontano si vede più attorno."},
	{"id": "chiarore", "sec": "video", "name": "Chiarore del buio", "type": "choice", "def": 0.0,
		"choices": [[0.0, "Buio pieno (come è pensato)"], [0.04, "Appena visibile"], [0.08, "Poco visibile"], [0.14, "Visibile"]],
		"desc": "Dove la luce non arriva il gioco è nero. Per chi fatica a vedere, un filo di chiarore ovunque."},
	{"id": "tremolio", "sec": "video", "name": "Fiamma della torcia che tremola", "type": "bool", "def": true,
		"desc": "La luce della torcia in mano cambia un poco d'intensità, come una fiamma vera."},
	{"id": "particelle", "sec": "video", "name": "Polvere e scintille", "type": "bool", "def": true,
		"desc": "La polvere dello scavo, gli sbuffi e le scintille. Spente: più leggero."},
	{"id": "contatore_fps", "sec": "video", "name": "Mostra i fotogrammi al secondo", "type": "bool", "def": false,
		"desc": "Un numero piccolo in basso a sinistra."},
	# interfaccia
	{"id": "aiuto_tasti", "sec": "interfaccia", "name": "Aiuto dei tasti in alto", "type": "choice", "def": "auto",
		"choices": [["auto", "Nelle prime ore di gioco"], ["sempre", "Sempre"], ["mai", "Mai (si apre con F1)"]],
		"desc": "Le due righe che ricordano i comandi."},
	{"id": "obiettivi", "sec": "interfaccia", "name": "Obiettivi a sinistra", "type": "bool", "def": true,
		"desc": "I prossimi tre obiettivi sotto l'orologio."},
	{"id": "riga_albero", "sec": "interfaccia", "name": "Che cosa chiede l'Albero-Madre", "type": "bool", "def": true,
		"desc": "La riga con le offerte dello stadio in corso."},
	{"id": "filo", "sec": "interfaccia", "name": "Il filo da seguire", "type": "bool", "def": true,
		"desc": "In alto al centro: la prossima cosa da fare e una freccia verso dove farla."},
	{"id": "lista_spesa", "sec": "interfaccia", "name": "La lista della spesa", "type": "bool", "def": true,
		"desc": "A destra: le ricette segnate in Esamina e che cosa manca per farle."},
	{"id": "consigli", "sec": "interfaccia", "name": "Consigli alla prima volta", "type": "bool", "def": true,
		"desc": "Una scheda breve la prima volta che succede una cosa nuova (la notte, il buio, la Bisaccia piena…)."},
	{"id": "minimappa", "sec": "interfaccia", "name": "Minimappa", "type": "bool", "def": true,
		"desc": "Il ritaglio della mappa sotto Vita e Linfa (si mostra e si nasconde anche con N)."},
	{"id": "barre_creature", "sec": "interfaccia", "name": "Barre della Vita delle creature", "type": "choice", "def": "ferite",
		"choices": [["ferite", "Solo quando sono ferite"], ["sempre", "Sempre"], ["mai", "Mai"]],
		"desc": "La barretta sopra le creature (le antiche la mostrano sempre)."},
	{"id": "avvisi", "sec": "interfaccia", "name": "Durata degli avvisi", "type": "choice", "def": 1.5,
		"choices": [[1.0, "Breve"], [1.5, "Normale"], [3.0, "Lunga"], [5.0, "Molto lunga"]],
		"desc": "Quanto restano le scritte al centro («Raccolto…», «Obiettivo raggiunto…»)."},
	# gioco
	{"id": "scavo_intelligente", "sec": "gioco", "name": "Scavo intelligente", "type": "bool", "def": true,
		"desc": "Tenendo premuto il piccone su una cella vuota scavi da solo i blocchi a portata, prima i più vicini al mouse. Mai ciò che hai costruito, mai sotto i piedi, mai vicino ai liquidi. Con Maiusc all'inizio: solo lo stesso blocco."},
	{"id": "mostra_fili", "sec": "gioco", "name": "Mostra sempre i fili", "type": "bool", "def": false,
		"desc": "I fili dell'Impulso (Roadmap 19) si vedono sempre, non solo con la Pinza delle vene in mano."},
	{"id": "riponi_tasto", "sec": "gioco", "name": "Tasto «Riponi nelle casse»", "type": "bool", "def": true,
		"desc": "Il tasto Riponi (Q) mette ogni oggetto della Bisaccia (non la barra rapida) nelle casse vicine che lo contengono già o che raccolgono il suo tipo."},
	{"id": "ospiti", "sec": "gioco", "name": "Ospiti delle case", "type": "bool", "def": true,
		"desc": "Nelle stanze lasciate sole al buio arrivano i ragni; sui tetti gli uccelli fanno il nido. Nessuno rompe nulla."},
	{"id": "assedi", "sec": "gioco", "name": "Assedi alla base", "type": "bool", "def": true,
		"desc": "Una volta a stagione, di notte, i rosicchiatori attaccano la tua casa (solo le porte). Spento: niente assedi."},
	{"id": "pausa_bisaccia", "sec": "gioco", "name": "Pausa mentre crei", "type": "bool", "def": false,
		"desc": "Con la Bisaccia aperta (e il pannello Creare) il mondo si ferma: creature, tempo, crescita."},
	{"id": "pausa_pannelli", "sec": "gioco", "name": "Pausa con i pannelli grandi", "type": "bool", "def": true,
		"desc": "Mappa, Erbario, Enciclopedia, Semenzaio, Mandria, Albero-Madre, Bacheca, Innesti: il mondo si ferma."},
	{"id": "pausa_fuoco", "sec": "gioco", "name": "Pausa quando passi a un'altra finestra", "type": "bool", "def": true,
		"desc": "Se il gioco non è più in primo piano si ferma, e riparte quando ci torni."},
	{"id": "pile", "sec": "gioco", "name": "Grandezza delle pile", "type": "choice", "def": 1.0,
		"choices": [[0.25, "Piccole (un quarto)"], [0.5, "Ridotte (metà)"], [1.0, "Normali"], [4.0, "Grandi (×4)"],
			[10.0, "Molto grandi (×10)"], [100.0, "Enormi (×100)"], [-1.0, "Infinite"]],
		"desc": "Quanti oggetti uguali stanno in una casella (Bisaccia e casse). Vale per ciò che si impila: attrezzi, armi e armature restano uno per casella. Le pile già più grandi del nuovo limite restano come sono."},
	{"id": "autosalvataggio", "sec": "gioco", "name": "Salvataggio automatico", "type": "choice", "def": 300.0,
		"choices": [[60.0, "Ogni minuto"], [180.0, "Ogni 3 minuti"], [300.0, "Ogni 5 minuti"], [600.0, "Ogni 10 minuti"], [0.0, "Mai (solo uscendo)"]],
		"desc": "Il mondo e il personaggio si salvano da soli. Si salva sempre anche uscendo."},
	# suggerimenti
	{"id": "tip_attivi", "sec": "suggerimenti", "name": "Suggerimenti", "type": "bool", "def": true,
		"desc": "Le schede che compaiono con il mouse sopra oggetti, creature e interfaccia."},
	{"id": "tip_ritardo", "sec": "suggerimenti", "name": "Ritardo nell'interfaccia", "type": "slider", "min": 0.0, "max": 1.5,
		"step": 0.05, "fmt": "s", "def": 0.22, "desc": "Quanto tenere il mouse su una casella o un bottone prima della scheda."},
	{"id": "tip_mondo", "sec": "suggerimenti", "name": "Suggerimenti nel mondo", "type": "bool", "def": true,
		"desc": "Le schede di creature, stazioni, minerali, piante con il mouse fermo sopra."},
	{"id": "tip_ritardo_mondo", "sec": "suggerimenti", "name": "Ritardo nel mondo", "type": "slider", "min": 0.0, "max": 2.0,
		"step": 0.05, "fmt": "s", "def": 0.4, "desc": "Nel mondo il mouse passa sopra a tante cose: un attimo in più."},
	{"id": "tip_scala", "sec": "suggerimenti", "name": "Grandezza delle schede", "type": "choice", "def": 1.0,
		"choices": [[0.85, "Piccole"], [1.0, "Normali"], [1.15, "Grandi"], [1.3, "Molto grandi"]],
		"desc": "Testo e riquadri dei suggerimenti."},
	{"id": "tip_confronto", "sec": "suggerimenti", "name": "Confronto con ciò che hai", "type": "choice", "def": "maiusc",
		"choices": [["maiusc", "Tenendo Maiusc"], ["sempre", "Sempre"]],
		"desc": "Le armi e le armature confrontate con quelle che indossi o hai in mano."},
]


static func get_opt(id: String) -> Dictionary:
	for o in OPTIONS:
		if String(o["id"]) == id:
			return o
	return {}
