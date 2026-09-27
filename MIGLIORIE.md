# TERRAWORLD: le migliorie future più incisive

Scritto il 27 set 2026, a Roadmap 5-11 finite, per discuterne insieme. Parto da cosa c'è oggi, poi elenco le migliorie
**in ordine di impatto**, cioè quanto avvicinano il gioco alla sua filosofia: sapere *cosa* cercare e *perché*, e ogni
tanto trovare *ciò che non ci si aspetta*. Ogni voce dice il problema, la proposta, cosa **moltiplica** (la regola
«moltiplicare, non sommare») e quanto costa (S piccola, M media, L grande).

## Dove siamo, in numeri

- 1318 oggetti (768 nati da 48 materiali × 16 forme), 1042 ricette, 55 stazioni.
- 50 creature in 37 famiglie, ognuna in varianti (taglia × elemento × indole, più 4 indoli di grado).
- 76 geni in 13 categorie; 12 firme; 8 luoghi scritti a mano; 3 Guardiani scritti e infiniti generati; 6 leggende.
- Leggi dei mondi: acqua, Linfa e brace liquide, 6 tempi atmosferici, gravità, Guscio, Arcipelago, terra viva, tempo
  dei mondi.
- Fine gioco senza tetto: gradi del vigore, tempra, Seme Primo, sfide con i livelli.
- Circa 46.000 righe in 357 file; il giro delle prove dura ~5 minuti, con 0 errori nei dati.

**La forza del gioco**: il motore genetico e i contenuti scritti come dati. Un gene nuovo porta davvero mondi,
creature, materiali e ricerche insieme.

**Il rischio più grande**: un gioco così ricco non è mai stato giocato per ore da una persona. Le prove automatiche
dicono che tutto *funziona*, ma non che è *divertente*, né che il ritmo è giusto. È la cosa da risolvere per prima.

---

## 1. Partite vere, e strumenti per bilanciare (M) — la più urgente
**Problema.** Nessuno sa quanto dura arrivare al primo Guardiano, al vigore 5 o al Seme Primo. Non sappiamo se il
danno cresce troppo in fretta rispetto alla Vita delle creature, se le Schegge bastano, o se l'Albero-Madre chiede
troppo. I numeri sono sensati uno per uno, ma nessuno li ha mai guardati tutti insieme.

**Proposta.**
- Un **diario di partita** automatico: ogni traguardo con l'ora di gioco (primo Seme, primo Guardiano, vigore, stadi
  dell'Albero, morti e dove, cosa hai fabbricato e usato davvero). Lo leggiamo insieme dopo le tue partite.
- `tools/bilancio.gd`: le curve su una pagina. Danno delle armi per grado, Vita e danno delle creature per vigore,
  colpi per sconfiggerle, tempo per ottenere una ricetta. Così si vedono i salti e i buchi.
- Una **partita guidata di prova** (tu o un amico, 2-3 ore), con il diario acceso.

**Moltiplica** tutto: ogni sistema già fatto diventa migliore senza aggiungere niente.

## 2. La prima ora, e i sistemi che si aprono poco alla volta (M)
**Problema.** Oggi un personaggio nuovo ha davanti una sessantina di sistemi: HUD, dieci pannelli, tasti, Enciclopedia.
La filosofia chiede «sempre un filo da seguire», ma all'inizio i fili sono troppi.

**Proposta.**
- **Apertura progressiva**: pannelli, tasti e righe dell'HUD compaiono quando servono la prima volta. Esempi:
  Semenzaio al primo Seme, Mandria alla prima creatura amica, Maglio e tempra al primo grado.
- **L'Albero-Madre fa da guida**: una frase contestuale sul prossimo passo, che rimanda al capitolo giusto
  dell'Enciclopedia.
- Una **prima ora scritta a mano** nel Giardino e nel primo mondo, con un luogo che insegna scavo, luce e portale.

**Moltiplica** l'Enciclopedia, gli obiettivi e l'Albero, che già ci sono: vanno solo messi in fila.

## 3. Il «Consigliere dei Semi»: pianificare cosa cercare (M)
**Problema.** Il giro del gioco è: voglio X → mi serve il gene Y → innesto i Semi giusti → esploro. Oggi però il
giocatore deve ricostruirlo da solo, tra Genario, Erbario, catene e leggende.

