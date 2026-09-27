class_name EncyCraftData
## Enciclopedia (27 set 2026), seconda parte: creare ed equipaggiarsi, combattere, la vita del mondo.
## Stesso formato di `EncyGuideData`.

const CHAPTERS := [
	{"id": "creare", "group": "Creare ed equipaggiarsi", "name": "Creare", "text":
"""Il pannello [b]Creare[/b] è in alto a sinistra della Bisaccia aperta. Mostra le ricette dei [b]banchi[/b] a portata (entro {craft_reach} tessere) e quelle che si fanno a mano; con «Anche i banchi lontani» anche le altre, per sapere cosa serve e dove.
• A sinistra le categorie colorate, ognuna con «possibili / tutte»; sopra la ricerca per nome o per ingrediente e «Solo possibili». In fondo alle categorie, le [b]Lavorazioni[/b] del Maglio e del Telaio sull'oggetto in mano (tratti, innesti, fasce), quando ce ne sono.
• Ogni ricetta è una casella con l'icona e, sotto, una barra: quanto hai già degli ingredienti (piena e verde = si può fare).
• [b]Clic[/b] la sceglie: nella colonna [b]Esamina[/b], a destra, compaiono il banco, gli ingredienti con «ne hai / ne servono», la quantità (−, +, Max) e il pulsante [b]Crea[/b]. [b]Doppio clic[/b] crea subito una volta, [b]Maiusc+clic[/b] cinque.
• Gli ingredienti vengono dalla Bisaccia e dalle [url=cap:casse]casse vicine[/url].
I banchi:
{cat_banchi}
Le ricette delle [b]leghe[/b] si scoprono trovando i loro materiali (vedi [url=cap:materiali]Materiali[/url])."""},
	{"id": "materiali", "group": "Creare ed equipaggiarsi", "name": "Materiali e leghe", "text":
"""Armi, attrezzi e armature nascono da una [url=cap:forme]forma[/url] e da un [b]materiale[/b]. Il materiale ha delle proprietà: [b]durezza[/b] (forza del piccone, difesa), [b]filo[/b] (danno), [b]peso[/b] (lento o veloce), [b]tenacia[/b], [b]conduzione[/b] (i bastoni), a volte un [url=cap:elementi]elemento[/url] e la [b]risonanza[/b] (posti d'innesto in più).
Le [b]leghe[/b] uniscono due metalli al Baccello ardente e ne mescolano le proprietà (e gli elementi, che si alternano a ogni colpo). I materiali dei [url=cap:geni]geni[/url] si trovano solo nei mondi con quel gene.
{cat_materiali_breve}
Il catalogo completo: [url=cat:materiali]tutti i materiali[/url]."""},
	{"id": "forme", "group": "Creare ed equipaggiarsi", "name": "Le forme", "text":
"""La forma decide come si usa un oggetto: la sua area di colpo, la velocità, a che cosa serve. Ogni forma esiste in ogni materiale.
{cat_forme}"""},
	{"id": "qualita", "group": "Creare ed equipaggiarsi", "name": "La qualità", "text":
"""Ogni arma, attrezzo e armatura nasce con una [b]qualità[/b]: {cat_qualita}. La qualità cambia i valori e dà posti d'innesto in più. Al [b]Maglio dei Seminatori[/b] escono più spesso le qualità alte; la fortuna aiuta."""},
	{"id": "tratti", "group": "Creare ed equipaggiarsi", "name": "Tratti e innesti", "text":
"""Un oggetto può nascere con un [b]tratto[/b] (Spina: +15% danno; Vento: colpi più rapidi…). Al Maglio si [b]rinnova[/b] il tratto (sempre diverso dal vecchio) pagando materiali.
Le [b]Essenze[/b] (lasciate dalle creature antiche, una per tratto delle antiche) si [b]innestano[/b] al Maglio: ogni oggetto ha dei [b]posti d'innesto[/b] (uno in più per ogni qualità sopra «buono» e per la risonanza del materiale, al massimo {max_slots}). Un innesto si può togliere, perdendo l'Essenza.
I suggerimenti mostrano i tratti in rosso quando peggiorano l'oggetto.
Tutti i tratti: [url=cat:tratti]catalogo dei tratti[/url]."""},
	{"id": "fasce", "group": "Creare ed equipaggiarsi", "name": "Le fasce del Telaio", "text":
"""Al [b]Telaio di foglie[/b] si avvolge una [b]fascia[/b] sul manico di un'arma o di un attrezzo: cambia un poco i suoi valori (più spinta, più velocità, più danno…) e prende il posto della fascia di prima.
{cat_fasce}"""},
	{"id": "set", "group": "Creare ed equipaggiarsi", "name": "I set", "text":
"""Elmo, corazza e gambali dello stesso metallo (o le vesti e le coppie di accessori dello stesso set) dati insieme danno un [b]bonus di set[/b]. La scheda di un pezzo dice quanti pezzi del set indossi.
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
Gli [url=cap:elementi]elementi[/url] contano: ogni creatura ha almeno una debolezza."""},
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
Le creature della mandria stanno nel personaggio e passano da un mondo all'altro. Ognuna può [b]seguirti[/b] (combatte, ti dà il suo dono, va nutrita), vivere in un [b]Recinto[/b] (mangia dalla mangiatoia e produce: lana, seta, miele…) o [b]riposare[/b] nel Giardino. Crescono di livello combattendo, mangiando e producendo. Alcune si [b]cavalcano[/b] ({k_cavalca}). Il [b]Vasetto[/b] porta una creatura come oggetto.
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
{cat_abitanti}"""},
	{"id": "effetti", "group": "Creare ed equipaggiarsi", "name": "Effetti speciali e oggetti unici", "text":
"""Alcuni oggetti non sono solo più forti: [b]fanno qualcosa[/b]. Gli [b]effetti speciali[/b] (✦ nella scheda) scattano a ogni colpo o ogni tanti colpi, quando sconfiggi una creatura, quando sei ferito, quando la Vita finirebbe, oppure valgono finché è vera una condizione (di notte, nell'acqua, sotto terra, da fermo, con poca Vita) o di continuo attorno a te. Valgono indossati (armature, accessori) o in mano (armi).
{cat_effetti}
Gli [b]oggetti unici[/b] sono scritti a mano, ognuno con la sua storia e i suoi effetti: il nome dorato, e un posto preciso dove si trovano. I primi li lasciano, a volte, i Guardiani evocati al [url=cap:evocazioni]Cerchio dei Seminatori[/url]."""},
]
