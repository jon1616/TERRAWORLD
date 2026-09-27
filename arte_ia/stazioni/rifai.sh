#!/bin/sh
# Rifà le stazioni (arte/stazioni/, misura di ogni stazione da StationsData, 16 px per tessera). Le stazioni a gradi
# (_1, _2, _3) hanno un disegno solo con la parte del materiale in grigio (nome senza il numero): le colora il gioco.
# sh arte_ia/stazioni/rifai.sh
T="python tools/tavola.py"
D="--cartella arte/stazioni --stazioni --colori 16 --pieno 0.28"
$T arte_ia/stazioni/01_banchi_v1.png --griglia 4x3 --nomi ceppo,baccello_ardente,maglio,alambicco,telaio,mola,paiolo,focolare,lampada,tavolo,sedia,letto $D
