# TERRAWORLD a confronto con Terraria e Starbound

Ricerca del 29 set 2026, chiesta dall'utente. Scopo: sapere **dove siamo** rispetto ai due giochi più vicini al nostro,
per numeri e meccaniche, e raccogliere **le idee che loro hanno e noi no**, ripensate per il Giardino dei Semi.

- **Terraria**: versione 1.4.5.8 (la 1.4.5 «Bigger and Boulder» è del 27 gen 2026). Fonte: il wiki ufficiale
  https://terraria.wiki.gg (pagine citate in fondo).
- **Starbound**: versione 1.4.4 del 7 ago 2019, l'ultima con contenuti nuovi (la 1.4.5 del 2024 è solo il porting su
  Xbox). Fonte: il wiki ufficiale https://starbounder.org.
- **TerraWorld**: contato dai dati del gioco il 29 set 2026 (`tools/elenco.gd`, `src/data/`), compreso il lavoro in
  corso della Roadmap 16 (il cielo).
- I numeri con «circa» sono stime: i wiki non danno sempre un totale (ricette, accessori, blocchi, decorazioni).

---

## 1. I numeri a confronto

| | **Terraria 1.4.5** | **Starbound 1.4** | **TerraWorld (29 set 2026)** |
|---|---|---|---|
| Oggetti | circa 6.100-6.200 | circa 4.500-4.700 | **2.780** |
| Ricette | circa 3.000+ | non contate (150 di cucina) | **2.077** |
| Armi | 609 | generate da parti (oltre un milione), 80-150 uniche | forme × materiali × qualità × tratti × innesti, circa 560 di base + 151 unici |
| Set di armatura | 70 | 60 di razza + circa 12 | circa 65 pezzi per tipo, set dei metalli e delle vesti |
| Accessori | circa 300-450 | 27 potenziamenti dell'EPP | circa 290 + anelli, amuleti, gioielli (10 posti d'equipaggiamento) |
| Pozioni / cibi | circa 44 pozioni + 61 cibi | 150 ricette di cucina | circa 40 consumabili, poca cucina |
| Tipi di blocco / muro | 753 / 367 | circa 200-300 blocchi | 56 tessere + **243 costrutti** (27 materiali × 9 forme) |
| Mobili e decorazioni | 65 set, circa 1.300 pezzi | oltre 1.500 (stima) | **120 arredi** |
| Banchi per fabbricare | 35 | oltre 25, spesso in 3 gradi | circa 12 banchi (264 stazioni con totem, trappole, casse, meccanismi) |
| Nemici | 391 | generati da parti + 105 unici | **171 specie** con varianti di taglia, elemento, indole e grado |
| Boss | 18 fissi + 14 di evento | 7 della storia + 2 mini + Guardiani dei Vault | 7 Guardiani + 6 Custodi + 24 Signori + **Guardiani generati senza fine** |
| Eventi | 19 | pochi (incontri, taglie) | 3 eventi + 6 maree + assedi; 6 tempi atmosferici; 4 stagioni |
| Biomi | 7 grandi + 4 sotterranei + 4 Hardmode + 12 mini | 19 principali + 18-19 mini + 11-12 grotte | 16 di superficie + 9 sotterranei + 6 del cielo (in corso) |
| Mondi | uno per volta, 3 grandezze | pianeti quasi infiniti | **mondi infiniti progettati con i Semi** |
| Grandezza del mondo | da 4.200×1.200 a 8.400×2.400 | da 1.000×2.000 a 6.000×3.000 | 3.000×1.000 |
| Varietà dei mondi | 9 seed speciali + 37 segreti | 6 livelli di minaccia | **107 geni** combinabili, vigore senza tetto |
| Abitanti | 26 + 11 animali da città | oltre 60 tipi di inquilini | 9 abitanti con affetto e richieste |
| Animali da compagnia | 84 | 60 + 57 rari (catturati) | 6 compagni + la mandria (addomesticare, allevare) |
| Cavalcature / veicoli | 37 / carrelli | 5 veicoli + mech | cavalcature della mandria, 11 ali, rampino |
| Minerali | 21 in 13 fasce (due alternative per fascia) | 6 fasce | 8 metalli + **28 leghe** |
| Gemme / liquidi | 7 / 4 | — / **9** | 4 / 3 (acqua, Linfa, brace) |
| Modificatori | 83 prefissi, reforge | rarità, elementi | 25 tratti + qualità + innesti + tempra senza tetto |
| Effetti di stato | circa 400 | elementi | 6 elementi + 4 reazioni + 30 effetti speciali |
| Pesca | 59 pesci, missioni del pescatore | 48 pesci | circa 59 pesci in tutti i liquidi |
| Collezioni | Bestiary (546), carillon, trofei, reliquie | 7 album, 445 voci | Erbario, reliquie, trofei, unici in serie, Genario |
| Testi di storia | pochi | 121 libri | 25 pagine, lingua dei Seminatori (50 parole), tavolette, diario |
| Obiettivi | 137 | 51 | 107 |
| Musica | **104 brani** | **71 brani** + 31 strumenti | **2 brani** |
| Difficoltà | 4 del mondo + 4 del personaggio | una | nessuna modalità: sale il vigore |
| Giocatori | fino a 255, mod | multigiocatore, mod | 1 (rete rimandata) |

