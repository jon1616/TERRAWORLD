# Il piano «La vastità» (Roadmap 38-51)

Scritto il 6 ottobre 2026 su richiesta dell'utente: «una lunga e dettagliata roadmap che indirizzi il nostro gioco verso
la profondità di Terraria. Getta le basi solide per avere, in futuro, una quantità di oggetti di qualsiasi tipo
paragonabile se non superiore a Terraria con le 2 mod … progressione, oggetti, comportamenti, ritrovamenti unici».

Il piano nasce da due misure:
- **I dati reali di Terraria + Calamity + Thorium** (cartella `TERRARIA MOD/dati/grezzi/tutte`, solo le tre mod di
  gioco).
- **Gli stessi conti fatti su TERRAWORLD** (`tools/confronto.gd` → `prove/confronto.json`).

Il confronto completo è nel rapporto «TERRAWORLD contro Terraria» (artefatto del 6 ott 2026). Qui sotto: che cosa
abbiamo imparato, lo spirito del progetto, i numeri da raggiungere, le fondamenta e quattordici Roadmap con le loro
voci.

---

> **Scelta dell'utente (6 ott 2026): niente estetica pura.** «La parte dell'estetica, sia indumenti, che mobili puramente
> estetici, senza alcuna funzione non li voglio.» Dal piano sono tolte vanità, abiti, maschere, tinture per gli abiti,
> carillon, quadri e serie di arredi decorativi: **ogni oggetto nuovo ha una funzione** (un effetto, un uso, un bonus di
> stanza, un ingrediente). E: «calibrare tutti i numeri, dalle armi, oggetti, mostri, boss»: ogni Roadmap si chiude con
> la calibrazione misurata (`tools/percorso.gd`, `tools/curva.gd`, `tools/armi.gd`, `tools/boss.gd`, `tools/vastita.gd`).

## 1. Che cosa dicono i dati

### 1.1 Dove siamo

