#!/bin/sh
# Rifà tutte le icone dell'interfaccia (arte/interfaccia/) dalle tavole di Nano Banana, in ordine: le tavole dopo
# sostituiscono i pezzi rifatti di quelle prima. Lanciare dalla cartella del progetto: sh arte_ia/interfaccia/rifai.sh
T="python tools/tavola.py"
D="--cartella arte/interfaccia --lato 16 --misure 16,20"
$T arte_ia/interfaccia/01_prova_v1.png --nomi vita,linfa,scorza,x1,x2,x3 --cartella arte/interfaccia --lato 20 --misure 16,20
rm -f arte/interfaccia/x1.png arte/interfaccia/x2.png arte/interfaccia/x3.png
$T arte_ia/interfaccia/02_elementi_stati_v1.png --griglia 6x3 --nomi brace,gelo,spora,linfa_elemento,vuoto,luce,vapore,fiammata,cristallo,squarcio,vulnerabile,accecato,freddo,sete,calore,polvere,stordito,rallentato $D
$T arte_ia/interfaccia/02b_ritocchi_v1.png --griglia 3x1 --nomi x1,x2,rallentato $D
$T arte_ia/interfaccia/02c_ritocchi_v1.png --griglia 2x1 --nomi accecato,stordito $D
rm -f arte/interfaccia/x1.png arte/interfaccia/x2.png
$T arte_ia/interfaccia/03_poteri_pannelli_v1.png --griglia 6x2 --nomi potere_vista,potere_canto,potere_passo,potere_brace,potere_salto,potere_ponte,pannello_bisaccia,pannello_mappa,pannello_erbario,pannello_semenzaio,pannello_enciclopedia,pannello_mandria $D
$T arte_ia/interfaccia/03b_ritocchi_pannelli_v1.png --griglia 6x1 --nomi potere_ponte,pannello_mandria,potere_salto,pannello_bacheca,pannello_albero,pannello_opzioni $D