**In breve.** Per quantità Terraria è circa il doppio di noi e Starbound poco meno; tutti e due hanno molta più
musica. Noi siamo avanti nei **sistemi che si moltiplicano da soli** (mondi, equipaggiamento, boss) e nelle ragioni
per esplorare.

---

## 2. Solo nel nostro gioco

- **Progettare i mondi**: Semi con 107 geni, dominanza, innesto, mutazioni; ogni mondo ha una firma. Terraria dà un
  mondo, Starbound fa trovare pianeti: da noi si **progettano**.
- **Il motivo della partita**: l'Albero-Madre in 12 stadi con le sue richieste, 6 poteri, i Sigilli, la Bacheca
  senza fine, le richieste degli abitanti.
- **Boss da curare o sconfiggere**, con esiti diversi; Guardiani generati diversi in ogni mondo; Custodi e Signori da
  richiamare all'Altare e al Cerchio.
- **La materia viva**: materiali con proprietà, 28 leghe, forme × materiali, qualità, innesti, fasce, tempra.
- **Elementi con reazioni** (Vapore, Fiammata, Cristallo, Squarcio) e debolezze per ogni creatura.
- **Ecologia**: popolazioni, prede e predatori, nidi, migrazioni; creature che pensano, con astuzie e contromosse;
  maree con un capo; assedi una volta a stagione; studio delle creature con bonus per sempre.
- **Mandria con genetica**: allevamento, doti, manti, uova, recinti, cavalcature.
- **Le leggi dei mondi**: gravità, correnti, terra viva, tempo (giorni eterni, eclissi), stagioni, liquidi che scorrono.
- **Rigori delle terre estreme** (freddo, sete, calore, polvere) con ripari e rimedi. Starbound ha gli EPP, ma solo
  come zaini da indossare.
- **Il racconto come meccanica**: lingua da imparare, catene tra i mondi, luoghi scritti a mano, enigmi, la scelta sul
  Seme Nero che vale per tutti i mondi.
- **Segreti con contatore**, 151 unici in 15 serie con premio, leggende e Seme Primo, sfide dei Semi.
- **Costruire con proprietà**: isolamento, luce, bellezza; 9 stanze con comfort e un aiuto; riparo; progetti.
- **Totem di zona, farm componibili, trappole a gradi.**
- **Diario, Enciclopedia, suggerimenti ricchi, Erbario che dice cosa manca e dove cercarlo.**

## 3. Solo in Terraria

- Multigiocatore e mod.
- **Cablaggio**: fili di 4 colori, porte logiche, sensori, attuatori, teletrasporti; statue che fanno nascere creature.
- **Shimmer**: il liquido che scompone e trasforma gli oggetti e dà bonus permanenti.
- **Modalità**: Journey (duplicazione, comandi sul tempo), Expert e Master (borse del tesoro, reliquie, pet
  esclusivi), personaggio Hardcore.
- **L'Hardmode**: a metà partita il mondo cambia, arrivano minerali nuovi e biomi che si allargano.
- **Due alternative per ogni fascia** di minerale e due biomi malvagi: ogni mondo è diverso già dal primo.
- **Accessori fusi a catena** dal Tinkerer; 83 prefissi con il reforge.
- **Collezionismo estetico**: vestiti estetici sopra l'armatura, tinture, 104 brani con i carillon, 84 pet,
  37 cavalcature, carrelli su binari.
