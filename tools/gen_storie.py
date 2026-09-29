import io
# abitante -> (titoli e capitoli [titolo, richiesta, requisito, premio, scena], merce finale)
# requisito: ("item", id, n) o ("stat", nome, n)
S = {
 "viandante": ([
  ["La strada di casa", "Portami trenta torce: la strada che faccio ogni notte è buia.", ("item", "torcia", 30), {"lumino": 120},
   "«Ogni torcia che pianto è una casa per un'ora», dice. «Poi riparto.»"],
  ["I tre mondi", "Visita cinque mondi: voglio sapere se ci sono ancora le strade che ricordo.", ("stat", "viaggi", 5), {"mappa_seminatori": 1},
   "Le racconti dei mondi e lei ride: «Le strade cambiano. Chi le cammina, no.»"],
  ["La bisaccia leggera", "Una cesta: la mia bisaccia non basta più.", ("item", "cesta", 1), {"pozione_rugiada": 5},
   "Riempie la cesta con cura. «Mi fermo un po'», dice, e sembra sorpresa lei stessa."],
  ["Il nome del viandante", "Trova due firme: una volta ne vidi una, e non ricordo dove.", ("stat", "firme", 2), {"linfa_antica": 1},
   "«Era questa», sussurra davanti al ricordo. «Ci sono passata da bambina. Allora avevo un nome diverso.»"],
  ["Restare", "Dieci pozioni di rugiada, per chi arriva stanco.", ("item", "pozione_rugiada", 10), {"lumino": 400},
   "Appende la sua bisaccia accanto al letto. «Il Giardino è l'ultimo mondo della mia strada. E il primo.»"],
 ], ["radice_uncino", 1]),
 "erborista": ([
  ["Foglie e radici", "Dieci funghi luminosi: le mie pozioni ne hanno bisogno.", ("item", "fungo_luminoso", 10), {"pozione_bagliore": 3},
   "Li schiaccia nel mortaio e l'aria si fa turchese. «Ecco. Ora respira.»"],
  ["L'orto delle cure", "Raccogli trenta colture: voglio sapere che cosa cresce qui.", ("stat", "raccolti", 30), {"pozione_rigoglio": 3},
   "«La tua terra è buona», dice annusandola. «Chi la cura, la rende così.»"],
  ["Il fiore che non c'è", "Semina quaranta colture diverse volte.", ("stat", "semine", 40), {"seme_campanula": 6},
   "Tra le file dell'orto trova un fiore che non aveva mai visto. Lo disegna, e sorride."],
  ["La pozione perduta", "Cinque sete di radice.", ("item", "seta_radice", 5), {"pozione_passo": 3},
   "«Mia madre la faceva così», dice mescolando. «L'avevo dimenticata. Grazie di avermela fatta ricordare.»"],
  ["La serra", "Una stanza serra nel Giardino.", ("stat", "stanza_serra", 1), {"lumino": 400},
   "Passa la notte nella serra. La mattina dopo ha le mani verdi e gli occhi lucidi."],
 ], ["pozione_vigore", 3]),
 "forgiatore": ([
  ["Il canto del Maglio", "Dieci lingotti di legnoferro.", ("item", "lingotto_legnoferro", 10), {"polvere_brace": 5},
   "Batte il primo colpo e il Maglio risponde. «Senti? Si ricorda di me.»"],
  ["Le armi dei Custodi", "Sconfiggi due Custodi.", ("stat", "custodi", 2), {"lingotto_ambra": 3},
   "Esamina le tue armi graffiate. «Hanno combattuto bene. Anche tu.»"],
  ["L'ambra che canta", "Otto lingotti d'ambra.", ("item", "lingotto_ambra", 8), {"baccello_tonante": 3},
   "L'ambra fonde e per un attimo dentro si vede un insetto antico. «Tutto torna», dice."],
  ["La tempra", "Sconfiggi un Signore dei luoghi.", ("stat", "signori", 1), {"polvere_iridata": 1},
   "«Un'arma si tempra nel fuoco», dice, «chi la porta, contro chi la sfida.»"],
  ["L'ultima lama", "Cinque cristalli di Linfa.", ("item", "cristallo_linfa", 5), {"lumino": 450},
   "Forgia una lama sottile e te la mostra, poi la appende al muro. «Questa è per il Giardino. Non per la guerra.»"],
 ], ["lingotto_linfa", 2]),
 "vecchia_radice": ([
  ["Le radici ricordano", "Raccontami un mondo: visitane tre.", ("stat", "viaggi", 3), {"lumino": 100},
   "«L'Albero sente ogni mondo che attraversi», dice. «Io sento l'Albero.»"],
  ["La prima Linfa", "Tre Linfe antiche.", ("item", "linfa_antica", 3), {"provetta": 5},
   "Ne beve una goccia e chiude gli occhi. «Sapeva di pioggia, il giorno che ci piantarono.»"],
  ["Le parole dell'Albero", "Leggi quindici stele.", ("stat", "stele", 15), {"tavoletta_seminatori": 2},
   "«I Seminatori scrivevano sulle pietre», dice, «l'Albero lo scrive nel legno. È la stessa lingua.»"],
  ["Le mie radici", "Risolvi i Guardiani di quattro mondi.", ("stat", "guardiani", 4), {"linfa_antica": 2},
   "Per la prima volta ti mostra le sue radici: sono intrecciate a quelle dell'Albero-Madre."],
  ["Il seme della Vecchia Radice", "Guarisci un Albero perduto.", ("stat", "perduti", 1), {"lumino": 500},
   "«Io ero un seme di uno di loro», confessa. «Non l'ho mai detto a nessuno. Ora posso tornare a trovarlo.»"],
 ], ["linfa_antica", 1]),
 "mercante_semi": ([
  ["Il seme raro", "Impara cinque geni.", ("stat", "geni_imparati", 5), {"seme_mondo_mosaico": 1},
   "«Chi conosce i geni, conosce i mondi», dice sfogliando il suo quaderno."],
  ["Il catalogo", "Innesta due Semi.", ("stat", "innesti", 2), {"linfa_antica": 1},
   "Annota i tuoi innesti in una pagina nuova. «Questo non l'avevo mai visto.»"],
  ["La mutazione", "Fai nascere un Seme mutato.", ("stat", "mutazioni", 1), {"fiala_fertile": 1},
   "Tiene il Seme controluce per un'ora intera. «È nato qualcosa che non c'era.»"],
  ["Il mercante di mondi", "Visita dieci mondi.", ("stat", "viaggi", 10), {"linfa_antica": 2},
   "«Un tempo li vendevo, i mondi», dice. «Poi ho capito che si possono solo piantare.»"],
  ["L'ultimo seme", "Impara venticinque geni.", ("stat", "geni_imparati", 25), {"lumino": 500},
   "Ti regala il suo quaderno. «Ora ne sai più di me. Continua tu.»"],
 ], ["fiala_vene_ricche", 1]),
 "mandriano": ([
  ["La prima bestia", "Addomestica tre creature.", ("stat", "addomesticate", 3), {"laccio": 1},
   "Accarezza la tua creatura. «Si fida di te. Non tradirla.»"],
  ["Il recinto", "Venti prodotti della mandria.", ("stat", "prodotti", 20), {"vasetto": 3},
   "«Una bestia contenta dà di più», dice, «e tu dormi meglio.»"],
  ["Le uova", "Due uova schiuse.", ("stat", "schiuse", 2), {"laccio": 2},
   "Il piccolo ti segue ovunque. Il Mandriano ride: «Ti ha scelto.»"],
  ["La cavalcata", "Cavalca dieci volte.", ("stat", "cavalcate", 10), {"polvere_iridata": 1},
   "«Correre insieme a una bestia è l'unico modo di capirla», dice."],
  ["Il manto raro", "Fai nascere un manto raro.", ("stat", "manti_rari", 1), {"lumino": 500},
   "Guarda il manto nuovo in silenzio. «Mio padre ne aspettò uno per tutta la vita.»"],
 ], ["vasetto", 5]),
 "pescatore": ([
  ["L'acqua ascolta", "Pesca quaranta pesci.", ("stat", "pesci", 40), {"esca_petali": 10},
   "«L'acqua ti ha sentito», dice. «Ora ti risponde.»"],
  ["Le specie", "Pesca venti specie.", ("stat", "specie_pescate", 20), {"esca_squama": 10},
   "Ti mostra il suo quaderno di pesci. Il tuo è già più lungo."],
  ["Il grande", "Pesca un pesce leggendario.", ("stat", "pesci_leggendari", 1), {"amo_ambra": 1},
   "Lo guarda a lungo, poi ti chiede di liberarlo. Lo fai. Lui annuisce."],
  ["Il lago di Linfa", "Dieci perle di stagno.", ("item", "perla_stagno", 10), {"esca_iridata": 10},
   "Le infila in una collana. «Per mia figlia», dice, e non aggiunge altro."],
  ["L'ultimo lancio", "Pesca quaranta specie.", ("stat", "specie_pescate", 40), {"lumino": 500},
   "Ti regala la sua canna più vecchia. «Ha pescato per cinquant'anni. Ora pesca con te.»"],
 ], ["esca_iridata", 10]),
 "palombara": ([
  ["Il respiro", "Pesca venti pesci: sotto il sole o sotto la luna, basta che siano venti.", ("stat", "pesci", 20), {"esca_squama": 5},
   "«Sott'acqua si impara a stare fermi», dice. «È la cosa più difficile.»"],
  ["Il fondo del lago", "Dieci gusci del lago.", ("item", "guscio_lago", 10), {"goccia_acqua_viva": 5},
   "Costruisce una piccola vasca e ci mette i gusci. «Così mi sento a casa.»"],
  ["La perla", "Una perla delle maree.", ("item", "perla_maree", 1), {"linfa_antica": 2},
   "La tiene sul palmo e canta piano. Non avevi mai sentito quella lingua."],
  ["Il mare lontano", "Pesca sessanta specie.", ("stat", "specie_pescate", 60), {"esca_iridata": 20},
   "«Ci sono mari che nessuno ha visto», dice, «e tu li stai vedendo tutti.»"],
  ["Tornare a galla", "Quindici gocce d'acqua viva.", ("item", "goccia_acqua_viva", 15), {"lumino": 500},
   "Si siede sulla riva e respira a lungo. «L'aria non mi pesa più», dice."],
 ], ["amo_ambra", 1]),
 "fabbro_radici": ([
  ["Il ferro vivo", "Quindici ingranaggi di radice.", ("item", "ingranaggio_radice", 15), {"vena_ambra": 20},
   "Monta gli ingranaggi e li fa girare una volta. «Sentono la Linfa. Come noi.»"],
  ["La rete grande", "Venti macchine in un mondo.", ("stat", "macchine", 20), {"vena_cristallo": 10},
   "Cammina lungo le tue vene con l'orecchio a terra. «Canta bene, la tua rete.»"],
  ["Le Centrali", "Risveglia cinque Centrali.", ("stat", "centrali", 5), {"linfa_antica": 2},
   "«I Seminatori non volevano far lavorare gli Alberi», dice. «Volevano farli cantare insieme. Qualcuno sbagliò.»"],
  ["La spola", "Una spola viva.", ("item", "spola_viva", 1), {"polvere_iridata": 2},
   "La fa girare tra le dita. «Questa tesse da sola da cent'anni. Lasciamola riposare.»"],
  ["Il canto", "Cinquanta macchine in un mondo.", ("stat", "macchine", 50), {"lumino": 500},
   "Accende tutto insieme e il Giardino si illumina. «Ecco. Così doveva essere.»"],
 ], ["nodo_memoria", 2]),
 "guardaboschi": ([
  ["Le tracce", "Addomestica cinque creature.", ("stat", "addomesticate", 5), {"laccio": 2},
   "«Una bestia si avvicina a chi non ha fretta», dice."],
  ["I rovi", "Venti bacche di rovo.", ("item", "bacca_rovo", 20), {"marmellata_rovo": 4},
   "Ne mangia una e fa una smorfia. «Aspre. Come il Re dei rovi.»"],
  ["Il cuore di rovo", "Un cuore di rovo.", ("item", "cuore_rovo", 1), {"linfa_antica": 2},
   "Lo pianta in un vaso. Il giorno dopo ha già una foglia."],
  ["La radura", "Quattro uova dalle coppie del recinto.", ("stat", "uova_allevate", 4), {"polvere_iridata": 1},
   "«Le stirpi continuano», dice guardando i piccoli. «È questo, il Giardino.»"],
  ["Il bosco", "Raccogli cento colture.", ("stat", "raccolti", 100), {"lumino": 500},
   "Pianta un albero accanto alla sua casa. «Tra cent'anni sarà un bosco. Tornerò a vederlo.»"],
 ], ["laccio", 3]),
 "cantastorie": ([
  ["La prima storia", "Leggi trenta stele.", ("stat", "stele", 30), {"tavoletta_seminatori": 2},
   "Te la racconta di sera, accanto al Focolare. Gli abitanti ascoltano in silenzio."],
  ["Le parole rubate", "Dieci eco di parola.", ("item", "eco_parola", 10), {"stilo_seminatori": 1},
   "Le libera una a una nell'aria. Alcune tornano a lei, come uccelli."],
  ["La parola prima", "La parola prima.", ("item", "parola_prima", 1), {"linfa_antica": 2},
   "La pronuncia una volta sola, piano. L'Albero-Madre, lontano, muove una foglia."],
  ["Gli scrigni", "Apri quindici scrigni a parola.", ("stat", "scrigni_parola", 15), {"polvere_iridata": 1},
   "«Ogni scrigno è una frase finita», dice. «Ne restano tante da finire.»"],
  ["L'ultima storia", "Leggi cento stele.", ("stat", "stele", 100), {"lumino": 500},
   "Racconta la storia del Seme Nero, tutta. Quando finisce, nessuno parla per molto tempo."],
 ], ["stilo_seminatori", 1]),
 "tessitrice": ([
  ["Il primo filo", "Dieci macchine in un mondo.", ("stat", "macchine", 10), {"vena_ambra": 10},
   "Segue le tue vene con un dito. «Le hai posate bene. Si sente.»"],
  ["La Linfa rappresa", "Dieci Linfe rappresa.", ("item", "linfa_rappresa", 10), {"valvola_sfogo": 1},
   "«I Succhiavena non sono cattivi», dice. «Hanno fame. Come tutti.»"],
  ["La tempesta", "Tre Centrali risvegliate.", ("stat", "centrali", 3), {"vena_cristallo": 10},
   "Guarda il cielo. «Quando la Linfa ribolle, la rete deve respirare. Ricordatelo.»"],
  ["Le lucciole", "Dieci luci di vena.", ("item", "luce_vena", 10), {"ampolla_lucciole": 1},
   "Le lascia volare sopra le vene. «Ecco. Ora sai dove scorre.»"],
  ["La trama del mondo", "Trenta macchine in un mondo.", ("stat", "macchine", 30), {"lumino": 500},
   "«Tutto il mondo è una rete», dice. «Tu hai imparato a vederla.»"],
 ], ["vena_cristallo", 10]),
 "innestatrice": ([
  ["La mano", "Innesta tre Semi.", ("stat", "innesti", 3), {"linfa_antica": 1},
   "«Hai la mano ferma», dice. «Il resto si impara.»"],
  ["I geni rari", "Impara quindici geni.", ("stat", "geni_imparati", 15), {"fiala_vene_ricche": 1},
   "Ti mostra un gene che non conoscevi. «L'ho trovato in un mondo che nessuno ricorda.»"],
  ["La mutazione", "Due Semi mutati.", ("stat", "mutazioni", 2), {"linfa_antica": 2},
   "«Una mutazione è un mondo che sceglie da solo», dice. «Rispettala.»"],
  ["Le leggende", "Una leggenda compiuta.", ("stat", "leggende", 1), {"polvere_iridata": 2},
   "Per la prima volta ride forte. «Allora esistono davvero.»"],
  ["Il Seme perfetto", "Impara trenta geni.", ("stat", "geni_imparati", 30), {"lumino": 500},
   "«Non esiste un Seme perfetto», dice, «esiste il Seme giusto per chi lo pianta.»"],
 ], ["fiala_rovine_fitte", 1]),
 "cartografo": ([
  ["La mappa bianca", "Trova tre firme.", ("stat", "firme", 3), {"mappa_firma": 1},
   "Segna i tre luoghi sulla sua mappa, con cura. «Ora sono veri.»"],
  ["I Sigilli", "Apri tre Sigilli.", ("stat", "sigilli", 3), {"mappa_sigilli": 1},
   "«I Seminatori chiudevano ciò che temevano», dice. «O ciò che amavano troppo.»"],
  ["I segreti", "Trova quindici segreti.", ("stat", "segreti", 15), {"linfa_antica": 1},
   "Ti chiede di raccontarli tutti, uno per uno, e li disegna a margine."],
  ["Il mondo intero", "Un mondo con tutti i segreti trovati.", ("stat", "mondi_completi", 1), {"polvere_iridata": 2},
   "«Un mondo intero», ripete. «Non l'ha mai fatto nessuno, che io sappia.»"],
  ["L'atlante", "Trova otto firme.", ("stat", "firme", 8), {"lumino": 500},
   "Ti regala il suo atlante. «La mia mappa finisce qui. La tua comincia.»"],
 ], ["mappa_firma", 1]),
}
LV = [1, 1, 2, 3, 4]