**Proposta.** Un pannello che risponde a «come ottengo…?», per un oggetto, un materiale, una creatura o una leggenda:
- quali geni servono;
- dove li hai visti o imparati;
- quale coppia di Semi della tua Bisaccia ci si avvicina di più (il motore di `Genome.odds` c'è già);
- in che strato cercare.

Si possono **segnare obiettivi** («sto cercando il Nucleo del gelo»): la mappa e la scheda del portale lo ricordano.

**Moltiplica** l'innesto, le leggende, le catene e l'Erbario. È il cuore della filosofia («il giocatore progetta i
suoi mondi») reso visibile.

## 4. Combattimento più leggibile e più profondo (M-L)
**Problema.** I Guardiani generati sono vari negli attacchi, ma i colpi arrivano senza preavviso, e il corpo è la
creatura ingrandita a blocchi. Il combattimento si regge su tempi dell'arma, elementi e accessori; manca la mossa del
giocatore.

**Proposta.**
- **Preavvisi** per gli attacchi dei Guardiani (un bagliore, una posa prima della carica, un cerchio a terra prima
  della bomba) e **punti deboli** secondo l'elemento.
- Una **schivata** (scatto breve con un attimo di invulnerabilità, che costa Linfa) e la **parata** con lo scudo.
- La grafica dei Guardiani scritti a mano e dei corpi dei generati con Nano Banana, con lo stesso metodo del
  Germogliato (era già tra i lavori rimandati).

**Moltiplica** tutte le 16 forme d'arma, gli elementi, le indoli e i Guardiani generati: ogni combinazione diventa una
lotta diversa, non solo numeri diversi.

## 5. Mondi che si parlano (L)
**Problema.** Oggi ogni mondo è un'isola: ci vai, lo risolvi, torni. La rete dei mondi c'è (portali, Aiuole, radici
viandanti), ma i mondi non si influenzano.

**Proposta.**
- **Migrazioni tra mondi**: le creature addomesticate e le famiglie si spostano lungo i portali aperti.
- Un mondo lasciato con l'Avvizzimento **contagia** i vicini.
- **Commerci** tra gli abitanti di mondi diversi, e **richieste della Bacheca** che attraversano due o tre mondi.
- La mappa della rete come un **atlante**, con cosa è rimasto da trovare in ciascun mondo.

**Moltiplica** portali, fauna, Avvizzimento, abitanti e Bacheca, e dà un motivo per tornare nei mondi vecchi (la
terra viva ha già aperto la strada).

## 6. Il Giardino come casa che cresce (M)
**Problema.** Si costruisce (pareti, porte, mobili, abitanti), ma costruire rende poco, a parte le stanze per gli
abitanti.

**Proposta.** **Stanze con funzione**, riconosciute dal gioco quando hanno i mobili giusti:
- serra: colture più rapide;
- stalla: la mandria rende di più;
- officina: qualità di fabbricazione;
- biblioteca: le tavolette dei Seminatori si leggono meglio;
- osservatorio: le eclissi e i tempi si vedono in anticipo.

In più, il Giardino si allarga con gli stadi dell'Albero e le decorazioni si sbloccano con i trofei.

**Moltiplica** costruzione, abitanti, mandria, orto e trofei.

## 7. Contenuti scritti a mano, dove devono essere speciali (M, a pezzi)
**Problema.** Il generatore dà la quantità; il sapore viene da ciò che è scritto a mano: 8 luoghi, 3 Guardiani,
9 abitanti. In confronto a tutto il resto sono pochi.

**Proposta.**
- **Una storia per abitante**: una catena di richieste che finisce con un dono unico e una pagina di storia.
- Altri **luoghi** (uno per famiglia di geni).
- **Un Guardiano scritto a mano ogni 5 gradi di vigore** (i generati riempiono gli altri).
- **Oggetti unici legati alle firme** dei mondi.

**Moltiplica** firme, catene e lingua dei Seminatori, che già piazzano i pezzi nei mondi giusti.

## 8. Tenere in ordine il bottino (S-M)
**Problema.** 768 pezzi d'equipaggiamento generati sono ricchezza, ma anche una Bisaccia sempre piena.

**Proposta.**
- **Smontare** al Maglio: un pezzo torna in parte materiale e Schegge.
- **Filtri di raccolta**: non raccogliere ciò che è sotto una certa qualità.
- «Confronta con l'indossato» anche nella casella Esamina.
- I **preferiti** che il Deposita tutto non tocca.

**Moltiplica** la tempra, gli innesti e la qualità: il pezzo giusto vale più di dieci pezzi.

## 9. Preparare la rete a due (L, da pianificare ora)
**Problema.** Per giocarlo con 2-3 amici serve la rete, rimandata. Intanto il codice ha accumulato **stati statici**
condivisi, comodi in singolo e scomodi in rete. Alcuni esempi: `Creature.grav`, `Behavior.fog`, `Projectiles.wind`,
`Genome.known`, i moduli che toccano il Germogliato direttamente.

**Proposta.** Non fare la rete adesso, ma:
1. un inventario di questi punti;
2. una regola nuova in CLAUDE.md: «lo stato del mondo sta nel mondo, lo stato del giocatore nel giocatore»;
3. la separazione simulazione / disegno nei moduli nuovi.

Così, quando vorrai la rete, non servirà riscrivere tutto.

**Moltiplica**: ogni sistema diventa giocabile in due.

## 10. Suono dei mondi (S-M)
**Problema.** La musica c'è, e i suoni sono generati. Ma pioggia, vento, bufere, fiumi di brace, caverne allagate ed
eclissi non si sentono.

**Proposta.** Sottofondi generati per tempo atmosferico e liquidi (lo stesso sintetizzatore di `SfxSynth`), la musica
che cambia con lo strato, e un suono per ogni gene raro in arrivo.

**Moltiplica** meteo, liquidi e strati: le leggi dei mondi si sentono, non solo si vedono.

## 11. Ordine del codice e prove più svelte (S)
- `crafting_panel.gd` (515 righe), `tests_genes.gd` (513) e `main.gd` (482) sono sopra la soglia delle 400: vanno
  divisi. `main.gd` può montare i moduli da un elenco scritto come dati.
- Il giro completo dura ~5 minuti. I gruppi indipendenti possono girare su mondi di prova piccoli, e il mondo si può
  generare una volta e ricaricare. Obiettivo: 2 minuti.
- Prima di dare il gioco agli amici: una **versione stabile** con le migrazioni dei salvataggi riattivate (voce 41),
  perché le loro partite non vadano perse.

---

## La mia proposta d'ordine
1. **Partite vere + strumenti di bilancio** (1), perché tutto il resto dipende da cosa scopriamo giocando.
2. **Prima ora e apertura progressiva** (2), insieme al **Consigliere dei Semi** (3): sono il «filo da seguire».
3. **Combattimento leggibile** (4), con la grafica dei Guardiani.
4. Poi, a scelta tua, **mondi che si parlano** (5) o **la casa che cresce** (6); i contenuti scritti a mano (7) si
   aggiungono a pezzi lungo la strada.
5. Le voci 8-11 si fanno quando capita, tra una grande e l'altra.