| Che cosa | Terraria + Calamity + Thorium | TERRAWORLD (6 ott 2026) |
|---|---:|---:|
| Oggetti | 11.005 | 3.635 |
| Armi | 2.008 | 647 |
| Armi con un comportamento tutto loro | 1.607 (80%) | 41 (6%) |
| Comportamenti d'arma diversi | 1.650 | 59 |
| Armi «gemelle» (stessi numeri e gesto) | 65 (3%) | 185 (29%) |
| Accessori (effetti diversi) | 883 (676) | 466 (272) |
| Effetti a tempo e stati | 404 | ~140 |
| Pezzi d'armatura | 585 | 420 |
| Nemici comuni (specie) | 973 | 175 (+ varianti) |
| Comportamenti dei nemici | 88 di base + centinaia scritti a mano | 35 (57 combinazioni) |
| Boss | 90 | 49 |
| Biomi del bestiario | 71 (mediana 8 nemici l'uno) | 31 tra superficie, sottosuolo e cielo |
| Ricette (stazioni) | 7.849 (49) | 2.609 (12) |
| Catena di fabbricazione più lunga | 9 passaggi | 3 |
| Danno delle armi, inizio → fine | ×38 in 23 fasi | ×4,8 in 6 metalli |
| Vita dei boss, primo → ultimo | ×500 | ×6,5 |
| Durata di uno scontro con un boss | da 1 a 15-18 minuti | sempre 1-2 minuti |
| Voci nei negozi | 1.811 | 130 + 21 servizi |

### 1.2 Come è fatta la vastità di Terraria (ciò che i numeri lasciano vedere)

1. **Ogni boss è un tesoro.** In media un boss lascia **20 oggetti diversi**: 7 armi, 2-3 accessori, più materiali,
   vanità, trofeo, reliquia, animaletto, maschera, carillon. Batterlo di nuovo ha senso, perché il bottino è un tiro
   da una tabella grande.
2. **La progressione è una spina di boss**, con alcune soglie che cambiano il mondo:
   - prima del Muro di carne arrivano circa 4.600 oggetti (in gran parte blocchi e arredi);
   - **dopo il Muro**, in una fase sola, ne arrivano **1.166** (243 armi, 181 accessori), e il mondo cambia: minerali
     nuovi, biomi che si allargano, nemici nuovi ovunque;
   - poi Plantera, Golem, Cultista e Signore della Luna; con Calamity proseguono altre 5 fasi.
3. **Le armi si distribuiscono su tutte le fasi e su 8 classi.** Ogni blocco di fasi ha 50-180 armi di mischia,
   100 a distanza, 90 magiche, 60 di evocazione, e le classi delle mod (ladro, bardo, guaritore, lancio).
   **Ogni classe ha qualcosa di nuovo in ogni fase.**
4. **Ogni arma ha un gesto suo.** 1.650 proiettili diversi per 2.008 armi. Il «comportamento» è il primo modo di
   distinguere un oggetto, prima dei numeri.
5. **Le famiglie di oggetti da collezionare**, ognuna lunga e a gradi:
   - 54 ali, 33 rampini, 35 cavalcature, 14+ animaletti;
   - 29 casse da pesca, 90 pozioni, 222 consumabili con un effetto;
   - 541 stendardi (uno per nemico), 108 trofei, 46 reliquie, 66 sacchetti dei boss;
   - 189 tinture, 141 maschere, 105 carillon;
   - 4.371 oggetti che si posano.
6. **La generosità delle ricette.** 713 ricette accettano ingredienti alternativi («qualsiasi legno», «ferro o piombo»),
   e 630 oggetti si fanno in più modi. Le stazioni sono 49, e le ricette più usate stanno al banco, all'incudine,
   all'incudine di mithril, al solidificatore, alla segheria, alla stazione lunare e al banco del tinkerer
   (l'unione degli accessori).
7. **Le trasformazioni.** Il Luccichio ne fa 707 (oggetto → oggetto, nemico → oggetto): un modo di trovare ciò che manca
   e di sperimentare.
8. **I nemici si contano e si ricordano.** 775 nemici hanno uno **stendardo**: dopo 50 sconfitte si fabbrica, e dove è
   appeso fa più danno contro quel nemico. 71 biomi, con una mediana di 8 nemici ciascuno (il Dungeon 52, le Caverne
   48). Gli eventi (goblin, pirati, marziani, Legione del gelo, armata dell'Antico) hanno nemici propri.
9. **La rarità si vede.** Dodici colori di rarità nel gioco base, più quelli delle mod: il nome dell'oggetto dice subito
   «quanto vale» e «a che punto della partita sta».
10. **Le modalità di difficoltà danno contenuto.** Esperto e Maestro portano sacchetti, oggetti solo-Esperto (139) e
    solo-Maestro (117: reliquie, animaletti). Calamity aggiunge Revengeance e Death con meccaniche (Rabbia, Adrenalina).

### 1.3 Lo spirito di progetto (le regole che leggo dietro i numeri)

- **«Un oggetto, un gesto.»** Un'arma nuova è interessante se si usa diversamente, non se fa +4 di danno.
  I numeri servono a mettere l'oggetto nella fase giusta.
- **«Ogni incontro paga.»** Boss, mini-boss, eventi, casse dei biomi, pesca: ognuno ha una tabella sua con
  oggetti che si trovano solo lì. Il giocatore torna perché c'è sempre qualcosa da trovare.
- **«Le soglie cambiano il mondo.»** Le soglie grandi (Muro di carne, Plantera, Signore della Luna) non sono solo boss
  più forti: cambiano il mondo che si esplora e aprono una nuova infornata di tutto.
- **«Tante strade nella stessa fase.»** In ogni fase ci sono 8 classi, decine di armi, più set: la scelta è vera, e
  rigiocare con un'altra classe è un'altra partita.
- **«La collezione è infinita in larghezza.»** Ali, rampini, cavalcature, animaletti, tinture, vanità, trofei,
  carillon, arredi: ogni famiglia ha decine di pezzi, quasi tutti legati a un posto o a un incontro.
- **«Le mod moltiplicano, non sostituiscono.»** Calamity e Thorium aggiungono classi, biomi, boss e intere fasi sopra il
  gioco base, con lo stesso linguaggio: è la prova che un'architettura giusta regge una crescita enorme.

### 1.4 Che cosa abbiamo noi che loro non hanno (e che va tenuto)

- **I mondi progettati con i geni** (104 geni): l'esplorazione è infinita e guidata dal giocatore.
- **L'ecologia** (168 famiglie con prede, nidi, migrazioni, varianti per taglia, elemento e indole).
- **La mandria, l'allevamento e i compagni di battaglia.**
- **La rete di Linfa** (69 macchine, logica).
- **La lingua dei Seminatori** (114 parole) e la storia vera.
- **I dieci pilastri della maestria.**

La strada non è copiare Terraria: è dare alla **nostra** struttura (mondi a geni, vigore senza fine, Albero-Madre in
tre atti) la stessa **densità di cose diverse da trovare e da usare** che ha Terraria lungo la sua spina di boss.

---

## 2. I numeri da raggiungere

Obiettivi a fine piano. Non tutto in una volta: le fondamenta (Roadmap 38) li rendono raggiungibili con **dati**,
non con codice nuovo per ogni oggetto.

| Che cosa | Oggi | Fine piano | Terraria + 2 mod |
|---|---:|---:|---:|
| Oggetti | 3.635 | **≥ 12.000** | 11.005 |
| Armi | 647 | **≥ 2.200** | 2.008 |
| Comportamenti d'arma diversi | 59 | **≥ 1.500** | 1.650 |
| Armi gemelle | 29% | **< 5%** | 3% |
| Accessori (effetti diversi) | 466 (272) | **≥ 900 (≥ 600)** | 883 (676) |
| Pezzi d'armatura / set | 420 / 74 | **≥ 700 / 140** | 585 |
| Nemici comuni | 175 | **≥ 900** | 973 |
| Comportamenti dei nemici | 35 | **≥ 120 mattoni** | 88 + mano |
| Boss scritti a mano (più i generati) | 49 | **≥ 80** | 90 |
| Oggetti diversi lasciati da un boss | 3-6 | **15-25** | 20 |
| Ricette / stazioni | 2.609 / 12 | **≥ 8.000 / ≥ 40** | 7.849 / 49 |
| Catena più lunga | 3 | **8-10** | 9 |
| Danno inizio → fine | ×4,8 | **×25-40** | ×38 |
| Fasi della spina | 6 metalli | **≥ 24 fasi** | 23 |
| Famiglie con una funzione (ali, rampini, cavalcature, stendardi…) | poche | **≥ 12 famiglie da 30-100** | ~20 |

---

## 3. Le fondamenta (perché la vastità non diventi un mucchio)

Quattro regole di architettura, da scrivere in CLAUDE.md quando il piano parte:

1. **Tutto è dati, anche il comportamento.** Un'arma nuova = una riga che compone *moduli di comportamento* (traiettoria,
   colpo, effetto, suono, luce). Oggi il gesto sta nel codice della forma; con il motore dei moduli (voce 356) un
   oggetto nuovo non chiede codice. **Codice nuovo solo per un modulo nuovo**, che poi riusano centinaia di oggetti.
2. **Ogni oggetto ha una fase.** Il campo `fase` (calcolato come fanno gli strumenti di Terraria: dalla fonte, dalla
   ricetta, dal boss) decide rarità, colore del nome, valore e bilancio. Lo strumento della vastità (voce 359) conta
   quanti oggetti di ogni tipo arrivano in ogni fase e segnala i buchi, come `tools/durata.gd` fa per le ore.
3. **Ogni fonte ha una tabella.** Boss, mini-boss, eventi, casse, pesca, nidi, scrigni: ognuno ha la sua tabella di
   bottino con oggetti propri. Un oggetto senza fonte, o una fonte senza oggetti propri, è un errore di `verifica_dati`.
4. **Le famiglie si scrivono a tabelle, i pezzi speciali a mano.** Armi generate (forma × materiale × modulo), set
   generati, arredi funzionali in serie, stendardi, trofei: le tabelle danno la quantità. Armi uniche, boss, accessori
   firma, ritrovamenti: scritti a mano, danno il sapore. È la regola «generato + scritto a mano» della filosofia.

---

## 4. Le Roadmap

Ordine pensato perché ogni Roadmap renda subito qualcosa giocabile e prepari la successiva. Voci numerate da 356.

### Roadmap 38 «Le fondamenta della vastità» (il motore, prima dei contenuti)

Obiettivo: poter aggiungere migliaia di oggetti diversi **solo con dati**, e misurare in ogni momento quanto il gioco è
vasto e dove ha buchi.

- **356. Il motore dei gesti (moduli di proiettile e di colpo).** Una libreria `GesturesData` di **moduli** componibili,
  ognuno un piccolo comportamento con i suoi parametri:
  - **traiettorie**: dritta, ad arco, che torna (boomerang), che rimbalza, che insegue, che orbita attorno al
    Germogliato, a spirale, a onda, che cade dal cielo, che sale dal terreno, raggio continuo, catena tra bersagli;
  - **colpi**: si divide all'impatto, esplode, lascia una pozza, lascia una scia, si incastra e scoppia dopo, rimbalza
    sulla creatura vicina, trapassa n creature, aumenta a ogni colpo (carica), richiama una creatura;
  - **gesti dell'arma**: fendente, affondo, rotante, carica tenuta, raffica, canalizzato, lancio, frusta che marchia,
    scudo che para, evocazione che resta.

  Un proiettile = una combinazione di moduli + aspetto (forma, colore, luce, particelle da `ImpactData`). Le armi di
  oggi diventano combinazioni dei moduli (nessun comportamento perso). Prova: un foglio con un'arma per modulo
  (foto), e la misura «comportamenti diversi» di `tools/confronto.gd`.
- **357. Le fasi e le rarità.** `PhasesData`: la spina della partita in **fasi numerate** (vedi Roadmap 39). Ogni oggetto
  riceve la sua fase in automatico (dalla fonte, dalla ricetta, dal Guardiano), come fa `bilancio.py` per Terraria.
  Da qui:
  - dodici **rarità** con il loro colore nel nome e nelle schede («Ambra», «Linfa viva», «Stellare»…, nomi nostri);
  - valore e prezzo legati alla fase.
- **358. Le tabelle del bottino per fonte.** Ogni fonte (boss, mini-boss, evento, cassa, pesca, scrigno, nido, meraviglia)
  ha una tabella in un posto solo (`SourcesData`), con:
  - **garantiti**;
  - **uno a scelta tra** (le armi del boss: se ne ha 5, ne cade una);
  - **rari** (1/20, 1/100);
  - **primo incontro** (cosa dà solo la prima volta).

  `ItemInfo.how_to_get` e il nuovo «Dove si trova» dell'Esamina le leggono tutte.
- **359. Lo strumento della vastità.** `tools/vastita.gd` → `prove/vastita.txt`:
  - per ogni fase quanti oggetti di ogni tipo (armi per classe, accessori, armature, consumabili, collezione), quanti
    comportamenti diversi, quante gemelle;
  - per ogni bioma e strato quanti nemici;
  - per ogni fonte quanti oggetti propri.

  Lo confronta con le curve di Terraria (che stanno già nei dati della cartella) e scrive i **buchi** in cima.
  Da qui in poi **ogni Roadmap del piano si chiude con questa misura**.
- **360. Il generatore di contenuti.** Gli script che scrivono i dati da tabelle compatte (come `gen_bestiario.py`), per
  tutte le famiglie del piano: armi (forma × materiale × modulo), set, accessori a gradi, stendardi, trofei,
  arredi, pesci. Ogni file generato porta in cima «generato da …: non toccare a mano».
- **361. La verifica allargata.** `verifica_dati` controlla anche:
  - ogni oggetto ha una fase e una fonte; ogni fonte ha oggetti propri;
  - ogni modulo usato esiste; nessuna arma gemella fuori dalle eccezioni dichiarate;
  - ogni nemico ha un bioma e uno stendardo; ogni boss ha almeno 12 oggetti nel suo bottino.

### Roadmap 39 «La spina della partita» (progressione e soglie)

Obiettivo: una progressione lunga, a **24+ fasi**, con soglie che cambiano il mondo, dentro la nostra struttura
(Albero-Madre in tre atti, mondi a vigore).

- **362. Le fasi.** La spina è fatta dai **Guardiani** (uno per vigore, scritti a mano fino al 24) e dalle **soglie**
  dell'Albero-Madre. Le fasi proposte:

  | Fasi | Dove siamo nella partita | Soglia che chiude |
  |---|---|---|
  | 0-3 | Giardino, primi mondi | Nodo, Regina, Colosso (i tre di oggi) |
  | 4-7 | fine Atto I | **Il Risveglio del Cuore**: la prima grande soglia (come il Muro di carne) |
  | 8-15 | Atto II, Giardini perduti | **La Radice del cosmo** (dopo i quattro Giardini perduti) |
  | 16-23 | Atto III | **Il Seme Primo** |
  | 24+ | il dopo | Semi d'oro, vigore oltre il 24, Guardiani generati |

- **363. I metalli e i materiali per fase.** Da 6 metalli a **16 gradi** (un metallo o una lega maestra ogni 1-2 fasi),
  ognuno con:
  - le sue vene (in mondi di un certo vigore o con un certo gene);
  - la sua stazione di lavoro;
  - il suo set per classe;
  - il suo **gesto** (voce 371).

  Proposte di nomi nostri da affinare:
  - prima della prima soglia: radicite, legnoferro, ambra, **corallite**, **ossidiana di brace**, Linfa;
  - Atto II: vuotite, **nimbite**, **sanguinite**, **ferrolume**;
  - Atto III: stellare, **cuorelegno**, **eterite**, **prima-ambra**.
- **364. La prima grande soglia: il Risveglio del Cuore.** Battuto (o curato) il Guardiano della fase 7, **tutti i
  mondi cambiano**:
  - nel Giardino cresce una seconda radice;
  - in ogni mondo (anche quelli già visitati) si apre uno **strato nuovo** sotto il Fondo, o una **corruzione della
    Linfa** che si allarga;
  - minerali nuovi compaiono nelle rocce antiche (come gli altari di Terraria);
  - nascono nemici «risvegliati» in tutti gli strati.

  È il nostro «hardmode»: la partita raddoppia.
- **365. La scala dei numeri.** Ritaratura di tutto con `tools/percorso.gd` e `tools/curva.gd`:
  - danno delle armi da ×4,8 a **×30 circa** sull'intera spina;
  - Vita dei Guardiani da ×6,5 a **×100-200**;
  - Scorza e Vita del Germogliato in proporzione;
  - scontri finali di Atto che durano **5-10 minuti** e chiedono preparazione (pozioni, arena costruita, set).

  Il vigore oltre la spina resta un moltiplicatore, ma ogni 5 punti porta anche una «fase del dopo» con un materiale
  e oggetti propri.
- **366. Le soglie si vedono.** Il Libro dei pilastri e il filo mostrano la fase attuale, che cosa la chiude e che cosa
  aprirà (senza svelare i nomi). Un **«Diario della spina»** (scheda nel Semenzaio) mostra le fasi passate con ciò che
  hanno portato.

### Roadmap 40 «Le armi» (prima ondata: da 59 a 600+ comportamenti)

Obiettivo: ogni arma con un gesto proprio, in ogni fase e per ogni classe.

- **367. Le classi del Giardiniere.** Otto stili, ognuno con la sua risorsa, i suoi accessori e i suoi set:

  | Stile | Risorsa e meccanica |
  |---|---|
  | **Mischia** | Vigore: colpi pieni caricano un colpo forte |
  | **Distanza** | Dardi e semi da fionda |
  | **Linfa** (magia) | Linfa |
  | **Evocazione** | Alleati, posti alleato |
  | **Lancio** | Furtività, come il ladro di Calamity: stare fermi carica il lancio perfetto |
  | **Canto** (come il bardo di Thorium) | Ispirazione; i canti rinforzano te e i compagni |
  | **Cura** (come il guaritore) | Rugiada; la cura degli alleati e della mandria fa danno ai nemici |
  | **Radice** (nostra) | Piante da combattimento che si seminano sul campo e crescono durante lo scontro |

  Con la mandria e i compagni si legano bene **Evocazione**, **Canto** e **Cura**.
- **368. Le forme nuove.** Dalle 16 forme di oggi a **30 circa**:
  - mischia: falce lunga, guanti, scudo-arma, ascia da guerra, bastone da combattimento;
  - distanza: fionda, cerbottana, lanciaspore;
  - Linfa: tomo, sfera;
  - lancio: lame da lancio, boomerang;
  - Canto: corni, flauti, tamburi;
  - Cura: rami;
  - Radice: semi-bomba e semi-torre.

  Ognuna ha il suo gesto base fatto di moduli.
- **369. Il gesto del materiale.** Ogni metallo, lega e materiale dei geni (57 oggi, ~80 a fine piano) aggiunge **un
  modulo** al gesto della forma. Per esempio:
  - radicite: rimbalza;
  - legnoferro: trapassa;
  - ambra: intrappola;
  - corallite: lascia una pozza;
  - brace: incendia e scoppia;
  - Linfa: insegue;
  - vuotite: si divide;
  - nimbite: chiama un fulmine;
  - stellare: piove dal cielo.

  Con 30 forme × 16 gradi × moduli del materiale le gemelle spariscono, e ogni combinazione si comporta in modo
  diverso. **È la voce che da sola porta i comportamenti da 59 a diverse centinaia.**
- **370. Le armi scritte a mano, per fase.** Per ogni fase, **8-12 armi uniche** (fuori dalla tabella forma ×
  materiale), una per classe, con un gesto speciale (moduli rari o un modulo nuovo). 24 fasi × 10 = **~240 armi
  firma**. Si trovano: nei bottini dei Guardiani, dei Custodi, dei Signori, nelle casse dei biomi, negli eventi.
- **371. Le linee d'arma che crescono.** Alcune armi uniche hanno una **linea**: si fondono con altre armi della stessa
  famiglia, in catene lunghe (5-8 passaggi), fino a un'**arma suprema** per classe, come la Zenith (le spade di tutto
  il gioco fuse in una). Otto armi supreme, una per stile, ognuna il traguardo di un pilastro.
- **372. Le munizioni.** Dardi, semi da fionda, spore da cerbottana, frecce di Linfa: 30-40 munizioni, ognuna con un
  **modulo** suo (dardo di brace che incendia, seme che germoglia, spora che avvelena), che si somma a quello
  dell'arma.

### Roadmap 41 «I boss come tesori»

Obiettivo: ogni boss un incontro ricordabile e un bottino ricco.

- **373. I Guardiani scritti a mano fino al 24.** Oggi ne sono scritti a mano tre (poi generati). Fino alla fase 24 un
  Guardiano scritto a mano per fase, con:
  - **fasi di scontro** (2-3, con cambio di comportamento e di arena);
  - attacchi annunciati (i segnali di `TeleMark`);
  - un'**arena** che cambia (il Cuore di ogni vigore ha una forma sua);
  - musica.

  I Guardiani generati restano per il dopo.
- **374. I sacchetti dei Guardiani.** Ogni Guardiano lascia un **Sacchetto** (come i Treasure Bag):
  - 1-2 armi a scelta tra 5-6 (una per stile);
  - 1 accessorio firma;
  - materiali e un ingrediente unico per le armi supreme;
  - il trofeo (bonus nella sala dei trofei), un animaletto con un dono (raro), un richiamo.

  **12-20 oggetti propri per Guardiano**, tutti con una funzione. Rifarlo al Cerchio ha senso finché la collezione non è piena.
- **375. I mini-boss e i boss di evento.** Per ogni fase 2-3 mini-boss che si incontrano esplorando (nelle grandi
  caverne, sopra le meraviglie, nel cielo), più i capi delle maree e degli eventi. Ognuno lascia 5-10 oggetti propri.
- **376. I boss facoltativi.** Una decina di boss fuori dalla spina, che si chiamano con un oggetto da costruire
  (come Calamity e Thorium): più difficili della fase in cui si possono affrontare, con bottini che anticipano la fase
  dopo. Per chi vuole la sfida.
- **377. La corsa dei boss e i boss del dopo.** Dopo il Seme Primo:
  - la **corsa dei Guardiani** (tutti in fila, una ricompensa propria);
  - tre **superboss** del dopo (il vigore oltre il 24), con l'equipaggiamento finale.

### Roadmap 42 «Le creature» (da 175 a 900 specie, da 35 a 120 comportamenti)

- **378. La libreria dei comportamenti.** Da 35 a **120 mattoni**. Ogni mattone è un file piccolo con parametri, come
  oggi:
  - movimenti: scavare, nuotare, planare, arrampicarsi, rotolare, saltare a molla, teletrasportarsi, dividersi,
    agganciarsi al soffitto, correre in branco;
  - attacchi: raggio, pioggia di colpi, onda d'urto, carica con scia, cerchio di spine, scudo, cura degli altri,
    evocazione, furto, travestimento.

  I mattoni nuovi si scrivono **una volta** e li usano centinaia di specie.
- **379. Nemici per bioma e per fase.** Ogni bioma di superficie, del sottosuolo e del cielo ha **almeno 12 specie**
  (Terraria ne ha una mediana di 8), divise per fase: le specie della prima soglia («risvegliate») si aggiungono a
  tutti i biomi. Con 31 biomi × 2 fasi × 12, più gli strati e gli eventi, si arriva a **~900 specie**.
- **380. Le specie firma.** Ogni bioma ha **2-3 creature con un comportamento che c'è solo lì**, scritto apposta (come
  i mimic, le creature della Corruzione, il Dungeon Guardian): la ragione di andare in quel bioma.
