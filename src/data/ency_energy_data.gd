class_name EncyEnergyData
## Enciclopedia, ottava parte (Roadmap 19 «La Linfa che scorre», voce 210): la rete del Flusso e dell'Impulso, le
## macchine, la logica, le Centrali dei Seminatori, la Tempesta di Linfa e ciò che vive attorno alle vene.
## Stesso formato di `EncyGuideData`; i cataloghi {cat_rete_…} li scrive `EncyEnergy`.

const CHAPTERS := [
	{"id": "rete", "group": "La Linfa che scorre", "name": "La rete: Flusso e Impulso", "text":
"""La Linfa del mondo si può far scorrere. Due reti, due cose diverse:
• il [url=cap:rete_flusso]Flusso[/url] porta [b]energia[/b] lungo le [url=cap:rete_vene]vene[/url]: le [b]sorgenti[/b] la danno, le [b]riserve[/b] la tengono, le [b]macchine[/b] la usano;
• l'[url=cap:rete_impulso]Impulso[/url] porta [b]comandi[/b] lungo i fili di quattro colori: una leva, un sensore o un nodo accendono e spengono ciò che il filo tocca.
Il primo corredo lo dona l'Albero-Madre al suo secondo stadio: il [url=cap:guida]filo[/url] ti porta passo passo al primo circuito (Tamburo, vena, Otre, Lampada, Leva). Le macchine si fanno al Ceppo, al Baccello ardente e al Maglio (categoria «Linfa e macchine» di Creare)."""},
	{"id": "rete_vene", "group": "La Linfa che scorre", "name": "Le vene e la Pinza", "text":
"""Le vene si posano con la [url=item:pinza_vene]Pinza delle vene[/url]: clic e trascina per una linea, clic destro per riprendere, {k_confronta}+rotella per scegliere che cosa posare. Passano anche dentro la roccia, e scavando non si tagliano.
Ogni grado porta una quantità diversa di Linfa (i [b]pulsi[/b]):
{cat_rete_vene}
Una macchina prende al più la portata della vena più stretta sulla strada dalla sorgente fino a lei: una sola vena di radice in mezzo a vene d'ambra strozza tutto.
Due vene di grado diverso che si toccano si collegano; l'[url=item:isolante_resina]Isolante di gelatina[/url] le separa (così due reti si incrociano), e protegge la vena dalla [url=cap:rete_tempesta]Tempesta[/url] e dai [url=cap:rete_creature]Succhiavena[/url].
Le vene del Flusso si vedono sempre; i fili solo con la Pinza o con l'[url=item:occhio_vene]Occhio delle vene[/url] in mano (o con l'opzione «mostra i fili»)."""},
	{"id": "rete_flusso", "group": "La Linfa che scorre", "name": "Sorgenti, riserve e macchine", "text":
"""Ogni quarto di secondo ogni rete fa il conto: quanto danno le sorgenti, quanto chiedono le macchine, quanto entra ed esce dalle riserve. Se la Linfa non basta, le macchine a priorità alta (nel pannello, clic destro) la prendono per prime.
[b]Le sorgenti[/b]
{cat_rete_sorgenti}
[b]Le riserve[/b]
{cat_rete_riserve}
[b]Mentre sei via[/b] la rete lavora a metà velocità, al più per due ore; a piena velocità se il portale del suo mondo, nel Giardino, sta su una rete viva di almeno 20 pulsi (un'[b]Aiuola alimentata[/b])."""},
	{"id": "rete_macchine", "group": "La Linfa che scorre", "name": "Le macchine", "text":
"""Le macchine chiedono i loro pulsi a ogni conto; con meno Linfa lavorano più piano o si fermano (la scheda dice perché). Quelle con una cassetta (combustibile, materiali, piccone) la aprono dal pannello.
{cat_rete_macchine}
Nelle stanze, la Fontana di Linfa e la Teca d'esposizione contano come mobili belli."""},
	{"id": "rete_impulso", "group": "La Linfa che scorre", "name": "L'Impulso: fili e comandi", "text":
"""I fili dello stesso colore che si toccano fanno una rete del filo; i quattro colori passano nella stessa tessera senza toccarsi. Un filo è [b]acceso[/b] se almeno un comando che lo tocca è acceso; un [b]colpo[/b] (pulsante, orologio) è un istante.
Ogni macchina reagisce secondo la sua [b]reazione[/b] (nel pannello): «segue» (accesa finché il filo è acceso) o «alterna» (ogni accensione la alterna). Una macchina senza fili la comanda il suo pannello.
[b]I comandi e i sensori[/b]
{cat_rete_comandi}
Le trappole toccate da un filo sono armate solo finché il filo è acceso."""},
	{"id": "rete_logica", "group": "La Linfa che scorre", "name": "I nodi della logica", "text":
"""Un nodo tocca fili di colori diversi: uno è la sua [b]uscita[/b] (nel pannello; all'inizio il colore più alto), gli altri sono gli [b]ingressi[/b]. L'uscita cambia sempre un passo dopo, così un circuito chiuso su se stesso oscilla invece di bloccare il mondo.
{cat_rete_nodi}
[b]Qualche idea[/b]: un Occhio di luce e un nodo NON accendono le lampade al tramonto; un Orecchio di muschio e una Campana fanno l'allarme; un Orologio, qualche nodo del ritardo e i Carillon suonano una melodia; un Sensore di cassa accende il Baccello di brace solo quando c'è minerale; un Sensore di riserva accende una sorgente di scorta."""},
	{"id": "rete_centrali", "group": "La Linfa che scorre", "name": "Le Centrali dei Seminatori", "text":
"""Nelle Caverne d'ardesia e più giù ogni mondo nasconde da tre a sei [b]Centrali dei Seminatori[/b] (più nei mondi vigorosi, due in più con il gene [url=gene:vene_mondo]Vene del mondo[/url]): sale di pietra con un enigma di Linfa.
• il [b]Cuore della centrale[/b] dorme: un [url=item:cristallo_linfa]cristallo di Linfa[/url] (clic destro) lo sveglia;
• la vena d'ambra del pavimento è spezzata in tre punti: lo scrigno all'ingresso ha le vene e la Pinza;
• tre leve, con fili di tre colori, arrivano a un nodo E: alzate tutte, il filo viola apre la porta della sala interna (se la rete ha Linfa).
La prima volta che la porta si apre la Centrale dona un progetto dei Seminatori, uno degli [b]Ingegni dei Seminatori[/b] (una serie di oggetti unici) e Linfa antica.
Un mondo può avere come firma [b]la Centrale intatta[/b]: il cuore batte ancora, le vene sono sane, e nella sala interna c'è lo scrigno della firma."""},
	{"id": "rete_tempesta", "group": "La Linfa che scorre", "name": "La Tempesta di Linfa e i geni della rete", "text":
"""Nei mondi con una rete, qualche giorno la Linfa ribolle: la [b]Tempesta di Linfa[/b]. Le sorgenti danno il 50% in più, le [url=cr:lucciola_vena]Lucciole di vena[/url] escono a sciami, ma ogni tanto una vena di radice o di legnoferro di una rete che scorre si spezza. Una [url=item:valvola_sfogo]Valvola di sfogo[/url] sulla rete la protegge; le vene isolate con la gelatina non si spezzano.
[b]I geni della rete[/b]:
• [url=gene:sole_linfa]Sole di Linfa[/url]: le Foglie-lanterna danno il 50% in più;
• [url=gene:vento_perenne]Vento perenne[/url]: i Mulini girano sempre almeno all'80%;
• [url=gene:terra_conduce]Terra che conduce[/url]: ogni vena porta il 50% in più;
• [url=gene:tempeste_linfa]Tempeste di Linfa[/url]: Tempeste sei volte più frequenti;
• [url=gene:vene_mondo]Vene del mondo[/url]: due Centrali dei Seminatori in più."""},
	{"id": "rete_creature", "group": "La Linfa che scorre", "name": "Chi vive attorno alle vene", "text":
"""• Il [url=cr:succhiavena]Succhiavena[/url] (Sottobosco e Caverne) fiuta le vene di radice e le beve: la vena sparisce, i fili restano. Le vene di legnoferro e più dure non le tocca, e nemmeno quelle isolate. Lascia la [url=item:linfa_rappresa]Linfa rappresa[/url], che serve alla Valvola di sfogo.
• La [url=cr:lucciola_vena]Lucciola di vena[/url] è innocua: volteggia sopra le vene e lascia la [url=item:luce_vena]Luce di vena[/url] (Lampade, Ampolla di lucciole).
• La [b]Tessitrice di vene[/b] arriva al Focolare quando un mondo ha quattro macchine: vende vene, fili e pezzi della rete, e ha tre richieste per te.
• La [b]Bacheca[/b] chiede anche cose della rete, e ci sono obiettivi per le macchine e per le Centrali."""},
]
