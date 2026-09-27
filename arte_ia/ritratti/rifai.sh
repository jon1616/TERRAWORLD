#!/bin/sh
# Rifà i ritratti degli abitanti (arte/ritratti/) dalle tavole di Nano Banana: sh arte_ia/ritratti/rifai.sh
python tools/tavola.py arte_ia/ritratti/01_abitanti_v1.png --griglia 4x2 --nomi viandante,erborista,forgiatore,vecchia_radice,mercante_semi,mandriano,innestatrice,cartografo --cartella arte/ritratti --lato 56 --colori 16 --misure 48,56 --dettagli 2.0
