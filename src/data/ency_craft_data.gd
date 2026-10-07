class_name EncyCraftData
## Enciclopedia (27 set 2026), seconda parte: creare ed equipaggiarsi, combattere, la vita del mondo.
## Stesso formato di `EncyGuideData`.

const CHAPTERS := [
	{"id": "creare", "group": "Creare ed equipaggiarsi", "name": "Creare", "text":
"""Il pannello [b]Creare[/b] è in alto a sinistra della Bisaccia aperta. Mostra le ricette dei [b]banchi[/b] a portata (entro {craft_reach} tessere) e quelle che si fanno a mano; con «Anche i banchi lontani» anche le altre, per sapere cosa serve e dove.
• A sinistra le categorie colorate, in quattro gruppi (Equipaggiamento, Consumi e materiali, Costruire, Il mondo), ognuna con quante ricette puoi fare adesso: i [b]banchi da lavoro[/b] stanno in «Banchi e casse», lontani da trappole, totem e macchine. Scelta una categoria, sopra la griglia compaiono le sue [b]sottocategorie[/b] (Spade, Lance, Archi…; Mattoni, Colonne…; le serie di arredi): un clic mostra solo quella, «Tutte» le rimette. Sopra, la ricerca per nome o per ingrediente e «Solo possibili». In fondo alle categorie, le [b]Lavorazioni[/b] del Maglio e del Telaio sull'oggetto in mano (tratti, innesti, fasce), quando ce ne sono.
• Ogni ricetta è una casella con l'icona e, sotto, una barra: quanto hai già degli ingredienti (piena e verde = si può fare).
• [b]Clic[/b] la sceglie: nella colonna [b]Esamina[/b], a destra, compaiono il banco, gli ingredienti con «ne hai / ne servono», la quantità (−, +, Max) e il pulsante [b]Crea[/b]. [b]Doppio clic[/b] crea subito una volta, [b]Maiusc+clic[/b] cinque.
• Gli ingredienti vengono dalla Bisaccia e dalle [url=cap:casse]casse vicine[/url].
I banchi:
{cat_banchi}
Le ricette delle [b]leghe[/b] si scoprono trovando i loro materiali (vedi [url=cap:materiali]Materiali[/url])."""},
	{"id": "materiali", "group": "Creare ed equipaggiarsi", "name": "Materiali e leghe", "text":
"""Armi, attrezzi e armature nascono da una [url=cap:forme]forma[/url] e da un [b]materiale[/b]. Il materiale ha delle proprietà: [b]durezza[/b] (forza del piccone, difesa), [b]filo[/b] (danno), [b]peso[/b] (lento o veloce), [b]tenacia[/b], [b]conduzione[/b] (i bastoni), a volte un [url=cap:elementi]elemento[/url] e la [b]risonanza[/b] (posti d'innesto in più).
Le [b]leghe[/b] uniscono due metalli al Baccello ardente e ne mescolano le proprietà (e gli elementi, che si alternano a ogni colpo). I materiali dei [url=cap:geni]geni[/url] si trovano solo nei mondi con quel gene.
Ogni materiale ha anche un [b]carattere[/b], un bonus tutto suo: la radicite fa ricrescere la Vita, il legnoferro dà Scorza, la pallidite corsa, l'ambra luce, la tizzonite spine, la Linfa Linfa, la vuotite ti nasconde, la nimbite fa saltare, lo stellare porta fortuna; i materiali dei geni hanno i loro. Le leghe prendono metà del carattere di ciascuno dei due metalli. Ogni pezzo ne prende una parte: un quarto elmo, corazza e gambali, metà guanti, stivali e mantello, metà l'arma o l'attrezzo che tieni in mano (la sua scheda dice «In mano»). Così due pezzi dello stesso grado di materiali diversi non sono mai uguali.
Ogni materiale ha poi un [b]gesto[/b]: tutte le armi fatte di quel materiale lo portano. Al colpo fanno qualcosa in più:
• la radicite trattiene, il legnoferro trapassa, l'ambra rallenta;
• la Linfa rende Vita, il vuoto lancia schegge, la tizzonite incendia;
• la stellare fa cadere stelle, la nimbite chiama fulmini.
E i colpi a distanza (archi, verghe) volano in modo diverso: rimbalzano, si dividono, scoppiano, inseguono, ondeggiano o tornano indietro.
Una [b]lega[/b] porta i gesti dei suoi due metalli insieme. Esamina dice il gesto di ogni arma.
{cat_materiali_breve}
Il catalogo completo: [url=cat:materiali]tutti i materiali[/url]."""},
	{"id": "spina", "group": "Creare ed equipaggiarsi", "name": "La spina della partita", "text":
"""La partita ha ventiquattro [b]fasi[/b]: le dispari sono i dodici metalli, le pari i Guardiani e le soglie. Il colore del nome di ogni oggetto dice in che fase arriva. Dove sei arrivato lo dice la pagina [b]La spina[/b] nel Taccuino del Semenzaio, con tutti i metalli e dove si trovano.
Ogni mondo di vigore più alto ha creature con molta più Vita (un terzo in più a ogni vigore) e che colpiscono più forte. Per questo ogni metallo nuovo fa un terzo di danno in più del precedente: dalla radicite alla primambra il danno cresce di ventisei volte. I Guardiani durano di più a ogni vigore: da un minuto a tre.
[b]Il Risveglio del Cuore[/b] è la prima grande soglia. Quando risolvi il Guardiano di un mondo di vigore 4 o più, curato o abbattuto, tutti i mondi cambiano, anche quelli già visitati:
• nelle rocce dei mondi più vigorosi compaiono sei metalli nuovi: corallite (vigore 6), sanguinite (7), cuorelegno (8, nelle radici giganti), eterite (9), astrite (10, nel Fondo) e primambra (11). Ognuno si trova per qualche vigore, poi lascia il posto al successivo; la primambra resta per sempre;
• le creature antiche nascono più spesso e a volte lasciano il metallo del loro mondo;
• nel Giardino spunta una radice nuova: un'Aiuola in più;
• i Guardiani dei mondi di vigore 5 e oltre lasciano la [b]Linfa del Cuore[/b]: +15 Vita massima per sempre, fino a dodici volte.
I metalli nuovi si fondono al Baccello ardente come gli altri (tre grezzi per un lingotto) e danno armi, attrezzi, armature e un set ciascuno, con il loro gesto e il loro carattere. Non fanno leghe.
Oltre il vigore 11 le creature crescono piano: lì contano la [url=cap:vigore]tempra[/url] al Maglio, i set e le arti."""},
	{"id": "stili", "group": "Combattere", "name": "Gli otto stili", "text":
"""Ogni arma appartiene a uno [b]stile[/b], e ogni stile ha una [b]risorsa[/b] che cresce mentre lo usi. La sua riga compare sopra la barra rapida.
• [b]Mischia[/b] (spade, pugnali, falci lunghe, manopole, egide, bipenni, randelli…): lo [b]Slancio[/b]. Ogni giro che colpisce ne dà uno. Quando è pieno, il giro dopo fa il doppio e scuote chi sta attorno. L'egida in mano dà anche Scorza.
• [b]Distanza[/b] (archi, balestre, fionde, cerbottane, lanciaspore): le [b]munizioni[/b]. Archi e balestre tirano dardi, le fionde sassi, cerbottane e lanciaspore spore. Ogni munizione ha il suo modo: rimbalza, si divide, scoppia, insegue, gela, brucia. L'arma tira quella del suo tipo che fa più danno.
• [b]Linfa[/b] (verghe, tomi, sfere): incantesimi che spendono Linfa. Il tomo tira tre pagine che inseguono, la sfera un globo lento che attraversa tutto.
• [b]Evocazione[/b] (scettri del branco): richiamano un alleato forte come il metallo dello scettro.
• [b]Lancio[/b] (dischi, girandole): la [b]Mira ferma[/b]. Se resti fermo un attimo, il lancio dopo è perfetto: quasi doppio e attraversa.
• [b]Canto[/b] (buccine, flauti, tamburi): l'[b]Ispirazione[/b]. Ogni nota che colpisce ne dà una. Quando è piena parte il canto dello strumento: la buccina dà più danno, il flauto cura te e i compagni, il tamburo dà Scorza.
• [b]Cura[/b] (virgulti): ferire ti cura. Ogni sei colpi un'onda di [b]Rugiada[/b] cura te e i compagni in campo.
• [b]Radice[/b] (semi-torre e semi-bomba): il seme-torre si pianta su un pavimento vicino e tira spine da solo per dodici secondi; puoi cambiare arma intanto. Il seme-bomba si lancia ad arco e scoppia.
Le forme nuove si fanno al Maglio con i metalli e i materiali dei geni, non con le leghe.

[b]Le armi firma[/b]
Per ogni fase della partita ci sono dieci armi uniche, una per stile più due: nome proprio, elemento, effetti tutti loro e, se tirano, il loro modo di volare. Non si fabbricano. Le lasciano i Guardiani (sempre una), i Signori, i Custodi, i capi delle maree e delle prove (a volte), e si trovano negli scrigni delle rovine. Sono della fase del posto in cui le trovi.

[b]Le linee d'arma[/b]
Al Maglio dei Seminatori le armi firma di uno stile si fondono in una [b]linea[/b] di sei passi. Ogni passo porta gli effetti delle armi che l'hanno fatto. L'ultimo è l'[b]arma suprema[/b] dello stile, per esempio la Radice del mondo per la mischia o l'Arco del firmamento per la distanza."""},
	{"id": "pozioni", "group": "Creare ed equipaggiarsi", "name": "Pozioni, fiale, fonti e piatti", "text":
"""All'Alambicco quaranta [b]pozioni[/b] a tempo, ognuna in tre gradi (minore, normale, maggiore: più forte e più lunga, con ingredienti di fasi più avanti): corsa, salto, scavo, respiro, pesca, mandria, la forza di ognuno degli otto stili, i ripari dal caldo, dal freddo, dalla polvere e dall'aria sottile, e tre [b]viste[/b] che fanno brillare nel buio i tesori, le creature o le trappole (anche i mimi).
La Vita massima cresce con la partita, e con lei le [b]pozioni di cura[/b]: dopo quella di rugiada e quella di radice ce ne sono cinque più forti, fino a quella della prima Linfa.
Le [b]fiale[/b] si versano sull'arma: per qualche minuto i colpi bruciano, gelano, avvelenano, curano, fanno cadere stelle, rendono fragili o fanno sanguinare.
Le [b]fonti[/b] si posano nella base: toccandole, l'effetto della loro pozione dura un'ora.
Al Paiolo i [b]piatti[/b] hanno tre gradi di sazietà (Sazio, Ben nutrito, Rifocillato): più gli ingredienti sono avanti, più il piatto rende, e ognuno aggiunge un effetto suo.
Pescando negli stagni di ogni bioma abbocca a volte la sua [b]cassa da pesca[/b], con oggetti che si trovano solo lì; nei mondi più vigorosi le casse dei gradi del mondo. Il Pescatore premia chi vince molte gare del giorno."""},
	{"id": "armature", "group": "Creare ed equipaggiarsi", "name": "Elmi degli stili, set e forgia", "text":
"""Ogni stile ha il suo [b]elmo[/b], in ogni metallo puro e materiale dei geni: la Celata per la mischia, il Cappuccio da tiro per la distanza, il Diadema per la Linfa, la Maschera del branco per gli alleati, la Benda del lanciatore, la Ghirlanda per il canto, il Velo di rugiada per la cura e il Cappello di radice per i semi. Ha meno Scorza dell'elmo comune, ma l'arma del suo stile ferisce di più (solo quella: con un'arma di un altro stile in mano non conta).
Con la corazza e i gambali dello stesso materiale l'elmo fa il [b]set dello stile[/b]: il bonus cresce ancora e arriva un'abilità dello stile.
Ogni set intero ha un'[b]abilità[/b], una cosa che fa da solo: il set d'ambra stordisce chi ti ferisce, quello di nimbite chiama un fulmine quando salti, quello del Vuoto ti fa diventare ombra ogni tanto, quello di radicite scuote il terreno quando atterri dall'alto. Le leghe portano le abilità dei loro due metalli. Esamina scrive l'abilità di ogni set.
I Guardiani, i capi erranti, gli sfidanti, i superboss e i capi degli eventi lasciano le loro [b]spoglie[/b]: tre pezzi (un pezzo a ogni capo sconfitto o Sacchetto aperto) che insieme fanno un set con un'abilità sua.
La [b]forgia[/b]: le essenze della forgia (dai capi, dai Sacchetti e dagli scrigni delle rovine) si innestano al Maglio sui pezzi d'armatura: danno, colpi più rapidi, incantesimi, salto, Scorza, Linfa, alleati o canto. Anche i pezzi trovati o fabbricati nascono a volte con uno di questi tratti."""},
	{"id": "abilita", "group": "Creare ed equipaggiarsi", "name": "Accessori, abilità e Officina", "text":
"""Molti accessori hanno un'[b]abilità[/b]: una cosa che fanno da soli quando succede qualcosa. Saltando, con il doppio salto, atterrando da in alto, con uno scatto, raccogliendo un oggetto, volando o agganciando il rampino. Lasciano una scia che ferisce, ti coprono di Scorza per un attimo, attirano gli oggetti, chiamano stelle e fulmini, danno Slancio o Ispirazione, rendono pronta la Mira ferma. Esamina scrive l'abilità di ogni accessorio.
Gli [b]accessori firma[/b] sono sei per ogni fase della partita, tutti diversi: cadono dai capi e dai Guardiani insieme alle armi firma, e si trovano negli scrigni delle rovine.
All'[b]Officina[/b] del Maglio trenta [b]linee[/b] (Passo del vento, Mano del minatore, Corteccia viva…) fondono gli accessori firma in quattro passi: ogni passo tiene le abilità di quelli che l'hanno fatto, e il quarto ne ha una sua.
Ci sono ali per ogni fase (le veloci e le lunghe, ognuna con un'abilità in volo), rampini sempre più lunghi e svelti con un'abilità all'aggancio, e quarantotto [b]animaletti[/b] nuovi da trovare dai capi: ognuno ha un dono piccolo (luce, oggetti attirati, Linfa, un poco di fortuna o di Scorza…)."""},
	{"id": "forme", "group": "Creare ed equipaggiarsi", "name": "Le forme", "text":
"""La forma decide come si usa un oggetto: la sua area di colpo, la velocità, a che cosa serve. Ogni forma esiste in ogni materiale.
{cat_forme}"""},
	{"id": "qualita", "group": "Creare ed equipaggiarsi", "name": "La qualità", "text":
"""Ogni arma, attrezzo e armatura nasce con una [b]qualità[/b]: {cat_qualita}. La qualità cambia i valori e dà posti d'innesto in più. Al [b]Maglio dei Seminatori[/b] escono più spesso le qualità alte; la fortuna aiuta.
[b]La rifusione dei doppioni[/b]: al Maglio, con un oggetto in mano e un altro identico nella Bisaccia (stessa forma, stesso materiale), la lavorazione «Rifondi» li unisce in uno solo con la qualità più alta dei due (se sono uguali, un grado in più), il tratto migliore e gli innesti di tutti e due finché c'è posto. Non cambia il materiale: per salire di grado serve sempre il metallo nuovo."""},
	{"id": "tratti", "group": "Creare ed equipaggiarsi", "name": "Tratti e innesti", "text":
"""Un oggetto può nascere con un [b]tratto[/b] (Spina: +15% danno; Vento: colpi più rapidi…). Al Maglio si [b]rinnova[/b] il tratto (sempre diverso dal vecchio) pagando materiali.
Le [b]Essenze[/b] (lasciate dalle creature antiche, una per tratto delle antiche) si [b]innestano[/b] al Maglio: ogni oggetto ha dei [b]posti d'innesto[/b] (uno in più per ogni qualità sopra «buono» e per la risonanza del materiale, al massimo {max_slots}). Un innesto si può togliere, perdendo l'Essenza.
I suggerimenti mostrano i tratti in rosso quando peggiorano l'oggetto.
Tutti i tratti: [url=cat:tratti]catalogo dei tratti[/url]."""},
	{"id": "fasce", "group": "Creare ed equipaggiarsi", "name": "Le fasce del Telaio", "text":
"""Al [b]Telaio di foglie[/b] si avvolge una [b]fascia[/b] sul manico di un'arma o di un attrezzo: cambia un poco i suoi valori (più spinta, più velocità, più danno…) e prende il posto della fascia di prima.
{cat_fasce}"""},
	{"id": "set", "group": "Creare ed equipaggiarsi", "name": "I set", "text":
"""Elmo, corazza, gambali, guanti e stivali dello stesso materiale (o le vesti e le coppie di accessori dello stesso set) indossati insieme danno un [b]bonus di set[/b]. Ogni metallo, ogni [url=cap:materiali]lega[/url] e ogni materiale dei geni ha il suo: quello di una lega unisce i set dei suoi due metalli, a metà ciascuno. La scheda di un pezzo dice quanti pezzi del set indossi.
{cat_set}"""},
	{"id": "accessori", "group": "Creare ed equipaggiarsi", "name": "Gli accessori", "text":
"""Due posti per gli accessori. Danno effetti che cambiano il modo di muoversi e combattere: correre più veloci, saltare più in alto, [b]planare[/b] tenendo il salto, [b]salti in aria[/b], scivolare e saltare sulle [b]pareti[/b], niente ferite da caduta, alone più ampio, fortuna nel bottino, spine, Linfa più rapida, alleati in più.
Ce ne sono in ogni parte del gioco: dalle creature rare, dai trofei, dai Custodi, dalle stagioni, dalle reliquie. [url=cat:oggetti:accessori]Tutti gli accessori[/url]."""},
	{"id": "pozioni", "group": "Creare ed equipaggiarsi", "name": "Pozioni e cibo", "text":
"""All'[b]Alambicco di Linfa[/b] si fanno le pozioni: curano, ridanno Linfa o danno un effetto a tempo (bagliore, scorza, vigore, rigoglio, passo, vista di notte, fortuna, scavo…). Tra una pozione e l'altra bisogna aspettare {potion_cd} secondi.
Al [b]Paiolo di radice[/b] si cucina: il cibo rende [b]sazio[/b] per molti minuti (colpi e corsa un poco più forti, Vita più svelta).
Gli effetti attivi e il tempo che resta sono in alto a destra, sotto la minimappa."""},
	# combattere
	{"id": "combattere", "group": "Combattere", "name": "Combattere", "text":
"""[b]Mischia[/b]: si colpisce a ogni giro dell'arma; la forma decide l'area (il pugnale corto e rapidissimo, lo spadone largo, la lancia lontano in linea, il martello alto, la falce un giro davanti e dietro, la frusta lunghissima).
[b]Archi[/b]: tirano i dardi della Bisaccia verso il mouse.
[b]Bastoni di Linfa[/b]: tenendo premuto tirano incantesimi verso il mouse spendendo Linfa; alcuni attraversano più creature, altri inseguono.
[b]Bastoni evocatori[/b]: chiamano creature alleate che combattono con te.
[b]Da lanciare[/b]: esplosivi (rompono la roccia fino alla loro forza, feriscono anche te se sei vicino), semi ricurvi (tornano in mano), giavellotti.
[b]Rampino[/b]: si aggancia alla roccia e ti tira; si sgancia saltando o con {k_giu}.
Gli [url=cap:elementi]elementi[/url] contano: ogni creatura ha almeno una debolezza.
[b]Il segnale «!»[/b]: prima di caricare, scattare, sputare o lasciar cadere un colpo, sopra la creatura lampeggia un «!» color ambra. È il momento di spostarsi, saltare o schivare.
[b]La schivata[/b] ({k_schiva}): uno scatto breve con un attimo in cui niente ti ferisce. Non c'è di base: la sblocca il [b]Cavigliere di vento[/b] (al Telaio), e la [b]Fascia-lampo[/b] (al Maglio) la ricarica molto più in fretta.

[b]Come ti sentono le creature[/b]: al buio ti vedono meno lontano (chi vive sotto terra no); lo scavo, i colpi, le esplosioni e i passi di corsa si sentono, e chi li sente viene a guardare (un [b]?[/b] sopra la testa); se sei ferito gravemente i predatori ti fiutano da lontano; un'esca in mano attira. Persa di vista, una creatura ti cerca dove ti ha visto l'ultima volta; ferita gravemente, una paurosa fugge. La scheda di una creatura dice che cosa sta facendo.

[b]Le astuzie[/b]: alcune creature hanno un'astuzia (sbucano da sotto, si dividono, rubano, si travestono, parano davanti, curano le compagne, chiamano rinforzi, si attaccano e bevono Linfa, saltano fuori dall'acqua, tendono ragnatele, rodono la terra, temono la luce, guidano un gregge, scoppiano). Ognuna si annuncia prima e ha una contromossa: la scheda della creatura te la dice. Nessuna rompe i blocchi che hai costruito.

[b]Studiare le creature[/b]: ogni specie ha un grado nell'Erbario: vista, sconfitta, studiata. Sconfitta una volta, la sua scheda mostra le debolezze; studiata (una dozzina di sconfitte, tre per i Guardiani e i Signori, o la [b]Provetta[/b] usata su di lei) mostra come si batte, e fai il 6% di danno in più contro di lei, per sempre. Il filo ti propone la specie più vicina a essere studiata."""},
	{"id": "unici", "group": "Creare ed equipaggiarsi", "name": "La collezione degli unici", "text":
"""Gli [b]oggetti unici[/b] hanno un nome, una storia e [b]effetti speciali[/b] che non si trovano altrove: ognuno cambia qualcosa nel modo di giocare. Stanno in [b]serie[/b]: quando l'Erbario le ricorda tutte, la serie completa dà il suo premio [b]per sempre[/b].
Escono dai segreti profondi e leggendari, dalle creature ancestrali e iridate, dagli scrigni antichi delle rovine profonde, dai Custodi e dai Guardiani evocati; alcuni si fabbricano con i trofei delle creature rare. Chi li lascia a caso preferisce quelli che non hai ancora.
{cat_unici}"""},
	{"id": "elementi", "group": "Combattere", "name": "Elementi e reazioni", "text":
"""Sei elementi. Un'arma con un elemento lascia sulla creatura un [b]segno[/b] per qualche secondo e le dà il suo stato:
{cat_elementi}
Se sul segno di un elemento arriva l'elemento giusto nasce una [b]reazione[/b]:
{cat_reazioni}
Le creature sono [b]deboli[/b] ad alcuni elementi (danno ×{weak}) e ne [b]resistono[/b] ad altri (danno ×{resist}): la scheda di una creatura (mouse sopra) lo dice."""},
	{"id": "creature", "group": "Combattere", "name": "Le creature", "text":
"""Le creature vivono in [url=cap:ecologia]famiglie[/url] con un ruolo (erbivori, predatori, colonie, volanti, scavatori, tranquilli). Nascono secondo lo strato, il bioma, la notte, la stagione, gli eventi e i geni del mondo, fuori dalla tua visuale e mai vicino alle torce.
Ogni specie esiste in varianti: [b]taglia[/b], [b]elemento[/b] e [b]indole[/b] (docile, aggressiva…). Le docili non attaccano finché non le colpisci.
[b]Rare[/b]: le [b]antiche[/b] (più forti, con uno o più tratti, contorno acceso; lasciano Essenze e trofei), le [b]ancestrali[/b] (rarissime, più tratti) e le [b]iridate[/b] (non attaccano, fuggono e svaniscono; lasciano la Polvere iridata). I [b]capobranco[/b] guidano un branco.
I [b]trofei[/b] (solo dalle rare) si trasformano in oggetti unici.
[b]Le specie firma[/b]: ogni bioma, ogni bioma del sottosuolo e del cielo ha le sue (una o due), con un modo di combattere che non ha nessun'altra creatura. Sono la ragione per andarci.
[b]Le risvegliate[/b]: dopo il [url=cap:spina]Risveglio del Cuore[/url], in ogni bioma e in ogni strato nascono creature nuove e più forti: saltano a molla, rotolano, ricadono dall'alto scuotendo il terreno, chiamano piogge di colpi, girano attorno, si sdoppiano.
[b]Gli stendardi[/b]: ogni cinquanta creature di una famiglia sconfitte ne cade lo [b]stendardo[/b]. Issato (clic), vale per sempre e ovunque: contro quella famiglia fai il 10% di danno in più e prendi il 10% di ferite in meno. Al Telaio, con lo stendardo e un trofeo di ogni specie della famiglia, si fa lo [b]stendardo d'oro[/b] (+20% e −18%).
[url=cat:creature]Tutte le creature[/url] · [url=cat:famiglie]tutte le famiglie[/url]."""},
	{"id": "guardiani", "group": "Combattere", "name": "I Guardiani e il Cuore", "text":
"""In fondo a ogni mondo c'è la cupola del [b]Cuore del mondo[/b], malato, difeso da un [b]Guardiano[/b] che si sveglia quando entri. Nel Fondo un battito ti dice da che parte è il Cuore.
Un Guardiano si può [b]sconfiggere[/b] (lascia i suoi frammenti; l'Avvizzimento si ferma) o [b]curare[/b]: versa la [b]Rugiada di Linfa[/b] sui quattro nodi avvizziti attorno al Cuore. Curato, lascia la sua Linfa, ti dona +20 Vita per sempre (una volta per mondo) e l'Avvizzimento si ritira.
Poi il Cuore guarisce e ti dà un [url=cap:semi]Seme di mondo[/url].
{cat_guardiani}"""},
	{"id": "custodi", "group": "Combattere", "name": "I Custodi degli strati", "text":
"""Negli strati profondi dormono i [b]Custodi[/b] dentro grandi bozzoli: si svegliano quando ti avvicini. Sconfitti, lasciano i loro oggetti e un [b]richiamo[/b]. All'[b]Altare dei Seminatori[/b], con il richiamo in mano, si risveglia di nuovo un Custode già sconfitto.
{cat_custodi}"""},
	# la vita del mondo
	{"id": "ecologia", "group": "La vita del mondo", "name": "L'ecologia", "text":
"""Le creature non sono solo nemici: ogni zona del mondo ha le sue [b]popolazioni[/b]. I predatori [b]cacciano[/b] le prede, gli erbivori [b]pascolano[/b] le piante, le famiglie hanno [b]nidi[/b] e alcune [b]migrano[/b] con le stagioni.
[b]Nidi[/b] (clic destro): prendi un uovo (da far schiudere nell'Incubatrice), nutri il nido (le uova si schiudono prima) o distruggilo.
Cacciare troppo una specie la fa diminuire in quella zona; lasciarla in pace la fa tornare."""},
	{"id": "mandria", "group": "La vita del mondo", "name": "La mandria", "text":
"""Molte famiglie si possono [b]addomesticare[/b]. Tre modi:
• il [b]cibo[/b] della sua famiglia (clic destro con il cibo in mano) su una creatura che si fida: docile e mai colpita, oppure affamata, stordita o indebolita. Ogni pasto dà affetto; a 100 è tua. La dieta la scopri dandole il cibo giusto o dopo averne sconfitte alcune;
• il [b]Laccio[/b] su una creatura stremata (meno del 40% della Vita);
• le [b]uova[/b] nell'[b]Incubatrice[/b], che si schiudono in vasetti con la creatura già tua.
Dal 2 ott 2026 ogni creatura (tranne i boss) si lega: vedi [url=cap:legare]Legare le creature[/url] e [url=cap:compagni_battaglia]I compagni di battaglia[/url].
Le creature della mandria stanno nel personaggio e passano da un mondo all'altro. Cinque possono stare nella [b]Sacca dei legami[/b] (una in campo combatte con il suo stile e ti dà il suo dono), vivere in un [b]Recinto[/b] (mangia dalla mangiatoia e produce: lana, seta, miele…) o [b]riposare[/b] nel Giardino. Crescono di livello combattendo, mangiando e producendo. Alcune si [b]cavalcano[/b] ({k_cavalca}). Il [b]Vasetto[/b] porta una creatura come oggetto.
Tutto nel pannello Mandria ({k_mandria}). Vedi anche [url=cap:allevamento]Allevamento[/url]."""},
	{"id": "allevamento", "group": "La vita del mondo", "name": "L'allevamento", "text":
"""Due creature della stessa famiglia, messe in [b]coppia[/b] nel pannello Mandria, nello stesso recinto, sazie e contente, dopo un po' fanno un [b]uovo[/b] nella mangiatoia.
Il figlio prende specie, taglia, elemento e indole da uno dei genitori; le [b]doti[/b] (vita, danno, resa) dalla media dei due con un po' di caso; il [b]manto[/b] secondo regole proprie: alcuni manti rari nascono solo da certe coppie. Prima di decidere, il pannello mostra che cosa può nascere da una coppia."""},
	{"id": "compagni", "group": "La vita del mondo", "name": "Compagni e alleati", "text":
"""Un [b]compagno[/b] ti segue (uno alla volta; si chiama e si congeda con il clic sul suo oggetto) e ti fa un dono: attira gli oggetti da più lontano, fa ricrescere la Linfa, fa luce.
Gli [b]alleati[/b] dei bastoni evocatori combattono per te finché non appassisci; il più vecchio lascia il posto al nuovo."""},
	{"id": "abitanti", "group": "La vita del mondo", "name": "Gli abitanti", "text":
"""Gli abitanti arrivano quando c'è un [b]Focolare[/b] con un letto libero vicino e la loro condizione è rispettata (un banco, dei Custodi sconfitti, uno stadio dell'Albero-Madre…). Nel Giardino alcuni arrivano con gli stadi dell'Albero.
Clic destro: [b]commercio[/b] in Lumini (vendi ciò che hai in mano, o Maiusc+clic su una casella). Ognuno ha un mestiere e merci sue.
[b]Affetto[/b]: cresce con i doni (molto di più con ciò che gli piace) e con le sue richieste. Ogni livello (un cuore) dà uno sconto; a certi livelli un regalo. Ogni abitante ha tre richieste in fila.
[b]I servizi[/b]: ogni abitante sa fare una o due cose che nessun altro fa, pagate in [b]Lumini[/b]. Si vedono a sinistra del commercio, con il prezzo e quante volte si possono chiedere oggi. Alcuni esempi:
• la Viandante segna sulla mappa i tre segreti più vicini; la Vecchia Radice dice dov'è la firma del mondo;
• il Forgiatore alza la qualità dell'oggetto che tieni in mano; il Fabbro delle radici lo tempra senza Schegge;
• il Mercante di Semi fa un Seme di mondo con il gene della Fiala che tieni in mano, e legge i geni nascosti di un Seme; l'Innestatrice estrae una Fiala da un Seme;
• il Mandriano addestra il tuo compagno e sfama tutta la mandria; il Pescatore dà fortuna alla canna; il Pellegrino e la Cantastorie traducono parole dei Seminatori;
• la Tessitrice riempie le riserve della rete; il Cartografo segna Sigilli e reliquiari; il Cacciatore scrive taglie nuove.
Ciò che non riesce non si paga. Ogni servizio fa crescere un poco l'affetto.
{cat_abitanti}"""},
	{"id": "effetti", "group": "Creare ed equipaggiarsi", "name": "Effetti speciali e oggetti unici", "text":
"""Alcuni oggetti non sono solo più forti: [b]fanno qualcosa[/b]. Gli [b]effetti speciali[/b] (✦ nella scheda) scattano a ogni colpo o ogni tanti colpi, quando sconfiggi una creatura, quando sei ferito, quando la Vita finirebbe, oppure valgono finché è vera una condizione (di notte, nell'acqua, sotto terra, da fermo, con poca Vita) o di continuo attorno a te. Valgono indossati (armature, accessori) o in mano (armi).
{cat_effetti}
Gli [b]oggetti unici[/b] sono scritti a mano, ognuno con la sua storia e i suoi effetti: il nome dorato, e un posto preciso dove si trovano. I primi li lasciano, a volte, i Guardiani evocati al [url=cap:evocazioni]Cerchio dei Seminatori[/url]."""},
	{"id": "equipaggiamento", "group": "Creare ed equipaggiarsi", "name": "I dieci posti dell'equipaggiamento", "text":
"""Nella Bisaccia aperta, a sinistra, ci sono [b]dieci posti[/b]: elmo, corazza, gambali e stivali; guanti, mantello, amuleto e anello; due accessori.
• [b]Guanti[/b], [b]stivali[/b] e [b]mantello[/b] si fanno al Maglio con ogni metallo, lega o materiale dei geni, come le armature: i guanti rendono i colpi più rapidi e lo scavo più svelto, gli stivali allungano corsa e salto, il mantello fa ricrescere la Vita più in fretta; tutti danno un po' di Scorza. Più il metallo è di grado alto, più rendono.
• [b]Amuleti[/b] e [b]anelli[/b] si fanno alla Mola del gemmaio: una gemma incastonata in un metallo. L'amuleto dà la qualità della gemma, l'anello il suo [url=cap:effetti]effetto speciale[/url]; la montatura aggiunge il [url=cap:materiali]carattere[/url] del suo metallo (metà nell'amuleto, tre decimi nell'anello):
{cat_gemme}
• I [b]set dei metalli[/b] sono di cinque pezzi: elmo, corazza, gambali, guanti e stivali dello stesso metallo.

[b]Il risveglio[/b]
Al [b]Maglio dei Seminatori[/b], con l'oggetto in mano, la prima lavorazione è [b]Risveglia[/b]: una volta sola, l'arma o il pezzo d'armatura prende il [b]modo della sua forma[/b] e diventa più forte (+12% di danno, o +2 di Scorza). Il nome si segna con ✦.
• Spada: [i]Lama del vento[/i], ogni terzo colpo un'onda vola dritta e attraversa tre creature.
• Pugnale: [i]Mille tagli[/i], ogni colpo apre una ferita che sanguina, e le ferite si sommano.
• Spadone: [i]Schianto[/i], ogni terzo colpo ferisce e spinge via chi sta attorno.
• Lancia: [i]Trafittura[/i], ogni colpo raggiunge anche chi sta dietro, in fila.
• Martello: [i]Terremoto[/i], ogni quarto colpo stordisce tutto attorno a te.
• Falce: [i]Mietitura larga[/i], un colpo su due raggiunge altre due creature.
• Frusta: [i]Strappo[/i], tira la creatura verso di te.
• Arco e balestra: [i]Dardo che si divide[/i], un colpo su due si divide in tre schegge.
• Bastoni e verghe: [i]Eco di Linfa[/i], ogni creatura sconfitta rende Linfa.
• Armatura: elmo [i]Occhio vigile[/i], corazza [i]Scorza di rovo[/i], gambali [i]Gambe leste[/i], guanti [i]Presa viva[/i], stivali [i]Passo che slancia[/i], mantello [i]Mantello di nebbia[/i].
Costa sei pezzi del [url=cap:strati]materiale del profondo[/url] del grado del metallo e una Linfa antica:
• radicite e legnoferro: il Midollo di radice;
• ambra: il Cuore d'ardesia;
• Linfa: la Linfa nera;
• vuotite e stellare: il Frammento di Vuoto.
Esamina dice, per ogni oggetto, che modo prenderebbe e quanto costa.

[b]La qualità conta[/b]: un oggetto grezzo fa l'85% del danno, uno fine il 112%, un capolavoro il 130%. La qualità si sale rifondendo due doppioni al Maglio, o con la [b]Rifinitura[/b] del Forgiatore (un servizio pagato in Lumini)."""},
]
