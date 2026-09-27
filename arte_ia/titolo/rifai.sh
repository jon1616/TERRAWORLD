#!/bin/sh
# Rifà lo sfondo e il logo del menu (arte/titolo/) e l'anteprima prove/arte_menu.png: sh arte_ia/titolo/rifai.sh
python tools/illustrazione.py --sfondo arte_ia/titolo/01_sfondo_v1.jpg arte/titolo/sfondo.png --largo 400
python tools/illustrazione.py --logo arte_ia/titolo/02_logo_v1.png arte/titolo/logo.png --largo 150
python tools/illustrazione.py --prova-menu arte/titolo/sfondo.png arte/titolo/logo.png
