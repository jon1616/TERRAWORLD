#!/bin/sh
# Rifà le stazioni (arte/stazioni/, misura di ogni stazione da StationsData, 16 px per tessera). Le stazioni a gradi
# (_1, _2, _3) hanno un disegno solo con la parte del materiale in grigio (nome senza il numero): le colora il gioco.
# sh arte_ia/stazioni/rifai.sh
T="python tools/tavola.py"
D="--cartella arte/stazioni --stazioni --colori 16 --pieno 0.28"
$T arte_ia/stazioni/01_banchi_v1.png --griglia 4x3 --nomi ceppo,baccello_ardente,maglio,alambicco,telaio,mola,paiolo,focolare,lampada,tavolo,sedia,letto $D
$T arte_ia/stazioni/02_totem_trappole_v1.png --griglia 6x4 --nomi totem_germoglio,totem_riposo,totem_fortuna,totem_luce,totem_quiete,x1,totem_guardia,totem_stirpi,totem_saccheggio,x2,totem_purezza,totem_rifugio,trappola_spuntoni,trappola_lama,trappola_runa_brace,trappola_runa_gelo,trappola_runa_spora,trappola_runa_vuoto,x3,trappola_pressa,trappola_getto_brace,x4,trappola_getto_acqua,trappola_rete $D
$T arte_ia/stazioni/03_casse_casa_v1.png --nomi cesta,cassa_legnoferro,forziere_ambra,scrigno_linfa,arca_vuoto,arca_stellare,x1,scrigno_antico,arca_seminatori,scrigno,porta,porta_aperta,x2,fagotto,bacheca,banco_innesti,reliquiario,recinto,incubatrice,leggio --riempi porta,porta_aperta $D
$T arte_ia/stazioni/04_meccanismi_v1.png --griglia 6x3 --nomi leva_trappole,leva_trappole_su,esca,esca_legnoferro,esca_ambra,tramoggia,tramoggia_ambra,nastro_dx,nastro_sx,stella_eterna,braciere,braciere_acceso,leva,leva_su,piastra,piastra_premuta,cristallo_eco,cristallo_eco_desto $D
$T arte_ia/stazioni/05_grandi_v1.png --griglia 4x3 --nomi bozzolo_madre_grumi,bozzolo_tessitrice,bozzolo_serpe_madre,bozzolo_mietitore,bozzolo_grande_cervo,bozzolo_madre_salamandre,bozzolo_rotto,cuore_mondo,cuore_vivo,portale,aiuola,altare $D --colori 24
$T arte_ia/stazioni/06_ultime_v1.png --griglia 4x3 --nomi radice_viandante,totem_antico_germoglio,totem_antico_quiete,totem_antico_stirpi,radice_ancora,arena,nido_erba,nido_tana,nido_alveare,nido_formicaio,stele,pianta_seme $D --colori 20