- **Invasioni a punteggio** (lune di zucca e di gelo), la difesa della torre (Old One's Army).
- **Pylon** legati alla felicità degli abitanti; missioni giornaliere del pescatore; seed segreti che capovolgono
  il gioco; eventi pacifici (festa, notte delle lanterne).
- Pendenze e mezzi blocchi (esclusi da noi per scelta dell'utente).

## 4. Solo in Starbound

- **Astronave come casa**, viaggio tra le stelle, incontri nello spazio, **equipaggio** con ruoli che danno bonus.
- **7 razze giocabili** con armature, navi, mobili, villaggi, dungeon e libri propri.
- **Mech componibili** e **veicoli** (hoverbike, barca).
- **Colonie a etichette**: l'inquilino dipende dai mobili della stanza, paga l'affitto, dà missioni generate senza
  fine e può diventare equipaggio.
- **Armi con l'abilità del tasto destro** legata al tipo d'arma.
- **Tecniche** (scatto, sfera che rotola, salto multiplo) come sistema a sé.
- **Album di collezione**: insetti col retino, fossili con un minigioco di scavo e i musei, action figure.
- **Cucina ricca** (150 ricette) e animali da fattoria.
- **Strumenti musicali suonabili**, anche in gruppo.
- **9 liquidi** (veleno, olio, melma, acqua curativa, latte di cocco…).
- **Taglie** con piccoli dungeon generati.
- **Pittura dei blocchi** e cablaggio logico.

---

## 5. Le idee: ciò che loro hanno e noi no, ripensato per il Giardino dei Semi

Ogni idea passa dalla filosofia del gioco (CLAUDE.md). Deve rispondere ad almeno una di queste domande: *cosa cerco,
perché mi serve, cosa trovo che non mi aspettavo*. E deve **moltiplicare** i sistemi che ci sono, non sommarsi.
Per ognuna: da dove viene, come sarebbe da noi, cosa moltiplica, il peso (S piccola, M media, L grande) e i vincoli.

### A. Il mondo e la progressione

**A1. Due metalli per fascia, scelti dal Seme** (da Terraria: rame o stagno, cobalto o palladio…) — S-M
Ogni fascia ha due metalli gemelli con proprietà diverse: per esempio la radicite oppure una «cuprite di radice» più
duttile ma meno dura. Il gene di minerali del Seme sceglie quale nasce in un mondo. Per avere tutte e due le leghe
bisogna **progettare due Semi**, oppure commerciare tra i mondi.
*Moltiplica*: geni, leghe (il doppio delle combinazioni), firma dei mondi, rete dei portali, Bacheca.
*Vincolo*: le ricette chiedono «un metallo di fascia 2», non un nome fisso (ci sono già i gruppi di materiali).

**A2. La Seconda Fioritura** (dall'Hardmode di Terraria) — L
Quando l'Albero-Madre si sveglia (o quando si guarisce il Seme Nero), **tutti i mondi già visitati cambiano**. Nel
Fondo compaiono vene nuove, la Linfa sale in superficie in strisce vive che si allargano come l'Avvizzimento ma al
contrario, i Guardiani curati si risvegliano più forti. Tornare nei mondi vecchi ha di nuovo un senso.
*Moltiplica*: mondi già fatti (tornano utili), Avvizzimento (ora c'è la sua forza opposta), rete delle Aiuole, diario.
*Vincolo*: non deve cancellare ciò che il giocatore ha costruito.

**A3. La guerra dei biomi** (da Corruzione, Cremisi e Consacrato di Terraria) — M
Oggi l'Avvizzimento si allarga e si purifica. Si può aggiungere un **innaffiatoio da terraformazione** (l'«Aspersorio
di Linfa», con cariche di biomi): trasforma a raggio le tessere di un bioma in un altro. Serve a **portarsi un bioma
in casa**, per esempio la brina accanto al Giardino per i suoi pesci e le sue creature.
*Moltiplica*: biomi (diventano materiale da costruzione), pesca, ecologia, stanze, farm.
*Vincolo*: le cariche vengono dai biomi stessi, così bisogna esserci stati.

**A4. I Semi strani** (dai seed segreti di Terraria) — S ciascuno
Parole-seme segrete da scrivere nel menu, oppure scoperte nelle tavolette dei Seminatori, che cambiano le regole:
mondo capovolto, tutto sottosopra, gravità doppia, sempre notte, creature tutte antiche. Ogni parola trovata va nel
Taccuino.
*Moltiplica*: lingua dei Seminatori (le parole sono indizi), segreti, sfide, geni (molte regole esistono già come geni).

**A5. Le cacce della Bacheca** (dalle taglie di Starbound) — S
La Bacheca chiede **una creatura antica con un nome**, generata con i suoi tratti, che vive in un mondo preciso. Un
indizio dice dove, a grandi linee.
*Moltiplica*: creature antiche e ancestrali, portali, Bacheca, Erbario.

### B. Le creature e il combattimento

**B1. L'abilità del tasto destro per ogni forma** (da Starbound) — M-L
Ogni forma d'arma ha un secondo colpo: lo spadone fa un fendente circolare, la lancia un affondo, l'arco una raffica,
il bastone uno scudo di Linfa. Il **materiale** ne cambia l'effetto (la brace brucia, il cristallo congela) e gli
**innesti** lo modificano.
*Moltiplica*: 16 forme × 36 materiali × elementi × innesti, cioè centinaia di mosse nuove senza scriverle una per una.
*Vincolo*: oggi il clic destro serve a toccare le cose; l'abilità andrebbe su un altro tasto o su Maiusc+clic.

**B2. Gli Assedi al Cuore** (dall'Old One's Army di Terraria) — M
Un evento da difendere: le creature puntano al Cuore del mondo, o a un'Aiuola, e il giocatore ha i totem-sentinella
(i totem di zona che attaccano) e le trappole. Si gioca a ondate, con un punteggio e i premi.
*Moltiplica*: totem, trappole, farm, Cuore, maree.

**B3. Lune a punteggio** (dalle lune di zucca e di gelo di Terraria) — S-M
Una notte speciale **per ogni stagione**, con ondate crescenti di creature di quella stagione, un punteggio e i premi a
soglie.
*Moltiplica*: stagioni, maree, unici di stagione, obiettivi.

**B4. Le difficoltà** (da Expert/Master e Hardcore di Terraria) — S-M
Due scelte separate:
- **Per il mondo**, come gene del Seme: «Seme selvatico» (più vigore, un baccello del Guardiano con un oggetto in più),
  «Seme ostile» (creature più furbe).
- **Per il personaggio**, alla creazione: «Radice fragile», che appassendo perde la Bisaccia per sempre.
*Moltiplica*: geni, Guardiani (il baccello dà un premio in più), sfide.

**B5. La Modalità del Giardiniere** (dal Journey mode di Terraria) — M
Per chi vuole costruire: ogni oggetto «studiato» (tot pezzi consegnati all'Albero) si può duplicare; si comandano il
tempo e la stagione. Si sceglie alla creazione del personaggio.
*Moltiplica*: costruzione, arredi, progetti. *Vincolo*: personaggi separati, niente scambi con quelli normali.

### C. L'equipaggiamento

**C1. Accessori intrecciati** (dal Tinkerer di Terraria) — M
Al Telaio si **intrecciano** due accessori in uno solo, che somma gli effetti con un piccolo sconto; l'intreccio si
può ripetere a catena, come per gli Stivali delle Terre Spaziali. I posti d'equipaggiamento diventano una scelta
strategica: l'intreccio libera un posto.
*Moltiplica*: 290 accessori, effetti speciali, unici, set. *Vincolo*: un tetto al numero di intrecci.

**C2. Le vesti estetiche e le tinture dell'equipaggiamento** (Terraria e Starbound) — M
Posti estetici sopra l'armatura e tinture per ogni pezzo.
*Moltiplica*: arredi, tinture (ci sono già per i costrutti), trofei.
*Vincolo*: serve prima l'armatura sugli sprite del Germogliato (voce 117 della Roadmap 13).

**C3. Il Crogiolo del ritorno** (dallo Shimmer di Terraria) — M
Un **quarto liquido**, la Linfa Antica sciolta, che nasce solo in un bioma raro o con un gene. Un oggetto immerso torna
agli ingredienti (recupero dei materiali), oppure si trasforma nel suo «gemello», oppure dà un bonus una tantum (la
prima volta per oggetto). Il Germogliato che ci nuota attraversa i blocchi per qualche secondo.
*Moltiplica*: fabbricazione, liquidi, pesca (pesci del crogiolo), geni, segreti.

**C4. Uncini per materiale** (i 30 e più rampini di Terraria) — S
L'uncino come **forma** d'attrezzo × materiale: portata, velocità e numero di ganci crescono con il materiale, e le
leghe aggiungono un effetto.
*Moltiplica*: forme, materiali, movimento, cielo.

### D. La casa, gli abitanti, la costruzione

**D1. Gli ospiti delle stanze** (dalle colonie di Starbound) — L
Oltre ai 9 abitanti fissi, ogni stanza può chiamare **un ospite generato**, secondo gli arredi, i materiali e il
bioma. Per esempio una stanza di brina con arredi d'ambra chiama un «viandante delle nevi mercante di gemme». L'ospite
paga un piccolo affitto in Lumini o in materiali e dà **missioni generate**: portami, caccia, esplora quel mondo.
*Moltiplica*: stanze, arredi (diventano ingredienti di una ricetta), Bacheca, portali, affetto.
*Vincolo*: nomi e mestieri generati da `NamesData` e da una tabella di mestieri.

**D2. L'equipaggio del Giardino** (da Starbound) — M
Gli abitanti con l'affetto al massimo possono **seguire il Germogliato** nei mondi (uno o due alla volta). Ognuno ha
un ruolo che dà un bonus: il Forgiatore ripara, l'Erborista cura, il Cartografo segna i luoghi sulla mappa.
*Moltiplica*: abitanti, affetto, alleati, esplorazione.

**D3. Le Radici nervose: il cablaggio** (Terraria e Starbound) — L
Fili di radice tesi col Martello, che portano un segnale. Ci sono:
- **sensori**: creatura vicina, luce, orario, Linfa, pioggia, stagione;
- **porte logiche** (E, O, NON, pari) disegnate come nodi di radice;
- **attuatori**: blocchi che si ritirano nel muro;
- **teletrasporti** tra due Radici viandanti;
- porte, lampade, trappole e totem collegabili.
*Moltiplica*: trappole, farm, enigmi dei Seminatori (potrebbero usare gli stessi pezzi), costruzione, assedi.

**D4. I calchi delle creature** (dalle statue di Terraria) — M
Con un trofeo e della pietra si scolpisce un **calco**. Collegato a un filo di radice, fa nascere quella creatura
senza bottino raro, con un tetto per zona come le farm di oggi.
*Moltiplica*: trofei, farm, studio delle creature, cablaggio.

**D5. Carrelli e binari di radice** (da Terraria) — M
Binari che si posano come passerelle e una «slitta di baccello» che corre veloce, anche in verticale nei pozzi.
*Moltiplica*: movimento, costruzione, farm (i nastri di oggi potrebbero incrociarsi coi binari), miniere.

### E. Le collezioni e le attività laterali

**E1. La cucina del Paiolo** (da Starbound) — M
Una cucina **combinatoria**, come i materiali: ogni ingrediente (raccolto, pesce, carne, frutto, insetto) ha delle
proprietà (dolce, amaro, caldo, fresco, Linfa). Il piatto nasce dalla combinazione, con un effetto a tempo e un nome
generato («Zuppa calda di pesce lume»). Le ricette si scoprono e vanno nel libro di cucina dell'Erbario. Cura i
rigori: il caldo contro il freddo, i piatti freschi nel deserto.
*Moltiplica*: orto, pesca, mandria (latte, uova), caccia, rigori, stagioni.

**E2. Il retino e il lucciolario** (dagli insetti di Starbound) — S-M
Piccole creature da catturare col retino, diverse per bioma, stagione, ora e tempo: lucciole, farfalle, falene di
brace, coleotteri di cristallo. Servono come esche per la pesca, per le tinture, come luci da mettere in un barattolo,
per l'album.
*Moltiplica*: ecologia, pesca, tinture, stagioni, Erbario.

**E3. Le ossa dei mondi antichi** (dai fossili di Starbound) — M
Nel terreno degli strati profondi ci sono rocce con dentro un fossile. Si scavano con un minigioco breve (pennello e
martelletto, senza rompere le ossa) e si montano nel **Museo del Giardino**. Uno scheletro completo dà un bonus o
svela una pagina sui Seminatori.
*Moltiplica*: strati, segreti, lingua dei Seminatori, stanze (il museo come tipo di stanza).

**E4. La Sala delle raccolte** (album di Starbound, Bestiary di Terraria) — S
Un posto nel Giardino dove si vedono tutte le collezioni: trofei, reliquie, insetti, fossili, pesci, unici. Ogni
album completo dà un premio per sempre, come le serie degli unici.
*Moltiplica*: tutte le collezioni che ci sono già, oggi sparse.

**E5. Gli strumenti di canna** (da Starbound) — M
Flauti e tamburi di radice suonabili a note. Si usano davvero: i **cristalli d'eco** degli enigmi rispondono a una
melodia, il potere «Canto delle radici» si amplifica, alcune creature si calmano o si avvicinano, e c'è una canzone dei
Seminatori da ricostruire dalle tavolette.
*Moltiplica*: enigmi, poteri, mandria, lingua.

**E6. Le missioni del pescatore** (dall'Angler di Terraria) — S
Un abitante nuovo, il «Pescatore di Linfa», che ogni giorno chiede un pesce raro diverso. I premi sono esche, canne
uniche e mobili da pesca.
*Moltiplica*: pesca (oggi è un'attività senza richieste), abitanti, Bacheca.

**E7. Eventi pacifici** (dalla festa e dalla notte delle lanterne di Terraria) — S
Notti calme con un bonus: la «Notte delle lanterne», in cui i baccelli volano in cielo e tornano come regali; la
«Festa del raccolto», con gli abitanti che si radunano e affetto doppio.
*Moltiplica*: stagioni, abitanti, orto.

### F. Il viaggio e il movimento

**F1. Veicoli** (dalla barca e dalle hoverbike di Starbound) — M
Una **barca di baccello** per i mari del gene Sommerso e i laghi del sottosuolo, e una **slitta a vela** per le
distese col vento (la spinge `Player.wind`).
*Moltiplica*: liquidi, vento, geni dei mondi d'acqua, pesca (si pesca dalla barca).

**F2. Il Seme rotolante** (dalla sfera delle tecniche di Starbound) — S-M
Un potere, o un accessorio, che chiude il Germogliato in un seme che rotola nei cunicoli alti una tessera.
*Moltiplica*: segreti (passaggi bassi), enigmi, poteri.

**F3. Le Isole del Vuoto** (dagli incontri nello spazio di Starbound) — M
Viaggiando tra le Aiuole, a volte il portale si ferma su un frammento di mondo morto che galleggia nel Vuoto: un
piccolo luogo generato con uno scrigno, una creatura del Vuoto e una pagina.
*Moltiplica*: portali, Vuoto, Seme Nero, segreti.

### G. Il suono e l'identità

**G1. La musica dei mondi** (104 brani per Terraria, 71 per Starbound) — S per brano, **la mancanza più grande**
Il sistema `Musica` c'è già. Mancano i brani:
- uno per strato (5);
- uno per famiglia di biomi (temperati, estremi, rari, cielo);
- notte, eventi e maree;
- uno per Guardiano e uno per i Signori;
- il Giardino, e il Giardino sveglio.
Li farebbe l'utente con Gemini, come i due di oggi. Ci sono anche i **carillon di conchiglia**: si trovano o si
fabbricano, registrano un brano e lo suonano in casa.
*Moltiplica*: stanze (bellezza e comfort), collezioni, biomi, eventi.

**G2. I Popoli dei mondi** (dalle razze di Starbound) — L
Non razze giocabili: **popoli generati** che vivono in alcuni mondi, secondo i geni. Hanno villaggi con la loro
estetica (materiali e arredi del bioma), un mercante, una lingua con parole generate da imparare come quella dei
Seminatori, e missioni. Un gene «Popolato» li fa comparire.
*Moltiplica*: geni, firma, lingua, arredi, commercio, abitanti (un popolo può mandare un ospite nel Giardino).

**G3. Villaggi e dungeon di popolo** (da Starbound) — M, dopo G2
Villaggi pacifici e fortezze ostili, generati con le stesse passate dei luoghi scritti (`PassLuoghi`), con pezzi dei
mobili del popolo.

### H. Rete e mod

**H1. Multigiocatore** — L, rimandato per scelta dell'utente (voce 6). Il piano c'è in `MIGLIORIE.md` (punto 9).
**H2. Le mod come pacchetti di dati** — M
Il gioco è già scritto a dati (i biomi sono file). Una cartella `pacchetti/` fuori dal gioco, letta all'avvio, per i
biomi, le creature e gli oggetti degli amici, senza toccare il codice.

---

## 6. Da non fare (o già scelto)

- **Pendenze e mezzi blocchi**: esclusi dall'utente (29 set 2026).
- **Mech a gravità zero e astronave**: il nostro «spazio» è il Vuoto tra i mondi, e la casa è il Giardino, non una
  nave. Idee come F3 e D2 ne prendono il buono senza cambiare universo.
- **Oggetti presi da altri giochi**: fuori tema.
- **Reforge a caso**: c'è già il rinnovo dei tratti al Maglio, con gli innesti che danno controllo. Basta la C1.
- **Felicità degli abitanti con i vicini e i prezzi**: esiste già (gusti, felicità, affetto).
- **Aggiungere quantità una cosa per volta**: per raggiungere i loro numeri si usa la regola del gioco, «un generatore
  in più moltiplica». Una forma, un materiale o un gene nuovo valgono centinaia di oggetti.

---

## 7. La mia proposta d'ordine

Il criterio è quanto rende rispetto a quanto costa, e quanti sistemi moltiplica.

1. **G1 La musica dei mondi** (S a brano): è la mancanza più visibile, costa poco e il sistema esiste già.
2. **E1 La cucina del Paiolo** (M): moltiplica orto, pesca, mandria, caccia e rigori in un colpo solo.
3. **E2 + E4 Il retino e la Sala delle raccolte** (S-M): danno un «cosa cerco» leggero e continuo, e riuniscono le
   collezioni sparse.
4. **A1 Due metalli per fascia** (S-M): mondi più diversi dal primo, leghe raddoppiate, un motivo per progettare più Semi.
5. **C1 Accessori intrecciati** (M): profondità di equipaggiamento con i dati che ci sono.
6. **B1 L'abilità del tasto destro** (M-L): combattimento più ricco, moltiplicato dalle forme.
7. **D1 Gli ospiti delle stanze** (L): il Giardino si riempie e le missioni non finiscono mai.
8. **D3 Le Radici nervose** (L): apre la strada a D4, a B2 e a enigmi più ricchi.
9. **C3 Il Crogiolo del ritorno** (M): recupero dei materiali e un segreto da trovare.
10. **A2 La Seconda Fioritura** (L): il grande giro di metà partita, da fare quando il contenuto regge.

Poi, a piacere: E3, E5, E6, E7, F1, F2, F3, B2, B3, B4, B5, C2 (dopo l'armatura sugli sprite), G2 e G3 (il progetto
più grande: popoli e villaggi).

---

## Fonti

**Terraria** (https://terraria.wiki.gg):
- versioni: `/wiki/1.4.5.0`, `/wiki/1.4.5.7`, `/wiki/Terraria`
- equipaggiamento: `/wiki/Weapons`, `/wiki/Armor`, `/wiki/Accessories`, `/wiki/Potions`, `/wiki/Modifiers`
- mondo e costruzione: `/wiki/Tile_IDs`, `/wiki/Wall_IDs`, `/wiki/Furniture_sets`, `/wiki/Crafting_stations`,
  `/wiki/Biomes`, `/wiki/World_size`, `/wiki/Ores`, `/wiki/Shimmer`
- nemici, boss, eventi: `/wiki/Enemies`, `/wiki/Bosses`, `/wiki/Events`
- abitanti e compagni: `/wiki/NPCs`, `/wiki/NPC_happiness`, `/wiki/Pets`, `/wiki/Mounts`, `/wiki/Wings`, `/wiki/Pylons`
- il resto: `/wiki/Achievements`, `/wiki/Special_world_seeds`, `/wiki/Secret_world_seeds`, `/wiki/Music`,
  `/wiki/Angler/Quests`, `/wiki/Bestiary`, `/wiki/Buff_IDs`
- conteggio degli oggetti: https://steamcommunity.com/sharedfiles/filedetails/?id=3655391218

**Starbound** (https://starbounder.org):
- versioni: `/Version_history`, `/Version_1.4.5`
- oggetti ed equipaggiamento: `/Items`, `/Weapons`, `/Armor`, `/Augments`, `/Food`, `/Crafting_Stations`
- mondo: `/Biomes`, `/Planet`, `/Dungeons`, `/Ores`, `/Liquids`
- creature e storia: `/Monsters`, `/Bosses`, `/Quests`, `/Tenants`
- il resto: `/Vehicles`, `/Mech`, `/Music_Tracks`, `/Codex`, `/Instruments`, `/Collections`, `/Techs`
- altre fonti: https://playstarbound.com/xbox-update-1-4-5-2/, https://en.wikipedia.org/wiki/Starbound,
  https://steamcommunity.com/stats/211820/achievements, https://commands.gg/starbound/items