def gd(v):
    if isinstance(v, dict):
        return "{" + ", ".join('"%s": %s' % (k, gd(x)) for k, x in v.items()) + "}"
    if isinstance(v, str):
        return '"%s"' % v.replace('"', '\\"')
    return str(v)


out = ['class_name NpcStoriesData', 'extends RefCounted',
       '## Le storie degli abitanti (Roadmap 22, voce 231): cinque capitoli per abitante, dopo le sue richieste di sempre.',
       "## Un capitolo si apre con l'affetto (`lvl`: livello dell'affetto), ha una richiesta (oggetti `need` o un traguardo",
       '## `stat` + `n`), un premio e una **scena** (il racconto che compare consegnandolo). Finita la storia, l\'abitante vende',
       '## una merce in più (`FINAL`). Scritto da `tools/gen_storie.py` (python, 29 set 2026): si cambia là e si rilancia, o',
       '## si ritocca a mano. Le regole in `NpcBonds`.', '', 'const STORIES := {']
fin = ['const FINAL := {']
for npc, (chs, final) in S.items():
    out.append('\t"%s": [' % npc)
    for i, c in enumerate(chs):
        title, text, req, reward, scene = c
        d = {"title": title, "text": text, "lvl": LV[i]}
        if req[0] == "item":
            d["need"] = {req[1]: req[2]}
        else:
            d["stat"] = req[1]
            d["n"] = req[2]
        d["reward"] = reward
        d["scene"] = scene
        out.append('\t\t%s,' % gd(d))
    out.append('\t],')
    fin.append('\t"%s": ["%s", %d],' % (npc, final[0], final[1]))
out.append('}')
fin.append('}')
io.open('src/data/npc_stories_data.gd', 'w', encoding='utf-8', newline='').write("\n".join(out) + "\n\n## La merce che l'abitante vende in più a storia finita.\n" + "\n".join(fin) + "\n")
print('ok', sum(len(v[0]) for v in S.values()))