- **381. Gli stendardi.** Ogni specie ha il suo **stendardo**: dopo 50 sconfitte lo si fabbrica; appeso, fa più danno
  e meno ferite contro quella specie in un raggio. 900 stendardi da collezionare, con una sala del Museo. Si lega
  allo studio delle creature: lo studio dà la conoscenza, lo stendardo il dominio.
- **382. Gli eventi per fase.** Da 4-5 eventi a **12-15**, ognuno con nemici propri, un capo e un bottino proprio:
  - l'assalto dei rovi;
  - la notte delle falene;
  - la marea di Linfa nera;
  - l'invasione dei Seminatori caduti;
  - la pioggia di stelle viva;
  - l'eclissi del Vuoto;
  - la carovana dei mercanti di mondi.

  Alcuni arrivano da soli, altri si chiamano con un oggetto.

### Roadmap 43 «Gli accessori e il movimento»

Obiettivo: 900 accessori, di cui 600 con un effetto diverso; il movimento come famiglia di collezione.

- **383. Il motore delle abilità.** Gli accessori oggi sommano 35 numeri. Si aggiungono le **abilità**: effetti di
  `EffectsData` con «quando» nuovi (salto doppio, scatto, atterraggio, parata, cambio d'arma, raccolta, notte, acqua,
  stare fermi, volare) e «cosa» nuovi (scia, scudo, aura, pioggia, clone, magnete). Ogni accessorio firma ha
  un'abilità che nessun altro ha.
