class_name EncyStoryData
## Enciclopedia, quarta parte (Roadmap 9 «Il mistero dei Seminatori»): la lingua, le catene, i luoghi, gli enigmi,
## il Seme Nero. Stesso formato di `EncyGuideData`; ogni voce della Roadmap 9 aggiunge qui il suo capitolo.

const CHAPTERS := [
	{"id": "lingua", "group": "Il mistero dei Seminatori", "name": "La lingua dei Seminatori", "text":
"""I Seminatori scrivevano in una lingua loro, e nessuno te la insegna: si [b]decifra[/b]. Nelle rovine (e due vicino alla partenza di ogni mondo) ci sono le [b]stele[/b]: clic destro per leggerle. Tutto ciò che sai sta nel [b]Quaderno delle parole[/b] ({k_quaderno}).
[b]I tre stati di una parola[/b]
• [color=#8aa09a]Vista[/color]: l'hai letta su una stele, sai com'è scritta, non che cosa vuol dire.
• [color=#e0b060]Ipotesi[/color]: l'hai vista in abbastanza frasi diverse (due; tre per le lingue più alte) da farti un'idea: nel Quaderno ha [b]tre significati possibili[/b]. Guarda le frasi in cui compare (il Quaderno le mostra, tradotte per quello che sai) e scegli: giusto, diventa certa; sbagliato, quel significato è scartato e per riprovare devi ritrovarla in una frase nuova. Scartati due, resta quello giusto.
• [color=#ffe8b0]Certa[/color]: la sai, in tutti i mondi. Solo le parole certe si leggono in italiano.
[b]Altri modi di esserne certi[/b]
• Una stele che [b]indica un luogo[/b] («sigillo di brace dorme sotto, verso l'alba, lontano»): quando ogni sua parola è almeno un'ipotesi il luogo si segna «forse» sulla mappa; [b]arrivandoci[/b], le sue parole diventano certe.
• Gli [url=cap:scrigni_parola]scrigni a parola[/url]: aprirli conferma la parola mancante.
• Le [b]tavolette dei Seminatori[/b] (negli scrigni, dal Cartografo) confermano due parole che hai già visto.
• Lo Stilo dei Seminatori, una [url=cap:ricette_scritte]ricetta scritta[/url].
[b]Tre lingue[/b]: la lingua comune ({n_comune} parole, ovunque), la lingua antica ({n_antica}, nei mondi di vigore 3 o più e negli osservatori del cielo) e la lingua del Seme Nero ({n_nera}, nel suo mondo e sui leggii della sua via). Ne sai con certezza {parole_note} su {n_parole}.
[b]A che cosa servono[/b]: segnano i luoghi sulla mappa, aprono scrigni e porte, si [url=cap:incisioni]incidono[/url] sulle armi, svelano [url=cap:ricette_scritte]ricette[/url] e, nella lingua nera, la verità sul Seme.
Il [url=cat:glossario]glossario[/url] raccoglie le parole certe."""},
	{"id": "scrigni_parola", "group": "Il mistero dei Seminatori", "name": "Gli scrigni a parola", "text":
"""In un terzo delle rovine lo scrigno ha un sigillo d'ambra: sul coperchio è incisa una frase di una stele di [b]quel mondo[/b], con una parola mancante. Clic destro apre la [b]ruota dei glifi[/b]: ti dice che tipo di parola manca (una cosa, un'azione, un luogo, una quantità) e ti fa scegliere tra le parole di quel tipo che hai visto.
Giusta: lo scrigno si apre, dentro c'è più del solito (e una tavoletta), e la parola diventa certa. Sbagliata: il sigillo si richiude per quarantacinque secondi.
Per indovinare: leggi le altre stele del mondo (la parola mancante compare in almeno due) e ragiona sulla frase."""},
	{"id": "incisioni", "group": "Il mistero dei Seminatori", "name": "Le incisioni", "text":
"""Al [b]Maglio dei Seminatori[/b], con un'arma, un attrezzo, un'armatura o un accessorio in mano, tra le Lavorazioni compaiono le [b]incisioni[/b]: una parola certa della lingua incisa sull'oggetto dà un effetto in più che [b]non prende un posto d'innesto[/b]. Una sola incisione per oggetto (una nuova prende il posto della vecchia).
Più alta la lingua, più forte l'incisione: «brace» +8% danno, «fuoco» (antica) +14%, «divora» (nera) +22%. Il Quaderno dice che cosa incide ogni parola.
{cat_incisioni}"""},
	{"id": "ricette_scritte", "group": "Il mistero dei Seminatori", "name": "Le ricette scritte", "text":
"""Alcune ricette i Seminatori le hanno scritte nella loro lingua: [b]compaiono[/b] (e si possono fare) solo quando tutte le loro parole sono certe. Il Quaderno conta quelle svelate e, per ogni parola, dice se è in una ricetta ancora nascosta.
Tra queste: la [b]Bussola delle stele[/b] (segna sulla mappa le stele non lette), gli [b]Occhiali del decifratore[/b] (un'ipotesi con una frase in meno), lo [b]Stilo dei Seminatori[/b] (conferma un'ipotesi), e oggetti forti per chi sa le lingue alte."""},
	{"id": "catene", "group": "Il mistero dei Seminatori", "name": "Le catene di ricerca", "text":
"""Una catena è una ricerca tra più mondi. Ogni tappa dice [b]di che geni deve essere fatto un mondo[/b]: quando pianti un Seme con quei geni, il mondo che nasce ha una [b]cripta dei Seminatori[/b], segnata sulla mappa appena entri. Si raggiunge scavando; sul suo [b]leggio[/b] (clic destro) ci sono un pezzo di storia, il premio e l'indizio della tappa dopo.
• [b]La via del Seme Nero[/b]: la catena lunga, scritta dai Seminatori, cinque tappe in cinque mondi diversi. Comincia dopo il primo viaggio.
• Le [b]catene brevi[/b]: nascono dai geni che hai già visto, due alla volta, e non finiscono mai. Premi: Semi con geni rari, Linfa antica, tavolette, Polvere iridata, Lumini.
Le catene aperte sono nel [b]Taccuino[/b], la terza scheda del [url=cap:semenzaio]Semenzaio[/url] ({k_semenzaio}): per ogni tappa i geni che servono e se li conosci già. La scheda di un Seme (mouse sopra) dice se porta a una cripta.
Per costruire il Seme giusto: [url=cap:innesto]l'innesto[/url], con le Fiale dei geni imparati."""},
	{"id": "luoghi", "group": "Il mistero dei Seminatori", "name": "I luoghi dei Seminatori", "text":
"""Oltre alle rovine, i Seminatori costruirono [b]luoghi[/b] speciali, uno per ogni loro arte. Ognuno si trova solo nei mondi con i [url=cap:geni]geni[/url] giusti, nel suo strato: trovarne uno è un evento (una scritta, il segno sulla mappa). Dentro: un [b]leggio[/b] con un pezzo della loro storia, uno [b]scrigno[/b] ricco con un [b]oggetto unico[/b] del luogo, tavolette e Linfa antica. La stanza del tesoro è chiusa da una [b]porta dei Seminatori[/b], che si apre risolvendo l'[url=cap:enigmi]enigma[/url] del luogo.
Anche le stele possono indicarli («pietra seminatori veglia…»).
{cat_luoghi}"""},
	{"id": "enigmi", "group": "Il mistero dei Seminatori", "name": "Enigmi e meccanismi", "text":
"""La stanza del tesoro di ogni [url=cap:luoghi]luogo[/url] è chiusa da una [b]porta dei Seminatori[/b]: il piccone non la scalfisce, si apre risolvendo l'enigma del luogo. La scheda della porta (mouse sopra) dice che cosa chiede.
• [b]Bracieri[/b]: accendili tutti, clic destro con una torcia nella Bisaccia (la consuma).
• [b]Leve[/b]: mettile come dice il leggio del luogo, scritto nella [url=cap:lingua]lingua dei Seminatori[/url] (su e giù: impara quelle due parole).
• [b]Piastre[/b]: salici sopra tutte entro pochi secondi, prima che si rialzino.
• [b]Cristalli d'eco[/b]: ognuno risuona con un [url=cap:elementi]elemento[/url]; clic destro con un'arma di quell'elemento in mano.
• [b]Glifi[/b]: la porta porta una frase; si apre quando ne conosci tutte le parole (clic destro sulla porta).
• [b]Chiave[/b]: la Chiave dei Seminatori è in uno scrigno delle rovine dello stesso mondo."""},
	{"id": "seme_nero", "group": "Il mistero dei Seminatori", "name": "Il Seme Nero", "text":
"""L'Avvizzimento non è nato nei mondi: è caduto dal Vuoto, dentro un [b]seme nero[/b] che i Seminatori accolsero senza sapere che cosa fosse. Le stele, i luoghi e soprattutto [url=cap:catene]la via del Seme Nero[/url] raccontano come andò.
L'ultima tappa della catena ti dà il [b]Seme Nero[/b]. Piantato in un'[url=cap:portali]Aiuola[/url], apre il mondo [b]dove cadde[/b]: Avvizzimento ovunque, roccia malata attorno al Cuore, e nella cupola non un Guardiano come gli altri ma [b]l'Avvizzitore[/b], il seme stesso cresciuto (debole alla luce e alla Linfa).
Come ogni [url=cap:guardiani]Guardiano[/url] si può [b]sconfiggere[/b] o [b]curare[/b] (Rugiada di Linfa sui quattro nodi), e la scelta vale per [b]tutti i mondi[/b]:
• [b]spezzato[/b]: l'Avvizzimento smette di allargarsi ovunque; lascia le Schegge del Seme Nero (amuleto della forza, al Maglio);
• [b]curato[/b]: l'Avvizzimento si ritira un poco alla volta in tutti i mondi; lascia la Linfa del Seme guarito (amuleto della Vita e della Linfa).
Non è la fine: dopo il Seme Nero comincia il fine gioco."""},
]
