#!/bin/sh
# Rifà le vignette delle pagine di storia (arte/storia/, nomi = chiavi di LoreData.PAGES): sh arte_ia/storia/rifai.sh
V="python tools/illustrazione.py --largo 240 --vignette"
$V arte_ia/storia/01_mito_v1.png arte/storia --nomi albero_addormentato,albero_primo_respiro,albero_linfa,albero_memoria,albero_sveglio,cuore_trovato,portale,seme_primo,primo_compiuto
$V arte_ia/storia/02_guardiani_v1.png arte/storia --nomi guardiano_sconfitto,regina_sconfitta,colosso_sconfitto,nero_spezzato,generato_sconfitto,guardiano_curato,regina_curata,colosso_curato,nero_curato,generato_curato
$V arte_ia/storia/01c_mito_ritocchi_v1.png arte/storia --nomi albero_addormentato,cuore_trovato,primo_compiuto
$V arte_ia/storia/03_custodi_v1.png arte/storia --nomi custode_madre,custode_tessitrice,custode_serpe,custode_mietitore,custode_cervo,custode_salamandre