- **384. Le linee del Tinkerer (l'Officina del Giardiniere).** Accessori che si **uniscono** in catene: stivali della
  corsa + stivali del salto → stivali della tempesta → … (come gli stivali di Terraspark). 30 linee di 3-6 passaggi,
  per tutte le funzioni (movimento, raccolta, difesa, luce, pesca, costruzione, mandria).
- **385. Le ali.** Da poche a **~50 ali**, a gradi per fase, ognuna con il suo volo (planata, sbattere, librarsi,
  scatto in aria) e il suo aspetto. Si trovano dai boss, dagli eventi, si fabbricano con materiali delle creature del
  cielo.
- **386. I rampini.** **~30 rampini**: portata, velocità, numero di ganci, gesti speciali (aggancio alle creature,
  doppio aggancio, rampino che fa luce).
- **387. Le cavalcature.** Dalla mandria: ogni famiglia addomesticabile può diventare cavalcatura con la sua sella;
  in più ~20 cavalcature uniche (scritte a mano) dai boss e dagli eventi. In tutto **~60**.
- **388. Gli animaletti e le luci.** **~60 animaletti** e luci da compagnia (dai boss, dalla pesca, dai segreti), con
  piccoli doni (luce, magnete, fortuna).

### Roadmap 44 «Le armature e i set» (senza vanità)

- **389. I set per stile e per fase.** Per ogni grado di metallo un set per ogni stile (testa diversa per stile, come in
  Terraria): 16 gradi × 8 stili = **128 set** generati, più ~40 set scritti a mano (dai boss, dagli eventi, dai Giardini
  perduti).
- **390. I bonus dei set come gesti.** Il bonus del set intero non è più solo un numero: è un'**abilità**:
  - il set di ambra intrappola chi ti colpisce;
  - quello di nimbite chiama fulmini quando salti;
  - quello del Vuoto ti fa diventare ombra per un attimo dopo un colpo critico.

  Una riga di dati per set, con i moduli del motore delle abilità.
- **391. ~~La vanità e le tinture~~** — tolta (scelta dell'utente: niente estetica pura). Al suo posto: **la forgiatura
  dei pezzi d'armatura** (ogni pezzo ha 1-2 posti per gemme e Essenze, come le armi, e i pezzi trovati hanno tratti
  propri), così anche l'armatura si cura e si migliora.

### Roadmap 45 «I ritrovamenti» (esplorare paga sempre)

- **392. Le casse dei biomi.** Ogni bioma e ogni strato ha la sua **cassa** (nelle rovine, nelle strutture, sotto le
  meraviglie) con 6-10 oggetti propri (armi uniche, accessori, attrezzi). Alcune si aprono solo con una **chiave del
  bioma** (si trova rara dalle creature di quel bioma dopo la prima soglia), come le casse del Dungeon.
- **393. I mimi.** Casse che sono creature (i Mimi del Giardino): un mini-scontro con un bottino proprio, uno per
  bioma.
- **394. Le strutture scritte a mano.** Il generatore piazza **100+ strutture** scritte a mano (oggi luoghi, rovine,
  cripte, centrali, osservatori), con:
  - una griglia di caratteri e un tesoro proprio;
  - una per bioma per fase (templi, nidi giganti, villaggi abbandonati, navi nel cielo, fucine sepolte);
  - una sorpresa (un enigma, un mini-boss, un abitante da salvare).
- **395. I rari dei nemici.** Ogni specie ha **un oggetto raro** (1/50 - 1/150), spesso un'arma o un accessorio con un
  gesto proprio: il motivo per cacciare una creatura anche quando si è più forti.
- **396. La Pozza di Linfa antica (le trasformazioni).** Una pozza da trovare in ogni mondo dopo la prima soglia:
  - un oggetto gettato dentro diventa un altro (~700 trasformazioni, come il Luccichio);
  - alcune creature che ci cadono diventano altro;
  - si scoprono e si scrivono nell'Erbario.

  Lega i materiali comuni ai rari e dà un modo di ottenere ciò che manca.
- **397. I semi segreti dei mondi.** Geni rarissimi e combinazioni nascoste che fanno nascere **mondi speciali**
  (come i seed segreti di Terraria): un mondo capovolto, un mondo di sola acqua, un mondo di Seminatori vivi, un mondo
  dove la notte non finisce. Ognuno con oggetti propri.

### Roadmap 46 «Consumabili, pesca e cucina»

- **398. Le pozioni.** Da ~90 consumabili a **~250**:
  - pozioni con effetti nuovi del motore delle abilità (respiro, salto, gravità, luce, scavo, pesca, mandria,
    costruzione, vista dei tesori, delle trappole, delle creature);
  - fiale che si versano sull'arma (veleno, brace, Linfa);
  - pozioni di stazione (si beve dalla stazione per un'ora).
- **399. Il cibo a gradi.** La cucina (30 piatti oggi) a **~120 piatti** in tre gradi di sazietà, con i prodotti dell'orto,
  della mandria e della pesca. La sazietà cresce per fase.
- **400. Le casse da pesca e le missioni.** **~40 casse da pesca** (una per bioma e per fase, con oggetti propri) e il
  libro del Pescatore con **missioni giornaliere** (un pesce strano al giorno, premi a collezione, come l'Angler).

### Roadmap 47 «Costruire con uno scopo» (niente arredi solo belli)

- **401. Trofei e reliquie che servono.** Per ogni boss un **trofeo** (nella sala dei trofei: più danno contro quel
  boss e la sua famiglia) e una **reliquia** (solo nella modalità più dura, voce 405: un piccolo bonus per sempre).
  Niente carillon né quadri.
- **402. Gli arredi funzionali.** Gli arredi esistono solo se servono: definiscono il tipo di una stanza (comfort,
  bonus), sono stazioni, contenitori, luci, letti, sedili che curano, scaffali che conservano, altari che danno un
  effetto. Le serie di oggi restano; se ne aggiungono solo con una funzione nuova (stanze nuove: officina, forgia,
  laboratorio di Linfa, serra calda, sala d'armi).
- **403. I blocchi che fanno qualcosa.** Più materiali da costruzione solo dove hanno una **proprietà** (isolano dal
  freddo, resistono alle esplosioni, fanno luce, conducono la Linfa, rallentano le creature, sono trasparenti alla
  luce): la costruzione diventa una scelta, non un catalogo di colori.

### Roadmap 48 «Il commercio e gli abitanti»

- **404. Il mercante viandante e le merci rare.** Un mercante che arriva a giorni alterni con merci **a rotazione**, una
  parte uniche (armi, accessori, vanità che si trovano solo lì). Gli abitanti vendono merci diverse secondo:
  - la fase;
  - la stagione;
  - la notte;
  - un evento in corso.

  Le voci nei negozi passano da 130 a **~1.500**. Ci sono oggetti da migliaia di Lumini.

### Roadmap 49 «La difficoltà come contenuto»

- **405. Le modalità.** Tre modalità scelte alla creazione del Giardino:
  - **Normale**;
  - **Radice dura**: creature più intelligenti, più fasi nei boss, **sacchetti con un oggetto in più**, accessori
    solo-Radice-dura;
  - **Vuoto** (come il Death di Calamity): una meccanica in più, la **Furia del Giardiniere**, che si carica con le
    ferite e si scatena; poi reliquie, animaletti e titoli propri.

  Come in Terraria, la difficoltà più alta **dà oggetti propri** (100+), non solo numeri.

### Roadmap 50 «La fabbricazione profonda»

- **406. Le stazioni.** Da 12 stazioni usate a **~40**, una per famiglia di lavoro, con la loro progressione (banco →
  banco pesante → officina). Ogni stazione nuova apre una famiglia di ricette.
- **407. Gli ingredienti alternativi.** I **gruppi** di ingredienti («qualsiasi legno», «qualsiasi pesce», «qualsiasi
  gemma», «radicite o pallidite»): come le 713 ricette di Terraria, rendono la fabbricazione generosa e permettono
  a ogni mondo di contare.
- **408. Più strade per lo stesso oggetto.** Gli oggetti importanti hanno 2-3 ricette (dal bioma, dalla mandria, dalla
  rete), coerenti con la regola «strade alternative» dei pilastri.

### Roadmap 51 «Il dopo senza fine»

- **409. Le fasi del dopo.** Oltre la spina (vigore oltre il 24), ogni 5 punti di vigore una **fase del dopo** generata
  ma con un **materiale nuovo** (dai geni del mondo), un set, 10 armi generate con i moduli più rari e un Guardiano
  generato con un sacchetto suo.
- **410. Le armi leggendarie generate.** Nei mondi del dopo, armi **leggendarie** con un nome, una storia breve (il canone
  della storia vera) e una combinazione di moduli rarissima: il «loot» senza fine. Restano poche, preziose e diverse.
- **411. La misura finale.** Lo strumento della vastità rifatto: oggetti, comportamenti, nemici, boss, ricette e ore
  contro gli obiettivi della sezione 2, e un rapporto per l'utente.

---

## 5. Ordine consigliato e prime mosse

1. **Roadmap 38** (fondamenta): niente di questo piano regge senza il motore dei gesti, le fasi e lo strumento della
   vastità. È anche la Roadmap che risolve per prima l'«equipaggiamento piatto» (con la voce 369, che si può anticipare
   subito dopo la 356).
2. **Roadmap 39** (la spina) e **40** (le armi): danno la sensazione di crescita e la varietà nelle mani del giocatore.
3. **Roadmap 41** (boss come tesori) e **42** (creature): danno la ragione di esplorare e di tornare.
4. **Roadmap 43-45** (accessori, armature, ritrovamenti): la larghezza.
5. **Roadmap 46-51**: consumabili e pesca, costruzione con uno scopo, l'economia, le modalità, la fabbricazione
   profonda, il dopo.

Ogni Roadmap:
- si chiude con `tools/vastita.gd` (i buchi), `tools/percorso.gd` (la difficoltà) e il giro intero delle prove;
- lascia un capitolo dell'Enciclopedia;
- si fa **rigiocare dall'utente** prima della successiva.

Come ha mostrato la Roadmap 37, la partita vera trova ciò che le prove non vedono.

## 6. Le regole del piano (da aggiungere a CLAUDE.md quando parte)

- **Un oggetto, un gesto.** Un'arma o un accessorio nuovo senza un comportamento o un'abilità che lo distingua è una
  gemella: va bene solo nelle famiglie generate, e la verifica le conta.
- **Ogni fonte ha i suoi oggetti, ogni oggetto ha la sua fonte.**
- **Ogni fase porta qualcosa a ogni stile.** Lo strumento della vastità segnala la fase in cui uno stile resta senza
  armi, accessori o set nuovi.
- **Le soglie cambiano il mondo**, non solo i numeri.
- **Quantità dalle tabelle, sapore dalla mano.** Le famiglie generate danno il numero; armi firma, boss, strutture e
  accessori firma sono scritti a mano, e ce ne sono in ogni fase.
- **I nostri sistemi restano il cuore.** Geni, ecologia, mandria, rete, lingua e pilastri devono **ricevere** dal piano
  (oggetti, creature, ricette per ognuno) e **dare** al piano (fonti, strade alternative). Nessuna voce del piano li
  scavalca.
