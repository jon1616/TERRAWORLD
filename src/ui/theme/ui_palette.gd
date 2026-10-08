class_name UiPalette
extends RefCounted
## I colori dell'interfaccia (voce 270; rivista nella Roadmap 55 «Il volto chiaro»): un posto solo, così un ritocco cambia
## tutto il gioco. Inchiostro verde-notte per i fondi, un filo di Linfa per i bordi, l'ambra per ciò che conta.
## Tre colori hanno un significato fisso in tutto il gioco: BUONO (ti aiuta, ce l'hai), PERICOLO (ti nuoce, ti manca),
## AMBRA (il nome, il titolo, la cosa da guardare). Il resto è testo in tre toni.

const FONDO := Color("#081011")
const PANNELLO := Color("#0f1a1b")
const PANNELLO_ALTO := Color("#152325")
const PANNELLO_VIVO := Color("#1c2f30")
const BORDO := Color("#2b4e4b")
const BORDO_CHIARO := Color("#4d9c90")
const RADICE := Color("#3a2630")
const RADICE_CHIARA := Color("#6a4a52")
const FOGLIA := Color("#3aa08a")
const LINFA := Color("#7fe6d2")
const AMBRA := Color("#f0b45c")
const AMBRA_CHIARA := Color("#ffd59a")
const TESTO := Color("#e8efe9")
const TESTO_SPENTO := Color("#a9bdb6")
const TESTO_MUTO := Color("#71877f")
const BUONO := Color("#8fe0a4")
const PERICOLO := Color("#ff7a66")
const OMBRA := Color(0.0, 0.0, 0.0, 0.5)

## La scala del testo (Roadmap 55): Alegreya Sans ha l'occhio più piccolo del carattere di prima, quindi due pixel in più.
const MINI := 13
const NOTA := 14
const TESTO_PX := 16
const GRANDE := 18
const SOTTOTITOLO := 22
const TITOLO := 32

## Gli spazi (Roadmap 55): multipli di 4. Tra le righe di una sezione 6, tra le sezioni 18, dentro i riquadri 20.
const SPAZIO := 4
const RIGA := 6
const SEZIONE := 18
const MARGINE := 20
