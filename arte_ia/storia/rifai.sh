#!/bin/sh
# Rifà le vignette delle pagine di storia (arte/storia/, nomi = chiavi di LoreData.PAGES): sh arte_ia/storia/rifai.sh
V="python tools/illustrazione.py --largo 240 --vignette"
$V arte_ia/storia/01_mito_v1.png arte/storia --nomi albero_addormentato,albero_primo_respiro,albero_linfa,albero_memoria,albero_sveglio,cuore_trovato,portale,seme_primo,primo_compiuto
