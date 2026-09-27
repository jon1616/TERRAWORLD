#!/bin/sh
# Rifà le forme delle icone degli oggetti (arte/forme/, 16 px, parte del materiale in grigio: la colora ItemIcons con
# la tavolozza di ogni materiale). Nomi = forme di ItemsData ("icon"[0]). sh arte_ia/icone/rifai.sh
T="python tools/tavola.py"
D="--cartella arte/forme --lato 16 --misure 16,32 --pieno 0.25"
$T arte_ia/icone/01_armi_attrezzi_v1.png --griglia 6x2 --nomi piccone,ascia,spada,spadone,pugnale,lancia,mazza,falcione,frusta,arco,balestra,trivella $D
$T arte_ia/icone/02_armature_accessori_v1.png --griglia 6x2 --nomi elmo,corazza,gambali,mantello,stivali,guanti,amuleto,anello,lingotto,gemma,pozione,verga $D
